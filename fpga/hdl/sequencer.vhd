----------------------------------------------------------------------
--
-- S3MO5 - cpu sequencer
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
use work.cpu_package.all;

entity sequencer is
  port
  (
     resetn            :  in std_logic;                     
     clk               :  in std_logic;                     
     clken             :  in std_logic;                     
     --
     nirq              :  in std_logic;
     nnmi              :  in std_logic;
     --                                                     
     busreq            : out std_logic;                     
     write             : out std_logic;
     rdata             :  in std_logic_vector( 7 downto 0);                     
     --                                                     
     refetch           :  in std_logic;                     
     opcode            :  in std_logic_vector( 9 downto 0);  
     ccr               :  in std_logic_vector( 7 downto 0); 
     --                                                     
     vector            : out std_logic_vector( 2 downto 0); 
     set_e             : out std_logic;                     
     set_f             : out std_logic;                     
     set_i             : out std_logic;                     
     clear_e           : out std_logic;                     
     --                                                     
     alu_mode          : out t_alu;                         
     alu_mux_sel       : out std_logic_vector( 3 downto 0); 
     index_mux_sel     : out std_logic_vector( 3 downto 0); 
     index_add_sel     : out std_logic;                     
     addr_mux_sel      : out std_logic_vector( 2 downto 0); 
     bytelane_mux_sel  : out std_logic;                     
     allreg_mux_sel    : out std_logic_vector( 1 downto 0);  
     mr_mux_sel        : out std_logic_vector( 1 downto 0);  
     pc_mux_sel        : out std_logic_vector( 1 downto 0); 
     x_mux_sel         : out std_logic;                     
     y_mux_sel         : out std_logic;                     
     u_mux_sel         : out std_logic;                     
     s_mux_sel         : out std_logic;                     
     ea_mux_sel        : out std_logic_vector( 3 downto 0); 
     dp_mux_sel        : out std_logic;                    
     mult_mux_sel      : out std_logic;                    
     --                                                     
     ab_en             : out std_logic_vector( 1 downto 0); 
     x_en              : out std_logic; 
     y_en              : out std_logic; 
     u_en              : out std_logic; 
     s_en              : out std_logic; 
     mr_en             : out std_logic;                     
     pc_en             : out std_logic; 
     dp_en             : out std_logic;                     
     cc_en             : out std_logic;                     
     ea_en             : out std_logic;                     
     op_en             : out std_logic;                     
     mw_en             : out std_logic                     
  );
end entity sequencer;

architecture rtl of sequencer is

  signal next_postbyte       : std_logic_vector( 7 downto 0);
  signal postbyte            : std_logic_vector( 7 downto 0);
  signal pushpull_mask       : std_logic_vector( 9 downto 0);
  signal next_pushpull_mask  : std_logic_vector( 9 downto 0);
  signal state               : t_cpu_state;
  signal next_state          : t_cpu_state;
  signal nmi_active          : std_logic;
  signal next_nmi_active     : std_logic;
  signal enter_nmi           : std_logic;
  signal next_enter_nmi      : std_logic;
  signal enter_irq           : std_logic;
  signal next_enter_irq      : std_logic;
  signal nnmi_resync         : std_logic;
  signal nirq_resync         : std_logic;

begin

  -- ---------------------------------------------------------------------------
  -- Probes
  -- ---------------------------------------------------------------------------
  probe_state      <= state;
  probe_next_state <= next_state;
  probe_opcode     <= opcode;

  -- ---------------------------------------------------------------------------
  -- Sequencer state machine
  -- ---------------------------------------------------------------------------
  
  p_sequencer_seq:process(clk,resetn)
  begin
  
    if resetn='0' then
    
      state         <= s_reset;
      postbyte      <= (others=>'0');
      pushpull_mask <= (others=>'0');
      nmi_active    <= '0';
      enter_irq     <= '0';
      enter_nmi     <= '0';
      nnmi_resync   <= '1';
      nirq_resync   <= '1';      
    
    elsif clk'event and clk='1' then
    
      if clken='1' then
    
        nnmi_resync    <= nnmi;
        nirq_resync    <= nirq;
        
        postbyte       <= next_postbyte;
        pushpull_mask  <= next_pushpull_mask;
        state          <= next_state;
        nmi_active     <= next_nmi_active;
        enter_irq      <= next_enter_irq;
        enter_nmi      <= next_enter_nmi;
        
      end if;
    
    end if;
  
  end process p_sequencer_seq;
  
  
  p_sequencer_comb:process(state,refetch,opcode,rdata,ccr,postbyte,pushpull_mask,nirq_resync,
                           nnmi_resync,nmi_active,enter_irq,enter_nmi)
  
    variable op_instr   : t_cpu_state;
    variable op_mode    : t_mode;
    variable op_operand : t_operand;
    variable op_info    : t_opcode_info  ;
  begin
   
    next_pushpull_mask <= pushpull_mask;
    next_postbyte      <= postbyte;
    next_state         <= s_unknow;
    next_nmi_active    <= nmi_active;
    next_enter_irq     <= '0';  
    next_enter_nmi     <= '0';
    --
    busreq             <= '0';      
    write              <= '0';      
    vector             <= "000";    
    set_e              <= '0';      
    set_f              <= '0';      
    set_i              <= '0';      
    clear_e            <= '0';      
    --                                                       
    alu_mode           <= a_nop;    
    alu_mux_sel        <= "0000";    
    index_mux_sel      <= "0000";    
    index_add_sel      <= '0';      
    addr_mux_sel       <= "000";    
    bytelane_mux_sel   <= '0';      
    allreg_mux_sel     <= "00";     
    mr_mux_sel         <= "00";     
    pc_mux_sel         <= "00";     
    x_mux_sel          <= '0';      
    y_mux_sel          <= '0';      
    u_mux_sel          <= '0';      
    s_mux_sel          <= '0';      
    ea_mux_sel         <= "0000"; 
    dp_mux_sel         <= '0';  
    mult_mux_sel       <= '0'; 
    --                                                       
    ab_en              <= "00";     
    x_en               <= '0';     
    y_en               <= '0';     
    u_en               <= '0';     
    s_en               <= '0';     
    mr_en              <= '0';      
    pc_en              <= '0';     
    dp_en              <= '0';      
    cc_en              <= '0';      
    ea_en              <= '0';      
    op_en              <= '0';      
    mw_en              <= '0';
    
    
    op_info            := get_opcode_info(opcode=>opcode);
    op_instr           := op_info.instruction;
    op_mode            := op_info.mode;
    op_operand         := op_info.operand;
    
    case state is                                                               
                                                                              
      -- -------------------------------------------------------------------    
      -- Fetch exception vectors                                           
      -- -------------------------------------------------------------------    
      when s_reset =>                                                           
        
        pc_mux_sel       <= "10";
        pc_en            <= '1';
        vector           <= "111";
        next_state       <= s_fetch_interrupt_h;                                         
                                                                                
      when s_fetch_interrupt_h=>
      
        busreq           <= '1';
        addr_mux_sel     <= "110";
        index_add_sel    <= '1';
        index_mux_sel    <= "0010";
        mr_en            <= '1';
        pc_en            <= '1';
        next_state       <= s_fetch_interrupt_l;                                         
      
      when s_fetch_interrupt_l=>
      
        busreq           <= '1';
        addr_mux_sel     <= "110";
        pc_mux_sel       <= "01";
        pc_en            <= '1';
        next_state       <= s_fetch;                                                 

      -- -------------------------------------------------------------------    
      -- Fetch and Decode, all simple inherent instructions                                                       
      -- -------------------------------------------------------------------    
      when s_fetch => 
      
        if nirq_resync='0' and ccr(4)='0' and 
           opcode(9 downto 1)/="000001000" and refetch='0' 
        then
       
          next_pushpull_mask <= (others=>'1');
          next_postbyte      <= (others=>'1');
          set_e              <= '1';
          cc_en              <= '1';
          next_enter_irq     <= '1';
          next_state         <= s_psh;
        
        elsif nnmi_resync='0' and nmi_active='0' and 
              opcode(9 downto 1)/="000001000" and refetch='0' 
        then
        
          next_pushpull_mask <= (others=>'1');
          next_postbyte      <= (others=>'1');
          set_e              <= '1';
          cc_en              <= '1';
          next_enter_nmi     <= '1';
          next_state         <= s_psh;
        
        else
        
          busreq        <= '1';
          addr_mux_sel  <= "110";
          index_mux_sel <= "0010";
          index_add_sel <= '1';
          pc_en         <= '1';
          op_en         <= '1';
  
          if refetch='1' then
      
            next_state <= s_fetch;
      
          else
      
            next_state <= s_decode;
      
          end if;
          
        end if;
      
      when s_decode =>
      
        busreq       <= '1';
        addr_mux_sel <= "110";
        
        case op_mode is
        
          -- ---------------------------------------------------------------
          -- DECODE/Immediate
          -- ---------------------------------------------------------------
          when m_immediate8=>
          
            index_mux_sel <= "0010";
            index_add_sel <= '1';
            pc_en         <= '1';
            cc_en         <= '1';
            
            case op_instr is
            
              when s_andcc =>
              
                alu_mode <= a_and_ccr;
                
              when s_orcc =>
              
                alu_mode <= a_or_ccr;
              
              when s_ld =>
              
                alu_mode <= a_assign8_op2;
                
                if op_operand=o_a_ra then
                
                  ab_en    <= "10";
                  
                else
       
                  ab_en    <= "01";
                
                end if;
               
              when s_sub =>
              
                alu_mode <= a_minus8;
                 
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
             
              when s_cmp =>
              
                alu_mode <= a_minus8;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  
                else
       
                  alu_mux_sel <= "0001";
                
                end if;
              
              when s_sbc =>
              
                alu_mode <= a_minus8c;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
               
              when s_and =>
              
                alu_mode <= a_and8;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
             
              when s_bit =>
              
                alu_mode <= a_and8;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  
                else
       
                  alu_mux_sel <= "0001";
                
                end if;
               
              when s_eor =>
              
                alu_mode <= a_eor8;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
            
              when s_adc =>
              
                alu_mode <= a_plus8c;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_or =>
              
                alu_mode <= a_or8;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
            
              when others=> -- s_add
              
                alu_mode <= a_plus8;
               
                if op_operand=o_a_ra then
                
                  alu_mux_sel <= "0000";
                  ab_en       <= "10";
                  
                else
       
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
             
            end case;
            
            next_state <= s_fetch;
            
          when m_immediate16=>
          
            index_mux_sel <= "0010";
            index_add_sel <= '1';
            pc_en         <= '1';
            mr_en         <= '1';
            next_state    <= s_immediate16;
          
          -- ---------------------------------------------------------------
          -- DECODE/Indexed
          -- ---------------------------------------------------------------
          
          when m_indexed => 
        
            addr_mux_sel  <= "110";
            index_mux_sel <= "0010";
            index_add_sel <= '1';
            pc_en         <= '1';
          
            if rdata(7)='0' then -- 5 bit offset
            
              next_postbyte <= rdata;
              mr_en         <= '1';
              next_state    <= s_idx_5b_offset;
            
            else
            
              case rdata(3 downto 0) is                     
                                                           
                when "0000"=> -- ,R+
                
                  case rdata(6 downto 5) is
        
                    when "00"  => ea_mux_sel <= "0010";
                    when "01"  => ea_mux_sel <= "0011";
                    when "10"  => ea_mux_sel <= "0100";
                    when others=> ea_mux_sel <= "0101";

                  end case;
                 
                  ea_en         <= '1';
                  next_postbyte <= rdata;
                  next_state    <= s_idx_inc;
                
                when "0001"=> -- ,R++
                
                  case rdata(6 downto 5) is
        
                    when "00"  => ea_mux_sel <= "0010";
                    when "01"  => ea_mux_sel <= "0011";
                    when "10"  => ea_mux_sel <= "0100";
                    when others=> ea_mux_sel <= "0101";

                  end case;
                 
                  ea_en         <= '1';
                  next_postbyte <= rdata;
                  next_state    <= s_idx_incinc;
                
                when "0010"=> -- ,-R 
                
                  next_postbyte <= rdata;
                  next_state    <= s_idx_dec;
                
                when "0011"=> -- ,-R 
                
                  next_postbyte <= rdata;
                  next_state    <= s_idx_decdec;
                
                when "0100"=> -- no-offset 
                  
                  case rdata(6 downto 5) is
                    
                    when "00"  => ea_mux_sel <= "0010";
                    when "01"  => ea_mux_sel <= "0011";
                    when "10"  => ea_mux_sel <= "0100";
                    when others=> ea_mux_sel <= "0101";
                  
                  end case;  
                
                  ea_en <= '1';
                  
                  if rdata(4)='0' then
                  
                    if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then
            
                      next_state <= op_instr;
                    
                    else
            
                      if op_operand=o_a_ra or op_operand=o_b_rn then
                    
                        next_state <= s_read_modify;
                      
                      else
                    
                        next_state <= s_read_modify16;
                      
                      end if;
                    
                    end if;    
                  
                  else
                    
                    next_state <= s_idx_indirect3;
                    
                  end if;
                
                when "0101"|"0110"|"1011"=> -- A,R ; B,R ; D,R 
                
                  next_postbyte <= rdata;
                  next_state    <= s_idx_reg_offset;
                                                           
                when "1000"|"1001"|"1100"|"1101"=> -- 8/16 bit offset with X;Y;U;S;PC
                
                  next_postbyte <= rdata;
                  next_state    <= s_idx_8_16b_offset;
               
                when "1111"=> -- [n]                   
                                                            
                  next_postbyte <= rdata;
                  next_state    <= s_idx_indirect;             
                
                when others =>                           
                                                            
                  next_state <= s_unknow;                
                                                           
              end case;                                     
         
            end if;
          
          -- ---------------------------------------------------------------
          -- DECODE/Inherent
          -- ---------------------------------------------------------------
          when m_inherent=>
            
            case op_instr is
            
              when s_nop =>
              
                next_state     <= s_fetch;
                
              when s_sync =>
              
                next_state     <= s_sync;
                  
              when s_daa =>
              
                alu_mode       <= a_dadj8;
                ab_en          <= "10";
                cc_en          <= '1';
                next_state     <= s_fetch;
                
              when s_sex =>
            
                alu_mux_sel    <= "0001";
                alu_mode       <= a_sex8;
                cc_en          <= '1';
                ab_en          <= "10";
                next_state     <= s_fetch;
              
              when s_exg =>
              
                index_mux_sel  <= "0010";
                index_add_sel  <= '1';
                pc_en          <= '1';
                next_postbyte  <= rdata;
                next_state     <= s_exg;

              when s_tfr =>
              
                index_mux_sel  <= "0010";
                index_add_sel  <= '1';
                pc_en          <= '1';
                next_postbyte  <= rdata;
                next_state     <= s_tfr;

              when s_psh   =>
              
                next_pushpull_mask <= (others=>'1');
                index_mux_sel  <= "0010";
                index_add_sel  <= '1';
                pc_en          <= '1';
                next_postbyte  <= rdata;
                next_state     <= s_psh;
             
              when s_pul   =>
              
                next_pushpull_mask <= (others=>'1');
                index_mux_sel  <= "0010";
                index_add_sel  <= '1';
                pc_en          <= '1';
                next_postbyte  <= rdata;
                next_state     <= s_pul;
              
              when s_rts =>
              
                next_pushpull_mask <= (others=>'1');
                next_postbyte      <= "10000000";
                next_state         <= s_pul; 

              when s_rti =>
              
                if nmi_active='1' then
                
                  next_nmi_active  <= '0';
                
                end if;
                
                next_pushpull_mask <= (others=>'1');
                next_postbyte      <= "11111111";
                next_state         <= s_pul; 
              
              when s_abx   =>
              
                ea_mux_sel    <= "0010";
                ea_en         <= '1';
                next_state    <= s_abx2;
              
              when s_mul   =>
              
                alu_mode     <= a_mult;
                alu_mux_sel  <= "0010";
                mult_mux_sel <= '1';
                ab_en        <= "11";
                cc_en        <= '1';
                next_state   <= s_fetch;
             
              when s_swi   =>
              
                next_pushpull_mask <= (others=>'1');
                next_postbyte      <= (others=>'1');
                set_e              <= '1';
                cc_en              <= '1';
                next_state         <= s_psh;
              
              when s_neg   =>
              
                alu_mode   <= a_neg8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
                
              
              when s_com   =>
       
                alu_mode   <= a_com8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
                
              when s_lsr   =>
              
                alu_mode   <= a_lsr8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_ror   =>
              
                alu_mode   <= a_ror8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_asr   =>
              
                alu_mode   <= a_asr8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_lsl   =>
              
                alu_mode   <= a_lsl8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_rol   =>
              
                alu_mode   <= a_rol8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_dec   =>
              
                alu_mode   <= a_dec8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_inc   =>
              
                alu_mode   <= a_inc8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when s_tst   =>
              
                alu_mode   <= a_tst8;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
              
              when others  => -- s_clr
           
                alu_mode   <= a_clr;
                cc_en      <= '1';
                next_state <= s_fetch;
                
                if op_operand=o_a_ra then
                
                  ab_en       <= "10";
                
                else
                
                  alu_mux_sel <= "0001";
                  ab_en       <= "01";
                
                end if;
            
            end case;
          
          -- ---------------------------------------------------------------
          -- DECODE/Direct
          -- ---------------------------------------------------------------
          when m_direct =>
          
            index_add_sel <= '1';
            index_mux_sel <= "0010";
            pc_en         <= '1';
            
            ea_mux_sel    <= "0001";
            ea_en         <= '1';
            
            if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then
            
              next_state <= op_instr;
              
            else
            
              if op_operand=o_a_ra or op_operand=o_b_rn then
              
                next_state <= s_read_modify;
                
              else
              
                next_state <= s_read_modify16;
                
              end if;
           
            end if;
         
          -- ---------------------------------------------------------------
          -- DECODE/Extended
          -- ---------------------------------------------------------------
          when m_extended=>
          
            index_add_sel <= '1';
            index_mux_sel <= "0010";
            pc_en         <= '1';
            mr_en         <= '1';
            
            next_state    <= s_extended;
          
          -- ---------------------------------------------------------------
          -- DECODE/relative
          -- ---------------------------------------------------------------
          when others   => 
          
            index_add_sel <= '1';
            pc_en         <= '1';
           
            if op_instr=s_bsr then
            
              --mr_mux_sel    <= "10";
              mr_en         <= '1';
              index_mux_sel <= "0010";
              next_state    <= s_bsr;
            
            elsif op_instr=s_lbsr then
            
              mr_en         <= '1';
              index_mux_sel <= "0010";
              next_state    <= s_lbsr;
              
            else
              
              if op_instr=s_b then
              
                mr_mux_sel    <= "10";
                if take_branch(ccr,op_operand)='1' then
            
                  index_mux_sel <= "0111";
                  next_state    <= op_instr;
                
                else
            
                  index_mux_sel <= "0010";
                  next_state    <= s_dummy;
            
                end if;
              
              else -- s_lb
            
                mr_en         <= '1';
                index_mux_sel <= "0010";
                addr_mux_sel  <= "110";
                next_state    <= s_lb;
            
              end if;
              
            end if;
              
        end case;      
    
      -- -------------------------------------------------------------------    
      -- Relative                                    
      -- -------------------------------------------------------------------    
      when s_b=>
      
        addr_mux_sel  <= "110";
        index_add_sel <= '1';
        index_mux_sel <= "0010";
        pc_en         <= '1';
        next_state    <= s_fetch;

      when s_lb=>
      
        busreq        <= '1';
        
        addr_mux_sel  <= "110";
        index_add_sel <= '1';
        index_mux_sel <= "0010";
        pc_en         <= '1';
        
        ea_mux_sel    <= "0001";
        ea_en         <= '1';
        
        if take_branch(ccr,op_operand)='1' then
        
          next_state <= s_lb2;
          
        else
        
          next_state <= s_fetch;
        
        end if;
        
      when s_lb2 =>
      
        addr_mux_sel  <= "110";
        index_add_sel <= '1';
        index_mux_sel <= "1000";
        pc_en         <= '1';
        next_state    <= s_fetch;

      -- -------------------------------------------------------------------    
      -- Indexed R++                                     
      -- -------------------------------------------------------------------    
      when s_idx_incinc =>
      
        index_add_sel <= '1';
        index_mux_sel <= "0010";
      
        case postbyte(6 downto 5) is
        
          when "00"  => -- X
          
            addr_mux_sel <= "000";
            x_en         <= '1';
          
          when "01"  => -- Y
          
            addr_mux_sel <= "001";
            y_en         <= '1';
          
          when "10"  => -- U
 
            addr_mux_sel <= "010";
            u_en         <= '1';
          
          when others=> -- S
            
            addr_mux_sel <= "011";
            s_en         <= '1';
       
        end case;
        
        next_state <= s_idx_inc;
      
      -- -------------------------------------------------------------------    
      -- Indexed R+                                      
      -- -------------------------------------------------------------------    
      when s_idx_inc =>
        
        index_add_sel <= '1';
        index_mux_sel <= "0010";
      
        case postbyte(6 downto 5) is
        
          when "00"  => -- X
          
            addr_mux_sel <= "000";
            x_en         <= '1';
          
          when "01"  => -- Y
          
            addr_mux_sel <= "001";
            y_en         <= '1';
          
          when "10"  => -- U
 
            addr_mux_sel <= "010";
            u_en         <= '1';
          
          when others=> -- S
            
            addr_mux_sel <= "011";
            s_en         <= '1';
       
        end case;
        
        if postbyte(4)='1' then
        
          next_state <= s_idx_indirect3;
        
        else
        
          if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then  
                                                                     
            next_state <= op_instr;                                  
                                                                     
          else                                                       
                                                                     
            if op_operand=o_a_ra or op_operand=o_b_rn then           
                                                                     
              next_state <= s_read_modify;                           
                                                                     
            else                                                     
                                                                     
              next_state <= s_read_modify16;                         
                                                                     
            end if;                                                  
                                                                    
          end if;                                                    
        
        end if;
        
      -- -------------------------------------------------------------------    
      -- Indexed --R                                        
      -- -------------------------------------------------------------------    
      when s_idx_decdec=>
      
        index_add_sel <= '1';
        index_mux_sel <= "0001";
        
        case postbyte(6 downto 5) is
        
          when "00"  => -- X
          
            addr_mux_sel <= "000";
            x_en         <= '1';
          
          when "01"  => -- Y
          
            addr_mux_sel <= "001";
            y_en         <= '1';
          
          when "10"  => -- U
 
            addr_mux_sel <= "010";
            u_en         <= '1';
          
          when others=> -- S
            
            addr_mux_sel <= "011";
            s_en         <= '1';
       
        end case;
        
        next_state <= s_idx_dec;
        
      -- -------------------------------------------------------------------    
      -- Indexed -R                                        
      -- -------------------------------------------------------------------    
      when s_idx_dec    =>
      
        index_add_sel <= '1';
        index_mux_sel <= "0001";
        ea_en         <= '1';
        
        case postbyte(6 downto 5) is
        
          when "00"  => --  X
          
            addr_mux_sel <= "000";
            x_en         <= '1';
          
          when "01"  => --  Y
          
            addr_mux_sel <= "001";
            y_en         <= '1';
          
          when "10"  => --  U
 
            addr_mux_sel <= "010";
            u_en         <= '1';
          
          when others=> --  S
            
            addr_mux_sel <= "011";
            s_en         <= '1';
       
        end case;
      
        if postbyte(4)='1' then
        
          next_state <= s_idx_indirect3;
        
        else
        
          if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then  
                                                                     
            next_state <= op_instr;                                  
                                                                     
          else                                                       
                                                                     
            if op_operand=o_a_ra or op_operand=o_b_rn then           
                                                                     
              next_state <= s_read_modify;                           
                                                                     
            else                                                     
                                                                     
              next_state <= s_read_modify16;                         
                                                                     
            end if;                                                  
                                                                    
          end if;                                                    
        
        end if;
      
      -- -------------------------------------------------------------------    
      -- Indexed 5/8/16 bits offset                                         
      -- -------------------------------------------------------------------    
      when s_idx_5b_offset =>
      
        mr_mux_sel    <= "01";
        index_mux_sel <= "0111";
        index_add_sel <= '1';
        addr_mux_sel  <= '0'&postbyte(6 downto 5);
        ea_en         <= '1';
        
        if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then    
                                                                     
          next_state <= op_instr;                                    
                                                                     
        else                                                         
                                                                     
          if op_operand=o_a_ra or op_operand=o_b_rn then             
                                                                     
            next_state <= s_read_modify;                             
                                                                     
          else                                                       
                                                                     
            next_state <= s_read_modify16;                           
                                                                     
          end if;                                                    
                                                                    
        end if;                                                      
      
      when s_idx_8_16b_offset =>
      
        busreq        <= '1';
        addr_mux_sel  <= "110";
        index_mux_sel <= "0010";
        index_add_sel <= '1';
        pc_en         <= '1';
        mr_en         <= '1';
        
        if postbyte(0)='0' then
        
          next_state <= s_idx_8b_offset2;
          
        else
        
          next_state <= s_idx_16b_offset2;
          
        end if;
        
      when s_idx_8b_offset2 =>
      
        
        index_add_sel <= '1';
        index_mux_sel <= "0111";
        mr_mux_sel    <= "11";
        ea_en         <= '1';
       
        if postbyte(2)='1' then
        
          addr_mux_sel <= "110";
        
        else
        
          addr_mux_sel  <= '0'&postbyte(6 downto 5);
        
        end if;
       
        if postbyte(4)='1' then
        
          next_state <= s_idx_indirect3;
        
        else
        
          if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then  
                                                                     
            next_state <= op_instr;                                  
                                                                     
          else                                                       
                                                                     
            if op_operand=o_a_ra or op_operand=o_b_rn then           
                                                                     
              next_state <= s_read_modify;                           
                                                                     
            else                                                     
                                                                     
              next_state <= s_read_modify16;                         
                                                                     
            end if;                                                  
                                                                    
          end if;                                                    
        
        end if;

      when s_idx_16b_offset2 =>
      
        busreq        <= '1';
        addr_mux_sel  <= "110";
        index_add_sel <= '1';
        index_mux_sel <= "0010";
        pc_en         <= '1';
        
        ea_mux_sel    <= "0001";
        ea_en         <= '1';
        
        next_state    <= s_idx_16b_offset3;
        
      when s_idx_16b_offset3 =>

        index_add_sel <= '1';
        index_mux_sel <= "1000";
        ea_en         <= '1';
       
        if postbyte(2)='1' then
        
          addr_mux_sel <= "110";
        
        else
        
          addr_mux_sel  <= '0'&postbyte(6 downto 5);
        
        end if;
 
        if postbyte(4)='1' then
        
          next_state <= s_idx_indirect3;
        
        else
        
          if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then  
                                                                     
            next_state <= op_instr;                                  
                                                                     
          else                                                       
                                                                     
            if op_operand=o_a_ra or op_operand=o_b_rn then           
                                                                     
              next_state <= s_read_modify;                           
                                                                     
            else                                                     
                                                                     
              next_state <= s_read_modify16;                         
                                                                     
            end if;                                                  
                                                                    
          end if;                                                    
        
        end if;

      -- -------------------------------------------------------------------    
      -- Indexed A,B,D offset                                         
      -- -------------------------------------------------------------------    
      when s_idx_reg_offset =>

        index_add_sel <= '1';
        addr_mux_sel  <= '0'&postbyte(6 downto 5);
        ea_en         <= '1';
        
        if postbyte(3)='1' then 
        
          index_mux_sel <= "0101"; -- D
        
        else
        
          if postbyte(0)='0' then 
          
            index_mux_sel <= "0011"; -- A
          
          else  
          
            index_mux_sel <= "0100"; -- B
          
          end if;
        
        end if;
        
        if postbyte(4)='1' then
        
          next_state <= s_idx_indirect3;
        
        else
        
          if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then  
                                                                     
            next_state <= op_instr;                                  
                                                                     
          else                                                       
                                                                     
            if op_operand=o_a_ra or op_operand=o_b_rn then           
                                                                     
              next_state <= s_read_modify;                           
                                                                     
            else                                                     
                                                                     
              next_state <= s_read_modify16;                         
                                                                     
            end if;                                                  
                                                                    
          end if;                                                    
        
        end if;
      
      -- -------------------------------------------------------------------    
      -- Indirect addressing                                               
      -- -------------------------------------------------------------------    
      when s_idx_indirect=>
      
        busreq        <= '1';
        addr_mux_sel  <= "110";
        index_mux_sel <= "0010";
        index_add_sel <= '1';
        pc_en         <= '1';
        mr_en         <= '1';
        next_state    <= s_idx_indirect2;
      
      when s_idx_indirect2=>
      
        busreq        <= '1';
        addr_mux_sel  <= "110";
        index_mux_sel <= "0010";
        index_add_sel <= '1';
        pc_en         <= '1';
        ea_mux_sel    <= "0001";
        ea_en         <= '1';
        next_state    <= s_idx_indirect3;
      
      --
      -- entry point for other indirect modes
      --
      when s_idx_indirect3=>
      
        busreq        <= '1';
        addr_mux_sel  <= "100";
        index_add_sel <= '1';
        index_mux_sel <= "0010";
        ea_en         <= '1';
        mr_en         <= '1';
        next_state    <= s_idx_indirect4;
        
      when s_idx_indirect4=>
      
        busreq        <= '1';
        addr_mux_sel  <= "100";
        ea_mux_sel    <= "0001";
        ea_en         <= '1';
       
        if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then    
                                                                     
          next_state <= op_instr;                                    
                                                                     
        else                                                         
                                                                     
          if op_operand=o_a_ra or op_operand=o_b_rn then             
                                                                     
            next_state <= s_read_modify;                             
                                                                     
          else                                                       
                                                                     
            next_state <= s_read_modify16;                           
                                                                     
          end if;                                                    
                                                                    
        end if;                                                      
       
      -- -------------------------------------------------------------------    
      -- Extended                                      
      -- -------------------------------------------------------------------    
      when s_extended=>
      
        busreq        <= '1';
        addr_mux_sel  <= "110";
        index_add_sel <= '1';
        index_mux_sel <= "0010";
        pc_en         <= '1';
        
        ea_mux_sel    <= "0001";
        ea_en         <= '1';
        
        if op_instr=s_st or op_instr=s_jmp or op_instr=s_jsr then    
                                                                     
          next_state <= op_instr;                                    
                                                                     
        else                                                         
                                                                     
          if op_operand=o_a_ra or op_operand=o_b_rn then             
                                                                     
            next_state <= s_read_modify;                             
                                                                     
          else                                                       
                                                                     
            next_state <= s_read_modify16;                           
                                                                     
          end if;                                                    
                                                                    
        end if;                                                      

      -- -------------------------------------------------------------------    
      -- Read, Modify and Write                                          
      -- -------------------------------------------------------------------    
      when s_read_modify16=>
      
        if op_instr=s_lea then
        
          addr_mux_sel  <= "100";
          index_add_sel <= '1';
          index_mux_sel <= "0000";
          
          case op_operand is
          
            when o_x_ls  => 
              
              alu_mode    <= a_tstz;
              alu_mux_sel <= "0111";
              cc_en       <= '1';
              x_en        <= '1';
            
            when o_y_hs  => 
            
              alu_mode    <= a_tstz;
              alu_mux_sel <= "0111";
              cc_en       <= '1';
              y_en        <= '1';
             
            when o_u_ne  => 
            
              u_en <= '1';
            
            when others=> 
            
              s_en <= '1';
          
          end case;
        
          next_state <= s_fetch;
        
        else
        
          busreq        <= '1';
        
          if op_mode=m_direct then
        
            addr_mux_sel <= "101";
        
          else
        
            addr_mux_sel <= "100";
        
          end if;
        
          index_add_sel <= '1';
          index_mux_sel <= "0010";
          ea_en         <= '1';
          mr_en         <= '1';
          next_state    <= s_read_modify;
          
        end if;
      
      when s_read_modify=>
      
        busreq       <= '1';
        
        if op_mode=m_direct then
        
          addr_mux_sel <= "101";
        
        else
        
          addr_mux_sel <= "100";
        
        end if;
        
        cc_en        <= '1';
        
        case op_instr is
        
          --
          -- read-modify-write instructions
          --
          when s_neg =>
          
            alu_mode    <= a_neg8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_com =>
          
            alu_mode    <= a_com8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_lsr =>
          
            alu_mode    <= a_lsr8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_ror =>
          
            alu_mode    <= a_ror8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_asr =>
          
            alu_mode    <= a_asr8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_lsl =>
          
            alu_mode    <= a_lsl8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_rol =>
          
            alu_mode    <= a_rol8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_dec =>
          
            alu_mode    <= a_dec8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          when s_inc =>
          
            alu_mode    <= a_inc8;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          
          when s_clr =>
          
            alu_mode    <= a_clr;
            alu_mux_sel <= "1000";
            mw_en       <= '1';
            next_state  <= s_write;
          
          --
          -- read-modify instructions
          --
          when s_tst =>
          
            alu_mode    <= a_tst8;
            alu_mux_sel <= "1000";
            mr_en       <= '1';
            next_state  <= s_fetch;
         
          when s_sub =>
          
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mode    <= a_minus8;
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            elsif op_operand=o_b_rn then
            
              alu_mode    <= a_minus8;
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            else
            
              alu_mode    <= a_minus16;
              alu_mux_sel <= "0010"; 
              ab_en       <= "11";
            
            end if;
          
          when s_cmp =>
          
            next_state <= s_fetch;
            
            case op_operand is
            
              when o_a_ra=> 
              
                alu_mux_sel <= "0000";
                alu_mode    <= a_minus8;
              
              when o_b_rn=> 
              
                alu_mux_sel <= "0001";
                alu_mode    <= a_minus8;
              
              when o_d_hi=> 
              
                alu_mux_sel <= "0010";
                alu_mode    <= a_minus16;
              
              when o_x_ls=>
               
                alu_mux_sel <= "0011";
                alu_mode    <= a_minus16;
              
              when o_y_hs=> 
               
                alu_mux_sel <= "0100";
                alu_mode    <= a_minus16;
             
              when o_u_ne=> 
                
                alu_mux_sel <= "0101";
                alu_mode    <= a_minus16;
             
              when others=> 
                
                alu_mux_sel <= "0110";
                alu_mode    <= a_minus16;
             
            end case;
          
          when s_add =>
          
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mode    <= a_plus8;
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            elsif op_operand=o_b_rn then
            
              alu_mode    <= a_plus8;
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            else
            
              alu_mode    <= a_plus16;
              alu_mux_sel <= "0010"; 
              ab_en       <= "11";
            
            end if;
          
          when s_bit =>
          
            alu_mode   <= a_and8;
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mux_sel <= "0000"; 
            
            else 
            
              alu_mux_sel <= "0001"; 
            
            end if;
          
          when s_eor =>
          
            alu_mode   <= a_eor8;
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            else 
            
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            end if;
          
          when s_adc =>
          
            alu_mode   <= a_plus8c;
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            else 
            
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            end if;
         
          when s_sbc =>
          
            alu_mode   <= a_minus8c;
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            else 
            
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            end if;
          
          when s_or =>
           
            alu_mode   <= a_or8;
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            else 
            
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            end if;
          
          when s_and =>
           
            alu_mode   <= a_and8;
            next_state <= s_fetch;
            
            if op_operand=o_a_ra then
          
              alu_mux_sel <= "0000"; 
              ab_en       <= "10";
            
            else 
            
              alu_mux_sel <= "0001"; 
              ab_en       <= "01";
            
            end if;
            
          when others => -- s_ld
          
            next_state <= s_fetch;
            case op_operand is
            
              when o_a_ra=>
              
                alu_mode  <= a_assign8_op2;
                ab_en     <= "10";
               
              when o_b_rn=> 
              
                alu_mode  <= a_assign8_op2;
                ab_en     <= "01";
              
              when o_d_hi=> 
             
                alu_mode  <= a_assign16_op2;
                ab_en     <= "11";
              
              when o_x_ls=>
              
                alu_mode  <= a_assign16_op2;
                x_mux_sel <= '1';
                x_en      <= '1';
              
              when o_y_hs=> 
              
                alu_mode  <= a_assign16_op2;
                y_mux_sel <= '1';
                y_en      <= '1';
              
              when o_u_ne=> 
              
                alu_mode  <= a_assign16_op2;
                u_mux_sel <= '1';
                u_en      <= '1';
              
              when others=> -- S
            
                alu_mode  <= a_assign16_op2;
                s_mux_sel <= '1';
                s_en      <= '1';
              
            end case;
        
        end case;
        
      when s_write=>
       
        busreq       <= '1';
        write        <= '1';
        next_state   <= s_fetch;
        
        if op_mode=m_direct then
        
          addr_mux_sel <= "101";
        
        else
        
          addr_mux_sel <= "100";
        
        end if;
        
        
      -- -------------------------------------------------------------------    
      -- Immediate16                                           
      -- -------------------------------------------------------------------    
      when s_immediate16 =>
      
        busreq        <= '1';
        addr_mux_sel  <= "110";
        index_add_sel <= '1';
        index_mux_sel <= "0010";
        pc_en         <= '1';
        
        case op_instr is
        
          when s_add=>
          
            alu_mode      <= a_plus16;
            alu_mux_sel   <= "0010";
            ab_en         <= "11";
            cc_en         <= '1';
            next_state    <= s_dummy;
          
          when s_sub=>
          
            addr_mux_sel  <= "110";
            index_add_sel <= '1';
            index_mux_sel <= "0010";
            pc_en         <= '1';
            alu_mode      <= a_minus16;
            alu_mux_sel   <= "0010";
            ab_en         <= "11";
            cc_en         <= '1';
            next_state    <= s_dummy;
          
          when s_cmp=>
          
            alu_mode <= a_minus16;
            cc_en    <= '1';
            
            case op_operand is
            
              when o_d_hi=> alu_mux_sel <= "0010";
              when o_x_ls=> alu_mux_sel <= "0011";
              when o_y_hs=> alu_mux_sel <= "0100";
              when o_u_ne=> alu_mux_sel <= "0101";
              when others=> alu_mux_sel <= "0110"; 
            
            end case;
            
            next_state  <= s_dummy;
          
          when others=> -- s_ld
          
            cc_en    <= '1';
            alu_mode <= a_assign16_op2;
            
            case op_operand is
            
              when o_d_hi=>
              
                ab_en    <= "11"; 
              
              when o_x_ls=> 
              
                x_mux_sel <= '1';
                x_en      <= '1';
              
              when o_y_hs=> 
              
                y_mux_sel <= '1';
                y_en      <= '1';
              
              when o_u_ne=> 
              
                u_mux_sel <= '1';
                u_en      <= '1';
              
              when others=> 
              
                s_mux_sel <= '1';
                s_en      <= '1';
            
            end case;
            
            next_state <= s_fetch;
          
        end case;
     
      -- -------------------------------------------------------------------    
      -- JSR                                           
      -- -------------------------------------------------------------------    
      when s_jsr =>
      
        addr_mux_sel     <= "011";
        index_add_sel    <= '1';
        index_mux_sel    <= "0001";
        s_en             <= '1';
        allreg_mux_sel   <= "10";
        mw_en            <= '1';
        next_state       <= s_jsr2;
        
      when s_jsr2 =>
      
        busreq           <= '1';
        write            <= '1';
        addr_mux_sel     <= "011";
        index_add_sel    <= '1';
        index_mux_sel    <= "0001";
        s_en             <= '1';
        allreg_mux_sel   <= "10";
        bytelane_mux_sel <= '1';
        mw_en            <= '1';
        next_state       <= s_jsr3;
        
      when s_jsr3 =>
        
        busreq           <= '1';
        write            <= '1';
        addr_mux_sel     <= "011";
        next_state       <= s_jmp;
        
      -- -------------------------------------------------------------------    
      -- JMP                                           
      -- -------------------------------------------------------------------    
      when s_jmp =>
      
        if op_mode=m_direct then
        
          addr_mux_sel <= "101";
        
        else
        
          addr_mux_sel <= "100";
        
        end if;
   
        index_add_sel    <= '1';
        index_mux_sel    <= "0000";
        pc_en            <= '1';
        next_state       <= s_fetch;
      
      -- -------------------------------------------------------------------    
      -- BSR
      -- -------------------------------------------------------------------    
      when s_bsr =>
      
        addr_mux_sel     <= "011";
        index_add_sel    <= '1';
        index_mux_sel    <= "0001";
        s_en             <= '1';
        allreg_mux_sel   <= "10";
        mw_en            <= '1';
        next_state       <= s_bsr2;
      
      when s_bsr2 =>
              
        busreq           <= '1';
        write            <= '1';
        addr_mux_sel     <= "011";
        index_add_sel    <= '1';
        index_mux_sel    <= "0001";
        s_en             <= '1';
        allreg_mux_sel   <= "10";
        bytelane_mux_sel <= '1';
        mw_en            <= '1';
        next_state       <= s_bsr3;
      
      when s_bsr3 =>
        
        busreq           <= '1';
        write            <= '1';
        addr_mux_sel     <= "011";
        next_state       <= s_bsr4;
        
      when s_bsr4 =>
      
        addr_mux_sel     <= "110";
        index_mux_sel    <= "0111";
        index_add_sel    <= '1';
        mr_mux_sel       <= "11";
        pc_en            <= '1';
        next_state       <= s_fetch;
       
      -- -------------------------------------------------------------------    
      -- LBSR
      -- -------------------------------------------------------------------    
      -- o read busreq 
      -- o PC+1     -> PC
      -- o MR&rdata -> EA
      -- -------------------------------------------------------------------    
      when s_lbsr=>
      
        busreq          <= '1';
        index_add_sel   <= '1';
        index_mux_sel   <= "0010";
        pc_en           <= '1';
        addr_mux_sel    <= "110";
        ea_mux_sel      <= "0001";
        ea_en           <= '1';
        next_state      <= s_lbsr2;

      -- -------------------------------------------------------------------    
      -- o S-1 -> S
      -- o PC[7:0]->MW
      -- -------------------------------------------------------------------    
      when s_lbsr2 =>
      
        addr_mux_sel     <= "011";
        index_add_sel    <= '1';
        index_mux_sel    <= "0001";
        s_en             <= '1';
        allreg_mux_sel   <= "10";
        mw_en            <= '1';
        next_state       <= s_lbsr3;
        
      -- -------------------------------------------------------------------    
      -- 
      -- -------------------------------------------------------------------    
      when s_lbsr3 =>
      
        busreq           <= '1';
        write            <= '1';
        addr_mux_sel     <= "011";
        index_add_sel    <= '1';
        index_mux_sel    <= "0001";
        s_en             <= '1';
        allreg_mux_sel   <= "10";
        bytelane_mux_sel <= '1';
        mw_en            <= '1';
        next_state       <= s_lbsr4;
        
      when s_lbsr4 =>
        
        busreq           <= '1';
        write            <= '1';
        addr_mux_sel     <= "011";
        next_state       <= s_lbsr5;
        
      when s_lbsr5 =>
      
        addr_mux_sel     <= "110";
        index_add_sel    <= '1';
        index_mux_sel    <= "1000";
        pc_en            <= '1';
        next_state       <= s_fetch;   
        
      -- -------------------------------------------------------------------    
      -- ST                                           
      -- -------------------------------------------------------------------    
      when s_st=>
      
        mw_en         <= '1';
        
        case op_operand is
             
          when o_a_ra=>
          
            alu_mode         <= a_assign8;
            alu_mux_sel      <= "0000";
            next_state       <= s_write;
            cc_en            <= '1';
              
          when o_b_rn=> 
          
            alu_mode         <= a_assign8;
            alu_mux_sel      <= "0001";
            next_state       <= s_write;
            cc_en            <= '1';
             
          when o_d_hi=>  
          
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0010";
            bytelane_mux_sel <= '1';
            next_state       <= s_st2;
          
          when o_x_ls=>    
         
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0011";
            bytelane_mux_sel <= '1';
            next_state       <= s_st2;
            
          when o_y_hs=>       
          
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0100";
            bytelane_mux_sel <= '1';
            next_state       <= s_st2;
             
          when o_u_ne=>          
     
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0101";
            bytelane_mux_sel <= '1';
            next_state       <= s_st2;
          
          when others=>        
          
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0110";
            bytelane_mux_sel <= '1';
            next_state       <= s_st2;
        
        end case;
        
      when s_st2=>
      
        busreq        <= '1';
        write         <= '1';
        index_mux_sel <= "0010";
        index_add_sel <= '1';
        ea_en         <= '1';
        mw_en         <= '1';
        cc_en         <= '1';
        
        if op_mode=m_direct then
        
          addr_mux_sel <= "101";
          
        else
        
          addr_mux_sel <= "100";
        
        end if;
        
        case op_operand is
             
          when o_d_hi=>  
          
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0010";
            next_state       <= s_write;
          
          when o_x_ls=>    
         
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0011";
            next_state       <= s_write;
            
          when o_y_hs=>       
          
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0100";
            next_state       <= s_write;
             
          when o_u_ne=>          
     
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0101";
            next_state       <= s_write;
          
          when others=>        
          
            alu_mode         <= a_assign16;
            alu_mux_sel      <= "0110";
            next_state       <= s_write;
        
        end case;
         
      -- -------------------------------------------------------------------    
      -- TFR  (6 cycles)                                             
      -- -------------------------------------------------------------------    
      when s_tfr=>
      
        ea_en         <= '1';
        
        -- source register
        case postbyte(7 downto 4) is
        
          when "0000"=> -- D
          
            index_mux_sel <= "0101";
            ea_mux_sel    <= "0000";
          
          when "0001"=> -- X
          
            ea_mux_sel    <= "0010";
            
          when "0010"=> -- Y
          
            ea_mux_sel    <= "0011";

          when "0011"=> -- U
          
            ea_mux_sel    <= "0100";

          when "0100"=> -- S
          
            ea_mux_sel    <= "0101";

          when "0101"=> -- PC
          
            addr_mux_sel  <= "110";
            index_add_sel <= '1';

          when "1000"=> -- A
          
            index_mux_sel <= "0011";

          when "1001"=> -- B
          
            index_mux_sel <= "0100";
 
          when "1010"=> -- CC
          
            ea_mux_sel <= "0110";
           
          when others=> -- DP 
          
            ea_mux_sel <= "0111";
          
        end case;
        
        next_state <= s_tfr2;

      when s_tfr2 =>
        
        -- destination register
        case postbyte(3 downto 0) is
        
          when "0000"=> -- D
          
            alu_mode    <= a_assign16;
            alu_mux_sel <= "0111";
            ab_en       <= "11";
          
          when "0001"=> -- X
          
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            x_en          <= '1';
          
          when "0010"=> -- Y
          
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            y_en          <= '1';
          
          when "0011"=> -- U
            
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            u_en          <= '1';
          
          when "0100"=> -- S
          
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            s_en          <= '1';
            
          when "0101"=> -- PC
          
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            pc_en          <= '1';
          
          when "1000"=> -- A
          
            alu_mode    <= a_assign8;
            alu_mux_sel <= "0111";
            ab_en       <= "10";
          
          when "1001"=> -- B
            
            alu_mode    <= a_assign8;
            alu_mux_sel <= "0111";
            ab_en       <= "01";
         
          when "1010"=> -- CC
          
            alu_mode    <= a_assign_ccr;
            cc_en       <= '1';
          
          when others=> -- DP 
          
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            dp_en         <= '1';
          
        end case;
        
        next_state <= s_dummy2;
        
      -- -------------------------------------------------------------------    
      -- EXG  (7 cycles)  
      --
      -- s_exg   R0->EA
      -- s_exg2  EA->R1 ; R1->EA
      -- s_exg3  EA->R0  
      --                                      
      -- -------------------------------------------------------------------    
      when s_exg=>
      
        ea_en         <= '1';
        
        -- source register
        case postbyte(7 downto 4) is
        
          when "0000"=> -- D
          
            index_mux_sel <= "0101";
            ea_mux_sel    <= "0000";
          
          when "0001"=> -- X
          
            ea_mux_sel    <= "0010";
            
          when "0010"=> -- Y
          
            ea_mux_sel    <= "0011";

          when "0011"=> -- U
          
            ea_mux_sel    <= "0100";

          when "0100"=> -- S
          
            ea_mux_sel    <= "0101";

          when "0101"=> -- PC
          
            addr_mux_sel  <= "110";
            index_add_sel <= '1';

          when "1000"=> -- A
          
            index_mux_sel <= "0011";

          when "1001"=> -- B
          
            index_mux_sel <= "0100";
 
          when "1010"=> -- CC
          
            ea_mux_sel <= "0110";
           
          when others=> -- DP 
          
            ea_mux_sel <= "0111";
          
        end case;
        
        next_state <= s_exg2;

      when s_exg2 =>
        
        ea_en         <= '1';
        
        -- destination register
        case postbyte(3 downto 0) is
        
          when "0000"=> -- D
          
            -- EA->D
            alu_mode      <= a_assign16;
            alu_mux_sel   <= "0111";
            ab_en         <= "11";
            
            -- D->EA
            index_mux_sel <= "0101";
            index_add_sel <= '0';
            ea_mux_sel    <= "0000";
          
          when "0001"=> -- X
          
            -- EA->X
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            x_en          <= '1';
          
            -- X->EA
            ea_mux_sel    <= "0010";
          
          when "0010"=> -- Y
          
            -- EA->Y
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            y_en          <= '1';
        
            -- Y->EA
            ea_mux_sel    <= "0011";
          
          when "0011"=> -- U
            
            -- EA->U
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            u_en          <= '1';
            
            -- U->EA
            ea_mux_sel    <= "0100";
          
          when "0100"=> -- S
          
            -- EA->S
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            s_en          <= '1';

            -- S->EA
            ea_mux_sel    <= "0101";
            
          when "0101"=> -- PC
          
            -- EA->PC
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            pc_en         <= '1';
          
            -- PC->EA
            ea_mux_sel    <= "1000";
          
          when "1000"=> -- A
          
            -- EA->A
            alu_mode    <= a_assign8;
            alu_mux_sel <= "0111";
            ab_en       <= "10";
            
            -- A->EA
            index_mux_sel <= "0011";
            index_add_sel <= '0';
            ea_mux_sel    <= "0000";
          
          when "1001"=> -- B
            
            -- EA->B
            alu_mode    <= a_assign8;
            alu_mux_sel <= "0111";
            ab_en       <= "01";
            
            -- B->EA
            index_mux_sel <= "0100";
            index_add_sel <= '0';
            ea_mux_sel    <= "0000";
         
          when "1010"=> -- CC
          
            -- EA->CC
            alu_mux_sel <= "0111";
            alu_mode    <= a_assign_ccr;
            cc_en       <= '1';
            
            -- CC->EA
            ea_mux_sel  <= "0110";
          
          when others=> -- DP 
          
            -- EA->DP
            addr_mux_sel  <= "100";
            index_add_sel <= '1';
            dp_en         <= '1';
            
            -- DP->EA
            ea_mux_sel    <= "0111";
          
        end case;
        
        next_state <= s_exg3;

      when s_exg3=>
      
        case postbyte(7 downto 4) is
        
          when "0000"=> -- D
          
            alu_mode    <= a_assign16;
            alu_mux_sel <= "0111";
            ab_en       <= "11";
            
          when "0001"=> -- X
          
            index_mux_sel <= "1000";
            index_add_sel <= '0';
            x_en          <= '1';
          
          when "0010"=> -- Y
          
            index_mux_sel <= "1000";
            index_add_sel <= '0';
            y_en          <= '1';
          
          when "0011"=> -- U
          
            index_mux_sel <= "1000";
            index_add_sel <= '0';
            u_en          <= '1';
          
          when "0100"=> -- S
          
            index_mux_sel <= "1000";
            index_add_sel <= '0';
            s_en          <= '1';
          
          when "0101"=> -- PC
          
            index_mux_sel <= "1000";
            index_add_sel <= '0';
            pc_en         <= '1';
          
          when "1000"=> -- A
          
            alu_mode    <= a_assign16;
            alu_mux_sel <= "0111";
            ab_en       <= "10";
          
          when "1001"=> -- B
          
            alu_mode    <= a_assign16;
            alu_mux_sel <= "0111";
            ab_en       <= "01";
          
          when "1010"=> -- CC
          
            alu_mode    <= a_assign_ccr;
            alu_mux_sel <= "0111";
            cc_en       <= '1';
            
          when others=> -- DP 
           
            index_mux_sel <= "1000";
            index_add_sel <= '0';
            dp_en         <= '1';
          
        end case;
      
      next_state <= s_dummy2;

      -- -------------------------------------------------------------------    
      -- abx                         
      -- -------------------------------------------------------------------    
      when s_abx2=>
      
        index_add_sel <= '1';
        index_mux_sel <= "0110";
        addr_mux_sel  <= "100";
        x_en          <= '1';
        next_state    <= s_fetch;
      
      -- -------------------------------------------------------------------    
      -- Push resgisters to the stack                          
      -- -------------------------------------------------------------------    
      when s_psh =>
      
        index_add_sel         <= '1';
        index_mux_sel         <= "0001";
        next_pushpull_mask(8) <= '1';
        
        next_enter_irq        <= enter_irq;
        next_enter_nmi        <= enter_nmi;
        next_state            <= s_psh;

        if op_operand=o_u_ne and enter_irq='0' and enter_nmi='0' then
        
          -- Only pshu
          addr_mux_sel <= "010";
          u_en         <= '1';
          
        else
        
          -- S, SWI, etc...
          addr_mux_sel <= "011";
          s_en         <= '1';
        
        end if;

        if pushpull_mask(9)='1' then
        
          busreq                <= '0';
          write                 <= '0';
          next_pushpull_mask(9) <= '0';
          
        else
        
          busreq                <= '1';
          write                 <= '1';
        
        end if;
        
        if pushpull_mask(7)='1' and postbyte(7)='1' then -- PC
        
          mw_en          <= '1';
          allreg_mux_sel <= "10";

          if pushpull_mask(8)='1' then
          
            next_pushpull_mask(8) <= '0';
          
          else
          
            next_pushpull_mask(7) <= '0';
            bytelane_mux_sel      <= '1';
            
          end if;
        
        elsif pushpull_mask(6)='1' and postbyte(6)='1' then -- U/S
        
          mw_en       <= '1';
          alu_mode    <= a_assign16;
          
          if op_operand=o_u_ne and enter_nmi='0' and enter_irq='0' then
                                                       
            alu_mux_sel <= "0110";
                                                      
          else                                         
                                                      
            alu_mux_sel <= "0101";
                                                      
          end if;                                      
         
          
          if pushpull_mask(8)='1' then
          
            next_pushpull_mask(8) <= '0';
          
          else
        
            next_pushpull_mask(6) <= '0';
            bytelane_mux_sel      <= '1';
          
          end if;

        elsif pushpull_mask(5)='1' and postbyte(5)='1' then -- Y
        
          mw_en       <= '1';
          alu_mode    <= a_assign16;
          alu_mux_sel <= "0100";
          
          if pushpull_mask(8)='1' then
          
            next_pushpull_mask(8) <= '0';
          
          else
        
            next_pushpull_mask(5) <= '0';
            bytelane_mux_sel      <= '1';
          
          end if;
        
        elsif pushpull_mask(4)='1' and postbyte(4)='1' then -- X
        
          mw_en       <= '1';             
          alu_mode    <= a_assign16;      
          alu_mux_sel <= "0011";          
          
          if pushpull_mask(8)='1' then    
          
            next_pushpull_mask(8) <= '0'; 
          
          else                            
        
            next_pushpull_mask(4) <= '0'; 
            bytelane_mux_sel      <= '1'; 
          
          end if;                         
        
        elsif pushpull_mask(3)='1' and postbyte(3)='1' then -- DP
         
          mw_en                 <= '1';
          allreg_mux_sel        <= "01";
          next_pushpull_mask(3) <= '0';
                   
        elsif pushpull_mask(2)='1' and postbyte(2)='1'  then -- B
         
          mw_en                 <= '1';
          alu_mode              <= a_assign8;
          alu_mux_sel           <= "0001";
          next_pushpull_mask(2) <= '0';
         
        elsif pushpull_mask(1)='1' and postbyte(1)='1'  then -- A
         
          mw_en                 <= '1';
          alu_mode              <= a_assign8;
          next_pushpull_mask(1) <= '0';
         
        elsif pushpull_mask(0)='1' and postbyte(0)='1'  then -- CC
         
          mw_en                 <= '1';
          allreg_mux_sel        <= "11"; 
          next_pushpull_mask(0) <= '0';

        else
        
          s_en <= '0';
          u_en <= '0';
          
          if enter_nmi='1' then
          
            pc_mux_sel      <= "10";
            vector          <= "110";
            pc_en           <= '1';
            set_i           <= '1';
            set_f           <= '1';
            cc_en           <= '1';
            next_nmi_active <= '1';
            next_enter_nmi  <= '0';
            next_state      <= s_fetch_interrupt_h;
          
          elsif enter_irq='1' then
          
            pc_mux_sel      <= "10";
            vector          <= "100";
            pc_en           <= '1';
            set_i           <= '1';
            cc_en           <= '1';
            next_enter_irq  <= '0';
            next_state      <= s_fetch_interrupt_h;
          
          elsif op_instr=s_swi then
          
            pc_mux_sel <= "10";
            pc_en      <= '1';
            
            if op_operand=o_one_eq then
            
              vector     <= "101";
              set_f <= '1';
              set_i <= '1';
              cc_en <= '1';
            
            else
            
              if op_operand=o_two_vc then
                
                vector     <= "010";
             
              else
               
                vector     <= "001";
 
              end if;
            
            end if;
            
            next_state <= s_fetch_interrupt_h;
          
          else
          
            next_state <= s_fetch; 
          
          end if;
          
        end if;
       
      -- -------------------------------------------------------------------    
      -- Pull registers from the stack                                        
      -- -------------------------------------------------------------------    
      when s_pul=>
      
        busreq        <= '1';
        index_mux_sel <= "0010";
        index_add_sel <= '1';
        
        if op_operand=o_u_ne then
        
          addr_mux_sel <= "010";
          u_en         <= '1';
          
        else
        
          addr_mux_sel <= "011";
          s_en         <= '1';
        
        end if;
        
        next_pushpull_mask(8) <= '1';
        
        if postbyte(0)='1' and pushpull_mask(0)='1' then -- CC
        
          next_pushpull_mask(0) <= '0';
          alu_mode              <= a_assign_ccr_op2;
          cc_en                 <= '1';
          
          if op_instr=s_rti and rdata(7)='0' then
          
            next_pushpull_mask(9 downto 1) <= "011000000";
          
          end if;
          
          next_state <= s_pul;
        
        elsif postbyte(1)='1' and pushpull_mask(1)='1' then -- A
        
          next_pushpull_mask(1) <='0';
          alu_mode              <= a_assign8_op2;
          ab_en                 <= "10";
          next_state <= s_pul;

        elsif postbyte(2)='1' and pushpull_mask(2)='1' then -- B
        
          next_pushpull_mask(2) <='0';
          alu_mode              <= a_assign8_op2;
          ab_en                 <= "01";
          next_state <= s_pul;
 
        elsif postbyte(3)='1' and pushpull_mask(3)='1' then -- DP
        
          next_pushpull_mask(3) <= '0';
          dp_mux_sel            <= '1';
          dp_en                 <= '1';
          next_state <= s_pul;
          
        elsif postbyte(4)='1' and pushpull_mask(4)='1' then -- X
        
          if pushpull_mask(8)='1' then
          
            mr_en                 <= '1';
            next_pushpull_mask(8) <= '0'; --XH
          
          else
           
            x_mux_sel              <= '1';
            x_en                   <= '1';
            next_pushpull_mask(4)  <= '0';  --XL

          end if;
          next_state <= s_pul;

        elsif postbyte(5)='1' and pushpull_mask(5)='1' then -- Y
        
          if pushpull_mask(8)='1' then
          
            mr_en                 <= '1';
            next_pushpull_mask(8) <= '0'; --YH
          
          else
           
            y_mux_sel              <= '1';
            y_en                   <= '1';
            next_pushpull_mask(5)<='0';  --YL

          end if;
          next_state <= s_pul;
        
        elsif postbyte(6)='1' and pushpull_mask(6)='1' then -- U/S
        
          if pushpull_mask(8)='1' then
          
            mr_en                 <= '1';
            next_pushpull_mask(8) <= '0'; --USH
          
          else
           
            if op_operand=o_u_ne then
            
              s_mux_sel <= '1';
              s_en      <= '1';
           
            else
           
              -- puls, rti
              u_mux_sel <= '1';
              u_en      <= '1';
           
            end if; 
              
            next_pushpull_mask(6)<='0';  --USL

          end if;
          next_state <= s_pul;

        elsif postbyte(7)='1' and pushpull_mask(7)='1' then -- PC
        
          if pushpull_mask(8)='1' then
          
            mr_en                 <= '1';
            next_pushpull_mask(8) <= '0'; --PCH
          
          else
           
            pc_mux_sel            <= "01";
            pc_en                 <= '1';
            next_pushpull_mask(7) <= '0';  --PCL

          end if;
          next_state <= s_pul;
        
        else
        
          busreq     <= '0';
          u_en       <= '0';
          s_en       <= '0';
          next_state <= s_fetch;
        
        end if;

      -- -------------------------------------------------------------------    
      -- dummy                                               
      -- -------------------------------------------------------------------    
      when s_dummy2 =>
        
        next_state <= s_dummy;
        
      when s_dummy  =>
      
        next_state <= s_fetch;
    
      -- -------------------------------------------------------------------    
      -- sync                                               
      -- -------------------------------------------------------------------    
      when s_sync =>
      
        if nnmi_resync='0' or nirq_resync='0' then            
                                            
          next_state <= s_fetch;            
                                            
        else                                
                                            
          next_state <= s_sync;             
                                            
        end if;                             
                
      -- -------------------------------------------------------------------    
      -- UNKNOW                                               
      -- -------------------------------------------------------------------    
      when others=>
      
        null;  
                                                                                
    end case;                                                                   
  
  end process p_sequencer_comb;

end architecture rtl;
