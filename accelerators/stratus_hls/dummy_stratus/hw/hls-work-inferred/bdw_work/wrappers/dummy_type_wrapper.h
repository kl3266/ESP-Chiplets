/****************************************************************************
*
*  Copyright (c) 2015, Cadence Design Systems. All Rights Reserved.
*
*  This file contains confidential information that may not be
*  distributed under any circumstances without the written permision
*  of Cadence Design Systems.
*
****************************************************************************/
/****************************************************************************
*
* This file contains the dummy_type_wrapper module
* for use in the verilog verification wrapper dummy_vlwrapper.v
* It creats an instance of the dummy module and has threads
* for converting the BEH ports to RTL level ports on the wrapper.
*
****************************************************************************/


#ifndef _DUMMY_TYPE_WRAP_INCLUDED_
#define _DUMMY_TYPE_WRAP_INCLUDED_

#if !defined(ioConfig_IOCFG_DMA64) && !defined(ioConfig_IOCFG_DMA128) && !defined(ioConfig_IOCFG_DMA256) && !defined(ioConfig_IOCFG_DMA512)
#if defined(_p_ioConfig_IOCFG_DMA64)
#define ioConfig_IOCFG_DMA64 1
#endif
#if defined(_p_ioConfig_IOCFG_DMA128)
#define ioConfig_IOCFG_DMA128 1
#endif
#if defined(_p_ioConfig_IOCFG_DMA256)
#define ioConfig_IOCFG_DMA256 1
#endif
#if defined(_p_ioConfig_IOCFG_DMA512)
#define ioConfig_IOCFG_DMA512 1
#endif
#endif


#include <systemc.h>
#include "dummy.hpp"


// Declaration of wrapper with RTL level ports

SC_MODULE(dummy_type_wrapper)
{
public:

	
#if defined ( ioConfig_IOCFG_DMA64 )
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< sc_uint< 32 > > conf_info_tokens;
	sc_in< sc_uint< 32 > > conf_info_batch;
	sc_in< sc_uint< 32 > > conf_info_source;
	sc_in< sc_uint< 32 > > conf_info_ndests;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< sc_uint< 32 > > debug;
	sc_in< bool > dma_read_chnl_valid;
	sc_in< sc_biguint< 64 > > dma_read_chnl_data;
	sc_out< bool > dma_read_chnl_ready;
	sc_out< bool > dma_read_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_read_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_read_ctrl_data_user;
	sc_in< bool > dma_read_ctrl_ready;
	sc_out< bool > dma_write_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_write_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_write_ctrl_data_user;
	sc_in< bool > dma_write_ctrl_ready;
	sc_out< bool > dma_write_chnl_valid;
	sc_out< sc_biguint< 64 > > dma_write_chnl_data;
	sc_in< bool > dma_write_chnl_ready;
	
#elif defined ( ioConfig_IOCFG_DMA128)
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< sc_uint< 32 > > conf_info_tokens;
	sc_in< sc_uint< 32 > > conf_info_batch;
	sc_in< sc_uint< 32 > > conf_info_source;
	sc_in< sc_uint< 32 > > conf_info_ndests;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< sc_uint< 32 > > debug;
	sc_in< bool > dma_read_chnl_valid;
	sc_in< sc_biguint< 128 > > dma_read_chnl_data;
	sc_out< bool > dma_read_chnl_ready;
	sc_out< bool > dma_read_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_read_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_read_ctrl_data_user;
	sc_in< bool > dma_read_ctrl_ready;
	sc_out< bool > dma_write_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_write_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_write_ctrl_data_user;
	sc_in< bool > dma_write_ctrl_ready;
	sc_out< bool > dma_write_chnl_valid;
	sc_out< sc_biguint< 128 > > dma_write_chnl_data;
	sc_in< bool > dma_write_chnl_ready;
	
#elif defined ( ioConfig_IOCFG_DMA256)
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< sc_uint< 32 > > conf_info_tokens;
	sc_in< sc_uint< 32 > > conf_info_batch;
	sc_in< sc_uint< 32 > > conf_info_source;
	sc_in< sc_uint< 32 > > conf_info_ndests;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< sc_uint< 32 > > debug;
	sc_in< bool > dma_read_chnl_valid;
	sc_in< sc_biguint< 256 > > dma_read_chnl_data;
	sc_out< bool > dma_read_chnl_ready;
	sc_out< bool > dma_read_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_read_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_read_ctrl_data_user;
	sc_in< bool > dma_read_ctrl_ready;
	sc_out< bool > dma_write_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_write_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_write_ctrl_data_user;
	sc_in< bool > dma_write_ctrl_ready;
	sc_out< bool > dma_write_chnl_valid;
	sc_out< sc_biguint< 256 > > dma_write_chnl_data;
	sc_in< bool > dma_write_chnl_ready;
	
	
#else
	
	sc_in< bool > clk;
	sc_in< bool > rst;
	sc_in< sc_uint< 32 > > conf_info_tokens;
	sc_in< sc_uint< 32 > > conf_info_batch;
	sc_in< sc_uint< 32 > > conf_info_source;
	sc_in< sc_uint< 32 > > conf_info_ndests;
	sc_in< bool > conf_done;
	sc_out< bool > acc_done;
	sc_out< sc_uint< 32 > > debug;
	sc_in< bool > dma_read_chnl_valid;
	sc_in< sc_biguint< 512 > > dma_read_chnl_data;
	sc_out< bool > dma_read_chnl_ready;
	sc_out< bool > dma_read_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_read_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_read_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_read_ctrl_data_user;
	sc_in< bool > dma_read_ctrl_ready;
	sc_out< bool > dma_write_ctrl_valid;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_index;
	sc_out< sc_uint< 32 > > dma_write_ctrl_data_length;
	sc_out< sc_biguint< 3 > > dma_write_ctrl_data_size;
	sc_out< sc_biguint< 5 > > dma_write_ctrl_data_user;
	sc_in< bool > dma_write_ctrl_ready;
	sc_out< bool > dma_write_chnl_valid;
	sc_out< sc_biguint< 512 > > dma_write_chnl_data;
	sc_in< bool > dma_write_chnl_ready;
	
#endif

    
    // These signals are used to connect structured ports or ports that need
    // type conversion to the RTL ports.
    
#if defined ( ioConfig_IOCFG_DMA64 )
    
    sc_signal< sc_bv< 64 > > dma_read_chnl_data_conv;
    sc_signal< conf_info_t > conf_info;
    sc_signal< unsigned int > debug_conv;
    sc_signal< dma_info_t > dma_read_ctrl_data;
    sc_signal< dma_info_t > dma_write_ctrl_data;
    sc_signal< sc_bv< 64 > > dma_write_chnl_data_conv;
    
#elif defined ( ioConfig_IOCFG_DMA128)
    
    sc_signal< sc_bv< 128 > > dma_read_chnl_data_conv;
    sc_signal< conf_info_t > conf_info;
    sc_signal< unsigned int > debug_conv;
    sc_signal< dma_info_t > dma_read_ctrl_data;
    sc_signal< dma_info_t > dma_write_ctrl_data;
    sc_signal< sc_bv< 128 > > dma_write_chnl_data_conv;
    
#elif defined ( ioConfig_IOCFG_DMA256)
    
    sc_signal< sc_bv< 256 > > dma_read_chnl_data_conv;
    sc_signal< conf_info_t > conf_info;
    sc_signal< unsigned int > debug_conv;
    sc_signal< dma_info_t > dma_read_ctrl_data;
    sc_signal< dma_info_t > dma_write_ctrl_data;
    sc_signal< sc_bv< 256 > > dma_write_chnl_data_conv;
    
    
#else
    
    sc_signal< sc_bv< 512 > > dma_read_chnl_data_conv;
    sc_signal< conf_info_t > conf_info;
    sc_signal< unsigned int > debug_conv;
    sc_signal< dma_info_t > dma_read_ctrl_data;
    sc_signal< dma_info_t > dma_write_ctrl_data;
    sc_signal< sc_bv< 512 > > dma_write_chnl_data_conv;
    
#endif

    

	// create the netlist
    void InitInstances();
    void InitThreads();

    // delete the netlist
    void DeleteInstances();

    // The following threads are used to connect structured ports to the actual
    // RTL ports.
    
#if defined ( ioConfig_IOCFG_DMA64 )
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data_index();
    void thread_dma_read_ctrl_data_length();
    void thread_dma_read_ctrl_data_size();
    void thread_dma_read_ctrl_data_user();
    void thread_dma_write_ctrl_data_index();
    void thread_dma_write_ctrl_data_length();
    void thread_dma_write_ctrl_data_size();
    void thread_dma_write_ctrl_data_user();
    void thread_dma_write_chnl_data_conv();
    
#elif defined ( ioConfig_IOCFG_DMA128)
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data_index();
    void thread_dma_read_ctrl_data_length();
    void thread_dma_read_ctrl_data_size();
    void thread_dma_read_ctrl_data_user();
    void thread_dma_write_ctrl_data_index();
    void thread_dma_write_ctrl_data_length();
    void thread_dma_write_ctrl_data_size();
    void thread_dma_write_ctrl_data_user();
    void thread_dma_write_chnl_data_conv();
    
#elif defined ( ioConfig_IOCFG_DMA256)
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data_index();
    void thread_dma_read_ctrl_data_length();
    void thread_dma_read_ctrl_data_size();
    void thread_dma_read_ctrl_data_user();
    void thread_dma_write_ctrl_data_index();
    void thread_dma_write_ctrl_data_length();
    void thread_dma_write_ctrl_data_size();
    void thread_dma_write_ctrl_data_user();
    void thread_dma_write_chnl_data_conv();
    
    
#else
    
    void thread_dma_read_chnl_data_conv();
    void thread_conf_info();
    void thread_debug_conv();
    void thread_dma_read_ctrl_data_index();
    void thread_dma_read_ctrl_data_length();
    void thread_dma_read_ctrl_data_size();
    void thread_dma_read_ctrl_data_user();
    void thread_dma_write_ctrl_data_index();
    void thread_dma_write_ctrl_data_length();
    void thread_dma_write_ctrl_data_size();
    void thread_dma_write_ctrl_data_user();
    void thread_dma_write_chnl_data_conv();
    
#endif


	SC_HAS_PROCESS(dummy_type_wrapper);

	dummy_type_wrapper( sc_module_name name = sc_module_name( sc_gen_unique_name("dummy")) )
		: sc_module(name)
		  
#if defined ( ioConfig_IOCFG_DMA64 )
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info_tokens("conf_info_tokens"),
		  conf_info_batch("conf_info_batch"),
		  conf_info_source("conf_info_source"),
		  conf_info_ndests("conf_info_ndests")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl_valid("dma_read_chnl_valid")
		  	,dma_read_chnl_data("dma_read_chnl_data")
		  	,dma_read_chnl_ready("dma_read_chnl_ready")
		  	,dma_read_ctrl_valid("dma_read_ctrl_valid")
		  	,dma_read_ctrl_data_index("dma_read_ctrl_data_index"),
		  dma_read_ctrl_data_length("dma_read_ctrl_data_length"),
		  dma_read_ctrl_data_size("dma_read_ctrl_data_size"),
		  dma_read_ctrl_data_user("dma_read_ctrl_data_user")
		  	,dma_read_ctrl_ready("dma_read_ctrl_ready")
		  	,dma_write_ctrl_valid("dma_write_ctrl_valid")
		  	,dma_write_ctrl_data_index("dma_write_ctrl_data_index"),
		  dma_write_ctrl_data_length("dma_write_ctrl_data_length"),
		  dma_write_ctrl_data_size("dma_write_ctrl_data_size"),
		  dma_write_ctrl_data_user("dma_write_ctrl_data_user")
		  	,dma_write_ctrl_ready("dma_write_ctrl_ready")
		  	,dma_write_chnl_valid("dma_write_chnl_valid")
		  	,dma_write_chnl_data("dma_write_chnl_data")
		  	,dma_write_chnl_ready("dma_write_chnl_ready")
		  	
#elif defined ( ioConfig_IOCFG_DMA128)
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info_tokens("conf_info_tokens"),
		  conf_info_batch("conf_info_batch"),
		  conf_info_source("conf_info_source"),
		  conf_info_ndests("conf_info_ndests")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl_valid("dma_read_chnl_valid")
		  	,dma_read_chnl_data("dma_read_chnl_data")
		  	,dma_read_chnl_ready("dma_read_chnl_ready")
		  	,dma_read_ctrl_valid("dma_read_ctrl_valid")
		  	,dma_read_ctrl_data_index("dma_read_ctrl_data_index"),
		  dma_read_ctrl_data_length("dma_read_ctrl_data_length"),
		  dma_read_ctrl_data_size("dma_read_ctrl_data_size"),
		  dma_read_ctrl_data_user("dma_read_ctrl_data_user")
		  	,dma_read_ctrl_ready("dma_read_ctrl_ready")
		  	,dma_write_ctrl_valid("dma_write_ctrl_valid")
		  	,dma_write_ctrl_data_index("dma_write_ctrl_data_index"),
		  dma_write_ctrl_data_length("dma_write_ctrl_data_length"),
		  dma_write_ctrl_data_size("dma_write_ctrl_data_size"),
		  dma_write_ctrl_data_user("dma_write_ctrl_data_user")
		  	,dma_write_ctrl_ready("dma_write_ctrl_ready")
		  	,dma_write_chnl_valid("dma_write_chnl_valid")
		  	,dma_write_chnl_data("dma_write_chnl_data")
		  	,dma_write_chnl_ready("dma_write_chnl_ready")
		  	
#elif defined ( ioConfig_IOCFG_DMA256)
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info_tokens("conf_info_tokens"),
		  conf_info_batch("conf_info_batch"),
		  conf_info_source("conf_info_source"),
		  conf_info_ndests("conf_info_ndests")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl_valid("dma_read_chnl_valid")
		  	,dma_read_chnl_data("dma_read_chnl_data")
		  	,dma_read_chnl_ready("dma_read_chnl_ready")
		  	,dma_read_ctrl_valid("dma_read_ctrl_valid")
		  	,dma_read_ctrl_data_index("dma_read_ctrl_data_index"),
		  dma_read_ctrl_data_length("dma_read_ctrl_data_length"),
		  dma_read_ctrl_data_size("dma_read_ctrl_data_size"),
		  dma_read_ctrl_data_user("dma_read_ctrl_data_user")
		  	,dma_read_ctrl_ready("dma_read_ctrl_ready")
		  	,dma_write_ctrl_valid("dma_write_ctrl_valid")
		  	,dma_write_ctrl_data_index("dma_write_ctrl_data_index"),
		  dma_write_ctrl_data_length("dma_write_ctrl_data_length"),
		  dma_write_ctrl_data_size("dma_write_ctrl_data_size"),
		  dma_write_ctrl_data_user("dma_write_ctrl_data_user")
		  	,dma_write_ctrl_ready("dma_write_ctrl_ready")
		  	,dma_write_chnl_valid("dma_write_chnl_valid")
		  	,dma_write_chnl_data("dma_write_chnl_data")
		  	,dma_write_chnl_ready("dma_write_chnl_ready")
		  	
		  
#else
		  
		  ,clk("clk")
		  	,rst("rst")
		  	,conf_info_tokens("conf_info_tokens"),
		  conf_info_batch("conf_info_batch"),
		  conf_info_source("conf_info_source"),
		  conf_info_ndests("conf_info_ndests")
		  	,conf_done("conf_done")
		  	,acc_done("acc_done")
		  	,debug("debug")
		  	,dma_read_chnl_valid("dma_read_chnl_valid")
		  	,dma_read_chnl_data("dma_read_chnl_data")
		  	,dma_read_chnl_ready("dma_read_chnl_ready")
		  	,dma_read_ctrl_valid("dma_read_ctrl_valid")
		  	,dma_read_ctrl_data_index("dma_read_ctrl_data_index"),
		  dma_read_ctrl_data_length("dma_read_ctrl_data_length"),
		  dma_read_ctrl_data_size("dma_read_ctrl_data_size"),
		  dma_read_ctrl_data_user("dma_read_ctrl_data_user")
		  	,dma_read_ctrl_ready("dma_read_ctrl_ready")
		  	,dma_write_ctrl_valid("dma_write_ctrl_valid")
		  	,dma_write_ctrl_data_index("dma_write_ctrl_data_index"),
		  dma_write_ctrl_data_length("dma_write_ctrl_data_length"),
		  dma_write_ctrl_data_size("dma_write_ctrl_data_size"),
		  dma_write_ctrl_data_user("dma_write_ctrl_data_user")
		  	,dma_write_ctrl_ready("dma_write_ctrl_ready")
		  	,dma_write_chnl_valid("dma_write_chnl_valid")
		  	,dma_write_chnl_data("dma_write_chnl_data")
		  	,dma_write_chnl_ready("dma_write_chnl_ready")
		  	
#endif
		  

		  ,dummy0(0)
		

    {
        InitInstances();
        InitThreads();
		end_module();
    }


    // destructor
    ~dummy_type_wrapper()
    {
        DeleteInstances();
    }


protected:
	dummy* dummy0;
};

#endif /*  */
