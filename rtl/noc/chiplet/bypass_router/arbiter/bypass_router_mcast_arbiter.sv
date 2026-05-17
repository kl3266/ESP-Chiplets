module bypass_router_mcast_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic [3:0] request,
    input  logic [3:0] forwarding_head,
    input  logic [3:0] forwarding_tail,
    input  logic [3:0] reset_arbiter,
    output logic [3:0] grant,
    output logic grant_valid
);

    logic grant_locked;
    logic forwarding_head_input;
    logic forwarding_tail_input;
    logic [3:0] saved_grant;

    // Pairwise priority bits.
    // pij == 1 means request[i] has higher priority than request[j].
    logic p01, p02, p03;
    logic p12, p13;
    logic p23;

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

            p12 <= 1'b1;
            p13 <= 1'b1;

            p23 <= 1'b1;
        end else if (forwarding_head_input) begin
            unique case (grant)
                4'b0001: begin
                    // request[0] moves to lowest priority
                    p01 <= 1'b0;
                    p02 <= 1'b0;
                    p03 <= 1'b0;
                end

                4'b0010: begin
                    // request[1] moves to lowest priority
                    p01 <= 1'b1;
                    p12 <= 1'b0;
                    p13 <= 1'b0;
                end

                4'b0100: begin
                    // request[2] moves to lowest priority
                    p02 <= 1'b1;
                    p12 <= 1'b1;
                    p23 <= 1'b0;
                end

                4'b1000: begin
                    // request[3] moves to lowest priority
                    p03 <= 1'b1;
                    p13 <= 1'b1;
                    p23 <= 1'b1;
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
          (request[3] && !p03));

    assign grant[1] =
        request[1] &&
        !((request[0] &&  p01) ||
          (request[2] && !p12) ||
          (request[3] && !p13));

    assign grant[2] =
        request[2] &&
        !((request[0] &&  p02) ||
          (request[1] &&  p12) ||
          (request[3] && !p23));

    assign grant[3] =
        request[3] &&
        !((request[0] &&  p03) ||
          (request[1] &&  p13) ||
          (request[2] &&  p23));

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
