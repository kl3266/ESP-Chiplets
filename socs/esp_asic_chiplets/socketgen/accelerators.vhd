-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0


library ieee;
use ieee.std_logic_1164.all;
use work.sld_devices.all;
use work.allacc.all;

entity dummy_stratus_rtl is

    generic (
      hls_conf  : hlscfg_t
    );

    port (
      conf_info_tokens           : in  std_logic_vector(31 downto 0);
      conf_info_batch            : in  std_logic_vector(31 downto 0);
      conf_info_source           : in  std_logic_vector(31 downto 0);
      conf_info_ndests           : in  std_logic_vector(31 downto 0);
      clk                        : in  std_ulogic;
      acc_rst                    : in  std_ulogic;
      conf_done                  : in  std_ulogic;
      dma_read_ctrl_valid        : out std_ulogic;
      dma_read_ctrl_ready        : in  std_ulogic;
      dma_read_ctrl_data_index   : out std_logic_vector(31 downto 0);
      dma_read_ctrl_data_length  : out std_logic_vector(31 downto 0);
      dma_read_ctrl_data_size    : out std_logic_vector(2 downto 0);
      dma_read_ctrl_data_user    : out std_logic_vector(4 downto 0);
      dma_write_ctrl_valid       : out std_ulogic;
      dma_write_ctrl_ready       : in  std_ulogic;
      dma_write_ctrl_data_index  : out std_logic_vector(31 downto 0);
      dma_write_ctrl_data_length : out std_logic_vector(31 downto 0);
      dma_write_ctrl_data_size   : out std_logic_vector(2 downto 0);
      dma_write_ctrl_data_user   : out std_logic_vector(4 downto 0);
      dma_read_chnl_valid        : in  std_ulogic;
      dma_read_chnl_ready        : out std_ulogic;
      dma_read_chnl_data         : in  std_logic_vector(511 downto 0);
      dma_write_chnl_valid       : out std_ulogic;
      dma_write_chnl_ready       : in  std_ulogic;
      dma_write_chnl_data        : out std_logic_vector(511 downto 0);
      acc_done                   : out std_ulogic
    );

end entity dummy_stratus_rtl;


architecture mapping of dummy_stratus_rtl is

begin  -- mapping


  impl_basic_dma512_gen: if hls_conf = HLSCFG_DUMMY_STRATUS_BASIC_DMA512 generate
    dummy_stratus_basic_dma512_i: dummy_stratus_basic_dma512
    port map(
      conf_info_tokens           => conf_info_tokens,
      conf_info_batch            => conf_info_batch,
      conf_info_source           => conf_info_source,
      conf_info_ndests           => conf_info_ndests,
      clk                        => clk,
      rst                        => acc_rst,
      conf_done                  => conf_done,
      dma_read_ctrl_valid        => dma_read_ctrl_valid,
      dma_read_ctrl_ready        => dma_read_ctrl_ready,
      dma_read_ctrl_data_index   => dma_read_ctrl_data_index,
      dma_read_ctrl_data_length  => dma_read_ctrl_data_length,
      dma_read_ctrl_data_size    => dma_read_ctrl_data_size,
      dma_read_ctrl_data_user    => dma_read_ctrl_data_user,
      dma_write_ctrl_valid       => dma_write_ctrl_valid,
      dma_write_ctrl_ready       => dma_write_ctrl_ready,
      dma_write_ctrl_data_index  => dma_write_ctrl_data_index,
      dma_write_ctrl_data_length => dma_write_ctrl_data_length,
      dma_write_ctrl_data_size   => dma_write_ctrl_data_size,
      dma_write_ctrl_data_user   => dma_write_ctrl_data_user,
      dma_read_chnl_valid        => dma_read_chnl_valid,
      dma_read_chnl_ready        => dma_read_chnl_ready,
      dma_read_chnl_data         => dma_read_chnl_data,
      dma_write_chnl_valid       => dma_write_chnl_valid,
      dma_write_chnl_ready       => dma_write_chnl_ready,
      dma_write_chnl_data        => dma_write_chnl_data,
      acc_done                   => acc_done
    );
  end generate impl_basic_dma512_gen;

end mapping;

