// 4 inputs to 1 output router arbiter
//
// There is no delay from request to grant.
// The abriter assumes that the request remains stable while the entire
// packet is forwarded. Hence, priority is updated whenever a tail flit
// is forwarded. Grant is locked between a head flit and the corresponding
// tail flit.
//
// Interface
//
// * Inputs
// - clk: clock.
// - rst: active-high reset.
// - request: each bit should be set to 1 if there is a valid flit coming from the corresponding
//   input port that needs to be routed to the output port arbitrated by this module.
// - forwarding_head: set to 1 to indicate the head flit of a new packet is being routed this cycle.
//   The current grant gets locked until the tail flit is forwarded (wormhole routing)
// - forwarding_tail: set to 1 to indicate the tail flit of a packet is being routed this cycle.
//   Priority is updated and grant is unlocked.
//
// * Outputs
// - grant: one-hot or zero. When grant[i] is set, request[i] is granted and the packet from the
//   corresponding input port i can be routed.
//   and the packet from the input
// - grant_valid: this flag indicates whether the current grant output is valid. When at least one
//   request bit is set, the arbiter grants the next higher priority request with zero-cycles delay,
//   unless grant is locked.
//

module router_mcast_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic [4:0] request,
    input  logic [4:0] forwarding_head,
    input  logic [4:0] forwarding_tail,
    input  logic [4:0] reset_arbiter,
    output logic [4:0] grant,
    output logic grant_valid
);

    logic grant_locked;
    logic forwarding_head_input;
    logic forwarding_tail_input;
    logic [4:0] saved_grant;

    // Pairwise priority bits.
    // pij == 1 means request[i] has higher priority than request[j].
    logic p01, p02, p03, p04;
    logic p12, p13, p14;
    logic p23, p24;
    logic p34;

    //
    // Lock current grant for flit between head and tail, tail included.
    // Kept equivalent to the original behavior.
    //
    always_ff @(posedge clk) begin
        if (rst || (|reset_arbiter)) begin
            grant_locked <= 1'b0;
            saved_grant  <= '0;
        end else begin
            if (forwarding_tail_input) begin
                grant_locked <= 1'b0;
                saved_grant  <= '0;
            end else if (forwarding_head_input) begin
                saved_grant  <= grant;
                grant_locked <= 1'b1;
            end
        end
    end

    assign forwarding_head_input = (|(grant & forwarding_head)) && !grant_locked;
    assign forwarding_tail_input = |(saved_grant & forwarding_tail);
    assign grant_valid           = (|request) && !grant_locked;

    //
    // Priority state update.
    //
    // Reset priority:
    // request[0] > request[1] > request[2] > request[3] > request[4]
    //
    // On grant of k:
    // request[k] becomes lowest priority.
    // All other relative priorities are preserved.
    //
    always_ff @(posedge clk) begin
        if (rst) begin
            p01 <= 1'b1;
            p02 <= 1'b1;
            p03 <= 1'b1;
            p04 <= 1'b1;

            p12 <= 1'b1;
            p13 <= 1'b1;
            p14 <= 1'b1;

            p23 <= 1'b1;
            p24 <= 1'b1;

            p34 <= 1'b1;
        end else if (forwarding_head_input) begin
            unique case (grant)
                5'b00001: begin
                    // request[0] moves to lowest priority
                    p01 <= 1'b0;
                    p02 <= 1'b0;
                    p03 <= 1'b0;
                    p04 <= 1'b0;
                end

                5'b00010: begin
                    // request[1] moves to lowest priority
                    p01 <= 1'b1;
                    p12 <= 1'b0;
                    p13 <= 1'b0;
                    p14 <= 1'b0;
                end

                5'b00100: begin
                    // request[2] moves to lowest priority
                    p02 <= 1'b1;
                    p12 <= 1'b1;
                    p23 <= 1'b0;
                    p24 <= 1'b0;
                end

                5'b01000: begin
                    // request[3] moves to lowest priority
                    p03 <= 1'b1;
                    p13 <= 1'b1;
                    p23 <= 1'b1;
                    p34 <= 1'b0;
                end

                5'b10000: begin
                    // request[4] moves to lowest priority
                    p04 <= 1'b1;
                    p14 <= 1'b1;
                    p24 <= 1'b1;
                    p34 <= 1'b1;
                end

                default: begin
                    // Hold priority state.
                end
            endcase
        end
    end

    //
    // Grant generation.
    //
    // A requester wins if it is requesting and no higher-priority requester
    // is also requesting.
    //
    assign grant[0] =
        request[0] &&
        !((request[1] && !p01) ||
          (request[2] && !p02) ||
          (request[3] && !p03) ||
          (request[4] && !p04));

    assign grant[1] =
        request[1] &&
        !((request[0] &&  p01) ||
          (request[2] && !p12) ||
          (request[3] && !p13) ||
          (request[4] && !p14));

    assign grant[2] =
        request[2] &&
        !((request[0] &&  p02) ||
          (request[1] &&  p12) ||
          (request[3] && !p23) ||
          (request[4] && !p24));

    assign grant[3] =
        request[3] &&
        !((request[0] &&  p03) ||
          (request[1] &&  p13) ||
          (request[2] &&  p23) ||
          (request[4] && !p34));

    assign grant[4] =
        request[4] &&
        !((request[0] &&  p04) ||
          (request[1] &&  p14) ||
          (request[2] &&  p24) ||
          (request[3] &&  p34));

`ifndef SYNTHESIS
    // pragma coverage off
    //VCS coverage off

    a_grant_onehot :
    assert property (@(posedge clk) disable iff (rst) $onehot0(grant))
    else $error("Fail: a_grant_onehot");

    // Optional sanity check: grant_valid should imply some grant exists
    // when the priority state is valid.
    a_grant_valid_matches_grant :
    assert property (@(posedge clk) disable iff (rst)
        grant_valid |-> (|grant))
    else $error("Fail: a_grant_valid_matches_grant");

    // pragma coverage on
    //VCS coverage on
`endif

endmodule
