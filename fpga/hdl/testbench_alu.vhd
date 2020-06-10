----------------------------------------------------------------------
--
-- S3MO5 - testbench alu
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

entity testbench_alu is
end entity testbench_alu;

architecture testbench of testbench_alu is

  component alu
    port
    (
      -- mode
      mode    :  in std_logic_vector( 4 downto 0); 
      
      -- operands & result
      op1     :  in std_logic_vector(15 downto 0);
      op2     :  in std_logic_vector(15 downto 0);
      result  : out std_logic_vector(15 downto 0);
      
      -- condition flag
      h_in    :  in std_logic;
      n_in    :  in std_logic;
      z_in    :  in std_logic;
      v_in    :  in std_logic;
      c_in    :  in std_logic;
      h_out   : out std_logic;
      n_out   : out std_logic;
      z_out   : out std_logic;
      v_out   : out std_logic;
      c_out   : out std_logic
    );
  end component;
  
  signal vec     : std_logic_vector(23 downto 0) := (others=>'0');
  signal mode    : std_logic_vector( 4 downto 0); 
  signal op1     : std_logic_vector(15 downto 0);
  signal op2     : std_logic_vector(15 downto 0);
  signal result  : std_logic_vector(15 downto 0);
  signal h_in    : std_logic;
  signal n_in    : std_logic;
  signal z_in    : std_logic;
  signal v_in    : std_logic;
  signal c_in    : std_logic;
  signal h_out   : std_logic;
  signal n_out   : std_logic;
  signal z_out   : std_logic;
  signal v_out   : std_logic;
  signal c_out   : std_logic;

begin 

  -- ---------------------------------------------------------------------------
  -- 
  -- ---------------------------------------------------------------------------

  p_stimuli_generation:process
  
    file file_out     : text open write_mode is "results/alu.txt";
    variable line_out : line;
  
  begin
  
    if vec(23 downto 19)="11001" then
    
      wait;
      
    end if;
     
    mode <= vec(23 downto 19);                
                                              
    h_in <= vec(18);                          
    n_in <= vec(17);                          
    z_in <= vec(16);                          
    v_in <= vec(15);                          
    c_in <= vec(14);                          
                                              
    op1(15 downto 13)  <= vec(13 downto 11);  
    op1(12 downto  4)  <= (others=>vec(10));  
    op1(3)             <= vec(9);
    op1(2)             <= vec(10);
    op1(1 downto 0)    <= vec(8 downto 7);    
  
  
  
                                              
    op2(15 downto 13)  <= vec(6 downto  4);   
    op2(12 downto  3)  <= (others=>vec(3));   
    op2(2 downto 0)    <= vec(2 downto 0);    
                                              
    wait for 5 ns;                            
                                             
    hwrite(line_out,("000"&mode));            
    write(line_out,string'(" "));             
                                             
    hwrite(line_out,op1);                     
    write(line_out,string'(" "));             
    hwrite(line_out,op2);                     
    write(line_out,string'(" "));             
                                             
    write(line_out,h_in);                     
    write(line_out,n_in);                     
    write(line_out,z_in);                     
    write(line_out,v_in);                     
    write(line_out,c_in);                     
    write(line_out,string'(" "));             
                                              
    write(line_out,h_out);                    
    write(line_out,n_out);                    
    write(line_out,z_out);                    
    write(line_out,v_out);                    
    write(line_out,c_out);                    
    write(line_out,string'(" "));             
                                              
    hwrite(line_out,result);                  
                                              
    writeline(file_out,line_out);             
                                              
                                             
    vec  <= vec + 1;                          
                                              
    wait for 5 ns;                            
    
  end process p_stimuli_generation;
  
  
  alu_1:alu
  port map
  (
    mode    => mode,     
    op1     => op1,     
    op2     => op2,     
    result  => result,  
    h_in    => h_in,    
    n_in    => n_in,    
    z_in    => z_in,    
    v_in    => v_in,    
    c_in    => c_in,   
    h_out   => h_out,   
    n_out   => n_out,   
    z_out   => z_out,   
    v_out   => v_out,   
    c_out   => c_out   
  );

end architecture testbench;

configuration alu_conf of testbench_alu is
  for testbench
    for all:alu
      use entity work.alu(rtl);
    end for;
  end for;
end configuration alu_conf;

