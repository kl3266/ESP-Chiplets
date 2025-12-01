//
// Verilog co-simulation wrapper module for the dummy module.

// This module contains the followng items:
//	- An instance of the verilog RTL module created by stratus_vlg.
//	- Wires and reg's connected to the ports of the RTL module.
//	- A clock generator using the project's clock frequency and connected to
//    the RTL module's clock port.
//
// The wires and reg's will be connected to sc_signals in the SystemC simulaton
// by esc_link_signals calls in the proxy module found in the dummy_cosim.h 
// file.

`timescale 1 ps / 1 ps

module dummy_cosim;

	`ifdef ioConfig_IOCFG_DMA64
	
	reg clk;
	reg rst;
	reg dma_read_chnl_valid;
	reg[63:0] dma_read_chnl_data;
	wire dma_read_chnl_ready;
	reg[31:0] conf_info_tokens;
	reg[31:0] conf_info_batch;
	reg[31:0] conf_info_source;
	reg[31:0] conf_info_ndests;
	reg conf_done;
	wire acc_done;
	wire[31:0] debug;
	wire dma_read_ctrl_valid;
	wire[31:0] dma_read_ctrl_data_index;
	wire[31:0] dma_read_ctrl_data_length;
	wire[2:0] dma_read_ctrl_data_size;
	wire[4:0] dma_read_ctrl_data_user;
	reg dma_read_ctrl_ready;
	wire dma_write_ctrl_valid;
	wire[31:0] dma_write_ctrl_data_index;
	wire[31:0] dma_write_ctrl_data_length;
	wire[2:0] dma_write_ctrl_data_size;
	wire[4:0] dma_write_ctrl_data_user;
	reg dma_write_ctrl_ready;
	wire dma_write_chnl_valid;
	wire[63:0] dma_write_chnl_data;
	reg dma_write_chnl_ready;
	
	`endif
	`ifdef ioConfig_IOCFG_DMA128
	
	reg clk;
	reg rst;
	reg dma_read_chnl_valid;
	reg[127:0] dma_read_chnl_data;
	wire dma_read_chnl_ready;
	reg[31:0] conf_info_tokens;
	reg[31:0] conf_info_batch;
	reg[31:0] conf_info_source;
	reg[31:0] conf_info_ndests;
	reg conf_done;
	wire acc_done;
	wire[31:0] debug;
	wire dma_read_ctrl_valid;
	wire[31:0] dma_read_ctrl_data_index;
	wire[31:0] dma_read_ctrl_data_length;
	wire[2:0] dma_read_ctrl_data_size;
	wire[4:0] dma_read_ctrl_data_user;
	reg dma_read_ctrl_ready;
	wire dma_write_ctrl_valid;
	wire[31:0] dma_write_ctrl_data_index;
	wire[31:0] dma_write_ctrl_data_length;
	wire[2:0] dma_write_ctrl_data_size;
	wire[4:0] dma_write_ctrl_data_user;
	reg dma_write_ctrl_ready;
	wire dma_write_chnl_valid;
	wire[127:0] dma_write_chnl_data;
	reg dma_write_chnl_ready;
	
	`endif
	`ifdef ioConfig_IOCFG_DMA256
	
	reg clk;
	reg rst;
	reg dma_read_chnl_valid;
	reg[255:0] dma_read_chnl_data;
	wire dma_read_chnl_ready;
	reg[31:0] conf_info_tokens;
	reg[31:0] conf_info_batch;
	reg[31:0] conf_info_source;
	reg[31:0] conf_info_ndests;
	reg conf_done;
	wire acc_done;
	wire[31:0] debug;
	wire dma_read_ctrl_valid;
	wire[31:0] dma_read_ctrl_data_index;
	wire[31:0] dma_read_ctrl_data_length;
	wire[2:0] dma_read_ctrl_data_size;
	wire[4:0] dma_read_ctrl_data_user;
	reg dma_read_ctrl_ready;
	wire dma_write_ctrl_valid;
	wire[31:0] dma_write_ctrl_data_index;
	wire[31:0] dma_write_ctrl_data_length;
	wire[2:0] dma_write_ctrl_data_size;
	wire[4:0] dma_write_ctrl_data_user;
	reg dma_write_ctrl_ready;
	wire dma_write_chnl_valid;
	wire[255:0] dma_write_chnl_data;
	reg dma_write_chnl_ready;
	
	`endif
	`ifdef ioConfig_IOCFG_DMA512
	
	reg clk;
	reg rst;
	reg dma_read_chnl_valid;
	reg[511:0] dma_read_chnl_data;
	wire dma_read_chnl_ready;
	reg[31:0] conf_info_tokens;
	reg[31:0] conf_info_batch;
	reg[31:0] conf_info_source;
	reg[31:0] conf_info_ndests;
	reg conf_done;
	wire acc_done;
	wire[31:0] debug;
	wire dma_read_ctrl_valid;
	wire[31:0] dma_read_ctrl_data_index;
	wire[31:0] dma_read_ctrl_data_length;
	wire[2:0] dma_read_ctrl_data_size;
	wire[4:0] dma_read_ctrl_data_user;
	reg dma_read_ctrl_ready;
	wire dma_write_ctrl_valid;
	wire[31:0] dma_write_ctrl_data_index;
	wire[31:0] dma_write_ctrl_data_length;
	wire[2:0] dma_write_ctrl_data_size;
	wire[4:0] dma_write_ctrl_data_user;
	reg dma_write_ctrl_ready;
	wire dma_write_chnl_valid;
	wire[511:0] dma_write_chnl_data;
	reg dma_write_chnl_ready;
	
	`endif


	`include "hub.v"

	dummy dummy0( `ifdef ioConfig_IOCFG_DMA64
	
	.clk(clk),
	 .rst(rst),
	 .conf_info_tokens(conf_info_tokens),
	 .conf_info_batch(conf_info_batch),
	 .conf_info_source(conf_info_source),
	 .conf_info_ndests(conf_info_ndests),
	 .conf_done(conf_done),
	 .acc_done(acc_done),
	 .debug(debug),
	 .dma_read_chnl_valid(dma_read_chnl_valid),
	 .dma_read_chnl_data(dma_read_chnl_data),
	 .dma_read_chnl_ready(dma_read_chnl_ready),
	 .dma_read_ctrl_valid(dma_read_ctrl_valid),
	 .dma_read_ctrl_data_index(dma_read_ctrl_data_index),
	 .dma_read_ctrl_data_length(dma_read_ctrl_data_length),
	 .dma_read_ctrl_data_size(dma_read_ctrl_data_size),
	 .dma_read_ctrl_data_user(dma_read_ctrl_data_user),
	 .dma_read_ctrl_ready(dma_read_ctrl_ready),
	 .dma_write_ctrl_valid(dma_write_ctrl_valid),
	 .dma_write_ctrl_data_index(dma_write_ctrl_data_index),
	 .dma_write_ctrl_data_length(dma_write_ctrl_data_length),
	 .dma_write_ctrl_data_size(dma_write_ctrl_data_size),
	 .dma_write_ctrl_data_user(dma_write_ctrl_data_user),
	 .dma_write_ctrl_ready(dma_write_ctrl_ready),
	 .dma_write_chnl_valid(dma_write_chnl_valid),
	 .dma_write_chnl_data(dma_write_chnl_data),
	 .dma_write_chnl_ready(dma_write_chnl_ready)
	`endif
	`ifdef ioConfig_IOCFG_DMA128
	
	.clk(clk),
	 .rst(rst),
	 .conf_info_tokens(conf_info_tokens),
	 .conf_info_batch(conf_info_batch),
	 .conf_info_source(conf_info_source),
	 .conf_info_ndests(conf_info_ndests),
	 .conf_done(conf_done),
	 .acc_done(acc_done),
	 .debug(debug),
	 .dma_read_chnl_valid(dma_read_chnl_valid),
	 .dma_read_chnl_data(dma_read_chnl_data),
	 .dma_read_chnl_ready(dma_read_chnl_ready),
	 .dma_read_ctrl_valid(dma_read_ctrl_valid),
	 .dma_read_ctrl_data_index(dma_read_ctrl_data_index),
	 .dma_read_ctrl_data_length(dma_read_ctrl_data_length),
	 .dma_read_ctrl_data_size(dma_read_ctrl_data_size),
	 .dma_read_ctrl_data_user(dma_read_ctrl_data_user),
	 .dma_read_ctrl_ready(dma_read_ctrl_ready),
	 .dma_write_ctrl_valid(dma_write_ctrl_valid),
	 .dma_write_ctrl_data_index(dma_write_ctrl_data_index),
	 .dma_write_ctrl_data_length(dma_write_ctrl_data_length),
	 .dma_write_ctrl_data_size(dma_write_ctrl_data_size),
	 .dma_write_ctrl_data_user(dma_write_ctrl_data_user),
	 .dma_write_ctrl_ready(dma_write_ctrl_ready),
	 .dma_write_chnl_valid(dma_write_chnl_valid),
	 .dma_write_chnl_data(dma_write_chnl_data),
	 .dma_write_chnl_ready(dma_write_chnl_ready)
	`endif
	`ifdef ioConfig_IOCFG_DMA256
	
	.clk(clk),
	 .rst(rst),
	 .conf_info_tokens(conf_info_tokens),
	 .conf_info_batch(conf_info_batch),
	 .conf_info_source(conf_info_source),
	 .conf_info_ndests(conf_info_ndests),
	 .conf_done(conf_done),
	 .acc_done(acc_done),
	 .debug(debug),
	 .dma_read_chnl_valid(dma_read_chnl_valid),
	 .dma_read_chnl_data(dma_read_chnl_data),
	 .dma_read_chnl_ready(dma_read_chnl_ready),
	 .dma_read_ctrl_valid(dma_read_ctrl_valid),
	 .dma_read_ctrl_data_index(dma_read_ctrl_data_index),
	 .dma_read_ctrl_data_length(dma_read_ctrl_data_length),
	 .dma_read_ctrl_data_size(dma_read_ctrl_data_size),
	 .dma_read_ctrl_data_user(dma_read_ctrl_data_user),
	 .dma_read_ctrl_ready(dma_read_ctrl_ready),
	 .dma_write_ctrl_valid(dma_write_ctrl_valid),
	 .dma_write_ctrl_data_index(dma_write_ctrl_data_index),
	 .dma_write_ctrl_data_length(dma_write_ctrl_data_length),
	 .dma_write_ctrl_data_size(dma_write_ctrl_data_size),
	 .dma_write_ctrl_data_user(dma_write_ctrl_data_user),
	 .dma_write_ctrl_ready(dma_write_ctrl_ready),
	 .dma_write_chnl_valid(dma_write_chnl_valid),
	 .dma_write_chnl_data(dma_write_chnl_data),
	 .dma_write_chnl_ready(dma_write_chnl_ready)
	`endif
	`ifdef ioConfig_IOCFG_DMA512
	
	.clk(clk),
	 .rst(rst),
	 .conf_info_tokens(conf_info_tokens),
	 .conf_info_batch(conf_info_batch),
	 .conf_info_source(conf_info_source),
	 .conf_info_ndests(conf_info_ndests),
	 .conf_done(conf_done),
	 .acc_done(acc_done),
	 .debug(debug),
	 .dma_read_chnl_valid(dma_read_chnl_valid),
	 .dma_read_chnl_data(dma_read_chnl_data),
	 .dma_read_chnl_ready(dma_read_chnl_ready),
	 .dma_read_ctrl_valid(dma_read_ctrl_valid),
	 .dma_read_ctrl_data_index(dma_read_ctrl_data_index),
	 .dma_read_ctrl_data_length(dma_read_ctrl_data_length),
	 .dma_read_ctrl_data_size(dma_read_ctrl_data_size),
	 .dma_read_ctrl_data_user(dma_read_ctrl_data_user),
	 .dma_read_ctrl_ready(dma_read_ctrl_ready),
	 .dma_write_ctrl_valid(dma_write_ctrl_valid),
	 .dma_write_ctrl_data_index(dma_write_ctrl_data_index),
	 .dma_write_ctrl_data_length(dma_write_ctrl_data_length),
	 .dma_write_ctrl_data_size(dma_write_ctrl_data_size),
	 .dma_write_ctrl_data_user(dma_write_ctrl_data_user),
	 .dma_write_ctrl_ready(dma_write_ctrl_ready),
	 .dma_write_chnl_valid(dma_write_chnl_valid),
	 .dma_write_chnl_data(dma_write_chnl_data),
	 .dma_write_chnl_ready(dma_write_chnl_ready)
	`endif
	 );


	`ifdef ioConfig_IOCFG_DMA64
	
	// Variables that can be set externally
	reg clk_firstEdge;
	reg clk_initialized;
	reg clk_started;
	real clk_startTime;
	real clk_firstHalf;
	real clk_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    clk_firstEdge = 1'b1;
	    clk_startTime = 0.000;    // Offset from time 0 to first edge.
	    clk_firstHalf = 5.000;    // Delay for first half of cycle.
	    clk_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on clk_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( clk_initialized !== 1'b1 )
	        @( clk_initialized );
	
	    if ( clk_startTime > 0.0 ) begin
	        clk_started = #clk_startTime 1;
	    end
	    else begin
	        clk_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.clk ) begin
	    if ( clk_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( clk_started !== 1'b1 )
	        @( clk_started );
	
	    clk <= clk_firstEdge;
	    if ( clk_firstHalf > 0.0 ) begin
	        #clk_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        clk = ~clk_firstEdge;
	    end
	    else begin
	        clk = ~clk_firstEdge;
	    end
	    if ( clk_secondHalf > 0.0 ) begin
	        #clk_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg rst_firstEdge;
	reg rst_initialized;
	reg rst_started;
	real rst_startTime;
	real rst_firstHalf;
	real rst_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    rst_firstEdge = 1'b1;
	    rst_startTime = 0.000;    // Offset from time 0 to first edge.
	    rst_firstHalf = 5.000;    // Delay for first half of cycle.
	    rst_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on rst_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( rst_initialized !== 1'b1 )
	        @( rst_initialized );
	
	    if ( rst_startTime > 0.0 ) begin
	        rst_started = #rst_startTime 1;
	    end
	    else begin
	        rst_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.rst ) begin
	    if ( rst_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( rst_started !== 1'b1 )
	        @( rst_started );
	
	    rst <= rst_firstEdge;
	    if ( rst_firstHalf > 0.0 ) begin
	        #rst_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        rst = ~rst_firstEdge;
	    end
	    else begin
	        rst = ~rst_firstEdge;
	    end
	    if ( rst_secondHalf > 0.0 ) begin
	        #rst_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_chnl_valid_firstEdge;
	reg dma_read_chnl_valid_initialized;
	reg dma_read_chnl_valid_started;
	real dma_read_chnl_valid_startTime;
	real dma_read_chnl_valid_firstHalf;
	real dma_read_chnl_valid_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_chnl_valid_firstEdge = 1'b1;
	    dma_read_chnl_valid_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_chnl_valid_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_chnl_valid_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_chnl_valid_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_chnl_valid_initialized !== 1'b1 )
	        @( dma_read_chnl_valid_initialized );
	
	    if ( dma_read_chnl_valid_startTime > 0.0 ) begin
	        dma_read_chnl_valid_started = #dma_read_chnl_valid_startTime 1;
	    end
	    else begin
	        dma_read_chnl_valid_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_chnl_valid ) begin
	    if ( dma_read_chnl_valid_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_chnl_valid_started !== 1'b1 )
	        @( dma_read_chnl_valid_started );
	
	    dma_read_chnl_valid <= dma_read_chnl_valid_firstEdge;
	    if ( dma_read_chnl_valid_firstHalf > 0.0 ) begin
	        #dma_read_chnl_valid_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    else begin
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    if ( dma_read_chnl_valid_secondHalf > 0.0 ) begin
	        #dma_read_chnl_valid_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg conf_done_firstEdge;
	reg conf_done_initialized;
	reg conf_done_started;
	real conf_done_startTime;
	real conf_done_firstHalf;
	real conf_done_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    conf_done_firstEdge = 1'b1;
	    conf_done_startTime = 0.000;    // Offset from time 0 to first edge.
	    conf_done_firstHalf = 5.000;    // Delay for first half of cycle.
	    conf_done_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on conf_done_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( conf_done_initialized !== 1'b1 )
	        @( conf_done_initialized );
	
	    if ( conf_done_startTime > 0.0 ) begin
	        conf_done_started = #conf_done_startTime 1;
	    end
	    else begin
	        conf_done_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.conf_done ) begin
	    if ( conf_done_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( conf_done_started !== 1'b1 )
	        @( conf_done_started );
	
	    conf_done <= conf_done_firstEdge;
	    if ( conf_done_firstHalf > 0.0 ) begin
	        #conf_done_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        conf_done = ~conf_done_firstEdge;
	    end
	    else begin
	        conf_done = ~conf_done_firstEdge;
	    end
	    if ( conf_done_secondHalf > 0.0 ) begin
	        #conf_done_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_ctrl_ready_firstEdge;
	reg dma_read_ctrl_ready_initialized;
	reg dma_read_ctrl_ready_started;
	real dma_read_ctrl_ready_startTime;
	real dma_read_ctrl_ready_firstHalf;
	real dma_read_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_ctrl_ready_firstEdge = 1'b1;
	    dma_read_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_ctrl_ready_initialized !== 1'b1 )
	        @( dma_read_ctrl_ready_initialized );
	
	    if ( dma_read_ctrl_ready_startTime > 0.0 ) begin
	        dma_read_ctrl_ready_started = #dma_read_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_read_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_ctrl_ready ) begin
	    if ( dma_read_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_ctrl_ready_started !== 1'b1 )
	        @( dma_read_ctrl_ready_started );
	
	    dma_read_ctrl_ready <= dma_read_ctrl_ready_firstEdge;
	    if ( dma_read_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    if ( dma_read_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_ctrl_ready_firstEdge;
	reg dma_write_ctrl_ready_initialized;
	reg dma_write_ctrl_ready_started;
	real dma_write_ctrl_ready_startTime;
	real dma_write_ctrl_ready_firstHalf;
	real dma_write_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_ctrl_ready_firstEdge = 1'b1;
	    dma_write_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_ctrl_ready_initialized !== 1'b1 )
	        @( dma_write_ctrl_ready_initialized );
	
	    if ( dma_write_ctrl_ready_startTime > 0.0 ) begin
	        dma_write_ctrl_ready_started = #dma_write_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_write_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_ctrl_ready ) begin
	    if ( dma_write_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_ctrl_ready_started !== 1'b1 )
	        @( dma_write_ctrl_ready_started );
	
	    dma_write_ctrl_ready <= dma_write_ctrl_ready_firstEdge;
	    if ( dma_write_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    if ( dma_write_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_chnl_ready_firstEdge;
	reg dma_write_chnl_ready_initialized;
	reg dma_write_chnl_ready_started;
	real dma_write_chnl_ready_startTime;
	real dma_write_chnl_ready_firstHalf;
	real dma_write_chnl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_chnl_ready_firstEdge = 1'b1;
	    dma_write_chnl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_chnl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_chnl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_chnl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_chnl_ready_initialized !== 1'b1 )
	        @( dma_write_chnl_ready_initialized );
	
	    if ( dma_write_chnl_ready_startTime > 0.0 ) begin
	        dma_write_chnl_ready_started = #dma_write_chnl_ready_startTime 1;
	    end
	    else begin
	        dma_write_chnl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_chnl_ready ) begin
	    if ( dma_write_chnl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_chnl_ready_started !== 1'b1 )
	        @( dma_write_chnl_ready_started );
	
	    dma_write_chnl_ready <= dma_write_chnl_ready_firstEdge;
	    if ( dma_write_chnl_ready_firstHalf > 0.0 ) begin
	        #dma_write_chnl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    else begin
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    if ( dma_write_chnl_ready_secondHalf > 0.0 ) begin
	        #dma_write_chnl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	
	`endif
	`ifdef ioConfig_IOCFG_DMA128
	
	// Variables that can be set externally
	reg clk_firstEdge;
	reg clk_initialized;
	reg clk_started;
	real clk_startTime;
	real clk_firstHalf;
	real clk_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    clk_firstEdge = 1'b1;
	    clk_startTime = 0.000;    // Offset from time 0 to first edge.
	    clk_firstHalf = 5.000;    // Delay for first half of cycle.
	    clk_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on clk_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( clk_initialized !== 1'b1 )
	        @( clk_initialized );
	
	    if ( clk_startTime > 0.0 ) begin
	        clk_started = #clk_startTime 1;
	    end
	    else begin
	        clk_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.clk ) begin
	    if ( clk_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( clk_started !== 1'b1 )
	        @( clk_started );
	
	    clk <= clk_firstEdge;
	    if ( clk_firstHalf > 0.0 ) begin
	        #clk_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        clk = ~clk_firstEdge;
	    end
	    else begin
	        clk = ~clk_firstEdge;
	    end
	    if ( clk_secondHalf > 0.0 ) begin
	        #clk_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg rst_firstEdge;
	reg rst_initialized;
	reg rst_started;
	real rst_startTime;
	real rst_firstHalf;
	real rst_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    rst_firstEdge = 1'b1;
	    rst_startTime = 0.000;    // Offset from time 0 to first edge.
	    rst_firstHalf = 5.000;    // Delay for first half of cycle.
	    rst_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on rst_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( rst_initialized !== 1'b1 )
	        @( rst_initialized );
	
	    if ( rst_startTime > 0.0 ) begin
	        rst_started = #rst_startTime 1;
	    end
	    else begin
	        rst_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.rst ) begin
	    if ( rst_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( rst_started !== 1'b1 )
	        @( rst_started );
	
	    rst <= rst_firstEdge;
	    if ( rst_firstHalf > 0.0 ) begin
	        #rst_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        rst = ~rst_firstEdge;
	    end
	    else begin
	        rst = ~rst_firstEdge;
	    end
	    if ( rst_secondHalf > 0.0 ) begin
	        #rst_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_chnl_valid_firstEdge;
	reg dma_read_chnl_valid_initialized;
	reg dma_read_chnl_valid_started;
	real dma_read_chnl_valid_startTime;
	real dma_read_chnl_valid_firstHalf;
	real dma_read_chnl_valid_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_chnl_valid_firstEdge = 1'b1;
	    dma_read_chnl_valid_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_chnl_valid_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_chnl_valid_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_chnl_valid_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_chnl_valid_initialized !== 1'b1 )
	        @( dma_read_chnl_valid_initialized );
	
	    if ( dma_read_chnl_valid_startTime > 0.0 ) begin
	        dma_read_chnl_valid_started = #dma_read_chnl_valid_startTime 1;
	    end
	    else begin
	        dma_read_chnl_valid_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_chnl_valid ) begin
	    if ( dma_read_chnl_valid_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_chnl_valid_started !== 1'b1 )
	        @( dma_read_chnl_valid_started );
	
	    dma_read_chnl_valid <= dma_read_chnl_valid_firstEdge;
	    if ( dma_read_chnl_valid_firstHalf > 0.0 ) begin
	        #dma_read_chnl_valid_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    else begin
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    if ( dma_read_chnl_valid_secondHalf > 0.0 ) begin
	        #dma_read_chnl_valid_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg conf_done_firstEdge;
	reg conf_done_initialized;
	reg conf_done_started;
	real conf_done_startTime;
	real conf_done_firstHalf;
	real conf_done_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    conf_done_firstEdge = 1'b1;
	    conf_done_startTime = 0.000;    // Offset from time 0 to first edge.
	    conf_done_firstHalf = 5.000;    // Delay for first half of cycle.
	    conf_done_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on conf_done_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( conf_done_initialized !== 1'b1 )
	        @( conf_done_initialized );
	
	    if ( conf_done_startTime > 0.0 ) begin
	        conf_done_started = #conf_done_startTime 1;
	    end
	    else begin
	        conf_done_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.conf_done ) begin
	    if ( conf_done_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( conf_done_started !== 1'b1 )
	        @( conf_done_started );
	
	    conf_done <= conf_done_firstEdge;
	    if ( conf_done_firstHalf > 0.0 ) begin
	        #conf_done_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        conf_done = ~conf_done_firstEdge;
	    end
	    else begin
	        conf_done = ~conf_done_firstEdge;
	    end
	    if ( conf_done_secondHalf > 0.0 ) begin
	        #conf_done_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_ctrl_ready_firstEdge;
	reg dma_read_ctrl_ready_initialized;
	reg dma_read_ctrl_ready_started;
	real dma_read_ctrl_ready_startTime;
	real dma_read_ctrl_ready_firstHalf;
	real dma_read_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_ctrl_ready_firstEdge = 1'b1;
	    dma_read_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_ctrl_ready_initialized !== 1'b1 )
	        @( dma_read_ctrl_ready_initialized );
	
	    if ( dma_read_ctrl_ready_startTime > 0.0 ) begin
	        dma_read_ctrl_ready_started = #dma_read_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_read_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_ctrl_ready ) begin
	    if ( dma_read_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_ctrl_ready_started !== 1'b1 )
	        @( dma_read_ctrl_ready_started );
	
	    dma_read_ctrl_ready <= dma_read_ctrl_ready_firstEdge;
	    if ( dma_read_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    if ( dma_read_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_ctrl_ready_firstEdge;
	reg dma_write_ctrl_ready_initialized;
	reg dma_write_ctrl_ready_started;
	real dma_write_ctrl_ready_startTime;
	real dma_write_ctrl_ready_firstHalf;
	real dma_write_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_ctrl_ready_firstEdge = 1'b1;
	    dma_write_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_ctrl_ready_initialized !== 1'b1 )
	        @( dma_write_ctrl_ready_initialized );
	
	    if ( dma_write_ctrl_ready_startTime > 0.0 ) begin
	        dma_write_ctrl_ready_started = #dma_write_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_write_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_ctrl_ready ) begin
	    if ( dma_write_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_ctrl_ready_started !== 1'b1 )
	        @( dma_write_ctrl_ready_started );
	
	    dma_write_ctrl_ready <= dma_write_ctrl_ready_firstEdge;
	    if ( dma_write_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    if ( dma_write_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_chnl_ready_firstEdge;
	reg dma_write_chnl_ready_initialized;
	reg dma_write_chnl_ready_started;
	real dma_write_chnl_ready_startTime;
	real dma_write_chnl_ready_firstHalf;
	real dma_write_chnl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_chnl_ready_firstEdge = 1'b1;
	    dma_write_chnl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_chnl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_chnl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_chnl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_chnl_ready_initialized !== 1'b1 )
	        @( dma_write_chnl_ready_initialized );
	
	    if ( dma_write_chnl_ready_startTime > 0.0 ) begin
	        dma_write_chnl_ready_started = #dma_write_chnl_ready_startTime 1;
	    end
	    else begin
	        dma_write_chnl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_chnl_ready ) begin
	    if ( dma_write_chnl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_chnl_ready_started !== 1'b1 )
	        @( dma_write_chnl_ready_started );
	
	    dma_write_chnl_ready <= dma_write_chnl_ready_firstEdge;
	    if ( dma_write_chnl_ready_firstHalf > 0.0 ) begin
	        #dma_write_chnl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    else begin
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    if ( dma_write_chnl_ready_secondHalf > 0.0 ) begin
	        #dma_write_chnl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	
	`endif
	`ifdef ioConfig_IOCFG_DMA256
	
	// Variables that can be set externally
	reg clk_firstEdge;
	reg clk_initialized;
	reg clk_started;
	real clk_startTime;
	real clk_firstHalf;
	real clk_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    clk_firstEdge = 1'b1;
	    clk_startTime = 0.000;    // Offset from time 0 to first edge.
	    clk_firstHalf = 5.000;    // Delay for first half of cycle.
	    clk_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on clk_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( clk_initialized !== 1'b1 )
	        @( clk_initialized );
	
	    if ( clk_startTime > 0.0 ) begin
	        clk_started = #clk_startTime 1;
	    end
	    else begin
	        clk_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.clk ) begin
	    if ( clk_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( clk_started !== 1'b1 )
	        @( clk_started );
	
	    clk <= clk_firstEdge;
	    if ( clk_firstHalf > 0.0 ) begin
	        #clk_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        clk = ~clk_firstEdge;
	    end
	    else begin
	        clk = ~clk_firstEdge;
	    end
	    if ( clk_secondHalf > 0.0 ) begin
	        #clk_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg rst_firstEdge;
	reg rst_initialized;
	reg rst_started;
	real rst_startTime;
	real rst_firstHalf;
	real rst_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    rst_firstEdge = 1'b1;
	    rst_startTime = 0.000;    // Offset from time 0 to first edge.
	    rst_firstHalf = 5.000;    // Delay for first half of cycle.
	    rst_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on rst_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( rst_initialized !== 1'b1 )
	        @( rst_initialized );
	
	    if ( rst_startTime > 0.0 ) begin
	        rst_started = #rst_startTime 1;
	    end
	    else begin
	        rst_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.rst ) begin
	    if ( rst_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( rst_started !== 1'b1 )
	        @( rst_started );
	
	    rst <= rst_firstEdge;
	    if ( rst_firstHalf > 0.0 ) begin
	        #rst_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        rst = ~rst_firstEdge;
	    end
	    else begin
	        rst = ~rst_firstEdge;
	    end
	    if ( rst_secondHalf > 0.0 ) begin
	        #rst_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_chnl_valid_firstEdge;
	reg dma_read_chnl_valid_initialized;
	reg dma_read_chnl_valid_started;
	real dma_read_chnl_valid_startTime;
	real dma_read_chnl_valid_firstHalf;
	real dma_read_chnl_valid_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_chnl_valid_firstEdge = 1'b1;
	    dma_read_chnl_valid_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_chnl_valid_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_chnl_valid_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_chnl_valid_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_chnl_valid_initialized !== 1'b1 )
	        @( dma_read_chnl_valid_initialized );
	
	    if ( dma_read_chnl_valid_startTime > 0.0 ) begin
	        dma_read_chnl_valid_started = #dma_read_chnl_valid_startTime 1;
	    end
	    else begin
	        dma_read_chnl_valid_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_chnl_valid ) begin
	    if ( dma_read_chnl_valid_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_chnl_valid_started !== 1'b1 )
	        @( dma_read_chnl_valid_started );
	
	    dma_read_chnl_valid <= dma_read_chnl_valid_firstEdge;
	    if ( dma_read_chnl_valid_firstHalf > 0.0 ) begin
	        #dma_read_chnl_valid_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    else begin
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    if ( dma_read_chnl_valid_secondHalf > 0.0 ) begin
	        #dma_read_chnl_valid_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg conf_done_firstEdge;
	reg conf_done_initialized;
	reg conf_done_started;
	real conf_done_startTime;
	real conf_done_firstHalf;
	real conf_done_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    conf_done_firstEdge = 1'b1;
	    conf_done_startTime = 0.000;    // Offset from time 0 to first edge.
	    conf_done_firstHalf = 5.000;    // Delay for first half of cycle.
	    conf_done_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on conf_done_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( conf_done_initialized !== 1'b1 )
	        @( conf_done_initialized );
	
	    if ( conf_done_startTime > 0.0 ) begin
	        conf_done_started = #conf_done_startTime 1;
	    end
	    else begin
	        conf_done_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.conf_done ) begin
	    if ( conf_done_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( conf_done_started !== 1'b1 )
	        @( conf_done_started );
	
	    conf_done <= conf_done_firstEdge;
	    if ( conf_done_firstHalf > 0.0 ) begin
	        #conf_done_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        conf_done = ~conf_done_firstEdge;
	    end
	    else begin
	        conf_done = ~conf_done_firstEdge;
	    end
	    if ( conf_done_secondHalf > 0.0 ) begin
	        #conf_done_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_ctrl_ready_firstEdge;
	reg dma_read_ctrl_ready_initialized;
	reg dma_read_ctrl_ready_started;
	real dma_read_ctrl_ready_startTime;
	real dma_read_ctrl_ready_firstHalf;
	real dma_read_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_ctrl_ready_firstEdge = 1'b1;
	    dma_read_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_ctrl_ready_initialized !== 1'b1 )
	        @( dma_read_ctrl_ready_initialized );
	
	    if ( dma_read_ctrl_ready_startTime > 0.0 ) begin
	        dma_read_ctrl_ready_started = #dma_read_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_read_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_ctrl_ready ) begin
	    if ( dma_read_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_ctrl_ready_started !== 1'b1 )
	        @( dma_read_ctrl_ready_started );
	
	    dma_read_ctrl_ready <= dma_read_ctrl_ready_firstEdge;
	    if ( dma_read_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    if ( dma_read_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_ctrl_ready_firstEdge;
	reg dma_write_ctrl_ready_initialized;
	reg dma_write_ctrl_ready_started;
	real dma_write_ctrl_ready_startTime;
	real dma_write_ctrl_ready_firstHalf;
	real dma_write_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_ctrl_ready_firstEdge = 1'b1;
	    dma_write_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_ctrl_ready_initialized !== 1'b1 )
	        @( dma_write_ctrl_ready_initialized );
	
	    if ( dma_write_ctrl_ready_startTime > 0.0 ) begin
	        dma_write_ctrl_ready_started = #dma_write_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_write_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_ctrl_ready ) begin
	    if ( dma_write_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_ctrl_ready_started !== 1'b1 )
	        @( dma_write_ctrl_ready_started );
	
	    dma_write_ctrl_ready <= dma_write_ctrl_ready_firstEdge;
	    if ( dma_write_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    if ( dma_write_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_chnl_ready_firstEdge;
	reg dma_write_chnl_ready_initialized;
	reg dma_write_chnl_ready_started;
	real dma_write_chnl_ready_startTime;
	real dma_write_chnl_ready_firstHalf;
	real dma_write_chnl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_chnl_ready_firstEdge = 1'b1;
	    dma_write_chnl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_chnl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_chnl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_chnl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_chnl_ready_initialized !== 1'b1 )
	        @( dma_write_chnl_ready_initialized );
	
	    if ( dma_write_chnl_ready_startTime > 0.0 ) begin
	        dma_write_chnl_ready_started = #dma_write_chnl_ready_startTime 1;
	    end
	    else begin
	        dma_write_chnl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_chnl_ready ) begin
	    if ( dma_write_chnl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_chnl_ready_started !== 1'b1 )
	        @( dma_write_chnl_ready_started );
	
	    dma_write_chnl_ready <= dma_write_chnl_ready_firstEdge;
	    if ( dma_write_chnl_ready_firstHalf > 0.0 ) begin
	        #dma_write_chnl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    else begin
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    if ( dma_write_chnl_ready_secondHalf > 0.0 ) begin
	        #dma_write_chnl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	
	`endif
	`ifdef ioConfig_IOCFG_DMA512
	
	// Variables that can be set externally
	reg clk_firstEdge;
	reg clk_initialized;
	reg clk_started;
	real clk_startTime;
	real clk_firstHalf;
	real clk_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    clk_firstEdge = 1'b1;
	    clk_startTime = 0.000;    // Offset from time 0 to first edge.
	    clk_firstHalf = 5.000;    // Delay for first half of cycle.
	    clk_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on clk_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( clk_initialized !== 1'b1 )
	        @( clk_initialized );
	
	    if ( clk_startTime > 0.0 ) begin
	        clk_started = #clk_startTime 1;
	    end
	    else begin
	        clk_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.clk ) begin
	    if ( clk_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( clk_started !== 1'b1 )
	        @( clk_started );
	
	    clk <= clk_firstEdge;
	    if ( clk_firstHalf > 0.0 ) begin
	        #clk_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        clk = ~clk_firstEdge;
	    end
	    else begin
	        clk = ~clk_firstEdge;
	    end
	    if ( clk_secondHalf > 0.0 ) begin
	        #clk_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg rst_firstEdge;
	reg rst_initialized;
	reg rst_started;
	real rst_startTime;
	real rst_firstHalf;
	real rst_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    rst_firstEdge = 1'b1;
	    rst_startTime = 0.000;    // Offset from time 0 to first edge.
	    rst_firstHalf = 5.000;    // Delay for first half of cycle.
	    rst_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on rst_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( rst_initialized !== 1'b1 )
	        @( rst_initialized );
	
	    if ( rst_startTime > 0.0 ) begin
	        rst_started = #rst_startTime 1;
	    end
	    else begin
	        rst_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.rst ) begin
	    if ( rst_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( rst_started !== 1'b1 )
	        @( rst_started );
	
	    rst <= rst_firstEdge;
	    if ( rst_firstHalf > 0.0 ) begin
	        #rst_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        rst = ~rst_firstEdge;
	    end
	    else begin
	        rst = ~rst_firstEdge;
	    end
	    if ( rst_secondHalf > 0.0 ) begin
	        #rst_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_chnl_valid_firstEdge;
	reg dma_read_chnl_valid_initialized;
	reg dma_read_chnl_valid_started;
	real dma_read_chnl_valid_startTime;
	real dma_read_chnl_valid_firstHalf;
	real dma_read_chnl_valid_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_chnl_valid_firstEdge = 1'b1;
	    dma_read_chnl_valid_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_chnl_valid_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_chnl_valid_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_chnl_valid_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_chnl_valid_initialized !== 1'b1 )
	        @( dma_read_chnl_valid_initialized );
	
	    if ( dma_read_chnl_valid_startTime > 0.0 ) begin
	        dma_read_chnl_valid_started = #dma_read_chnl_valid_startTime 1;
	    end
	    else begin
	        dma_read_chnl_valid_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_chnl_valid ) begin
	    if ( dma_read_chnl_valid_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_chnl_valid_started !== 1'b1 )
	        @( dma_read_chnl_valid_started );
	
	    dma_read_chnl_valid <= dma_read_chnl_valid_firstEdge;
	    if ( dma_read_chnl_valid_firstHalf > 0.0 ) begin
	        #dma_read_chnl_valid_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    else begin
	        dma_read_chnl_valid = ~dma_read_chnl_valid_firstEdge;
	    end
	    if ( dma_read_chnl_valid_secondHalf > 0.0 ) begin
	        #dma_read_chnl_valid_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg conf_done_firstEdge;
	reg conf_done_initialized;
	reg conf_done_started;
	real conf_done_startTime;
	real conf_done_firstHalf;
	real conf_done_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    conf_done_firstEdge = 1'b1;
	    conf_done_startTime = 0.000;    // Offset from time 0 to first edge.
	    conf_done_firstHalf = 5.000;    // Delay for first half of cycle.
	    conf_done_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on conf_done_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( conf_done_initialized !== 1'b1 )
	        @( conf_done_initialized );
	
	    if ( conf_done_startTime > 0.0 ) begin
	        conf_done_started = #conf_done_startTime 1;
	    end
	    else begin
	        conf_done_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.conf_done ) begin
	    if ( conf_done_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( conf_done_started !== 1'b1 )
	        @( conf_done_started );
	
	    conf_done <= conf_done_firstEdge;
	    if ( conf_done_firstHalf > 0.0 ) begin
	        #conf_done_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        conf_done = ~conf_done_firstEdge;
	    end
	    else begin
	        conf_done = ~conf_done_firstEdge;
	    end
	    if ( conf_done_secondHalf > 0.0 ) begin
	        #conf_done_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_read_ctrl_ready_firstEdge;
	reg dma_read_ctrl_ready_initialized;
	reg dma_read_ctrl_ready_started;
	real dma_read_ctrl_ready_startTime;
	real dma_read_ctrl_ready_firstHalf;
	real dma_read_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_read_ctrl_ready_firstEdge = 1'b1;
	    dma_read_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_read_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_read_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_read_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_read_ctrl_ready_initialized !== 1'b1 )
	        @( dma_read_ctrl_ready_initialized );
	
	    if ( dma_read_ctrl_ready_startTime > 0.0 ) begin
	        dma_read_ctrl_ready_started = #dma_read_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_read_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_read_ctrl_ready ) begin
	    if ( dma_read_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_read_ctrl_ready_started !== 1'b1 )
	        @( dma_read_ctrl_ready_started );
	
	    dma_read_ctrl_ready <= dma_read_ctrl_ready_firstEdge;
	    if ( dma_read_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_read_ctrl_ready = ~dma_read_ctrl_ready_firstEdge;
	    end
	    if ( dma_read_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_read_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_ctrl_ready_firstEdge;
	reg dma_write_ctrl_ready_initialized;
	reg dma_write_ctrl_ready_started;
	real dma_write_ctrl_ready_startTime;
	real dma_write_ctrl_ready_firstHalf;
	real dma_write_ctrl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_ctrl_ready_firstEdge = 1'b1;
	    dma_write_ctrl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_ctrl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_ctrl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_ctrl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_ctrl_ready_initialized !== 1'b1 )
	        @( dma_write_ctrl_ready_initialized );
	
	    if ( dma_write_ctrl_ready_startTime > 0.0 ) begin
	        dma_write_ctrl_ready_started = #dma_write_ctrl_ready_startTime 1;
	    end
	    else begin
	        dma_write_ctrl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_ctrl_ready ) begin
	    if ( dma_write_ctrl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_ctrl_ready_started !== 1'b1 )
	        @( dma_write_ctrl_ready_started );
	
	    dma_write_ctrl_ready <= dma_write_ctrl_ready_firstEdge;
	    if ( dma_write_ctrl_ready_firstHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    else begin
	        dma_write_ctrl_ready = ~dma_write_ctrl_ready_firstEdge;
	    end
	    if ( dma_write_ctrl_ready_secondHalf > 0.0 ) begin
	        #dma_write_ctrl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	// Variables that can be set externally
	reg dma_write_chnl_ready_firstEdge;
	reg dma_write_chnl_ready_initialized;
	reg dma_write_chnl_ready_started;
	real dma_write_chnl_ready_startTime;
	real dma_write_chnl_ready_firstHalf;
	real dma_write_chnl_ready_secondHalf;
	
	initial begin
	
	    // Only send values from SystemC to the simulator at clock edges.
	    hubSetOption("cycleOnly=1");
	
	    // Default values for config variables.  Values come from static clock.
	    dma_write_chnl_ready_firstEdge = 1'b1;
	    dma_write_chnl_ready_startTime = 0.000;    // Offset from time 0 to first edge.
	    dma_write_chnl_ready_firstHalf = 5.000;    // Delay for first half of cycle.
	    dma_write_chnl_ready_secondHalf = 5.000;    // Second half of cycle less offset value.
	
	    // Make sure that we detect the transition on dma_write_chnl_ready_initalized.
	    hubScheduleDelayedAssignments;
	
	    while ( dma_write_chnl_ready_initialized !== 1'b1 )
	        @( dma_write_chnl_ready_initialized );
	
	    if ( dma_write_chnl_ready_startTime > 0.0 ) begin
	        dma_write_chnl_ready_started = #dma_write_chnl_ready_startTime 1;
	    end
	    else begin
	        dma_write_chnl_ready_started = 1;
	    end
	end
	
	// Make sure that we process delayed assignments after the clock edge.
	always @( dummy0.dma_write_chnl_ready ) begin
	    if ( dma_write_chnl_ready_started === 1'b1 ) begin
	        if ($time == top.cur_time) top.n_cur_time=top.n_cur_time-1;
	        else top.n_cur_time=0;
	        if (top.n_cur_time==0) begin
	            hubScheduleDelayedAssignments;
	        end
	    end
	end
	
	always begin
	    // Make sure our delays are non-zero before starting simulation.
	    while ( dma_write_chnl_ready_started !== 1'b1 )
	        @( dma_write_chnl_ready_started );
	
	    dma_write_chnl_ready <= dma_write_chnl_ready_firstEdge;
	    if ( dma_write_chnl_ready_firstHalf > 0.0 ) begin
	        #dma_write_chnl_ready_firstHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    else begin
	        dma_write_chnl_ready = ~dma_write_chnl_ready_firstEdge;
	    end
	    if ( dma_write_chnl_ready_secondHalf > 0.0 ) begin
	        #dma_write_chnl_ready_secondHalf;
	        if ($time==top.cur_time) begin
	            top.n_cur_time=top.n_cur_time+1;
	        end else begin
	            top.n_cur_time=1; top.cur_time=$time;
	        end
	    end
	end
	
	`endif


endmodule
