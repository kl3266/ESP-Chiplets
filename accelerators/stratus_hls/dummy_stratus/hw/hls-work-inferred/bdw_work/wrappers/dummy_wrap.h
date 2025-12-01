/****************************************************************************
*
*  Copyright (c) 2015, Cadence Design Systems. All Rights Reserved.
*
*  This file contains confidential information that may not be
*  distributed under any circumstances without the written permision
*  of Cadence Design Systems.
*
****************************************************************************/


#ifndef _DUMMY_WRAP_INCLUDED_
#define _DUMMY_WRAP_INCLUDED_

#ifndef BDW_NO_SUBMOD_WRAPPERS

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


/* Save ioConfig define values for parent module and define those for this module's ioConfigs. */
#if defined(ioConfig_IOCFG_DMA64)
#if defined(ioConfig) && defined(_wrap_ioConfig) && !defined(_local_ioConfig)
#undef ioConfig
#define ioConfig _local_ioConfig
#define _local_ioConfig IOCFG_DMA64
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && !defined(_local_DMA_WIDTH)
#undef DMA_WIDTH
#define DMA_WIDTH _local_DMA_WIDTH
#define _local_DMA_WIDTH 64
#endif
#endif
#if defined(ioConfig_IOCFG_DMA128)
#if defined(ioConfig) && defined(_wrap_ioConfig) && !defined(_local_ioConfig)
#undef ioConfig
#define ioConfig _local_ioConfig
#define _local_ioConfig IOCFG_DMA128
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && !defined(_local_DMA_WIDTH)
#undef DMA_WIDTH
#define DMA_WIDTH _local_DMA_WIDTH
#define _local_DMA_WIDTH 128
#endif
#endif
#if defined(ioConfig_IOCFG_DMA256)
#if defined(ioConfig) && defined(_wrap_ioConfig) && !defined(_local_ioConfig)
#undef ioConfig
#define ioConfig _local_ioConfig
#define _local_ioConfig IOCFG_DMA256
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && !defined(_local_DMA_WIDTH)
#undef DMA_WIDTH
#define DMA_WIDTH _local_DMA_WIDTH
#define _local_DMA_WIDTH 256
#endif
#endif
#if defined(ioConfig_IOCFG_DMA512)
#if defined(ioConfig) && defined(_wrap_ioConfig) && !defined(_local_ioConfig)
#undef ioConfig
#define ioConfig _local_ioConfig
#define _local_ioConfig IOCFG_DMA512
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && !defined(_local_DMA_WIDTH)
#undef DMA_WIDTH
#define DMA_WIDTH _local_DMA_WIDTH
#define _local_DMA_WIDTH 512
#endif
#endif


#if defined(STRATUS_VLG) 

#include <systemc.h>

#define dummy_wrapper dummy

/* This is the section that is seen during processing by stratus_vlg of a module
 * that instantiates the module defined by this wrapper.
 */
SC_MODULE(dummy)
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

	SC_CTOR(dummy);
};

#elif defined(CYNTHHL) || defined(BDW_EXTRACT)

/* This is the section seen during processing by stratus_hls or bdw_extract of a module 
 * that instantiates the module defined by this wrapper.
 */
#include <systemc.h>

#include "../src/dummy_conf_info.hpp"
#include "cynw_put_get_channels/cynw_put_get_port_base.h"
#include "/home/kevin/nov_submission/esp/accelerators/stratus_hls/common/inc/core/systems/esp_dma_info.hpp"


#define dummy_wrapper dummy

/* Only port declarations are required for nested modules.
 */
SC_MODULE(dummy)
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


	SC_HAS_PROCESS(dummy);
    	dummy_wrapper( sc_module_name name = sc_module_name( sc_gen_unique_name("dummy")) );
};

#else

#include <esc.h>


/* This is the section seen during processing by gcc either when the module
 * itself is compiled, or when a module that instantiates it is compiled.
 */

struct dummy;
struct dummy_cosim;
struct dummy_rtl;

#include "../src/dummy_conf_info.hpp"
#include "cynw_put_get_channels/cynw_put_get_port_base.h"
#include "/home/kevin/nov_submission/esp/accelerators/stratus_hls/common/inc/core/systems/esp_dma_info.hpp"


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

    
	enum Representation { BDWRep_None, BDWRep_Behavioral, BDWRep_RTL_C, BDWRep_RTL_HDL, BDWRep_Gates, BDWRep_CYC_HDL };
	static const char * simConfigName();
	static Representation lookupRepresentation( const char* instName );
	// create the netlist
    void InitInstances( );
    void InitThreads();

    // delete the netlist
    void DeleteInstances();

	void CloseTrace();
	void start_of_simulation();
	void end_of_simulation();


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
		  

          		  ,dummy0(0), dummy_cosim0(0), dummy_rtl0(0)
		

    {
        InitInstances( );
		InitThreads();
    }


    // destructor
    ~dummy_wrapper()
    {
        DeleteInstances();

		CloseTrace();
    }

    bool isBEH() { return ( dummy_wrapper::lookupRepresentation( name() ) == BDWRep_Behavioral ); }
    bool isRTL_C() { return ( dummy_wrapper::lookupRepresentation( name() ) == BDWRep_RTL_C ); }
    bool isRTL_V() { return ( dummy_wrapper::lookupRepresentation( name() ) == BDWRep_RTL_HDL ); }
    bool isGATES_V() { return ( dummy_wrapper::lookupRepresentation( name() ) == BDWRep_Gates ); }
	bool isCosim() { return ( isRTL_V() || isGATES_V() ); }
    
        
#ifdef dummy_INTERNAL
	dummy* behModule() { return dummy0; }
#else
	dummy* behModule() { return dummy0; }
#endif
	dummy_cosim* cosimModule() { return dummy_cosim0; }
    	dummy_rtl* rtlModule() { return dummy_rtl0; }

#ifdef dummy_INTERNAL
	dummy* dummy0;
#else
	dummy* dummy0;
#endif
	dummy_cosim* dummy_cosim0;
	dummy_rtl* dummy_rtl0;
	};

// Declaration of wrapper with RTL level ports

SC_MODULE(dummy_wrapper_r)
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

    
	enum Representation { BDWRep_None, BDWRep_Behavioral, BDWRep_RTL_C, BDWRep_RTL_HDL, BDWRep_Gates, BDWRep_CYC_HDL };

	static const char * simConfigName();
	static Representation lookupRepresentation( const char* instName );
	// create the netlist
    void InitInstances();
    void InitThreads();

    // delete the netlist
    void DeleteInstances();

	void CloseTrace();
	void start_of_simulation();
	void end_of_simulation();


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


	SC_HAS_PROCESS(dummy_wrapper_r);

	dummy_wrapper_r( sc_module_name name = sc_module_name( sc_gen_unique_name("dummy")) )
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
		  

          		  ,dummy0(0), dummy_cosim0(0), dummy_rtl0(0)
		

    {
        InitInstances();
        InitThreads();
		end_module();
    }


    // destructor
    ~dummy_wrapper_r()
    {
        DeleteInstances();

		CloseTrace();
    }

    bool isBEH() { return ( dummy_wrapper_r::lookupRepresentation( name() ) == BDWRep_Behavioral ); }
    bool isRTL_C() { return ( dummy_wrapper_r::lookupRepresentation( name() ) == BDWRep_RTL_C ); }
    bool isRTL_V() { return ( dummy_wrapper_r::lookupRepresentation( name() ) == BDWRep_RTL_HDL ); }
    bool isGATES_V() { return ( dummy_wrapper_r::lookupRepresentation( name() ) == BDWRep_Gates ); }
	bool isCosim() { return ( isRTL_V() || isGATES_V() ); }
	
#ifdef dummy_INTERNAL
	dummy* behModule() { return dummy0; }
#else
	dummy* behModule() { return dummy0; }
#endif
	dummy_cosim* cosimModule() { return dummy_cosim0; }
		dummy_rtl* rtlModule() { return dummy_rtl0; }

protected:
#ifdef dummy_INTERNAL
	dummy* dummy0;
#else
	dummy* dummy0;
#endif
	dummy_cosim* dummy_cosim0;
	dummy_rtl* dummy_rtl0;
	};

#endif

/* Restore ioConfig define values for parent module. */
#if defined(ioConfig_IOCFG_DMA64)
#if defined(ioConfig) && defined(_wrap_ioConfig) && defined(_local_ioConfig)
#undef _local_ioConfig
#undef ioConfig
#define ioConfig _wrap_ioConfig
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && defined(_local_DMA_WIDTH)
#undef _local_DMA_WIDTH
#undef DMA_WIDTH
#define DMA_WIDTH _wrap_DMA_WIDTH
#endif
#endif
#if defined(ioConfig_IOCFG_DMA128)
#if defined(ioConfig) && defined(_wrap_ioConfig) && defined(_local_ioConfig)
#undef _local_ioConfig
#undef ioConfig
#define ioConfig _wrap_ioConfig
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && defined(_local_DMA_WIDTH)
#undef _local_DMA_WIDTH
#undef DMA_WIDTH
#define DMA_WIDTH _wrap_DMA_WIDTH
#endif
#endif
#if defined(ioConfig_IOCFG_DMA256)
#if defined(ioConfig) && defined(_wrap_ioConfig) && defined(_local_ioConfig)
#undef _local_ioConfig
#undef ioConfig
#define ioConfig _wrap_ioConfig
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && defined(_local_DMA_WIDTH)
#undef _local_DMA_WIDTH
#undef DMA_WIDTH
#define DMA_WIDTH _wrap_DMA_WIDTH
#endif
#endif
#if defined(ioConfig_IOCFG_DMA512)
#if defined(ioConfig) && defined(_wrap_ioConfig) && defined(_local_ioConfig)
#undef _local_ioConfig
#undef ioConfig
#define ioConfig _wrap_ioConfig
#endif
#if defined(DMA_WIDTH) && defined(_wrap_DMA_WIDTH) && defined(_local_DMA_WIDTH)
#undef _local_DMA_WIDTH
#undef DMA_WIDTH
#define DMA_WIDTH _wrap_DMA_WIDTH
#endif
#endif


#else /* BDW_NO_SUBMOD_WRAPPERS */

#define dummy_wrapper dummy
#include "dummy.h"

#endif /* BDW_NO_SUBMOD_WRAPPERS */

#endif /*  */
