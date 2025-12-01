#ifdef ioConfig_IOCFG_DMA64
	if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_vcd );
		}
	}
	if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_fsdb );
		}
	}
#endif

#ifdef ioConfig_IOCFG_DMA128
	if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_vcd );
		}
	}
	if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_fsdb );
		}
	}
#endif

#ifdef ioConfig_IOCFG_DMA256
	if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_vcd );
		}
	}
	if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_fsdb );
		}
	}
#endif

#ifdef ioConfig_IOCFG_DMA512
	if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_vcd );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_vcd );
		}
	}
	if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
		if ( dummy0 != NULL ) {
			esc_trace_signal( &dummy0->clk, ( std::string(name()) + std::string( ".dummy.clk" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->rst, ( std::string(name()) + std::string( ".dummy.rst" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_chnl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_info, ( std::string(name()) + std::string( ".dummy.conf_info" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->conf_done, ( std::string(name()) + std::string( ".dummy.conf_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->acc_done, ( std::string(name()) + std::string( ".dummy.acc_done" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->debug, ( std::string(name()) + std::string( ".dummy.debug" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_read_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_read_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.data, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_ctrl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_ctrl.ready" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.valid, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.valid" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.data, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.data" ) ).c_str(), esc_trace_fsdb );
			esc_trace_signal( &dummy0->dma_write_chnl.ready, ( std::string(name()) + std::string( ".dummy.dma_write_chnl.ready" ) ).c_str(), esc_trace_fsdb );
		}
	}
#endif

