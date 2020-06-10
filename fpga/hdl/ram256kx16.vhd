----------------------------------------------------------------------
--
-- S3MO5 - ram256kx16
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
-- filemode :
--
--   0: 16 bits data only.         
--
--      i.e:
--          10CE
--          AFF0
--          7FAF
--           
--   1: 24 bits address + 16x 16 bits data           (1) 
--
--      i.e:
--
--          00A000 10CEAFF07FAF01B6A7FE8A04B7A7FE10
--          00A008 8EA7C0865FA7A48604A722868CA7A486
-- 
-- NOTE:
--
-- (1) o word address
--     o word read from left (lower address) to right (higher address)
--     o always big endian representation (MBS left, LSB right).
--    
----------------------------------------------------------------------

library std,ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

entity ram256kx16 is
  generic
  (
    -- 0: no address/1: address present
    init_filemode : integer := 0;
    init_filename : string;
    dump_filename : string
  );
  port
  (
    -- dump contentent into a file
    dump     :    in std_logic;
    -- asynchronous memory interface
    csn      :    in std_logic;
    wen      :    in std_logic; 
    oen      :    in std_logic; 
    ubn      :    in std_logic; 
    lbn      :    in std_logic; 
    a        :    in std_logic_vector(17 downto 0);
    dq       : inout std_logic_vector(15 downto 0)    
  );
end entity ram256kx16;

architecture behaviour of ram256kx16 is

  signal periodic_dump : std_logic := '0';

begin

  p_periodic_dump:process
  begin
  
    periodic_dump <= '0';
    wait for 200 ms;
    periodic_dump <= '1';
    wait for 100 ns;
  
  end process p_periodic_dump;
  
  p_ram:process(csn,wen,oen,ubn,lbn,a,dq,dump,periodic_dump)
  
    file file_in      : text open read_mode  is init_filename;
    file file_out     : text open write_mode is dump_filename;
    variable line_in  : line;
    variable line_out : line;
    variable is_init  : std_logic :='0';
    
    type t_mem          is array(0 to 262143) of std_logic_vector(15 downto 0);
    variable mem        : t_mem;
    variable tmp16      : std_logic_vector(15 downto 0);
    variable tmp24      : std_logic_vector(23 downto 0);
    variable dump_state : std_logic;
  
    variable tmp_period : time := 0 ns;
  
  begin
  
    -- -------------------------------------------------------------------------
    -- initialise memory content from file
    -- -------------------------------------------------------------------------
    if is_init='0' then
    
      if init_filemode=0 then
      
        for i in 0 to 262143 loop     
      
          exit when endfile(file_in); 
          readline(file_in,line_in);  
          hread(line_in,tmp16);
          mem(i) := tmp16;
        
        end loop;
        
      else
          
        loop
          
          exit when endfile(file_in); 
          readline(file_in,line_in);  
          hread(line_in,tmp24);
          
          for i in 0 to 7 loop
          
            hread(line_in,tmp16);
            mem(conv_integer(tmp24(17 downto 0))) := tmp16;
            tmp24 := tmp24 + 1;
        
          end loop;
        
        end loop;
     
      end if;
      is_init := '1';
    
    end if;
    
    if dump_state='0' then
    
      if dump='1' or periodic_dump='1' then 
      
        write(line_out,string'("dump "));
        write(line_out,now);
        writeline(file_out,line_out);
        
        dump_state := '1';
        for j in 0 to 32767 loop
        
          hwrite(line_out,conv_std_logic_vector(j*8,24));
          write(line_out,string'(" "));
         
          for i in 0 to 7 loop
        
            hwrite(line_out,mem(j*8+i));
             
          end loop;
          
          writeline(file_out,line_out);
          
        end loop;
      
      end if;
      
    else
    
      if dump='0' and periodic_dump='0'then
       
        dump_state := '0';
        
      end if;
    
    end if;
    
    -- -------------------------------------------------------------------------
    -- memory description
    -- -------------------------------------------------------------------------
    
    if csn='0' then
    
      if wen='0' then
      
        tmp16 := mem(conv_integer(a));
        
        if ubn='0' then
        
          tmp16 := dq(15 downto 8)&tmp16(7 downto 0);   
      
        end if;
        
        if lbn='0' then
       
          tmp16 := tmp16(15 downto 8)&dq(7 downto 0);   
        
        end if;
      
        mem(conv_integer(a)) := tmp16;
      
      else
      
        if oen='0' then
        
          tmp16 := mem(conv_integer(a));
          
          if ubn='0' then
          
            dq(15 downto 8) <= tmp16(15 downto 8);
          
          else
          
            dq(15 downto 8) <= (others=>'Z');
          
          end if;
          
          if lbn='0' then
          
            dq( 7 downto 0) <= tmp16( 7 downto 0);
          
          else
          
            dq(7  downto 0) <= (others=>'Z');
          
          end if;
          
        else
        
          dq <= (others=>'Z');
        
        end if;    
      
      end if;
    
    else
    
      dq <= (others=>'Z');
    
    end if;
    
  end process p_ram;

end architecture behaviour;
