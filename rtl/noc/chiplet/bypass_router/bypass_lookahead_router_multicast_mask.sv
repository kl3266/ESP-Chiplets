// 2D mesh NoC router
//
// This module is a 5x5 router with 1 local port and 4 link ports (north, south, west, east) to
// route data. The routing algorithm is XY Dimension Order. The router uses a worm-hole flow-control
// at network level and an ACK/NACK or credit-based flow control at link level. Links can tolerate
// wire pipeline through the insertion of relay stations. The router implements routing look-ahead,
// performing routing for the following hop and carrying the routing result into the head flit of
// the worm. In case of incoming head flit directed to a free output without contention the flit is
// forwarded in a single clock cycle. In case of contention, the worm arriving from the port with
// the current highest priority is forwarded one cycle after the tail flit of the previous worm.
//
// This module has been implemented in SystemVerilog based on the original VHDL implementation from
// the Columbia University open-source project ESP: https://github.com/sld-columbia/esp
//
// The original copyright notice and author information are included below.
//
// Interface
//
// * Inputs
// - clk: all signals are synchronous to this clock signal.
// - rst: active high reset
// - position: static input that encodes the x,y coordinates of the router on the mesh.
// - data_X_in: input data for each port (North, South, West, East, Local).
// - data_void_in: each bit indicates if the corresponding data_X_in holds valid data.
// - stop_in: when using ACK/NACK flow control, stop_in[X] is 0 to indicate that the corresponding
//   output port X is ready to accept a new flit; when using credit-based flow control, stop_in[X]
//   is 0 to send credits back for the output port X.
//
// * Outputs
// - data_X_out: output data for each port (North, South, West, East, Local).
// - data_void_out: each bit indicates if the corresponding data_X_out holds valid data.
// - stop_out: when using ACK/NACK flow control, stop_out[X] is 0 to indicate that the corresponding
//   input port X is ready to accept a new flit; when using credit-based flow control, stop_in[X] is
//   0 to send credits back for the input port X.
//
// * Parameters
// - FlowControl: either ACK/NACK (stop-void) or credit-based
// - DataWidth: width of the router port, except for the two preaamble bits indicating head and
//   tail. DataWidth must be large enough to hold the header flit information for routing:
//   DataWidth > $bits(noc::packet_info_t) + $bits(noc::direction_t).
// - PortWidth: DataWidth + 2. This parameter is used to define input ports.
//   and should not be overwritten.
// - Ports: each bit is set to 1 to indicate that the corresponding input and output port is
//   enabled. This parameter can be used to disable ports on the fringe of the NoC mesh.
//

////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
// Author: Michele Petracca
////////////////////////////////////////////////////////////////////////////////

module bypass_lookahead_router_multicast_mask #(
    parameter noc::noc_flow_control_t FlowControl = noc::kFlowControlAckNack,
    parameter int unsigned DataWidth = 64,
    parameter int unsigned PortWidth = DataWidth + $bits(noc::preamble_t),
    parameter bit [3:0] Ports = noc::AllPorts,
    parameter integer QUEUE_SIZE = 4,
    parameter noc::chip_xy_t chip = '0
) (
    input  logic clk,
    input  logic rst,
    // Input ports
    input  logic [PortWidth-1:0] data_n_in,
    input  logic [PortWidth-1:0] data_s_in,
    input  logic [PortWidth-1:0] data_w_in,
    input  logic [PortWidth-1:0] data_e_in,
    input  logic [3:0] data_void_in,
    output logic [3:0] stop_out,
    // Output ports
    output logic [PortWidth-1:0] data_n_out,
    output logic [PortWidth-1:0] data_s_out,
    output logic [PortWidth-1:0] data_w_out,
    output logic [PortWidth-1:0] data_e_out,
    output logic [3:0] data_void_out,
    input  logic [3:0] stop_in
);

    localparam int unsigned ReservedWidth = DataWidth - 3 * $bits(  // SRC, DEST, DEST_MASK
        noc::xy_t
    ) - 3 * $bits(
        noc::chip_xy_t
    ) - $bits(
        noc::message_t
    ) - $bits(
        noc::tile_t
    ) - $bits(
        noc::plane_t
    ) - $bits(
        noc::routing_lock_t
    ) - $bits(
        noc::pkt_type_t
    ) - $bits(
        noc::mcast_t
    ) - $bits(
        noc::direction_t
    );

	    localparam int unsigned CreditsWidth = $clog2(QUEUE_SIZE + 1);
	    typedef logic [3:0][CreditsWidth-1:0] credits_t;
	    localparam int unsigned ReservedPreChipMaskWidth = 2;
	    localparam int unsigned DestinationChipMaskPreWidth =
	        $bits(noc::preamble_t) + 2*$bits(noc::xy_t) + $bits(noc::message_t) +
	        $bits(noc::mcast_routing_lock_t) + $bits(noc::plane_t) +
	        $bits(noc::routing_lock_t) + 2*$bits(noc::chip_xy_t) +
	        $bits(noc::pkt_type_t) + $bits(noc::mcast_t) + $bits(noc::xy_t) +
	        ReservedPreChipMaskWidth;

    // Modified the structure to add more destinations and a valid bit for each destination
    typedef struct packed {
        noc::xy_t source;
        noc::xy_t destination;
        noc::message_t message;
        noc::mcast_routing_lock_t mcast_routing_lock; // On-chip: use as mcast_routing_lock. When goes chiplet, use as tile.
        noc::plane_t plane; // for D2D use
        noc::routing_lock_t routing_lock; // 0 - on-chip; 1 - off-chip - for unicast
        noc::chip_xy_t source_chip; // for D2D use
        noc::chip_xy_t destination_chip;  // for D2D use
        noc::pkt_type_t uni_or_mcast;  // 0 - unicast; 1 - mcast; for D2D RX use
        noc::mcast_t mcast_type;    // 0 - tree; 1 - brcp
        noc::xy_t destination_mask; // unicast -- all 0
        logic [ReservedWidth-1:0] reserved; // 64b - 2 bits;
        noc::chip_xy_t destination_chip_mask; // use this field and 2 bits of reserved for unicast reserved bits; KL address D2D RX & bypass router routing to accommodate this
      } packet_info_t;

    localparam bit FifoBypassEnable = FlowControl == noc::kFlowControlAckNack;

    typedef struct packed {
        noc::preamble_t preamble;
        packet_info_t info;
        noc::direction_t routing;
    } header_t;

    typedef logic [PortWidth-1:0] payload_t;

	    typedef union packed {
	        header_t  header;
	        payload_t flit;
	    } flit_t;

	    function automatic noc::chip_xy_t flit_destination_chip_mask(
	        input logic [PortWidth-1:0] flit
	    );
	        return flit[PortWidth-DestinationChipMaskPreWidth-1 -: $bits(noc::chip_xy_t)];
	    endfunction

    typedef enum logic [1:0] {
        kReservePort  = 2'b00,
        kHeadFlit     = 2'b01,
        kPayloadFlits = 2'b10
    } state_t;

    state_t state [3:0];
    state_t new_state [3:0];

    flit_t data_in [3:0];
    flit_t fifo_head [3:0];
    flit_t data_out_crossbar [3:0];
    flit_t last_flit [3:0];
    flit_t fifo_head_routing [3:0];

    logic [3:0] saved_routing_request [3:0];
    logic [3:0] final_routing_request [3:0];  // ri lint_check_waive NOT_READ

    //mcast arbiter logic
    logic [3:0] bp_frr [3:0];
    logic [3:0] case_b [3:0];
    logic [3:0] case_c [3:0];
    logic [3:0] unicast_req [3:0];
    logic [3:0] new_final_routing_request [3:0];
    logic [3:0] granted_req [3:0];
    logic output_reserved [3:0];

    logic mcast_input_initial [3:0];
    logic unicast_req_OR [3:0];
    logic [3:0] mcast_input_c, grant_mcast;
    logic grant_mcast_arbiter [3:0];
    logic grant_valid_mcast;

    logic [2:0] transp_final_routing_request [3:0];
    logic [3:0] enhanc_routing_configuration [3:0];
    logic [2:0] saved_routing_configuration [3:0];
    logic [2:0] grant [3:0];
    logic grant_valid [3:0];

    logic [3:0] input_throttled;
//    logic [4:0] rd_fifo_vector [4:0];

    logic [3:0] rd_fifo [3:0];
    logic no_backpressure_mcast [3:0];
    logic no_backpressure_single [3:0];

    logic [3:0] backpressure_single;
    logic rd_fifo_or [3:0];

    logic in_unvalid_flit [3:0];
    logic out_unvalid_flit [3:0];
    logic [3:0] in_valid_head;

    logic full [3:0];
    logic empty [3:0];
    logic wr_fifo [3:0];
//    noc::noc_port_t input_direction [4:0];

    credits_t credits;

    logic forwarding_tail [3:0];
    logic forwarding_head [3:0];
    logic [3:0] forwarding_tail_input;
    logic forwarding_in_progress [3:0];
    logic insert_lookahead_routing [3:0];
    logic sample_routing_config [3:0];
    logic [3:0] reset_arbiter;
    logic rst_arbiter [3:0];

    assign data_in[noc::kNorthPort] = data_n_in;
    assign data_in[noc::kSouthPort] = data_s_in;
    assign data_in[noc::kWestPort] = data_w_in;
    assign data_in[noc::kEastPort] = data_e_in;
    //This router has a two cycle delay.
    // When using ready-valid protocol, the register is placed at the output; for credit-based,
    // the register is the input FIFO (not bypassable) and the output of the crossbar is not
    // registered.
    assign data_n_out = FifoBypassEnable ? last_flit[noc::kNorthPort] :
                      data_out_crossbar[noc::kNorthPort];
    assign data_s_out = FifoBypassEnable ? last_flit[noc::kSouthPort] :
                      data_out_crossbar[noc::kSouthPort];
    assign data_w_out = FifoBypassEnable ? last_flit[noc::kWestPort]  :
                      data_out_crossbar[noc::kWestPort];
    assign data_e_out = FifoBypassEnable ? last_flit[noc::kEastPort]  :
                      data_out_crossbar[noc::kEastPort];

    genvar g_i;

    //////////////////////////////////////////////////////////////////////////////
    // Input FIFOs and look-ahead routing
    //////////////////////////////////////////////////////////////////////////////
    for (g_i = 0; g_i < 4; g_i++) begin : gen_input_fifo
        if (Ports[g_i]) begin : gen_input_port_enabled
            logic [3:0] rd_fifo_column;
            // Read FIFO if any of the output ports requests data.
            // The FIFO won't update read pointer if empty
//            always_comb begin
//              for (int i=0; i<5; i++) begin
//                rd_fifo_column[i] = rd_fifo[i][g_i];
//              end
//            end
//            assign rd_fifo_or[g_i] = |rd_fifo_column;
            assign rd_fifo_or[g_i] = rd_fifo[0][g_i] | rd_fifo[1][g_i] | rd_fifo[2][g_i] |
                               rd_fifo[3][g_i];

            // Write FIFO if data is valid.
            // The FIFO won't accept the write if full.
            assign wr_fifo[g_i] = ~data_void_in[g_i];

            // Input FIFO
            router_fifo #(
                .BypassEnable(FifoBypassEnable),
                .Depth(QUEUE_SIZE),
                .Width(PortWidth)
            ) input_queue (
                .clk,
                .rst,
                .rdreq(rd_fifo_or[g_i]),
                .wrreq(wr_fifo[g_i]),
                .data_in(data_in[g_i]),
                .empty(empty[g_i]),
                .full(full[g_i]),
                .data_out(fifo_head[g_i])
            );

            assign in_unvalid_flit[g_i] = FifoBypassEnable ? empty[g_i] & data_void_in[g_i] : empty[g_i];
            assign in_valid_head[g_i] = fifo_head[g_i].header.preamble.head & ~in_unvalid_flit[g_i];

            always_ff @(posedge clk) begin
                if (rst) begin
                    saved_routing_request[g_i] <= '0;
                end else begin
                    if (forwarding_tail_input[g_i]) begin
                        // Clear saved_routing_request if tail is next
                        saved_routing_request[g_i] <= '0;
                    end else if (in_valid_head[g_i]) begin
                        // Sample saved_routing_request if valid head flit
                        saved_routing_request[g_i] <= fifo_head[g_i].header.routing;
                    end
                end
            end

            assign final_routing_request[g_i] = in_valid_head[g_i] ? fifo_head[g_i].header.routing :
                                            saved_routing_request[g_i];
            assign bp_frr[g_i] = |(final_routing_request[g_i] & backpressure_single) ? '0 : final_routing_request[g_i];
//            assign mcast_input_initial[g_i] = |(bp_frr[g_i] & (bp_frr[g_i] - 1));
            assign mcast_input_initial[g_i] = (bp_frr[g_i][0] & (|bp_frr[g_i][3:1])) |
                                              (bp_frr[g_i][1] & (|bp_frr[g_i][3:2])) |
                                              (bp_frr[g_i][2] & (|bp_frr[g_i][3]));
            assign unicast_req[g_i] = bp_frr[g_i] & {4{~mcast_input_initial[g_i]}};
            assign granted_req[g_i] = {4{grant_mcast_arbiter[g_i]}} & case_b[g_i];
            assign new_final_routing_request[g_i] = case_c[g_i] | granted_req[g_i] | unicast_req[g_i];
            assign forwarding_tail_input[g_i] = fifo_head[g_i].header.preamble.tail & ~in_unvalid_flit[g_i] & rd_fifo_or[g_i];
            assign grant_mcast_arbiter[g_i] = grant_valid_mcast & grant_mcast[g_i];

            logic [3:0] rd_fifo_vector;
            assign rd_fifo_vector = { enhanc_routing_configuration[3][g_i],
                                      enhanc_routing_configuration[2][g_i],
                                      enhanc_routing_configuration[1][g_i],
                                      enhanc_routing_configuration[0][g_i] };
            //always_comb begin
            //    for (int j = 0; j < 5; j++) begin
            //        rd_fifo_vector[g_i][j] = enhanc_routing_configuration[j][g_i];
            //    end
            assign input_throttled[g_i] = |(rd_fifo_vector & backpressure_single);
            //end

            // AckNack: stop data at input port if FIFO is full
            // CreditBased: send credits when reading from the input FIFO
            assign stop_out[g_i] =  FifoBypassEnable ? full[g_i] :
                                ~(rd_fifo_or[g_i] & ~in_unvalid_flit[g_i]);
        end else begin : gen_input_port_disabled

            assign stop_out[g_i]                       = 1'b1;
            assign final_routing_request[g_i]          = '0;
            assign saved_routing_request[g_i]          = '0;
            assign in_unvalid_flit[g_i]                = '1;
            assign fifo_head[g_i]                      = '0;
            assign empty[g_i]                          = 1'b1;
            assign full[g_i]                           = '0;
            assign rd_fifo_or[g_i]                     = '0;
            assign wr_fifo[g_i]                        = '0;
            assign in_valid_head[g_i]                  = 1'b0;
            assign granted_req[g_i]                    = '0;
            assign new_final_routing_request[g_i]      = '0;
            assign mcast_input_initial[g_i]            = '0;
            assign forwarding_tail_input[g_i]          = 1'b0;
            assign grant_mcast_arbiter[g_i]            = 1'b0;
            assign unicast_req[g_i]                    = '0;
            assign bp_frr[g_i]                         = '0;
            assign input_throttled[g_i]                = 1'b0;
            //assign rd_fifo_vector[g_i]                 = '0;
        end  // if (Ports[g_i])

    end  // for gen_input_fifo

    always_comb begin
        logic [3:0] req [3:0];
        logic [3:0] col_vec, conflict_mask, port_blocked;

        for (int i = 0; i < 4; i++) begin
            req[i] = final_routing_request[i] & {4{mcast_input_initial[i]}};
            for (int j = 0; j < 4; j++) begin
                port_blocked[j] = unicast_req_OR[j] ||
                  (output_reserved[j] &&
                  !enhanc_routing_configuration[j][i]);
            end  //end j for
            if ((req[i] & port_blocked) != '0) begin
                case_b[i] = 4'b0000;
            end else begin
                case_b[i] = req[i];
            end
        end  //end i for

        conflict_mask = '0;
        for (int i = 0; i < 4; i++) begin  //i = output
            col_vec = {req[3][i], req[2][i], req[1][i], req[0][i]};
            //col_vec = {case_b[3][i], case_b[2][i], case_b[1][i], case_b[0][i]}; // Above line --> better for area and timing. This one improves performance by ~10%
            //if ((col_vec & (col_vec - 5'b1)) != '0) begin
            conflict_mask[i] = (col_vec[0] & (|col_vec[3:1])) |
                               (col_vec[1] & (|col_vec[3:2])) |
                               (col_vec[2] & (|col_vec[3]));
//            if ((col_vec[0] & (|col_vec[4:1])) |
//                (col_vec[1] & (|col_vec[4:2])) |
//                (col_vec[2] & (|col_vec[4:3])) |
//                (col_vec[3] & col_vec[4])) begin
//              conflict_mask[i] = 1'b1;
//            end
        end  //end i for

        for (int i = 0; i < 4; i++) begin
            if ((case_b[i] & conflict_mask) != '0) begin
                mcast_input_c[i] = 1'b1;
                case_c[i] = 4'b0000;
            end else begin
                mcast_input_c[i] = 1'b0;
                case_c[i] = case_b[i];
            end
        end
    end  //end always_comb

    bypass_router_mcast_arbiter mcast_arbiter_i (
        .clk(clk),
        .rst(rst),
        .request(mcast_input_c),
        .forwarding_head(in_valid_head),
        .forwarding_tail(forwarding_tail_input),
        .reset_arbiter(reset_arbiter),
        .grant(grant_mcast),
        .grant_valid(grant_valid_mcast)
    );

    //////////////////////////////////////////////////////////////////////////////
    // Output crossbar and arbitration
    //////////////////////////////////////////////////////////////////////////////
    for (g_i = 0; g_i < 4; g_i++) begin : gen_output_control
        genvar g_j;
        if (Ports[g_i]) begin : gen_output_port_enabled
            assign output_reserved[g_i] = (state[g_i] != kReservePort);
            assign unicast_req_OR[g_i] = unicast_req[0][g_i] | unicast_req[1][g_i] | unicast_req[2][g_i] | unicast_req[3][g_i];
            for (g_j = 0; g_j < 4; g_j++) begin : gen_transpose_routing
                // transpose current routing request for easier accesss, but
                // allow routing only to output port different from input port
                if (g_j < g_i) begin : gen_transpose_routin_j_lt_i
                    assign transp_final_routing_request[g_i][g_j] = new_final_routing_request[g_j][g_i];
                    assign enhanc_routing_configuration[g_i][g_j] = saved_routing_configuration[g_i][g_j];
                end else if (g_j > g_i) begin : gen_transpose_routin_j_gt_i
                    assign transp_final_routing_request[g_i][g_j-1] = new_final_routing_request[g_j][g_i];
                    assign enhanc_routing_configuration[g_i][g_j] = saved_routing_configuration[g_i][g_j-1];
                end else begin : gen_transpose_routin_j_eq_i
                    assign enhanc_routing_configuration[g_i][g_j] = 1'b0;
                end
            end  // for gen_transpose_routing

            // Arbitration
            bypass_router_arbiter_rtpe arbiter_i (
                .clk(clk),
                .rst(rst_arbiter[g_i]),
                .request(transp_final_routing_request[g_i]),
                .forwarding_head(forwarding_head[g_i]),
                .forwarding_tail(forwarding_tail[g_i]),
                .grant(grant[g_i]),
                .grant_valid(grant_valid[g_i])
            );

            assign rst_arbiter[g_i] = rst || reset_arbiter[g_i];
//            assign input_direction[g_i] = noc::get_direction(
//                enhanc_routing_configuration[g_i]
//            );

            assign rd_fifo[g_i] = {4{no_backpressure_mcast[g_i] && forwarding_in_progress[g_i]}} & enhanc_routing_configuration[g_i];
//            assign rd_fifo[g_i][noc::kNorthPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kNorthPort];
//            assign rd_fifo[g_i][noc::kSouthPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kSouthPort];
//            assign rd_fifo[g_i][noc::kEastPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kEastPort];
//            assign rd_fifo[g_i][noc::kWestPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kWestPort];
//            assign rd_fifo[g_i][noc::kLocalPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kLocalPort];

            // Sample current routing configuration
            always_ff @(posedge clk) begin
                if (rst) begin
                    saved_routing_configuration[g_i] <= '0;
                end else begin
                    if (sample_routing_config[g_i]) begin
                        saved_routing_configuration[g_i] <= grant[g_i];
                    end else if (state[g_i] == kReservePort) begin
                        saved_routing_configuration[g_i] <= '0;
                    end
                end
            end


            // Set to overwrite routing info only on the head flit
            always_ff @(posedge clk) begin
                if (rst) begin
                    // First flit must be head
                    insert_lookahead_routing[g_i] <= 1'b1;
                end else begin
                    if (forwarding_tail[g_i]) begin
                        // Next flit will be head (convers single-flit packet)
                        insert_lookahead_routing[g_i] <= 1'b1;
                    end else if (forwarding_head[g_i]) begin
                        // Next flit will not be head
                        insert_lookahead_routing[g_i] <= 1'b0;
                    end
                end
            end

            // Crossbar
//            always_comb begin
//                fifo_head_routing[g_i] = '0;
//                out_unvalid_flit[g_i]  = 1'b1;
//
//                // for each input port
//                for (int j = 0; j < 5; j++) begin
//                    // j is the current input port for output port g_i
//                    if (enhanc_routing_configuration[g_i][j]) begin
//                      fifo_head_routing[g_i] = fifo_head[j];
//                      out_unvalid_flit[g_i] = in_unvalid_flit[j];
//                    end
//                end
//            end
            noc::chip_xy_t selected_destination;
            noc::chip_xy_t selected_destination_mask;
            noc::pkt_type_t selected_uni_or_mcast;

            always_comb begin : crossbar_onehot_case
              fifo_head_routing[g_i] = '0;
              out_unvalid_flit[g_i]  = 1'b1;
              selected_destination = '0;
              selected_destination_mask = '0;
              selected_uni_or_mcast = 1'b0;
  
              unique0 case (1'b1)
	                (g_i != 0) && enhanc_routing_configuration[g_i][0]: begin
	                  fifo_head_routing[g_i]    = fifo_head[0];
	                  out_unvalid_flit[g_i]     = in_unvalid_flit[0];
	                  selected_destination      = fifo_head[0].header.info.destination_chip;
	                  selected_destination_mask = flit_destination_chip_mask(fifo_head[0].flit);
	                  selected_uni_or_mcast     = fifo_head[0].header.info.uni_or_mcast;
	                end
	                (g_i != 1) && enhanc_routing_configuration[g_i][1]: begin
	                  fifo_head_routing[g_i]    = fifo_head[1];
	                  out_unvalid_flit[g_i]     = in_unvalid_flit[1];
	                  selected_destination      = fifo_head[1].header.info.destination_chip;
	                  selected_destination_mask = flit_destination_chip_mask(fifo_head[1].flit);
	                  selected_uni_or_mcast     = fifo_head[1].header.info.uni_or_mcast;
	                end
	                (g_i != 2) && enhanc_routing_configuration[g_i][2]: begin
	                  fifo_head_routing[g_i] = fifo_head[2];
	                  out_unvalid_flit[g_i]  = in_unvalid_flit[2];
	                  selected_destination      = fifo_head[2].header.info.destination_chip;
	                  selected_destination_mask = flit_destination_chip_mask(fifo_head[2].flit);
	                  selected_uni_or_mcast     = fifo_head[2].header.info.uni_or_mcast;
	                end
	                (g_i != 3) && enhanc_routing_configuration[g_i][3]: begin
	                  fifo_head_routing[g_i] = fifo_head[3];
	                  out_unvalid_flit[g_i]  = in_unvalid_flit[3];
	                  selected_destination      = fifo_head[3].header.info.destination_chip;
	                  selected_destination_mask = flit_destination_chip_mask(fifo_head[3].flit);
	                  selected_uni_or_mcast     = fifo_head[3].header.info.uni_or_mcast;
	                end
              endcase
            end

            localparam logic [1:0] PORT_ID_L = g_i[1:0];
            noc::direction_t next_hop_routing;
            noc::mcast_t next_mcast_type;

            bypass_lookahead_routing_multicast_mask #(
                .W(noc::chip_xWidth),
                .PORT_ID(PORT_ID_L),
                .chip(chip)
            ) bypass_lookahead_routing_multicast_mask_i (
                .chip_destination(selected_destination),
                .chip_destination_mask(selected_destination_mask),
                .uni_or_mcast(selected_uni_or_mcast), // 0 unicast; 1 mcast
                .next_mcast_type(next_mcast_type),
                .next_routing(next_hop_routing)
            );

            always_comb begin
              data_out_crossbar[g_i] = fifo_head_routing[g_i].flit;
              if (insert_lookahead_routing[g_i]) begin
                data_out_crossbar[g_i].header.info.mcast_type = next_mcast_type;
                data_out_crossbar[g_i].header.routing = next_hop_routing;
              end
            end

            // Sample output
            if (FifoBypassEnable) begin
                always_ff @(posedge clk) begin
                    if (rst) begin
                        last_flit[g_i] <= '0;
                    end else begin
                        if (no_backpressure_mcast[g_i] & forwarding_in_progress[g_i] & ~out_unvalid_flit[g_i]) begin
                            last_flit[g_i] <= data_out_crossbar[g_i];
                        end
                    end
                end
            end else begin
                assign last_flit[g_i] = '0;
            end

            // Flow control
            assign backpressure_single[g_i] = FifoBypassEnable ? stop_in[g_i] : (credits[g_i] == '0);
            assign no_backpressure_single[g_i] = ~backpressure_single[g_i];
            assign no_backpressure_mcast[g_i] = ~backpressure_single[g_i] && ~(|(input_throttled & enhanc_routing_configuration[g_i]));
            assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail &
                                   ~out_unvalid_flit[g_i] & no_backpressure_mcast[g_i] & forwarding_in_progress[g_i];
            assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head &
                                    ~out_unvalid_flit[g_i] & no_backpressure_mcast[g_i] &
                                    forwarding_in_progress[g_i];


            always_comb begin : flow_control_fsm
                new_state[g_i]              = state[g_i];
                forwarding_in_progress[g_i] = 1'b0;
                sample_routing_config[g_i]  = 1'b0;
                reset_arbiter[g_i]          = 1'b0;

                unique case (state[g_i])
                    kReservePort: begin
                        if (grant_valid[g_i]) begin
                            sample_routing_config[g_i] = 1'b1;
                            new_state[g_i]             = kHeadFlit;
                        end
                    end

                    kHeadFlit: begin
                        // First flit of a new packet can be forwarded
                        if (no_backpressure_mcast[g_i]) begin
                            forwarding_in_progress[g_i] = 1'b1;
                            // Non-single-flit packet; expecting more payload flit
                            if (forwarding_tail[g_i]) begin
                              new_state[g_i] = kReservePort;
                            end else begin
                              new_state[g_i] = kPayloadFlits;
                            end
                        end else begin
                            reset_arbiter[g_i] = 1'b1;
                            new_state[g_i]     = kReservePort;
                        end
                    end

                    kPayloadFlits: begin
                        // Payload of a packet is being forwarded; do not change routing configuration
                        forwarding_in_progress[g_i] = 1'b1;
                        if (forwarding_tail[g_i]) begin
                            // Next flit must be head
                            new_state[g_i] = kReservePort;
                        end
                    end

                    default: begin
                    end
                endcase  // unique case (state[g_i])
            end

            always_ff @(posedge clk) begin
                if (rst) begin
                    state[g_i] <= kReservePort;
                end else begin
                    state[g_i] <= new_state[g_i];
                end
            end

            // Data void out and credits
            if (FifoBypassEnable) begin : gen_data_void_out_acknack
                always_ff @(posedge clk) begin
                    if (rst) begin
                        data_void_out[g_i] <= 1'b1;
                    end else begin
                        if (~forwarding_in_progress[g_i] && no_backpressure_single[g_i]) begin
                            data_void_out[g_i] <= 1'b1;
                        end else if (no_backpressure_mcast[g_i]) begin
                            data_void_out[g_i] <= out_unvalid_flit[g_i];
                        end else if (no_backpressure_single[g_i]) begin
                            data_void_out[g_i] <= 1'b1;
                        end
                    end
                end
                assign credits[g_i] = '0;
            end else begin : gen_data_void_out_creditbased
                assign data_void_out[g_i] = forwarding_in_progress[g_i] & no_backpressure_mcast[g_i] ?
                                  out_unvalid_flit[g_i] : 1'b1;
                always_ff @(posedge clk) begin
                    if (rst) begin
                        credits[g_i] <= CreditsWidth'(QUEUE_SIZE);
                    end else begin
                        if (~data_void_out[g_i]) begin
                            credits[g_i] <= credits[g_i] - stop_in[g_i];
                        end else begin
                            credits[g_i] <= credits[g_i] + ~stop_in[g_i];
                        end
                    end
                end
            end



        end else begin : gen_input_port_disabled
            assign grant_valid[g_i]                  = '0;
            assign grant[g_i]                        = '0;
            assign saved_routing_configuration[g_i]  = '0;
            assign data_void_out[g_i]                = '1;
            assign out_unvalid_flit[g_i]             = '1;
            assign data_out_crossbar[g_i]            = '0;
            assign last_flit[g_i]                    = '0;
            assign rd_fifo[g_i]                      = '0;
            assign no_backpressure_mcast[g_i]        = '1;
            assign no_backpressure_single[g_i]       = '1;
            assign backpressure_single[g_i]          = '0;
            assign forwarding_tail[g_i]              = '0;
            assign forwarding_head[g_i]              = '0;
            assign forwarding_in_progress[g_i]       = '0;
            assign insert_lookahead_routing[g_i]     = '0;
            assign credits[g_i]                      = '0;
            assign enhanc_routing_configuration[g_i] = '0;
            assign state[g_i]                        = kReservePort;
            assign sample_routing_config[g_i]        = '0;
//            assign input_direction[g_i]              = noc::kNorthPort;
            assign reset_arbiter[g_i]                = '0;
            assign rst_arbiter[g_i]                  = '0;
            assign unicast_req_OR[g_i]               = '0;
            assign fifo_head_routing[g_i]            = '0;
            assign output_reserved[g_i]              = '0;
        end  // block: gen_output_port_enabled

    end  // for gen_output_control

    //////////////////////////////////////////////////////////////////////////////
    // Assertions
    //////////////////////////////////////////////////////////////////////////////

`ifndef SYNTHESIS
    // pragma coverage off
    //VCS coverage off

    if (DataWidth < $bits(packet_info_t) + $bits(noc::direction_t)) begin : gen_a_data_width
        $fatal(2'd2, "Fail: DataWidth insufficient to hold packet and routing information.");
    end

    if ($bits(header_t) != DataWidth + $bits(noc::preamble_t)) begin : gen_a_header_width
        $fatal(
            2'd2,
            "Fail: header_t width (%02d) must be DataWidth (%02d) + preamble_t width (%01d)",
            $bits(
                header_t
            ),
            DataWidth,
            $bits(
                noc::preamble_t
            )
        );
    end

    if (PortWidth != $bits(header_t)) begin : gen_a_port_width
        $fatal(2'd2, "Fail: PortWidth must match header_t width.");
    end

    for (g_i = 0; g_i < 4; g_i++) begin : gen_assert_legal_routing_request
        // a_no_request_to_same_port: assert property (@(posedge clk) disable iff(rst)
        //   final_routing_request[g_i][g_i] == 1'b0)
        //   else $error("Fail: a_no_request_to_same_port");
        a_enhanc_routing_configuration_onehot :
        assert property (@(posedge clk) disable iff (rst) $onehot0(
            enhanc_routing_configuration[g_i]
        ))
        else $error("Fail: a_enhanc_routing_configuration_onehot");
        a_expect_head_flit :
        assert property (@(posedge clk) disable iff(rst)
      ~out_unvalid_flit[g_i] & state[g_i] == kHeadFlit
      |->
      data_out_crossbar[g_i].header.preamble.head)
        else $error("Fail: a_expect_head_flit");
        a_credits_in_range :
        assert property (@(posedge clk) disable iff (rst) credits[g_i] <= QUEUE_SIZE)
        else $error("Fail: a_enhanc_routing_configuration_onehot");
    end

    // pragma coverage on
    //VCS coverage on
`endif  // ~SYNTHESIS

endmodule
