----------------------------------------------------------------------
--
-- S3MO5 - video controller package
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
package videocntl_package is
  
  signal probe_videocntl_hcounter      : std_logic_vector(10 downto 0);  
  signal probe_videocntl_vcounter      : std_logic_vector( 9 downto 0);  
  signal probe_videocntl_hsync         : std_logic;                      
  signal probe_videocntl_vsync         : std_logic;                      
  signal probe_videocntl_toggle_dither : std_logic;                      
  signal probe_videocntl_hborder       : std_logic;                      
  signal probe_videocntl_vborder       : std_logic;                      
  signal probe_videocntl_hactive       : std_logic;                      
  signal probe_videocntl_vactive       : std_logic;                      
  signal probe_videocntl_bgr           : std_logic_vector(2 downto 0);   
  signal probe_videocntl_pixel_data    : std_logic_vector(7 downto 0);   
  signal probe_videocntl_color_data    : std_logic_vector(7 downto 0);   
  
end package videocntl_package;
