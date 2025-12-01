module top2 (inst_0_in1, inst_0_out1, inst_1_in1, inst_1_out1, inst_2_in1, inst_2_out1, clk);

input [3:0] inst_0_in1;
wire [3:0] inst_0_in1_w;
reg [3:0] inst_0_in1_r;
output [3:0] inst_0_out1;
wire [3:0] inst_0_out1_w;
reg [3:0] inst_0_out1_r;
input [2:0] inst_1_in1;
wire [2:0] inst_1_in1_w;
reg [2:0] inst_1_in1_r;
output [2:0] inst_1_out1;
wire [2:0] inst_1_out1_w;
reg [2:0] inst_1_out1_r;
input [1:0] inst_2_in1;
wire [1:0] inst_2_in1_w;
reg [1:0] inst_2_in1_r;
output [1:0] inst_2_out1;
wire [1:0] inst_2_out1_w;
reg [1:0] inst_2_out1_r;
input clk;

assign inst_0_in1_w = inst_0_in1_r;
assign inst_0_out1 = inst_0_out1_r;
assign inst_1_in1_w = inst_1_in1_r;
assign inst_1_out1 = inst_1_out1_r;
assign inst_2_in1_w = inst_2_in1_r;
assign inst_2_out1 = inst_2_out1_r;

dummy_Add_4U_9_4 inst_0 (inst_0_in1_w, inst_0_out1_w);
dummy_Add_3U_8_4 inst_1 (inst_1_in1_w, inst_1_out1_w);
dummy_Add_2U_7_4 inst_2 (inst_2_in1_w, inst_2_out1_w);

	always @ (posedge clk ) begin
		inst_0_in1_r <= inst_0_in1;
		inst_0_out1_r <= inst_0_out1_w;
		inst_1_in1_r <= inst_1_in1;
		inst_1_out1_r <= inst_1_out1_w;
		inst_2_in1_r <= inst_2_in1;
		inst_2_out1_r <= inst_2_out1_w;
	end
endmodule