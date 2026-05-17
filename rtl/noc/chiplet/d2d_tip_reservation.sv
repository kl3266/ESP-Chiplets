(* keep_hierarchy = "no", syn_hier = "remove" *)
module d2d_tip_reservation #(
    parameter int unsigned SOURCES = 2,
    parameter int unsigned TIPS = 4,
    parameter int unsigned SourceIndexWidth = (SOURCES > 1) ? $clog2(SOURCES) : 1
  )
(
  input  logic clk,
  input  logic rst,
  input  logic routable [SOURCES-1:0],
  input  logic head_valid [SOURCES-1:0],
  input  logic packet_active [SOURCES-1:0],
  input  logic [TIPS-1:0] tip_target_mask [SOURCES-1:0],
  input  logic head_accepted [SOURCES-1:0],
  input  logic tail_accepted [SOURCES-1:0],
  output logic reservation_stop [SOURCES-1:0]
);

  logic existing_reservation_conflict [SOURCES-1:0];
  logic new_reservation_request [SOURCES-1:0];
  logic new_reservation_grant [SOURCES-1:0];
  logic [TIPS-1:0] reserved_by_source [SOURCES-1:0];
  logic [TIPS-1:0] all_reserved;
  logic [SourceIndexWidth-1:0] rr_ptr;

  always_comb begin
    all_reserved = '0;
    for (int unsigned source = 0; source < SOURCES; source++) begin
      all_reserved |= reserved_by_source[source];
    end

    for (int unsigned source = 0; source < SOURCES; source++) begin
      existing_reservation_conflict[source] =
          |(tip_target_mask[source] & (all_reserved & ~reserved_by_source[source]));
    end
  end

  always_comb begin
    logic [TIPS-1:0] newly_claimed_tips;

    newly_claimed_tips = '0;
    for (int unsigned source = 0; source < SOURCES; source++) begin
      new_reservation_grant[source] = 1'b0;
      new_reservation_request[source] =
          routable[source] &&
          head_valid[source] &&
          !packet_active[source] &&
          (|tip_target_mask[source]);
    end

    for (int unsigned offset = 0; offset < SOURCES; offset++) begin
      int unsigned source;

      source = int'(rr_ptr) + offset;
      if (source >= SOURCES) begin
        source = source - SOURCES;
      end

      if (new_reservation_request[source] &&
          !existing_reservation_conflict[source]) begin
        if (|(tip_target_mask[source] & newly_claimed_tips)) begin
          new_reservation_grant[source] = 1'b0;
        end else begin
          new_reservation_grant[source] = 1'b1;
          newly_claimed_tips |= tip_target_mask[source];
        end
      end
    end

    for (int unsigned source = 0; source < SOURCES; source++) begin
      reservation_stop[source] =
          routable[source] &&
          head_valid[source] &&
          !packet_active[source] &&
          (existing_reservation_conflict[source] ||
           (new_reservation_request[source] &&
            !new_reservation_grant[source]));
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      rr_ptr <= '0;
      for (int unsigned source = 0; source < SOURCES; source++) begin
        reserved_by_source[source] <= '0;
      end
    end else begin
      for (int unsigned source = 0; source < SOURCES; source++) begin
        if (tail_accepted[source]) begin
          reserved_by_source[source] <= reserved_by_source[source] & ~tip_target_mask[source];
        end else if (head_accepted[source]) begin
          reserved_by_source[source] <= reserved_by_source[source] | tip_target_mask[source];
        end
      end

      for (int unsigned offset = 0; offset < SOURCES; offset++) begin
        int unsigned source;

        source = int'(rr_ptr) + offset;
        if (source >= SOURCES) begin
          source = source - SOURCES;
        end

        if (head_accepted[source]) begin
          if (source == (SOURCES - 1)) begin
            rr_ptr <= '0;
          end else begin
            rr_ptr <= SourceIndexWidth'(source + 1);
          end
        end
      end
    end
  end

endmodule
