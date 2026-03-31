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
    logic forwarding_head_input, forwarding_tail_input;
    logic [4:0] saved_grant;

    // Update priority
    logic [4:0] priority_matrix [4:0];
    logic [4:0] update_prio_mask, higher_prio_mask;
    logic [4:0] unused_signals;
    
    // Lock current grant for flit between head and tail, tail included
    always_ff @(posedge clk) begin
        if (rst | (|(reset_arbiter))) begin
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

    assign forwarding_head_input = |(grant & forwarding_head) & (~grant_locked);
    assign forwarding_tail_input = |(saved_grant & forwarding_tail);
    assign grant_valid           = |request & ~grant_locked;

    always_comb begin
      grant = '0;
      for (int i=0 ; i<5; i++) begin
        for (int j=0; j<5; j++) begin
          higher_prio_mask[j] = priority_matrix[j][i];
        end
        if (request[i] && ((request & higher_prio_mask) == '0)) begin
          grant[i] = 1'b1;
        end
      end
    end
    assign grant_valid = |grant;

    assign update_prio_mask = grant & forwarding_head;
    
    always_ff @(posedge clk) begin
      if (rst) begin
        for (int j=0; j<5; j++) begin
          for (int i=0; i<5; i++) begin
            priority_matrix[j][i] <= (j < i);
          end
        end
      end else if (|update_prio_mask) begin
        for (int k=0; k<5; k++) begin
          if (update_prio_mask[k]) begin
            priority_matrix[k] <= '0;
            for (int row=0; row<5; row++) begin
              if (row != k) begin
                priority_matrix[row][k] <= 1'b1;
              end
            end
          end
        end
      end
    end

    assign unused_signals = forwarding_tail || reset_arbiter;
endmodule
