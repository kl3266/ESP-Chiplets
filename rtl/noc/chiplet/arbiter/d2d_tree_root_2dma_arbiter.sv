module d2d_tree_root_2dma_arbiter #(
    parameter int unsigned CHDataWidth        = 132,
    parameter int unsigned CMDataWidth        = 66,
    parameter int unsigned DMA_LANES_PER_FLIT = 2  // kept only for interface compatibility
) (
    input  logic clk,
    input  logic rst,

    input  logic [CHDataWidth-1:0] dma0_data_in,
    input  logic [(CHDataWidth / CMDataWidth)-1:0] dma0_data_void_in,

    input  logic [CHDataWidth-1:0] dma1_data_in,
    input  logic [(CHDataWidth / CMDataWidth)-1:0] dma1_data_void_in,

    input  logic [(CHDataWidth / CMDataWidth)-1:0] stop_in,

    output logic dma0_stop_out,
    output logic dma1_stop_out,
    output logic [CHDataWidth-1:0] data_out,
    output logic [(CHDataWidth / CMDataWidth)-1:0] data_void_out
);

  localparam int unsigned CM_STREAMS = CHDataWidth / CMDataWidth;
  localparam int unsigned DMA_GROUPS = CM_STREAMS / DMA_LANES_PER_FLIT;

  logic dma0_busy, dma0_busy_next;
  logic dma1_busy, dma1_busy_next;

  logic dma0_valid;
  logic dma1_valid;

  logic dma0_head;
  logic dma0_tail;
  logic dma1_head;
  logic dma1_tail;

  logic arb_free;

  logic dma0_new_req;
  logic dma1_new_req;

  logic dma0_selected;
  logic dma1_selected;

  logic dma0_stalled;
  logic dma1_stalled;

  logic dma0_xfer;
  logic dma1_xfer;

  logic rr_prefer_dma1, rr_prefer_dma1_next;
  logic dma0_grant_start;
  logic dma1_grant_start;

  initial begin
    if ((CHDataWidth % CMDataWidth) != 0) begin
      $error("d2d_tree_root_2dma_arbiter expects CHDataWidth to be an integer multiple of CMDataWidth");
    end
    if ((DMA_LANES_PER_FLIT < 1) || ((CM_STREAMS % DMA_LANES_PER_FLIT) != 0)) begin
      $error("d2d_tree_root_2dma_arbiter expects DMA_LANES_PER_FLIT to divide CHDataWidth/CMDataWidth");
    end
  end

  function automatic logic dma_group_valid(
      input logic [CM_STREAMS-1:0] voids,
      input int unsigned group
  );
    logic valid;
    begin
      valid = 1'b1;
      for (int unsigned lane = 0; lane < DMA_LANES_PER_FLIT; lane++) begin
        valid &= ~voids[group * DMA_LANES_PER_FLIT + lane];
      end
      return valid;
    end
  endfunction

  function automatic logic dma_any_valid(input logic [CM_STREAMS-1:0] voids);
    logic valid;
    begin
      valid = 1'b0;
      for (int unsigned group = 0; group < DMA_GROUPS; group++) begin
        valid |= dma_group_valid(voids, group);
      end
      return valid;
    end
  endfunction

  function automatic logic dma_any_head(
      input logic [CHDataWidth-1:0] data,
      input logic [CM_STREAMS-1:0] voids
  );
    logic head;
    begin
      head = 1'b0;
      for (int unsigned group = 0; group < DMA_GROUPS; group++) begin
        if (dma_group_valid(voids, group)) begin
          head |= data[((group + 1) * DMA_LANES_PER_FLIT * CMDataWidth) - 1];
        end
      end
      return head;
    end
  endfunction

  function automatic logic dma_all_active_tail(
      input logic [CHDataWidth-1:0] data,
      input logic [CM_STREAMS-1:0] voids
  );
    logic any_active;
    logic tail;
    begin
      any_active = 1'b0;
      tail = 1'b1;
      for (int unsigned group = 0; group < DMA_GROUPS; group++) begin
        if (dma_group_valid(voids, group)) begin
          any_active = 1'b1;
          tail &= data[((group + 1) * DMA_LANES_PER_FLIT * CMDataWidth) - 2];
        end
      end
      return any_active && tail;
    end
  endfunction

  assign dma0_valid = dma_any_valid(dma0_data_void_in);
  assign dma1_valid = dma_any_valid(dma1_data_void_in);

  assign dma0_head  = dma_any_head(dma0_data_in, dma0_data_void_in);
  assign dma0_tail  = dma_all_active_tail(dma0_data_in, dma0_data_void_in);

  assign dma1_head  = dma_any_head(dma1_data_in, dma1_data_void_in);
  assign dma1_tail  = dma_all_active_tail(dma1_data_in, dma1_data_void_in);

  assign arb_free   = !(dma0_busy || dma1_busy);

  assign dma0_new_req = dma0_head;
  assign dma1_new_req = dma1_head;

  assign dma0_selected =
      dma0_busy ||
      (arb_free && dma0_new_req &&
       (!dma1_new_req || !rr_prefer_dma1));

  assign dma1_selected =
      dma1_busy ||
      (arb_free && dma1_new_req &&
       (!dma0_new_req || rr_prefer_dma1));

  // DMA bundle stalls if any constituent lane is stopped while the bundle is valid
  assign dma0_stalled = |(stop_in & ~dma0_data_void_in);
  assign dma1_stalled = |(stop_in & ~dma1_data_void_in);

  assign dma0_xfer = dma0_selected && dma0_valid && !dma0_stalled;
  assign dma1_xfer = dma1_selected && dma1_valid && !dma1_stalled;

  assign dma0_stop_out = dma0_valid && (!dma0_selected || dma0_stalled);
  assign dma1_stop_out = dma1_valid && (!dma1_selected || dma1_stalled);

  always_comb begin
    dma0_busy_next = dma0_busy;
    if (dma0_xfer) begin
      dma0_busy_next = ~dma0_tail;
    end
  end

  always_comb begin
    dma1_busy_next = dma1_busy;
    if (dma1_xfer) begin
      dma1_busy_next = ~dma1_tail;
    end
  end

  // True packet-level RR update on successful packet start from idle
  assign dma0_grant_start = arb_free && dma0_xfer;
  assign dma1_grant_start = arb_free && dma1_xfer;

  always_comb begin
    rr_prefer_dma1_next = rr_prefer_dma1;

    if (dma0_grant_start) begin
      rr_prefer_dma1_next = 1'b1; // DMA0 just won, prefer DMA1 next tie
    end else if (dma1_grant_start) begin
      rr_prefer_dma1_next = 1'b0; // DMA1 just won, prefer DMA0 next tie
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      dma0_busy       <= 1'b0;
      dma1_busy       <= 1'b0;
      rr_prefer_dma1  <= 1'b0; // first tie after reset prefers DMA0
    end else begin
      dma0_busy       <= dma0_busy_next;
      dma1_busy       <= dma1_busy_next;
      rr_prefer_dma1  <= rr_prefer_dma1_next;
    end
  end

  always_comb begin
    data_out      = '0;
    data_void_out = '1;

    if (dma0_selected) begin
      data_out      = dma0_data_in;
      data_void_out = dma0_data_void_in;
    end else if (dma1_selected) begin
      data_out      = dma1_data_in;
      data_void_out = dma1_data_void_in;
    end
  end

`ifndef SYNTHESIS
  assert property (@(posedge clk) disable iff (rst)
    !(dma0_busy && dma1_busy));

  assert property (@(posedge clk) disable iff (rst)
    !(dma0_selected && dma1_selected));

  assert property (@(posedge clk) disable iff (rst)
    dma0_xfer && !dma0_busy |-> dma0_new_req);

  assert property (@(posedge clk) disable iff (rst)
    dma1_xfer && !dma1_busy |-> dma1_new_req);

  for (genvar group = 0; group < DMA_GROUPS; group++) begin : gen_dma_void_assert
    localparam int unsigned LANE_BASE = group * DMA_LANES_PER_FLIT;

    assert property (@(posedge clk) disable iff (rst)
      dma0_data_void_in[LANE_BASE +: DMA_LANES_PER_FLIT] ==
      {DMA_LANES_PER_FLIT{dma0_data_void_in[LANE_BASE]}});

    assert property (@(posedge clk) disable iff (rst)
      dma1_data_void_in[LANE_BASE +: DMA_LANES_PER_FLIT] ==
      {DMA_LANES_PER_FLIT{dma1_data_void_in[LANE_BASE]}});
  end
`endif

endmodule
