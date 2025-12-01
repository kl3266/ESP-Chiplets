/****************************************************************************
 *
 *  Copyright (c) 2015, Cadence Design Systems. All Rights Reserved.
 *
 *  This file contains confidential information that may not be
 *  distributed under any circumstances without the written permision
 *  of Cadence Design Systems.
 *
 ***************************************************************************/

#ifndef _DUMMY_COSIM_INCLUDED_
#define _DUMMY_COSIM_INCLUDED_

#include "systemc.h"
#include "cynthhl.h"
#include "esc.h"
#if __GNUC__ < 3
#include <ostream.h>
#else
#include <ostream>


#endif

#if !defined(XM_SYSTEMC) && defined(NC_SYSTEMC)
#define xmsc_foreign_module ncsc_foreign_module
#endif

#if defined(XM_SYSTEMC) || defined(NC_SYSTEMC)
struct dummy_cosim : public xmsc_foreign_module
#else
SC_MODULE(dummy_cosim)
#endif
{
	struct StringPair {
		const char* simConfigName;
		const char* instanceName;
		bool linked;
	};

	// Instance number used during elaboration-time SystemC-to-HDL signal linkage.
	static int numLinked;
	static StringPair instanceNames[];

	static int numInstanceNames( const char* simConfigName ) {
		int nin = 0;
		for ( int i = 0; instanceNames[i].simConfigName != NULL; ++i )
			if ( strcmp( instanceNames[i].simConfigName, simConfigName ) == 0 )
				++nin;
		return nin;
	}

	// Port declarations.
	
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

    void end_of_elaboration()
    {
#if __GNUC__ < 3
		strstream s;
#else
		std::ostringstream s;
#endif


		s << "top/";

		const char* scName = getenv("BDW_BASE_SIM_CONFIG");
		if (!scName) 
		    scName = getenv("BDW_SIM_CONFIG");
		if (!scName) 
			scName = "?";

		int nin = numInstanceNames(scName);
		if ( nin == 0 )
		{
#if !( defined(XM_SYSTEMC) || defined(NC_SYSTEMC) )
			if ( numLinked > 0 ) 
			{
				esc_report_error( esc_fatal, 
					"More than one instance of module dummy is being simulated in Verilog,\n"
					"but no instance names have been specified in simConfig %s.\n"
					"Additional instances can be specified using the following syntax:\n\n"
					"    simConfig <config_name> { <module> RTL_V <config> <inst1> <inst2> ...}\n\n"
					"where <inst1> and <inst2> are the leaf names of instances of dummy in SystemC\n", 
					scName );
				return;
			} else {
				s << "dummy0" << std::ends;
			}
#endif
		}
		else
		{
			StringPair *instPair = &instanceNames[ numLinked ];
			while ( instPair->instanceName != NULL )
			{
				if ( ( ! instPair->linked )
					 && ( ! strcmp( instPair->simConfigName, scName ) ) )
				{
					const char *instName = instPair->instanceName;

					// Hierarchical SystemC instance names must be escaped for Verilog.
					if ( strchr( instName, '.' ) != NULL )
						s << '\\' << instName << ' ' << std::ends;
					else
						s << instName << std::ends;

					instPair->linked = true;
					break;
				}

				++instPair;
			}

			if ( instPair->instanceName == NULL )
			{
				esc_report_error( esc_fatal, 
								  "More than %d instance(s) of module dummy are being simulated in Verilog,\n"
								  "but only %d instance name(s) have been specified in simConfig %s.\n",
								  nin, nin, scName );
				return;
			}
		}
		numLinked++;


#if __GNUC__ < 3
		char *c = s.str();
#else
		char *c = (char *)strdup( s.str().c_str() );
#endif

        link_signals(c, "verilog");
#if __GNUC__ < 3
		delete c;
#else
		free( c );
#endif
    }

    void link_signals(const char *module_path, const char *sim_domain)
    {
#if !defined(XM_SYSTEMC) && !defined(NC_SYSTEMC)
        int registeredClocks = 0;

		double inputDelay = 0.0;
		const char* scName = getenv("BDW_SIM_CONFIG");
		if (!scName) scName = "?";
		if ( qbhVerilogInputDelay( qbhEmptyHandle, scName, &inputDelay ) != qbhOK )
			inputDelay = 0.0;

		// Try to register the boolean input ports as clocks.
		
#if defined ( ioConfig_IOCFG_DMA64 )
		
		int clk_is_clock = esc_link_clockgen( &clk, sc_time( 0, SC_NS ), module_path, sim_domain, "clk" );
		int rst_is_clock = esc_link_clockgen( &rst, sc_time( 0, SC_NS ), module_path, sim_domain, "rst" );
		int dma_read_chnl_valid_is_clock = esc_link_clockgen( &dma_read_chnl_valid, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_chnl_valid" );
		int conf_done_is_clock = esc_link_clockgen( &conf_done, sc_time( 0, SC_NS ), module_path, sim_domain, "conf_done" );
		int dma_read_ctrl_ready_is_clock = esc_link_clockgen( &dma_read_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_ctrl_ready" );
		int dma_write_ctrl_ready_is_clock = esc_link_clockgen( &dma_write_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_ctrl_ready" );
		int dma_write_chnl_ready_is_clock = esc_link_clockgen( &dma_write_chnl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_chnl_ready" );
		
#elif defined ( ioConfig_IOCFG_DMA128)
		
		int clk_is_clock = esc_link_clockgen( &clk, sc_time( 0, SC_NS ), module_path, sim_domain, "clk" );
		int rst_is_clock = esc_link_clockgen( &rst, sc_time( 0, SC_NS ), module_path, sim_domain, "rst" );
		int dma_read_chnl_valid_is_clock = esc_link_clockgen( &dma_read_chnl_valid, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_chnl_valid" );
		int conf_done_is_clock = esc_link_clockgen( &conf_done, sc_time( 0, SC_NS ), module_path, sim_domain, "conf_done" );
		int dma_read_ctrl_ready_is_clock = esc_link_clockgen( &dma_read_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_ctrl_ready" );
		int dma_write_ctrl_ready_is_clock = esc_link_clockgen( &dma_write_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_ctrl_ready" );
		int dma_write_chnl_ready_is_clock = esc_link_clockgen( &dma_write_chnl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_chnl_ready" );
		
#elif defined ( ioConfig_IOCFG_DMA256)
		
		int clk_is_clock = esc_link_clockgen( &clk, sc_time( 0, SC_NS ), module_path, sim_domain, "clk" );
		int rst_is_clock = esc_link_clockgen( &rst, sc_time( 0, SC_NS ), module_path, sim_domain, "rst" );
		int dma_read_chnl_valid_is_clock = esc_link_clockgen( &dma_read_chnl_valid, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_chnl_valid" );
		int conf_done_is_clock = esc_link_clockgen( &conf_done, sc_time( 0, SC_NS ), module_path, sim_domain, "conf_done" );
		int dma_read_ctrl_ready_is_clock = esc_link_clockgen( &dma_read_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_ctrl_ready" );
		int dma_write_ctrl_ready_is_clock = esc_link_clockgen( &dma_write_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_ctrl_ready" );
		int dma_write_chnl_ready_is_clock = esc_link_clockgen( &dma_write_chnl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_chnl_ready" );
		
		
#else
		
		int clk_is_clock = esc_link_clockgen( &clk, sc_time( 0, SC_NS ), module_path, sim_domain, "clk" );
		int rst_is_clock = esc_link_clockgen( &rst, sc_time( 0, SC_NS ), module_path, sim_domain, "rst" );
		int dma_read_chnl_valid_is_clock = esc_link_clockgen( &dma_read_chnl_valid, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_chnl_valid" );
		int conf_done_is_clock = esc_link_clockgen( &conf_done, sc_time( 0, SC_NS ), module_path, sim_domain, "conf_done" );
		int dma_read_ctrl_ready_is_clock = esc_link_clockgen( &dma_read_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_read_ctrl_ready" );
		int dma_write_ctrl_ready_is_clock = esc_link_clockgen( &dma_write_ctrl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_ctrl_ready" );
		int dma_write_chnl_ready_is_clock = esc_link_clockgen( &dma_write_chnl_ready, sc_time( 0, SC_NS ), module_path, sim_domain, "dma_write_chnl_ready" );
		
#endif

		
#if defined ( ioConfig_IOCFG_DMA64 )
		
		if ( ! clk_is_clock )
			esc_link_signals( &clk, module_path, sim_domain, true, inputDelay );
		if ( ! rst_is_clock )
			esc_link_signals( &rst, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_valid, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_data, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_ready, module_path, sim_domain, true );
		esc_link_signals( &conf_info_tokens, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_batch, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_source, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_ndests, module_path, sim_domain, true, inputDelay );
		if ( ! conf_done_is_clock )
			esc_link_signals( &conf_done, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &acc_done, module_path, sim_domain, true );
		esc_link_signals( &debug, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_chnl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_data, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_ready, module_path, sim_domain, true, inputDelay );
		
#elif defined ( ioConfig_IOCFG_DMA128)
		
		if ( ! clk_is_clock )
			esc_link_signals( &clk, module_path, sim_domain, true, inputDelay );
		if ( ! rst_is_clock )
			esc_link_signals( &rst, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_valid, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_data, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_ready, module_path, sim_domain, true );
		esc_link_signals( &conf_info_tokens, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_batch, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_source, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_ndests, module_path, sim_domain, true, inputDelay );
		if ( ! conf_done_is_clock )
			esc_link_signals( &conf_done, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &acc_done, module_path, sim_domain, true );
		esc_link_signals( &debug, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_chnl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_data, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_ready, module_path, sim_domain, true, inputDelay );
		
#elif defined ( ioConfig_IOCFG_DMA256)
		
		if ( ! clk_is_clock )
			esc_link_signals( &clk, module_path, sim_domain, true, inputDelay );
		if ( ! rst_is_clock )
			esc_link_signals( &rst, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_valid, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_data, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_ready, module_path, sim_domain, true );
		esc_link_signals( &conf_info_tokens, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_batch, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_source, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_ndests, module_path, sim_domain, true, inputDelay );
		if ( ! conf_done_is_clock )
			esc_link_signals( &conf_done, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &acc_done, module_path, sim_domain, true );
		esc_link_signals( &debug, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_chnl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_data, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_ready, module_path, sim_domain, true, inputDelay );
		
		
#else
		
		if ( ! clk_is_clock )
			esc_link_signals( &clk, module_path, sim_domain, true, inputDelay );
		if ( ! rst_is_clock )
			esc_link_signals( &rst, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_valid, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_data, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_read_chnl_ready, module_path, sim_domain, true );
		esc_link_signals( &conf_info_tokens, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_batch, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_source, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &conf_info_ndests, module_path, sim_domain, true, inputDelay );
		if ( ! conf_done_is_clock )
			esc_link_signals( &conf_done, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &acc_done, module_path, sim_domain, true );
		esc_link_signals( &debug, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_read_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_ctrl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_index, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_length, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_size, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_data_user, module_path, sim_domain, true );
		esc_link_signals( &dma_write_ctrl_ready, module_path, sim_domain, true, inputDelay );
		esc_link_signals( &dma_write_chnl_valid, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_data, module_path, sim_domain, true );
		esc_link_signals( &dma_write_chnl_ready, module_path, sim_domain, true, inputDelay );
		
#endif
		

		
#if defined ( ioConfig_IOCFG_DMA64 )
		
		if ( clk_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = clk[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, clk.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "clk", scName ) ) {
			esc_report_error( esc_error, "The port 'clk' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( rst_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = rst[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, rst.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "rst", scName ) ) {
			esc_report_error( esc_error, "The port 'rst' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_chnl_valid_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_chnl_valid[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_chnl_valid.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "valid", scName ) ) {
			esc_report_error( esc_error, "The port 'valid' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( conf_done_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = conf_done[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, conf_done.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "conf_done", scName ) ) {
			esc_report_error( esc_error, "The port 'conf_done' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_chnl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_chnl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_chnl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		
#elif defined ( ioConfig_IOCFG_DMA128)
		
		if ( clk_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = clk[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, clk.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "clk", scName ) ) {
			esc_report_error( esc_error, "The port 'clk' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( rst_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = rst[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, rst.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "rst", scName ) ) {
			esc_report_error( esc_error, "The port 'rst' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_chnl_valid_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_chnl_valid[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_chnl_valid.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "valid", scName ) ) {
			esc_report_error( esc_error, "The port 'valid' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( conf_done_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = conf_done[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, conf_done.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "conf_done", scName ) ) {
			esc_report_error( esc_error, "The port 'conf_done' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_chnl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_chnl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_chnl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		
#elif defined ( ioConfig_IOCFG_DMA256)
		
		if ( clk_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = clk[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, clk.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "clk", scName ) ) {
			esc_report_error( esc_error, "The port 'clk' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( rst_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = rst[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, rst.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "rst", scName ) ) {
			esc_report_error( esc_error, "The port 'rst' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_chnl_valid_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_chnl_valid[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_chnl_valid.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "valid", scName ) ) {
			esc_report_error( esc_error, "The port 'valid' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( conf_done_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = conf_done[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, conf_done.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "conf_done", scName ) ) {
			esc_report_error( esc_error, "The port 'conf_done' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_chnl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_chnl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_chnl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		
		
#else
		
		if ( clk_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = clk[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, clk.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "clk", scName ) ) {
			esc_report_error( esc_error, "The port 'clk' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( rst_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = rst[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, rst.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "rst", scName ) ) {
			esc_report_error( esc_error, "The port 'rst' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_chnl_valid_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_chnl_valid[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_chnl_valid.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "valid", scName ) ) {
			esc_report_error( esc_error, "The port 'valid' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( conf_done_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = conf_done[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, conf_done.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "conf_done", scName ) ) {
			esc_report_error( esc_error, "The port 'conf_done' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_read_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_read_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_read_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_ctrl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_ctrl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_ctrl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		if ( dma_write_chnl_ready_is_clock )
		{
			sc_signal_in_if< bool > *clock_inif = dma_write_chnl_ready[0];
			sc_clock *clock_module = dynamic_cast<sc_clock*>(clock_inif);
			esc_hub_register_clock( clock_module, esc_alledge, 0, module_path, sim_domain, dma_write_chnl_ready.basename() );
			++registeredClocks;
		} else if ( qbhGetPortUsedAsClock( qbhEmptyHandle, "dummy", "ready", scName ) ) {
			esc_report_error( esc_error, "The port 'ready' on module 'dummy'\n\tis used as a clock in the design,\n\tbut is not connected to an sc_clock");
		}
		
#endif


        if ( registeredClocks == 0 )
		{
			esc_report_error( esc_fatal, 
				"The clock port in module dummy must have\n"
				"an sc_clock bound to it to make cosimulation work" );
		}
#endif
    }

#if defined(XM_SYSTEMC) || defined(NC_SYSTEMC)
    const char* hdl_name() const 
    {
        if ( getenv("BDW_NO_NCWRAPPER") )
        {
            return "dummy"; 
        }
        else
        {
            return "dummy_nc_cosim"; 
        }
    } 
    dummy_cosim( sc_module_name name )
        : xmsc_foreign_module(name)
#else
	dummy_cosim( sc_module_name in_name=sc_module_name(sc_gen_unique_name(" dummy") ) )
		: sc_module(in_name)
#endif
		  
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
		  

    {
    };
};

int dummy_cosim::numLinked = 0;
dummy_cosim::StringPair dummy_cosim::instanceNames[] = {
	{ NULL, NULL, false } };

#endif
