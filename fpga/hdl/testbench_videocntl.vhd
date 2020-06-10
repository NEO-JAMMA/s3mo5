----------------------------------------------------------------------
--
-- S3MO5 - testbnech videocntl
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

library std,ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity testbench_videocntl is
end entity testbench_videocntl;

architecture testbench of testbench_videocntl is

  component videocntl
    port
    (
      -- system
      resetn     :  in std_logic;
      clk        :  in std_logic;
      -- data
      data_req   : out std_logic;
      data       :  in std_logic_vector(15 downto 0);
      border     :  in std_logic_vector( 3 downto 0);
      -- 
      hsync      : out std_logic; 
      vsync      : out std_logic; 
      r          : out std_logic; 
      g          : out std_logic; 
      b          : out std_logic  
    );
  end component;
  
  signal resetn   : std_logic;
  signal clk      : std_logic;
  signal data_req : std_logic;
  signal data     : std_logic_vector(15 downto 0);
  signal border   : std_logic_vector( 3 downto 0);
  signal hsync    : std_logic;
  signal vsync    : std_logic;
  signal r        : std_logic;
  signal g        : std_logic;
  signal b        : std_logic; 
  
  signal done     : std_logic :='0';

begin 

  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------
  
  
  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------
  p_clock_generation:process
  begin
  
    if done='1' then
    
      wait;
    
    else
    
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    
    end if;
  
  end process p_clock_generation;
  
  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 15 ns;
    resetn <= '1';
    wait;
  
  end process p_reset_generation;


  -- ---------------------------------------------------------------------------
  -- send data
  -- ---------------------------------------------------------------------------
  p_data_generation:process(resetn,clk)
  
    variable is_init : std_logic :='0';
    type t_mem       is array(0 to 7999) of std_logic_vector(15 downto 0);
    variable mem     : t_mem;
    
    file  file_in    : text open read_mode is "./stimuli/videocntl.txt";
    variable line_in : line;
    
    variable odd     : integer;
    variable x       : integer;
    variable y       : integer;
  
  begin
  
    if resetn='0' then
    
      border <= "1000";
      data   <= (others=>'0');
      odd    := 0;
      x      := 0;
      y      := 0;
      
      if is_init='0' then
      
        for i in 0 to 7999 loop
        
          readline(file_in,line_in);
          hread(line_in,mem(i));
          exit when endfile(file_in);
        
        end loop;
      
        is_init := '1';
      
      end if;
    
    elsif clk'event and clk='1' then
      
      if data_req='1' and done='0' then
      
        data <= mem(x+y*40);
        x    := x + 1;
        
        if x=40 then
        
          x:=0;
          
          if odd=0 then
          
            odd := 1;
            
          else
          
            odd := 0;
            y   := y + 1;
            
            if y=200 then
            
              done <= '1';
            
            end if;
          
          end if;
          
        end if;
      
      end if;
    
    end if;
  
  end process p_data_generation;




  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------

  video_1:videocntl
  port map
  (
    resetn     => resetn,             
    clk        => clk,
    -- data                                          
    data_req   => data_req,
    data       => data,
    border     => border,
    --                                               
    hsync      => hsync,
    vsync      => vsync,
    r          => r,
    g          => g,
    b          => b
  );

end architecture testbench;

configuration video_conf of testbench_videocntl is
  for testbench
    for all:videocntl
      use entity work.videocntl(rtl);
    end for;
  end for;
end configuration video_conf;

