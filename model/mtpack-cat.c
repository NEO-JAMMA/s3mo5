/*********************************************************************
* 
* s3mo5 model -  memory traffic compressed file format
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
#include <stdlib.h>
#include <zlib.h>

#include "mtpack.h" 

unsigned int  a,b,x,y,u,s,dp,cc,pc;
unsigned int  pa,pb,px,py,pu,ps,pdp,pcc,ppc;

int main(int argc,char**argv)
{
  mtpack_count=0;
  mtpack_buffer=0; 
  paddr=0;
  
  if(argc!=2)
  {
    printf("error: bad argument number !\n");
    printf("usage: %s <file>\n",argv[0]);
    exit(-1);
  }

  mtpack_file=gzopen(argv[1],"rb");
  
  if(!mtpack_file)
  {
    printf("error:unable to open file %s\n",argv[1]);
    exit(-1);
  }
  
  mtpack_cat();
  
  gzclose(mtpack_file);
}
