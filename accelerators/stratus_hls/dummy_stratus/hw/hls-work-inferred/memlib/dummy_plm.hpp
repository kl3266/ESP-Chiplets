//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

#ifndef __DUMMY_PLM_HPP__
#define __DUMMY_PLM_HPP__
#include "dummy_plm.h"
template<class T, unsigned S, typename ioConfig=CYN::PIN>
class dummy_plm_t : public sc_module
{

  HLS_INLINE_MODULE;
public:
  dummy_plm_t(const sc_module_name& name = sc_gen_unique_name("dummy_plm"))
  : sc_module(name)
  , clk("clk")
  , port1("port1")
  , port2("port2")
  , port3("port3")
  , port4("port4")
  , port5("port5")
  , port6("port6")
  , port7("port7")
  , port8("port8")
  , port9("port9")
  , port10("port10")
  , port11("port11")
  , port12("port12")
  , port13("port13")
  , port14("port14")
  , port15("port15")
  , port16("port16")
  {
    m_m0.clk_rst(clk);
    port1(m_m0.if1);
    port2(m_m0.if2);
    port3(m_m0.if3);
    port4(m_m0.if4);
    port5(m_m0.if5);
    port6(m_m0.if6);
    port7(m_m0.if7);
    port8(m_m0.if8);
    port9(m_m0.if9);
    port10(m_m0.if10);
    port11(m_m0.if11);
    port12(m_m0.if12);
    port13(m_m0.if13);
    port14(m_m0.if14);
    port15(m_m0.if15);
    port16(m_m0.if16);
  }

  sc_in<bool> clk;

  dummy_plm::wrapper<ioConfig> m_m0;

  typedef dummy_plm::port_1<ioConfig, T[1][S]> Port1_t;
  typedef dummy_plm::port_2<ioConfig, T[1][S]> Port2_t;
  typedef dummy_plm::port_3<ioConfig, T[1][S]> Port3_t;
  typedef dummy_plm::port_4<ioConfig, T[1][S]> Port4_t;
  typedef dummy_plm::port_5<ioConfig, T[1][S]> Port5_t;
  typedef dummy_plm::port_6<ioConfig, T[1][S]> Port6_t;
  typedef dummy_plm::port_7<ioConfig, T[1][S]> Port7_t;
  typedef dummy_plm::port_8<ioConfig, T[1][S]> Port8_t;
  typedef dummy_plm::port_9<ioConfig, T[1][S]> Port9_t;
  typedef dummy_plm::port_10<ioConfig, T[1][S]> Port10_t;
  typedef dummy_plm::port_11<ioConfig, T[1][S]> Port11_t;
  typedef dummy_plm::port_12<ioConfig, T[1][S]> Port12_t;
  typedef dummy_plm::port_13<ioConfig, T[1][S]> Port13_t;
  typedef dummy_plm::port_14<ioConfig, T[1][S]> Port14_t;
  typedef dummy_plm::port_15<ioConfig, T[1][S]> Port15_t;
  typedef dummy_plm::port_16<ioConfig, T[1][S]> Port16_t;

  Port1_t port1;
  Port2_t port2;
  Port3_t port3;
  Port4_t port4;
  Port5_t port5;
  Port6_t port6;
  Port7_t port7;
  Port8_t port8;
  Port9_t port9;
  Port10_t port10;
  Port11_t port11;
  Port12_t port12;
  Port13_t port13;
  Port14_t port14;
  Port15_t port15;
  Port16_t port16;
};
#endif
