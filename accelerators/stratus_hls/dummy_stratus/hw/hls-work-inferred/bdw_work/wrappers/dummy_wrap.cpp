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
* This file is used to wrap the three different versions of the DUT
* block called "dummy". By default, it will include the behavioral
* model. Otherwise, it will include the RTL C++ or the RTL Verilog
* depending on the definition of either of "RTL" or "COSIM".
*
****************************************************************************/

#if defined(STRATUS_VLG)


#ifndef BDW_PORTS_ONLY
#define BDW_PORTS_ONLY 1
#endif


#include	"dummy_rtl.cpp"

#else 

#if defined(BDW_HUB)

#define SC_INCLUDE_DYNAMIC_PROCESSES 1
#include "esc.h"

#if defined(BDW_RTL)

#define BDW_AUTO_KNOWN 1 


#ifndef BDW_PORTS_ONLY
#define BDW_PORTS_ONLY 1
#endif


#undef dummy
#define dummy dummy_rtl
#	include	"dummy_rtl.cpp"
#undef dummy


#ifdef BDW_PORTS_ONLY
#undef BDW_PORTS_ONLY
#endif



#elif defined(BDW_HOIST) 
#else

#endif

#include	"dummy_cosim.h"




// Include the source for the behavioral model so it will be compiled.
#include	"/home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/src/dummy.cpp"


#define		dummy_INTERNAL


#include	"dummy_wrap.h"


#define MAX_SIMCONFIG_LENGTH 128

#if BDW_WRITEFSDB == 1

#if (defined(XM_SYSTEMC) || defined(NC_SYSTEMC)) && defined(BDW_NCSC_VER) && BDW_NCSC_VER > 102
#include "fsdb_nc_mix.h"
#else
#if SYSTEMC_VERSION >= 20120701
#include "fsdb_osci.h"
#else
#include "fsdb_trace_file.h"
#endif
#endif 
#if BDW_USE_SCV
#include "scv.h"
#include "scv_tr_fsdb.h"
#endif

#endif /* BDW_WRITEFSDB */

inline void esc_open_fsdb_trace( const char *file_name = "systemc" );
inline void esc_close_fsdb_trace();
inline void esc_close_fsdb_scv_trace();

// The following threads are used to connect structured ports to the actual
// RTL ports

#if defined ( ioConfig_IOCFG_DMA64 )

void dummy_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl.data.read();
}
void dummy_wrapper::thread_conf_info_tokens()
{
   conf_info_tokens = conf_info.read().tokens;
}
void dummy_wrapper::thread_conf_info_batch()
{
   conf_info_batch = conf_info.read().batch;
}
void dummy_wrapper::thread_conf_info_source()
{
   conf_info_source = conf_info.read().source;
}
void dummy_wrapper::thread_conf_info_ndests()
{
   conf_info_ndests = conf_info.read().ndests;
}
void dummy_wrapper::thread_debug_conv()
{
   unsigned int tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper::thread_dma_read_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_read_ctrl_data_index.read();
   tmp.length = dma_read_ctrl_data_length.read();
   tmp.size = dma_read_ctrl_data_size.read();
   tmp.user = dma_read_ctrl_data_user.read();
   dma_read_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_write_ctrl_data_index.read();
   tmp.length = dma_write_ctrl_data_length.read();
   tmp.size = dma_write_ctrl_data_size.read();
   tmp.user = dma_write_ctrl_data_user.read();
   dma_write_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_bv< 64 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl.data.write(tmp);
}

#elif defined ( ioConfig_IOCFG_DMA128)

void dummy_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl.data.read();
}
void dummy_wrapper::thread_conf_info_tokens()
{
   conf_info_tokens = conf_info.read().tokens;
}
void dummy_wrapper::thread_conf_info_batch()
{
   conf_info_batch = conf_info.read().batch;
}
void dummy_wrapper::thread_conf_info_source()
{
   conf_info_source = conf_info.read().source;
}
void dummy_wrapper::thread_conf_info_ndests()
{
   conf_info_ndests = conf_info.read().ndests;
}
void dummy_wrapper::thread_debug_conv()
{
   unsigned int tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper::thread_dma_read_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_read_ctrl_data_index.read();
   tmp.length = dma_read_ctrl_data_length.read();
   tmp.size = dma_read_ctrl_data_size.read();
   tmp.user = dma_read_ctrl_data_user.read();
   dma_read_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_write_ctrl_data_index.read();
   tmp.length = dma_write_ctrl_data_length.read();
   tmp.size = dma_write_ctrl_data_size.read();
   tmp.user = dma_write_ctrl_data_user.read();
   dma_write_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_bv< 128 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl.data.write(tmp);
}

#elif defined ( ioConfig_IOCFG_DMA256)

void dummy_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl.data.read();
}
void dummy_wrapper::thread_conf_info_tokens()
{
   conf_info_tokens = conf_info.read().tokens;
}
void dummy_wrapper::thread_conf_info_batch()
{
   conf_info_batch = conf_info.read().batch;
}
void dummy_wrapper::thread_conf_info_source()
{
   conf_info_source = conf_info.read().source;
}
void dummy_wrapper::thread_conf_info_ndests()
{
   conf_info_ndests = conf_info.read().ndests;
}
void dummy_wrapper::thread_debug_conv()
{
   unsigned int tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper::thread_dma_read_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_read_ctrl_data_index.read();
   tmp.length = dma_read_ctrl_data_length.read();
   tmp.size = dma_read_ctrl_data_size.read();
   tmp.user = dma_read_ctrl_data_user.read();
   dma_read_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_write_ctrl_data_index.read();
   tmp.length = dma_write_ctrl_data_length.read();
   tmp.size = dma_write_ctrl_data_size.read();
   tmp.user = dma_write_ctrl_data_user.read();
   dma_write_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_bv< 256 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl.data.write(tmp);
}


#else

void dummy_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl.data.read();
}
void dummy_wrapper::thread_conf_info_tokens()
{
   conf_info_tokens = conf_info.read().tokens;
}
void dummy_wrapper::thread_conf_info_batch()
{
   conf_info_batch = conf_info.read().batch;
}
void dummy_wrapper::thread_conf_info_source()
{
   conf_info_source = conf_info.read().source;
}
void dummy_wrapper::thread_conf_info_ndests()
{
   conf_info_ndests = conf_info.read().ndests;
}
void dummy_wrapper::thread_debug_conv()
{
   unsigned int tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper::thread_dma_read_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_read_ctrl_data_index.read();
   tmp.length = dma_read_ctrl_data_length.read();
   tmp.size = dma_read_ctrl_data_size.read();
   tmp.user = dma_read_ctrl_data_user.read();
   dma_read_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_ctrl_data()
{
   dma_info_t tmp;
   tmp.index = dma_write_ctrl_data_index.read();
   tmp.length = dma_write_ctrl_data_length.read();
   tmp.size = dma_write_ctrl_data_size.read();
   tmp.user = dma_write_ctrl_data_user.read();
   dma_write_ctrl.data.write(tmp);
}
void dummy_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_bv< 512 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl.data.write(tmp);
}

#endif


const char * dummy_wrapper::simConfigName()
{
	static char defineBuf[MAX_SIMCONFIG_LENGTH];
	const char *simConfig = NULL;
	if ( qbhGetDefine( "BDW_SIM_CONFIG", defineBuf, MAX_SIMCONFIG_LENGTH ) == qbhOK )
	{
		simConfig = defineBuf;
	}
	else
	{
		simConfig = getenv( "BDW_SIM_CONFIG" );
	}

	if ( simConfig == NULL )
	{
		esc_report_error( esc_fatal, "BDW_SIM_CONFIG needs to be set" );
	}

	return simConfig;
}

enum dummy_wrapper::Representation dummy_wrapper::lookupRepresentation( const char* instName )
{
	const char *simConfig = simConfigName();

	if ( simConfig == NULL )
		return BDWRep_None;

	Representation result;

	qbhProjectHandle hProj;
	qbhError err = qbhGetCurrentProject( &hProj );
	if ( err == qbhErrorNoProject )
	{
		err = qbhOpenProject( "project.tcl", &hProj );

		if ( err != qbhOK )
		{
			esc_report_error( esc_fatal, "could not open project file %s",
							  "project.tcl" );
			return BDWRep_None;
		}
	}

	int iresult = 0;
	err = qbhGetRepresentation(hProj, "dummy", simConfig, instName, &iresult );
	result = (Representation)iresult;

	if ( err == qbhOK )
		return result;

	// If this module isn't mentioned in the simConfig, assume it's behavioral.
	if ( err == qbhErrorNotFound ) {
		return BDWRep_Behavioral;
	} else if ( err == qbhErrorBadInstName ) {
		if (instName && *instName) {
			const char* leaf = strrchr( instName, '.' ) + 1;
			esc_report_error( esc_warning, "Instance names were specified for module '%s' in simConfig '%s', but they did not "
			                    "match the actal instance names in the RTL.  Try '%s' or '%s'. Simulating '%s' as BEH.\n",
								 "dummy", simConfig, instName, leaf,  "dummy" );
		}
		return BDWRep_Behavioral;
	}

    // If we couldn't get a license, then just exit.
    if ( err == qbhErrorNoLicense )
    {
        exit(1);
    }

	return BDWRep_None;
}

void dummy_wrapper::InitInstances(  )
{
    enum dummy_wrapper::Representation rep =
		dummy_wrapper::lookupRepresentation( name() );

	esc_log_wrapper_inst( "dummy" );
	esc_log_representation( "dummy", name(), rep );

	
#if defined ( ioConfig_IOCFG_DMA64 )
	
	
#elif defined ( ioConfig_IOCFG_DMA128)
	
	
#elif defined ( ioConfig_IOCFG_DMA256)
	
	
	
#else
	
	
#endif


	switch ( rep )
	{
		case BDWRep_Gates:
		    dummy_cosim0 = new dummy_cosim( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
		    
#else
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#endif

			break;
		case BDWRep_RTL_HDL:
		    dummy_cosim0 = new dummy_cosim( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
		    
#else
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug_conv);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#endif

			break;
#if defined(BDW_RTL)
		case BDWRep_RTL_C:
		    dummy_rtl0 = new dummy_rtl( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug_conv);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug_conv);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug_conv);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
		    
#else
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl.valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data_conv);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl.ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug_conv);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl.valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl.ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl.valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl.ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl.valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data_conv);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl.ready);
		    
#endif


			{
			const char *simConfig = dummy_wrapper::simConfigName();
			
			if ( simConfig != NULL )
				{
				qbhProjectHandle hProj;
				qbhError err = qbhGetCurrentProject( &hProj );
				if ( err == qbhErrorNoProject )
				{
					err = qbhOpenProject( "project.tcl", &hProj );
			
					if ( err != qbhOK )
					{
						esc_report_error( esc_fatal, "could not open project file %s",
						                                          "project.tcl" );
							return;
					}
				}
			
				if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
					esc_get_vcd_trace_file();
				}
				if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
					esc_get_fsdb_trace_file();
				}
				}
			}

			break;
#endif
		case BDWRep_Behavioral:
		    dummy0 = new dummy( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl.data);
		    dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl.data);
		    dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl.data);
		    dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl.data);
		    dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl.data);
		    dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl.data);
		    dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
		    
		    
#else
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl.data);
		    dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl.data);
		    dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
		    
#endif


			{
			const char *simConfig = dummy_wrapper::simConfigName();
			
			if ( simConfig != NULL )
				{
				qbhProjectHandle hProj;
				qbhError err = qbhGetCurrentProject( &hProj );
				if ( err == qbhErrorNoProject )
				{
					err = qbhOpenProject( "project.tcl", &hProj );
			
					if ( err != qbhOK )
					{
						esc_report_error( esc_fatal, "could not open project file %s",
						                                          "project.tcl" );
							return;
					}
				}
			
				if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
					esc_get_vcd_trace_file();
				}
				if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
					esc_get_fsdb_trace_file();
				}
				}
			}

			break;
		case BDWRep_None:
		default:
			esc_report_error( esc_error, "No representation could be determined for simulating instance %s. Please make sure that you used the right name string in the module constructor",
							  name() );
			break;
	}
}

void dummy_wrapper::InitThreads()
{
	if ( !isBEH() )
	{
		
#if defined ( ioConfig_IOCFG_DMA64 )
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl.data;
		SC_METHOD(thread_conf_info_tokens);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_batch);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_source);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_ndests);
		  sensitive << conf_info;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data);
		  sensitive << dma_read_ctrl_data_index;
		  sensitive << dma_read_ctrl_data_length;
		  sensitive << dma_read_ctrl_data_size;
		  sensitive << dma_read_ctrl_data_user;
		SC_METHOD(thread_dma_write_ctrl_data);
		  sensitive << dma_write_ctrl_data_index;
		  sensitive << dma_write_ctrl_data_length;
		  sensitive << dma_write_ctrl_data_size;
		  sensitive << dma_write_ctrl_data_user;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
#elif defined ( ioConfig_IOCFG_DMA128)
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl.data;
		SC_METHOD(thread_conf_info_tokens);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_batch);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_source);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_ndests);
		  sensitive << conf_info;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data);
		  sensitive << dma_read_ctrl_data_index;
		  sensitive << dma_read_ctrl_data_length;
		  sensitive << dma_read_ctrl_data_size;
		  sensitive << dma_read_ctrl_data_user;
		SC_METHOD(thread_dma_write_ctrl_data);
		  sensitive << dma_write_ctrl_data_index;
		  sensitive << dma_write_ctrl_data_length;
		  sensitive << dma_write_ctrl_data_size;
		  sensitive << dma_write_ctrl_data_user;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
#elif defined ( ioConfig_IOCFG_DMA256)
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl.data;
		SC_METHOD(thread_conf_info_tokens);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_batch);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_source);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_ndests);
		  sensitive << conf_info;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data);
		  sensitive << dma_read_ctrl_data_index;
		  sensitive << dma_read_ctrl_data_length;
		  sensitive << dma_read_ctrl_data_size;
		  sensitive << dma_read_ctrl_data_user;
		SC_METHOD(thread_dma_write_ctrl_data);
		  sensitive << dma_write_ctrl_data_index;
		  sensitive << dma_write_ctrl_data_length;
		  sensitive << dma_write_ctrl_data_size;
		  sensitive << dma_write_ctrl_data_user;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
		
#else
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl.data;
		SC_METHOD(thread_conf_info_tokens);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_batch);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_source);
		  sensitive << conf_info;
		SC_METHOD(thread_conf_info_ndests);
		  sensitive << conf_info;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data);
		  sensitive << dma_read_ctrl_data_index;
		  sensitive << dma_read_ctrl_data_length;
		  sensitive << dma_read_ctrl_data_size;
		  sensitive << dma_read_ctrl_data_user;
		SC_METHOD(thread_dma_write_ctrl_data);
		  sensitive << dma_write_ctrl_data_index;
		  sensitive << dma_write_ctrl_data_length;
		  sensitive << dma_write_ctrl_data_size;
		  sensitive << dma_write_ctrl_data_user;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
#endif

	}
}

void dummy_wrapper::start_of_simulation()
{

#include <dummy_trace.h>

        esc_multiple_writers_warning();
}

void dummy_wrapper::CloseTrace()
{
	if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
	esc_close_vcd_trace();
	}
	if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
		esc_close_fsdb_trace();
		if ( esc_trace_is_enabled( esc_trace_scv ) ) {
			esc_close_fsdb_scv_trace();
		}
	}
}

void dummy_wrapper::end_of_simulation()
{
      CloseTrace();
}



void dummy_wrapper::DeleteInstances()
{
    if (dummy0)
    {
        delete dummy0;
        dummy0 = 0;
    }
    if (dummy_cosim0)
    {
        delete dummy_cosim0;
        dummy_cosim0 = 0;
    }
  #if defined(BDW_RTL)
    if (dummy_rtl0)
    {
        delete dummy_rtl0;
        dummy_rtl0 = 0;
    }
#endif
}

// The following threads are used to connect RTL ports to the actual
// structured ports

#if defined ( ioConfig_IOCFG_DMA64 )

void dummy_wrapper_r::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_wrapper_r::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_wrapper_r::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 64 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}

#elif defined ( ioConfig_IOCFG_DMA128)

void dummy_wrapper_r::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_wrapper_r::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_wrapper_r::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 128 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}

#elif defined ( ioConfig_IOCFG_DMA256)

void dummy_wrapper_r::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_wrapper_r::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_wrapper_r::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 256 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}


#else

void dummy_wrapper_r::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_wrapper_r::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_wrapper_r::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_wrapper_r::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_wrapper_r::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 512 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}

#endif


const char * dummy_wrapper_r::simConfigName()
{
	static char defineBuf[MAX_SIMCONFIG_LENGTH];
	const char *simConfig = NULL;
	if ( qbhGetDefine( "BDW_SIM_CONFIG", defineBuf, MAX_SIMCONFIG_LENGTH ) == qbhOK )
	{
		simConfig = defineBuf;
	}
	else
	{
		simConfig = getenv( "BDW_SIM_CONFIG" );
	}

	if ( simConfig == NULL )
	{
		esc_report_error( esc_fatal, "BDW_SIM_CONFIG needs to be set" );
	}

	return simConfig;
}

enum dummy_wrapper_r::Representation dummy_wrapper_r::lookupRepresentation( const char* instName )
{
	const char *simConfig = simConfigName();

	if ( simConfig == NULL )
		return BDWRep_None;

	Representation result;

	qbhProjectHandle hProj;
	qbhError err = qbhGetCurrentProject( &hProj );
	if ( err == qbhErrorNoProject )
	{
		err = qbhOpenProject( "project.tcl", &hProj );

		if ( err != qbhOK )
		{
			esc_report_error( esc_fatal, "could not open project file %s",
							  "project.tcl" );
			return BDWRep_None;
		}
	}

	int iresult = 0;
	err = qbhGetRepresentation(hProj, "dummy", simConfig, instName, &iresult );
	result = (Representation)iresult;

	if ( err == qbhOK )
		return result;

	// If this module isn't mentioned in the simConfig, assume it's behavioral.
	if ( err == qbhErrorNotFound )
		return BDWRep_Behavioral;

    // If we couldn't get a license, then just exit.
    if ( err == qbhErrorNoLicense )
    {
        exit(1);
    }

	return BDWRep_None;
}

void dummy_wrapper_r::InitInstances()
{
    enum dummy_wrapper_r::Representation rep =
		dummy_wrapper_r::lookupRepresentation( name() );

	esc_log_wrapper_inst( "dummy" );
	esc_log_representation( "dummy", name(), rep );

	switch ( rep )
	{
		case BDWRep_Gates:
		    dummy_cosim0 = new dummy_cosim( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
		    
#else
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#endif

			break;
		case BDWRep_RTL_HDL:
		    dummy_cosim0 = new dummy_cosim( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
		    
#else
		    
		    dummy_cosim0->clk(clk);
		    dummy_cosim0->rst(rst);
		    dummy_cosim0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_cosim0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_cosim0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_cosim0->conf_info_tokens(conf_info_tokens);
		    dummy_cosim0->conf_info_batch(conf_info_batch);
		    dummy_cosim0->conf_info_source(conf_info_source);
		    dummy_cosim0->conf_info_ndests(conf_info_ndests);
		    dummy_cosim0->conf_done(conf_done);
		    dummy_cosim0->acc_done(acc_done);
		    dummy_cosim0->debug(debug);
		    dummy_cosim0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_cosim0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_cosim0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_cosim0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_cosim0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_cosim0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_cosim0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_cosim0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_cosim0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_cosim0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_cosim0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_cosim0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_cosim0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_cosim0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_cosim0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#endif

			break;
#if defined(BDW_RTL)
		case BDWRep_RTL_C:
		    dummy_rtl0 = new dummy_rtl( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
		    
#else
		    
		    dummy_rtl0->clk(clk);
		    dummy_rtl0->rst(rst);
		    dummy_rtl0->dma_read_chnl_valid(dma_read_chnl_valid);
		    dummy_rtl0->dma_read_chnl_data(dma_read_chnl_data);
		    dummy_rtl0->dma_read_chnl_ready(dma_read_chnl_ready);
		    dummy_rtl0->conf_info_tokens(conf_info_tokens);
		    dummy_rtl0->conf_info_batch(conf_info_batch);
		    dummy_rtl0->conf_info_source(conf_info_source);
		    dummy_rtl0->conf_info_ndests(conf_info_ndests);
		    dummy_rtl0->conf_done(conf_done);
		    dummy_rtl0->acc_done(acc_done);
		    dummy_rtl0->debug(debug);
		    dummy_rtl0->dma_read_ctrl_valid(dma_read_ctrl_valid);
		    dummy_rtl0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
		    dummy_rtl0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
		    dummy_rtl0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
		    dummy_rtl0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
		    dummy_rtl0->dma_read_ctrl_ready(dma_read_ctrl_ready);
		    dummy_rtl0->dma_write_ctrl_valid(dma_write_ctrl_valid);
		    dummy_rtl0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
		    dummy_rtl0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
		    dummy_rtl0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
		    dummy_rtl0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
		    dummy_rtl0->dma_write_ctrl_ready(dma_write_ctrl_ready);
		    dummy_rtl0->dma_write_chnl_valid(dma_write_chnl_valid);
		    dummy_rtl0->dma_write_chnl_data(dma_write_chnl_data);
		    dummy_rtl0->dma_write_chnl_ready(dma_write_chnl_ready);
		    
#endif


			{
			const char *simConfig = dummy_wrapper::simConfigName();
			
			if ( simConfig != NULL )
				{
				qbhProjectHandle hProj;
				qbhError err = qbhGetCurrentProject( &hProj );
				if ( err == qbhErrorNoProject )
				{
					err = qbhOpenProject( "project.tcl", &hProj );
			
					if ( err != qbhOK )
					{
						esc_report_error( esc_fatal, "could not open project file %s",
						                                          "project.tcl" );
							return;
					}
				}
			
				if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
					esc_get_vcd_trace_file();
				}
				if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
					esc_get_fsdb_trace_file();
				}
				}
			}

			break;
#endif
		case BDWRep_Behavioral:
		    dummy0 = new dummy( "dummy" );

		    
#if defined ( ioConfig_IOCFG_DMA64 )
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl_valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl_data_conv);
		    dummy0->dma_read_chnl.ready(dma_read_chnl_ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug_conv);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl_valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl_data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl_ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl_valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl_data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl_ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl_valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl_data_conv);
		    dummy0->dma_write_chnl.ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA128)
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl_valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl_data_conv);
		    dummy0->dma_read_chnl.ready(dma_read_chnl_ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug_conv);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl_valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl_data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl_ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl_valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl_data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl_ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl_valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl_data_conv);
		    dummy0->dma_write_chnl.ready(dma_write_chnl_ready);
		    
#elif defined ( ioConfig_IOCFG_DMA256)
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl_valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl_data_conv);
		    dummy0->dma_read_chnl.ready(dma_read_chnl_ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug_conv);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl_valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl_data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl_ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl_valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl_data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl_ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl_valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl_data_conv);
		    dummy0->dma_write_chnl.ready(dma_write_chnl_ready);
		    
		    
#else
		    
		    dummy0->clk(clk);
		    dummy0->rst(rst);
		    dummy0->dma_read_chnl.valid(dma_read_chnl_valid);
		    dummy0->dma_read_chnl.data(dma_read_chnl_data_conv);
		    dummy0->dma_read_chnl.ready(dma_read_chnl_ready);
		    dummy0->conf_info(conf_info);
		    dummy0->conf_done(conf_done);
		    dummy0->acc_done(acc_done);
		    dummy0->debug(debug_conv);
		    dummy0->dma_read_ctrl.valid(dma_read_ctrl_valid);
		    dummy0->dma_read_ctrl.data(dma_read_ctrl_data);
		    dummy0->dma_read_ctrl.ready(dma_read_ctrl_ready);
		    dummy0->dma_write_ctrl.valid(dma_write_ctrl_valid);
		    dummy0->dma_write_ctrl.data(dma_write_ctrl_data);
		    dummy0->dma_write_ctrl.ready(dma_write_ctrl_ready);
		    dummy0->dma_write_chnl.valid(dma_write_chnl_valid);
		    dummy0->dma_write_chnl.data(dma_write_chnl_data_conv);
		    dummy0->dma_write_chnl.ready(dma_write_chnl_ready);
		    
#endif


			{
			const char *simConfig = dummy_wrapper::simConfigName();
			
			if ( simConfig != NULL )
				{
				qbhProjectHandle hProj;
				qbhError err = qbhGetCurrentProject( &hProj );
				if ( err == qbhErrorNoProject )
				{
					err = qbhOpenProject( "project.tcl", &hProj );
			
					if ( err != qbhOK )
					{
						esc_report_error( esc_fatal, "could not open project file %s",
						                                          "project.tcl" );
							return;
					}
				}
			
				if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
					esc_get_vcd_trace_file();
				}
				if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
					esc_get_fsdb_trace_file();
				}
				}
			}

			break;
		case BDWRep_None:
		default:
			esc_report_error( esc_error, "No representation could be determined for simulating instance %s. Please make sure that you used the right name string in the module constructor",
							  name() );
			break;
	}
}

void dummy_wrapper_r::InitThreads()
{
	if ( isBEH() ) 
	{
		
#if defined ( ioConfig_IOCFG_DMA64 )
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl_data;
		SC_METHOD(thread_conf_info);
		  sensitive << conf_info_tokens;
		  sensitive << conf_info_batch;
		  sensitive << conf_info_source;
		  sensitive << conf_info_ndests;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data_index);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_length);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_size);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_user);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_index);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_length);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_size);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_user);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
#elif defined ( ioConfig_IOCFG_DMA128)
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl_data;
		SC_METHOD(thread_conf_info);
		  sensitive << conf_info_tokens;
		  sensitive << conf_info_batch;
		  sensitive << conf_info_source;
		  sensitive << conf_info_ndests;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data_index);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_length);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_size);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_user);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_index);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_length);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_size);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_user);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
#elif defined ( ioConfig_IOCFG_DMA256)
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl_data;
		SC_METHOD(thread_conf_info);
		  sensitive << conf_info_tokens;
		  sensitive << conf_info_batch;
		  sensitive << conf_info_source;
		  sensitive << conf_info_ndests;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data_index);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_length);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_size);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_user);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_index);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_length);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_size);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_user);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
		
#else
		
		SC_METHOD(thread_dma_read_chnl_data_conv);
		  sensitive << dma_read_chnl_data;
		SC_METHOD(thread_conf_info);
		  sensitive << conf_info_tokens;
		  sensitive << conf_info_batch;
		  sensitive << conf_info_source;
		  sensitive << conf_info_ndests;
		SC_METHOD(thread_debug_conv);
		  sensitive << debug_conv;
		SC_METHOD(thread_dma_read_ctrl_data_index);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_length);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_size);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_read_ctrl_data_user);
		  sensitive << dma_read_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_index);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_length);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_size);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_ctrl_data_user);
		  sensitive << dma_write_ctrl_data;
		SC_METHOD(thread_dma_write_chnl_data_conv);
		  sensitive << dma_write_chnl_data_conv;
		
#endif

	}
}

void dummy_wrapper_r::start_of_simulation()
{

#include <dummy_trace.h>

        esc_multiple_writers_warning();
}

void dummy_wrapper_r::CloseTrace()
{
	if ( esc_trace_is_enabled( esc_trace_vcd ) ) {
	esc_close_vcd_trace();
	}
	if ( esc_trace_is_enabled( esc_trace_fsdb ) ) {
		esc_close_fsdb_trace();
		if ( esc_trace_is_enabled( esc_trace_scv ) ) {
			esc_close_fsdb_scv_trace();
		}
	}
}

void dummy_wrapper_r::end_of_simulation()
{
      CloseTrace();
}



void dummy_wrapper_r::DeleteInstances()
{
    if (dummy0)
    {
        delete dummy0;
        dummy0 = 0;
    }
    if (dummy_cosim0)
    {
        delete dummy_cosim0;
        dummy_cosim0 = 0;
    }
  #if defined(BDW_RTL)
    if (dummy_rtl0)
    {
        delete dummy_rtl0;
        dummy_rtl0 = 0;
    }
#endif
}

#if BDW_WRITEFSDB == 1

inline void esc_open_fsdb_trace( const char *file_name  )
{
	sc_trace_file *fsdb_file;
#if ( (defined(XM_SYSTEMC) || defined(NC_SYSTEMC)) && defined(BDW_NCSC_VER) && BDW_NCSC_VER > 102 ) || SYSTEMC_VERSION >= 20120701
    fsdbDumpfile(file_name);
    esc_set_trace_file( fsdb_file, esc_trace_fsdb );
# else

	// SystemC suffixes .fsdb to filenames automatically. Make sure
	// that doesn't get tacked onto a filename that already has the suffix.
	if ( strrchr( file_name, '.' ) != NULL )
	{
		char *trunc_file_name = new char[strlen(file_name)+1];
		strcpy( trunc_file_name, file_name );

		fsdb_file = new fsdb_trace_file( trunc_file_name );
		esc_set_trace_file( fsdb_file, esc_trace_fsdb );

		delete trunc_file_name;
	}
	else
	{
		fsdb_file = new fsdb_trace_file( file_name );
		esc_set_trace_file( fsdb_file, esc_trace_fsdb );
	}
#endif

//
// Novas's SystemC wrapper doesn't have a way to set the time unit as of SystemC 2.1v1.
//
//		((fsdb_trace_file*)fsdb_file)->sc_set_fsdb_time_unit( -12 );
}

inline void esc_close_fsdb_trace()
{
#if ! (((defined(XM_SYSTEMC) || defined(NC_SYSTEMC)) &&  defined(BDW_NCSC_VER) && BDW_NCSC_VER > 102) || SYSTEMC_VERSION >= 20120701)
	fsdb_trace_file * fsdb_file =
		(fsdb_trace_file *)esc_trace_file( esc_trace_fsdb );

	if ( fsdb_file != NULL )
	{
		fsdb_file->CloseFile();
		delete fsdb_file;
		esc_set_trace_file( NULL, esc_trace_fsdb );
	}
#endif
}

#else

inline void esc_open_fsdb_trace( const char *file_name )
{
}

inline void esc_close_fsdb_trace()
{
}

#endif

#if BDW_USE_SCV && BDW_WRITEFSDB == 1
static scv_tr_db* local_fsdb_scv_db = 0;

inline void esc_open_fsdb_scv_trace( const char *file_name  )
{
	// Start SCV logging to FSDB if there is not already a database setup.
    if (!esc_get_scv_tr_db() && esc_trace_is_enabled(esc_trace_scv) )
	{
		scv_startup();
		scv_tr_fsdb_init();

		char* scv_file_name = new char[strlen(file_name) + 1];
		strcpy( scv_file_name, file_name );
		char* fsdb_suffix = strstr( scv_file_name, ".fsdb" );
		if (fsdb_suffix)
			*fsdb_suffix = 0;
		local_fsdb_scv_db = new scv_tr_db(scv_file_name);

		delete [] scv_file_name;
		esc_set_scv_tr_db(local_fsdb_scv_db);
		scv_tr_db::set_default_db(local_fsdb_scv_db);
		local_fsdb_scv_db->set_recording(true);
	}
}

inline void esc_close_fsdb_scv_trace()
{
    if ( local_fsdb_scv_db && (local_fsdb_scv_db == esc_get_scv_tr_db() ) ) 
	{
		delete local_fsdb_scv_db;
		local_fsdb_scv_db = 0;
		esc_set_scv_tr_db(0);
	}
}
#else 
inline void esc_open_fsdb_scv_trace( const char *file_name  )
{
}

inline void esc_close_fsdb_scv_trace()
{
}

#endif

class dummy_wrapper_fsdb_opener {
public:
	dummy_wrapper_fsdb_opener() {
		esc_set_open_fsdb_trace( esc_open_fsdb_trace );
		esc_set_open_fsdb_scv_trace( esc_open_fsdb_scv_trace );
	}
};

static dummy_wrapper_fsdb_opener
  dummy_wrapper_fsdb_opener_inst;

#else

// Visible to uses of the wrapper outside of the BDW environment.
// Only behavioral SystemC simulation is supported.


// Include the source for the behavioral model so it will be compiled.
#include	"/home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/src/dummy.cpp"

#define		dummy_INTERNAL


#include	"dummy_wrap.h"

const char * dummy_wrapper::simConfigName()
{
  return "";
}

enum dummy_wrapper::Representation dummy_wrapper::lookupRepresentation( const char* instName )
{
  return BDWRep_Behavioral;
}

void dummy_wrapper::InitInstances(  )
{
	dummy0 = new dummy( "dummy" );

	
#if defined ( ioConfig_IOCFG_DMA64 )
	
	dummy0->clk(clk);
	dummy0->rst(rst);
	dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
	dummy0->dma_read_chnl.data(dma_read_chnl.data);
	dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
	dummy0->conf_info(conf_info);
	dummy0->conf_done(conf_done);
	dummy0->acc_done(acc_done);
	dummy0->debug(debug);
	dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
	dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
	dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
	dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
	dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
	dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
	dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
	dummy0->dma_write_chnl.data(dma_write_chnl.data);
	dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
	
#elif defined ( ioConfig_IOCFG_DMA128)
	
	dummy0->clk(clk);
	dummy0->rst(rst);
	dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
	dummy0->dma_read_chnl.data(dma_read_chnl.data);
	dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
	dummy0->conf_info(conf_info);
	dummy0->conf_done(conf_done);
	dummy0->acc_done(acc_done);
	dummy0->debug(debug);
	dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
	dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
	dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
	dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
	dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
	dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
	dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
	dummy0->dma_write_chnl.data(dma_write_chnl.data);
	dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
	
#elif defined ( ioConfig_IOCFG_DMA256)
	
	dummy0->clk(clk);
	dummy0->rst(rst);
	dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
	dummy0->dma_read_chnl.data(dma_read_chnl.data);
	dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
	dummy0->conf_info(conf_info);
	dummy0->conf_done(conf_done);
	dummy0->acc_done(acc_done);
	dummy0->debug(debug);
	dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
	dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
	dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
	dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
	dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
	dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
	dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
	dummy0->dma_write_chnl.data(dma_write_chnl.data);
	dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
	
	
#else
	
	dummy0->clk(clk);
	dummy0->rst(rst);
	dummy0->dma_read_chnl.valid(dma_read_chnl.valid);
	dummy0->dma_read_chnl.data(dma_read_chnl.data);
	dummy0->dma_read_chnl.ready(dma_read_chnl.ready);
	dummy0->conf_info(conf_info);
	dummy0->conf_done(conf_done);
	dummy0->acc_done(acc_done);
	dummy0->debug(debug);
	dummy0->dma_read_ctrl.valid(dma_read_ctrl.valid);
	dummy0->dma_read_ctrl.data(dma_read_ctrl.data);
	dummy0->dma_read_ctrl.ready(dma_read_ctrl.ready);
	dummy0->dma_write_ctrl.valid(dma_write_ctrl.valid);
	dummy0->dma_write_ctrl.data(dma_write_ctrl.data);
	dummy0->dma_write_ctrl.ready(dma_write_ctrl.ready);
	dummy0->dma_write_chnl.valid(dma_write_chnl.valid);
	dummy0->dma_write_chnl.data(dma_write_chnl.data);
	dummy0->dma_write_chnl.ready(dma_write_chnl.ready);
	
#endif

}

void dummy_wrapper::InitThreads()
{
}

void dummy_wrapper::CloseTrace()
{
}

void dummy_wrapper::DeleteInstances()
{
    if (dummy0)
    {
        delete dummy0;
        dummy0 = 0;
    }
}

void dummy_wrapper::start_of_simulation()
{
}

void dummy_wrapper::end_of_simulation()
{
}



inline void esc_open_fsdb_trace( const char *file_name )
{
}

inline void esc_close_fsdb_trace()
{
}


inline void esc_open_fsdb_scv_trace( const char *file_name  )
{
}

inline void esc_close_fsdb_scv_trace()
{
}

class dummy_wrapper_fsdb_opener {
public:
	dummy_wrapper_fsdb_opener() {
	}
};

static dummy_wrapper_fsdb_opener
  dummy_wrapper_fsdb_opener_inst;

#endif

#endif
