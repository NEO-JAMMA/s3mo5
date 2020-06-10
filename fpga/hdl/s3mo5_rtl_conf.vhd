----------------------------------------------------------------------
--
-- S3MO5 - s3mo5 rtl configuration
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

configuration s3mo5_rtl_conf of testbench_s3mo5 is
  for testbench
    for all:s3mo5
      use entity s3mo5_lib.s3mo5(rtl);
      for rtl
        for all:cpu6809
          use entity s3mo5_lib.cpu6809(rtl);
          for rtl
            for all:datapath
              use entity s3mo5_lib.datapath(rtl);
              for rtl
                for all:alu
                  use entity s3mo5_lib.alu(rtl);
                end for;
                for all:mult18x18
                  use entity unisim.mult18x18(mult18x18_v);
                end for;
              end for;
            end for;
            for all:sequencer
              use entity s3mo5_lib.sequencer(rtl);
            end for;
          end for;
        end for;
        for all:videocntl
          use entity s3mo5_lib.videocntl(rtl);
        end for;
        for all:memcntl
          use entity s3mo5_lib.memcntl(rtl);
        end for;
         for all:keyboard
          use entity s3mo5_lib.keyboard(rtl);
        end for;
        for all:uart
          use entity s3mo5_lib.uart(rtl);
        end for;
      end for;
    end for;
    for all:ram256kx16                               
      use entity s3mo5_lib.ram256kx16(behaviour);    
    end for;                                         
    for all:uart                                
      use entity s3mo5_lib.uart(rtl);           
    end for;                                    
  end for;
end configuration s3mo5_rtl_conf;

