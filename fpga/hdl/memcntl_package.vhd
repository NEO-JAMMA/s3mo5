----------------------------------------------------------------------
--
-- S3MO5 - memcntl package
--
-- Copyright (C) 2005 Olivier Ringot <oringot@gmail.com>
-- 
-- This file is part of the S3MO5 project
--
-- The S3MO5 project is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- The S3MO5 project is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this S3MO5 project; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, 
-- Boston, MA  02110-1301, USA.
-- 
----------------------------------------------------------------------
-- $Revision: $
-- $Date: $
-- $Source: $
-- $Log: $
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------
--      
----------------------------------------------------------------------
package memcntl_package is

  type  t_uart_state   is (s_idle,s_get_addr0,s_get_addr1,
                           s_get_qty,s_read_get_data_req,
                           s_read_get_data_ack,s_read_get_data_sent,
                           s_write_put_data,s_write_put_data_receive,
                           s_write_put_data_write);
  
  signal probe_memcntl_uart_state     : t_uart_state;                  
  signal probe_memcntl_emi_state      : std_logic_vector( 2 downto 0); 
  signal probe_memcntl_reg_control    : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_control2   : std_logic;                     
  signal probe_memcntl_reg_index_l    : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_index_h    : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_pra0       : std_logic_vector( 6 downto 0); 
  signal probe_memcntl_reg_prb0       : std_logic_vector( 6 downto 0); 
  signal probe_memcntl_reg_dda0       : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_ddb0       : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_cra0       : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_crb0       : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_gatearray0 : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_gatearray1 : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_gatearray2 : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_reg_gatearray3 : std_logic_vector( 7 downto 0); 
  --
  signal probe_memcntl_sel_write      : std_logic;                     
  signal probe_memcntl_sel_registers  : std_logic_vector(3 downto 0);  
  --
  signal probe_memcntl_vga_addr       : std_logic_vector(12 downto 0); 
  signal probe_memcntl_vga_row        : std_logic_vector( 7 downto 0); 
  signal probe_memcntl_vga_col        : std_logic_vector( 5 downto 0); 
  signal probe_memcntl_vga_odd        : std_logic;                     
  signal probe_memcntl_vga_vsync_1t   : std_logic;                     
  --
  signal probe_memcntl_source_irq_1t  : std_logic;                     
  --
  signal probe_memcntl_cpu_stall      : std_logic;                     
  signal probe_memcntl_cpu_slow_count : std_logic_vector( 2 downto 0); 
  --
  signal probe_memcntl_uart_addr      : std_logic_vector(15 downto 0); 
  signal probe_memcntl_uart_write     : std_logic;                     
  signal probe_memcntl_uart_qty       : std_logic_vector( 7 downto 0); 

end package memcntl_package;
