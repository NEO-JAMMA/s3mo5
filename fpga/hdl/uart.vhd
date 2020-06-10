----------------------------------------------------------------------
--
-- S3MO5 - uart
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart is
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
end entity uart;

architecture rtl of uart is

 -- RX
 type t_rx_state is (s_idle,s_receive,s_done,s_stop);
 signal rx_state        : t_rx_state;
 signal rx_sr           : std_logic_vector( 8 downto 0);
 signal phase_counter   : std_logic_vector( 1 downto 0);
 signal best_phase      : std_logic_vector( 1 downto 0);
 signal sr_counter      : std_logic_vector( 3 downto 0);
 signal phase_eval      : std_logic_vector( 3 downto 0);
 -- TX
 type t_tx_state is (s_idle,s_send,s_done);
 signal tx_state        : t_tx_state;
 signal tx_sr           : std_logic_vector( 9 downto 0);
 signal tx_counter      : std_logic_vector( 3 downto 0);

begin

  -- ---------------------------------------------------------------------------
  -- RX
  -- ---------------------------------------------------------------------------
  p_rx_fsm:process(clk,resetn)
  begin
  
    if resetn='0' then
    
      phase_counter <= "00";
      sr_counter    <= "0000";
      phase_eval    <= "1111";
      valid         <= '0';
      data_out      <= (others=>'0');
      best_phase    <= "00";
      rx_sr         <= (others=>'0');
      rx_state      <= s_idle;
    
    elsif clk'event and clk='1' then
    
      -- generate 4 clock phases for optimal sampling
      if clken='1' then
      
        phase_counter <= phase_counter + "01";
      
        case phase_counter is
      
          when "00"=>   phase_eval(0) <= rx;
          when "01"=>   phase_eval(1) <= rx;
          when "10"=>   phase_eval(2) <= rx;
          when others=> phase_eval(3) <= rx;
      
        end case;
        
      end if;
      
      -- RX fsm
      case rx_state is
      
        -- ---------------------------------------------------------------------
        -- Scrutinize the phase_eval stage for any event. When a change happen,
        -- choose 2 phase later for optimal sampling
        -- ---------------------------------------------------------------------
        when s_idle=>
        
          sr_counter <= "1000";
          valid      <= '0';
          
          case phase_eval is
          
            when "1110"=>
            
              best_phase <= "10";
              rx_state   <= s_receive;
            
            when "1101"=>

              best_phase <= "11";
              rx_state   <= s_receive;
            
            when "1011"=>
 
              best_phase <= "00";
              rx_state   <= s_receive;
           
            when "0111"=>
         
              best_phase <= "01";
              rx_state   <= s_receive;
           
            when others=>
            
              null;
          
          end case;
          
        -- ---------------------------------------------------------------------
        -- Fill the rx shift register
        -- ---------------------------------------------------------------------
        when s_receive=>
        
          if clken='1' then
          
            if best_phase=phase_counter then
          
              rx_sr      <= rx&rx_sr(8 downto 1);
            
              if sr_counter="0000" then
            
                rx_state <= s_done;
            
              else
            
                sr_counter <= sr_counter + "1111";
              
               end if;
          
            end if;
            
          end if;
          
        -- ---------------------------------------------------------------------
        -- Evaluate the result
        -- ---------------------------------------------------------------------
        when s_done=>
        
          data_out <= rx_sr(8 downto 1);
          valid    <= '1';
          rx_state <= s_stop;
        
        -- ---------------------------------------------------------------------
        -- Skip the bit stop
        -- ---------------------------------------------------------------------
        when s_stop=>
            
           valid <= '0';
           if phase_eval="1111" then
           
             rx_state <= s_idle;
             
           end if;
             
      end case;
    
    end if;
  
  end process p_rx_fsm;
  
  -- ---------------------------------------------------------------------------
  -- TX
  -- ---------------------------------------------------------------------------
  p_tx_fsm:process(clk,resetn)
  begin
  
    if resetn='0' then
    
      tx_state   <= s_idle;
      tx         <= '1';
      busy       <= '0';
      tx_sr      <= (others=>'1');
      tx_counter <= (others=>'0');
      
    elsif clk'event and clk='1' then
    
      case tx_state is
      
        when s_idle=>
        
          busy <= '0';
          
          if wen='1' then
          
            busy              <= '1';
            tx_sr(8 downto 1) <= data_in;
            tx_sr(0)          <= '0';
            tx_sr(9)          <= '1';
            tx_counter        <= "1001";
            
            tx_state          <= s_send;
            
          end if;
        
        when s_send=>
        
          if clken='1' then
          
            if phase_counter="00" then
          
              tx <= tx_sr(0);
              tx_sr <= '1'&tx_sr(9 downto 1);
          
              if tx_counter="0000" then
              
                tx_state   <= s_done;
              
              else
              
                tx_counter <= tx_counter + "1111";
              
              end if;
          
            end if;
            
          end if;
      
        when s_done=>
        
          if clken='1' and phase_counter="00" then
          
            tx_state <= s_idle;
          
          end if;
      
      end case;
    
    end if;
  
  end process p_tx_fsm;

end architecture rtl;
