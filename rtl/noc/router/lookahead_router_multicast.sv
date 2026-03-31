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

module lookahead_router_multicast #(
    parameter noc::noc_flow_control_t FlowControl = noc::kFlowControlAckNack,
    parameter int unsigned DataWidth = 64,
    parameter int unsigned PortWidth = DataWidth + $bits(noc::preamble_t),
    parameter bit [4:0] Ports = noc::AllPorts,
    parameter integer QUEUE_SIZE = 4
) (
    input  logic clk,
    input  logic rst,
    // Coordinates
    input  noc::xy_t position,
    // Input ports
    input  logic [PortWidth-1:0] data_n_in,
    input  logic [PortWidth-1:0] data_s_in,
    input  logic [PortWidth-1:0] data_w_in,
    input  logic [PortWidth-1:0] data_e_in,
    input  logic [PortWidth-1:0] data_p_in,
    input  logic [4:0] data_void_in,
    output logic [4:0] stop_out,
    // Output ports
    output logic [PortWidth-1:0] data_n_out,
    output logic [PortWidth-1:0] data_s_out,
    output logic [PortWidth-1:0] data_w_out,
    output logic [PortWidth-1:0] data_e_out,
    output logic [PortWidth-1:0] data_p_out,
    output logic [4:0] data_void_out,
    input  logic [4:0] stop_in
);

    localparam int unsigned ReservedWidth = DataWidth - 3 * $bits(
        noc::xy_t
    ) - $bits(
        noc::message_t
    ) - $bits(
        noc::direction_t
    );

    parameter int unsigned CreditsWidth = $clog2(QUEUE_SIZE + 1);
    typedef logic [CreditsWidth-1:0] credits_t [4:0];

    // Modified the structure to add more destinations and a valid bit for each destination
    typedef struct packed {
        noc::xy_t source;
        noc::xy_t destination;
        noc::message_t message;
        logic [ReservedWidth-1:0] reserved;
        noc::xy_t destination_mask;
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

    typedef enum logic [1:0] {
        kReservePort  = 2'b00,
        kHeadFlit     = 2'b01,
        kPayloadFlits = 2'b10
    } state_t;

    state_t state [4:0];
    state_t new_state [4:0];

    flit_t data_in [4:0];
    flit_t fifo_head [4:0];
    flit_t data_out_crossbar [4:0];
    flit_t last_flit [4:0];
    flit_t fifo_head_routing [4:0];

    logic [4:0] saved_routing_request [4:0];
    logic [4:0] final_routing_request [4:0];  // ri lint_check_waive NOT_READ
    logic [4:0] next_hop_routing [4:0];

    //mcast arbiter logic
    logic [4:0] bp_frr [4:0];
    logic [4:0] case_b [4:0];
    logic [4:0] case_c [4:0];
    logic [4:0] unicast_req [4:0];
    logic [4:0] new_final_routing_request [4:0];
    logic [4:0] granted_req [4:0];

    logic mcast_input_initial [4:0];
    logic unicast_req_OR [4:0];
    logic [4:0] mcast_input_c, grant_mcast;
    logic grant_mcast_arbiter [4:0];
    logic grant_valid_mcast;

    logic [3:0] transp_final_routing_request [4:0];
    logic [4:0] enhanc_routing_configuration [4:0];
    logic [3:0] saved_routing_configuration [4:0];
    logic [3:0] grant [4:0];
    logic grant_valid [4:0];

    logic [4:0] input_throttled;
    logic [4:0] rd_fifo_vector [4:0];

    logic [4:0] rd_fifo [4:0];
    logic no_backpressure_mcast [4:0];
    logic no_backpressure_single [4:0];

    logic [4:0] backpressure_single;
    logic rd_fifo_or [4:0];

    logic in_unvalid_flit [4:0];
    logic out_unvalid_flit [4:0];
    logic [4:0] in_valid_head;

    logic full [4:0];
    logic empty [4:0];
    logic wr_fifo [4:0];

    noc::noc_port_t input_direction [4:0];
    credits_t credits;

//    logic [3:0] arbiter_request_masked [4:0];
    noc::xy_t la_destination [3:0];
    noc::xy_t la_destination_mask [3:0];

    logic forwarding_tail [4:0];
    logic forwarding_head [4:0];
    logic [4:0] forwarding_tail_input;
    logic forwarding_in_progress [4:0];
    logic insert_lookahead_routing [4:0];
    logic sample_routing_config [4:0];
    logic [4:0] reset_arbiter;
    logic rst_arbiter [4:0];

    assign data_in[noc::kNorthPort] = data_n_in;
    assign data_in[noc::kSouthPort] = data_s_in;
    assign data_in[noc::kWestPort] = data_w_in;
    assign data_in[noc::kEastPort] = data_e_in;
    assign data_in[noc::kLocalPort] = data_p_in;
    //This router has a two-cycle delay.
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
    assign data_p_out = FifoBypassEnable ? last_flit[noc::kLocalPort] :
                      data_out_crossbar[noc::kLocalPort];

    genvar g_i;

    //////////////////////////////////////////////////////////////////////////////
    // Input FIFOs and look-ahead routing
    //////////////////////////////////////////////////////////////////////////////
    for (g_i = 0; g_i < 5; g_i++) begin : gen_input_fifo
        if (Ports[g_i]) begin : gen_input_port_enabled

            // Read FIFO if any of the output ports requests data.
            // The FIFO won't update read pointer if empty
            assign rd_fifo_or[g_i] = rd_fifo[0][g_i] | rd_fifo[1][g_i] | rd_fifo[2][g_i] |
                               rd_fifo[3][g_i] | rd_fifo[4][g_i];

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
                    if (fifo_head[g_i].header.preamble.tail) begin
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
            assign mcast_input_initial[g_i] = |(bp_frr[g_i] & (bp_frr[g_i] - 1));
            assign unicast_req[g_i] = bp_frr[g_i] & {5{~mcast_input_initial[g_i]}};
            assign granted_req[g_i] = {5{grant_mcast_arbiter[g_i]}} & case_b[g_i];
            assign new_final_routing_request[g_i] = case_c[g_i] | granted_req[g_i] | unicast_req[g_i];
            assign forwarding_tail_input[g_i] = fifo_head[g_i].header.preamble.tail & ~in_unvalid_flit[g_i];
            assign grant_mcast_arbiter[g_i] = grant_valid_mcast & grant_mcast[g_i];

            // AckNack: stop data at input port if FIFO is full
            // CreditBased: send credits when reading from the input FIFO
            assign stop_out[g_i] =  FifoBypassEnable ? full[g_i] :
                                ~(rd_fifo_or[g_i] & ~in_unvalid_flit[g_i]);

            always_comb begin
                for (int j = 0; j < 5; j++) begin
                    rd_fifo_vector[g_i][j] = enhanc_routing_configuration[j][g_i];
                end
                input_throttled[g_i] = |(rd_fifo_vector[g_i] & backpressure_single);
            end
        end else begin : gen_input_port_disabled

            assign stop_out[g_i]                       = 1'b1;
            assign final_routing_request[g_i]          = '0;
            assign saved_routing_request[g_i]          = '0;
            assign in_unvalid_flit[g_i]                = '1;
            assign fifo_head[g_i]                      = '0;
            assign empty[g_i]                          = 1'b1;
            assign full[g_i]                           = '0;
            assign next_hop_routing[g_i]               = '0;
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
            assign rd_fifo_vector[g_i]                 = '0;
        end  // if (Ports[g_i])

    end  // for gen_input_fifo

    logic [4:0] req, col_vec, conflict_mask, port_blocked;

    always_comb begin
        for (int i = 0; i < 5; i++) begin
            req = final_routing_request[i] & {5{mcast_input_initial[i]}};
            for (int j = 0; j < 5; j++) begin
                port_blocked[j] = unicast_req_OR[j] | ((noc::int2noc_port(i) != input_direction[j]) && (state[j] != kReservePort));
            end  //end j for
            if ((req & port_blocked) != '0) begin
                case_b[i] = 5'b0;
            end else begin
                case_b[i] = req;
            end
        end  //end i for

        conflict_mask = '0;
        for (int i = 0; i < 5; i++) begin  //i = output
            col_vec = {case_b[4][i], case_b[3][i], case_b[2][i], case_b[1][i], case_b[0][i]};
            if ((col_vec & (col_vec - 5'b1)) != '0) begin
              conflict_mask[i] = 1'b1;
            end
        end  //end i for

        for (int i = 0; i < 5; i++) begin
            if ((case_b[i] & conflict_mask) != '0) begin
                mcast_input_c[i] = 1'b1;
                case_c[i] = 5'b0;
            end else begin
                mcast_input_c[i] = 1'b0;
                case_c[i] = case_b[i];
            end
        end
    end  //end always_comb

    router_mcast_arbiter mcast_arbiter_i (
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
    for (g_i = 0; g_i < 5; g_i++) begin : gen_output_control
        genvar g_j;
        if (Ports[g_i]) begin : gen_output_port_enabled
            assign unicast_req_OR[g_i] = |{unicast_req[0][g_i], unicast_req[1][g_i], unicast_req[2][g_i], unicast_req[3][g_i], unicast_req[4][g_i]};
            for (g_j = 0; g_j < 5; g_j++) begin : gen_transpose_routing
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

//            assign arbiter_request_masked[g_i] = (state[g_i] == kReservePort) ? transp_final_routing_request[g_i] : 4'b0;

            // Arbitration
//            router_arbiter arbiter_i (
//                .clk(clk),
//                .rst(rst_arbiter[g_i]),
////                .request(arbiter_request_masked[g_i]),
//                .request(transp_final_routing_request[g_i]),
//                .forwarding_head(forwarding_head[g_i]),
//                .forwarding_tail(forwarding_tail[g_i]),
//                .grant(grant[g_i]),
//                .grant_valid(grant_valid[g_i])
//            );
            
            router_arbiter_rtpe arbiter_i (
                .clk(clk),
                .rst(rst_arbiter[g_i]),
//                .request(arbiter_request_masked[g_i]),
                .request(transp_final_routing_request[g_i]),
                .forwarding_head(forwarding_head[g_i]),
                .forwarding_tail(forwarding_tail[g_i]),
                .grant(grant[g_i]),
                .grant_valid(grant_valid[g_i])
            );

            assign rst_arbiter[g_i] = rst || reset_arbiter[g_i];
            assign input_direction[g_i] = noc::get_direction(
                enhanc_routing_configuration[g_i]
            );

            assign rd_fifo[g_i][noc::kNorthPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kNorthPort];
            assign rd_fifo[g_i][noc::kSouthPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kSouthPort];
            assign rd_fifo[g_i][noc::kEastPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kEastPort];
            assign rd_fifo[g_i][noc::kWestPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kWestPort];
            assign rd_fifo[g_i][noc::kLocalPort] = no_backpressure_mcast[g_i] && forwarding_in_progress[g_i] && enhanc_routing_configuration[g_i][noc::kLocalPort];

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
            always_comb begin
                fifo_head_routing[g_i] = '0;
                out_unvalid_flit[g_i]  = 1'b1;

                // for each input port
                for (int j = 0; j < 5; j++) begin
                    if (enhanc_routing_configuration[g_i][j]) begin
                        fifo_head_routing[g_i] = fifo_head[j];
                        out_unvalid_flit[g_i] = in_unvalid_flit[j];
                    end
                end
            end

            if (g_i < 4) begin
              lookahead_routing_multicast_mask #(
                  .W(4),
                  .PORT_ID(g_i[2:0])
              ) lookahead_routing_i (
                  .clk,
                  .position,
                  .destination(la_destination[g_i]),
                  .destination_mask(la_destination_mask[g_i]),
                  .next_routing(next_hop_routing[g_i])
              );
              assign la_destination[g_i] = insert_lookahead_routing[g_i] ? fifo_head_routing[g_i].header.info.destination : '0;
              assign la_destination_mask[g_i] = insert_lookahead_routing[g_i] ? fifo_head_routing[g_i].header.info.destination_mask : '0;
            end else begin
              assign next_hop_routing[g_i] = '0;
            end

            // Only update valid bits only when we have a header
            assign data_out_crossbar[g_i] = insert_lookahead_routing[g_i] ? {fifo_head_routing[g_i].flit[PortWidth-1:5], (next_hop_routing[g_i])} : fifo_head_routing[g_i];

            // Sample output
            always_ff @(posedge clk) begin
                if (rst) begin
                    last_flit[g_i] <= '0;
                end else begin
                    if (FifoBypassEnable) begin
                        if (no_backpressure_mcast[g_i] & forwarding_in_progress[g_i] & ~out_unvalid_flit[g_i]) begin
                            last_flit[g_i] <= data_out_crossbar[g_i];
                        end
                    end else begin
                        if (~data_void_out[g_i]) begin
                            last_flit[g_i] <= data_out_crossbar[g_i];
                        end
                    end
                end
            end

            assign backpressure_single[g_i] = FifoBypassEnable ? stop_in[g_i] : credits[g_i] == '0;
            assign no_backpressure_single[g_i] = ~backpressure_single[g_i];
            assign no_backpressure_mcast[g_i] = ~(|(input_throttled & enhanc_routing_configuration[g_i]));
            assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail &
                                   ~out_unvalid_flit[g_i] & no_backpressure_mcast[g_i];
            assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head &
                                    ~out_unvalid_flit[g_i] & forwarding_in_progress[g_i];


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
                            new_state[g_i]              = kPayloadFlits;
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
                        credits[g_i] = QUEUE_SIZE;
                    end else begin
                        if (~data_void_out[g_i]) begin
                            credits[g_i] = credits[g_i] - stop_in[g_i];
                        end else begin
                            credits[g_i] = credits[g_i] + ~stop_in[g_i];
                        end
                    end
                end
            end



        end else begin : gen_input_port_disabled
            assign grant_valid[g_i]                  = '0;
            assign grant[g_i]                        = '0;
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
            assign input_direction[g_i]              = noc::kNorthPort;
            assign reset_arbiter[g_i]                = '0;
            assign rst_arbiter[g_i]                  = '0;
            assign unicast_req_OR[g_i]               = '0;
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
