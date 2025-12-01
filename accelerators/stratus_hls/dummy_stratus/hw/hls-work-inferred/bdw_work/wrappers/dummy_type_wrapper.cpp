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

#include "dummy_type_wrapper.h"


SC_MODULE_EXPORT(dummy_type_wrapper)

// The following threads are used to connect RTL ports to the actual
// structured ports

#if defined ( ioConfig_IOCFG_DMA64 )

void dummy_type_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_type_wrapper::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_type_wrapper::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 64 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}

#elif defined ( ioConfig_IOCFG_DMA128)

void dummy_type_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_type_wrapper::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_type_wrapper::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 128 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}

#elif defined ( ioConfig_IOCFG_DMA256)

void dummy_type_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_type_wrapper::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_type_wrapper::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 256 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}


#else

void dummy_type_wrapper::thread_dma_read_chnl_data_conv()
{
   dma_read_chnl_data_conv = dma_read_chnl_data.read();
}
void dummy_type_wrapper::thread_conf_info()
{
   conf_info_t tmp;
   tmp.tokens = conf_info_tokens.read();
   tmp.batch = conf_info_batch.read();
   tmp.source = conf_info_source.read();
   tmp.ndests = conf_info_ndests.read();
   conf_info.write(tmp);
}
void dummy_type_wrapper::thread_debug_conv()
{
   sc_uint< 32 > tmp;
   tmp = debug_conv.read();
   debug.write(tmp);
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_index()
{
   dma_read_ctrl_data_index = dma_read_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_length()
{
   dma_read_ctrl_data_length = dma_read_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_size()
{
   dma_read_ctrl_data_size = dma_read_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_read_ctrl_data_user()
{
   dma_read_ctrl_data_user = dma_read_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_index()
{
   dma_write_ctrl_data_index = dma_write_ctrl_data.read().index;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_length()
{
   dma_write_ctrl_data_length = dma_write_ctrl_data.read().length;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_size()
{
   dma_write_ctrl_data_size = dma_write_ctrl_data.read().size;
}
void dummy_type_wrapper::thread_dma_write_ctrl_data_user()
{
   dma_write_ctrl_data_user = dma_write_ctrl_data.read().user;
}
void dummy_type_wrapper::thread_dma_write_chnl_data_conv()
{
   sc_biguint< 512 > tmp;
   tmp = dma_write_chnl_data_conv.read();
   dma_write_chnl_data.write(tmp);
}

#endif


void dummy_type_wrapper::InitInstances()
{
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

}

void dummy_type_wrapper::InitThreads()
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

void dummy_type_wrapper::DeleteInstances()
{
        delete dummy0;
        dummy0 = 0;
}

