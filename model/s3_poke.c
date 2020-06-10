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
**********************************************************************
*
* poke a byte
*
* usage: s3_poke 0xaddress 0xvalue
*
*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

char get_char(int ttys);
void send_char(int ttys,unsigned char c);


int main(int argc,char **argv)
{
  FILE *file_in;
  int ttyS0,i,count,base,value;
  char c;
  char buffer[128];
  
  if(argc!=3)
  {
    printf("error: bad argument number !\n");
    printf("usage: %s <0xaddress> <0xvalue>\n",argv[0]);
    exit(-1);
  }
  
  ttyS0=open("/dev/ttyS0",O_WRONLY);
  if(ttyS0==-1)
  {
    printf("error: unable to open /dev/ttyS0\n");
    exit(-1);
  }

  base=strtoul(argv[1],(char**)NULL,16);
  value=strtoul(argv[2],(char**)NULL,16);
  
  send_char(ttyS0,0x01);
  send_char(ttyS0,(base>>8)&0xff);
  send_char(ttyS0,base&0xff);
  send_char(ttyS0,0x01);
  send_char(ttyS0,value&0xff);
  
  close(ttyS0);
}

void send_char(int ttys,unsigned char c)
{
  int count;
  do
  {
    count=write(ttys,&c,1);
    if(count==-1)
    {
      printf("error during send_char\n");
      exit(-1);
    }
  }
  while(count==0);
}

char get_char(int ttys)
{
  int count;
  unsigned char r;
  do                                        
  {                                         
    count=read(ttys,&r,1);                
  }
  while(count==0);
  if(count!=1)
  {
    printf("error during get_char (%d,%d)\n",count,errno);
    perror(NULL);
    exit(-1);
  }
  return r;
}
