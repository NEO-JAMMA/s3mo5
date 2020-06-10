----------------------------------------------------------------------
--
-- S3MO5 - s3mo5_gate_conf
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

----------------------------------------------------------------------
-- configuration
----------------------------------------------------------------------
library s3mo5_lib;
library unisim;
library simprim;

configuration s3mo5_gate_conf of testbench_s3mo5 is
  for testbench
    for all:s3mo5
      use entity s3mo5_lib.s3mo5;
    end for;
    for all:ram256kx16                               
      use entity s3mo5_lib.ram256kx16(behaviour);    
    end for;                                         
    for all:uart                                
      use entity s3mo5_lib.uart(rtl);           
      for rtl                                   
        for all:uart_rx                         
          use entity s3mo5_lib.uart_rx(rtl);    
        end for;                                
        for all:uart_tx                         
          use entity s3mo5_lib.uart_tx(rtl);    
        end for;                                
      end for;                                  
    end for;                                    
  end for;
end configuration s3mo5_gate_conf;

