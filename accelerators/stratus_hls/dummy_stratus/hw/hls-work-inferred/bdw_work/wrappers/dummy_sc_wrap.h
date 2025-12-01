/****************************************************************************
*
*  Copyright (c) 2017, Cadence Design Systems. All Rights Reserved.
*
*  This file contains confidential information that may not be
*  distributed under any circumstances without the written permision
*  of Cadence Design Systems.
*
****************************************************************************/


#ifndef _DUMMY_SC_WRAP_INCLUDED_
#define _DUMMY_SC_WRAP_INCLUDED_

#include <systemc.h>

struct dummy;

#include "dummy_conf_info.hpp"
#include "cynw_put_get_channels/cynw_put_get_port_base.h"
#include "core/systems/esp_dma_info.hpp"


// Declaration of wrapper with BEH level ports

SC_MODULE(dummy_wrapper)
{
public:

	
#if defined ( ioConfig_IOCFG_DMA64 )
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< conf_info_t > conf_info;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< unsigned int > debug;
	cynw::cynw_get_port_base <sc_dt::sc_bv <(int)64 > > dma_read_chnl;
	cynw::cynw_put_port_base <dma_info_t > dma_read_ctrl;
	cynw::cynw_put_port_base <dma_info_t > dma_write_ctrl;
	cynw::cynw_put_port_base <sc_dt::sc_bv <(int)64 > > dma_write_chnl;
	
#elif defined ( ioConfig_IOCFG_DMA128)
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< conf_info_t > conf_info;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< unsigned int > debug;
	cynw::cynw_get_port_base <sc_dt::sc_bv <(int)128 > > dma_read_chnl;
	cynw::cynw_put_port_base <dma_info_t > dma_read_ctrl;
	cynw::cynw_put_port_base <dma_info_t > dma_write_ctrl;
	cynw::cynw_put_port_base <sc_dt::sc_bv <(int)128 > > dma_write_chnl;
	
#elif defined ( ioConfig_IOCFG_DMA256)
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< conf_info_t > conf_info;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< unsigned int > debug;
	cynw::cynw_get_port_base <sc_dt::sc_bv <(int)256 > > dma_read_chnl;
	cynw::cynw_put_port_base <dma_info_t > dma_read_ctrl;
	cynw::cynw_put_port_base <dma_info_t > dma_write_ctrl;
	cynw::cynw_put_port_base <sc_dt::sc_bv <(int)256 > > dma_write_chnl;
	
	
#else
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< conf_info_t > conf_info;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< unsigned int > debug;
	cynw::cynw_get_port_base <sc_dt::sc_bv <(int)512 > > dma_read_chnl;
	cynw::cynw_put_port_base <dma_info_t > dma_read_ctrl;
	cynw::cynw_put_port_base <dma_info_t > dma_write_ctrl;
	cynw::cynw_put_port_base <sc_dt::sc_bv <(int)512 > > dma_write_chnl;
	
#endif

    
    // These signals are used to connect structured ports or ports that need
    // type conversion to the RTL ports.
    
#if defined ( ioConfig_IOCFG_DMA64 )
    
    sc_signal< sc_biguint< 64 > > dma_read_chnl_data_conv;
    sc_signal< sc_uint< 32 > > conf_info_tokens;
    sc_signal< sc_uint< 32 > > conf_info_batch;
    sc_signal< sc_uint< 32 > > conf_info_source;
    sc_signal< sc_uint< 32 > > conf_info_ndests;
    sc_signal< sc_uint< 32 > > debug_conv;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_read_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_read_ctrl_data_user;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_write_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_write_ctrl_data_user;
    sc_signal< sc_biguint< 64 > > dma_write_chnl_data_conv;
    
#elif defined ( ioConfig_IOCFG_DMA128)
    
    sc_signal< sc_biguint< 128 > > dma_read_chnl_data_conv;
    sc_signal< sc_uint< 32 > > conf_info_tokens;
    sc_signal< sc_uint< 32 > > conf_info_batch;
    sc_signal< sc_uint< 32 > > conf_info_source;
    sc_signal< sc_uint< 32 > > conf_info_ndests;
    sc_signal< sc_uint< 32 > > debug_conv;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_read_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_read_ctrl_data_user;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_write_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_write_ctrl_data_user;
    sc_signal< sc_biguint< 128 > > dma_write_chnl_data_conv;
    
#elif defined ( ioConfig_IOCFG_DMA256)
    
    sc_signal< sc_biguint< 256 > > dma_read_chnl_data_conv;
    sc_signal< sc_uint< 32 > > conf_info_tokens;
    sc_signal< sc_uint< 32 > > conf_info_batch;
    sc_signal< sc_uint< 32 > > conf_info_source;
    sc_signal< sc_uint< 32 > > conf_info_ndests;
    sc_signal< sc_uint< 32 > > debug_conv;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_read_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_read_ctrl_data_user;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_write_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_write_ctrl_data_user;
    sc_signal< sc_biguint< 256 > > dma_write_chnl_data_conv;
    
    
#else
    
    sc_signal< sc_biguint< 512 > > dma_read_chnl_data_conv;
    sc_signal< sc_uint< 32 > > conf_info_tokens;
    sc_signal< sc_uint< 32 > > conf_info_batch;
    sc_signal< sc_uint< 32 > > conf_info_source;
    sc_signal< sc_uint< 32 > > conf_info_ndests;
    sc_signal< sc_uint< 32 > > debug_conv;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_read_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_read_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_read_ctrl_data_user;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_index;
    sc_signal< sc_uint< 32 > > dma_write_ctrl_data_length;
    sc_signal< sc_biguint< 3 > > dma_write_ctrl_data_size;
    sc_signal< sc_biguint< 5 > > dma_write_ctrl_data_user;
    sc_signal< sc_biguint< 512 > > dma_write_chnl_data_conv;
    
#endif

    
	// create the netlist
    void InitInstances( );
    void InitThreads();

    // delete the netlist
    void DeleteInstances();

    // The following threads are used to connect structured ports to the actual
    // RTL ports.
    
#if defined ( ioConfig_IOCFG_DMA64 )
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info_tokens();
    void thread_conf_info_batch();
    void thread_conf_info_source();
    void thread_conf_info_ndests();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data();
    void thread_dma_write_ctrl_data();
    void thread_dma_write_chnl_data_conv();
    
#elif defined ( ioConfig_IOCFG_DMA128)
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info_tokens();
    void thread_conf_info_batch();
    void thread_conf_info_source();
    void thread_conf_info_ndests();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data();
    void thread_dma_write_ctrl_data();
    void thread_dma_write_chnl_data_conv();
    
#elif defined ( ioConfig_IOCFG_DMA256)
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info_tokens();
    void thread_conf_info_batch();
    void thread_conf_info_source();
    void thread_conf_info_ndests();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data();
    void thread_dma_write_ctrl_data();
    void thread_dma_write_chnl_data_conv();
    
    
#else
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info_tokens();
    void thread_conf_info_batch();
    void thread_conf_info_source();
    void thread_conf_info_ndests();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data();
    void thread_dma_write_ctrl_data();
    void thread_dma_write_chnl_data_conv();
    
#endif


	SC_HAS_PROCESS(dummy_wrapper);

    	dummy_wrapper( sc_module_name name = sc_module_name( sc_gen_unique_name("dummy")) )
		: sc_module(name)
		  
#if defined ( ioConfig_IOCFG_DMA64 )
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info("conf_info")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl("dma_read_chnl")
		  	,dma_read_ctrl("dma_read_ctrl")
		  	,dma_write_ctrl("dma_write_ctrl")
		  	,dma_write_chnl("dma_write_chnl")
		  	
#elif defined ( ioConfig_IOCFG_DMA128)
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info("conf_info")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl("dma_read_chnl")
		  	,dma_read_ctrl("dma_read_ctrl")
		  	,dma_write_ctrl("dma_write_ctrl")
		  	,dma_write_chnl("dma_write_chnl")
		  	
#elif defined ( ioConfig_IOCFG_DMA256)
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info("conf_info")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl("dma_read_chnl")
		  	,dma_read_ctrl("dma_read_ctrl")
		  	,dma_write_ctrl("dma_write_ctrl")
		  	,dma_write_chnl("dma_write_chnl")
		  	
		  
#else
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info("conf_info")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl("dma_read_chnl")
		  	,dma_read_ctrl("dma_read_ctrl")
		  	,dma_write_ctrl("dma_write_ctrl")
		  	,dma_write_chnl("dma_write_chnl")
		  	
#endif
		  

		  ,dummy0(0)

    {
        InitInstances( );
		InitThreads();
    }

    // destructor
    ~dummy_wrapper()
    {
        DeleteInstances();
    }

	dummy* dummy0;
};

#endif /* _DUMMY_SC_WRAP_INCLUDED_ */
