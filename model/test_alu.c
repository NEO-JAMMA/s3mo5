/*********************************************************************
* 
* S3MO5 model -  emulateur MO5
* Copyright (C) 2005 Olivier Ringot <oringot@gmail.com>
* 
* This file is part of the S3MO5 project
*
* The S3MO5 project is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
* 
* The S3MO5 project is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this S3MO5 project; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, 
* Boston, MA  02110-1301, USA.
* 
**********************************************************************
* 
* $Revision: $
* $Date: $
* $Source: $
* $Log: $
*
*********************************************************************/
#include <stdio.h>

unsigned int cc;

int main(int argc,char**argv)
{
  
  unsigned int vec,result,pcc;
  
  unsigned int mode;
  unsigned int op1;
  unsigned int op2;
  unsigned int h_in;
  unsigned int n_in;
  unsigned int z_in;
  unsigned int v_in;
  unsigned int c_in;
  
  vec=0;
  
  while(1)
  {
    
    h_in = (vec&(1<<18))?1:0;
    n_in = (vec&(1<<17))?1:0;
    z_in = (vec&(1<<16))?1:0;
    v_in = (vec&(1<<15))?1:0;
    c_in = (vec&(1<<14))?1:0;
    
    mode = (vec>>19)&0x1f;
    
    if(mode==25) break;
    
    op1  = (((vec>>11)&0x07)<<13)|((vec>>7)&0x03)|(((vec>>9)&0x1)<<3)|(vec&(1<<10)?0x1ff4:0);
    op2  =(((vec>>4)&0x07)<<13)|(vec&0x07)|(vec&(1<<3)?0x1ff8:0);
    
    cc = (h_in<<5) | (n_in<<3) | (z_in<<2) |
         (v_in<<1) | c_in;  
    pcc = cc;
    
    result=alu(op1,op2,mode);
    
    printf("%-.2X %-.4X %-.4X %d%d%d%d%d %d%d%d%d%d %-.4X\n",
           mode,
           op1,
           op2,
           (pcc>>5)&1,
           (pcc>>3)&1,
           (pcc>>2)&1,
           (pcc>>1)&1,
           (pcc)&1,
           (cc>>5)&1,
           (cc>>3)&1,
           (cc>>2)&1,
           (cc>>1)&1,
           (cc)&1,
           result);
    
  
    vec++;
  }
}
