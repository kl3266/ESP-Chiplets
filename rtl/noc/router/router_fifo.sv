// FIFO for packet-switched router
//
// Interface
//
// * Inputs
// - clk: all signals are synchronous to this clock signal.
// - rst: active high reset
// - rdreq: set to 1 for one cycle to pop unless the FIFO is empty; if BypassEnable is set, rdreq
//   and wrreq can be asserted in the same cycle to forward data_in to data_out.
// - wrreq: set to 1 for one cycle to push; wrreq has no effect if the FIFO is full.
// - data_in: data to be pushed; if BypassEnable is set and the FIFO is empty data_in is forwarded
//   to data_out with zero-cycles delay.
//
// * Outputs
// - empty: when set to 1, the FIFO is empty; after reset, the FIFO is empty.
// - full: when set to 1, the FIFO is full.
// - data_out: data present at the head of the FIFO; this output is not valid when the FIFO is
//   empty. If BypassEnable is set, data_out may be valid if data_in is valid; in this case the
//   user should assert both rdreq and wrreq.
//
// Parameters
// - BypassEnable: set to 1 to enable zero-cycles delay between data_in and data_out when the FIFO
//   is empty.
// - Depth: depth of the FIFO
// - Width: bit-width of data_in and data_out
//
module router_fifo
  #(
    parameter bit BypassEnable = 1'b1,
    parameter int unsigned Depth = 4,
    parameter int unsigned Width = 8
    )
  (
   input logic clk,
   input logic rst,
   input logic rdreq,
   input logic wrreq,
   input logic [Width-1:0] data_in,
   output logic empty,
   output logic full,
   output logic [Width-1:0] data_out
   );

  initial begin
    if ((Depth & (Depth - 1)) != 0) 
      $error("Error: Depth must be a power of 2 (2,4,8...) for efficiency.");
  end

  localparam int PtrWidth = $clog2(Depth);

  logic [PtrWidth:0] wr_ptr, rd_ptr;
  logic [Width-1:0] mem [Depth-1:0];
  logic write_en;
  logic read_en;
  logic bypass_condition;

  assign empty = (wr_ptr == rd_ptr);
  assign full = (wr_ptr[PtrWidth-1:0] == rd_ptr[PtrWidth-1:0]) &&
                (wr_ptr[PtrWidth] != rd_ptr[PtrWidth]);
  assign bypass_condition = BypassEnable & empty;
  assign write_en = bypass_condition ? wrreq & ~rdreq : wrreq & ~full;
  assign read_en = rdreq & ~empty;

  assign data_out = bypass_condition ? data_in : mem[rd_ptr[PtrWidth-1:0]];

  always_ff @(posedge clk) begin
    if (rst) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end else begin
      if (write_en) begin
        mem[wr_ptr[PtrWidth-1:0]] <= data_in;
        wr_ptr <= wr_ptr + 1'b1;
      end
      if (read_en) begin
        rd_ptr <= rd_ptr + 1'b1;
      end
    end
  end

  //
  // Assertions
  //

//`ifndef SYNTHESIS
// pragma coverage off
//VCS coverage off

  // FIFO is in good state
//  a_head_lt_depth: assert property (@(posedge clk) disable iff(rst) head < Depth)
//    else $error("Fail: a_head_lt_depth");
//  a_tail_onehot: assert property (@(posedge clk) disable iff(rst) $onehot(tail))
//    else $error("Fail: a_tail_onehot");

// pragma coverage on
//VCS coverage on
//`endif // ~SYNTHESIS

endmodule

// Use if not power of 2.
//module router_fifo
//  #(
//    parameter bit BypassEnable = 1'b1,
//    parameter int unsigned Depth = 4,
//    parameter int unsigned Width = 8
//    )
//  (
//   input  logic clk,
//   input  logic rst,
//   input  logic rdreq,
//   input  logic wrreq,
//   input  logic [Width-1:0] data_in,
//   output logic empty,
//   output logic full,
//   output logic [Width-1:0] data_out
//   );
//
//  // ---------------------------------------------------------
//  // Local Parameters & Signals
//  // ---------------------------------------------------------
//  localparam int PtrWidth = $clog2(Depth);
//  localparam int CntWidth = $clog2(Depth + 1);
//
//  logic [Width-1:0] mem [Depth-1:0];
//  logic [PtrWidth-1:0] wr_ptr, rd_ptr;
//  logic [CntWidth-1:0] count;
//
//  logic bypass_active;
//  logic write_en;
//  logic read_en;
//
//  // ---------------------------------------------------------
//  // Control Logic
//  // ---------------------------------------------------------
//
//  assign empty = (count == '0);
//  assign full  = (count == Depth[CntWidth-1:0]);
//
//  // Bypass Condition:
//  // If enabled, empty, and both requesting -> Pass data straight through.
//  // We do NOT write to memory (save power) and do NOT move pointers.
//  assign bypass_active = BypassEnable & empty & rdreq & wrreq;
//
//  // Write Enable: Write if requested, not full, and not currently bypassing
//  assign write_en = wrreq & ~full & ~bypass_active;
//
//  // Read Enable: Read if requested, not empty (Bypass handled purely combinatorially)
//  assign read_en  = rdreq & ~empty;
//
//  // ---------------------------------------------------------
//  // Datapath (Output Mux)
//  // ---------------------------------------------------------
//
//  // If bypassing, output data_in directly. Otherwise output from Memory.
//  // Note: mem[rd_ptr] creates the read-mux automatically.
//  assign data_out = (BypassEnable & empty) ? data_in : mem[rd_ptr];
//
//  // ---------------------------------------------------------
//  // Sequential Logic (Pointers & Memory)
//  // ---------------------------------------------------------
//  always_ff @(posedge clk) begin
//    if (rst) begin
//      wr_ptr <= '0;
//      rd_ptr <= '0;
//      count  <= '0;
//    end else begin
//
//      // Write Operation
//      if (write_en) begin
//        mem[wr_ptr] <= data_in;
//        // Wrap-around logic for generic Depth
//        wr_ptr <= (wr_ptr == Depth[PtrWidth-1:0] - 1'b1) ? '0 : wr_ptr + 1'b1;
//      end
//
//      // Read Operation
//      if (read_en) begin
//        // Wrap-around logic for generic Depth
//        rd_ptr <= (rd_ptr == Depth[PtrWidth-1:0] - 1'b1) ? '0 : rd_ptr + 1'b1;
//      end
//
//      // Count Update
//      case ({write_en, read_en})
//        2'b10: count <= count + 1'b1; // Write only
//        2'b01: count <= count - 1'b1; // Read only
//        default: count <= count;      // Both or None
//      endcase
//    end
//  end
//
//  // ---------------------------------------------------------
//  // Assertions (Simulation Only)
//  // ---------------------------------------------------------
//`ifndef SYNTHESIS
//  // pragma coverage off
//
//  default clocking cb @(posedge clk); endclocking
//
//  // Check for Overflow/Underflow
//  property p_no_overflow;
//    disable iff (rst) (wrreq && full && !rdreq) |-> ##1 ($stable(count));
//  endproperty
//
//  property p_no_underflow;
//    disable iff (rst) (rdreq && empty && !wrreq) |-> ##1 ($stable(count));
//  endproperty
//
//  a_no_overflow:  assert property (p_no_overflow)  else $error("FIFO Overflow Write");
//  a_no_underflow: assert property (p_no_underflow) else $error("FIFO Underflow Read");
//
//  // pragma coverage on
//`endif
//
//endmodule
