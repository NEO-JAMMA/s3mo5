/*********************************************************************
* 
* S3MO5 model -  genmire
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
* generation de la mire (8 vraies couleurs, 56 fausses couleurs)
**********************************************************************
* 
* $Revision: $
* $Date: $
* $Source: $
* $Log: $
*
*********************************************************************/
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char**argv)
{
  unsigned char mem[3*786432];
  unsigned int x,y,pos;
  
  FILE *file_out;
  
  for(y=0;y<768;y++)
  {
    for(x=0;x<1024;x++)
    {
      pos = x / 16;
      if(!y) printf("%-.8x\n",pos);
      if((x%2)==1)
      {
        if(!(y&1))
        {
          mem[3*(y*1024+x)]   = pos&0x04?255:0;
          mem[3*(y*1024+x)+1] = pos&0x02?255:0;
          mem[3*(y*1024+x)+2] = pos&0x01?255:0;
        }
        else
        {
          mem[3*(y*1024+x)]   = pos&0x20?255:0;
          mem[3*(y*1024+x)+1] = pos&0x10?255:0;
          mem[3*(y*1024+x)+2] = pos&0x08?255:0;
        }
      }
      else
      {
        if(!(y&1))
        {
          mem[3*(y*1024+x)]   = pos&0x20?255:0;
          mem[3*(y*1024+x)+1] = pos&0x10?255:0;
          mem[3*(y*1024+x)+2] = pos&0x08?255:0;
        }
        else
        {
          mem[3*(y*1024+x)]   = pos&0x04?255:0;
          mem[3*(y*1024+x)+1] = pos&0x02?255:0;
          mem[3*(y*1024+x)+2] = pos&0x01?255:0;
        }
      }
    }
  }
  
  file_out=fopen("mire.ppm","wb");
  fprintf(file_out,"P6\n1024 768\n255\n");
  fwrite(mem,1,3*1024*768,file_out);
  close(file_out);
  
}
