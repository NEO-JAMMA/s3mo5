/*********************************************************************
* 
* S3MO5 model -  Disassembler
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

unsigned int get_mem8(unsigned int);

unsigned char memory[64*1024];
unsigned int verbose,nocolor,display_memtraffic;

unsigned int a,b,x,y,u,s,pc,dp,cc;
unsigned int pa,pb,px,py,pu,ps,ppc,pdp,pcc;

int main(int argc,char**argv)
{
  FILE *file_in;
  unsigned int tmp,count,pos,start,stop;
  char buffer[256],command;
  
  if(argc!=4)
  {
    printf("error: bad argument number !\n");
    printf("syntax: %s <file.bin> <base> <command.txt>\n",argv[0]);
    exit(-1);
  }
  
  file_in=fopen(argv[1],"rb");
  if(!file_in)
  {
    printf("error: unable to open binary file !\n");
    exit(-1);
  }
  
  count=fread(memory+strtoul(argv[2],(char**)NULL,16),1,64*10524,file_in);
  
  printf("%d bytes read.\n",count);
  fclose(file_in);
  
  
  file_in=fopen(argv[3],"rb");
  if(!file_in)
  {
    printf("error: unable to open command file !\n");
    exit(-1);
  }
  
  /*
   *
   *
   *
   */
  
  while(1)
  {
    fgets(buffer,256,file_in);
    if(feof(file_in)) break;
    
    sscanf(buffer,"%c %x %x",&command,&start,&stop);
    
    switch(command)
    {
      case 'D':
      
        pos = start;
        do
        {
          tmp=get_mem8(pos);
          if(tmp==0x39 ||
             tmp==0x3b ||
             tmp==0x6e ||
             ((tmp&0xf0)==0x20)
            )
          {
            pos=disassemble(pos);
            printf("--------------------------------------------------------------------------------\n");
          }
          else
          {
            pos=disassemble(pos);
          }
        }
        while(pos<=stop);
      
        break;
      
      case 'B':
      
        pos=start;
        do
        {
          printf("%-.4x: %-.2x                 db  %-.2x\n",
                 pos,get_mem8(pos),get_mem8(pos));
          pos=pos+1;
        }
        while(pos<=stop);
        printf("--------------------------------------------------------------------------------\n");
        
        break;
      
      case 'W':
 
        pos=start;
        do
        {
          printf("%-.4x: %-.2x %-.2x              dw  %-.2x%-.2x\n",
                 pos,get_mem8(pos),get_mem8(pos+1),get_mem8(pos),get_mem8(pos+1));
          pos=pos+2;
        }
        while(pos<=stop);
        printf("--------------------------------------------------------------------------------\n");

        break;
      
      case '\n':
      
        break;

      case 'L':
        printf("--------------------------------------------------------------------------------\n");
      
        break;
        
      default:
        printf("error: unknown command %c\n",command);
        exit(-1);
     }
    /*pos=disassemble(pos);
    if(pos>=stop) break;
    */
  }
  
  fclose(file_in);
}

unsigned int get_mem8(unsigned int addr)
{
  //printf("%-.4x\n",addr);
  return (memory[addr])&0xff;
}

unsigned int get_mem16(unsigned int addr)
{
  unsigned int tmp;
  tmp = get_mem8(addr)<<8;
  tmp |= get_mem8(addr+1);
  return tmp&0xffff;
}

unsigned int put_mem8(unsigned int addr)
{
  return -1;
}

unsigned int put_mem16(unsigned int addr)
{
  return -1;
}


