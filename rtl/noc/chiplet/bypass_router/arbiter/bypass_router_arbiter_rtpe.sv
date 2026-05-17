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

module bypass_router_arbiter_rtpe (
    input  logic clk,
    input  logic rst,
    input  logic [2:0] request,
    input  logic forwarding_head,
    input  logic forwarding_tail,
    output logic [2:0] grant,
    output logic grant_valid
);

    logic grant_locked;
    logic [1:0] ptr;
    logic [2:0] nrequest;

    assign nrequest = ~request;
    assign grant_valid = (|request) && !grant_locked;

    always_comb begin
        grant = 3'b000;

        if (!grant_locked) begin
            unique case (ptr)
                2'd0: begin
                    grant[0] = request[0];
                    grant[1] = nrequest[0] && request[1];
                    grant[2] = nrequest[0] && nrequest[1] && request[2];
                end

                2'd1: begin
                    grant[1] = request[1];
                    grant[2] = nrequest[1] && request[2];
                    grant[0] = nrequest[1] && nrequest[2] && request[0];
                end

                2'd2: begin
                    grant[2] = request[2];
                    grant[0] = nrequest[2] && request[0];
                    grant[1] = nrequest[2] && nrequest[0] && request[1];
                end

                default: begin
                    grant = 3'b000;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            grant_locked <= 1'b0;
            ptr          <= 2'd0;
        end else begin
            if (forwarding_head) begin
                // Advance RR pointer whenever a valid granted head flit is forwarded.
                unique case (grant)
                    3'b001: ptr <= 2'd1;
                    3'b010: ptr <= 2'd2;
                    3'b100: ptr <= 2'd0;
                    default: ptr <= ptr;
                endcase

                // Single-flit packet: head and tail together.
                // Advance pointer, but do not remain locked.
                grant_locked <= !forwarding_tail;
            end else if (forwarding_tail) begin
                // Tail of a previously locked packet.
                grant_locked <= 1'b0;
            end
        end
    end

`ifndef SYNTHESIS
    a_grant_onehot :
    assert property (@(posedge clk) disable iff (rst) $onehot0(grant))
    else $error("Fail: a_grant_onehot");

    a_ptr_valid :
    assert property (@(posedge clk) disable iff (rst)
        ptr inside {2'd0, 2'd1, 2'd2})
    else $error("Fail: a_ptr_valid");

    a_no_grant_when_locked :
    assert property (@(posedge clk) disable iff (rst)
        grant_locked |-> grant == 3'b000)
    else $error("Fail: a_no_grant_when_locked");
`endif

endmodule
