----------------------------------------------------------------------
--
-- S3MO5 - memcntl
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
--====================================================================
--
-- emi_state
--
-- 101;000  : video cycles
-- 001      : turn-around cycle
-- 010;011  : cpu or uart cycles
-- 100      : turn-around cycle
--
--
--  |<-20ns->|<-20ns->|<-20ns->|<-20ns->|<-20ns->|<-20ns->|
-- 000      001      010      011      100      101      000 ...
--  |        |                 |        |       
--  |        |                 |        |
--  |        |                 |        |
--  |        |                 |        +- o W display video control
--  |        |                 |       
--  |        |                 +- o R sample cpu/uart data        
--  |        |                    o W bus inactive for turn-around
--  |        |          
--  |        |
--  |        +- o W display cpu/uart control 
--  |
--  +- o R video data sampling
--     o W bus inactive for turn-around
--     
--====================================================================
--
-- Memory mapping and translation
--
--                  bank:SRAM             CPU/UART DMA    
--                  (16 bits addr)        (8 bits addr)  
-- -------------------------------------------------------------------
-- Video RAM        0:00000-01fff          0000-1fff P       8192
-- (user)           P[15:8]  F[7:0]        0000-1fff F       8192
--
-- Video RAM        0:02000-03fff          0000-1fff P       8192
-- (bios)           P[15:8]  F[7:0]        0000-1fff F       8192
-- -------------------------------------------------------------------        
-- User  RAM        0:04000-07fff          2000-9fff        32768
-- (user)      
-- User  RAM        0:08000-0bfff          2000-9fff        32768
-- (bios)
-- -------------------------------------------------------------------        
-- sysregisters                            a7c0-a7ff     
-- -------------------------------------------------------------------        
-- sliding window                          a800-a8ff     
-- -------------------------------------------------------------------        
-- bios code        0:0e000-0efff          a900-afff         1792
-- -------------------------------------------------------------------
-- reserved                                b000-bfff     
-- -------------------------------------------------------------------
-- ROM              0:0c000-0dfff          c000-ffff        16384
-- -------------------------------------------------------------------
-- Free             0:0f000-3ffff          sliding window  401408 
-- Free             1:00000-3ffff          sliding window  524288
--
--====================================================================
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.memcntl_package.all;

entity memcntl is
  port
  (
     -- system
     resetn           :    in std_logic;
     clk50m           :    in std_logic;
     source_irq       :    in std_logic;
     soft_resetn      :   out std_logic;
     cpu_turbo        :    in std_logic;
     -- processor
     cpu_clken        :   out std_logic;
     cpu_nnmi         :   out std_logic;
     cpu_nfiq         :   out std_logic;
     cpu_nirq         :   out std_logic;
     cpu_busreq       :    in std_logic;
     cpu_write        :    in std_logic;
     cpu_addr         :    in std_logic_vector(15 downto 0);
     cpu_wdata        :    in std_logic_vector( 7 downto 0);
     cpu_rdata        :   out std_logic_vector( 7 downto 0);
     -- external sram
     sram_wen         :   out std_logic;
     sram_oen         :   out std_logic;
     sram_a           :   out std_logic_vector(17 downto 0);
     sram_csn         :   out std_logic_vector( 1 downto 0);
     sram_ben         :   out std_logic_vector( 1 downto 0);
     sram_dataen      :   out std_logic_vector( 1 downto 0);
     sram_rdata       :    in std_logic_vector(31 downto 0);
     sram_wdata       :   out std_logic_vector(31 downto 0); 
     -- vga controller
     vga_vsync        :    in std_logic;
     vga_data         :   out std_logic_vector(15 downto 0);
     vga_update       :    in std_logic; 
     vga_border       :   out std_logic_vector( 3 downto 0);
     -- jtag rom
     flash_clk        :   out std_logic;
     flash_q          :    in std_logic;
     -- uart tx
     uart_wen         :   out std_logic;
     uart_wdata       :   out std_logic_vector( 7 downto 0);
     uart_wbusy       :    in std_logic;
     uart_rdata       :    in std_logic_vector( 7 downto 0);
     uart_rvalid      :    in std_logic;
     -- keyboard
     keyboard_col     :   out std_logic_vector( 2 downto 0);
     keyboard_row     :   out std_logic_vector( 2 downto 0);
     keyboard_hit     :    in std_logic;
     keyboard_esc     :    in std_logic;
     -- sound
     sound            :   out std_logic
  );
end entity memcntl;

architecture rtl of memcntl is

  -- S3MO5 control registers
  signal reg_control     : std_logic_vector( 7 downto 0);
  signal reg_control2    : std_logic;
  signal reg_index_l     : std_logic_vector( 7 downto 0);
  signal reg_index_h     : std_logic_vector( 7 downto 0);
  signal reg_pra0        : std_logic_vector( 6 downto 0);
  signal reg_prb0        : std_logic_vector( 6 downto 0);
  signal reg_dda0        : std_logic_vector( 7 downto 0);
  signal reg_ddb0        : std_logic_vector( 7 downto 0);
  signal reg_cra0        : std_logic_vector( 7 downto 0);
  signal reg_crb0        : std_logic_vector( 7 downto 0);
  signal reg_gatearray0  : std_logic_vector( 7 downto 0);
  signal reg_gatearray1  : std_logic_vector( 7 downto 0);
  signal reg_gatearray2  : std_logic_vector( 7 downto 0);
  signal reg_gatearray3  : std_logic_vector( 7 downto 0);
  --
  signal sel_write       : std_logic;
  signal sel_registers   : std_logic_vector(3 downto 0);
  --
  signal sram_wen_i      : std_logic;
  signal sram_oen_i      : std_logic;
  signal sram_a_i        : std_logic_vector(17 downto 0);
  signal sram_csn_i      : std_logic_vector( 1 downto 0);
  signal sram_ben_i      : std_logic_vector( 1 downto 0);
  signal sram_dataen_i   : std_logic_vector( 1 downto 0);
  signal sram_wdata_i    : std_logic_vector( 7 downto 0); 
  --
  signal vga_addr        : std_logic_vector(12 downto 0);
  signal vga_row         : std_logic_vector( 7 downto 0);
  signal vga_col         : std_logic_vector( 5 downto 0);
  signal vga_odd         : std_logic;
  signal vga_vsync_1t    : std_logic;
  --
  signal source_irq_1t   : std_logic;
  --
  signal cpu_stall       : std_logic;
  signal cpu_slow_count  : std_logic_vector( 2 downto 0);
  --
  signal uart_addr       : std_logic_vector(15 downto 0);
  signal uart_write      : std_logic;
  signal uart_qty        : std_logic_vector( 7 downto 0);
  signal uart_wen_i      : std_logic;
  --
  signal uart_state      : t_uart_state;
  --
  signal emi_state       : std_logic_vector( 2 downto 0);

begin

  -- ---------------------------------------------------------------------------
  -- Probes
  -- ---------------------------------------------------------------------------
  probe_memcntl_uart_state     <= uart_state;        
  probe_memcntl_emi_state      <= emi_state;         
  probe_memcntl_reg_control    <= reg_control;       
  probe_memcntl_reg_control2   <= reg_control2;      
  probe_memcntl_reg_index_l    <= reg_index_l;       
  probe_memcntl_reg_index_h    <= reg_index_h;       
  probe_memcntl_reg_pra0       <= reg_pra0;          
  probe_memcntl_reg_prb0       <= reg_prb0;          
  probe_memcntl_reg_dda0       <= reg_dda0;          
  probe_memcntl_reg_ddb0       <= reg_ddb0;          
  probe_memcntl_reg_cra0       <= reg_cra0;          
  probe_memcntl_reg_crb0       <= reg_crb0;          
  probe_memcntl_reg_gatearray0 <= reg_gatearray0;    
  probe_memcntl_reg_gatearray1 <= reg_gatearray1;    
  probe_memcntl_reg_gatearray2 <= reg_gatearray2;    
  probe_memcntl_reg_gatearray3 <= reg_gatearray3;    
  probe_memcntl_sel_write      <= sel_write;         
  probe_memcntl_sel_registers  <= sel_registers;     
  probe_memcntl_vga_addr       <= vga_addr;          
  probe_memcntl_vga_row        <= vga_row;           
  probe_memcntl_vga_col        <= vga_col;           
  probe_memcntl_vga_odd        <= vga_odd;           
  probe_memcntl_vga_vsync_1t   <= vga_vsync_1t;      
  probe_memcntl_source_irq_1t  <= source_irq_1t;     
  probe_memcntl_cpu_stall      <= cpu_stall;         
  probe_memcntl_cpu_slow_count <= cpu_slow_count;    
  probe_memcntl_uart_addr      <= uart_addr;         
  probe_memcntl_uart_write     <= uart_write;        
  probe_memcntl_uart_qty       <= uart_qty;          
  
  -- ---------------------------------------------------------------------------
  -- assignments
  -- ---------------------------------------------------------------------------
  cpu_nfiq     <= '1';
  cpu_nnmi     <= not(reg_control(1));
  cpu_nirq     <= not(reg_crb0(7)) or not(reg_crb0(0));
  
  soft_resetn  <= not(reg_control(7));
  vga_border   <= reg_pra0(4 downto 1);
  keyboard_col <= reg_prb0(3 downto 1);
  keyboard_row <= reg_prb0(6 downto 4);
  sound        <= reg_prb0(0);
  
  sram_wen     <= sram_wen_i;   
  sram_oen     <= sram_oen_i;   
  sram_a       <= sram_a_i;   
  sram_csn     <= sram_csn_i;  
  sram_ben     <= sram_ben_i;  
  sram_dataen  <= sram_dataen_i;
  sram_wdata   <= sram_wdata_i&sram_wdata_i&sram_wdata_i&sram_wdata_i;
  
  uart_wen     <= uart_wen_i;
  

  -- ---------------------------------------------------------------------------
  -- 20 ms interrupt generation
  -- ---------------------------------------------------------------------------
  p_nirq_generation:process(resetn,clk50m)
  begin
  
    if resetn='0' then
    
      reg_crb0(7) <= '0';
    
    elsif clk50m'event and clk50m='1' then
    
      source_irq_1t <= source_irq;
      
      if emi_state="011" and sel_write='0' and
         sel_registers="0001" and reg_crb0(2)='1' then
         
        reg_crb0(7) <= '0';
      
      else
      
        if source_irq='1' and source_irq_1t='0' then
      
          reg_crb0(7) <= '1';
      
        end if;
        
      end if;
    
    end if;
  
  end process p_nirq_generation;

  -- ---------------------------------------------------------------------------
  -- video address calculus : vga_addr = vga_col + 40*vga_row
  -- ---------------------------------------------------------------------------
  vga_addr    <= ("00000"&vga_col) +
                 (vga_row&"00000") +
                 ("00"&vga_row&"000");
  
  -- ---------------------------------------------------------------------------
  -- video address generation finite state machine
  -- ---------------------------------------------------------------------------
  p_video_fsm:process(resetn,clk50m)
  begin
  
    if resetn='0' then
     
      vga_odd      <= '0';
      vga_col      <= (others=>'0');
      vga_row      <= (others=>'0');
      vga_vsync_1t <= '0';
    
    elsif clk50m'event and clk50m='1' then
  
      vga_vsync_1t <= vga_vsync;
      
      if vga_update='1' then
      
        if vga_col="100111" then
        
          vga_col <= (others=>'0');
          
          if vga_odd='0' then
          
            vga_odd <= '1';
          
          else
          
            if vga_row="11000111" then
            
              vga_row <= (others=>'0');
            
            else
              
              vga_row <= vga_row + "00000001";
            
            end if;
            
            vga_odd <= '0';
          
          end if;
        
        else
        
          vga_col <= vga_col + "000001";
        
        end if;
      
      else 
      
        -- ---------------------------------------------------------------------
        -- safety: ensure that all counters are reset after the vertical sync
        -- ---------------------------------------------------------------------
        if vga_vsync_1t='0' and vga_vsync='1' then
        
          vga_odd      <= '0';
          vga_col      <= (others=>'0');
          vga_row      <= (others=>'0');
        
        end if;
      
      end if;
  
    end if;
  
  end process p_video_fsm;
  
  -- ---------------------------------------------------------------------------
  -- uart finite state machine ( > from host ; < to host)
  -- ---------------------------------------------------------------------------
  -- >0x00  read
  -- >0xN0  adress 0xN0N1 (16 bits)
  -- >0xN1  
  -- >0xXX  XX bytes to be transfered (0x00=256)
  -- <0x..  data
  -- <0x..
  -- ...
  --
  -- >0x01  write
  -- >0xN0  adress 0xN0N1 (16 bits)
  -- >0xN1  
  -- >0xXX  XX bytes to be transfered (0x00=256)
  -- >0x..  data
  -- >0x..
  -- ...
  -- ---------------------------------------------------------------------------
  p_uart_fsm:process(resetn,clk50m)
  
    variable uart_qty_dec  : std_logic;
    variable uart_addr_inc : std_logic;
  
  begin
  
    if resetn='0' then
    
      uart_state    <= s_idle;
      uart_write    <= '0';
      uart_addr     <= (others=>'0');
      uart_qty      <= (others=>'0');
      uart_qty_dec  := '0';   
      uart_addr_inc := '0';
      
      flash_clk     <= '1';   
    
    elsif clk50m'event and clk50m='1' then
    
      uart_qty_dec  := '0';   
      uart_addr_inc := '0';   
    
      case uart_state is
        
        -- ---------------------------------------------------------------------
        -- Operating mode : UART
        -- ---------------------------------------------------------------------
        when s_idle=>
        
          if uart_rvalid='1' then
          
            case uart_rdata is
            
              when "00000000"=> --  read
              
                uart_state <= s_get_addr0;
                uart_write <= '0';
              
              when "00000001"=> -- write
              
                uart_state <= s_get_addr0;
                uart_write <= '1';
                
              when others=>
              
                null;
            
            end case;
          
          end if;
        
        -- ---------------------------------------------------------------------
        -- ADDRESS part
        -- ---------------------------------------------------------------------
        when s_get_addr0=>
        
          if uart_rvalid='1' then
          
            uart_addr(15 downto  8) <= uart_rdata;
            uart_state              <= s_get_addr1;
          
          end if;

        when s_get_addr1=>
        
          if uart_rvalid='1' then
          
            uart_addr( 7 downto  0) <= uart_rdata;
            uart_state              <= s_get_qty;
          
          end if;

        when s_get_qty=>
        
          if uart_rvalid='1' then
          
            uart_qty <= uart_rdata;
            
            if uart_write='0' then
            
              uart_state  <= s_read_get_data_req;
            
            else
            
              uart_state  <= s_write_put_data_receive;
            
            end if;
          
          end if;

        -- ---------------------------------------------------------------------
        -- READ part
        -- ---------------------------------------------------------------------
        when s_read_get_data_req=>
        
          if emi_state="001" then
          
              uart_state   <= s_read_get_data_ack;
              uart_qty_dec := '1';
          
          end if;
          
        when s_read_get_data_ack=>
        
          if emi_state="011" then
          
            uart_state  <= s_read_get_data_sent;
          
          end if;
          
        when s_read_get_data_sent=>
          
          if uart_wbusy='0' and uart_wen_i='0'  then
          
            if uart_qty="00000000" then
            
              uart_state <= s_idle;
              
            else
            
              uart_addr_inc := '1';
              uart_state    <= s_read_get_data_req;
            
            end if;
          
          end if;

        -- ---------------------------------------------------------------------
        -- WRITE part
        -- ---------------------------------------------------------------------
        when s_write_put_data_receive=>
        
          if uart_qty="00000000" then
          
            uart_state <= s_idle;
          
          else
          
            if uart_rvalid='1' then
          
              uart_qty_dec := '1';
              uart_state   <= s_write_put_data;

            end if;
            
          end if;

        when s_write_put_data=>
        
          if emi_state="001" then
          
            uart_state <= s_write_put_data_write;
          
          end if;
          
        when s_write_put_data_write=>
        
          if emi_state="011" then
          
            uart_addr_inc := '1';
            uart_state    <= s_write_put_data_receive;
          
          end if;
          
      end case;
    
      -- -----------------------------------------------------------------------
      --
      -- -----------------------------------------------------------------------
      if uart_addr_inc='1' then
      
        uart_addr <= uart_addr + "0000000000000001";
      
      end if;
      
      if uart_qty_dec='1' then
      
        uart_qty <= uart_qty + "11111111";
      
      end if;
      
    end if;
  
  end process p_uart_fsm;
  
  -- ---------------------------------------------------------------------------
  -- external memory finite state machine
  -- ---------------------------------------------------------------------------
  p_emi_fsm:process(resetn,clk50m)
  
    variable tmp_addr  : std_logic_vector(15 downto 0);
    variable tmp_data  : std_logic_vector( 7 downto 0);
    variable tmp_write : std_logic;
    variable tmp_ben   : std_logic_vector( 1 downto 0);
  
  begin
  
    if resetn='0' then
    
      -- external ram init
      sram_a_i       <= (others=>'0');
      sram_wdata_i   <= (others=>'0');
      sram_wen_i     <= '1';
      sram_oen_i     <= '1';
      sram_csn_i     <= "11";  
      sram_ben_i     <= "11";  
      sram_dataen_i  <= "00";
      --
      uart_wen_i     <= '0';
      uart_wdata     <= (others=>'0');
      -- fsm init
      emi_state      <= "000";
      cpu_clken      <= '0';
      cpu_stall      <= '0';
      -- cpu
      cpu_slow_count <= "000";
      
      -- vga
      vga_data       <= (others=>'0');
      -- registers
      reg_control    <= "00000000";  
      reg_control2   <= '0';  
      reg_index_l    <= (others=>'0');     
      reg_index_h    <= (others=>'0');     
      reg_pra0       <= (others=>'0');     
      reg_prb0       <= (others=>'0');     
      reg_dda0       <= (others=>'0');     
      reg_ddb0       <= (others=>'0');     
      reg_cra0       <= (others=>'0');     
      reg_crb0(6 downto 0) <= (others=>'0');     
      reg_gatearray0 <= (others=>'0');     
      reg_gatearray1 <= (others=>'0');     
      reg_gatearray2 <= (others=>'0');     
      reg_gatearray3 <= (others=>'0');     

      sel_write      <= '0';   
      sel_registers  <= (others=>'0');   
      
      -- wires
      tmp_addr       := (others=>'0');
      tmp_data       := (others=>'0');
      tmp_write      := '0';
      tmp_ben        := "11";
    
    elsif clk50m'event and clk50m='1' then
     
      -- ---------------------------------------------------------------------
      -- nmi state machine
      -- ---------------------------------------------------------------------
      if keyboard_esc='1' then
      
        reg_control(1) <= '1';
        
      end if;
      
      -- ---------------------------------------------------------------------
      -- External memory state machine
      -- ---------------------------------------------------------------------
      tmp_addr       := (others=>'0');
      tmp_data       := (others=>'0');
      tmp_write      := '0';
      tmp_ben        := "11";
      
      case emi_state is               
      
        -- ---------------------------------------------------------------------
        -- o video data sampling
        -- o bus inactive for turn-around
        -- ---------------------------------------------------------------------
        when "000"=>  
        
          sram_wen_i    <= '1';
          sram_oen_i    <= '1';
          sram_csn_i    <= "11";
          sram_ben_i    <= "11";
          sram_dataen_i <= "00";
          
          vga_data      <= sram_rdata(15 downto 0);
        
        -- ---------------------------------------------------------------------
        -- o uart/arbitration
        -- ---------------------------------------------------------------------
        when "001"=>  
        
          -- -------------------------------------------------------------------
          -- arbitration
          -- -------------------------------------------------------------------
          if uart_state=s_read_get_data_req or uart_state=s_write_put_data  then

            tmp_addr := uart_addr;
            tmp_data := uart_rdata;
            
            if uart_state=s_write_put_data then
            
              tmp_write  := '1';
              
            else
            
              tmp_write  := '0';
            
            end if;

          elsif cpu_busreq='1' then
          
            tmp_addr  := cpu_addr;
            tmp_data  := cpu_wdata;
            
            if cpu_stall='0' then
            
              tmp_write := cpu_write;
            
            end if;
            
          end if;
          
          -- -------------------------------------------------------------------
          -- address decoding
          --
          -- registers selections
          --
          -- 0000  pra0/dda0
          -- 0001  prb0/ddb0
          -- 0010  cra0
          -- 0011  crb0
          -- 0100  slinding window index h
          -- 0101  slinding window index l
          -- 0110  control
          -- 0111
          -- 1000  gate-array0
          -- 1001  gate-array1
          -- 1010  gate-array2
          -- 1011  gate-array3
          -- 1100
          -- 1101
          -- 1110  dummy/floppy ram
          -- 1111  external memories
          --
          --
          --
          --
          -- -------------------------------------------------------------------
          if tmp_addr(15 downto 13)="000" then -- 0x0000-0x1fff  (video section)
          
            sel_registers <= "1111";
            sram_csn_i    <= "10";
            sram_ben_i    <= reg_pra0(0)&not(reg_pra0(0));
            sram_a_i      <= "0000"&reg_control(2)&tmp_addr(12 downto 0);
          
          else -- 0x2000-0xffff  
          
            if tmp_addr(15)='0' or tmp_addr(15 downto 13)="100" then --0x2000-0x9fff (user ram section)
            
              sel_registers          <= "1111";
              sram_csn_i             <= "10";
              sram_ben_i             <= not(tmp_addr(0))&tmp_addr(0);
              sram_a_i(11 downto  0) <= tmp_addr(12 downto  1);
              sram_a_i(15 downto 12) <= ('0'&tmp_addr(15 downto 13)) + ("0"&reg_control(2)&"11");
              sram_a_i(17 downto 16) <= "00";
            
            else -- 0xa000-0xffff
            
              if tmp_addr(14 downto 12)="010" then -- PIA/Gate-Array/S3MO5 registers 0xa000-0xafff
              
                case tmp_addr(11 downto 8) is
                
                  when "0000"|"0001"|"0010"|"0011"|"0100"|"0101"|"0110"=> -- 0xa000-0xa6ff
                  
                    sel_registers <= "1110";
                  
                  when "0111"=> -- 0xa700-0xa7ff
                  
                    case tmp_addr(7 downto 2) is
                
                      when "110000"=> sel_registers <= "00"&tmp_addr(1 downto 0); -- 0xA7C0-0xA7C3
                      when "110100"=> sel_registers <= "1110";                    -- 0xA7D0-0xA7D3 floppy
                      when "111000"=> sel_registers <= "1110";                    -- 0xA7E0-0xA7E4 PIA parallel
                      when "111001"=> sel_registers <= "10"&tmp_addr(1 downto 0); -- 0xA7E0-0xA7E4 Gate-Array
                      when "111111"=> sel_registers <= "01"&tmp_addr(1 downto 0); -- 0xA7FC-0xA7FF S3MO5
                      when others  => sel_registers <= "1110";
                
                    end case;
                    
                  when "1000"=> -- 0xa800-0xa8ff
                    
                    sel_registers <= "1111";
                    sram_ben_i    <= not(tmp_addr(0))&tmp_addr(0);
                    sram_csn_i    <= not(reg_index_h(3))&reg_index_h(3);
                    sram_a_i      <= reg_index_h(2 downto 0)&reg_index_l&tmp_addr(7 downto 1);
                
                    if reg_control2='0' then
                  
                      tmp_write :='0';
                  
                    end if;
                 
                  when others=> -- 0xa900-0xafff
                
                    sel_registers <= "1111";
                    sram_ben_i    <= not(tmp_addr(0))&tmp_addr(0);
                    sram_csn_i    <= "10";
                    sram_a_i      <= "00111001"&tmp_addr(10 downto 1);
                
                end case;
                
              else --0xb000-0xffff
              
                if tmp_addr(14 downto 12)/="011" then -- ROM 0xc000-0xffff
                
                  sel_registers <= "1111";
                  sram_csn_i    <= "10";
                  sram_ben_i    <= not(tmp_addr(0))&tmp_addr(0);
                  sram_a_i      <= "00110"&tmp_addr(13 downto 1);
                  
                  if reg_control2='0' then
                  
                    tmp_write :='0';
                  
                  end if;
                  
                else
               
                  sel_registers <= "0000";
                
                end if;
              
              end if;
            
            end if;
          
          end if;                                                 
    
          -- -------------------------------------------------------------------
          -- assignment
          -- -------------------------------------------------------------------
          
          sel_write <= tmp_write;
          if tmp_write='0' then
          
            sram_wen_i    <= '1';
            sram_oen_i    <= '0';
            sram_dataen_i <= "00"; 
          
          else
          
            sram_wen_i    <= '0';
            sram_oen_i    <= '1'; 
            sram_dataen_i <= "11";
            sram_wdata_i  <= tmp_data;
          
          end if;
    
        -- ---------------------------------------------------------------------
        -- o cpu data sampling
        -- o bus inactive for turn-around
        -- ---------------------------------------------------------------------
        when "011"=>
      
          sel_write     <= '0';
          sel_registers <= "0000";
          
          if sel_write='0' then
          
            case sel_registers is
            
              when "0000"=> 
              
                if reg_cra0(2)='1'  then
                  tmp_data := '1'&reg_pra0;
                else
                  tmp_data := reg_dda0;
                end if;
              
              when "0001"=> 
              
                if reg_crb0(2)='1'  then
                  tmp_data := keyboard_hit&reg_prb0;
                else
                  tmp_data := reg_ddb0;
                end if;
              
              when "0010"=> tmp_data := reg_cra0;
              when "0011"=> tmp_data := reg_crb0;
              when "0100"=> tmp_data := reg_index_h;
              when "0101"=> tmp_data := reg_index_l;
              when "0110"=> tmp_data := reg_control;
              when "0111"=> tmp_data := "0000000"&reg_control2;
              when "1000"=> tmp_data := reg_gatearray0; reg_gatearray0<=not reg_gatearray0;
              when "1001"=> tmp_data := reg_gatearray1; reg_gatearray1<=not reg_gatearray1;
              when "1010"=> tmp_data := reg_gatearray2; reg_gatearray2<=not reg_gatearray2;
              when "1011"=> tmp_data := reg_gatearray3; reg_gatearray3<=not reg_gatearray3;
              when "1100"=> null;
              when "1101"=> null;
              when "1110"=> tmp_data := "00111001";
              when others=> 
              
                if sram_ben_i="10" then
                
                  if sram_csn_i(0)='0' then
                  
                    tmp_data := sram_rdata(15 downto 8);
                    
                  else
                  
                    tmp_data := sram_rdata(31 downto 24);
                  
                  end if;
                
                else
                
                  if sram_csn_i(0)='0' then
                  
                    tmp_data := sram_rdata( 7 downto 0);
                    
                  else
                  
                    tmp_data := sram_rdata(23 downto 16);
                  
                  end if;
                
                end if;
            
            end case;
            
          else
            
            case sel_registers is
            
              when "0000"=> 
              
                if reg_cra0(2)='1'  then
                  reg_pra0 <= sram_wdata_i(6 downto 0);
                else
                  reg_dda0 <= sram_wdata_i;
                end if;
              
              when "0001"=> 
              
                if reg_crb0(2)='1'  then
                  reg_prb0 <= sram_wdata_i(6 downto 0);
                else
                  reg_ddb0 <= sram_wdata_i;
                end if;
              
              when "0010"=> reg_cra0             <= sram_wdata_i;
              when "0011"=> reg_crb0(6 downto 0) <= sram_wdata_i(6 downto 0);
              when "0100"=> reg_index_h          <= sram_wdata_i;
              when "0101"=> reg_index_l          <= sram_wdata_i;
              when "0110"=> reg_control          <= sram_wdata_i;
              when "0111"=> reg_control2         <= sram_wdata_i(0);
              when "1000"=> reg_gatearray0       <= sram_wdata_i;
              when "1001"=> reg_gatearray1       <= sram_wdata_i;
              when "1010"=> reg_gatearray2       <= sram_wdata_i;
              when "1011"=> reg_gatearray3       <= sram_wdata_i;
              when others=> null;
            
            end case;
            
          end if;
          
          if uart_state=s_read_get_data_ack then
          
            uart_wdata <= tmp_data;
            uart_wen_i <= '1';
                                       
          elsif cpu_busreq='1' then
          
            cpu_rdata   <= tmp_data;
            
          end if;
          
          sram_wen_i    <= '1';
          sram_oen_i    <= '1';
          sram_csn_i    <= "11";
          sram_ben_i    <= "11";
          sram_dataen_i <= "00";

        -- ---------------------------------------------------------------------
        -- o display vga address
        -- o bus configured for video read access
        -- 
        -- ---------------------------------------------------------------------
        when "100"=>
                     
          sram_a_i      <= "0000"&reg_control(2)&vga_addr;
          sram_wen_i    <= '1';
          sram_oen_i    <= '0';
          sram_csn_i    <= "10";
          sram_ben_i    <= "00";
          sram_dataen_i <= "00";
          uart_wen_i    <= '0';
                 
        -- ---------------------------------------------------------------------
        -- cycles 2 & 5
        -- ---------------------------------------------------------------------
        when others=>
        
          sram_wen_i <= '1';            
      
      end case;                   
    
      -- -----------------------------------------------------------------------
      -- state transition
      -- -----------------------------------------------------------------------
      if emi_state="100" then
      
        if cpu_stall='1' or reg_control(3)='1' then
        
          cpu_stall <= '0';
          cpu_clken <= '0';
          
        else
        
          if cpu_turbo='1' then
          
            cpu_clken <= '1';
          
          else
          
            if cpu_slow_count="111" then
            
              cpu_clken      <= '1';
              cpu_slow_count <= "000";
              
            else
            
              cpu_clken      <= '0';
              cpu_slow_count <= cpu_slow_count + "001";
            
            end if;
          
          end if;
        
        end if;
        
      else
      
        cpu_clken <= '0';
      
      end if;
      
      if emi_state="101" then        
      
        emi_state <= "000";          
      
      else                        
      
        if emi_state="011" then
        
          if uart_state=s_read_get_data_ack or
             uart_state=s_write_put_data_write
          then
          
            cpu_stall <= '1';
          
          end if;
        
        end if;
        
        emi_state <= emi_state + "001";  
      
      end if;                     
    
    end if;
    
  end process p_emi_fsm;

end architecture rtl;
