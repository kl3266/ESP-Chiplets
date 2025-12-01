module top1 (inst_0_in2, inst_0_in1, inst_0_out1, inst_1_in2, inst_1_in1, inst_1_out1, inst_2_in2, inst_2_in1, inst_2_out1, inst_3_in3, inst_3_in2, inst_3_ctrl1, inst_3_out1, clk);

input [31:0] inst_0_in2;
wire [31:0] inst_0_in2_w;
reg [31:0] inst_0_in2_r;
input [2:0] inst_0_in1;
wire [2:0] inst_0_in1_w;
reg [2:0] inst_0_in1_r;
output [31:0] inst_0_out1;
wire [31:0] inst_0_out1_w;
reg [31:0] inst_0_out1_r;
input [15:0] inst_1_in2;
wire [15:0] inst_1_in2_w;
reg [15:0] inst_1_in2_r;
input [2:0] inst_1_in1;
wire [2:0] inst_1_in1_w;
reg [2:0] inst_1_in1_r;
output [15:0] inst_1_out1;
wire [15:0] inst_1_out1_w;
reg [15:0] inst_1_out1_r;
input [8:0] inst_2_in2;
wire [8:0] inst_2_in2_w;
reg [8:0] inst_2_in2_r;
input [1:0] inst_2_in1;
wire [1:0] inst_2_in1_w;
reg [1:0] inst_2_in1_r;
output [8:0] inst_2_out1;
wire [8:0] inst_2_out1_w;
reg [8:0] inst_2_out1_r;
input [255:0] inst_3_in3;
wire [255:0] inst_3_in3_w;
reg [255:0] inst_3_in3_r;
input [255:0] inst_3_in2;
wire [255:0] inst_3_in2_w;
reg [255:0] inst_3_in2_r;
input [0:0] inst_3_ctrl1;
wire [0:0] inst_3_ctrl1_w;
reg [0:0] inst_3_ctrl1_r;
output [255:0] inst_3_out1;
wire [255:0] inst_3_out1_w;
reg [255:0] inst_3_out1_r;
input clk;

assign inst_0_in2_w = inst_0_in2_r;
assign inst_0_in1_w = inst_0_in1_r;
assign inst_0_out1 = inst_0_out1_r;
assign inst_1_in2_w = inst_1_in2_r;
assign inst_1_in1_w = inst_1_in1_r;
assign inst_1_out1 = inst_1_out1_r;
assign inst_2_in2_w = inst_2_in2_r;
assign inst_2_in1_w = inst_2_in1_r;
assign inst_2_out1 = inst_2_out1_r;
assign inst_3_in3_w = inst_3_in3_r;
assign inst_3_in2_w = inst_3_in2_r;
assign inst_3_ctrl1_w = inst_3_ctrl1_r;
assign inst_3_out1 = inst_3_out1_r;

dummy_Add_32Sx3U_32S_4 inst_0 (inst_0_in2_w, inst_0_in1_w, inst_0_out1_w);
dummy_Add_16Ux3U_16U_4 inst_1 (inst_1_in2_w, inst_1_in1_w, inst_1_out1_w);
dummy_Add_9Ux2U_9U_4 inst_2 (inst_2_in2_w, inst_2_in1_w, inst_2_out1_w);
dummy_N_MuxB_256_2_1_4 inst_3 (inst_3_in3_w, inst_3_in2_w, inst_3_ctrl1_w, inst_3_out1_w);

	always @ (posedge clk ) begin
		inst_0_in2_r <= inst_0_in2;
		inst_0_in1_r <= inst_0_in1;
		inst_0_out1_r <= inst_0_out1_w;
		inst_1_in2_r <= inst_1_in2;
		inst_1_in1_r <= inst_1_in1;
		inst_1_out1_r <= inst_1_out1_w;
		inst_2_in2_r <= inst_2_in2;
		inst_2_in1_r <= inst_2_in1;
		inst_2_out1_r <= inst_2_out1_w;
		inst_3_in3_r <= inst_3_in3;
		inst_3_in2_r <= inst_3_in2;
		inst_3_ctrl1_r <= inst_3_ctrl1;
		inst_3_out1_r <= inst_3_out1_w;
	end
endmodule