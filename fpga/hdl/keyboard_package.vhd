----------------------------------------------------------------------
--
-- S3MO5 - keyboard package
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
package keyboard_package is

  type  t_mo5_key_state    is (s_idle,s_press_shift0,s_press_shift1,
                               s_press_shift2,s_press_key);

  signal probe_keyboard_ps2c_1t           : std_logic;                     
  signal probe_keyboard_ps2c_2t           : std_logic;                     
  signal probe_keyboard_ps2c_3t           : std_logic;                     
  signal probe_keyboard_count             : std_logic_vector( 3 downto 0); 
  signal probe_keyboard_shift             : std_logic_vector(10 downto 0); 
  signal probe_keyboard_parity            : std_logic;                     
  signal probe_keyboard_timeout_state     : std_logic;                     
  signal probe_keyboard_data              : std_logic_vector( 7 downto 0); 
  signal probe_keyboard_data_update       : std_logic; 
  signal probe_keyboard_ps2_shift_pressed : std_logic; 
  signal probe_keyboard_ps2_alt_pressed   : std_logic; 
  signal probe_keyboard_ps2_key_released  : std_logic; 
  signal probe_keyboard_ps2_key_pressed   : std_logic; 
  signal probe_keyboard_mo5_key_state     : t_mo5_key_state; 
  signal probe_keyboard_mo5_shift_pressed : std_logic; 
  signal probe_keyboard_key_decoded       : std_logic_vector(6 downto 0); 

end package keyboard_package;
