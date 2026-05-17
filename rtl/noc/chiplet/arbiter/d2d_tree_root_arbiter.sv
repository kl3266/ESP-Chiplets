module d2d_tree_root_arbiter #(
    parameter int unsigned CHDataWidth        = 132,
    parameter int unsigned CMDataWidth        = 66,
    parameter int unsigned DMA_LANES_PER_FLIT = 2  // kept only for interface compatibility
) (
    input  logic clk,
    input  logic rst,

    input  logic [CHDataWidth-1:0] cm_data_in,
    input  logic [(CHDataWidth / CMDataWidth)-1:0] cm_data_void_in,

    input  logic [CHDataWidth-1:0] dma_data_in,
    input  logic [(CHDataWidth / CMDataWidth)-1:0] dma_data_void_in,

    input  logic [(CHDataWidth / CMDataWidth)-1:0] stop_in,

    output logic [(CHDataWidth / CMDataWidth)-1:0] cm_stop_out,
    output logic dma_stop_out,
    output logic [CHDataWidth-1:0] data_out,
    output logic [(CHDataWidth / CMDataWidth)-1:0] data_void_out
);

  localparam int unsigned CM_STREAMS = CHDataWidth / CMDataWidth;
  localparam int unsigned DMA_GROUPS = CM_STREAMS / DMA_LANES_PER_FLIT;

  logic [CM_STREAMS-1:0] cm_busy, cm_busy_next;
  logic                  dma_busy, dma_busy_next;

  logic [CM_STREAMS-1:0] cm_valid_lane;

  logic [CM_STREAMS-1:0] cm_head;
  logic [CM_STREAMS-1:0] cm_tail;

  logic cm_all_idle;
  logic cm_new_req;
  logic dma_new_req;
  logic dma_queued;

  logic dma_valid;
  logic dma_head;
  logic dma_tail;

  logic dma_selected;
  logic dma_stalled;
  logic dma_xfer;
  logic cm_any_xfer;

  logic [CM_STREAMS-1:0] cm_lane_can_run;
  logic [CM_STREAMS-1:0] cm_lane_xfer;

  logic rr_prefer_dma, rr_prefer_dma_next;
  logic cm_grant_start;
  logic dma_grant_start;

  initial begin
    if ((CHDataWidth % CMDataWidth) != 0) begin
      $error("d2d_tree_root_arbiter expects CHDataWidth to be an integer multiple of CMDataWidth");
    end
    if ((DMA_LANES_PER_FLIT < 1) || ((CM_STREAMS % DMA_LANES_PER_FLIT) != 0)) begin
      $error("d2d_tree_root_arbiter expects DMA_LANES_PER_FLIT to divide CHDataWidth/CMDataWidth");
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

  assign cm_valid_lane = ~cm_data_void_in;

  // --------------------------------------------------------------------------
  // CM side: per-66b lane protocol
  // --------------------------------------------------------------------------
  generate
    for (genvar i = 0; i < CM_STREAMS; i++) begin : gen_cm_head_tail
      assign cm_head[CM_STREAMS-1-i] =
          cm_valid_lane[CM_STREAMS-1-i] &&
          cm_data_in[CHDataWidth-1-(i*CMDataWidth)];

      assign cm_tail[CM_STREAMS-1-i] =
          cm_valid_lane[CM_STREAMS-1-i] &&
          cm_data_in[CHDataWidth-2-(i*CMDataWidth)];
    end
  endgenerate

  // DMA side: one or more paired 132b DMA beats can be present inside the wider tree bundle.
  assign dma_valid = dma_any_valid(dma_data_void_in);
  assign dma_head  = dma_any_head(dma_data_in, dma_data_void_in);
  assign dma_tail  = dma_all_active_tail(dma_data_in, dma_data_void_in);

  assign cm_all_idle = ~(|cm_busy);

  assign cm_new_req  = |(cm_valid_lane & cm_head & ~cm_busy);
  assign dma_new_req = dma_head;

  // DMA is waiting behind an active CM reservation.
  // While this is true, existing busy CM lanes continue, but new CM heads are blocked.
  assign dma_queued = !cm_all_idle && dma_new_req;

  assign dma_selected =
      dma_busy ||
      (cm_all_idle && dma_new_req &&
       (!cm_new_req || rr_prefer_dma));

  // The DMA bundle stalls if any constituent output lane is stopped.
  assign dma_stalled  = |(stop_in & ~dma_data_void_in);
  assign dma_xfer     = dma_selected && dma_valid && !dma_stalled;
  assign dma_stop_out = dma_valid && (!dma_selected || dma_stalled);

  assign cm_lane_can_run =
      cm_busy | ({CM_STREAMS{~dma_queued}} & cm_head);

  assign cm_lane_xfer =
      cm_valid_lane &
      cm_lane_can_run &
      ~stop_in &
      {CM_STREAMS{~dma_selected}};

  assign cm_any_xfer = |cm_lane_xfer;

  assign cm_stop_out =
      cm_valid_lane &
      ({CM_STREAMS{dma_selected}} | ~cm_lane_can_run | stop_in);

  assign cm_busy_next =
      (cm_busy & ~cm_lane_xfer) |
      (cm_lane_xfer & ~cm_tail);

  always_comb begin
    dma_busy_next = dma_busy;
    if (dma_xfer) begin
      dma_busy_next = ~dma_tail;
    end
  end

  // True RR state update:
  //   - when CM starts using a free output, next tie prefers DMA
  //   - when DMA starts using a free output, next tie prefers CM
  assign cm_grant_start  = cm_all_idle && cm_any_xfer;
  assign dma_grant_start = !dma_busy && dma_xfer;

  always_comb begin
    rr_prefer_dma_next = rr_prefer_dma;

    if (cm_grant_start) begin
      rr_prefer_dma_next = 1'b1;
    end else if (dma_grant_start) begin
      rr_prefer_dma_next = 1'b0;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      cm_busy       <= '0;
      dma_busy      <= 1'b0;
      rr_prefer_dma <= 1'b0; // first idle tie after reset prefers CM
    end else begin
      cm_busy       <= cm_busy_next;
      dma_busy      <= dma_busy_next;
      rr_prefer_dma <= rr_prefer_dma_next;
    end
  end

  always_comb begin
    data_out      = '0;
    data_void_out = '1;

    if (dma_selected) begin
      data_out      = dma_data_in;
      data_void_out = dma_data_void_in;
    end else begin
      data_out      = cm_data_in;
      data_void_out = cm_data_void_in | ~cm_lane_can_run;
    end
  end

`ifndef SYNTHESIS
  for (genvar i = 0; i < CM_STREAMS; i++) begin : gen_cm_assert
    assert property (@(posedge clk) disable iff (rst)
      cm_lane_xfer[i] && !cm_busy[i] |-> cm_head[i]);

    assert property (@(posedge clk) disable iff (rst)
      cm_lane_xfer[i] && cm_busy[i] |-> !cm_head[i]);
  end

  assert property (@(posedge clk) disable iff (rst)
    dma_xfer && !dma_busy |-> dma_new_req);

  for (genvar group = 0; group < DMA_GROUPS; group++) begin : gen_dma_void_assert
    localparam int unsigned LANE_BASE = group * DMA_LANES_PER_FLIT;

    assert property (@(posedge clk) disable iff (rst)
      dma_data_void_in[LANE_BASE +: DMA_LANES_PER_FLIT] ==
      {DMA_LANES_PER_FLIT{dma_data_void_in[LANE_BASE]}});
  end
`endif

endmodule
