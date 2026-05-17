module cm_3to2_arbiter_max_throughput #(
    parameter int unsigned CMDataWidth = 66
) (
    input  logic clk,
    input  logic rst,

    // Channel 0 -> Output 0 only
    input  logic [CMDataWidth-1:0] ch0_data_in,
    input  logic                   ch0_void_in,
    output logic                   ch0_stop_out,

    // Channel 1 -> Output 1 only
    input  logic [CMDataWidth-1:0] ch1_data_in,
    input  logic                   ch1_void_in,
    output logic                   ch1_stop_out,

    // Channel 2 -> Output 0 or Output 1, but never both at once
    input  logic [CMDataWidth-1:0] ch2_data_in,
    input  logic                   ch2_void_in,
    output logic                   ch2_stop_out,

    // Output 0
    input  logic                   stop0_in,
    output logic [CMDataWidth-1:0] data0_out,
    output logic                   data0_void_out,

    // Output 1
    input  logic                   stop1_in,
    output logic [CMDataWidth-1:0] data1_out,
    output logic                   data1_void_out
);

  localparam int unsigned HEAD_BIT = CMDataWidth - 1;
  localparam int unsigned TAIL_BIT = CMDataWidth - 2;

  // --------------------------------------------------------------------------
  // Protocol extraction
  // --------------------------------------------------------------------------
  logic ch0_valid, ch1_valid, ch2_valid;
  logic ch0_head,  ch0_tail;
  logic ch1_head,  ch1_tail;
  logic ch2_head,  ch2_tail;

  assign ch0_valid = ~ch0_void_in;
  assign ch1_valid = ~ch1_void_in;
  assign ch2_valid = ~ch2_void_in;

  assign ch0_head = ch0_valid && ch0_data_in[HEAD_BIT];
  assign ch0_tail = ch0_valid && ch0_data_in[TAIL_BIT];

  assign ch1_head = ch1_valid && ch1_data_in[HEAD_BIT];
  assign ch1_tail = ch1_valid && ch1_data_in[TAIL_BIT];

  assign ch2_head = ch2_valid && ch2_data_in[HEAD_BIT];
  assign ch2_tail = ch2_valid && ch2_data_in[TAIL_BIT];

  // --------------------------------------------------------------------------
  // Per-output lock state
  // owner = 0 -> dedicated channel (ch0 for out0, ch1 for out1)
  // owner = 1 -> ch2
  // --------------------------------------------------------------------------
  logic out0_locked, out0_locked_next;
  logic out0_owner,  out0_owner_next;

  logic out1_locked, out1_locked_next;
  logic out1_owner,  out1_owner_next;

  // --------------------------------------------------------------------------
  // RR state
  // rr_out0     = 0 prefer ch0, 1 prefer ch2
  // rr_out1     = 0 prefer ch1, 1 prefer ch2
  // rr_ch2_pref = 0 prefer out0, 1 prefer out1 when both speculative grants pick ch2
  // --------------------------------------------------------------------------
  logic rr_out0,     rr_out0_next;
  logic rr_out1,     rr_out1_next;
  logic rr_ch2_pref, rr_ch2_pref_next;

  // --------------------------------------------------------------------------
  // Detect whether ch2 is already locked to one output
  // --------------------------------------------------------------------------
  logic ch2_locked_to_out0, ch2_locked_to_out1;

  assign ch2_locked_to_out0 = out0_locked && (out0_owner == 1'b1);
  assign ch2_locked_to_out1 = out1_locked && (out1_owner == 1'b1);

  // --------------------------------------------------------------------------
  // Requests
  // ch2 hides from the opposite output when already locked to one output
  // --------------------------------------------------------------------------
  logic req0_ch0, req0_ch2;
  logic req1_ch1, req1_ch2;

  assign req0_ch0 = ch0_head;
  assign req0_ch2 = ch2_head && !ch2_locked_to_out1;

  assign req1_ch1 = ch1_head;
  assign req1_ch2 = ch2_head && !ch2_locked_to_out0;

  // --------------------------------------------------------------------------
  // Stage 1: speculative per-output arbitration
  // --------------------------------------------------------------------------
  logic spec_grant0_ch0, spec_grant0_ch2;
  logic spec_grant1_ch1, spec_grant1_ch2;

  always_comb begin
    spec_grant0_ch0 = 1'b0;
    spec_grant0_ch2 = 1'b0;

    if (out0_locked) begin
      spec_grant0_ch0 = (out0_owner == 1'b0);
      spec_grant0_ch2 = (out0_owner == 1'b1);
    end else begin
      if (req0_ch0 && req0_ch2) begin
        spec_grant0_ch0 = !rr_out0;
        spec_grant0_ch2 =  rr_out0;
      end else if (req0_ch0) begin
        spec_grant0_ch0 = 1'b1;
      end else if (req0_ch2) begin
        spec_grant0_ch2 = 1'b1;
      end
    end
  end

  always_comb begin
    spec_grant1_ch1 = 1'b0;
    spec_grant1_ch2 = 1'b0;

    if (out1_locked) begin
      spec_grant1_ch1 = (out1_owner == 1'b0);
      spec_grant1_ch2 = (out1_owner == 1'b1);
    end else begin
      if (req1_ch1 && req1_ch2) begin
        spec_grant1_ch1 = !rr_out1;
        spec_grant1_ch2 =  rr_out1;
      end else if (req1_ch1) begin
        spec_grant1_ch1 = 1'b1;
      end else if (req1_ch2) begin
        spec_grant1_ch2 = 1'b1;
      end
    end
  end

  // --------------------------------------------------------------------------
  // Stage 2: conflict resolution
  //
  // If both outputs would speculatively grant ch2, choose only one output for ch2.
  // To maximize throughput:
  // - if only ch0 is present, force ch0->out0 and ch2->out1
  // - if only ch1 is present, force ch2->out0 and ch1->out1
  // - if both ch0/ch1 are present, use rr_ch2_pref to decide which output ch2 keeps
  // - if neither ch0/ch1 is present, use rr_ch2_pref to decide where ch2 goes
  // --------------------------------------------------------------------------
  logic double_win_conflict;
  logic final_grant0_ch0, final_grant0_ch2;
  logic final_grant1_ch1, final_grant1_ch2;

  assign double_win_conflict = spec_grant0_ch2 && spec_grant1_ch2;

  always_comb begin
    final_grant0_ch0 = spec_grant0_ch0;
    final_grant0_ch2 = spec_grant0_ch2;
    final_grant1_ch1 = spec_grant1_ch1;
    final_grant1_ch2 = spec_grant1_ch2;

    if (double_win_conflict) begin
      unique case ({req0_ch0, req1_ch1})
        2'b10: begin
          // Only ch0 is present besides ch2.
          // Best throughput: ch0->out0, ch2->out1.
          final_grant0_ch0 = 1'b1;
          final_grant0_ch2 = 1'b0;
          final_grant1_ch1 = 1'b0;
          final_grant1_ch2 = 1'b1;
        end

        2'b01: begin
          // Only ch1 is present besides ch2.
          // Best throughput: ch2->out0, ch1->out1.
          final_grant0_ch0 = 1'b0;
          final_grant0_ch2 = 1'b1;
          final_grant1_ch1 = 1'b1;
          final_grant1_ch2 = 1'b0;
        end

        2'b11: begin
          // Both dedicated channels are present.
          // Either choice keeps throughput at 2, so use RR.
          if (rr_ch2_pref == 1'b0) begin
            final_grant0_ch0 = 1'b0;
            final_grant0_ch2 = 1'b1;
            final_grant1_ch1 = 1'b1;
            final_grant1_ch2 = 1'b0;
          end else begin
            final_grant0_ch0 = 1'b1;
            final_grant0_ch2 = 1'b0;
            final_grant1_ch1 = 1'b0;
            final_grant1_ch2 = 1'b1;
          end
        end

        default: begin
          // Only ch2 is present.
          if (rr_ch2_pref == 1'b0) begin
            final_grant0_ch0 = 1'b0;
            final_grant0_ch2 = 1'b1;
            final_grant1_ch1 = 1'b0;
            final_grant1_ch2 = 1'b0;
          end else begin
            final_grant0_ch0 = 1'b0;
            final_grant0_ch2 = 1'b0;
            final_grant1_ch1 = 1'b0;
            final_grant1_ch2 = 1'b1;
          end
        end
      endcase
    end
  end

  // --------------------------------------------------------------------------
  // Transfers
  // --------------------------------------------------------------------------
  logic xfer0_ch0, xfer0_ch2;
  logic xfer1_ch1, xfer1_ch2;

  assign xfer0_ch0 = final_grant0_ch0 && ch0_valid && !stop0_in;
  assign xfer0_ch2 = final_grant0_ch2 && ch2_valid && !stop0_in;

  assign xfer1_ch1 = final_grant1_ch1 && ch1_valid && !stop1_in;
  assign xfer1_ch2 = final_grant1_ch2 && ch2_valid && !stop1_in;

  // --------------------------------------------------------------------------
  // Backpressure
  // --------------------------------------------------------------------------
  assign ch0_stop_out = ch0_valid && !xfer0_ch0;
  assign ch1_stop_out = ch1_valid && !xfer1_ch1;
  assign ch2_stop_out = ch2_valid && !(xfer0_ch2 || xfer1_ch2);

  // --------------------------------------------------------------------------
  // Output muxes
  // --------------------------------------------------------------------------
  always_comb begin
    data0_out      = '0;
    data0_void_out = 1'b1;

    if (final_grant0_ch2) begin
      data0_out      = ch2_data_in;
      data0_void_out = ch2_void_in;
    end else if (final_grant0_ch0) begin
      data0_out      = ch0_data_in;
      data0_void_out = ch0_void_in;
    end
  end

  always_comb begin
    data1_out      = '0;
    data1_void_out = 1'b1;

    if (final_grant1_ch2) begin
      data1_out      = ch2_data_in;
      data1_void_out = ch2_void_in;
    end else if (final_grant1_ch1) begin
      data1_out      = ch1_data_in;
      data1_void_out = ch1_void_in;
    end
  end

  // --------------------------------------------------------------------------
  // State update
  // --------------------------------------------------------------------------
  always_comb begin
    out0_locked_next = out0_locked;
    out0_owner_next  = out0_owner;
    rr_out0_next     = rr_out0;

    out1_locked_next = out1_locked;
    out1_owner_next  = out1_owner;
    rr_out1_next     = rr_out1;

    rr_ch2_pref_next = rr_ch2_pref;

    // Output 0 lock and RR update
    if (!out0_locked) begin
      if (xfer0_ch0 && ch0_head) begin
        out0_locked_next = !ch0_tail;
        out0_owner_next  = 1'b0;
        rr_out0_next     = 1'b1; // prefer ch2 next tie
      end else if (xfer0_ch2 && ch2_head) begin
        out0_locked_next = !ch2_tail;
        out0_owner_next  = 1'b1;
        rr_out0_next     = 1'b0; // prefer ch0 next tie
      end
    end else if ((out0_owner == 1'b0 && xfer0_ch0 && ch0_tail) ||
                 (out0_owner == 1'b1 && xfer0_ch2 && ch2_tail)) begin
      out0_locked_next = 1'b0;
    end

    // Output 1 lock and RR update
    if (!out1_locked) begin
      if (xfer1_ch1 && ch1_head) begin
        out1_locked_next = !ch1_tail;
        out1_owner_next  = 1'b0;
        rr_out1_next     = 1'b1; // prefer ch2 next tie
      end else if (xfer1_ch2 && ch2_head) begin
        out1_locked_next = !ch2_tail;
        out1_owner_next  = 1'b1;
        rr_out1_next     = 1'b0; // prefer ch1 next tie
      end
    end else if ((out1_owner == 1'b0 && xfer1_ch1 && ch1_tail) ||
                 (out1_owner == 1'b1 && xfer1_ch2 && ch2_tail)) begin
      out1_locked_next = 1'b0;
    end

    // Global ch2 destination preference update
    // Toggle toward the opposite output when ch2 successfully starts a packet.
    if (!ch2_locked_to_out0 && !ch2_locked_to_out1) begin
      if (xfer0_ch2 && ch2_head) begin
        rr_ch2_pref_next = 1'b1; // next double-win prefers out1
      end else if (xfer1_ch2 && ch2_head) begin
        rr_ch2_pref_next = 1'b0; // next double-win prefers out0
      end
    end
  end

  // --------------------------------------------------------------------------
  // Sequential logic
  // --------------------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (rst) begin
      out0_locked <= 1'b0;
      out0_owner  <= 1'b0;
      rr_out0     <= 1'b0;

      out1_locked <= 1'b0;
      out1_owner  <= 1'b0;
      rr_out1     <= 1'b0;

      rr_ch2_pref <= 1'b0;
    end else begin
      out0_locked <= out0_locked_next;
      out0_owner  <= out0_owner_next;
      rr_out0     <= rr_out0_next;

      out1_locked <= out1_locked_next;
      out1_owner  <= out1_owner_next;
      rr_out1     <= rr_out1_next;

      rr_ch2_pref <= rr_ch2_pref_next;
    end
  end

`ifndef SYNTHESIS
  // ch2 may never be granted both outputs in the same cycle
  assert property (@(posedge clk) disable iff (rst)
    !(final_grant0_ch2 && final_grant1_ch2));

  // ch2 may never hold both output locks simultaneously
  assert property (@(posedge clk) disable iff (rst)
    !(out0_locked && (out0_owner == 1'b1) &&
      out1_locked && (out1_owner == 1'b1)));

  // Output 0 must not grant both inputs at once
  assert property (@(posedge clk) disable iff (rst)
    !(final_grant0_ch0 && final_grant0_ch2));

  // Output 1 must not grant both inputs at once
  assert property (@(posedge clk) disable iff (rst)
    !(final_grant1_ch1 && final_grant1_ch2));
`endif

endmodule
