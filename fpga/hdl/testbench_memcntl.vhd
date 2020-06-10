----------------------------------------------------------------------
--
-- S3MO5 - testbench memcntl
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

entity testbench_memcntl is
end entity testbench_memcntl;

architecture testbench of testbench_memcntl is

  component memcntl
    port
    (
     -- system
     resetn           :    in std_logic;
     clk50m           :    in std_logic;
     soft_resetn      :   out std_logic;
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
     sram_rdata       :    in std_logic_vector(15 downto 0);
     sram_wdata       :   out std_logic_vector( 7 downto 0); 
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
     -- sound
     sound            :   out std_logic
    );
  end component;

  component videocntl
    port
    (
      -- system
      resetn     :  in std_logic;
      clk        :  in std_logic;
      -- data
      data_req   : out std_logic;
      data       :  in std_logic_vector(15 downto 0); 
      border     :  in std_logic_vector( 3 downto 0);
      -- 
      hsync      : out std_logic; 
      vsync      : out std_logic; 
      r          : out std_logic; 
      g          : out std_logic; 
      b          : out std_logic  
    );
  end component;

  component ram256kx16
    generic
    (
      filename : string
    );
    port
    (
      csn      :    in std_logic;
      wen      :    in std_logic; 
      oen      :    in std_logic; 
      ubn      :    in std_logic; 
      lbn      :    in std_logic; 
      a        :    in std_logic_vector(17 downto 0);
      dq       : inout std_logic_vector(15 downto 0)    
    );
  end component;
  
  -- system
  signal resetn      :  std_logic;
  signal soft_resetn :  std_logic;
  signal clk50m      :  std_logic;
  signal clken8m     :  std_logic;
  -- processor
  signal cpu_clken   :  std_logic;
  signal cpu_busreq  :  std_logic;
  signal cpu_write   :  std_logic;
  signal cpu_addr    :  std_logic_vector(15 downto 0);
  signal cpu_wdata   :  std_logic_vector( 7 downto 0);
  signal cpu_rdata   :  std_logic_vector( 7 downto 0);
   -- external sram
  signal memcntl_wen :  std_logic;
  signal sram_wen    :  std_logic;
  signal sram_oen    :  std_logic;
  signal sram_a      :  std_logic_vector(17 downto 0);
  signal sram_csn    :  std_logic_vector( 1 downto 0);
  signal sram_ben    :  std_logic_vector( 1 downto 0);
  signal sram_be1n   :  std_logic_vector( 1 downto 0);
  signal sram_dataen :  std_logic_vector( 1 downto 0);
  signal sram_rdata  :  std_logic_vector(15 downto 0);
  signal sram_wdata  :  std_logic_vector( 7 downto 0); 
  signal sram_dq     :  std_logic_vector(31 downto 0); 
  -- vga controller
  signal vga_hsync   :  std_logic;
  signal vga_vsync   :  std_logic;
  signal vga_data    :  std_logic_vector(15 downto 0);
  signal vga_update  :  std_logic; 
   -- jtag rom
  signal flash_clk   :  std_logic;
  signal flash_q     :  std_logic;
   -- uart tx
  signal uart_wen    :  std_logic;
  signal uart_wdata  :  std_logic_vector( 7 downto 0);
  signal uart_wbusy  :  std_logic;
  signal uart_rdata  :  std_logic_vector( 7 downto 0);
  signal uart_rvalid :  std_logic;
  --
  signal done        : std_logic :='0';
  signal line_pos    : integer   := 0;
  signal cpu_idle    : integer   := 0;

begin 
  -- ---------------------------------------------------------------------------
  -- assignments
  -- ---------------------------------------------------------------------------
  sram_dq( 7 downto  0) <= sram_wdata when sram_dataen(0)='1' else 
                          (others=>'Z');
  sram_dq(15 downto  8) <= sram_wdata when sram_dataen(1)='1' else 
                          (others=>'Z');
  sram_dq(23 downto 16) <= sram_wdata when sram_dataen(0)='1' else 
                          (others=>'Z');
  sram_dq(31 downto 24) <= sram_wdata when sram_dataen(1)='1' else 
                          (others=>'Z');

  sram_rdata <= sram_dq(15 downto  0);
  sram_rdata <= sram_dq(31 downto 16);

  -- ---------------------------------------------------------------------------
  -- clock generation
  -- ---------------------------------------------------------------------------
  p_clock_generation:process
  begin
  
    if done='1' then
    
      wait;
    
    else
     
      clk50m  <= '0';
      wait for 10 ns;
      clk50m  <= '1';
      wait for 10 ns;
    
    end if;
  
  end process p_clock_generation;
  
  -- ---------------------------------------------------------------------------
  --  reset generation
  -- ---------------------------------------------------------------------------
  p_reset_generation:process
  begin
  
    resetn <= '0';
    wait for 505 ns;
    resetn <= '1';
    wait until soft_resetn'event and soft_resetn='0';
  
  end process p_reset_generation;
 
  -- ---------------------------------------------------------------------------
  -- wen pulse generation
  -- ---------------------------------------------------------------------------
  p_wen_pulse_generation:process
  begin
    wait until clk50m'event and clk50m='0';
  
    sram_wen <= memcntl_wen;
  
  end process p_wen_pulse_generation;

  -- ---------------------------------------------------------------------------
  -- cpu interface
  -- ---------------------------------------------------------------------------
  p_cpu_interface:process(resetn,clk50m)
  
    file file_in             : text open read_mode is "./stimuli/tb_memcntl_cpu.txt";
    variable line_in         : line;                                                 
    variable line_out        : line;                                                 
    variable tmp_c           : character;                                            
    variable tmp_addr        : std_logic_vector(15 downto 0);                        
    variable tmp_data        : std_logic_vector( 7 downto 0);                        
    variable tmp_mask        : std_logic_vector( 7 downto 0);                        
    variable read_check      : std_logic;
    variable read_check_data : std_logic_vector( 7 downto 0);
    variable read_check_mask : std_logic_vector( 7 downto 0);
    variable cpu_end         : std_logic;
    variable tmp_i           : integer;
    
  begin
  
    if resetn='0' then
    
      cpu_busreq <= '0';
      cpu_write  <= '0'; 
      cpu_addr   <= (others=>'0');  
      cpu_wdata  <= (others=>'0'); 
      
      cpu_idle   <= 0;
      read_check := '0';
       
    elsif clk50m'event and clk50m='1' then
    
      if cpu_clken='1' then
      
        cpu_busreq <= '0';
        cpu_write  <= '0'; 
        cpu_addr   <= (others=>'0');  
        cpu_wdata  <= (others=>'0'); 
        
        if done='0' then
          
          if read_check='1' then                                                              
        
            if (read_check_data and read_check_mask) /= (cpu_rdata and read_check_mask) then  
                                                                                              
              write(line_out,string'("cpu read check failed at "));                           
              write(line_out,now);                                                            
              write(line_out,string'(", line :"));                           
              write(line_out,line_pos);                                                            
              writeline(output,line_out);                                                     
 
              write(line_out,string'("read data     : "));                                    
              hwrite(line_out,cpu_rdata);                                                     
              writeline(output,line_out);                                                     
                                                                                              
              write(line_out,string'("expected data : "));                                    
              hwrite(line_out,read_check_data);                                               
              writeline(output,line_out);                                                     
                                                                                              
              write(line_out,string'("mask          : "));                                    
              hwrite(line_out,read_check_mask);                                               
              writeline(output,line_out);                                                     
                                                                                              
            end if;                                                                           
        
          end if;                                                                             
          read_check := '0';                                                                  
          
          if cpu_idle/=0 then
        
            cpu_idle <= cpu_idle -1 ;
        
          else
        
      
            if not(endfile(file_in)) then
      
              tmp_i := 0;
              loop
              
                readline(file_in,line_in);
                read(line_in,tmp_c);
                tmp_i := tmp_i + 1;
                exit when tmp_c='R' or
                          tmp_c='W' or
                          tmp_c='E' or
                          tmp_c='I';
              
              end loop;
              
              line_pos <= line_pos + tmp_i;
              
              case tmp_c is
              
                when 'I'=>
                
                  read(line_in,tmp_i);
                  if tmp_i/=0 then
                  
                    cpu_idle <= tmp_i - 1;
                  
                  end if;
                
                when 'W'=>
                
                  hread(line_in,tmp_addr);
                  hread(line_in,tmp_data);
                  
                  cpu_busreq <= '1';
                  cpu_write  <= '1';
                  cpu_addr   <= tmp_addr;
                  cpu_wdata  <= tmp_data;
                 
                when 'R'=>
                
                  hread(line_in,tmp_addr);
                  hread(line_in,tmp_data);
                  hread(line_in,tmp_mask);
                  
                  cpu_busreq      <= '1';
                  cpu_write       <= '0';
                  cpu_addr        <= tmp_addr;
                  
                  read_check      := '1';
                  read_check_data := tmp_data;
                  read_check_mask := tmp_mask;
              
                when 'E'=>
                
                  done <= '1';
                
                when others=>
                
                  null;
              
              end case;
      
            end if;
        
          end if;
      
        end if;
      
      end if;
    
    end if;
  
  end process p_cpu_interface;


  -- ---------------------------------------------------------------------------
  -- memory instance
  -- ---------------------------------------------------------------------------
  ram_0:ram256kx16
  generic map
  (
    filename => "./stimuli/tb_memcntl_ram0.txt"
  )
  port map
  (
    csn      => sram_csn(0),
    wen      => sram_wen,
    oen      => sram_oen,
    ubn      => sram_ben(1),
    lbn      => sram_ben(0),
    a        => sram_a,
    dq       => sram_dq(15 downto 0)
  );
 
  ram_1:ram256kx16
  generic map
  (
    filename => "./stimuli/tb_memcntl_ram1.txt"
  )
  port map
  (
    csn      => sram_csn(1),
    wen      => sram_wen,
    oen      => sram_oen,
    ubn      => sram_ben(1),
    lbn      => sram_ben(0),
    a        => sram_a,
    dq       => sram_dq(31 downto 16)
  );

  -- ---------------------------------------------------------------------------
  -- memory controller instance
  -- ---------------------------------------------------------------------------
  memcntl_0:memcntl
  port map
  (
     -- system
     resetn         => resetn,
     clk50m         => clk50m,
     soft_resetn    => soft_resetn,
     -- processor
     cpu_clken      => cpu_clken,
     cpu_nnmi       => open,
     cpu_nfiq       => open,     
     cpu_nirq       => open,     
     cpu_busreq     => cpu_busreq,
     cpu_write      => cpu_write, 
     cpu_addr       => cpu_addr,  
     cpu_wdata      => cpu_wdata, 
     cpu_rdata      => cpu_rdata, 
     -- external sram
     sram_wen       => memcntl_wen,   
     sram_oen       => sram_oen,   
     sram_a         => sram_a,     
     sram_csn       => sram_csn,  
     sram_ben       => sram_ben,  
     sram_dataen    => sram_dataen,
     sram_rdata     => sram_rdata, 
     sram_wdata     => sram_wdata, 
     -- vga controller
     vga_vsync      => vga_vsync,  
     vga_data       => vga_data,   
     vga_update     => vga_update, 
     vga_border     => open,
     -- jtag rom
     flash_clk      => open, 
     flash_q        => '0',   
     -- uart tx
     uart_wen       => open,   
     uart_wdata     => open,
     uart_wbusy     => '0', 
     uart_rdata     => "00000000", 
     uart_rvalid    => '0',
     -- keyboard
     keyboard_col   => open,
     keyboard_row   => open,
     keyboard_hit   => '0',
     -- sound
     sound          => open
  );
  
  -- ---------------------------------------------------------------------------
  -- video controller instance
  -- ---------------------------------------------------------------------------
  videocntl0:videocntl
  port map
  (
    resetn     => resetn,
    clk        => clk50m,
    data_req   => vga_update,
    data       => vga_data,
    border     => "1000",
    hsync      => vga_hsync,
    vsync      => vga_vsync,
    r          => open,
    g          => open,
    b          => open
  );

end architecture testbench;

configuration memcntl_conf of testbench_memcntl is
  for testbench
    for all:memcntl
      use entity work.memcntl(rtl);
    end for;
    for all:videocntl
      use entity work.videocntl(rtl);
    end for;
    for all:ram256kx16
      use entity work.ram256kx16(behaviour);
    end for;
  end for;
end configuration memcntl_conf;

