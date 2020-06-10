----------------------------------------------------------------------
--
-- S3MO5 - cpu datapath
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

library unisim;
use unisim.vcomponents.all;

use work.cpu_package.all;

entity datapath is
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
    set_i             :  in std_logic;
    set_f             :  in std_logic;
    clear_e           :  in std_logic;
    ccr               : out std_logic_vector( 7 downto 0);
    
    -- ALU modes
    alu_mode          :  in t_alu;
    
    -- muxes control
    alu_mux_sel       :  in std_logic_vector( 3 downto 0);
    index_mux_sel     :  in std_logic_vector( 3 downto 0);
    index_add_sel     :  in std_logic;
    addr_mux_sel      :  in std_logic_vector( 2 downto 0);
    bytelane_mux_sel  :  in std_logic;
    allreg_mux_sel    :  in std_logic_vector( 1 downto 0); 
    mr_mux_sel        :  in std_logic_vector( 1 downto 0);
    mult_mux_sel      :  in std_logic;
    
    pc_mux_sel        :  in std_logic_vector( 1 downto 0);
    x_mux_sel         :  in std_logic;
    y_mux_sel         :  in std_logic;
    u_mux_sel         :  in std_logic;
    s_mux_sel         :  in std_logic;
    ea_mux_sel        :  in std_logic_vector( 3 downto 0);
    dp_mux_sel        :  in std_logic;
    
    -- registers control
    ab_en             :  in std_logic_vector( 1 downto 0);
    x_en              :  in std_logic;
    y_en              :  in std_logic;
    u_en              :  in std_logic;
    s_en              :  in std_logic;
    mr_en             :  in std_logic;
    pc_en             :  in std_logic;
    dp_en             :  in std_logic;
    cc_en             :  in std_logic;
    ea_en             :  in std_logic;
    op_en             :  in std_logic;
    mw_en             :  in std_logic;
    
    -- memory
    addr              : out std_logic_vector(15 downto 0);
    rdata             :  in std_logic_vector( 7 downto 0);
    wdata             : out std_logic_vector( 7 downto 0);
    
    -- opcode & postbyte
    opcode            : out std_logic_vector( 9 downto 0);
    refetch           : out std_logic
  );
end entity datapath;

architecture rtl of datapath is
  
  component MULT18X18
    port (
      P  : out std_logic_vector (35 downto 0);
      A  : in  std_logic_vector (17 downto 0);
      B  : in  std_logic_vector (17 downto 0)
    );
  end component;
  
  component alu
    port
    (
      -- mode
      mode    :  in t_alu;
      
      -- operands & result
      op1     :  in std_logic_vector(15 downto 0);
      op2     :  in std_logic_vector(15 downto 0);
      result  : out std_logic_vector(15 downto 0);
      
      -- condition flag
      cci     :  in std_logic_vector( 7 downto 0);
      cco     : out std_logic_vector( 7 downto 0)
    );
  end component;
  
  signal a               : std_logic_vector( 7 downto 0);
  signal b               : std_logic_vector( 7 downto 0);
  signal x               : std_logic_vector(15 downto 0);
  signal y               : std_logic_vector(15 downto 0);
  signal u               : std_logic_vector(15 downto 0);
  signal s               : std_logic_vector(15 downto 0);
  signal dp              : std_logic_vector( 7 downto 0);
  signal pc              : std_logic_vector(15 downto 0);
  signal ea              : std_logic_vector(15 downto 0);
  signal mr              : std_logic_vector( 7 downto 0);
  signal cc              : std_logic_vector( 7 downto 0);
  signal op              : std_logic_vector( 9 downto 0);
  
  signal alu_mux         : std_logic_vector(15 downto 0);
  signal alu_bus         : std_logic_vector(15 downto 0);
  signal addr_bus        : std_logic_vector(15 downto 0);
  signal index_mux       : std_logic_vector(15 downto 0);
  signal index_bus       : std_logic_vector(15 downto 0);
  signal allreg_bus      : std_logic_vector(15 downto 0);
  signal ea_mux          : std_logic_vector(15 downto 0);
  signal pc_mux          : std_logic_vector(15 downto 0);
  signal x_mux           : std_logic_vector(15 downto 0);
  signal y_mux           : std_logic_vector(15 downto 0);
  signal u_mux           : std_logic_vector(15 downto 0);
  signal s_mux           : std_logic_vector(15 downto 0);
  signal dp_mux          : std_logic_vector( 7 downto 0);

  signal mr_mux          : std_logic_vector(15 downto 0);
  signal mw_mux          : std_logic_vector( 7 downto 0);
  
  signal cc_to_alu       : std_logic_vector( 7 downto 0);
  signal cc_from_alu     : std_logic_vector( 7 downto 0);

  signal mult_op1        : std_logic_vector(17 downto 0);
  signal mult_op2        : std_logic_vector(17 downto 0);
  signal mult_res        : std_logic_vector(35 downto 0);
  
begin
  -- ---------------------------------------------------------------------------
  -- probes
  -- ---------------------------------------------------------------------------
  probe_a   <= a;
  probe_b   <= b;
  probe_x   <= x;
  probe_y   <= y;
  probe_u   <= u; 
  probe_s   <= s;
  probe_pc  <= pc;
  probe_cc  <= cc;
  probe_dp  <= dp;

  -- ---------------------------------------------------------------------------
  -- assignment
  -- ---------------------------------------------------------------------------
  ccr         <= cc;
  addr        <= addr_bus;
  opcode      <= op;
  
  -- ---------------------------------------------------------------------------
  -- Effective Address Adder
  -- ---------------------------------------------------------------------------
  p_ea_add_comb:process(index_add_sel,addr_bus,index_mux)
  
    variable tmp : std_logic_vector(15 downto 0);
  
  begin
  
    if index_add_sel='1' then
    
      tmp := addr_bus;
      
    else
    
      tmp := "0000000000000000";
      
    end if;
 
    index_bus <= tmp + index_mux;
  
  end process p_ea_add_comb;
  
  -- ---------------------------------------------------------------------------
  -- Multiplexers
  -- ---------------------------------------------------------------------------
  p_alu_mux_comb:process(alu_mux_sel,a,b,x,y,u,s,ea,mr_mux,mult_mux_sel,mult_res)
  begin
  
    case alu_mux_sel is
    
      when "0000" => alu_mux <= "00000000"&a;
      when "0001" => alu_mux <= "00000000"&b;
      when "0010" => 
      
      if mult_mux_sel='0' then
      
        alu_mux <= a&b;
      
      else
      
        alu_mux <= mult_res(15 downto 0);
      
      end if;
      
      when "0011" => alu_mux <= x;
      when "0100" => alu_mux <= y;
      when "0101" => alu_mux <= u;
      when "0110" => alu_mux <= s;
      when "0111" => alu_mux <= ea;
      when others => alu_mux <= mr_mux;
      
    end case;
  
  end process p_alu_mux_comb;
  
  p_index_mux_comb:process(index_mux_sel,a,b,mr_mux,ea)
  begin
  
    case index_mux_sel is
    
      when "0000" => index_mux <= "0000000000000000";
      when "0001" => index_mux <= "1111111111111111";
      when "0010" => index_mux <= "0000000000000001";
      when "0011" => index_mux(7 downto 0) <= a; index_mux(15 downto 8) <=(others=>a(7));
      when "0100" => index_mux(7 downto 0) <= b; index_mux(15 downto 8) <=(others=>b(7));
      when "0101" => index_mux <= a&b;
      when "0110" => index_mux <= "00000000"&b;
      when "0111" => index_mux <= mr_mux;
      when others => index_mux <= ea;
          
    end case;
  
  end process p_index_mux_comb;

  p_allreg_mux_comb:process(allreg_mux_sel,alu_bus,dp,pc,cc_from_alu)
  begin
  
    case allreg_mux_sel is
    
      when "00"  => allreg_bus <= alu_bus;
      when "01"  => allreg_bus <= "00000000"&dp;
      when "10"  => allreg_bus <= pc;
      when others=> allreg_bus <= "00000000"&cc_from_alu;
          
    end case;
  
  end process p_allreg_mux_comb;

  p_addr_mux_comb:process(addr_mux_sel,x,y,u,s,ea,dp,pc)
  begin
  
    case addr_mux_sel is
    
      when "000" => addr_bus <= x;
      when "001" => addr_bus <= y;
      when "010" => addr_bus <= u;
      when "011" => addr_bus <= s;
      when "100" => addr_bus <= ea;
      when "101" => addr_bus <= dp&ea(7 downto 0);
      when others=> addr_bus <= pc;
    
    end case;
  
  end process p_addr_mux_comb;
  
  
  p_pc_mux_comb:process(pc_mux_sel,index_bus,mr_mux,vector)
  begin
  
    case pc_mux_sel is                                                                
    
      when "00"  => pc_mux <= index_bus;                                                  
      when "01"  => pc_mux <= mr_mux;                                                   
      when others=> pc_mux(15 downto 4) <= (others=>'1'); pc_mux(3 downto 0)<= vector&'0';    
                                                                                      
    end case;                                                                         
  
  end process p_pc_mux_comb;
 
  p_mr_mux_comb:process(mr_mux_sel,mr,rdata)
  begin
  
    case mr_mux_sel is
    
      when "00"  => 
      
        mr_mux <= mr&rdata;
     
      when "01"  =>
      
        mr_mux(15 downto 5) <= (others=>mr(4));
        mr_mux( 4 downto 0) <= mr( 4 downto 0); 
      
      when "10"=>
      
        mr_mux(15 downto 8) <= (others=>rdata(7));
        mr_mux( 7 downto 0) <= rdata( 7 downto 0);
      
      when others=>
      
        mr_mux(15 downto 8) <= (others=>mr(7));
        mr_mux( 7 downto 0) <= mr( 7 downto 0);
   
    end case;
  
  end process p_mr_mux_comb;
  
  p_ea_mux_comb:process(ea_mux_sel,index_bus,mr_mux,x,y,u,s,cc,dp,pc)
  begin
  
    case ea_mux_sel is
    
      when "0000" => ea_mux <= index_bus;
      when "0001" => ea_mux <= mr_mux;
      when "0010" => ea_mux <= x;
      when "0011" => ea_mux <= y;
      when "0100" => ea_mux <= u;
      when "0101" => ea_mux <= s;
      when "0110" => ea_mux <= "00000000"&cc;
      when "0111" => ea_mux <= "00000000"&dp;
      when others => ea_mux <= pc;

    end case;
  
  end process p_ea_mux_comb;
  
  x_mux  <= index_bus when  x_mux_sel='0' else mr_mux;
  y_mux  <= index_bus when  y_mux_sel='0' else mr_mux;
  u_mux  <= index_bus when  u_mux_sel='0' else mr_mux;
  s_mux  <= index_bus when  s_mux_sel='0' else mr_mux;
  dp_mux <= index_bus(7 downto 0) when dp_mux_sel='0' else mr_mux(7 downto 0);
  
  mw_mux <= allreg_bus( 7 downto 0) when bytelane_mux_sel='0' else
            allreg_bus(15 downto 8);
 
 
  -- ---------------------------------------------------------------------------
  -- Opcode selection
  -- ---------------------------------------------------------------------------
  p_opcode_sel:process(rdata)
  begin
  
    if rdata(7 downto 1)="0001000" then
    
      refetch <= '1';
    
    else
    
      refetch <= '0';
    
    end if;
  
  end process p_opcode_sel;
  
  -- ---------------------------------------------------------------------------
  -- Registers
  -- ---------------------------------------------------------------------------
  cc_to_alu(7)          <= (cc(7) and not (clear_e)) or set_e;  -- E
  cc_to_alu(6)          <= cc(6) or set_f ;                     -- F
  cc_to_alu(5)          <= cc(5);                               -- H
  cc_to_alu(4)          <= cc(4) or set_i ;                     -- I
  cc_to_alu(3)          <= cc(3);                               -- N
  cc_to_alu(2)          <= cc(2);                               -- Z
  cc_to_alu(1)          <= cc(1);                               -- V
  cc_to_alu(0)          <= cc(0);                               -- C
 
  p_condition_code_register:process(clk,resetn)
  begin
      
    if resetn='0' then
    
      cc <= "01010000";
      
    elsif clk'event and clk='1' then
       
      if clken='1' then
      
        if cc_en='1' then
      
          cc   <= cc_from_alu;
        
        end if;
        
      end if;
    
    end if;
  
  end process p_condition_code_register;
  
  
  p_global_registers_seq:process(resetn,clk)
  begin

    if resetn='0' then
    
      a     <= (others=>'0');
      b     <= (others=>'0');
      x     <= (others=>'0');
      y     <= (others=>'0');
      u     <= (others=>'0');
      s     <= (others=>'0');
      pc    <= (others=>'0');
      dp    <= (others=>'0');
      ea    <= (others=>'0');
      mr    <= (others=>'0');
      op    <= (others=>'0');
      wdata <= (others=>'0');
      
    elsif clk'event and clk='1' then
    
      if clken='1' then
    
        if ab_en(1)='1' then
        
          if ab_en(0)='1' then
          
            a <= alu_bus(15 downto 8);
            b <= alu_bus( 7 downto 0);
            
          else
          
            a <= alu_bus( 7 downto 0);
          
          end if;
        
        else
        
          if ab_en(0)='1' then
          
            b <= alu_bus( 7 downto 0);
          
          end if;
        
        end if;
       
        if x_en='1' then
        
          x <= x_mux;
        
        end if;
        
        if y_en='1' then
        
          y <= y_mux;
        
        end if;
 
        if u_en='1' then
        
          u <= u_mux;
        
        end if;
        
        if s_en='1' then
        
          s <= s_mux;
        
        end if;
        
        if pc_en='1' then
        
          pc <= pc_mux;
          
        end if;
          
        if dp_en='1' then
        
          dp <= dp_mux;
        
        end if;
       
        if ea_en='1' then
        
          ea <= ea_mux;

        end if;
   
        if mr_en='1' then
        
          mr <= rdata;
        
        end if;
        
        if op_en='1' then
        
          if op(7 downto 1)="0001000" then  
          
            if op(0)='0' then               
                                            
              op(9 downto 8) <= "01";       
                                            
            else                            
                                            
              op(9 downto 8) <= "10";       
                                            
            end if;                         
          
          else                              
          
            op(9 downto 8) <= "00";         
          
          end if;                           
          
          op(7 downto 0) <= rdata;
          
        end if;
    
        if mw_en='1' then
        
          wdata <= mw_mux;
          
        end if;
    
      end if;
   
    end if;
  
  end process p_global_registers_seq;
  
  -- ---------------------------------------------------------------------------
  -- ALU instance
  -- ---------------------------------------------------------------------------
  alu_1:alu
  port map
  (
    -- mode
    mode    => alu_mode,
    
    -- operands & result
    op1     => alu_mux,
    op2     => mr_mux,
    result  => alu_bus,
    
    -- condition flag
    cci     => cc_to_alu,
    cco     => cc_from_alu
  );
  
  -- ---------------------------------------------------------------------------
  -- Fast Multiplier
  -- ---------------------------------------------------------------------------
  
  mult_op1 <= "0000000000"&a;
  mult_op2 <= "0000000000"&b;
  
  mult_1:MULT18X18
  port map 
  (
    P  => mult_res,  
    A  => mult_op1,  
    B  => mult_op2  
  );


end architecture rtl;
