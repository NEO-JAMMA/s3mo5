----------------------------------------------------------------------
--
-- S3MO5 - testbench cpu6809
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

library s3mo5_lib;
use s3mo5_lib.cpu_package.all;

entity testbench_cpu is
end entity testbench_cpu;

architecture testbench of testbench_cpu is

  component cpu6809
    port
    (
       -- system
       resetn   :  in std_logic;
       clk      :  in std_logic;
       clken    :  in std_logic;
       -- interruptions
       nnmi     :  in std_logic;
       nirq     :  in std_logic;
       nfiq     :  in std_logic;
       -- memory
       busreq   : out std_logic;
       write    : out std_logic;
       addr     : out std_logic_vector(15 downto 0);
       rdata    :  in std_logic_vector( 7 downto 0);
       wdata    : out std_logic_vector( 7 downto 0)
    );
  end component;

  signal line_pos            : integer := 0;                          
  signal end_simu            : std_logic := '0';                      
  
  -- from cpu
  signal resetn              : std_logic;                             
  signal clk                 : std_logic;                             
  signal clken               : std_logic;                             

  signal nnmi                : std_logic := '1';                      
  signal nirq                : std_logic := '1';                      
  signal nfiq                : std_logic := '1';                      
    
  signal busreq              : std_logic;                             
  signal write               : std_logic;                             
  signal addr                : std_logic_vector(15 downto 0);         
  signal rdata               : std_logic_vector( 7 downto 0);         
  signal wdata               : std_logic_vector( 7 downto 0);         

  signal cc_e                : std_logic;                             
  signal cc_f                : std_logic;                             
  signal cc_h                : std_logic;                             
  signal cc_i                : std_logic;                             
  signal cc_n                : std_logic;                             
  signal cc_z                : std_logic;                             
  signal cc_v                : std_logic;                             
  signal cc_c                : std_logic;                             
  
  -- from reference
  
  signal addr_fail           : std_logic;
  signal rdata_fail          : std_logic;
  signal wdata_fail          : std_logic;
  signal registers_fail      : std_logic;
  signal skip_register_check : std_logic;
  signal ref_instr_counter   : integer := 0;
  signal ref_instr_cycles    : integer := 0;
  
  signal ref_addr            : std_logic_vector(15 downto 0);       
  signal ref_rdata           : std_logic_vector( 7 downto 0);       
  signal ref_wdata           : std_logic_vector( 7 downto 0);       
  signal failure_detected    : std_logic := '0';       
  
  signal ref_a               : std_logic_vector( 7 downto 0);       
  signal ref_b               : std_logic_vector( 7 downto 0);       
  signal ref_x               : std_logic_vector(15 downto 0);       
  signal ref_y               : std_logic_vector(15 downto 0);       
  signal ref_u               : std_logic_vector(15 downto 0);       
  signal ref_s               : std_logic_vector(15 downto 0);       
  signal ref_cc              : std_logic_vector( 7 downto 0);       
  signal ref_dp              : std_logic_vector( 7 downto 0);       
  signal ref_pc              : std_logic_vector(15 downto 0);       
  
begin


  cc_e <= probe_cc(7);
  cc_f <= probe_cc(6);
  cc_h <= probe_cc(5);
  cc_i <= probe_cc(4);
  cc_n <= probe_cc(3);
  cc_z <= probe_cc(2);
  cc_v <= probe_cc(1);
  cc_c <= probe_cc(0);

  
  rdata <= ref_rdata when busreq='1' and write='0' else
           (others=>'X');
  
  p_clken_generation:process
  
    variable counter : integer := 0;
  
  begin
    wait until clk'event and clk='1';
    
    if counter=10 then
    
      clken   <= '0';
      counter := 0;
      
    else
    
      clken   <= '1';
      counter := counter + 1;
  
    end if;
  
  
  end process p_clken_generation;
  

  p_check:process(resetn,clk)
  
    variable line_out : line;
    
    procedure dump_cpu_registers is
    begin
      std.textio.write(line_out,string'("CPU registers"));
      std.textio.writeline(output,line_out);
      
      std.textio.write(line_out,string'("A="));
      hwrite(line_out,probe_a);
      std.textio.write(line_out,string'(" B="));
      hwrite(line_out,probe_b);
      std.textio.write(line_out,string'(" X="));
      hwrite(line_out,probe_x);
      std.textio.write(line_out,string'(" Y="));
      hwrite(line_out,probe_y);
      std.textio.write(line_out,string'(" U="));
      hwrite(line_out,probe_u);
      std.textio.write(line_out,string'(" S="));
      hwrite(line_out,probe_s);
      std.textio.write(line_out,string'(" PC="));
      hwrite(line_out,probe_pc);
      std.textio.write(line_out,string'(" CC="));
      hwrite(line_out,probe_cc);
      std.textio.write(line_out,string'(" DP="));
      hwrite(line_out,probe_dp);
      writeline(output,line_out);
    
    end procedure dump_cpu_registers;
   
    procedure dump_model_registers is
    begin
      std.textio.write(line_out,string'("Model registers"));
      std.textio.writeline(output,line_out);
      
      std.textio.write(line_out,string'("A="));
      hwrite(line_out,ref_a);
      std.textio.write(line_out,string'(" B="));
      hwrite(line_out,ref_b);
      std.textio.write(line_out,string'(" X="));
      hwrite(line_out,ref_x);
      std.textio.write(line_out,string'(" Y="));
      hwrite(line_out,ref_y);
      std.textio.write(line_out,string'(" U="));
      hwrite(line_out,ref_u);
      std.textio.write(line_out,string'(" S="));
      hwrite(line_out,ref_s);
      std.textio.write(line_out,string'(" PC="));
      hwrite(line_out,ref_pc);
      std.textio.write(line_out,string'(" CC="));
      hwrite(line_out,ref_cc);
      std.textio.write(line_out,string'(" DP="));
      hwrite(line_out,ref_dp);
      writeline(output,line_out);
    
    end procedure dump_model_registers;
  
  begin
    
    if resetn='0' then
    
      addr_fail           <= '0';
      rdata_fail          <= '0';
      wdata_fail          <= '0';
      registers_fail      <= '0';
      skip_register_check <= '0';
    
    elsif clk'event and clk='1' then
    
      addr_fail  <= '0';                                                                              
      rdata_fail <= '0';                                                                              
      wdata_fail <= '0';                                                                              
      
      if probe_state=s_fetch or                                                                       
         probe_refetch='1'                                                                            
      then                                                                                            
      
        skip_register_check <= '1';                                                                   
                                                                                                      
      else                                                                                            
      
        skip_register_check <= '0';                                                                   
      
      end if;                                                                                         
      
      -- registers check                                                                              
      if probe_state=s_fetch and skip_register_check='0' then                                         
      
        if probe_a/=ref_a or                                                                          
           probe_b/=ref_b or                                                                          
           probe_x/=ref_x or                                                                          
           probe_y/=ref_y or                                                                          
           probe_u/=ref_u or                                                                          
           probe_s/=ref_s or                                                                          
           probe_cc/=ref_cc or                                                                        
           probe_pc/=ref_pc or                                                                        
           probe_dp/=ref_dp                                                                           
        then                                                                                          
                                                                                                      
          if probe_next_state=s_decode then                                                           
                                                                                                      
            std.textio.write(line_out,string'("*************************************************"));  
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("instruction #"));                                      
            std.textio.write(line_out,ref_instr_counter);                                             
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("Registers discrepency detected !"));                   
            std.textio.writeline(output,line_out);                                                    
            dump_cpu_registers;                                                                       
            dump_model_registers;                                                                     
                                                                                                      
            registers_fail   <= '1';                                                                  
            failure_detected <= '1';                                                                  
                                                                                                      
          else                                                                                        
                                                                                                      
            registers_fail   <= '0';                                                                  
                                                                                                      
          end if;                                                                                     
                                                                                                      
        else                                                                                          
                                                                                                      
          registers_fail <= '0';                                                                      
                                                                                                      
        end if;                                                                                       
      
      end if;                                                                                         
      
      -- memory access                                                                                
      if busreq='1' then                                                                              
      
        if ref_addr/=addr then                                                                        
                                                                                                      
                                                                                                      
          std.textio.write(line_out,string'("*************************************************"));    
          std.textio.writeline(output,line_out);                                                      
          std.textio.write(line_out,string'("instruction #"));                                        
          std.textio.write(line_out,ref_instr_counter);                                               
          std.textio.writeline(output,line_out);                                                      
                                                                                                      
          std.textio.write(line_out,string'("Address discrepency detected !"));                       
          std.textio.writeline(output,line_out);                                                      
          std.textio.write(line_out,string'("expected : "));                                          
          hwrite(line_out,ref_addr);                                                                  
          std.textio.write(line_out,string'("    found : "));                                         
          hwrite(line_out,addr);                                                                      
          std.textio.writeline(output,line_out);                                                      
          dump_cpu_registers;                                                                         
          dump_model_registers;                                                                       
      
          addr_fail        <= '1';                                                                    
          failure_detected <= '1';                                                                    
                                                                                                      
        else                                                                                          
                                                                                                      
          addr_fail <= '0';                                                                           
                                                                                                      
        end if;                                                                                       
                                                                                                      
        if write='1' then                                                                             
                                                                                                      
          if ref_wdata/=wdata then                                                                    
                                                                                                      
            std.textio.write(line_out,string'("*************************************************"));  
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("instruction #"));                                      
            std.textio.write(line_out,ref_instr_counter);                                             
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("Data write discrepency detected !"));                  
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("expected : "));                                        
            hwrite(line_out,ref_wdata);                                                               
            std.textio.write(line_out,string'("    found : "));                                       
            hwrite(line_out,wdata);                                                                   
            std.textio.writeline(output,line_out);                                                    
            dump_cpu_registers;                                                                       
            dump_model_registers;                                                                     
                                                                                                      
            wdata_fail       <= '1';                                                                  
            failure_detected <= '1';                                                                  
                                                                                                      
          else                                                                                        
                                                                                                      
            wdata_fail <= '0';                                                                        
                                                                                                      
          end if;                                                                                     
                                                                                                      
        else                                                                                          
                                                                                                      
          if ref_rdata/=rdata then                                                                    
                                                                                                      
            std.textio.write(line_out,string'("*************************************************"));  
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("instruction #"));                                      
            std.textio.write(line_out,ref_instr_counter);                                             
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("Data read discrepency detected !"));                   
            std.textio.writeline(output,line_out);                                                    
            std.textio.write(line_out,string'("expected : "));                                        
            hwrite(line_out,ref_rdata);                                                               
            std.textio.write(line_out,string'("    found : "));                                       
            hwrite(line_out,rdata);                                                                   
            std.textio.writeline(output,line_out);                                                    
            dump_cpu_registers;                                                                       
            dump_model_registers;                                                                     
                                                                                                      
            rdata_fail       <= '1';                                                                  
            failure_detected <= '1';                                                                  
                                                                                                      
          else                                                                                        
                                                                                                      
            rdata_fail <= '0';                                                                        
                                                                                                      
          end if;                                                                                     
                                                                                                      
        end if;                                                                                       
                                                                                                      
      end if;
  
    end if;
  
  end process p_check;
  
  p_clock_generation:process
  
    variable line_out : line;
  begin
  
    if end_simu='1' then
    
      if failure_detected='0' then
      
        std.textio.write(line_out,string'("Simulation Successful !"));
      
      else
      
        std.textio.write(line_out,string'("Simulation FAILED !"));
      
      end if;
      
      writeline(output,line_out);
      wait;
      
    else
    
      clk <= '0';
      wait for 500 ns;
      clk <= '1';
      wait for 500 ns;
    
    end if;
  
  end process p_clock_generation;
 
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 1.2 us;
    resetn <= '1';
    wait ;
  
  end process p_reset_generation;
  
  
  p_stimuli_reader:process
  
    file file_in      : text open read_mode is "./stimuli/cpu.txt";
    variable line_in  : line;
    variable is_init  : std_logic := '0';
    
    variable tmp_pos  : integer;
    variable tmp_i    : integer;
    variable tmp_c    : character;
    variable tmp_s2   : string(1 to 2);
    variable tmp_s4   : string(1 to 4);
    variable tmp32    : std_logic_vector(31 downto 0);
    variable tmp_addr : std_logic_vector(15 downto 0);
    variable tmp_data : std_logic_vector( 7 downto 0);
 
    variable op_instr   : t_cpu_state;
    variable op_mode    : t_mode;
    variable op_operand : t_operand;
  
  begin
    wait until clk'event and clk='1';

    --op_instr           := get_opcode_info(opcode=>probe_opcode).instruction;
    --op_mode            := get_opcode_info(opcode=>probe_opcode).mode;
    --op_operand         := get_opcode_info(opcode=>probe_opcode).operand;
    
    if clken='1' then
    
      if busreq='1' or is_init='0' then
    
        is_init := '1';
        tmp_pos := 0;
    
        loop                           
                                       
          tmp_pos := tmp_pos + 1;
          if endfile(file_in) then     
                                       
            end_simu <= '1';           
            wait;                      
                                       
          end if;                      
                                       
          readline(file_in,line_in);   
          read(line_in,tmp_s2);         
            
          case tmp_s2 is
          
            -- -----------------------------------------------
            -- interrupt level change
            -- -----------------------------------------------
            when "it"=>
          
              read(line_in,tmp_c);                   
              read(line_in,tmp_c);                   
              read(line_in,tmp32(0));                 
                                                      
              case tmp_c is                          
                                                      
                when 'n'=> nnmi <= not tmp32(0);   
                when 'i'=> nirq <= not tmp32(0);   
                when 'f'=> nfiq <= not tmp32(0);   
                when others=>                         
    
                  assert false                        
                    report "unkown interrupt code '"&tmp_c&"' !"  
                      severity failure;               
                                                      
              end case;                               
          
            -- -----------------------------------------------
            -- register change
            -- -----------------------------------------------
            when "a "=>
            
              hread(line_in,tmp32(7 downto 0));
              ref_a <= tmp32(7 downto 0);
            
            when "b "=>
        
              hread(line_in,tmp32(7 downto 0));
              ref_b <= tmp32(7 downto 0);
          
            when "x "=>
             
              hread(line_in,tmp32(15 downto 0));
              ref_x <= tmp32(15 downto 0);
           
            when "y "=>

              hread(line_in,tmp32(15 downto 0));
              ref_y <= tmp32(15 downto 0);
            
            when "u "=>
             
              hread(line_in,tmp32(15 downto 0));
              ref_u <= tmp32(15 downto 0);
           
            when "s "=>

              hread(line_in,tmp32(15 downto 0));
              ref_s <= tmp32(15 downto 0);
          
            when "cc"=>

              hread(line_in,tmp32(7 downto 0));
              ref_cc <= tmp32(7 downto 0);
            
            when "pc"=>
          
              hread(line_in,tmp32(15 downto 0));
              ref_pc <= tmp32(15 downto 0);
            
            when "dp"=>
  
              hread(line_in,tmp32(7 downto 0));
              ref_dp <= tmp32(7 downto 0);
            
            -- -----------------------------------------------
            -- memory read access
            -- -----------------------------------------------
            when "r "=> 
            
              exit;
            
            -- -----------------------------------------------
            -- memory write access
            -- -----------------------------------------------
            when "w "=> 
            
              exit;
            -- -----------------------------------------------
            -- update instuction counter
            -- -----------------------------------------------
            when "- "=>
            
              read(line_in,tmp_i);
              ref_instr_counter <= tmp_i;
              
              read(line_in,tmp_i);
              
              if probe_next_state=s_fetch then
              
                ref_instr_cycles  <= tmp_i;
               
              end if;

            -- -----------------------------------------------
            -- illegal case
            -- -----------------------------------------------
            when others=>
            
               assert false                        
                 report "unkown stimuli code '"&tmp_s2&"' !" 
                   severity failure;               
           
           end case;
          
        end loop;  
        
        line_pos <= line_pos + tmp_pos;                    
    
        case tmp_s2 is                  
                                       
          when "r "=>                   
                                       
            hread(line_in,tmp_addr);   
            hread(line_in,tmp_data);  
            
            ref_addr    <= tmp_addr; 
            ref_rdata   <= tmp_data; 
                                       
          when "w "=>                   
                                       
            hread(line_in,tmp_addr);   
            hread(line_in,tmp_data); 
            
            ref_addr    <= tmp_addr;
            ref_wdata   <= tmp_data;
                                       
          when others=>                

            assert false 
              report "unkown control code '"&tmp_s2&"' !" 
                severity failure;
                                       
        end case;
        
      end if;                      
   
      if probe_next_state=s_fetch then        
                                              
        ref_instr_cycles  <= tmp_i;           
                                              
      end if;   
      
    end if;                              
  
  end process p_stimuli_reader;
  
  cpu_1:cpu6809
  port map                                                    
  (                                                        
    -- system                                       
    resetn   => resetn,                 
    clk      => clk,
    clken    => clken,
    -- interruptions                                
    nnmi     => nnmi,
    nirq     => nirq,
    nfiq     => nfiq,
    -- memory                                       
    busreq   => busreq,
    write    => write,
    addr     => addr,
    rdata    => rdata,
    wdata    => wdata
  );                                                       

end architecture testbench;

library s3mo5_lib;
library unisim;

configuration cpu_conf of testbench_cpu is
  for testbench
    for all:cpu6809
      use entity s3mo5_lib.cpu6809(rtl);
      for rtl
        for all:datapath
          use entity s3mo5_lib.datapath(rtl);
          for rtl
            for all:alu
              use entity s3mo5_lib.alu(rtl);
            end for;
            for all:mult18x18
              use entity unisim.mult18x18(mult18x18_v);
            end for;
          end for;
        end for;
        for all:sequencer
          use entity s3mo5_lib.sequencer(rtl);
        end for;
      end for;
    end for;
  end for;
end configuration cpu_conf;
