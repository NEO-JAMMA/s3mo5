----------------------------------------------------------------------
--
-- S3MO5 - alu
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

use work.cpu_package.all;

entity alu is
  port
  (
    -- mode
    mode    :  in t_alu; 
    
    -- operands & result
    op1     :  in std_logic_vector(15 downto 0);
    op2     :  in std_logic_vector(15 downto 0);
    result  : out std_logic_vector(15 downto 0);
    
    -- condition flag
    cci     :  in std_logic_vector(7 downto 0);
    cco     : out std_logic_vector(7 downto 0)
  );
end entity alu;

architecture rtl of alu is

  signal op_a      : std_logic_vector(15 downto 0);
  signal op_b      : std_logic_vector(15 downto 0);
  signal carry     : std_logic;
  signal res       : std_logic_vector(15 downto 0);
  
  signal null8     : std_logic_vector( 7 downto 0);
  signal dadj8     : std_logic_vector( 7 downto 0);
  signal sx8       : std_logic_vector( 7 downto 0);
  signal com8      : std_logic_vector( 7 downto 0);
  signal eor8      : std_logic_vector( 7 downto 0);
  signal neg8      : std_logic_vector( 7 downto 0);
  signal ass16     : std_logic_vector(15 downto 0);
  signal ass8      : std_logic_vector( 7 downto 0);
  signal ass16_op2 : std_logic_vector(15 downto 0);
  signal ass8_op2  : std_logic_vector( 7 downto 0);
  signal lsl8      : std_logic_vector( 7 downto 0);
  signal lsr8      : std_logic_vector( 7 downto 0);
  signal asr8      : std_logic_vector( 7 downto 0);
  signal ror8      : std_logic_vector( 7 downto 0);
  signal rol8      : std_logic_vector( 7 downto 0);
  signal and8      : std_logic_vector( 7 downto 0);
  signal or8       : std_logic_vector( 7 downto 0);
  signal sum       : std_logic_vector(16 downto 0);
  signal diff      : std_logic_vector(16 downto 0);
  
  signal c4        : std_logic;
  signal z8        : std_logic;
  signal z16       : std_logic;
  signal n8        : std_logic;
  signal n16       : std_logic;
  signal vp8       : std_logic;
  signal vp16      : std_logic;
  signal cp8       : std_logic;
  signal cp16      : std_logic;
  signal vm8       : std_logic;
  signal vm16      : std_logic;
  signal cm8       : std_logic;
  signal cm16      : std_logic;
  signal vl8       : std_logic;
  signal cn8       : std_logic;
  signal vn8       : std_logic;
  signal cdadj8    : std_logic;
  
  signal e_out     : std_logic;
  signal f_out     : std_logic;
  signal i_out     : std_logic;
  signal c_out     : std_logic;
  signal v_out     : std_logic;
  signal z_out     : std_logic;
  signal n_out     : std_logic;
  signal h_out     : std_logic;

begin

  null8 <= (others=>'0');
  
  sx8   <= "00000000" when op_a(7)='0' else "11111111";
  
  com8  <= not(op_a(7 downto 0));
  
  eor8  <= op_a(7 downto 0) xor op_b(7 downto 0);

  neg8  <= not(op_a(7 downto 0)) + "00000001";
  
  ass16 <= op_a;
  
  ass8  <= op_a(7 downto 0);
 
  ass16_op2 <= op_b;
  
  ass8_op2  <= op_b(7 downto 0);
  
  lsl8  <= op_a(6 downto 0)&'0';
  
  lsr8  <= '0'&op_a(7 downto 1);
 
  
  asr8  <= op_a(7)&op_a(7 downto 1);

  ror8  <= carry&op_a(7 downto 1);

  rol8  <= op_a(6 downto 0)&carry;
  
  and8  <= op_a(7 downto 0) and op_b(7 downto 0);

  or8   <= op_a(7 downto 0) or op_b(7 downto 0);

  sum   <= (op_a&'1') + (op_b&carry);
           
  diff  <= (op_a&'0') - (op_b&carry);
  
  c4    <= (op_a(3) and op_b(3)) or
           (op_a(3) and not(res(3))) or
           (op_b(3) and not(res(3)));
  
  z8    <= '1' when res(7 downto 0)="00000000" else '0';
  z16   <= '1' when res="0000000000000000"     else '0';
  
  n8    <= res(7);
  n16   <= res(15);
  
  vp8   <= (op_a(7) and op_b(7) and not(res(7))) or
           (not(op_a(7)) and not(op_b(7)) and res(7));
  
  vp16  <= (op_a(15) and op_b(15) and not(res(15))) or
           (not(op_a(15)) and not(op_b(15)) and res(15));
          
  cp8   <= (op_a(7) and op_b(7)) or
           (op_a(7) and not(res(7))) or
           (op_b(7) and not(res(7)));

  cp16  <= (op_a(15) and op_b(15)) or
           (op_a(15) and not(res(15))) or
           (op_b(15) and not(res(15)));

  vm8   <= (not(op_a(7)) and op_b(7) and res(7)) or
           (op_a(7) and not(op_b(7)) and not(res(7)));
  
  vm16  <= (not(op_a(15)) and op_b(15) and res(15)) or
           (op_a(15) and not(op_b(15)) and not(res(15)));
          
  cm8   <= (not(op_a(7)) and op_b(7)) or
           (not(op_a(7)) and res(7)) or
           (op_b(7) and res(7));

  cm16  <= (not(op_a(15)) and op_b(15)) or
           (not(op_a(15)) and res(15)) or
           (op_b(15) and res(15));

  vl8   <= (not(op_a(7)) and res(7)) or
           (op_a(7) and not(res(7)));

  cn8   <= '1' when op_a(7 downto 0)="00000000" else '0';
  
  vn8   <= '1' when op_a(7 downto 0)="11111111" else '0';

  
  result <= res;
  
  cco   <= e_out&f_out&h_out&i_out&n_out&z_out&v_out&c_out;
  
  p_dadj8_comb:process(op1,cci(5),cci(0))
  
    variable tmp : std_logic_vector(8 downto 0);
  
  begin
  
    tmp := '0'&op1(7 downto 0);
    
    if tmp(3 downto 1)="101" or tmp(3 downto 2)="11" or cci(5)='1' then
    
      tmp := tmp + "000000110";
      
    end if;
  
    if tmp(7 downto 5)="101" or tmp(7 downto 6)="11" or cci(0)='1' or tmp(8)='1' then
    
      tmp := tmp + "001100000";
      
    end if;

    dadj8  <= tmp(7 downto 0);
    cdadj8 <= tmp(8) or cci(0);
  
  end process p_dadj8_comb;
  
  p_alu_comb:process(op1,op2,cci,sx8,dadj8,
     com8,eor8,neg8,ass16,ass8,lsl8,lsr8,asr8,ror8,rol8,and8,
     or8,null8,sum,diff,n8,n16,c4,z8,z16,vp8,vp16,cp8,cp16,
     vm8,vm16,cm8,cm16,vl8,cn8,vn8,cdadj8,mode,ass16_op2,ass8_op2)
  begin
  
    e_out <= cci(7);
    f_out <= cci(6);
    i_out <= cci(4);
  
    case mode is
    
      when a_plus8 => -- PLUS8
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= '0';
        res    <= null8&sum(8 downto 1);
        
        h_out  <= c4;
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vp8;
        c_out  <= cp8;
        
      when a_plus8c => -- PLUS8C
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= cci(0);
        res    <= null8&sum(8 downto 1);
        
        h_out  <= c4; 
        n_out  <= n8; 
        z_out  <= z8; 
        v_out  <= vp8; 
        c_out  <= cp8; 
      
      when a_plus16 => -- PLUS16
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= '0';
        res    <= sum(16 downto 1);
        
        h_out  <= cci(5);
        n_out  <= n16;
        z_out  <= z16;
        v_out  <= vp16;
        c_out  <= cp16;
      
      when a_minus8 => -- MINUS8
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= '0';
        res    <= null8&diff(8 downto 1);
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vm8;
        c_out  <= cm8;
      
      when a_minus8c => -- MINUS8C
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= cci(0);
        res    <= null8&diff(8 downto 1);
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vm8;
        c_out  <= cm8;
      
      when a_minus16 => -- MINUS16
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= '0';
        res    <= diff(16 downto 1);
        
        h_out  <= cci(5);
        n_out  <= n16;
        z_out  <= z16;
        v_out  <= vm16;
        c_out  <= cm16;
    
      when a_or8 => -- OR8
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= '0';
        res    <= null8&or8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cci(0);
        
      when a_and8 => -- AND8
      
        op_a   <= op1;
        op_b   <= op2;
        carry  <= '0';
        res    <= null8&and8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cci(0);
        
      when a_rol8 => -- ROL8 
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= cci(0);
        res    <= null8&rol8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vl8;
        c_out  <= op1(7);
      
      when a_ror8 => -- ROR8
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= cci(0);
        res    <= null8&ror8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= cci(1);
        c_out  <= op1(0);
      
      when a_asr8 => -- ASR8
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= null8&asr8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= cci(1);
        c_out  <= op1(0);
        
      when a_lsl8 => -- LSL8
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= null8&lsl8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vl8;
        c_out  <= op1(7);
        
      when a_lsr8 => -- LSR8
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= null8&lsr8;
        
        h_out  <= cci(5);
        n_out  <= '0';
        z_out  <= z8;
        v_out  <= cci(1);
        c_out  <= op1(0);
        
      when a_assign8 => -- ASSIGN8
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= null8&ass8;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cci(0);
      
      when a_assign16  => -- ASSIGN16
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= ass16;
        
        h_out  <= cci(5);
        n_out  <= n16;
        z_out  <= z16;
        v_out  <= '0';
        c_out  <= cci(0);
      
      when a_tst8 => -- TST8
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0';  -- not used
        res    <= null8&ass8; -- not used
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cci(0);
      
      when a_neg8 => -- NEG8
      
        op_a   <= op1;
        op_b   <= op2; -- not used
        carry  <= '0'; -- not used
        res    <= null8&neg8; 
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vn8;
        c_out  <= cn8;
         
      when a_clr => -- CLR
      
        op_a   <= op1; -- not used
        op_b   <= op2; -- not used
        carry  <= '0'; -- not used
        res    <= null8&null8; 
        
        h_out  <= cci(5);
        n_out  <= '0';
        z_out  <= '1';
        v_out  <= '0';
        c_out  <= '0';
      
      when a_eor8 => -- EOR8
      
        op_a   <= op1;  
        op_b   <= op2;
        carry  <= '0'; -- not used
        res    <= null8&eor8; 
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cci(0);
        
      when a_com8 => -- COM8
      
        op_a   <= op1;  
        op_b   <= op2; -- not used  
        carry  <= '0'; -- not used
        res    <= null8&com8; 
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= '1';
        
      when a_inc8 => -- INC8
      
        op_a   <= op1;
        op_b   <= "0000000000000000";
        carry  <= '1';
        res    <= null8&sum(8 downto 1);
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vp8;
        c_out  <= cci(0);
     
      when a_dec8  => -- DEC8
      
        op_a   <= op1;
        op_b   <= "0000000000000000";
        carry  <= '1';
        res    <= null8&diff(8 downto 1);
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= vm8;
        c_out  <= cci(0);
      
      when a_tstz => -- TSTZ
      
        op_a   <= op1;  
        op_b   <= op2; -- not used  
        carry  <= '0'; -- not used
        res    <= ass16; 
        
        h_out  <= cci(5);
        n_out  <= cci(3);
        z_out  <= z16;
        v_out  <= cci(1);
        c_out  <= cci(0);
       
      when a_sex8 => -- SEX8
      
        op_a   <= op1;  
        op_b   <= op2; -- not used  
        carry  <= '0'; -- not used
        res    <= null8&sx8; 
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= cci(1);
        c_out  <= cci(0);
      
      when a_dadj8 => -- DADJ8
      
        op_a   <= op1;  
        op_b   <= op2; -- not used  
        carry  <= '0'; -- not used
        res    <= null8&dadj8; 
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cdadj8;
       
      when a_assign8_op2 => -- ASSIGN8_OP2
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= ass8_op2&ass8_op2;
        
        h_out  <= cci(5);
        n_out  <= n8;
        z_out  <= z8;
        v_out  <= '0';
        c_out  <= cci(0);
      
      when a_assign16_op2  => -- ASSIGN16_OP2
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0'; -- not used
        res    <= ass16_op2;
        
        h_out  <= cci(5);
        n_out  <= n16;
        z_out  <= z16;
        v_out  <= '0';
        c_out  <= cci(0);
 
      when a_assign_ccr  => -- ASSIGN_CCR
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0';  -- not used
        res    <= null8&null8;
        
        e_out  <= op1(7);
        f_out  <= op1(6);
        h_out  <= op1(5);
        i_out  <= op1(4);
        n_out  <= op1(3);
        z_out  <= op1(2);
        v_out  <= op1(1);
        c_out  <= op1(0);
    
      when a_assign_ccr_op2  => -- ASSIGN_CCR
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0';  -- not used
        res    <= null8&null8;
        
        e_out  <= op2(7);
        f_out  <= op2(6);
        h_out  <= op2(5);
        i_out  <= op2(4);
        n_out  <= op2(3);
        z_out  <= op2(2);
        v_out  <= op2(1);
        c_out  <= op2(0);
     
      when a_and_ccr  => -- AND_CCR
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0';  -- not used
        res    <= null8&null8;
        
        e_out  <= cci(7) and op2(7);
        f_out  <= cci(6) and op2(6);
        h_out  <= cci(5) and op2(5);
        i_out  <= cci(4) and op2(4);
        n_out  <= cci(3) and op2(3);
        z_out  <= cci(2) and op2(2);
        v_out  <= cci(1) and op2(1);
        c_out  <= cci(0) and op2(0);

      when a_or_ccr  => -- OR_CCR
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0';  -- not used
        res    <= null8&null8;
        
        e_out  <= cci(7) or op2(7);
        f_out  <= cci(6) or op2(6);
        h_out  <= cci(5) or op2(5);
        i_out  <= cci(4) or op2(4);
        n_out  <= cci(3) or op2(3);
        z_out  <= cci(2) or op2(2);
        v_out  <= cci(1) or op2(1);
        c_out  <= cci(0) or op2(0);
      
      when a_mult => -- MULT
      
        op_a   <= op1;
        op_b   <= op2;  -- not used
        carry  <= '0';  -- not used
        res    <= ass16;
        
        e_out  <= cci(7);
        f_out  <= cci(6);
        h_out  <= cci(5);
        i_out  <= cci(4);
        n_out  <= cci(3);
        z_out  <= z16;
        v_out  <= cci(1);
        c_out  <= n8;
      
      when a_nop =>  
      
        op_a   <= op1;  
        op_b   <= op2; -- not used  
        carry  <= '0'; -- not used
        res    <= null8&null8; 
        
        h_out  <= cci(5);
        n_out  <= cci(3);
        z_out  <= cci(2);
        v_out  <= cci(1);
        c_out  <= cci(0);
    
    end case;
  
  end process p_alu_comb;

end architecture rtl;
