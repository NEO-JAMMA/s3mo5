----------------------------------------------------------------------
--
-- S3MO5 - s3mo5
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
-- NOTE: pbutton(3) : reset
--       switch(7)  : irq_sel (timer 20 ms or vsync 13.3 ms) 
--       switch(2)  : time average for color display
--       switch(1)  : 7 segments display (ps2=0;uart=1)
--       switch(0)  : turbo
--      
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.s3mo5_package.all;

entity s3mo5 is  
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
    led            :   out std_logic_vector( 7 downto 0);
    
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
end entity s3mo5;

architecture rtl of s3mo5 is

  component memcntl
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

  component videocntl
    port
    (
      -- system
      resetn       :  in std_logic;
      clk          :  in std_logic;
      time_average :  in std_logic;
      -- data
      data_req     : out std_logic;
      data         :  in std_logic_vector(15 downto 0); --pixel&color
      border       :  in std_logic_vector( 3 downto 0);
      -- 
      hsync        : out std_logic; 
      vsync        : out std_logic; 
      r            : out std_logic; 
      g            : out std_logic; 
      b            : out std_logic  
    );
  end component;

  component keyboard
    port
    (
      -- system
      resetn       :  in std_logic;
      clk          :  in std_logic;
      clken_1ms    :  in std_logic;
      clken_20ms   :  in std_logic;
      -- PS2
      ps2c         :  in std_logic;
      ps2d         :  in std_logic;
      --
      data         : out std_logic_vector( 7 downto 0);
      data_update  : out std_logic;
      key_row      :  in std_logic_vector( 2 downto 0);
      key_column   :  in std_logic_vector( 2 downto 0);
      key_hit      : out std_logic;
      --
      key_esc      : out std_logic
    );
  end component;

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
     
  -- system
  signal reset           : std_logic; 
  signal reset_1t        : std_logic; 
  signal reset_2t        : std_logic; 
  signal resetn          : std_logic; 
  signal soft_resetn     : std_logic; 
  signal clk50m          : std_logic;
  signal source_irq      : std_logic;
  signal source_irq_sel  : std_logic;
  -- processor
  signal clken_cpu       : std_logic;
  signal cpu_nnmi        : std_logic;
  signal cpu_nfiq        : std_logic;
  signal cpu_nirq        : std_logic;
  -- keyboard
  signal keyboard_data   : std_logic_vector( 7 downto 0);
  signal keyboard_update : std_logic;
  -- 7 segments
  signal anode           : std_logic_vector( 3 downto 0);
  signal disp7s_toggle   : std_logic;
  signal disp7s_data     : std_logic_vector( 7 downto 0);
  signal disp7s_data_1t  : std_logic_vector( 7 downto 0);
  signal disp7s_data_2t  : std_logic_vector( 7 downto 0);
  -- vga controller
  signal vga_data        : std_logic_vector(15 downto 0);
  signal vga_update      : std_logic;
  signal vga_vsync_i     : std_logic;
  signal vga_border      : std_logic_vector( 3 downto 0);
  -- processor
  signal cpu_turbo       : std_logic;
  signal cpu_turbo_1t    : std_logic;
  signal cpu_busreq      : std_logic;
  signal cpu_write       : std_logic;
  signal cpu_addr        : std_logic_vector(15 downto 0);
  signal cpu_wdata       : std_logic_vector( 7 downto 0);
  signal cpu_rdata       : std_logic_vector( 7 downto 0);
  -- sram
  signal sram_dataen     : std_logic_vector( 1 downto 0);
  signal sram_wdata      : std_logic_vector(31 downto 0);
  signal sram_rdata      : std_logic_vector(31 downto 0);
  signal sram_wen_i      : std_logic;
  signal sram_ben_i      : std_logic_vector( 1 downto 0);
  -- uart
  signal uart_wen        : std_logic;
  signal uart_tx_i       : std_logic;
  signal uart_wdata      : std_logic_vector( 7 downto 0);
  signal uart_wbusy      : std_logic;
  signal uart_rdata      : std_logic_vector( 7 downto 0);
  signal uart_rvalid     : std_logic;
  -- keyboard
  signal keyboard_col    : std_logic_vector( 2 downto 0);
  signal keyboard_row    : std_logic_vector( 2 downto 0);
  signal keyboard_hit    : std_logic;
  signal keyboard_toggle : std_logic;
  signal keyboard_esc    : std_logic;
  -- dividers
  signal clken_uart      : std_logic;
  signal clken_20ms      : std_logic;
  signal clken_s7        : std_logic;
  signal state_s7        : std_logic;
  signal divider_uart    : std_logic_vector( 6 downto 0);
  signal divider_20ms    : std_logic_vector(13 downto 0);
  
begin
  
  -- ---------------------------------------------------------------------------
  -- Assignements
  -- ---------------------------------------------------------------------------
  --
  reset            <= pbutton(3) or reset_2t;
  resetn           <= not reset;
  clk50m           <= clk_osc;
  
  -- led
  led(7)           <= not uart_rx;
  led(6)           <= not uart_tx_i;
  led(5 downto 1)  <= "00000";
  
  -- dummy connection to prevent logic trim
  led(0)           <= pbutton(2) and pbutton(1) and pbutton(0) and
                      switch(3) and
                      switch(3) and switch(4) and switch(5) and switch(6) and 
                      flash_q ;
  -- 7 segment
  anode_s7         <= anode;
  
  -- sram tri-state buffer
  sram_dq( 7 downto  0) <= sram_wdata( 7 downto  0) when sram_dataen(0)='1' else (others=>'Z');
  sram_dq(15 downto  8) <= sram_wdata(15 downto  8) when sram_dataen(1)='1' else (others=>'Z');
  sram_dq(23 downto 16) <= sram_wdata(23 downto 16) when sram_dataen(0)='1' else (others=>'Z');
  sram_dq(31 downto 24) <= sram_wdata(31 downto 24) when sram_dataen(1)='1' else (others=>'Z');
  
  sram_rdata  <= sram_dq;
  sram_ben(0) <= sram_ben_i(0);
  sram_ben(1) <= sram_ben_i(1);
  sram_ben(2) <= sram_ben_i(0);
  sram_ben(3) <= sram_ben_i(1);
  
  -- video
  vga_vsync <= vga_vsync_i;
   
  -- 
  uart_tx <= uart_tx_i;
    
  -- ---------------------------------------------------------------------------
  -- reset cleaner
  -- ---------------------------------------------------------------------------
  p_clean_reset:process(clk50m,pbutton(3))
  begin  
    
    if pbutton(3)='1' then
    
      reset_1t <= '1';
      reset_2t <= '1';
    
    elsif clk50m'event and clk50m='1' then
  
      reset_1t <= not(soft_resetn);
      reset_2t <= reset_1t;
  
    end if;
  
  end process p_clean_reset;
 
  -- ---------------------------------------------------------------------------
  -- write enable : generated on falling edge to secure setup/hold
  -- ---------------------------------------------------------------------------
  p_wen_sync:process
  begin  
    wait until clk50m'event and clk50m='0';
  
    sram_wen <= sram_wen_i;
  
  end process p_wen_sync;
  
  -- ---------------------------------------------------------------------------
  -- clock enables generation
  --
  -- o clken_uart : 2.18 us 
  -- o clken_20ms : 20.0 ms 
  -- o clken_s7   : 1.11 ms 
  --
  -- ---------------------------------------------------------------------------
  p_clock_enable_generation:process(resetn,clk50m)
  begin
  
    if resetn='0' then
    
      clken_uart      <= '0';
      clken_s7        <= '0';
      state_s7        <= '0';
      clken_20ms      <= '0';
      
      divider_20ms    <= "00000000000000";
      divider_uart    <= "0000000";
    
    elsif clk50m'event and clk50m='1' then
    
      -- -----------------------------------------------------------------------
      -- uart divider : 460800 Hz <=> 4 x 115200 bit/s
      -- -----------------------------------------------------------------------
      if divider_uart="1101100" then -- 108
      
        clken_uart   <= '1';
        divider_uart <= "0000000" ;
        
      else
      
        clken_uart   <= '0';
        divider_uart <= divider_uart + "0000001";
      
      end if;
      
      -- -----------------------------------------------------------------------
      -- 20 ms divider
      -- -----------------------------------------------------------------------
      
      if clken_uart='1' then
        
        
        if divider_20ms="10001111010101" then -- 9173
       
          clken_20ms   <= '1';
          divider_20ms <= "00000000000000";
        
        else
      
          clken_20ms   <= '0';
          divider_20ms <= divider_20ms + "00000000000001";
      
        end if;
      
      end if;
      
      -- -----------------------------------------------------------------------
      -- 1.11 ms clken
      -- -----------------------------------------------------------------------
      state_s7 <= divider_20ms(8);
      
      if divider_20ms(8)='1' and state_s7='0' then
        
        clken_s7 <= '1';
        
      else
          
        clken_s7 <= '0';
        
      end if;
    
    end if;
  
  end process p_clock_enable_generation;
   
  p_7seg:process(resetn,clk50m)                                                                                       
                                                                                                                      
    variable tmp_segment : std_logic_vector(4 downto 0);                                                              
    variable tmp_dot     : std_logic;                                                                                 
                                                                                                                      
  begin
                                                                                                                      
    if resetn='0' then                                                                                                
                                                                                                                      
      anode           <= "1110";
      s7              <= (others=>'0');
      disp7s_toggle   <= '0';
      disp7s_data     <= (others=>'0');
      disp7s_data_1t  <= (others=>'0');
      disp7s_data_2t  <= (others=>'0');
      tmp_segment     := "00000";
      tmp_dot         := '0';
                                                                                                                      
    elsif clk50m'event and clk50m='1' then                                                                            
                                                                                                                      
      if switch(1)='0' then
      
        disp7s_data_1t <= keyboard_data;                                                                              
                                                                                                                      
        if keyboard_update='1' then                                                                                     
                                                                                                                      
          disp7s_data_2t <= disp7s_data_1t;                                                                         
          disp7s_toggle  <= not disp7s_toggle;                                                                      
                                                                                                                      
        end if; 
        
      else
      
        disp7s_data_1t <= uart_rdata;                                                                              
     
        if uart_rvalid='1' then                                                                                     
                                                                                                                      
          disp7s_data_2t <= disp7s_data_1t;                                                                         
          disp7s_toggle  <= not disp7s_toggle;                                                                      
                                                                                                                      
        end if;   
      
      end if;  

      tmp_segment := "10000";                                                                                         
      tmp_dot     := '0';                                                                                             
                                                                                                                      
      if clken_s7='1' then                                                                                            
                                                                                                                      
        case anode is                                                                                                 
                                                                                                                      
          when "1101"=> anode <= "1110" ; tmp_segment:= '0'&disp7s_data_1t(3 downto 0); tmp_dot := disp7s_toggle; 
          when "1011"=> anode <= "1101" ; tmp_segment:= '0'&disp7s_data_1t(7 downto 4); tmp_dot := '1';             
          when "0111"=> anode <= "1011" ; tmp_segment:= '0'&disp7s_data_2t(3 downto 0); tmp_dot := '1';             
          when others=> anode <= "0111" ; tmp_segment:= '0'&disp7s_data_2t(7 downto 4); tmp_dot := '1';             
                                                                                                                      
        end case;                                                                                                     
                                                                                                                      
        case tmp_segment is                                                                                           
                                                                                                                      
          when "00000"=> s7 <= tmp_dot&"1000000"; -- 0                                                                
          when "00001"=> s7 <= tmp_dot&"1111001"; -- 1                                                                
          when "00010"=> s7 <= tmp_dot&"0100100"; -- 2                                                                
          when "00011"=> s7 <= tmp_dot&"0110000"; -- 3                                                                
          when "00100"=> s7 <= tmp_dot&"0011001"; -- 4                                                                
          when "00101"=> s7 <= tmp_dot&"0010010"; -- 5                                                                
          when "00110"=> s7 <= tmp_dot&"0000010"; -- 6                                                                
          when "00111"=> s7 <= tmp_dot&"1111000"; -- 7                                                                
          when "01000"=> s7 <= tmp_dot&"0000000"; -- 8                                                                
          when "01001"=> s7 <= tmp_dot&"0010000"; -- 9                                                                
          when "01010"=> s7 <= tmp_dot&"0001000"; -- a                                                                
          when "01011"=> s7 <= tmp_dot&"0000011"; -- b                                                                
          when "01100"=> s7 <= tmp_dot&"1000110"; -- c                                                                
          when "01101"=> s7 <= tmp_dot&"0100001"; -- d                                                                
          when "01110"=> s7 <= tmp_dot&"0000110"; -- e                                                                
          when "01111"=> s7 <= tmp_dot&"0001110"; -- f                                                                
          when others => s7 <= tmp_dot&"1111111"; -- off                                                              
                                                                                                                      
        end case;                                                                                                     
                                                                                                                      
      end if;                                                                                                         
                                                                                                                      
    end if;                                                                                                           
  
  end process p_7seg;
 
  -- ---------------------------------------------------------------------------
  -- CPU IRQ source selection : VGA VSYNC (13.33 ms) or DIVIDER (20 ms)
  -- ---------------------------------------------------------------------------
  
  source_irq <= vga_vsync_i when source_irq_sel='1' else
                clken_20ms;

  -- bounce filter
  p_anti_bounce:process(resetn,clk50m)
  begin
  
    if resetn='0' then
    
      source_irq_sel <= '0'; 
      cpu_turbo_1t   <= '1';
      cpu_turbo      <= '1';
    
    elsif clk50m'event and clk50m='1' then
    
      if clken_20ms='1' then
      
        source_irq_sel <= switch(7); 
        cpu_turbo_1t   <= switch(0);
        cpu_turbo      <= cpu_turbo_1t;
      
      end if;
    
    end if;
  
  end process p_anti_bounce;


  -- ---------------------------------------------------------------------------
  -- CPU 6809
  -- ---------------------------------------------------------------------------
  cpu_0:cpu6809
  port map
  (
    -- system                                       
    resetn   => resetn,
    clk      => clk50m,
    clken    => clken_cpu,
    -- interruptions                                
    nnmi     => cpu_nnmi,
    nirq     => cpu_nirq,        
    nfiq     => cpu_nfiq, 
    -- memory                                       
    busreq   => cpu_busreq,
    write    => cpu_write,
    addr     => cpu_addr,
    rdata    => cpu_rdata,
    wdata    => cpu_wdata
  );
 
  -- ---------------------------------------------------------------------------
  -- memory controller
  -- ---------------------------------------------------------------------------
  memcntl_0:memcntl
  port map
  (                                                       
    -- system                                             
    resetn       => resetn,              
    clk50m       => clk50m,
    source_irq   => source_irq,              
    soft_resetn  => soft_resetn, 
    cpu_turbo    => cpu_turbo,         
    -- processor                                          
    cpu_clken    => clken_cpu,
    cpu_nnmi     => cpu_nnmi,          
    cpu_nfiq     => cpu_nfiq,          
    cpu_nirq     => cpu_nirq,          
    cpu_busreq   => cpu_busreq,          
    cpu_write    => cpu_write,           
    cpu_addr     => cpu_addr,            
    cpu_wdata    => cpu_wdata,           
    cpu_rdata    => cpu_rdata,           
    -- external sram                                      
    sram_wen     => sram_wen_i,            
    sram_oen     => sram_oen,            
    sram_a       => sram_a,              
    sram_csn     => sram_csn,           
    sram_ben     => sram_ben_i,           
    sram_dataen  => sram_dataen,         
    sram_rdata   => sram_rdata,          
    sram_wdata   => sram_wdata,          
    -- vga controller                                     
    vga_vsync    => vga_vsync_i,           
    vga_data     => vga_data,            
    vga_update   => vga_update,          
    vga_border   => vga_border,        
    -- jtag rom                                           
    flash_clk    => flash_clk,                      
    flash_q      => flash_q,                        
    --
    uart_wen     => uart_wen,
    uart_wdata   => uart_wdata,
    uart_wbusy   => uart_wbusy,
    uart_rdata   => uart_rdata,
    uart_rvalid  => uart_rvalid,
    -- keyboard
    keyboard_col => keyboard_col,              
    keyboard_row => keyboard_row,              
    keyboard_hit => keyboard_hit,      
    keyboard_esc => keyboard_esc,
    -- sound
    sound        => sound               
  );                                                      

  -- ---------------------------------------------------------------------------
  -- SVGA controller
  -- ---------------------------------------------------------------------------
  video_0:videocntl
  port map
  (
    resetn       => resetn,        
    clk          => clk50m,  
    time_average => switch(2),      
    --
    data_req     => vga_update,    
    data         => vga_data,      
    border       => vga_border,    
    --
    hsync        => vga_hsync,     
    vsync        => vga_vsync_i,   
    r            => vga_r,         
    g            => vga_g,         
    b            => vga_b          
  );

  -- ---------------------------------------------------------------------------
  -- UART
  -- ---------------------------------------------------------------------------
  uart_0:uart
  port map
  (                                               
    -- system                                     
    resetn   => resetn,           
    clk      => clk50m,           
    clken    => clken_uart,       
                                                  
    -- tx                                         
    wen      => uart_wen,         
    data_in  => uart_wdata,       
    busy     => uart_wbusy,       
    tx       => uart_tx_i,        
                                                  
    -- rx                                         
    rx       => uart_rx,          
    data_out => uart_rdata,       
    valid    => uart_rvalid       
  );                                              

  -- ---------------------------------------------------------------------------
  -- Keyboard
  -- ---------------------------------------------------------------------------
  keyboard_0:keyboard
  port map
  (                                      
    -- system                            
    resetn       => resetn,              
    clk          => clk50m, 
    clken_1ms    => clken_s7,             
    clken_20ms   => clken_20ms,             
    -- PS2                               
    ps2c         => ps2_c,                
    ps2d         => ps2_d,                
    --                                   
    data         => keyboard_data,       
    data_update  => keyboard_update,     
    key_row      => keyboard_row,               
    key_column   => keyboard_col,               
    key_hit      => keyboard_hit,
    key_esc      => keyboard_esc
  );                                     
    
end architecture rtl;
