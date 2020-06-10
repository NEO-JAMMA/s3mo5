----------------------------------------------------------------------
--
-- S3MO5 - cpu_package
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

----------------------------------------------------------------------
--      
----------------------------------------------------------------------
package cpu_package is

  type t_mode is
    (m_inherent,m_direct,m_extended,m_immediate8,m_immediate16,m_indexed,m_relative);
 
  type t_cpu_state is 
    (s_reset,s_fetch_interrupt_h,s_fetch_interrupt_l,
     s_fetch,s_decode,
     s_tfr,s_tfr2,
     s_abx,s_abx2,s_adc,s_add,s_and,s_andcc,
     s_lsl,s_asr,
     s_b,
     s_lb,s_lb2,
     s_lbsr,s_lbsr2,s_lbsr3,s_lbsr4,s_lbsr5,
     s_bit,
     s_bsr,s_bsr2,s_bsr3,s_bsr4,
     s_clr,s_cmp,s_com,s_cwait,
     s_daa,s_dec,s_eor,s_exg,s_exg2,s_exg3,s_inc,
     s_inca,s_incb,s_jmp,
     s_jsr,s_jsr2,s_jsr3,
     s_ld,s_ld2,
     s_lea,s_lsr,s_mul,s_neg,s_nop,
     s_or,s_orcc,s_psh,s_pul,
     s_rol,s_ror,s_rti,
     s_rts,s_rts2,s_rts3,
     s_sbc,s_sex,
     s_swi,
     s_st,s_st2,
     s_sub,
     s_fetch_swi_h,s_fetch_swi_l,
     s_sync,
     s_tst,
     s_unknow,s_dummy,s_dummy2,
     s_relative,
     s_extended,
     s_idx_5b_offset,s_idx_8_16b_offset,s_idx_8b_offset2,s_idx_16b_offset2,s_idx_16b_offset3,
     s_idx_dec,s_idx_decdec,s_idx_inc,s_idx_incinc,
     s_idx_reg_offset,
     s_idx_indirect,s_idx_indirect2,s_idx_indirect3,s_idx_indirect4,
     s_read_modify,s_read_modify16,s_write,
     s_immediate16);


  type t_operand is 
    (o_a_ra,o_b_rn,o_d_hi,o_x_ls,o_y_hs,o_s_cs,o_u_ne,o_one_eq,
     o_two_vc,o_three_vs,o_pl,o_mi,o_ge,o_lt,o_gt,o_le);
 
  type t_alu is 
    (a_plus8,a_plus8c,a_plus16,a_minus8,a_minus8c,a_minus16,a_or8,a_and8,
     a_rol8,a_ror8,a_asr8,a_lsl8,a_lsr8,a_assign8,a_assign16,a_tst8,
     a_neg8,a_clr,a_eor8,a_com8,a_inc8,a_dec8,a_tstz,a_sex8,
     a_dadj8,a_assign8_op2,a_assign16_op2,a_assign_ccr,a_assign_ccr_op2,
     a_and_ccr,a_or_ccr,a_mult,a_nop);                         

  type t_opcode_info is record
    mode        : t_mode;                       
    operand     : t_operand;                    
    instruction : t_cpu_state;
  end record t_opcode_info;                  

  function get_opcode_info(opcode : std_logic_vector(9 downto 0))  return t_opcode_info;
  function take_branch(ccr : std_logic_vector(7 downto 0); cond : t_operand) return std_logic;

  signal probe_a            : std_logic_vector( 7 downto 0);
  signal probe_b            : std_logic_vector( 7 downto 0);
  signal probe_x            : std_logic_vector(15 downto 0);
  signal probe_y            : std_logic_vector(15 downto 0);
  signal probe_u            : std_logic_vector(15 downto 0);
  signal probe_s            : std_logic_vector(15 downto 0);
  signal probe_pc           : std_logic_vector(15 downto 0);
  signal probe_cc           : std_logic_vector( 7 downto 0);
  signal probe_dp           : std_logic_vector( 7 downto 0);
  signal probe_state        : t_cpu_state;
  signal probe_next_state   : t_cpu_state;
  signal probe_refetch      : std_logic;
  signal probe_opcode       : std_logic_vector( 9 downto 0);

end package cpu_package;

----------------------------------------------------------------------
--      
----------------------------------------------------------------------
package body cpu_package is

  
  function get_opcode_info(opcode : std_logic_vector(9 downto 0)) return t_opcode_info is
  
    variable i : t_opcode_info;
  
  begin
  
    case opcode is                                                                                                                  
                                                                                                                                    
      when "0000000000" => i.mode := m_direct      ; i.instruction := s_neg    ; i.operand := o_a_ra     ; --  0x00
      when "0000000011" => i.mode := m_direct      ; i.instruction := s_com    ; i.operand := o_a_ra     ; --  0x03
      when "0000000100" => i.mode := m_direct      ; i.instruction := s_lsr    ; i.operand := o_a_ra     ; --  0x04
      when "0000000110" => i.mode := m_direct      ; i.instruction := s_ror    ; i.operand := o_a_ra     ; --  0x06
      when "0000000111" => i.mode := m_direct      ; i.instruction := s_asr    ; i.operand := o_a_ra     ; --  0x07
      when "0000001000" => i.mode := m_direct      ; i.instruction := s_lsl    ; i.operand := o_a_ra     ; --  0x08
      when "0000001001" => i.mode := m_direct      ; i.instruction := s_rol    ; i.operand := o_a_ra     ; --  0x09
      when "0000001010" => i.mode := m_direct      ; i.instruction := s_dec    ; i.operand := o_a_ra     ; --  0x0a
      when "0000001100" => i.mode := m_direct      ; i.instruction := s_inc    ; i.operand := o_a_ra     ; --  0x0c
      when "0000001101" => i.mode := m_direct      ; i.instruction := s_tst    ; i.operand := o_a_ra     ; --  0x0d
      when "0000001110" => i.mode := m_direct      ; i.instruction := s_jmp    ; i.operand := o_a_ra     ; --  0x0e
      when "0000001111" => i.mode := m_direct      ; i.instruction := s_clr    ; i.operand := o_a_ra     ; --  0x0f
      when "0000010000" => i.mode := m_inherent    ; i.instruction := s_unknow ; i.operand := o_a_ra     ; --  0x10  OPCODE10
      when "0000010001" => i.mode := m_inherent    ; i.instruction := s_unknow ; i.operand := o_a_ra     ; --  0x11  OPCODE11
      when "0000010010" => i.mode := m_inherent    ; i.instruction := s_nop    ; i.operand := o_a_ra     ; --  0x12
      when "0000010011" => i.mode := m_inherent    ; i.instruction := s_sync   ; i.operand := o_a_ra     ; --  0x13
      when "0000010110" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_a_ra     ; --  0x16
      when "0000010111" => i.mode := m_relative    ; i.instruction := s_lbsr   ; i.operand := o_a_ra     ; --  0x17
      when "0000011001" => i.mode := m_inherent    ; i.instruction := s_daa    ; i.operand := o_a_ra     ; --  0x19
      when "0000011010" => i.mode := m_immediate8  ; i.instruction := s_orcc   ; i.operand := o_a_ra     ; --  0x1a test
      when "0000011100" => i.mode := m_immediate8  ; i.instruction := s_andcc  ; i.operand := o_a_ra     ; --  0x1c
      when "0000011101" => i.mode := m_inherent    ; i.instruction := s_sex    ; i.operand := o_a_ra     ; --  0x1d
      when "0000011110" => i.mode := m_inherent    ; i.instruction := s_exg    ; i.operand := o_a_ra     ; --  0x1e
      when "0000011111" => i.mode := m_inherent    ; i.instruction := s_tfr    ; i.operand := o_a_ra     ; --  0x1f
      when "0000100000" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_a_ra     ; --  0x20
      when "0000100001" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_b_rn     ; --  0x21
      when "0000100010" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_d_hi     ; --  0x22
      when "0000100011" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_x_ls     ; --  0x23
      when "0000100100" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_y_hs     ; --  0x24
      when "0000100101" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_s_cs     ; --  0x25
      when "0000100110" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_u_ne     ; --  0x26
      when "0000100111" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_one_eq   ; --  0x27
      when "0000101000" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_two_vc   ; --  0x28
      when "0000101001" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_three_vs ; --  0x29
      when "0000101010" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_pl       ; --  0x2a
      when "0000101011" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_mi       ; --  0x2b
      when "0000101100" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_ge       ; --  0x2c
      when "0000101101" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_lt       ; --  0x2d
      when "0000101110" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_gt       ; --  0x2e
      when "0000101111" => i.mode := m_relative    ; i.instruction := s_b      ; i.operand := o_le       ; --  0x2f
      when "0000110000" => i.mode := m_indexed     ; i.instruction := s_lea    ; i.operand := o_x_ls     ; --  0x30
      when "0000110001" => i.mode := m_indexed     ; i.instruction := s_lea    ; i.operand := o_y_hs     ; --  0x31
      when "0000110010" => i.mode := m_indexed     ; i.instruction := s_lea    ; i.operand := o_s_cs     ; --  0x32
      when "0000110011" => i.mode := m_indexed     ; i.instruction := s_lea    ; i.operand := o_u_ne     ; --  0x33
      when "0000110100" => i.mode := m_inherent    ; i.instruction := s_psh    ; i.operand := o_s_cs     ; --  0x34  
      when "0000110101" => i.mode := m_inherent    ; i.instruction := s_pul    ; i.operand := o_s_cs     ; --  0x35  
      when "0000110110" => i.mode := m_inherent    ; i.instruction := s_psh    ; i.operand := o_u_ne     ; --  0x36  
      when "0000110111" => i.mode := m_inherent    ; i.instruction := s_pul    ; i.operand := o_u_ne     ; --  0x37  
      when "0000111001" => i.mode := m_inherent    ; i.instruction := s_rts    ; i.operand := o_a_ra     ; --  0x39  
      when "0000111010" => i.mode := m_inherent    ; i.instruction := s_abx    ; i.operand := o_a_ra     ; --  0x3a  
      when "0000111011" => i.mode := m_inherent    ; i.instruction := s_rti    ; i.operand := o_a_ra     ; --  0x3b  
      when "0000111100" => i.mode := m_inherent    ; i.instruction := s_cwait  ; i.operand := o_a_ra     ; --  0x3c  
      when "0000111101" => i.mode := m_inherent    ; i.instruction := s_mul    ; i.operand := o_a_ra     ; --  0x3d  
      when "0000111111" => i.mode := m_inherent    ; i.instruction := s_swi    ; i.operand := o_one_eq   ; --  0x3f  
      when "0001000000" => i.mode := m_inherent    ; i.instruction := s_neg    ; i.operand := o_a_ra     ; --  0x40
      when "0001000011" => i.mode := m_inherent    ; i.instruction := s_com    ; i.operand := o_a_ra     ; --  0x43
      when "0001000100" => i.mode := m_inherent    ; i.instruction := s_lsr    ; i.operand := o_a_ra     ; --  0x44
      when "0001000110" => i.mode := m_inherent    ; i.instruction := s_ror    ; i.operand := o_a_ra     ; --  0x46
      when "0001000111" => i.mode := m_inherent    ; i.instruction := s_asr    ; i.operand := o_a_ra     ; --  0x47
      when "0001001000" => i.mode := m_inherent    ; i.instruction := s_lsl    ; i.operand := o_a_ra     ; --  0x48
      when "0001001001" => i.mode := m_inherent    ; i.instruction := s_rol    ; i.operand := o_a_ra     ; --  0x49
      when "0001001010" => i.mode := m_inherent    ; i.instruction := s_dec    ; i.operand := o_a_ra     ; --  0x4a
      when "0001001100" => i.mode := m_inherent    ; i.instruction := s_inc    ; i.operand := o_a_ra     ; --  0x4c
      when "0001001101" => i.mode := m_inherent    ; i.instruction := s_tst    ; i.operand := o_a_ra     ; --  0x4d
      when "0001001111" => i.mode := m_inherent    ; i.instruction := s_clr    ; i.operand := o_a_ra     ; --  0x4f
      when "0001010000" => i.mode := m_inherent    ; i.instruction := s_neg    ; i.operand := o_b_rn     ; --  0x50
      when "0001010011" => i.mode := m_inherent    ; i.instruction := s_com    ; i.operand := o_b_rn     ; --  0x53
      when "0001010100" => i.mode := m_inherent    ; i.instruction := s_lsr    ; i.operand := o_b_rn     ; --  0x54
      when "0001010110" => i.mode := m_inherent    ; i.instruction := s_ror    ; i.operand := o_b_rn     ; --  0x56
      when "0001010111" => i.mode := m_inherent    ; i.instruction := s_asr    ; i.operand := o_b_rn     ; --  0x57
      when "0001011000" => i.mode := m_inherent    ; i.instruction := s_lsl    ; i.operand := o_b_rn     ; --  0x58
      when "0001011001" => i.mode := m_inherent    ; i.instruction := s_rol    ; i.operand := o_b_rn     ; --  0x59
      when "0001011010" => i.mode := m_inherent    ; i.instruction := s_dec    ; i.operand := o_b_rn     ; --  0x5a
      when "0001011100" => i.mode := m_inherent    ; i.instruction := s_inc    ; i.operand := o_b_rn     ; --  0x5c
      when "0001011101" => i.mode := m_inherent    ; i.instruction := s_tst    ; i.operand := o_b_rn     ; --  0x5d
      when "0001011111" => i.mode := m_inherent    ; i.instruction := s_clr    ; i.operand := o_b_rn     ; --  0x5f
      when "0001100000" => i.mode := m_indexed     ; i.instruction := s_neg    ; i.operand := o_a_ra     ; --  0x60
      when "0001100011" => i.mode := m_indexed     ; i.instruction := s_com    ; i.operand := o_a_ra     ; --  0x63
      when "0001100100" => i.mode := m_indexed     ; i.instruction := s_lsr    ; i.operand := o_a_ra     ; --  0x64
      when "0001100110" => i.mode := m_indexed     ; i.instruction := s_ror    ; i.operand := o_a_ra     ; --  0x66
      when "0001100111" => i.mode := m_indexed     ; i.instruction := s_asr    ; i.operand := o_a_ra     ; --  0x67
      when "0001101000" => i.mode := m_indexed     ; i.instruction := s_lsl    ; i.operand := o_a_ra     ; --  0x68
      when "0001101001" => i.mode := m_indexed     ; i.instruction := s_rol    ; i.operand := o_a_ra     ; --  0x69
      when "0001101010" => i.mode := m_indexed     ; i.instruction := s_dec    ; i.operand := o_a_ra     ; --  0x6a
      when "0001101100" => i.mode := m_indexed     ; i.instruction := s_inc    ; i.operand := o_a_ra     ; --  0x6c
      when "0001101101" => i.mode := m_indexed     ; i.instruction := s_tst    ; i.operand := o_a_ra     ; --  0x6d
      when "0001101110" => i.mode := m_indexed     ; i.instruction := s_jmp    ; i.operand := o_a_ra     ; --  0x6e
      when "0001101111" => i.mode := m_indexed     ; i.instruction := s_clr    ; i.operand := o_a_ra     ; --  0x6f
      when "0001110000" => i.mode := m_extended    ; i.instruction := s_neg    ; i.operand := o_a_ra     ; --  0x70
      when "0001110011" => i.mode := m_extended    ; i.instruction := s_com    ; i.operand := o_a_ra     ; --  0x73
      when "0001110100" => i.mode := m_extended    ; i.instruction := s_lsr    ; i.operand := o_a_ra     ; --  0x74
      when "0001110110" => i.mode := m_extended    ; i.instruction := s_ror    ; i.operand := o_a_ra     ; --  0x76
      when "0001110111" => i.mode := m_extended    ; i.instruction := s_asr    ; i.operand := o_a_ra     ; --  0x77
      when "0001111000" => i.mode := m_extended    ; i.instruction := s_lsl    ; i.operand := o_a_ra     ; --  0x78
      when "0001111001" => i.mode := m_extended    ; i.instruction := s_rol    ; i.operand := o_a_ra     ; --  0x79
      when "0001111010" => i.mode := m_extended    ; i.instruction := s_dec    ; i.operand := o_a_ra     ; --  0x7a
      when "0001111100" => i.mode := m_extended    ; i.instruction := s_inc    ; i.operand := o_a_ra     ; --  0x7c
      when "0001111101" => i.mode := m_extended    ; i.instruction := s_tst    ; i.operand := o_a_ra     ; --  0x7d
      when "0001111110" => i.mode := m_extended    ; i.instruction := s_jmp    ; i.operand := o_a_ra     ; --  0x7e
      when "0001111111" => i.mode := m_extended    ; i.instruction := s_clr    ; i.operand := o_a_ra     ; --  0x7f
      when "0010000000" => i.mode := m_immediate8  ; i.instruction := s_sub    ; i.operand := o_a_ra     ; --  0x80
      when "0010000001" => i.mode := m_immediate8  ; i.instruction := s_cmp    ; i.operand := o_a_ra     ; --  0x81
      when "0010000010" => i.mode := m_immediate8  ; i.instruction := s_sbc    ; i.operand := o_a_ra     ; --  0x82
      when "0010000011" => i.mode := m_immediate16 ; i.instruction := s_sub    ; i.operand := o_d_hi     ; --  0x83
      when "0010000100" => i.mode := m_immediate8  ; i.instruction := s_and    ; i.operand := o_a_ra     ; --  0x84
      when "0010000101" => i.mode := m_immediate8  ; i.instruction := s_bit    ; i.operand := o_a_ra     ; --  0x85
      when "0010000110" => i.mode := m_immediate8  ; i.instruction := s_ld     ; i.operand := o_a_ra     ; --  0x86
      when "0010001000" => i.mode := m_immediate8  ; i.instruction := s_eor    ; i.operand := o_a_ra     ; --  0x88
      when "0010001001" => i.mode := m_immediate8  ; i.instruction := s_adc    ; i.operand := o_a_ra     ; --  0x89
      when "0010001010" => i.mode := m_immediate8  ; i.instruction := s_or     ; i.operand := o_a_ra     ; --  0x8a
      when "0010001011" => i.mode := m_immediate8  ; i.instruction := s_add    ; i.operand := o_a_ra     ; --  0x8b
      when "0010001100" => i.mode := m_immediate16 ; i.instruction := s_cmp    ; i.operand := o_x_ls     ; --  0x8c
      when "0010001101" => i.mode := m_relative    ; i.instruction := s_bsr    ; i.operand := o_a_ra     ; --  0x8d
      when "0010001110" => i.mode := m_immediate16 ; i.instruction := s_ld     ; i.operand := o_x_ls     ; --  0x8e
      when "0010010000" => i.mode := m_direct      ; i.instruction := s_sub    ; i.operand := o_a_ra     ; --  0x90
      when "0010010001" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_a_ra     ; --  0x91
      when "0010010010" => i.mode := m_direct      ; i.instruction := s_sbc    ; i.operand := o_a_ra     ; --  0x92
      when "0010010011" => i.mode := m_direct      ; i.instruction := s_sub    ; i.operand := o_d_hi     ; --  0x93
      when "0010010100" => i.mode := m_direct      ; i.instruction := s_and    ; i.operand := o_a_ra     ; --  0x94
      when "0010010101" => i.mode := m_direct      ; i.instruction := s_bit    ; i.operand := o_a_ra     ; --  0x95
      when "0010010110" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_a_ra     ; --  0x96
      when "0010010111" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_a_ra     ; --  0x97
      when "0010011000" => i.mode := m_direct      ; i.instruction := s_eor    ; i.operand := o_a_ra     ; --  0x98
      when "0010011001" => i.mode := m_direct      ; i.instruction := s_adc    ; i.operand := o_a_ra     ; --  0x99
      when "0010011010" => i.mode := m_direct      ; i.instruction := s_or     ; i.operand := o_a_ra     ; --  0x9a
      when "0010011011" => i.mode := m_direct      ; i.instruction := s_add    ; i.operand := o_a_ra     ; --  0x9b
      when "0010011100" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_x_ls     ; --  0x9c
      when "0010011101" => i.mode := m_direct      ; i.instruction := s_jsr    ; i.operand := o_a_ra     ; --  0x9d
      when "0010011110" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_x_ls     ; --  0x9e
      when "0010011111" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_x_ls     ; --  0x9f
      when "0010100000" => i.mode := m_indexed     ; i.instruction := s_sub    ; i.operand := o_a_ra     ; --  0xa0
      when "0010100001" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_a_ra     ; --  0xa1
      when "0010100010" => i.mode := m_indexed     ; i.instruction := s_sbc    ; i.operand := o_a_ra     ; --  0xa2
      when "0010100011" => i.mode := m_indexed     ; i.instruction := s_sub    ; i.operand := o_d_hi     ; --  0xa3
      when "0010100100" => i.mode := m_indexed     ; i.instruction := s_and    ; i.operand := o_a_ra     ; --  0xa4
      when "0010100101" => i.mode := m_indexed     ; i.instruction := s_bit    ; i.operand := o_a_ra     ; --  0xa5
      when "0010100110" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_a_ra     ; --  0xa6
      when "0010100111" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_a_ra     ; --  0xa7
      when "0010101000" => i.mode := m_indexed     ; i.instruction := s_eor    ; i.operand := o_a_ra     ; --  0xa8
      when "0010101001" => i.mode := m_indexed     ; i.instruction := s_adc    ; i.operand := o_a_ra     ; --  0xa9
      when "0010101010" => i.mode := m_indexed     ; i.instruction := s_or     ; i.operand := o_a_ra     ; --  0xaa
      when "0010101011" => i.mode := m_indexed     ; i.instruction := s_add    ; i.operand := o_a_ra     ; --  0xab
      when "0010101100" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_x_ls     ; --  0xac
      when "0010101101" => i.mode := m_indexed     ; i.instruction := s_jsr    ; i.operand := o_a_ra     ; --  0xad
      when "0010101110" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_x_ls     ; --  0xae
      when "0010101111" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_x_ls     ; --  0xaf
      when "0010110000" => i.mode := m_extended    ; i.instruction := s_sub    ; i.operand := o_a_ra     ; --  0xb0
      when "0010110001" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_a_ra     ; --  0xb1
      when "0010110010" => i.mode := m_extended    ; i.instruction := s_sbc    ; i.operand := o_a_ra     ; --  0xb2
      when "0010110011" => i.mode := m_extended    ; i.instruction := s_sub    ; i.operand := o_d_hi     ; --  0xb3
      when "0010110100" => i.mode := m_extended    ; i.instruction := s_and    ; i.operand := o_a_ra     ; --  0xb4
      when "0010110101" => i.mode := m_extended    ; i.instruction := s_bit    ; i.operand := o_a_ra     ; --  0xb5
      when "0010110110" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_a_ra     ; --  0xb6
      when "0010110111" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_a_ra     ; --  0xb7
      when "0010111000" => i.mode := m_extended    ; i.instruction := s_eor    ; i.operand := o_a_ra     ; --  0xb8
      when "0010111001" => i.mode := m_extended    ; i.instruction := s_adc    ; i.operand := o_a_ra     ; --  0xb9
      when "0010111010" => i.mode := m_extended    ; i.instruction := s_or     ; i.operand := o_a_ra     ; --  0xba
      when "0010111011" => i.mode := m_extended    ; i.instruction := s_add    ; i.operand := o_a_ra     ; --  0xbb
      when "0010111100" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_x_ls     ; --  0xbc
      when "0010111101" => i.mode := m_extended    ; i.instruction := s_jsr    ; i.operand := o_a_ra     ; --  0xbd
      when "0010111110" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_x_ls     ; --  0xbe
      when "0010111111" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_x_ls     ; --  0xbf
      when "0011000000" => i.mode := m_immediate8  ; i.instruction := s_sub    ; i.operand := o_b_rn     ; --  0xc0
      when "0011000001" => i.mode := m_immediate8  ; i.instruction := s_cmp    ; i.operand := o_b_rn     ; --  0xc1
      when "0011000010" => i.mode := m_immediate8  ; i.instruction := s_sbc    ; i.operand := o_b_rn     ; --  0xc2
      when "0011000011" => i.mode := m_immediate16 ; i.instruction := s_add    ; i.operand := o_d_hi     ; --  0xc3
      when "0011000100" => i.mode := m_immediate8  ; i.instruction := s_and    ; i.operand := o_b_rn     ; --  0xc4
      when "0011000101" => i.mode := m_immediate8  ; i.instruction := s_bit    ; i.operand := o_b_rn     ; --  0xc5
      when "0011000110" => i.mode := m_immediate8  ; i.instruction := s_ld     ; i.operand := o_b_rn     ; --  0xc6
      when "0011001000" => i.mode := m_immediate8  ; i.instruction := s_eor    ; i.operand := o_b_rn     ; --  0xc8
      when "0011001001" => i.mode := m_immediate8  ; i.instruction := s_adc    ; i.operand := o_b_rn     ; --  0xc9
      when "0011001010" => i.mode := m_immediate8  ; i.instruction := s_or     ; i.operand := o_b_rn     ; --  0xca
      when "0011001011" => i.mode := m_immediate8  ; i.instruction := s_add    ; i.operand := o_b_rn     ; --  0xcb
      when "0011001100" => i.mode := m_immediate16 ; i.instruction := s_ld     ; i.operand := o_d_hi     ; --  0xcc
      when "0011001110" => i.mode := m_immediate16 ; i.instruction := s_ld     ; i.operand := o_u_ne     ; --  0xce
      when "0011010000" => i.mode := m_direct      ; i.instruction := s_sub    ; i.operand := o_b_rn     ; --  0xd0
      when "0011010001" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_b_rn     ; --  0xd1
      when "0011010010" => i.mode := m_direct      ; i.instruction := s_sbc    ; i.operand := o_b_rn     ; --  0xd2
      when "0011010011" => i.mode := m_direct      ; i.instruction := s_add    ; i.operand := o_d_hi     ; --  0xd3
      when "0011010100" => i.mode := m_direct      ; i.instruction := s_and    ; i.operand := o_b_rn     ; --  0xd4
      when "0011010101" => i.mode := m_direct      ; i.instruction := s_bit    ; i.operand := o_b_rn     ; --  0xd5
      when "0011010110" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_b_rn     ; --  0xd6
      when "0011010111" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_b_rn     ; --  0xd7
      when "0011011000" => i.mode := m_direct      ; i.instruction := s_eor    ; i.operand := o_b_rn     ; --  0xd8
      when "0011011001" => i.mode := m_direct      ; i.instruction := s_adc    ; i.operand := o_b_rn     ; --  0xd9
      when "0011011010" => i.mode := m_direct      ; i.instruction := s_or     ; i.operand := o_b_rn     ; --  0xda
      when "0011011011" => i.mode := m_direct      ; i.instruction := s_add    ; i.operand := o_b_rn     ; --  0xdb
      when "0011011100" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_d_hi     ; --  0xdc
      when "0011011101" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_d_hi     ; --  0xdd
      when "0011011110" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_u_ne     ; --  0xde
      when "0011011111" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_u_ne     ; --  0xdf
      when "0011100000" => i.mode := m_indexed     ; i.instruction := s_sub    ; i.operand := o_b_rn     ; --  0xe0
      when "0011100001" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_b_rn     ; --  0xe1
      when "0011100010" => i.mode := m_indexed     ; i.instruction := s_sbc    ; i.operand := o_b_rn     ; --  0xe2
      when "0011100011" => i.mode := m_indexed     ; i.instruction := s_add    ; i.operand := o_d_hi     ; --  0xe3
      when "0011100100" => i.mode := m_indexed     ; i.instruction := s_and    ; i.operand := o_b_rn     ; --  0xe4
      when "0011100101" => i.mode := m_indexed     ; i.instruction := s_bit    ; i.operand := o_b_rn     ; --  0xe5
      when "0011100110" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_b_rn     ; --  0xe6
      when "0011100111" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_b_rn     ; --  0xe7
      when "0011101000" => i.mode := m_indexed     ; i.instruction := s_eor    ; i.operand := o_b_rn     ; --  0xe8
      when "0011101001" => i.mode := m_indexed     ; i.instruction := s_adc    ; i.operand := o_b_rn     ; --  0xe9
      when "0011101010" => i.mode := m_indexed     ; i.instruction := s_or     ; i.operand := o_b_rn     ; --  0xea
      when "0011101011" => i.mode := m_indexed     ; i.instruction := s_add    ; i.operand := o_b_rn     ; --  0xeb
      when "0011101100" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_d_hi     ; --  0xec
      when "0011101101" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_d_hi     ; --  0xed
      when "0011101110" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_u_ne     ; --  0xee
      when "0011101111" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_u_ne     ; --  0xef
      when "0011110000" => i.mode := m_extended    ; i.instruction := s_sub    ; i.operand := o_b_rn     ; --  0xf0
      when "0011110001" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_b_rn     ; --  0xf1
      when "0011110010" => i.mode := m_extended    ; i.instruction := s_sbc    ; i.operand := o_b_rn     ; --  0xf2
      when "0011110011" => i.mode := m_extended    ; i.instruction := s_add    ; i.operand := o_d_hi     ; --  0xf3
      when "0011110100" => i.mode := m_extended    ; i.instruction := s_and    ; i.operand := o_b_rn     ; --  0xf4
      when "0011110101" => i.mode := m_extended    ; i.instruction := s_bit    ; i.operand := o_b_rn     ; --  0xf5
      when "0011110110" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_b_rn     ; --  0xf6
      when "0011110111" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_b_rn     ; --  0xf7
      when "0011111000" => i.mode := m_extended    ; i.instruction := s_eor    ; i.operand := o_b_rn     ; --  0xf8
      when "0011111001" => i.mode := m_extended    ; i.instruction := s_adc    ; i.operand := o_b_rn     ; --  0xf9
      when "0011111010" => i.mode := m_extended    ; i.instruction := s_or     ; i.operand := o_b_rn     ; --  0xfa
      when "0011111011" => i.mode := m_extended    ; i.instruction := s_add    ; i.operand := o_b_rn     ; --  0xfb
      when "0011111100" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_d_hi     ; --  0xfc
      when "0011111101" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_d_hi     ; --  0xfd
      when "0011111110" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_u_ne     ; --  0xfe
      when "0011111111" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_u_ne     ; --  0xff
      when "0100100001" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_b_rn     ; --  0x21
      when "0100100010" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_d_hi     ; --  0x22
      when "0100100011" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_x_ls     ; --  0x23
      when "0100100100" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_y_hs     ; --  0x24
      when "0100100101" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_s_cs     ; --  0x25
      when "0100100110" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_u_ne     ; --  0x26
      when "0100100111" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_one_eq   ; --  0x27
      when "0100101000" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_two_vc   ; --  0x28
      when "0100101001" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_three_vs ; --  0x29
      when "0100101010" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_pl       ; --  0x2a
      when "0100101011" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_mi       ; --  0x2b
      when "0100101100" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_ge       ; --  0x2c
      when "0100101101" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_lt       ; --  0x2d
      when "0100101110" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_gt       ; --  0x2e
      when "0100101111" => i.mode := m_relative    ; i.instruction := s_lb     ; i.operand := o_le       ; --  0x2f
      when "0100111111" => i.mode := m_inherent    ; i.instruction := s_swi    ; i.operand := o_two_vc   ; --  0x2f
      when "0110000011" => i.mode := m_immediate16 ; i.instruction := s_cmp    ; i.operand := o_d_hi     ; --  0x83
      when "0110001100" => i.mode := m_immediate16 ; i.instruction := s_cmp    ; i.operand := o_y_hs     ; --  0x8c
      when "0110001110" => i.mode := m_immediate16 ; i.instruction := s_ld     ; i.operand := o_y_hs     ; --  0x8e
      when "0110010011" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_d_hi     ; --  0x93
      when "0110011100" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_y_hs     ; --  0x9c
      when "0110011110" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_y_hs     ; --  0x9e
      when "0110011111" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_y_hs     ; --  0x9f
      when "0110100011" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_d_hi     ; --  0xa3
      when "0110101100" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_y_hs     ; --  0xac
      when "0110101110" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_y_hs     ; --  0xae
      when "0110101111" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_y_hs     ; --  0xaf
      when "0110110011" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_d_hi     ; --  0xb3
      when "0110111100" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_y_hs     ; --  0xbc
      when "0110111110" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_y_hs     ; --  0xbe
      when "0110111111" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_y_hs     ; --  0xbf
      when "0111001110" => i.mode := m_immediate16 ; i.instruction := s_ld     ; i.operand := o_s_cs     ; --  0xce
      when "0111011110" => i.mode := m_direct      ; i.instruction := s_ld     ; i.operand := o_s_cs     ; --  0xde
      when "0111011111" => i.mode := m_direct      ; i.instruction := s_st     ; i.operand := o_s_cs     ; --  0xdf
      when "0111101110" => i.mode := m_indexed     ; i.instruction := s_ld     ; i.operand := o_s_cs     ; --  0xee
      when "0111101111" => i.mode := m_indexed     ; i.instruction := s_st     ; i.operand := o_s_cs     ; --  0xef
      when "0111111110" => i.mode := m_extended    ; i.instruction := s_ld     ; i.operand := o_s_cs     ; --  0xfe
      when "0111111111" => i.mode := m_extended    ; i.instruction := s_st     ; i.operand := o_s_cs     ; --  0xff
      when "1000111111" => i.mode := m_inherent    ; i.instruction := s_swi    ; i.operand := o_three_vs ; --  0x3f
      when "1010000011" => i.mode := m_immediate16 ; i.instruction := s_cmp    ; i.operand := o_u_ne     ; --  0x83
      when "1010001100" => i.mode := m_immediate16 ; i.instruction := s_cmp    ; i.operand := o_s_cs     ; --  0x8c
      when "1010010011" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_u_ne     ; --  0x93
      when "1010011100" => i.mode := m_direct      ; i.instruction := s_cmp    ; i.operand := o_s_cs     ; --  0x9c
      when "1010100011" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_u_ne     ; --  0xa3
      when "1010101100" => i.mode := m_indexed     ; i.instruction := s_cmp    ; i.operand := o_s_cs     ; --  0xac
      when "1010110011" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_u_ne     ; --  0xb3
      when "1010111100" => i.mode := m_extended    ; i.instruction := s_cmp    ; i.operand := o_s_cs     ; --  0xbc
      when others       => i.mode := m_inherent    ; i.instruction := s_unknow ; i.operand := o_a_ra     ; --  others                                                                                                                               
    
    end case;
    
    return i;
  
  end function get_opcode_info;


  function take_branch(ccr : std_logic_vector(7 downto 0); cond : t_operand) return std_logic is
  
    variable hit : std_logic;  
  
  begin
  
    case cond is
    
      when o_a_ra     => hit := '1';
      when o_b_rn     => hit := '0';
      when o_d_hi     => hit := not(ccr(2) or ccr(0));
      when o_x_ls     => hit := ccr(2) or ccr(0);
      when o_y_hs     => hit := not(ccr(0));
      when o_s_cs     => hit := ccr(0);
      when o_u_ne     => hit := not(ccr(2));
      when o_one_eq   => hit := ccr(2);
      when o_two_vc   => hit := not(ccr(1));
      when o_three_vs => hit := ccr(1);
      when o_pl       => hit := not(ccr(3));
      when o_mi       => hit := ccr(3);
      when o_ge       => hit := not(ccr(1) xor ccr(3));
      when o_lt       => hit := ccr(1) xor ccr(3);
      when o_gt       => hit := not(ccr(2) or (ccr(1) xor ccr(3)));
      when o_le       => hit := ccr(2) or (ccr(1) xor ccr(3));
     
    end case;
  
    return hit;
  
  end function;

end package body cpu_package;
