----------------------------------------------------------------------
--
-- S3MO5 - testbench s3mo5
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
--
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--
use work.cpu_package.all;
use work.memcntl_package.all;
use work.keyboard_package.all;
use work.videocntl_package.all;
use work.s3mo5_package.all;
use work.testbench_s3mo5_package.all;

entity testbench_s3mo5 is
end entity testbench_s3mo5;

architecture testbench of testbench_s3mo5 is

  component s3mo5
    port
    (
      -- system
      clk_osc        :    in std_logic;
      
      -- push buttons
      pbutton        :    in std_logic_vector(3 downto 0);
      
      -- switches
      switch         :    in std_logic_vector( 7 downto 0);
      
      -- 4x7 segments display
      anode_s7       :   out std_logic_vector( 3 downto 0);
      s7             :   out std_logic_vector( 7 downto 0);
      led            :  out std_logic_vector( 7 downto 0);
      
      -- rs-232
      uart_tx        :   out std_logic;
      uart_rx        :    in std_logic;
      
      -- PS/2
      ps2_c          :    in std_logic;
      ps2_d          :    in std_logic;
      
      -- ram
      sram_wen       :   out std_logic;
      sram_oen       :   out std_logic;
      sram_a         :   out std_logic_vector(17 downto 0);
      sram_csn       :   out std_logic_vector( 1 downto 0);
      sram_ben       :   out std_logic_vector( 3 downto 0);
      sram_dq        : inout std_logic_vector(31 downto 0);
      
      -- Video
      vga_hsync      :  out std_logic;
      vga_vsync      :  out std_logic;
      vga_r          :  out std_logic;
      vga_g          :  out std_logic;
      vga_b          :  out std_logic;
      
      -- sound
      sound          :  out std_logic;
      
      
      -- flash
      flash_clk      :  out std_logic;
      flash_q        :   in std_logic
    );
  end component;

  component ram256kx16
    generic
    (
      init_filemode : integer := 0;
      init_filename : string;
      dump_filename : string
    );
    port
    (
      dump     :    in std_logic;
      csn      :    in std_logic;
      wen      :    in std_logic; 
      oen      :    in std_logic; 
      ubn      :    in std_logic; 
      lbn      :    in std_logic; 
      a        :    in std_logic_vector(17 downto 0);
      dq       : inout std_logic_vector(15 downto 0)    
    );
  end component;

  component uart
    port
    (
      -- system
      resetn   :  in std_logic;
      clk      :  in std_logic;
      clken    :  in std_logic;
      
      -- tx
      wen      :  in std_logic;
      data_in  :  in std_logic_vector(7 downto 0);
      busy     : out std_logic;
      tx       : out std_logic;
      
      -- rx
      rx       :  in std_logic;
      data_out : out std_logic_vector(7 downto 0);
      valid    : out std_logic
    );
  end component;
  
  component vcd_probe
  end component;
  
  signal done_uart         : std_logic := '0';
  signal done_keyboard     : std_logic := '0';
  signal constant_zero     : std_logic_vector(31 downto  0) := (others=>'0');

  signal dump_ram0         : std_logic := '0';
  signal dump_ram1         : std_logic := '0';
  
  signal clk_osc           : std_logic;
  signal resetn            : std_logic;
  signal pbutton           : std_logic_vector( 3 downto  0);
  signal switch            : std_logic_vector( 7 downto  0);
  signal uart_tx           : std_logic;
  signal uart_rx           : std_logic;
  signal ps2_c             : std_logic := '1';
  signal ps2_d             : std_logic := '1';
  signal sram_wen          : std_logic;
  signal sram_oen          : std_logic;
  signal sram_a            : std_logic_vector(17 downto  0);
  signal sram_csn          : std_logic_vector( 1 downto  0);
  signal sram_ben          : std_logic_vector( 3 downto  0);
  signal sram_dq           : std_logic_vector(31 downto  0);

  signal clken_uart        : std_logic;
  signal uart_divider      : std_logic_vector( 6 downto 0);
  signal uart_wen          : std_logic;
  signal uart_wdata        : std_logic_vector( 7 downto  0);
  signal uart_wbusy        : std_logic;
  signal uart_rdata        : std_logic_vector( 7 downto 0);
  signal uart_rvalid       : std_logic;

  signal flash_clk         : std_logic;
  signal flash_q           : std_logic;

  file file_vcd            : text open write_mode is "s3mo5.vcd";
  shared variable timestep : time := 0 ns; 

  type t_init_probe        is (s_idle,s_put_info,s_init_done);
  signal init_probe        : t_init_probe := s_idle;

  procedure do_probe(signal init_probe : in t_init_probe ; probe : std_logic ; name : string ; index : string) is
 
    variable line_out : line;
    variable is_init  : std_logic :='0';
 
  begin
  
    
    if init_probe=s_init_done then
    
      if now>timestep then
    
        timestep := now;
        write(line_out,'#');
        write(line_out,now);
        writeline(file_vcd,line_out);
    
      end if;
    
      write(line_out,probe);      
      write(line_out,index);
      writeline(file_vcd,line_out); 
   
    else
    
      if init_probe'event then
     
        if init_probe=s_put_info then                           
      
          write(line_out,"$var reg 1 "&index&" "&name&" $end"); 
          writeline(file_vcd,line_out);                         
      
        end if;                                                 
    
      end if;
    
    end if;
  
  end procedure do_probe;

  procedure do_probe(signal init_probe : in t_init_probe ; probe : std_logic_vector ; name : string ; index : string) is
 
    variable line_out : line;
 
  begin
  
    if init_probe=s_init_done then
    
      if now>timestep then
    
        timestep := now;
        write(line_out,'#');
        write(line_out,now);
        writeline(file_vcd,line_out); 
    
      end if;
    
      write(line_out,string'("b"));
      write(line_out,probe);
      write(line_out,string'(" "));
      write(line_out,index);      
      writeline(file_vcd,line_out); 
   
    else
    
      if init_probe'event then
      
        if init_probe=s_put_info then
      
          write(line_out,string'("$var reg "));
          write(line_out,probe'length);
          write(line_out," "&index&" "&name&" $end");
          writeline(file_vcd,line_out);
      
        end if;
    
      end if;
      
    end if;
  
  end procedure do_probe;
  
  procedure do_probe(signal init_probe : in t_init_probe ; probe : t_cpu_state ; name : string ; index : string) is
 
    variable line_out : line;
 
  begin
   
    if init_probe=s_init_done then
    
      if now>timestep then
    
        timestep := now;
        write(line_out,'#');
        write(line_out,now);
        writeline(file_vcd,line_out); 
    
      end if;
    
      write(line_out,string'("s"));
      write(line_out,t_cpu_state'image(probe));
      write(line_out,string'(" "));
      write(line_out,index);      
      writeline(file_vcd,line_out); 
   
    else
    
      if init_probe'event then
      
        if init_probe=s_put_info then
      
          write(line_out,"$var real 1 "&index&" "&name&" $end");
          writeline(file_vcd,line_out);
      
        end if;
    
      end if;
      
    end if;
   
  end procedure do_probe;
 
  procedure do_probe(signal init_probe : in t_init_probe ; probe : t_mo5_key_state ; name : string ; index : string) is
 
    variable line_out : line;
 
  begin
  
    if init_probe=s_init_done then
    
      if now>timestep then
    
        timestep := now;
        write(line_out,'#');
        write(line_out,now);
        writeline(file_vcd,line_out); 
    
      end if;
    
      write(line_out,string'("s"));
      write(line_out,t_mo5_key_state'image(probe));
      write(line_out,string'(" "));
      write(line_out,index);      
      writeline(file_vcd,line_out); 
   
    else
    
      if init_probe'event then
      
        if init_probe=s_put_info then
      
          write(line_out,"$var real 1 "&index&" "&name&" $end");
          writeline(file_vcd,line_out);
      
        end if;
    
      end if;
    
    end if;
   
  end procedure do_probe;
  
  procedure do_probe(signal init_probe : in t_init_probe ; probe : t_uart_state ; name : string ; index : string) is
 
    variable line_out : line;
 
  begin
  
    if init_probe=s_init_done then
    
      if now>timestep then
    
        timestep := now;
        write(line_out,'#');
        write(line_out,now);
        writeline(file_vcd,line_out); 
    
      end if;
    
      write(line_out,string'("s"));
      write(line_out,t_uart_state'image(probe));
      write(line_out,string'(" "));
      write(line_out,index);      
      writeline(file_vcd,line_out); 
   
    else
    
      if init_probe'event then
      
        if init_probe=s_put_info then
      
          write(line_out,"$var real 1 "&index&" "&name&" $end");
          writeline(file_vcd,line_out);
      
       end if;
    
      end if;
      
    end if;
   
  end procedure do_probe;
  
begin 
  
  -- ---------------------------------------------------------------------------
  -- Probes
  -- ---------------------------------------------------------------------------
  
  probe_tb_done_uart     <= done_uart;    
  probe_tb_done_keyboard <= done_keyboard;
  probe_tb_clk_osc       <= clk_osc;      
  probe_tb_resetn        <= resetn;       
  probe_tb_pbutton       <= pbutton;      
  probe_tb_switch        <= switch;       
  probe_tb_uart_tx       <= uart_tx;      
  probe_tb_uart_rx       <= uart_rx;      
  probe_tb_ps2_c         <= ps2_c;        
  probe_tb_ps2_d         <= ps2_d;        
  probe_tb_sram_wen      <= sram_wen;     
  probe_tb_sram_oen      <= sram_oen;     
  probe_tb_sram_a        <= sram_a;       
  probe_tb_sram_csn      <= sram_csn;     
  probe_tb_sram_ben      <= sram_ben;     
  probe_tb_sram_dq       <= sram_dq;      

  --p_probes_init:process
  --
  --  variable line_out : line;
  --
  --begin
 
  --  init_probe <= s_idle;
  --  wait for 1 ns;
  --  init_probe <= s_put_info;
  --  wait for 1 ns;
  --  write(line_out,string'("$enddefinitions $end"));
  --  writeline(file_vcd,line_out);
  --  write(line_out,string'("#0"));
  --  writeline(file_vcd,line_out);
  --  init_probe <= s_init_done;
  --  wait;
  --
  --end process p_probes_init;
  --
  ---- cpu
  --do_probe(init_probe ,probe_a                          ,"cpu.a"                     ,"ca");
  --do_probe(init_probe ,probe_b                          ,"cpu.b"                     ,"cb");
  --do_probe(init_probe ,probe_x                          ,"cpu.x"                     ,"cx");
  --do_probe(init_probe ,probe_y                          ,"cpu.y"                     ,"cy");
  --do_probe(init_probe ,probe_u                          ,"cpu.u"                     ,"ce"); 
  --do_probe(init_probe ,probe_s                          ,"cpu.s"                     ,"cf"); 
  --do_probe(init_probe ,probe_pc                         ,"cpu.pc"                    ,"cg"); 
  --do_probe(init_probe ,probe_cc                         ,"cpu.cc"                    ,"ch"); 
  --do_probe(init_probe ,probe_dp                         ,"cpu.dp"                    ,"ci"); 
  --do_probe(init_probe ,probe_state                      ,"cpu.state"                 ,"cj"); 
  --do_probe(init_probe ,probe_next_state                 ,"cpu.next_state"            ,"ck"); 
  --do_probe(init_probe ,probe_refetch                    ,"refetch"                   ,"cl"); 
  --do_probe(init_probe ,probe_opcode                     ,"opcode"                    ,"cm"); 

  ---- keyboard
  --do_probe(init_probe ,probe_keyboard_ps2c_1t           ,"keyboard.ps2c_1t"          ,"ka"); 
  --do_probe(init_probe ,probe_keyboard_ps2c_2t           ,"keyboard.ps2c_2t"          ,"kb"); 
  --do_probe(init_probe ,probe_keyboard_ps2c_3t           ,"keyboard.ps2c_3t"          ,"kc"); 
  --do_probe(init_probe ,probe_keyboard_count             ,"keyboard.count"            ,"kd");   
  --do_probe(init_probe ,probe_keyboard_shift             ,"keyboard.shift"            ,"ke");   
  --do_probe(init_probe ,probe_keyboard_parity            ,"keyboard.parity"           ,"kf");         
  --do_probe(init_probe ,probe_keyboard_timeout_state     ,"keyboard.timeout_state"    ,"kg");  
  --do_probe(init_probe ,probe_keyboard_data              ,"keyboard.data"             ,"kh");          
  --do_probe(init_probe ,probe_keyboard_data_update       ,"keyboard.data_update"      ,"ki");     
  --do_probe(init_probe ,probe_keyboard_ps2_shift_pressed ,"keyboard.ps2_shift_presse" ,"kj");
  --do_probe(init_probe ,probe_keyboard_ps2_alt_pressed   ,"keyboard.ps2_alt_pressed"  ,"kk"); 
  --do_probe(init_probe ,probe_keyboard_ps2_key_released  ,"keyboard.ps2_key_released" ,"kl");
  --do_probe(init_probe ,probe_keyboard_ps2_key_pressed   ,"keyboard.ps2_key_pressed"  ,"km"); 
  --do_probe(init_probe ,probe_keyboard_mo5_key_state     ,"keyboard.mo5_key_state"    ,"kn");   
  --do_probe(init_probe ,probe_keyboard_mo5_shift_pressed ,"keyboard.mo5_shift_presse" ,"ko");
  --do_probe(init_probe ,probe_keyboard_key_decoded       ,"keyboard.key_decoded"      ,"kp");    
  --
  ---- memcntl
  --do_probe(init_probe ,probe_memcntl_uart_state         ,"memcntl.uart_state"        ,"ma");
  --do_probe(init_probe ,probe_memcntl_emi_state          ,"memcntl.emi_state"         ,"mb");        
  --do_probe(init_probe ,probe_memcntl_reg_control        ,"memcntl.reg_control"       ,"mc");      
  --do_probe(init_probe ,probe_memcntl_reg_control2       ,"memcntl.reg_control2"      ,"md");    
  --do_probe(init_probe ,probe_memcntl_reg_index_l        ,"memcntl.reg_index_l"       ,"me");     
  --do_probe(init_probe ,probe_memcntl_reg_index_h        ,"memcntl.reg_index_h"       ,"mf");      
  --do_probe(init_probe ,probe_memcntl_reg_pra0           ,"memcntl.reg_pra0"          ,"mg");      
  --do_probe(init_probe ,probe_memcntl_reg_prb0           ,"memcntl.reg_prb0"          ,"mh");      
  --do_probe(init_probe ,probe_memcntl_reg_dda0           ,"memcntl.reg_dda0"          ,"mi");     
  --do_probe(init_probe ,probe_memcntl_reg_ddb0           ,"memcntl.reg_ddb0"          ,"mj");     
  --do_probe(init_probe ,probe_memcntl_reg_cra0           ,"memcntl.reg_cra0"          ,"mk");     
  --do_probe(init_probe ,probe_memcntl_reg_crb0           ,"memcntl.reg_crb0"          ,"ml");     
  --do_probe(init_probe ,probe_memcntl_reg_gatearray0     ,"memcntl.reg_gatearray0"    ,"mm");   
  --do_probe(init_probe ,probe_memcntl_reg_gatearray1     ,"memcntl.reg_gatearray1"    ,"mn");  
  --do_probe(init_probe ,probe_memcntl_reg_gatearray2     ,"memcntl.reg_gatearray2"    ,"mo");   
  --do_probe(init_probe ,probe_memcntl_reg_gatearray3     ,"memcntl.reg_gatearray3"    ,"mp");  
  --do_probe(init_probe ,probe_memcntl_sel_write          ,"memcntl.sel_write"         ,"mq");         
  --do_probe(init_probe ,probe_memcntl_sel_registers      ,"memcntl.sel_registers"     ,"mr");     
  --do_probe(init_probe ,probe_memcntl_vga_addr           ,"memcntl.vga_addr"          ,"ms");          
  --do_probe(init_probe ,probe_memcntl_vga_row            ,"memcntl.vga_row"           ,"mt");       
  --do_probe(init_probe ,probe_memcntl_vga_col            ,"memcntl.vga_col"           ,"mu");       
  --do_probe(init_probe ,probe_memcntl_vga_odd            ,"memcntl.vga_odd"           ,"mv");       
  --do_probe(init_probe ,probe_memcntl_vga_vsync_1t       ,"memcntl.vga_vsync_1t"      ,"mw");      
  --do_probe(init_probe ,probe_memcntl_source_irq_1t      ,"memcntl.source_irq_1t"     ,"mx");     
  --do_probe(init_probe ,probe_memcntl_cpu_stall          ,"memcntl.cpu_stall"         ,"my");         
  --do_probe(init_probe ,probe_memcntl_cpu_slow_count     ,"memcntl.cpu_slow_count"    ,"mz");    
  --do_probe(init_probe ,probe_memcntl_uart_addr          ,"memcntl.uart_addr"         ,"m0");         
  --do_probe(init_probe ,probe_memcntl_uart_write         ,"memcntl.uart_write"        ,"m1");        
  --do_probe(init_probe ,probe_memcntl_uart_qty           ,"memcntl.uart_qty"          ,"m2");          
  --
  ---- videocntl
  --do_probe(init_probe ,probe_videocntl_hcounter         ,"videocntl.hcounter"        ,"va");       
  --do_probe(init_probe ,probe_videocntl_vcounter         ,"videocntl.vcounter"        ,"vb");       
  --do_probe(init_probe ,probe_videocntl_hsync            ,"videocntl.hsync"           ,"vc");          
  --do_probe(init_probe ,probe_videocntl_vsync            ,"videocntl.vsync"           ,"vd");          
  --do_probe(init_probe ,probe_videocntl_toggle_dither    ,"videocntl.toggle_dither"   ,"ve");  
  --do_probe(init_probe ,probe_videocntl_hborder          ,"videocntl.hborder"         ,"vf");        
  --do_probe(init_probe ,probe_videocntl_vborder          ,"videocntl.vborder"         ,"vg");        
  --do_probe(init_probe ,probe_videocntl_hactive          ,"videocntl.hactive"         ,"vh");        
  --do_probe(init_probe ,probe_videocntl_vactive          ,"videocntl.vactive"         ,"vi");        
  --do_probe(init_probe ,probe_videocntl_bgr              ,"videocntl.bgr"             ,"vj");            
  --do_probe(init_probe ,probe_videocntl_pixel_data       ,"videocntl.pixel_data"      ,"vk");     
  --do_probe(init_probe ,probe_videocntl_color_data       ,"videocntl.color_data"      ,"vl");     

  ---- s3mo5
  --do_probe(init_probe ,probe_s3mo5_clk50m               ,"s3mo5.clk50m"              ,"c");           
  --do_probe(init_probe ,probe_s3mo5_reset                ,"s3mo5.reset"               ,"sa");             
  --do_probe(init_probe ,probe_s3mo5_reset_1t             ,"s3mo5.reset_1t"            ,"sb");           
  --do_probe(init_probe ,probe_s3mo5_reset_2t             ,"s3mo5.reset_2t"            ,"sc");           
  --do_probe(init_probe ,probe_s3mo5_resetn               ,"s3mo5.resetn"              ,"sd");             
  --do_probe(init_probe ,probe_s3mo5_soft_resetn          ,"s3mo5.soft_resetn"         ,"se");        
  --do_probe(init_probe ,probe_s3mo5_source_irq           ,"s3mo5.source_irq"          ,"sg");        
  --do_probe(init_probe ,probe_s3mo5_source_irq_sel       ,"s3mo5.source_irq_sel"      ,"sh");     
  --do_probe(init_probe ,probe_s3mo5_clken_cpu            ,"s3mo5.clken_cpu"           ,"si");          
  --do_probe(init_probe ,probe_s3mo5_cpu_nnmi             ,"s3mo5.cpu_nnmi"            ,"sj");           
  --do_probe(init_probe ,probe_s3mo5_cpu_nfiq             ,"s3mo5.cpu_nfiq"            ,"sk");           
  --do_probe(init_probe ,probe_s3mo5_cpu_nirq             ,"s3mo5.cpu_nirq"            ,"sl");          
  --do_probe(init_probe ,probe_s3mo5_keyboard_update      ,"s3mo5.keyboard_update"     ,"sm");    
  --do_probe(init_probe ,probe_s3mo5_keyboard_data        ,"s3mo5.keyboard_data"       ,"sn");      
  --do_probe(init_probe ,probe_s3mo5_keyboard_data_1t     ,"s3mo5.keyboard_data_1t"    ,"so");   
  --do_probe(init_probe ,probe_s3mo5_keyboard_data_2t     ,"s3mo5.keyboard_data_2t"    ,"sp");   
  --do_probe(init_probe ,probe_s3mo5_anode                ,"s3mo5.anode"               ,"sq");                        
  --do_probe(init_probe ,probe_s3mo5_vga_data             ,"s3mo5.vga_data"            ,"sr");          
  --do_probe(init_probe ,probe_s3mo5_vga_update           ,"s3mo5.vga_update"          ,"ss");        
  --do_probe(init_probe ,probe_s3mo5_vga_vsync_i          ,"s3mo5.vga_vsync_i"         ,"st");       
  --do_probe(init_probe ,probe_s3mo5_vga_border           ,"s3mo5.vga_border"          ,"su");        
  --do_probe(init_probe ,probe_s3mo5_cpu_turbo            ,"s3mo5.cpu_turbo"           ,"sv");         
  --do_probe(init_probe ,probe_s3mo5_cpu_turbo_1t         ,"s3mo5.cpu_turbo_1t"        ,"sw");      
  --do_probe(init_probe ,probe_s3mo5_cpu_busreq           ,"s3mo5.cpu_busreq"          ,"sx");        
  --do_probe(init_probe ,probe_s3mo5_cpu_write            ,"s3mo5.cpu_write"           ,"sy");         
  --do_probe(init_probe ,probe_s3mo5_cpu_addr             ,"s3mo5.cpu_addr"            ,"sz");          
  --do_probe(init_probe ,probe_s3mo5_cpu_wdata            ,"s3mo5.cpu_wdata"           ,"s0");         
  --do_probe(init_probe ,probe_s3mo5_cpu_rdata            ,"s3mo5.cpu_rdata"           ,"s1");         
  --do_probe(init_probe ,probe_s3mo5_sram_dataen          ,"s3mo5.sram_dataen"         ,"s2");       
  --do_probe(init_probe ,probe_s3mo5_sram_wdata           ,"s3mo5.sram_wdata"          ,"s3");        
  --do_probe(init_probe ,probe_s3mo5_sram_rdata           ,"s3mo5.sram_rdata"          ,"s4");        
  --do_probe(init_probe ,probe_s3mo5_sram_wen_i           ,"s3mo5.sram_wen_i"          ,"s5");        
  --do_probe(init_probe ,probe_s3mo5_sram_ben_i           ,"s3mo5.sram_ben_i"          ,"s6");        
  --do_probe(init_probe ,probe_s3mo5_uart_wen             ,"s3mo5.uart_wen"            ,"s7");          
  --do_probe(init_probe ,probe_s3mo5_uart_tx_i            ,"s3mo5.uart_tx_i"           ,"s8");         
  --do_probe(init_probe ,probe_s3mo5_uart_wdata           ,"s3mo5.uart_wdata"          ,"s9");        
  --do_probe(init_probe ,probe_s3mo5_uart_wbusy           ,"s3mo5.uart_wbusy"          ,"sA");        
  --do_probe(init_probe ,probe_s3mo5_uart_rdata           ,"s3mo5.uart_rdata"          ,"sB");        
  --do_probe(init_probe ,probe_s3mo5_uart_rvalid          ,"s3mo5.uart_rvalid"         ,"sC");       
  --do_probe(init_probe ,probe_s3mo5_keyboard_col         ,"s3mo5.keyboard_col"        ,"sD");      
  --do_probe(init_probe ,probe_s3mo5_keyboard_row         ,"s3mo5.keyboard_row"        ,"sE");      
  --do_probe(init_probe ,probe_s3mo5_keyboard_hit         ,"s3mo5.keyboard_hit"        ,"sF");     
  --do_probe(init_probe ,probe_s3mo5_keyboard_toggle      ,"s3mo5.keyboard_toggle"     ,"sG");   
  --do_probe(init_probe ,probe_s3mo5_keyboard_esc         ,"s3mo5.keyboard_esc"        ,"sH");       
  --do_probe(init_probe ,probe_s3mo5_clken_uart           ,"s3mo5.clken_uart"          ,"sI");         
  --do_probe(init_probe ,probe_s3mo5_clken_20ms           ,"s3mo5.clken_20ms"          ,"sJ");         
  --do_probe(init_probe ,probe_s3mo5_clken_s7             ,"s3mo5.clken_s7"            ,"sK");           
  --do_probe(init_probe ,probe_s3mo5_state_s7             ,"s3mo5.state_s7"            ,"sL");           
  --do_probe(init_probe ,probe_s3mo5_divider_uart         ,"s3mo5.divider_uart"        ,"sM");       
  --do_probe(init_probe ,probe_s3mo5_divider_20ms         ,"s3mo5.divider_20ms"        ,"sN");       

  ----testbench
  --do_probe(init_probe ,probe_tb_done_uart               ,"tb.done_uart"              ,"ta");                
  --do_probe(init_probe ,probe_tb_done_keyboard           ,"tb.done_keyboard"          ,"tb");        
  --do_probe(init_probe ,probe_tb_clk_osc                 ,"tb.clk_osc"                ,"d");              
  --do_probe(init_probe ,probe_tb_resetn                  ,"tb.resetn"                 ,"td");               
  --do_probe(init_probe ,probe_tb_pbutton                 ,"tb.pbutton"                ,"te");              
  --do_probe(init_probe ,probe_tb_switch                  ,"tb.switch"                 ,"tf");               
  --do_probe(init_probe ,probe_tb_uart_tx                 ,"tb.uart_tx"                ,"tg");              
  --do_probe(init_probe ,probe_tb_uart_rx                 ,"tb.uart_rx"                ,"th");              
  --do_probe(init_probe ,probe_tb_ps2_c                   ,"tb.ps2_c"                  ,"ti");                
  --do_probe(init_probe ,probe_tb_ps2_d                   ,"tb.ps2_d"                  ,"tj");                
  --do_probe(init_probe ,probe_tb_sram_wen                ,"tb.sram_wen"               ,"tk");             
  --do_probe(init_probe ,probe_tb_sram_oen                ,"tb.sram_oen"               ,"tl");             
  --do_probe(init_probe ,probe_tb_sram_a                  ,"tb.sram_a"                 ,"tm");               
  --do_probe(init_probe ,probe_tb_sram_csn                ,"tb.sram_csn"               ,"tn");             
  --do_probe(init_probe ,probe_tb_sram_ben                ,"tb.sram_ben"               ,"to");             
  --do_probe(init_probe ,probe_tb_sram_dq                 ,"tb.sram_dq"                ,"tp");             

  -- ---------------------------------------------------------------------------
  -- assignments
  -- ---------------------------------------------------------------------------
  p_cpu_logger:process(probe_s3mo5_resetn,probe_s3mo5_clk50m)
  
    file file_out                : text open write_mode is "cpu.log";
    variable line_out            : line;
  
    variable p_s3mo5_cpu_nnmi    : std_logic;
    variable p_s3mo5_cpu_nfiq    : std_logic;  
    variable p_s3mo5_cpu_nirq    : std_logic;     
    variable p_a                 : std_logic_vector( 7 downto 0);            
    variable p_b                 : std_logic_vector( 7 downto 0);            
    variable p_x                 : std_logic_vector(15 downto 0);            
    variable p_y                 : std_logic_vector(15 downto 0);            
    variable p_u                 : std_logic_vector(15 downto 0);            
    variable p_s                 : std_logic_vector(15 downto 0);            
    variable p_pc                : std_logic_vector(15 downto 0);          
    variable p_cc                : std_logic_vector( 7 downto 0);           
    variable p_dp                : std_logic_vector( 7 downto 0);           
    variable p_state             : t_cpu_state;      
    variable p_next_state        : t_cpu_state; 
    variable p_refetch           : std_logic;        
    variable p_opcode            : std_logic_vector( 9 downto 0);              
    variable p_s3mo5_cpu_busreq  : std_logic;     
    variable p_s3mo5_cpu_write   : std_logic;     
    variable p_s3mo5_cpu_addr    : std_logic_vector(15 downto 0);     
    variable p_s3mo5_cpu_wdata   : std_logic_vector( 7 downto 0);     
    variable p_s3mo5_cpu_rdata   : std_logic_vector( 7 downto 0);         
  
  
  begin
    
    if probe_s3mo5_resetn='0' then
    
      p_s3mo5_cpu_nnmi    := probe_s3mo5_cpu_nnmi;   
      p_s3mo5_cpu_nfiq    := probe_s3mo5_cpu_nfiq;   
      p_s3mo5_cpu_nirq    := probe_s3mo5_cpu_nirq;   
      p_a                 := probe_a;                
      p_b                 := probe_b;                
      p_x                 := probe_x;                
      p_y                 := probe_y;               
      p_u                 := probe_u;                
      p_s                 := probe_s;                
      p_pc                := probe_pc;               
      p_cc                := probe_cc;               
      p_dp                := probe_dp;               
      p_state             := probe_state;            
      p_next_state        := probe_next_state;       
      p_refetch           := probe_refetch;          
      p_opcode            := probe_opcode;           
      p_s3mo5_cpu_busreq  := probe_s3mo5_cpu_busreq; 
      p_s3mo5_cpu_write   := probe_s3mo5_cpu_write;  
      p_s3mo5_cpu_addr    := probe_s3mo5_cpu_addr;   
      p_s3mo5_cpu_wdata   := probe_s3mo5_cpu_wdata;  
      p_s3mo5_cpu_rdata   := probe_s3mo5_cpu_rdata;  
     
    elsif probe_s3mo5_clk50m'event and probe_s3mo5_clk50m='1' then
    
      if probe_s3mo5_clken_cpu='1' then

        if p_s3mo5_cpu_nnmi/=probe_s3mo5_cpu_nnmi then
        
          write(line_out,string'("cpu_nmi "));
          write(line_out,probe_s3mo5_cpu_nnmi);
          writeline(file_out,line_out);
          p_s3mo5_cpu_nnmi := probe_s3mo5_cpu_nnmi;   
        
        end if;
        
        if p_s3mo5_cpu_nirq/=probe_s3mo5_cpu_nirq then
        
          write(line_out,string'("cpu_nmi "));
          write(line_out,probe_s3mo5_cpu_nnmi);
          writeline(file_out,line_out);
          p_s3mo5_cpu_nirq := probe_s3mo5_cpu_nirq;   
        
        end if;
      
        if p_a/=probe_a then
        
          write(line_out,string'("a "));
          hwrite(line_out,probe_a);
          writeline(file_out,line_out);
          p_a := probe_a;                
        
        end if;
    
        if p_b/=probe_b then
        
          write(line_out,string'("b "));
          hwrite(line_out,probe_b);
          writeline(file_out,line_out);
          p_b := probe_b;                
        
        end if;
       
        if p_x/=probe_x then
        
          write(line_out,string'("x "));
          hwrite(line_out,probe_x);
          writeline(file_out,line_out);
          p_x := probe_x;                
        
        end if;

        if p_y/=probe_y then
        
          write(line_out,string'("y "));
          hwrite(line_out,probe_y);
          writeline(file_out,line_out);
          p_y := probe_y;                
        
        end if;

        if p_u/=probe_u then
        
          write(line_out,string'("u "));
          hwrite(line_out,probe_u);
          writeline(file_out,line_out);
          p_u := probe_u;                
        
        end if;
  
        if p_s/=probe_s then
        
          write(line_out,string'("s "));
          hwrite(line_out,probe_s);
          writeline(file_out,line_out);
          p_s := probe_s;                
        
        end if;

        if p_pc/=probe_pc then
        
          write(line_out,string'("pc "));
          hwrite(line_out,probe_pc);
          writeline(file_out,line_out);
          p_pc := probe_pc;                
        
        end if;
     
        if p_cc/=probe_cc then
        
          write(line_out,string'("cc "));
          hwrite(line_out,probe_cc);
          writeline(file_out,line_out);
          p_cc := probe_cc;                
        
        end if;
 
        if p_dp/=probe_dp then
        
          write(line_out,string'("dp "));
          hwrite(line_out,probe_dp);
          writeline(file_out,line_out);
          p_dp := probe_dp;                
        
        end if;
      
         if p_state/=probe_state then
        
          write(line_out,string'("cs "));
          write(line_out,t_cpu_state'image(probe_state));
          writeline(file_out,line_out);
          p_state := probe_state;                
        
        end if;
     
         if p_next_state/=probe_next_state then
        
          write(line_out,string'("ns "));
          write(line_out,t_cpu_state'image(probe_next_state));
          writeline(file_out,line_out);
          p_next_state := probe_next_state;                
        
        end if;
     
        if p_refetch/=probe_refetch then
        
          write(line_out,string'("rf "));
          write(line_out,probe_refetch);
          writeline(file_out,line_out);
          p_refetch := probe_refetch;          
        
        end if;

        if p_opcode/=probe_opcode then
        
          write(line_out,string'("op "));
          hwrite(line_out,"00"&probe_opcode);
          writeline(file_out,line_out);
          p_opcode := probe_opcode;           
        
        end if;
      
        if p_s3mo5_cpu_busreq/=probe_s3mo5_cpu_busreq then
        
          write(line_out,string'("bs "));
          write(line_out,probe_s3mo5_cpu_busreq);
          writeline(file_out,line_out);
          p_s3mo5_cpu_busreq := probe_s3mo5_cpu_busreq; 
        
        end if;
    
        if p_s3mo5_cpu_write/=probe_s3mo5_cpu_write then
        
          write(line_out,string'("wr "));
          write(line_out,probe_s3mo5_cpu_write);
          writeline(file_out,line_out);
          p_s3mo5_cpu_write := probe_s3mo5_cpu_write;  
        
        end if;
       
        if p_s3mo5_cpu_addr/=probe_s3mo5_cpu_addr then
        
          write(line_out,string'("ad "));
          hwrite(line_out,probe_s3mo5_cpu_addr);
          writeline(file_out,line_out);
          p_s3mo5_cpu_addr    := probe_s3mo5_cpu_addr;   
        
        end if;

        if p_s3mo5_cpu_wdata/=probe_s3mo5_cpu_wdata then
        
          write(line_out,string'("wd "));
          hwrite(line_out,probe_s3mo5_cpu_wdata);
          writeline(file_out,line_out);
          p_s3mo5_cpu_wdata := probe_s3mo5_cpu_wdata;  
        
        end if;

        if p_s3mo5_cpu_rdata/=probe_s3mo5_cpu_rdata then
        
          write(line_out,string'("rd "));
          hwrite(line_out,probe_s3mo5_cpu_rdata);
          writeline(file_out,line_out);
          p_s3mo5_cpu_rdata := probe_s3mo5_cpu_rdata;  
        
        end if;
      
      end if;
    
    end if;
  
  end process p_cpu_logger;
  
  -- ---------------------------------------------------------------------------
  -- assignments
  -- ---------------------------------------------------------------------------
  switch              <= "11111111";
  pbutton(3)          <= not resetn;
  pbutton(2 downto 0) <= "000";
  dump_ram0           <= '0';
  dump_ram1           <= '0';
  
  -- ---------------------------------------------------------------------------
  -- clock generation
  -- ---------------------------------------------------------------------------
  p_clk_osc_generation:process
  begin
  
    if done_uart='1' and done_keyboard='1' then
    
      wait;
    
    else
    
      clk_osc <= '0';
      wait for 10 ns;
      clk_osc <= '1';
      wait for 10 ns;
    
    end if;
  
  end process p_clk_osc_generation;
 
  -- ---------------------------------------------------------------------------
  -- clock enable for uart (host)
  -- ---------------------------------------------------------------------------
  p_clken_uart_generation:process(resetn,clk_osc)
  begin
  
    if resetn='0' then
    
      clken_uart   <= '0';
      uart_divider <= "0000000";
    
    elsif clk_osc'event and clk_osc='1' then
    
      if uart_divider="1101100" then
      
        clken_uart   <= '1';
        uart_divider <= "0000000";
        
      else
      
        clken_uart   <= '0';
        uart_divider <= uart_divider + "0000001";
      
      end if;
    
    end if;
  
  end process p_clken_uart_generation;
  
  -- ---------------------------------------------------------------------------
  -- reset generation
  -- ---------------------------------------------------------------------------
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 755 ns;
    resetn <= '1';
    wait;
  
  end process p_reset_generation;
 
  -- ---------------------------------------------------------------------------
  -- uart stimuli generation
  -- ---------------------------------------------------------------------------
  p_uart_host:process(clk_osc,resetn)
  
    file file_in        : text open read_mode is "./stimuli/tb_s3mo5_uart.txt";
    variable line_in    : line;
    variable line_out   : line;
    variable tmp_t      : time;
    variable tmp_c      : character;
    variable tmp_8      : std_logic_vector(7 downto 0);
    variable retry      : std_logic := '0';
    
    variable wait_until : std_logic := '0';
    variable wait_qty   : time;
  
  begin
    
    if resetn='0' then
    
      uart_wen <= '0';
      
    elsif clk_osc'event and clk_osc='1' then
    
      
      uart_wen <= '0';
      if done_uart='0' then
    
        if wait_until='1' then
        
          if now> wait_qty then
          
          
            wait_until := '0';
          
          end if;
        
        else
        
          if retry='0' then
    
            loop                                   
                                                   
              readline(file_in,line_in);           
              read(line_in,tmp_c);                 
          
              exit when tmp_c='T' or               
                        tmp_c='R' or               
                        tmp_c='W' or               
                        tmp_c='E';                 
                                                   
            end loop; 
            
            uart_wen <= '0';
            
          end if;                             
                                                 
          case tmp_c is                          
                                                 
            when 'T'=> 
            
              if uart_wbusy='1' or uart_wen='1' then
              
                retry    := '1';
                
              else
              
                hread(line_in,tmp_8);
                uart_wdata <= tmp_8;
                uart_wen   <= '1';
                retry := '0';
                
              end if;
              
            when 'R'=> 
            
              if uart_rvalid='0' then
              
                retry := '1';
                
              else
              
                retry := '0';
                hread(line_in,tmp_8);
              
                if tmp_8/=uart_rdata then
              
                  write(line_out,string'("uart check failure @"&time'image(now)));
                  writeline(output,line_out);
                
                  write(line_out,string'("read     : "));
                  hwrite(line_out,uart_rdata);
                  writeline(output,line_out);
                
                  write(line_out,string'("expected : "));
                  hwrite(line_out,tmp_8);
                  writeline(output,line_out);

                end if;
                
              end if;
              
            when 'W'=>
            
              read(line_in,tmp_t);
              wait_until := '1';
              wait_qty   := now + tmp_t;
            
            when 'E'=>
            
              done_uart <= '1';
                                                 
            when others=>                        
                                                 
              assert false                       
                report "unknown uart command "&tmp_c  
                  severity failure;              
                                                 
          end case;                              
        
        end if;
    
      end if;
    
    end if;
  
  end process p_uart_host;
  
  -- ---------------------------------------------------------------------------
  -- PS/2 stimuli generation
  -- ---------------------------------------------------------------------------
  p_keyboard_device:process
  
    file file_in        : text open read_mode is "./stimuli/tb_s3mo5_ps2.txt";
    variable line_in    : line;
    variable tmp_t      : time;
    variable tmp_c      : character;
    variable tmp_8      : std_logic_vector(7 downto 0);
   
    variable wait_until : std_logic := '0';
    variable wait_qty   : time;
  
  begin
  
    if wait_until='1' then                                  
                                                            
      if now> wait_qty then                                 
                                                            
        wait_until := '0';                                  
                                                            
      end if;                                               
                                                            
      wait for 1 us;                                       
                                                            
    else                                                    
    
      loop                                                  
                                                            
        readline(file_in,line_in);                          
        read(line_in,tmp_c);                                
                                                            
        exit when tmp_c='K' or                              
                  tmp_c='W' or                              
                  tmp_c='E';                                
                                                            
      end loop;                                             
                                                            
      case tmp_c is                                         
                                                            
        when 'K'=>                                          
                                                            
          hread(line_in,tmp_8);                             
                                                            
          for i in 0 to 10 loop                              
                                                            
            if i=0 then
            
              ps2_d <= '0';
              
            elsif i=9 then
            
              ps2_d <= not(tmp_8(0) xor tmp_8(1) xor
                           tmp_8(2) xor tmp_8(3) xor
                           tmp_8(4) xor tmp_8(5) xor
                           tmp_8(6) xor tmp_8(7));
                         
            
            elsif i=10 then
            
              ps2_d <= '1';
            
            else
            
              ps2_d <= tmp_8(i-1);                            
            end if;
            
            wait for 20 us;                                 
            ps2_c <= '0';                                   
            wait for 40 us;                                 
            ps2_c <= '1';                                   
            wait for 20 us;     
              
          end loop;                                         
                                                            
        when 'W'=>                                          
                                                            
          read(line_in,tmp_t);                              
          wait_until := '1';                                
          wait_qty   := now + tmp_t;                        
                                                            
        when 'E'=>                                          
                                                            
          done_keyboard <= '1';                             
          wait;                                             
                                                            
        when others=>                                       
                                                            
          assert false                                      
            report "unknown keyboard command "&tmp_c        
              severity failure;                             
                                                            
      end case;                                             
                                                            
    end if;                                                 
    
  end process p_keyboard_device;
  
  -- ---------------------------------------------------------------------------
  -- host uart
  -- ---------------------------------------------------------------------------
  host_uart_0:uart
  port map
  (
    -- system                                     
    resetn   => resetn,
    clk      => clk_osc,
    clken    => clken_uart,
                                                  
    -- tx                                         
    wen      => uart_wen,
    data_in  => uart_wdata,
    busy     => uart_wbusy,
    tx       => uart_tx,
                                                  
    -- rx                                         
    rx       => uart_rx, 
    data_out => uart_rdata,
    valid    => uart_rvalid
  );

  -- ---------------------------------------------------------------------------
  -- s3mo5 instance
  -- ---------------------------------------------------------------------------
  s3mo5_1:s3mo5
  port map
  (
    clk_osc        => clk_osc,
                                                           
    -- push buttons                                        
    pbutton        => pbutton,
                                                           
    -- switches                                            
    switch         => switch,
                                                           
    -- 4x7 segments display                                
    anode_s7       => open,
    s7             => open,
    led            => open,
                                                           
    -- rs-232                                              
    uart_tx        => uart_rx,
    uart_rx        => uart_tx,
                                                           
    -- PS/2                                                
    ps2_c          => ps2_c,
    ps2_d          => ps2_d,
                                                           
    -- ram                                                 
    sram_wen       => sram_wen,
    sram_oen       => sram_oen,
    sram_a         => sram_a,
    sram_csn       => sram_csn,
    sram_ben       => sram_ben,
    sram_dq        => sram_dq,
                                                           
    -- Video                                               
    vga_hsync      => open,     
    vga_vsync      => open,         
    vga_r          => open,
    vga_g          => open,
    vga_b          => open,
    
    -- sound
    sound          => open,
    
    -- flash
    flash_clk      => flash_clk,
    flash_q        => flash_q
  );

  -- ---------------------------------------------------------------------------
  -- external sram instance
  -- ---------------------------------------------------------------------------
  ram256kx16_0:ram256kx16
  generic map
  (
    init_filemode => 1,
    init_filename => "./stimuli/tb_s3mo5_ram0.txt",
    dump_filename => "./dump_ram0.txt"
    
  )                                                    
  port map                                                 
  (                                                     
    dump     => dump_ram0,
    csn      => sram_csn(0),
    wen      => sram_wen,           
    oen      => sram_oen,
    ubn      => sram_ben(0),     
    lbn      => sram_ben(1),    
    a        => sram_a,
    dq       => sram_dq(15 downto 0)
  );                                                    
  
  ram256kx16_1:ram256kx16
  generic map
  (
    init_filemode => 1,
    init_filename => "./stimuli/tb_s3mo5_ram1.txt",
    dump_filename => "./dump_ram1.txt"
  )                                                    
  port map                                                 
  (                                                     
    dump     => dump_ram1,
    csn      => sram_csn(1),
    wen      => sram_wen,           
    oen      => sram_oen,
    ubn      => sram_ben(2),     
    lbn      => sram_ben(3),    
    a        => sram_a,
    dq       => sram_dq(31 downto 16)
  );                                                    
 
end architecture testbench;


