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
* upload MO5 rom, S3 bios and file system content
*
* usage: s3_init rom.bin bios.bin fs.bin
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
  int ttyS0,i,count,address,slide_h,slide_l;
  char c;
  char buffer[128];
  unsigned int base,j,qty;
  
  if(argc!=4)
  {
    printf("error: bad argument number !\n");
    printf("usage: %s <rom.bin> <bios.bin> <fs.bin>\n",argv[0]);
    exit(-1);
  }
  
  ttyS0=open("/dev/ttyS0",O_WRONLY);
  if(ttyS0==-1)
  {
    printf("error: unable to open /dev/ttyS0\n");
    exit(-1);
  }
  
  /*******************************************************************
  /* unprotect rom
  *******************************************************************/
  printf("unlocking rom\n");

  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xff);
  send_char(ttyS0,0x01);
  send_char(ttyS0,0x01);
  
  /*******************************************************************
  /* stop processor 
  *******************************************************************/
  printf("stopping processor\n");

  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xfe);
  send_char(ttyS0,0x01);
  send_char(ttyS0,0x08);

  /*******************************************************************
  /* upload rom
  *******************************************************************/
  
  file_in = fopen(argv[1],"rb");
  if(!file_in)
  {
    printf("error: unable to open %s file !\n",argv[1]);
    exit(-1);
  }
  
  address=0xc000;
  qty=0;
  while(1)
  {
    printf("uploading MO5 rom     : %8d bytes\r",qty);fflush(stdout);
    if(feof(file_in)) break;
    
    count=fread(buffer,1,128,file_in);
    if(count<0)
    {
      printf("error: failure during write to ttyS0\n");
      exit(-1);
    }
    send_char(ttyS0,0x01);
    send_char(ttyS0,(address>>8)&0xff);
    send_char(ttyS0,(address)&0xff);
    address = address + count;
    
    if(count>=128)
      send_char(ttyS0,0x80);
    else
      send_char(ttyS0,count);
      
    for(i=0;i<count;i++)
    {
      send_char(ttyS0,buffer[i]);
    }
    qty+=count;
  }
  printf("\n");
  fclose(file_in);
  
  /*******************************************************************
  /* upload bios 
  *******************************************************************/
  
  file_in = fopen(argv[2],"rb");
  if(!file_in)
  {
    printf("error: unable to open %s file !\n",argv[2]);
    exit(-1);
  }
  
  address=0xa900;
  qty=0;
  while(1)
  {
    printf("uploading bios        : %8d bytes\r",qty);fflush(stdout);
    if(feof(file_in)) break;
    
    count=fread(buffer,1,128,file_in);
    if(count<0)
    {
      printf("error: failure during write to ttyS0\n");
      exit(-1);
    }
    send_char(ttyS0,0x01);
    send_char(ttyS0,(address>>8)&0xff);
    send_char(ttyS0,(address)&0xff);
    address = address + count;
    
    if(count>=128)
      send_char(ttyS0,0x80);
    else
      send_char(ttyS0,count);
      
    for(i=0;i<count;i++)
    {
      send_char(ttyS0,buffer[i]);
    }
    qty+=count;
  }
  printf("\n");
  fclose(file_in);
  
  /*******************************************************************
  /* upload fs
  *******************************************************************/
  
  file_in = fopen(argv[3],"rb");
  if(!file_in)
  {
    printf("error: unable to open %s file !\n",argv[3]);
    exit(-1);
  }
  
  address=0xa800;
  slide_h=0x01;
  slide_l=0xe0;
  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xfc);
  send_char(ttyS0,0x01);
  send_char(ttyS0,slide_h&0xff);
  
  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xfd);
  send_char(ttyS0,0x01);
  send_char(ttyS0,slide_l&0xff);
  
  qty=0;
  while(1)
  {
    printf("uploading file system : %8d bytes\r",qty);fflush(stdout);
    if(feof(file_in)) break;
    count=fread(buffer,1,128,file_in);
    if(count<0)
    {
      printf("error: failure during write to ttyS0\n");
      exit(-1);
    }
    send_char(ttyS0,0x01);
    send_char(ttyS0,(address>>8)&0xff);
    send_char(ttyS0,(address)&0xff);
    address = address + count;
    
    if(count>=128)
      send_char(ttyS0,0x80);
    else
      send_char(ttyS0,count);
      
    for(i=0;i<count;i++)
    {
      send_char(ttyS0,buffer[i]);
    }
    qty+=count;
  
    if(address==0xa900)
    {
      address=0xa800;
      slide_l++;
      
      if(slide_l==0x100)
      {
        slide_h++;
        slide_l=0;
      }
      send_char(ttyS0,0x01);
      send_char(ttyS0,0xa7);
      send_char(ttyS0,0xfc);
      send_char(ttyS0,0x01);
      send_char(ttyS0,slide_h&0xff);
   
      send_char(ttyS0,0x01);
      send_char(ttyS0,0xa7);
      send_char(ttyS0,0xfd);
      send_char(ttyS0,0x01);
      send_char(ttyS0,slide_l&0xff);
    }
  }
  printf("\n");
  fclose(file_in);

  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xfc);
  send_char(ttyS0,0x01);
  send_char(ttyS0,0);
 
  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xfd);
  send_char(ttyS0,0x01);
  send_char(ttyS0,0);
 
  /*******************************************************************
  * launch processor 
  *******************************************************************/
  printf("reseting board\n");

  send_char(ttyS0,0x01);
  send_char(ttyS0,0xa7);
  send_char(ttyS0,0xfe);
  send_char(ttyS0,0x01);
  send_char(ttyS0,0x80);

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
