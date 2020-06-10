----------------------------------------------------------------------
--
-- S3MO5 - testbench s3mo5 package
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
package testbench_s3mo5_package is

  signal probe_tb_done_uart     : std_logic := '0';
  signal probe_tb_done_keyboard : std_logic := '0';
  signal probe_tb_clk_osc       : std_logic;
  signal probe_tb_resetn        : std_logic;
  signal probe_tb_pbutton       : std_logic_vector( 3 downto  0);
  signal probe_tb_switch        : std_logic_vector( 7 downto  0);
  signal probe_tb_uart_tx       : std_logic;
  signal probe_tb_uart_rx       : std_logic;
  signal probe_tb_ps2_c         : std_logic := '1';
  signal probe_tb_ps2_d         : std_logic := '1';
  signal probe_tb_sram_wen      : std_logic;
  signal probe_tb_sram_oen      : std_logic;
  signal probe_tb_sram_a        : std_logic_vector(17 downto  0);
  signal probe_tb_sram_csn      : std_logic_vector( 1 downto  0);
  signal probe_tb_sram_ben      : std_logic_vector( 3 downto  0);
  signal probe_tb_sram_dq       : std_logic_vector(31 downto  0);

end package testbench_s3mo5_package;
