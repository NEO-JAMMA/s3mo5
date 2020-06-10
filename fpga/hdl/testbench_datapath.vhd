----------------------------------------------------------------------
--
-- S3MO5 - testbench cpu datapath
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

use work.cpu_package.all;

entity testbench_datapath is
end entity testbench_datapath;

architecture testbench of testbench_datapath is

  component datapath
    port
    (
      -- system
      resetn            :  in std_logic;
      clk               :  in std_logic;
      clken             :  in std_logic;
    
      -- exceptions
      vector            :  in std_logic_vector( 2 downto 0);
    
      -- condition flags
      set_e             :  in std_logic;
      clear_e           :  in std_logic;
      ccr               : out std_logic_vector( 7 downto 0);
    
      -- ALU modes
      alu_mode          :  in t_alu;
    
      -- muxes control
      alu_mux_sel       :  in std_logic_vector( 2 downto 0);
      index_mux_sel     :  in std_logic_vector( 2 downto 0);
      index_add_sel     :  in std_logic;
      addr_mux_sel      :  in std_logic_vector( 2 downto 0);
      bytelane_mux_sel  :  in std_logic;
      allreg_mux_sel    :  in std_logic_vector( 1 downto 0); 
      mr_mux_sel        :  in std_logic_vector( 1 downto 0); 
      
      pc_mux_sel        :  in std_logic_vector( 1 downto 0);
      x_mux_sel         :  in std_logic;
      y_mux_sel         :  in std_logic;
      u_mux_sel         :  in std_logic;
      s_mux_sel         :  in std_logic;
      ea_mux_sel        :  in std_logic;
    
      -- registers control
      ab_en             :  in std_logic_vector( 1 downto 0);
      x_en              :  in std_logic_vector( 1 downto 0);
      y_en              :  in std_logic_vector( 1 downto 0);
      u_en              :  in std_logic_vector( 1 downto 0);
      s_en              :  in std_logic_vector( 1 downto 0);
      mr_en             :  in std_logic;
      pc_en             :  in std_logic_vector( 1 downto 0);
      dp_en             :  in std_logic;
      cc_en             :  in std_logic;
      ea_en             :  in std_logic;
      op_en             :  in std_logic;
      pb_en             :  in std_logic;
   
      -- memory
      addr              : out std_logic_vector(15 downto 0);
      rdata             :  in std_logic_vector( 7 downto 0);
      wdata             : out std_logic_vector( 7 downto 0);
    
      -- opcode
      opcode            : out std_logic_vector( 9 downto 0);
      refetch           : out std_logic;
      postbyte          : out std_logic_vector( 7 downto 0)
    );
  end component;

  
  signal comment0         : string(1 to 16) := "                ";
  signal comment1         : string(1 to 16) := "                ";
  signal resetn          : std_logic;  
  signal clk             : std_logic;  
  signal clken           : std_logic;  

  signal vector          : std_logic_vector( 2 downto 0);
    
  signal set_e           : std_logic;                      
  signal clear_e         : std_logic;                      
  signal ccr             : std_logic_vector(7 downto 0);   
    
  signal alu_mode        : t_alu;  
    
  signal alu_mux_sel     : std_logic_vector( 2 downto 0);   
  signal index_mux_sel   : std_logic_vector( 2 downto 0);   
  signal index_add_sel   : std_logic;   
  signal addr_mux_sel    : std_logic_vector( 2 downto 0);   
  signal bytelane_mux_sel: std_logic;                       
  signal allreg_mux_sel  : std_logic_vector( 1 downto 0);   
  signal mr_mux_sel      : std_logic_vector( 1 downto 0);   
 
  signal ea_mux_sel      : std_logic;   
  signal x_mux_sel       : std_logic;   
  signal y_mux_sel       : std_logic;   
  signal u_mux_sel       : std_logic;   
  signal s_mux_sel       : std_logic;   
  signal pc_mux_sel      : std_logic_vector(1 downto 0);   
    
  signal ab_en           : std_logic_vector( 1 downto 0);  
  signal x_en            : std_logic_vector( 1 downto 0);                      
  signal y_en            : std_logic_vector( 1 downto 0);                      
  signal u_en            : std_logic_vector( 1 downto 0);                      
  signal s_en            : std_logic_vector( 1 downto 0);                      
  signal mr_en           : std_logic;                      
  signal pc_en           : std_logic_vector( 1 downto 0);                      
  signal dp_en           : std_logic;                      
  signal cc_en           : std_logic;                      
  signal ea_en           : std_logic;                      
  signal op_en           : std_logic;                      
    
  signal addr            : std_logic_vector(15 downto 0);  
  signal rdata           : std_logic_vector( 7 downto 0);  
  signal wdata           : std_logic_vector( 7 downto 0);   

  signal refetch         : std_logic;   
  signal opcode          : std_logic_vector( 9 downto 0);   

  signal line_pos        : integer   := 0; 
  signal end_simu        : std_logic := '0';

begin
  
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 105 ns;
    resetn <= '1';
    wait;
  
  end process p_reset_generation;
  
  
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
  
  
  p_stimuli_reader:process(clk,resetn)
  
    file     file_in : text open read_mode is "stimuli/datapath.txt";
    variable line_in : line;
    
    variable tmp     : std_logic_vector(15 downto 0); 
    variable tmp_c   : character; 
    variable tmp_s   : string(1 to 16); 
    variable tmp_pos : integer;
  
  begin
  
    if resetn='0' then
    
    elsif clk'event and clk='1' then
  
    
      tmp_pos := 0;
    
      loop
    
        exit when endfile(file_in);
        
        readline(file_in,line_in);
        read(line_in,tmp_c);
        tmp_pos := tmp_pos + 1;
        
        if tmp_c='C' then
        
          
          read(line_in,tmp_c);
          read(line_in,tmp_s);
          if tmp_c='0' then
          
            comment0 <= tmp_s;
          
          else
          
            comment1 <= tmp_s;
         
          end if;
        
        else
        
          exit when tmp_c='0' or tmp_c='1' ;
        
        end if;
    
      end loop;
    
      line_pos <= line_pos + tmp_pos;
    
      if endfile(file_in) then
    
        end_simu <= '1';
        
      else
    
       if tmp_c='0' then
        
          clken      <= '0';
          
        else
        
          clken      <= '1';
        
        end if;
        

        hread(line_in,tmp(3 downto 0));
        vector         <= tmp(2 downto 0);
       
        read(line_in,tmp(0));
        set_e          <= tmp(0);
 
        read(line_in,tmp(0));
        clear_e        <= tmp(0);
       
        hread(line_in,tmp(3 downto 0));
        ab_en          <= tmp(1 downto 0);
       
        read(line_in,tmp(0));
        mr_en       <= tmp(0);
       
        read(line_in,tmp(0));
        dp_en       <= tmp(0);
    
        read(line_in,tmp(0));
        cc_en       <= tmp(0);

        read(line_in,tmp(0));
        op_en       <= tmp(0);

       
        hread(line_in,tmp(3 downto 0));
        alu_mux_sel       <= tmp(2 downto 0);
       
        hread(line_in,tmp(7 downto 0));
        
        case tmp(4 downto 0) is
        
          when "00000" => alu_mode <= a_plus8;   
          when "00001" => alu_mode <= a_plus8c;  
          when "00010" => alu_mode <= a_plus16;  
          when "00011" => alu_mode <= a_minus8;  
          when "00100" => alu_mode <= a_minus8c;
          when "00101" => alu_mode <= a_minus16; 
          when "00110" => alu_mode <= a_or8;     
          when "00111" => alu_mode <= a_and8;    
          when "01000" => alu_mode <= a_rol8;    
          when "01001" => alu_mode <= a_ror8;    
          when "01010" => alu_mode <= a_asr8;    
          when "01011" => alu_mode <= a_lsl8;    
          when "01100" => alu_mode <= a_lsr8;    
          when "01101" => alu_mode <= a_assign8; 
          when "01110" => alu_mode <= a_assign16;
          when "01111" => alu_mode <= a_tst8;    
          when "10000" => alu_mode <= a_neg8;    
          when "10001" => alu_mode <= a_clr;     
          when "10010" => alu_mode <= a_eor8;    
          when "10011" => alu_mode <= a_com8;    
          when "10100" => alu_mode <= a_inc8;    
          when "10101" => alu_mode <= a_dec8;    
          when "10110" => alu_mode <= a_tstz;    
          when "10111" => alu_mode <= a_sex8;    
          when "11000" => alu_mode <= a_dadj8;   
          when "11011" => alu_mode <= a_assign8_op2;  
          when "11100" => alu_mode <= a_assign16_op2; 
          when others  => alu_mode <= a_nop;  
         
        end case;

        hread(line_in,tmp(3 downto 0));
        addr_mux_sel      <= tmp(2 downto 0);
        
        
        hread(line_in,tmp(3 downto 0));
        index_mux_sel     <= tmp(2 downto 0);
        
        read(line_in,tmp(0));
        index_add_sel     <= tmp(0);
        

        hread(line_in,tmp(3 downto 0));
        pc_mux_sel        <= tmp(1 downto 0);
       
        hread(line_in,tmp(3 downto 0));
        pc_en       <= tmp(1 downto 0);
       
       
        read(line_in,tmp(0));
        x_mux_sel   <= tmp(0);
       
        hread(line_in,tmp(3 downto 0));
        x_en       <= tmp(1 downto 0);
       
        read(line_in,tmp(0));
        y_mux_sel   <= tmp(0);
       
        hread(line_in,tmp(3 downto 0));
        y_en       <= tmp(1 downto 0);
       
        read(line_in,tmp(0));
        u_mux_sel   <= tmp(0);
       
        hread(line_in,tmp(3 downto 0));
        u_en       <= tmp(1 downto 0);
       
        read(line_in,tmp(0));
        s_mux_sel   <= tmp(0);
       
        hread(line_in,tmp(3 downto 0));
        s_en       <= tmp(1 downto 0);
       
        read(line_in,tmp(0));
        ea_mux_sel   <= tmp(0);
       
        read(line_in,tmp(0));
        ea_en       <= tmp(0);

        read(line_in,tmp(0));
        bytelane_mux_sel      <= tmp(0);
        
        hread(line_in,tmp(3 downto 0));
        allreg_mux_sel   <= tmp(1 downto 0);
        
        hread(line_in,tmp(3 downto 0));
        mr_mux_sel   <= tmp(1 downto 0);
        
        hread(line_in,tmp(7 downto 0));
        rdata       <= tmp(7 downto 0);
        
      end if;
      
    end if;
  
  end process p_stimuli_reader;
  
  
  datapath_1:datapath
  port map                                                    
  (                                                        
    -- system
    resetn            => resetn,
    clk               => clk,
    clken             => clken,

    -- exceptions
    vector            => vector,
    
    -- condition flags
    set_e             => set_e,
    clear_e           => clear_e,
    ccr               => ccr,
    
    -- ALU modes
    alu_mode          => alu_mode,
    
    -- muxes control
    alu_mux_sel       => alu_mux_sel,
    index_mux_sel     => index_mux_sel,  
    index_add_sel     => index_add_sel,   
    addr_mux_sel      => addr_mux_sel,   
    bytelane_mux_sel  => bytelane_mux_sel, 
    allreg_mux_sel    => allreg_mux_sel, 
    mr_mux_sel        => mr_mux_sel, 
    
    pc_mux_sel        => pc_mux_sel,
    x_mux_sel         => x_mux_sel,
    y_mux_sel         => y_mux_sel,
    u_mux_sel         => u_mux_sel,
    s_mux_sel         => s_mux_sel,
    ea_mux_sel        => ea_mux_sel,
           
    -- registers control
    ab_en             => ab_en,
    x_en              => x_en,
    y_en              => y_en,
    u_en              => u_en,    
    s_en              => s_en,    
    mr_en             => mr_en,   
    pc_en             => pc_en,   
    dp_en             => dp_en,   
    cc_en             => cc_en,   
    ea_en             => ea_en,   
    op_en             => op_en,
    pb_en             => '0',   
    
    -- memory
    addr              => addr, 
    rdata             => rdata,
    wdata             => wdata,
    
    -- opcode
    opcode            => opcode,
    refetch           => refetch,
    postbyte          => open
  );                                                       

end architecture testbench;

library s3mo5_lib;

configuration datapath_conf of testbench_datapath is
  for testbench
    for all:datapath
      use entity s3mo5_lib.datapath(rtl);
      for rtl
        for all:alu
          use entity s3mo5_lib.alu(rtl);
        end for;
      end for;
    end for;
  end for;
end configuration datapath_conf;
