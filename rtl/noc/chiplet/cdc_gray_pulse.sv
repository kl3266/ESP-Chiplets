module cdc_gray_pulse #(
  parameter int unsigned N = 4  // can handle < 2^N
)(
  input   logic src_clk,
  input   logic dst_clk,
  input   logic src_rstn,
  input   logic dst_rstn,
  input   logic src_pulse,
  output  logic dst_pulse
);
  function automatic [N-1:0] bin2gray (input logic [N-1:0] bin);
    return bin ^ (bin >> 1);
  endfunction

  function automatic [N-1:0] gray2bin (input logic [N-1:0] gray);
    logic [N-1:0] binary;
    binary[N-1] = gray[N-1]; // MSB is the same
    for (int i = N-2; i >= 0; i--) begin
        binary[i] = binary[i+1] ^ gray[i]; // Recursive XOR
    end
    return binary;
  endfunction

  logic [N-1:0] src_bin_count, src_gray_count;

  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) 
  logic [N-1:0] gray_ff1, gray_ff2;

  logic [N-1:0] dst_bin_count, dst_bin_count_prev;
  logic [N-1:0] new_events;
  logic [N:0] pending_events;

  always_ff @(posedge src_clk or negedge src_rstn) begin
    if (!src_rstn) begin
      src_bin_count <= '0;
      src_gray_count <= '0;
    end else begin
      if (src_pulse) begin
        src_bin_count <= src_bin_count + 1;
        src_gray_count <= bin2gray(src_bin_count + 1);
      end
    end
  end

  assign dst_bin_count = gray2bin(gray_ff2);
  assign new_events = dst_bin_count - dst_bin_count_prev;

  always_ff @(posedge dst_clk or negedge dst_rstn) begin
    if (!dst_rstn) begin
      dst_pulse <= 1'b0;
      gray_ff1 <= '0;
      gray_ff2 <= '0;
      dst_bin_count_prev <= '0;
      pending_events <= '0;
    end else begin
      gray_ff1 <= src_gray_count;
      gray_ff2 <= gray_ff1;
      dst_bin_count_prev <= dst_bin_count;
      if ((pending_events + new_events) != 0) begin
        dst_pulse <= 1'b1;
        pending_events <= pending_events + new_events - 1'b1;
      end else begin
        dst_pulse <= 1'b0;
        pending_events <= '0;
      end
    end
  end
endmodule
