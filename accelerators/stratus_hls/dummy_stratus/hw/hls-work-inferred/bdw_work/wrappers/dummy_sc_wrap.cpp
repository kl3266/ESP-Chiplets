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


#include	"dummy_sc_wrap.h"
#include	"dummy_sc_foreign.h"

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


void dummy_wrapper::InitInstances(  )
{
	
#if defined ( ioConfig_IOCFG_DMA64 )
	
	
#elif defined ( ioConfig_IOCFG_DMA128)
	
	
#elif defined ( ioConfig_IOCFG_DMA256)
	
	
	
#else
	
	
#endif

            
    dummy0 = new dummy( "dummy" );

    
#if defined ( ioConfig_IOCFG_DMA64 )
    
    dummy0->clk(clk);
    dummy0->rst(rst);
    dummy0->dma_read_chnl_valid(dma_read_chnl.valid);
    dummy0->dma_read_chnl_data(dma_read_chnl_data_conv);
    dummy0->dma_read_chnl_ready(dma_read_chnl.ready);
    dummy0->conf_info_tokens(conf_info_tokens);
    dummy0->conf_info_batch(conf_info_batch);
    dummy0->conf_info_source(conf_info_source);
    dummy0->conf_info_ndests(conf_info_ndests);
    dummy0->conf_done(conf_done);
    dummy0->acc_done(acc_done);
    dummy0->debug(debug_conv);
    dummy0->dma_read_ctrl_valid(dma_read_ctrl.valid);
    dummy0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
    dummy0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
    dummy0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
    dummy0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
    dummy0->dma_read_ctrl_ready(dma_read_ctrl.ready);
    dummy0->dma_write_ctrl_valid(dma_write_ctrl.valid);
    dummy0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
    dummy0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
    dummy0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
    dummy0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
    dummy0->dma_write_ctrl_ready(dma_write_ctrl.ready);
    dummy0->dma_write_chnl_valid(dma_write_chnl.valid);
    dummy0->dma_write_chnl_data(dma_write_chnl_data_conv);
    dummy0->dma_write_chnl_ready(dma_write_chnl.ready);
    
#elif defined ( ioConfig_IOCFG_DMA128)
    
    dummy0->clk(clk);
    dummy0->rst(rst);
    dummy0->dma_read_chnl_valid(dma_read_chnl.valid);
    dummy0->dma_read_chnl_data(dma_read_chnl_data_conv);
    dummy0->dma_read_chnl_ready(dma_read_chnl.ready);
    dummy0->conf_info_tokens(conf_info_tokens);
    dummy0->conf_info_batch(conf_info_batch);
    dummy0->conf_info_source(conf_info_source);
    dummy0->conf_info_ndests(conf_info_ndests);
    dummy0->conf_done(conf_done);
    dummy0->acc_done(acc_done);
    dummy0->debug(debug_conv);
    dummy0->dma_read_ctrl_valid(dma_read_ctrl.valid);
    dummy0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
    dummy0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
    dummy0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
    dummy0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
    dummy0->dma_read_ctrl_ready(dma_read_ctrl.ready);
    dummy0->dma_write_ctrl_valid(dma_write_ctrl.valid);
    dummy0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
    dummy0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
    dummy0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
    dummy0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
    dummy0->dma_write_ctrl_ready(dma_write_ctrl.ready);
    dummy0->dma_write_chnl_valid(dma_write_chnl.valid);
    dummy0->dma_write_chnl_data(dma_write_chnl_data_conv);
    dummy0->dma_write_chnl_ready(dma_write_chnl.ready);
    
#elif defined ( ioConfig_IOCFG_DMA256)
    
    dummy0->clk(clk);
    dummy0->rst(rst);
    dummy0->dma_read_chnl_valid(dma_read_chnl.valid);
    dummy0->dma_read_chnl_data(dma_read_chnl_data_conv);
    dummy0->dma_read_chnl_ready(dma_read_chnl.ready);
    dummy0->conf_info_tokens(conf_info_tokens);
    dummy0->conf_info_batch(conf_info_batch);
    dummy0->conf_info_source(conf_info_source);
    dummy0->conf_info_ndests(conf_info_ndests);
    dummy0->conf_done(conf_done);
    dummy0->acc_done(acc_done);
    dummy0->debug(debug_conv);
    dummy0->dma_read_ctrl_valid(dma_read_ctrl.valid);
    dummy0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
    dummy0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
    dummy0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
    dummy0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
    dummy0->dma_read_ctrl_ready(dma_read_ctrl.ready);
    dummy0->dma_write_ctrl_valid(dma_write_ctrl.valid);
    dummy0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
    dummy0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
    dummy0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
    dummy0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
    dummy0->dma_write_ctrl_ready(dma_write_ctrl.ready);
    dummy0->dma_write_chnl_valid(dma_write_chnl.valid);
    dummy0->dma_write_chnl_data(dma_write_chnl_data_conv);
    dummy0->dma_write_chnl_ready(dma_write_chnl.ready);
    
    
#else
    
    dummy0->clk(clk);
    dummy0->rst(rst);
    dummy0->dma_read_chnl_valid(dma_read_chnl.valid);
    dummy0->dma_read_chnl_data(dma_read_chnl_data_conv);
    dummy0->dma_read_chnl_ready(dma_read_chnl.ready);
    dummy0->conf_info_tokens(conf_info_tokens);
    dummy0->conf_info_batch(conf_info_batch);
    dummy0->conf_info_source(conf_info_source);
    dummy0->conf_info_ndests(conf_info_ndests);
    dummy0->conf_done(conf_done);
    dummy0->acc_done(acc_done);
    dummy0->debug(debug_conv);
    dummy0->dma_read_ctrl_valid(dma_read_ctrl.valid);
    dummy0->dma_read_ctrl_data_index(dma_read_ctrl_data_index);
    dummy0->dma_read_ctrl_data_length(dma_read_ctrl_data_length);
    dummy0->dma_read_ctrl_data_size(dma_read_ctrl_data_size);
    dummy0->dma_read_ctrl_data_user(dma_read_ctrl_data_user);
    dummy0->dma_read_ctrl_ready(dma_read_ctrl.ready);
    dummy0->dma_write_ctrl_valid(dma_write_ctrl.valid);
    dummy0->dma_write_ctrl_data_index(dma_write_ctrl_data_index);
    dummy0->dma_write_ctrl_data_length(dma_write_ctrl_data_length);
    dummy0->dma_write_ctrl_data_size(dma_write_ctrl_data_size);
    dummy0->dma_write_ctrl_data_user(dma_write_ctrl_data_user);
    dummy0->dma_write_ctrl_ready(dma_write_ctrl.ready);
    dummy0->dma_write_chnl_valid(dma_write_chnl.valid);
    dummy0->dma_write_chnl_data(dma_write_chnl_data_conv);
    dummy0->dma_write_chnl_ready(dma_write_chnl.ready);
    
#endif

}

void dummy_wrapper::InitThreads()
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

void dummy_wrapper::DeleteInstances()
{
    if (dummy0)
    {
        delete dummy0;
        dummy0 = 0;
    }
}

