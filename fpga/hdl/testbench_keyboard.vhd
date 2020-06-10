----------------------------------------------------------------------
--
-- S3MO5 - testbench keyboard
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

entity testbench_keyboard is
end entity testbench_keyboard;

architecture testbench of testbench_keyboard is

  component keyboard
    port
    (
      -- system
      resetn       :  in std_logic;
      clk          :  in std_logic;
      clken        :  in std_logic;
      -- PS2
      ps2c         :  in std_logic;
      ps2d         :  in std_logic;
      -- output
      data         : out std_logic_vector( 7 downto 0);
      data_update  : out std_logic;
      key_row      :  in std_logic_vector( 2 downto 0);
      key_column   :  in std_logic_vector( 2 downto 0);
      key_hit      : out std_logic;
      --
      key_f1       : out std_logic;
      key_f12      : out std_logic;
      key_esc      : out std_logic   
    );
  end component;
  
  
  signal clk         : std_logic;
  signal clken       : std_logic;
  signal resetn      : std_logic;
  signal ps2c        : std_logic :='1';
  signal ps2d        : std_logic :='1';
  signal data        : std_logic_vector( 7 downto 0);
  signal data_update : std_logic;
  signal key_row     : std_logic_vector( 2 downto 0);
  signal key_column  : std_logic_vector( 2 downto 0);
  signal key_scan    : std_logic_vector( 8 downto 0);
  signal key_hit     : std_logic;
  signal key_f1      : std_logic;
  signal key_f12     : std_logic;
  signal key_esc     : std_logic;
  signal done        : std_logic :='0';

begin 

  -- ---------------------------------------------------------------------------
  -- reset generation
  -- ---------------------------------------------------------------------------
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 255 ns;
    resetn <= '1';
    wait;
  
  end process p_reset_generation;
  
  -- ---------------------------------------------------------------------------
  -- 50 MHz clock generation
  -- ---------------------------------------------------------------------------
  p_clock50m_generation:process
  begin
  
    if done='1' then
    
      wait;
    
    else
    
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    
    end if;
  
  end process p_clock50m_generation;
  
  -- ---------------------------------------------------------------------------
  -- 50 kHz clock enable
  -- ---------------------------------------------------------------------------
  p_clk50ken_generation:process(clk,resetn)
  
    variable divider  : integer :=0;
  
  begin
  
    if resetn='0' then
    
      divider := 0;
    
    elsif clk'event and clk='1' then
    
      if divider=50000 then
    
        clken   <= '1';
        divider := 0;
        
      else
      
        clken   <= '0';
        divider := divider + 1;
      
      end if;
    
    end if;
  
  end process p_clk50ken_generation;

  -- ---------------------------------------------------------------------------
  -- keyboard scan
  -- ---------------------------------------------------------------------------
  p_keyboard_scan:process(resetn,clk)
  begin
  
    if resetn='0' then
    
      key_scan <= "000000000";
      
    
    elsif clk'event and clk='1' then
  
      key_scan <= key_scan + "000000001";
    
    end if;
  
  end process p_keyboard_scan;

  key_column <= key_scan(5 downto 3);
  key_row    <= key_scan(8 downto 6);
 
  -- ---------------------------------------------------------------------------
  -- send data
  -- ---------------------------------------------------------------------------
  p_data_generation:process
  
    file  file_in    : text open read_mode is "./stimuli/tb_keyboard_ps2.txt";
    variable line_in : line;
    variable tmp_c   : character;
    variable tmp_t   : time;
    variable tmp8    : std_logic_vector( 7 downto 0);
    variable parity  : std_logic;
  
  begin
  
    loop                                   
                                           
      readline(file_in,line_in);           
      exit when endfile(file_in);          
                                           
      read(line_in,tmp_c);                 
      exit when tmp_c='K' or               
                tmp_c='W' or               
                tmp_c='E';                 
                                           
    end loop;                              
                                           
    if not endfile(file_in) then           
                                           
      case tmp_c is                        
                                           
        when 'W'=>                         
                                           
          read(line_in,tmp_t);             
          wait for tmp_t;                  
                                           
        when 'K'=>                         
                                           
          hread(line_in,tmp8);             
                                           
          -- start                         
          ps2d <= '0';                     
          wait for 20 us;                  
          ps2c <= '0';                     
          wait for 40 us;                  
          ps2c <= '1';                     
          wait for 20 us;                  
                                           
          parity := '0';                   
                                           
          for i in 0 to 7 loop             
                                           
            parity := parity xor tmp8(i);  
            ps2d <= tmp8(i);               
            wait for 20 us;                
            ps2c <= '0';                   
            wait for 40 us;                
            ps2c <= '1';                   
            wait for 20 us;                
                                           
          end loop;                        
                                           
          -- parity                        
          ps2d <= not parity;                  
          wait for 20 us;                  
          ps2c <= '0';                     
          wait for 40 us;                  
          ps2c <= '1';                     
          wait for 20 us;                  
                                           
          -- stop                          
          ps2d <= '1';                     
          wait for 20 us;                  
          ps2c <= '0';                     
          wait for 40 us;                  
          ps2c <= '1';                     
          wait for 20 us;                  
                                           
        when others=>                      
                                           
         done <= '1';                      
         ps2c <= '1';                      
         ps2d <= '1';                      
         wait;                             
                                           
      end case;                            
                                           
    else                                   
                                           
      done <= '1';                         
      ps2c <= '1';                         
      ps2d <= '1';                         
      wait;                                
                                           
    end if;                                
  
  end process p_data_generation;

  -- ---------------------------------------------------------------------------
  -- keyboard controller instance
  -- ---------------------------------------------------------------------------
  keybord0:keyboard
  port map
  (                                                  
    resetn      => resetn,
    clk         => clk,
    clken       => clken,
    ps2c        => ps2c,
    ps2d        => ps2d,
    data        => data,
    data_update => data_update,
    key_row     => key_row,
    key_column  => key_column,
    key_hit     => key_hit,
    key_f1      => key_f1,
    key_f12     => key_f12,
    key_esc     => key_esc
  );                                                 

end architecture testbench;

configuration keyboard_conf of testbench_keyboard is
  for testbench
    for all:keyboard
      use entity work.keyboard(rtl);
    end for;
  end for;
end configuration keyboard_conf;

