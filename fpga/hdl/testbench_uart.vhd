----------------------------------------------------------------------
--
-- S3MO5 - testbnech uart
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
library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

entity testbench_uart is
end entity testbench_uart;

architecture testbench of testbench_uart is

  component uart
    port
    (
      -- system
      resetn   :  in std_logic;
      clk      :  in std_logic;
      clken    :  in std_logic;
      
      -- tx
      wen      :  in std_logic;
      data_in  :  in std_logic_vector(7 downto 0);
      busy     : out std_logic;
      tx       : out std_logic;
      
      -- rx
      rx       :  in std_logic;
      data_out : out std_logic_vector(7 downto 0);
      valid    : out std_logic
    );
  end component;

  signal resetn   : std_logic;
  signal clk      : std_logic;
  signal clken    : std_logic;
  signal wen      : std_logic;
  signal data_in  : std_logic_vector(7 downto 0);
  signal busy     : std_logic;
  signal tx       : std_logic;
  signal rx       : std_logic;
  signal data_out : std_logic_vector(7 downto 0);
  signal valid    : std_logic;
  
  signal end_simu_rx : std_logic := '0';
  signal end_simu_tx : std_logic := '0';
  signal end_simu    : std_logic := '0';

begin

  end_simu <= end_simu_tx and end_simu_rx;

  -- ---------------------------------------------------------------------------
  -- reset generation
  -- ---------------------------------------------------------------------------
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 505 ns;
    resetn <= '1';
    wait;
  
  end process p_reset_generation;

  -- ---------------------------------------------------------------------------
  -- clock generation (25 MHz)
  -- ---------------------------------------------------------------------------
  p_clock_generation:process
  begin
  
    if end_simu='1' then
    
      wait;
      
    else
    
      clk <= '0';
      wait for 20 ns;
      clk <= '1';
      wait for 20 ns;
    
    end if;
  
  end process p_clock_generation;
 
  -- ---------------------------------------------------------------------------
  -- clock enable generation (every 2.17 us for 115200 bit/s) 
  --------------------------------------------------------------------------
  p_clken_generation:process(clk,resetn)
  
    variable counter : integer;
  
  begin
  
    if resetn='0' then
    
      clken   <= '0';
      counter := 0;
    
    elsif clk'event and clk='1' then
    
      if counter=54 then
      
        counter := 0;
        clken   <= '1';
        
      else
      
        counter := counter + 1;
        clken   <= '0';
      
      end if;
    
    
    end if;
  
  end process p_clken_generation;

  -- ---------------------------------------------------------------------------
  -- RX path stimuli generation
  -- ---------------------------------------------------------------------------
  p_rx_stimuli_generation:process
  
    file file_in      : text open read_mode is "./stimuli/uart_rx.txt";
    variable line_in  : line;
    
    variable tmp_v    : std_logic_vector(31 downto 0);
    variable tmp_c    : character;
    variable tmp_time : time;
  
  begin
  
    loop
    
      exit when endfile(file_in);
      
      readline(file_in,line_in);
      read(line_in,tmp_c);
      
      exit when tmp_c='E' or
                tmp_c='W' or
                tmp_c='D';
    
    end loop;
  
    if endfile(file_in) then
    
      end_simu_rx <= '1';
      wait;
      
    else
    
      case tmp_c is
      
        when 'E'=>
        
          end_simu_rx <= '1';
          wait;
          
        when 'W'=>
        
          read(line_in,tmp_time);
          wait for tmp_time;
          
        when 'D'=>
        
          read(line_in,tmp_v(0));
          rx <= tmp_v(0);
          wait for 0 ns;
          
        when others=>
        
          assert false
              report "error: unknown command "
                 severity failure;
              
      
      end case;
    
    end if;
  
  end process p_rx_stimuli_generation;
 
  -- ---------------------------------------------------------------------------
  -- TX path stimuli generation
  -- ---------------------------------------------------------------------------
  p_tx_stimuli_generation:process(clk,resetn)
  
    file file_in      : text open read_mode is "./stimuli/uart_tx.txt";
    variable line_in  : line;
    
    variable tmp_v    : std_logic_vector(31 downto 0);
    variable tmp_c    : character;
    variable tmp_wait : integer;
  
  begin
  
    if resetn='0' then
    
      wen      <= '0';
      data_in  <= (others=>'0');
      tmp_wait := 0;
      
    elsif clk'event and clk='1' then
    
      wen <= '0';
      
      if tmp_wait/=0 then
      
        tmp_wait := tmp_wait - 1;
        
      elsif busy='1' then
      
        null;
      
      else
      
        loop
    
          exit when endfile(file_in);
          
          readline(file_in,line_in);
          read(line_in,tmp_c);
          
          exit when tmp_c='E' or
                    tmp_c='W' or
                    tmp_c='D';
    
        end loop;
    
        if endfile(file_in) then
  
          end_simu_tx <= '1';
          
        else
    
          case tmp_c is
          
            when 'E'=>
            
              end_simu_tx <= '1';
              
            when 'W'=>
            
              read(line_in,tmp_wait);
            
            when 'D'=>
            
              hread(line_in,tmp_v(7 downto 0));
              data_in <= tmp_v(7 downto 0);
              wen     <= '1';
              
            when others=>
            
              assert false
                  report "error: unknown command "
                     severity failure;
                  
          
          end case;
    
        end if;
        
      end if;
    
    end if;
    
  end process p_tx_stimuli_generation;
 
  
  
  

  -- ---------------------------------------------------------------------------
  -- UART instance
  -- ---------------------------------------------------------------------------
  uart_0:uart
  port map
  (
    -- system
    resetn   => resetn,
    clk      => clk,
    clken    => clken,
    
    -- tx
    wen      => wen,
    data_in  => data_in,
    busy     => busy,
    tx       => tx,
    
    -- rx
    rx       => rx,
    data_out => data_out,
    valid    => valid
  );

end architecture testbench;

library uart_lib;

configuration uart_conf of testbench_uart is
  for testbench
    for all:uart
      use entity uart_lib.uart(rtl);
    end for;
  end for;
end configuration uart_conf;
