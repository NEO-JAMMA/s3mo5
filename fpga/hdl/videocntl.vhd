----------------------------------------------------------------------
--
-- S3MO5 - video controller
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
-- VGA 800x600 controller
----------------------------------------------------------------------
-- Resolution:
--
-- VESA 800x600@72Hz Non-Interlaced mode
-- Horizontal Sync = 48kHz
-- Timing: H=(1.12us, 2.40us, 1.28us) V=(0.77ms, 0.13ms, 0.48ms)
--
-- name        clock   horizontal timing     vertical timing      flags
-- "800x600"     50      800  856  976 1040    600  637  643  666  +hsync +vsync
--
-- hcounter range (11 bits)
--
--    0 -   79     border      00000000000 00001001111
--   80 -  719     active x    00001010000 01011001111
--  720 -  799     border      01011010000 01100011111
--  800 -  855     inactive    01100100000 01101010111
--  856 -  975     hsync       01101011000 01111001111
--  976 - 1039     inactive    01111010000 10000001111
--
-- vcounter range (10 bits)
--
--    0 -   99     border      0000000000 0001100011 
--  100 -  499     active y    0001100100 0111110011 
--  500 -  599     border      0111110100 1001010111
--  600 -  636     inactive    1001011000 1001111100  
--  637 -  642     vsync       1001111101 1010000010  
--  643 -  665     inactive    1010000011 1010011001  
--
----------------------------------------------------------------------
-- Color encoding (16 true colors  to  8 dithered colors) 
--
-- no   name               P B G R       RGB sequence    Quality error
--
--  0   noir               0 0 0 0       0 0 0 - 0 0 0   0
--  1   rouge              0 0 0 1       0 0 1 - 0 0 1   0
--  2   vert               0 0 1 0       0 1 0 - 0 1 0   0
--  3   jaune              0 0 1 1       0 1 1 - 0 1 1   0
--  4   bleu               0 1 0 0       1 0 0 - 1 0 0   0
--  5   magenta            0 1 0 1       1 0 1 - 1 0 1   0
--  6   cyan               0 1 1 0       1 1 0 - 1 1 0   0
--  7   blanc              0 1 1 1       1 1 1 - 1 1 1   0
--  8   gris               1 0 0 0       1 1 1 - 0 0 0   3 
--  9   rose               1 0 0 1       0 0 1 - 1 1 1   2
-- 10   vert clair         1 0 1 0       0 1 0 - 1 1 1   2
-- 11   jaune poussin      1 0 1 1       0 1 1 - 1 1 1   1
-- 12   bleu clair         1 1 0 0       1 0 0 - 1 1 1   2 
-- 13   rose parme         1 1 0 1       1 0 1 - 1 1 1   1
-- 14   cyan clair         1 1 1 0       1 1 0 - 1 1 1   1
-- 15   orange             1 1 1 1       0 1 1 - 0 0 1   2
--
-----------------------------------------------------------------------
--
--
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.videocntl_package.all;

entity videocntl is
  port
  (
    -- system
    resetn       :  in std_logic;
    clk          :  in std_logic;
    time_average :  in std_logic;
    -- data
    data_req     : out std_logic;
    data         :  in std_logic_vector(15 downto 0); --pixel&color
    border       :  in std_logic_vector( 3 downto 0);
    -- 
    hsync        : out std_logic; 
    vsync        : out std_logic; 
    r            : out std_logic; 
    g            : out std_logic; 
    b            : out std_logic  
  );
end entity videocntl;

architecture rtl of videocntl is

  signal hcounter         : std_logic_vector(10 downto 0); -- 0 to 2047
  signal vcounter         : std_logic_vector( 9 downto 0); -- 0 to 1023

  signal hsync_i          : std_logic;
  signal vsync_i          : std_logic;
  signal toggle_dither_i  : std_logic;
  
  signal hborder          : std_logic;
  signal vborder          : std_logic;
  signal hactive          : std_logic;
  signal vactive          : std_logic;
  
  signal bgr_i            : std_logic_vector(2 downto 0);
  
  signal pixel_data       : std_logic_vector(7 downto 0);
  signal color_data       : std_logic_vector(7 downto 0);
  
  type  t_color_table     is array(0 to 15) of std_logic_vector(5 downto 0);
  constant color_table    : t_color_table 
    :=("000000","001001","010010","011011",
       "100100","101101","110110","111111",
       "111000","001111","010111","011111",
       "100111","101111","110111","011001");  

begin 
 
  -- ---------------------------------------------------------------------------
  -- Probes
  -- ---------------------------------------------------------------------------
  probe_videocntl_hcounter      <= hcounter;         
  probe_videocntl_vcounter      <= vcounter;         
  probe_videocntl_hsync         <= hsync_i;          
  probe_videocntl_vsync         <= vsync_i;          
  probe_videocntl_toggle_dither <= toggle_dither_i;  
  probe_videocntl_hborder       <= hborder;          
  probe_videocntl_vborder       <= vborder;          
  probe_videocntl_hactive       <= hactive;          
  probe_videocntl_vactive       <= vactive;          
  probe_videocntl_bgr           <= bgr_i;            
  probe_videocntl_pixel_data    <= pixel_data;       
  probe_videocntl_color_data    <= color_data;       
  
  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------
  p_realign:process
  begin
  
    wait until clk'event and clk='1';
    
    hsync <= not hsync_i;
    vsync <= not vsync_i;
    r     <= bgr_i(0);
    g     <= bgr_i(1);
    b     <= bgr_i(2);
  
  end process p_realign;
  
  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------
  p_counters:process(resetn,clk)
  begin
  
    if resetn='0' then
    
      hcounter        <= (others=>'0');
      vcounter        <= (others=>'0');
      hborder         <= '1';
      vborder         <= '1';
      hactive         <= '0';
      vactive         <= '0';
      hsync_i         <= '0';
      vsync_i         <= '0';
      toggle_dither_i <= '0';
    
    elsif clk'event and clk='1' then
    
      hcounter <= hcounter + "00000000001";
    
      case hcounter is

        when "00001001111"=> --   0 -   79   border
        
          hborder  <= '0';
          hactive  <= '1';
          hsync_i  <= '0';
                                  
        when "01011001111"=> --  80 -  719   active x 
        
          hborder  <= '1';
          hactive  <= '0';
          hsync_i  <= '0';
   
        when "01100011111"=> -- 720 -  799   border 
        
          hborder  <= '0';
          hactive  <= '0';
          hsync_i  <= '0';
          
        when "01101010111"=> -- 800 -  855   inactive 
        
          hborder  <= '0';
          hactive  <= '0';
          hsync_i  <= '1';
        
        when "01111001111"=> -- 856 -  975   hsync 
        
          hborder  <= '0';
          hactive  <= '0';
          hsync_i  <= '0';
           
        when "10000001111"=> -- 976 - 1039   inactive 
        
          hborder  <= '1';
          hactive  <= '0';
          hsync_i  <= '0';
          hcounter <= (others=>'0');
          
          vcounter <= vcounter +  "0000000001";
          
          case vcounter is
    
            when "0001100011"=> --   0 -   99     border   
                                   
              vborder  <= '0';   
              vactive  <= '1';   
              vsync_i  <= '0';   
                                   
            when "0111110011"=> -- 100 -  499     active y 
                                   
              vborder  <= '1';   
              vactive  <= '0';   
              vsync_i  <= '0';     
            
            when "1001010111"=> -- 500 -  599     border   
                                   
              vborder  <= '0';   
              vactive  <= '0';   
              vsync_i  <= '0';
              
            when "1001111100"=> -- 600 -  636     inactive 
                                   
              vborder  <= '0';   
              vactive  <= '0';
              vsync_i  <= '1';
              toggle_dither_i <= time_average and (not toggle_dither_i);
            
            when "1010000010"=> -- 637 -  642     vsync    
                                     
              vborder  <= '0';
              vactive  <= '0';
              vsync_i  <= '0';
               
            when "1010011001"=> -- 643 -  665     inactive
            
              vborder  <= '1';
              vactive  <= '0';
              vsync_i  <= '0';
              vcounter <= (others=>'0');
           
            when others=>  
            
              null; 
                                     
          end case; 
        
        when others=>
        
          null;
          
      end case; 

    end if;
  
  end process p_counters;
  
  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------
  
  process(hcounter,vcounter,hborder,vborder,hactive,vactive,
          pixel_data,color_data,border,hsync_i,vsync_i,toggle_dither_i)
  begin
  
    if hactive='1' and vactive='1' then
    
      if (toggle_dither_i xor hcounter(0) xor vcounter(0))='0' then                   
                                                                  
        if pixel_data(7)='1' then
        
          bgr_i <= color_table(conv_integer(color_data(7 downto 4)))(5 downto 3);   
        
        else
        
          bgr_i <= color_table(conv_integer(color_data(3 downto 0)))(5 downto 3);   

        end if;

      else                                                        
      
        if pixel_data(7)='1' then
        
          bgr_i <= color_table(conv_integer(color_data(7 downto 4)))(2 downto 0);   
        
        else
        
          bgr_i <= color_table(conv_integer(color_data(3 downto 0)))(2 downto 0);   

        end if;
                                                                  
      end if;                                                     
    
    else
    
      if (hborder='0' and hactive='0') or                           
         (vborder='0' and vactive='0') or                           
         hsync_i='1' or                                             
         vsync_i='1'                                                
      then                                                          
                                                                    
        bgr_i <= "000";                                             
                                                                    
      else                                                          
                                                                    
        if (toggle_dither_i xor hcounter(0) xor vcounter(0))='0' then                   
                                                                    
          bgr_i <= color_table(conv_integer(border))(5 downto 3);   

        else                                                        
                                                                    
          bgr_i <= color_table(conv_integer(border))(2 downto 0);   
                                                                    
        end if;                                                     
                                                                    
      end if;                                                       
      
    end if;
  
  end process;
  
  -- ---------------------------------------------------------------------------
  -- fifo and serializer
  -- ---------------------------------------------------------------------------
  p_fifo_serializer:process(resetn,clk)
  begin
  
    if resetn='0' then
    
      data_req   <= '0';
      pixel_data <= (others=>'0');
      color_data <= (others=>'0');
    
    elsif clk'event and clk='1' then
    
      if hcounter(3 downto 0)="1111" then
        
        pixel_data <= data(15 downto 8);
        color_data <= data( 7 downto 0);
    
      else
      
        if hactive='1' and vactive='1' and hcounter(3 downto 0)="0000" then
        
          data_req   <= '1';
          
        else
        
          data_req <= '0';
        
        end if;
       
        if hcounter(0)='1' then
        
          pixel_data <= pixel_data(6 downto 0)&'0';
        
        end if;
      
      end if;
      
    end if;
  
  end process p_fifo_serializer;
  
end architecture rtl;

