----------------------------------------------------------------------
--
-- S3MO5 - s3mo5 package
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
package s3mo5_package is

  -- system
  signal probe_s3mo5_reset           : std_logic; 
  signal probe_s3mo5_reset_1t        : std_logic; 
  signal probe_s3mo5_reset_2t        : std_logic; 
  signal probe_s3mo5_resetn          : std_logic; 
  signal probe_s3mo5_soft_resetn     : std_logic; 
  signal probe_s3mo5_clk50m          : std_logic;
  signal probe_s3mo5_source_irq      : std_logic;
  signal probe_s3mo5_source_irq_sel  : std_logic;
  -- processor
  signal probe_s3mo5_clken_cpu       : std_logic;
  signal probe_s3mo5_cpu_nnmi        : std_logic;
  signal probe_s3mo5_cpu_nfiq        : std_logic;
  signal probe_s3mo5_cpu_nirq        : std_logic;
  -- keyboard
  signal probe_s3mo5_keyboard_update : std_logic;
  signal probe_s3mo5_keyboard_data   : std_logic_vector( 7 downto 0);
  signal probe_s3mo5_keyboard_data_1t: std_logic_vector( 7 downto 0);
  signal probe_s3mo5_keyboard_data_2t: std_logic_vector( 7 downto 0);
  -- 7 segments
  signal probe_s3mo5_anode           : std_logic_vector( 3 downto 0);
  -- vga controller
  signal probe_s3mo5_vga_data        : std_logic_vector(15 downto 0);
  signal probe_s3mo5_vga_update      : std_logic;
  signal probe_s3mo5_vga_vsync_i     : std_logic;
  signal probe_s3mo5_vga_border      : std_logic_vector( 3 downto 0);
  -- processor
  signal probe_s3mo5_cpu_turbo       : std_logic;
  signal probe_s3mo5_cpu_turbo_1t    : std_logic;
  signal probe_s3mo5_cpu_busreq      : std_logic;
  signal probe_s3mo5_cpu_write       : std_logic;
  signal probe_s3mo5_cpu_addr        : std_logic_vector(15 downto 0);
  signal probe_s3mo5_cpu_wdata       : std_logic_vector( 7 downto 0);
  signal probe_s3mo5_cpu_rdata       : std_logic_vector( 7 downto 0);
  -- sram
  signal probe_s3mo5_sram_dataen     : std_logic_vector( 1 downto 0);
  signal probe_s3mo5_sram_wdata      : std_logic_vector(31 downto 0);
  signal probe_s3mo5_sram_rdata      : std_logic_vector(31 downto 0);
  signal probe_s3mo5_sram_wen_i      : std_logic;
  signal probe_s3mo5_sram_ben_i      : std_logic_vector( 1 downto 0);
  -- uart
  signal probe_s3mo5_uart_wen        : std_logic;
  signal probe_s3mo5_uart_tx_i       : std_logic;
  signal probe_s3mo5_uart_wdata      : std_logic_vector( 7 downto 0);
  signal probe_s3mo5_uart_wbusy      : std_logic;
  signal probe_s3mo5_uart_rdata      : std_logic_vector( 7 downto 0);
  signal probe_s3mo5_uart_rvalid     : std_logic;
  -- keyboard
  signal probe_s3mo5_keyboard_col    : std_logic_vector( 2 downto 0);
  signal probe_s3mo5_keyboard_row    : std_logic_vector( 2 downto 0);
  signal probe_s3mo5_keyboard_hit    : std_logic;
  signal probe_s3mo5_keyboard_toggle : std_logic;
  signal probe_s3mo5_keyboard_esc    : std_logic;
  -- dividers
  signal probe_s3mo5_clken_uart      : std_logic;
  signal probe_s3mo5_clken_20ms      : std_logic;
  signal probe_s3mo5_clken_s7        : std_logic;
  signal probe_s3mo5_state_s7        : std_logic;
  signal probe_s3mo5_divider_uart    : std_logic_vector( 6 downto 0);
  signal probe_s3mo5_divider_20ms    : std_logic_vector(13 downto 0);

end package s3mo5_package;
