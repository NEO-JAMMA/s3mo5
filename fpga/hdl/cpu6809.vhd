----------------------------------------------------------------------
--
-- S3MO5 - cpu6809
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

-- -------------------------------------------------------------------
--      
-- -------------------------------------------------------------------

entity cpu6809 is
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
end entity cpu6809;

-- -------------------------------------------------------------------
--      
-- -------------------------------------------------------------------

architecture rtl of cpu6809 is

  component datapath
    port
    (
      --
      resetn            :  in std_logic;
      clk               :  in std_logic;
      clken             :  in std_logic;
      --
      vector            :  in std_logic_vector( 2 downto 0);
      set_e             :  in std_logic;
      set_f             :  in std_logic;
      set_i             :  in std_logic;
      clear_e           :  in std_logic;
      ccr               : out std_logic_vector( 7 downto 0);
      --
      alu_mode          :  in t_alu;
      alu_mux_sel       :  in std_logic_vector( 3 downto 0);
      index_mux_sel     :  in std_logic_vector( 3 downto 0);
      index_add_sel     :  in std_logic;
      addr_mux_sel      :  in std_logic_vector( 2 downto 0);
      bytelane_mux_sel  :  in std_logic;
      allreg_mux_sel    :  in std_logic_vector( 1 downto 0); 
      mr_mux_sel        :  in std_logic_vector( 1 downto 0); 
      pc_mux_sel        :  in std_logic_vector( 1 downto 0);
      x_mux_sel         :  in std_logic;
      y_mux_sel         :  in std_logic;
      u_mux_sel         :  in std_logic;
      s_mux_sel         :  in std_logic;
      ea_mux_sel        :  in std_logic_vector( 3 downto 0);
      dp_mux_sel        :  in std_logic;
      mult_mux_sel      :  in std_logic;
      --
      ab_en             :  in std_logic_vector( 1 downto 0);
      x_en              :  in std_logic;
      y_en              :  in std_logic;
      u_en              :  in std_logic;
      s_en              :  in std_logic;
      mr_en             :  in std_logic;
      mw_en             :  in std_logic;
      pc_en             :  in std_logic;
      dp_en             :  in std_logic;
      cc_en             :  in std_logic;
      ea_en             :  in std_logic;
      op_en             :  in std_logic;
      --
      addr              : out std_logic_vector(15 downto 0);
      rdata             :  in std_logic_vector( 7 downto 0);
      wdata             : out std_logic_vector( 7 downto 0);
      --
      opcode            : out std_logic_vector( 9 downto 0);
      refetch           : out std_logic
    );
  end component;

  component sequencer
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
      mw_en             : out std_logic;
      pc_en             : out std_logic;
      dp_en             : out std_logic;
      cc_en             : out std_logic;
      ea_en             : out std_logic;
      op_en             : out std_logic
   );
  end component;

  signal refetch           : std_logic; 
  signal opcode            : std_logic_vector( 9 downto 0); 
  signal ccr               : std_logic_vector( 7 downto 0);
  signal vector            : std_logic_vector( 2 downto 0);
  signal set_e             : std_logic;                    
  signal set_f             : std_logic;                    
  signal set_i             : std_logic;                    
  signal clear_e           : std_logic;                    
  signal alu_mode          : t_alu;
  signal alu_mux_sel       : std_logic_vector( 3 downto 0);
  signal index_mux_sel     : std_logic_vector( 3 downto 0);
  signal index_add_sel     : std_logic;
  signal addr_mux_sel      : std_logic_vector( 2 downto 0);
  signal bytelane_mux_sel  : std_logic;
  signal allreg_mux_sel    : std_logic_vector( 1 downto 0); 
  signal mr_mux_sel        : std_logic_vector( 1 downto 0); 
  signal pc_mux_sel        : std_logic_vector( 1 downto 0);
  signal x_mux_sel         : std_logic;
  signal y_mux_sel         : std_logic;
  signal u_mux_sel         : std_logic;
  signal s_mux_sel         : std_logic;
  signal ea_mux_sel        : std_logic_vector( 3 downto 0);
  signal dp_mux_sel        : std_logic;
  signal mult_mux_sel      : std_logic;
  signal ab_en             : std_logic_vector( 1 downto 0);
  signal x_en              : std_logic;
  signal y_en              : std_logic;
  signal u_en              : std_logic;
  signal s_en              : std_logic;
  signal mr_en             : std_logic;
  signal mw_en             : std_logic;
  signal pc_en             : std_logic;
  signal dp_en             : std_logic;
  signal cc_en             : std_logic;
  signal ea_en             : std_logic;
  signal op_en             : std_logic;
  
begin

  -- ---------------------------------------------------------------------------
  -- Probes
  -- ---------------------------------------------------------------------------
  probe_refetch <= refetch;

  -- ---------------------------------------------------------------------------
  -- Sequencer
  -- ---------------------------------------------------------------------------
  sequencer_1:sequencer
  port map
  (                                                         
      resetn            => resetn,          
      clk               => clk,             
      clken             => clken,           
      nirq              => nirq,
      nnmi              => nnmi,
      busreq            => busreq,          
      write             => write,           
      rdata             => rdata,
      refetch           => refetch,         
      opcode            => opcode,          
      ccr               => ccr,             
      vector            => vector,          
      set_e             => set_e,           
      set_f             => set_f,           
      set_i             => set_i,           
      clear_e           => clear_e,         
      alu_mode          => alu_mode,        
      alu_mux_sel       => alu_mux_sel,     
      index_mux_sel     => index_mux_sel,   
      index_add_sel     => index_add_sel,   
      addr_mux_sel      => addr_mux_sel,    
      bytelane_mux_sel  => bytelane_mux_sel,
      allreg_mux_sel    => allreg_mux_sel,  
      mr_mux_sel        => mr_mux_sel,      
      pc_mux_sel        => pc_mux_sel,      
      x_mux_sel         => x_mux_sel,       
      y_mux_sel         => y_mux_sel,       
      u_mux_sel         => u_mux_sel,       
      s_mux_sel         => s_mux_sel,       
      ea_mux_sel        => ea_mux_sel,      
      dp_mux_sel        => dp_mux_sel,      
      mult_mux_sel      => mult_mux_sel,      
      ab_en             => ab_en,           
      x_en              => x_en,            
      y_en              => y_en,            
      u_en              => u_en,            
      s_en              => s_en,            
      mr_en             => mr_en,           
      mw_en             => mw_en,           
      pc_en             => pc_en,           
      dp_en             => dp_en,           
      cc_en             => cc_en,           
      ea_en             => ea_en,           
      op_en             => op_en           
  );                                                        

  -- ---------------------------------------------------------------------------
  -- Sequencer
  -- ---------------------------------------------------------------------------
  datapath_1:datapath
  port map                                                     
  (                                                         
      resetn            => resetn,          
      clk               => clk,             
      clken             => clken,           
      vector            => vector,          
      set_e             => set_e,           
      set_f             => set_f,           
      set_i             => set_i,           
      clear_e           => clear_e,         
      ccr               => ccr,             
      alu_mode          => alu_mode,        
      alu_mux_sel       => alu_mux_sel,     
      index_mux_sel     => index_mux_sel,   
      index_add_sel     => index_add_sel,   
      addr_mux_sel      => addr_mux_sel,    
      bytelane_mux_sel  => bytelane_mux_sel,
      allreg_mux_sel    => allreg_mux_sel,  
      mr_mux_sel        => mr_mux_sel,      
      pc_mux_sel        => pc_mux_sel,      
      x_mux_sel         => x_mux_sel,       
      y_mux_sel         => y_mux_sel,       
      u_mux_sel         => u_mux_sel,       
      s_mux_sel         => s_mux_sel,       
      ea_mux_sel        => ea_mux_sel,      
      dp_mux_sel        => dp_mux_sel,      
      mult_mux_sel      => mult_mux_sel,      
      ab_en             => ab_en,           
      x_en              => x_en,            
      y_en              => y_en,            
      u_en              => u_en,            
      s_en              => s_en,            
      mr_en             => mr_en,           
      mw_en             => mw_en,           
      pc_en             => pc_en,           
      dp_en             => dp_en,           
      cc_en             => cc_en,           
      ea_en             => ea_en,           
      op_en             => op_en,           
      addr              => addr,            
      rdata             => rdata,           
      wdata             => wdata,           
      opcode            => opcode,          
      refetch           => refetch         
  );                                                                        

end architecture rtl;
