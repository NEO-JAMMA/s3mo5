----------------------------------------------------------------------
--
-- S3MO5 - keyboard
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
-- MO5 Keyboard map
--
--                                   Column
--
--     | 0      1      2      3      4      5      6      7 
-------+--------------------------------------------------------------
--     |                                                  
--     |                                                      
--   0 | n      eff    j      h      u      y      7      6   
--     |                                           '      &   
--     |                                                      
--     |                                                      
--   1 | ,      ins    k      g      i      t      8      5              
--     | <                                         (      %   
--     |                                                      
--     |                                                      
--   2 | .      hom    l      f      o      r      9      4            
--     | >                                         )      $   
--     |                                                      
--     |
--   3 | @      drt    m      d      p      e      0      3            
--     | ^                                         `      #   
-- r   |                                                      
-- o   |
-- w 4 | spa    bas    b      s      /      z      -      2            
--     |                             ?             =      "   
--     |                                                      
--     |
--   5 | x      gau    v      q      *      a      +      1             
--     |                             :             ;      !   
--     |                                                      
--     |
--   6 | w      hau    c      raz    ent    cnt    acc    stp            
--     |                                                      
--     |                                                      
--     |
--   7 | sft    bsc 
--                                          
----------------------------------------------------------------------
--
--  ps/2 (hex)    MO5 (oct)      ps/2 (hex)    MO5 (oct)     
--                                                
--    12          70                4b             22           
--    e0 11       71                2b             23           
--    1a          60                44             24                                
--    e0 75       61                2d             25                                
--    21          62              S 46             26 (9)                            
--    66          63              S 25             27 (4)                            
--    5a          64                3a             10                                
--    14          65                e0 70          11                                
--    7e          66                42             12                                
--    0e          67                34             13                                
--    22          50                43             14                                
--    e0 6b       51                2c             15                                
--    2a          52              S 3e             16 (8)                            
--    1c          53              S 2e             17 (5)                               
--    5d          54                31             00                                
--    15          55                e0 71          01                                
--  S 55          56                3b             02                                
--  S 16          57 (1)            33             03                                
--    29          40                3c             04                                
--    e0 72       41                35             05                                
--    32          42              S 3d             06 (7)                            
--    1b          43              S 36             07 (6)                             
--  S 49          44                49          70 54                                
--    1d          45                41          70 56                                
--    36          46                4a          70 57                                
--  S 1E          47 (2)          S 3a          70 44                                
--  A 45          30                55          70 46                                
--    e0 74       31                26          70 47                              
--    4c          32              A 46          70 30                                
--    23          33              A 3d          70 36                                
--    4d          34              A 26          70 37                                
--    24          35              S 61          70 10                                
--  S 45          36 (0)          S 25          70 16                                
--  S 26          37 (3)          S 52          70 17                                
--  S 41          20                25          70 06                                                     
--    e0 6c       21                16          70 07                                   
--                                                                    
--
--
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.keyboard_package.all;

entity keyboard is
  port
  (
    -- system
    resetn       :  in std_logic;
    clk          :  in std_logic;
    clken_1ms    :  in std_logic; -- for timeout
    clken_20ms   :  in std_logic; -- for shift press
    -- PS2
    ps2c         :  in std_logic;
    ps2d         :  in std_logic;
    --
    data         : out std_logic_vector( 7 downto 0);
    data_update  : out std_logic;
    key_row      :  in std_logic_vector( 2 downto 0);
    key_column   :  in std_logic_vector( 2 downto 0);
    key_hit      : out std_logic;
    --
    key_esc      : out std_logic   
  );
end entity keyboard;

architecture rtl of keyboard is

  signal ps2c_1t           : std_logic;                     
  signal ps2c_2t           : std_logic;                     
  signal ps2c_3t           : std_logic;                     
  signal count             : std_logic_vector( 3 downto 0); 
  signal shift             : std_logic_vector(10 downto 0); 
  signal parity            : std_logic;                     
  signal timeout_state     : std_logic;                     
  signal data_i            : std_logic_vector( 7 downto 0); 
  signal data_update_i     : std_logic; 
  signal ps2_shift_pressed : std_logic; 
  signal ps2_alt_pressed   : std_logic; 
  signal ps2_key_released  : std_logic; 
  signal ps2_key_pressed   : std_logic; 
  signal mo5_key_state     : t_mo5_key_state; 
  signal mo5_shift_pressed : std_logic; 
  signal key_decoded       : std_logic_vector(6 downto 0); 

begin

  -- --------------------------------------------------------------------
  -- Probes 
  -- --------------------------------------------------------------------
  probe_keyboard_ps2c_1t           <= ps2c_1t;          
  probe_keyboard_ps2c_2t           <= ps2c_2t;          
  probe_keyboard_ps2c_3t           <= ps2c_3t;          
  probe_keyboard_count             <= count;            
  probe_keyboard_shift             <= shift;            
  probe_keyboard_parity            <= parity;           
  probe_keyboard_timeout_state     <= timeout_state;    
  probe_keyboard_data              <= data_i;           
  probe_keyboard_data_update       <= data_update_i;    
  probe_keyboard_ps2_shift_pressed <= ps2_shift_pressed;
  probe_keyboard_ps2_alt_pressed   <= ps2_alt_pressed;  
  probe_keyboard_ps2_key_released  <= ps2_key_released; 
  probe_keyboard_ps2_key_pressed   <= ps2_key_pressed;  
  probe_keyboard_mo5_key_state     <= mo5_key_state;    
  probe_keyboard_mo5_shift_pressed <= mo5_shift_pressed;
  probe_keyboard_key_decoded       <= key_decoded;      

  -- --------------------------------------------------------------------
  -- assignments 
  -- --------------------------------------------------------------------
  data        <= data_i;
  data_update <= data_update_i;

  -- --------------------------------------------------------------------
  -- mo5 key hit 
  -- --------------------------------------------------------------------
  p_mo5_key_hit:process(key_row,key_column,key_decoded,mo5_shift_pressed,
                        mo5_key_state)
  begin
  
    if key_row="111" and key_column="000" and 
       mo5_shift_pressed='1' 
    then
    
      key_hit <= '0';
      
    else
    
      if key_row=key_decoded(5 downto 3) and 
         key_column=key_decoded(2 downto 0) and 
         mo5_key_state=s_press_key
      then
      
        key_hit <= '0';
        
      else
      
        key_hit <= '1';
      
      end if;
    
    end if;
  
  end process p_mo5_key_hit;

  -- --------------------------------------------------------------------
  -- parity 
  -- --------------------------------------------------------------------

  parity <= shift(1) xor shift(2) xor shift(3) xor shift(4) xor
            shift(5) xor shift(6) xor shift(7) xor shift(8) xor
            shift(9);
  
  -- --------------------------------------------------------------------
  -- deserialiser 
  -- --------------------------------------------------------------------
  p_deserialiser:process(resetn,clk)
  begin
  
    if resetn='0' then
    
      ps2c_1t       <= '0';
      ps2c_2t       <= '0';
      ps2c_3t       <= '0';
      count         <= "0000";
      key_esc       <= '0';
      data_i        <= (others=>'0');
      data_update_i <= '0';
      timeout_state <= '0';
      
    elsif clk'event and clk='1' then
    
      key_esc       <= '0';
      data_update_i <= '0';
      ps2c_1t       <= ps2c;
      ps2c_2t       <= ps2c_1t;
      ps2c_3t       <= ps2c_2t;
      
      if ps2c_3t='1' and ps2c_2t='0' then
      
        timeout_state <= '0';
        shift         <= ps2d&shift(10 downto 1);
        
        if count="1011" then
        
          count <= "0000";
          
        else
        
          count <= count + "0001";
          
        end if;
        
      else
      
        if clken_1ms='1' then
        
          if timeout_state='0' then
        
            timeout_state <= '1';
              
          else
            
            timeout_state <= '0';
            count         <= "0000";
        
          end if;
      
        end if;
      
      end if;
      
      if count="1011" and ps2c_3t='0' and ps2c_2t='1' and 
         shift(0)='0' and shift(10)='1' and parity='1' 
      then
        
        if shift(8 downto 1)/="11100000" then 
        
          data_i        <= shift(8 downto 1); 
          data_update_i <= '1';     
         
          if shift(8 downto 1)="01110110" then
          
            key_esc <= '1';
            
          end if;                 
        
        end if;
        
        count <= "0000";              
         
      end if;
   
    end if;
  
  end process p_deserialiser;
  
  -- --------------------------------------------------------------------
  -- key decoder 
  -- --------------------------------------------------------------------
  p_decoder:process
  
   variable index : std_logic_vector(9 downto 0);
  
  begin
    wait until clk'event and clk='1';
    
    index := ps2_alt_pressed&ps2_shift_pressed&data_i;
    
    case index is
    
      when "0000000000"=> key_decoded <= "0111000";
      when "0000011010"=> key_decoded <= "0110000";
      when "0001110101"=> key_decoded <= "0110001";
      when "0000100001"=> key_decoded <= "0110010";
      when "0001100110"=> key_decoded <= "0110011";
      when "0001011010"=> key_decoded <= "0110100";
      when "0000010100"=> key_decoded <= "0110101";
      when "0001111110"=> key_decoded <= "0110110";
      when "0000001110"=> key_decoded <= "0110111";
      when "0000100010"=> key_decoded <= "0101000";
      when "0001101011"=> key_decoded <= "0101001";
      when "0000101010"=> key_decoded <= "0101010";
      when "0000011100"=> key_decoded <= "0101011";
      when "0001011101"=> key_decoded <= "0101100";
      when "0000010101"=> key_decoded <= "0101101";
      when "0101010101"=> key_decoded <= "0101110";
      when "0100010110"=> key_decoded <= "0101111";
      when "0000101001"=> key_decoded <= "0100000";
      when "0001110010"=> key_decoded <= "0100001";
      when "0000110010"=> key_decoded <= "0100010";
      when "0000011011"=> key_decoded <= "0100011";
      when "0101001001"=> key_decoded <= "0100100";
      when "0000011101"=> key_decoded <= "0100101";
      when "0000110110"=> key_decoded <= "0100110";
      when "0100011110"=> key_decoded <= "0100111";
      when "1001000101"=> key_decoded <= "0011000";
      when "0101000101"=> key_decoded <= "0011110";
      when "0001110100"=> key_decoded <= "0011001";
      when "0001001100"=> key_decoded <= "0011010";
      when "0000100011"=> key_decoded <= "0011011";
      when "0001001101"=> key_decoded <= "0011100";
      when "0000100100"=> key_decoded <= "0011101";
      when "0100100110"=> key_decoded <= "0011111";
      when "0101000001"=> key_decoded <= "0010000";
      when "0001101100"=> key_decoded <= "0010001";
      when "0001001011"=> key_decoded <= "0010010";
      when "0000101011"=> key_decoded <= "0010011";
      when "0001000100"=> key_decoded <= "0010100";
      when "0000101101"=> key_decoded <= "0010101";
      when "0101000110"=> key_decoded <= "0010110";
      when "0100100101"=> key_decoded <= "0010111";
      when "0000111010"=> key_decoded <= "0001000";
      when "0001110000"=> key_decoded <= "0001001";
      when "0001000010"=> key_decoded <= "0001010";
      when "0000110100"=> key_decoded <= "0001011";
      when "0001000011"=> key_decoded <= "0001100";
      when "0000101100"=> key_decoded <= "0001101";
      when "0100111110"=> key_decoded <= "0001110";
      when "0100101110"=> key_decoded <= "0001111";
      when "0000110001"=> key_decoded <= "0000000";
      when "0001110001"=> key_decoded <= "0000001";
      when "0000111011"=> key_decoded <= "0000010";
      when "0000110011"=> key_decoded <= "0000011";
      when "0000111100"=> key_decoded <= "0000100";
      when "0000110101"=> key_decoded <= "0000101";
      when "0100111101"=> key_decoded <= "0000110";
      when "1000111101"=> key_decoded <= "1011110";
      when "0100110110"=> key_decoded <= "0000111";
      when "0001001001"=> key_decoded <= "1101100";
      when "0001000001"=> key_decoded <= "1101110";
      when "0001001010"=> key_decoded <= "1101111";
      when "0100111010"=> key_decoded <= "1100100";
      when "0001010101"=> key_decoded <= "1100110";
      when "1001000110"=> key_decoded <= "1011000";
      when "1000100110"=> key_decoded <= "1011111";
      when "0101100001"=> key_decoded <= "1010000";
      when "0001100001"=> key_decoded <= "1001000";
      when "0000101110"=> key_decoded <= "1001110";
      when "0101010010"=> key_decoded <= "1001111";
      when "0000100101"=> key_decoded <= "1000110";
      when "0000010110"=> key_decoded <= "1000111";
      when "0000100110"=> key_decoded <= "1100111";
      when "0001001110"=> key_decoded <= "1010110";
      when "0001011011"=> key_decoded <= "1010111";
      when others=>       key_decoded <= "0111000";
    
    end case;
  
  end process p_decoder;
  
  -- --------------------------------------------------------------------
  -- key scan 
  -- --------------------------------------------------------------------
  p_scan:process(resetn,clk)
  begin
   
    if resetn='0' then
    
      ps2_shift_pressed <= '0';
      ps2_alt_pressed   <= '0';
      ps2_key_pressed   <= '0';
      ps2_key_released  <= '0';

      mo5_key_state     <= s_idle;    
      mo5_shift_pressed <= '0';    

    elsif clk'event and clk='1' then
  
      -- -----------------------------------------------------------------------
      -- key status
      -- -----------------------------------------------------------------------
      if data_update_i='1' then
       
        ps2_key_released <= '0';
        
        -- ---------------------------------------------------------------------
        -- Key release FSM
        -- ---------------------------------------------------------------------
        case data_i is
        
          when "11110000"=> -- release
          
            ps2_key_released <= '1';
            
          when "01011001"|"00010010"=> -- SHIFT
          
            if ps2_key_released='1' then
             
               ps2_shift_pressed <= '0';
               
             else
               
               ps2_shift_pressed <= '1';
             
             end if;
          
          when "00010001"=> -- ALT
        
            if ps2_key_released='1' then
          
              ps2_alt_pressed <= '0';
              
            else
              
              ps2_alt_pressed <= '1';
          
            end if;
          
          when others=>
          
            if ps2_key_released='1' then
            
              ps2_key_pressed <= '0';
            
            else
            
              ps2_key_pressed <= '1';
            
            end if;

        end case;
        
      end if;
      
      -- -----------------------------------------------------------------------
      -- Key sequencer
      -- -----------------------------------------------------------------------
      case mo5_key_state is
      
        when s_idle=>
        
          if ps2_key_pressed='1' then
          
            if key_decoded(6)='1' then
            
              mo5_key_state <= s_press_shift0;
            
            else
            
              mo5_key_state <= s_press_key;
            
            end if;
          
          end if;
        
        when s_press_shift0=>
        
          if clken_20ms='1' then
          
            mo5_key_state     <= s_press_shift1;
            mo5_shift_pressed <= '1';
          
          end if;
        
        when s_press_shift1 =>
        
          if clken_20ms='1' then
          
            mo5_key_state     <= s_press_shift2;
          
          end if;
   
        when s_press_shift2 =>
        
          if clken_20ms='1' then
          
            mo5_key_state     <= s_press_key;
          
          end if;
        
        when s_press_key =>
        
          if ps2_key_pressed='0' then
          
            mo5_key_state     <= s_idle;
            mo5_shift_pressed <= '0';
          
          end if;
      
      end case;
  
    end if;
  
  end process p_scan;
  
end architecture rtl;
