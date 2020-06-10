/*********************************************************************
* 
* S3MO5 model -  bin2ram16
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
*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc,char**argv)
{
  FILE *file_in,*file_out;
  char *buffer_argv,*s;
  unsigned int base,remaining_bytes,i;
  unsigned char checksum,c;
  struct stat  filestat;
  
  if(argc!=3)
  {
    printf("error: bad argument number !\n");
    printf("usage: %s <0xbase:file.bin[,...]> <target.bin>\n",argv[0]);
    exit(-1);
  }
  
  file_out=fopen(argv[2],"wb");
  if(!file_out)
  {
    printf("error: unable to create %s file !\n",argv[2]);
    exit(-1);
  }
  
  
  buffer_argv=strdup(argv[1]);
  if(!buffer_argv)
  {
    printf("error:unable to allocate enough memory to duplicate arguments !\n");
    exit(-1);
  }
  
  s=strtok(buffer_argv,":");
  while(1)
  {
    base=strtoul(s,(char**)NULL,16);
    s=strtok(NULL,",");
    if(!s) break;
    
    if(stat(s,&filestat))
    {
      printf("error: unable to stat %s file !\n",s);
      exit(-1);
    }
    
    printf("processing %s at base 0x%-.4x with %d bytes\n",s,base,filestat.st_size);
    
    file_in=fopen(s,"rb");
    if(!file_in)
    {
      printf("error: unable to open %s file !\n",s);
      exit(-1);
    }
    
    
    remaining_bytes=filestat.st_size;
    
    /* extraction loop */
    
    while(remaining_bytes)
    {
      if(remaining_bytes>16)
      {
        fprintf(file_out,"%-.6X ",base);
        for(i=0;i<16;i++)
        {
          c=fgetc(file_in);
          fprintf(file_out,"%-.2X",c&0xff);
        }
        fprintf(file_out,"\n");
        base+=8;
        remaining_bytes-=16;
      }
      else
      {
        /* last line */
        fprintf(file_out,"%-.6X ",base);
        for(i=0;i<remaining_bytes;i++)
        {
          c=fgetc(file_in);
          fprintf(file_out,"%-.2X",c&0xff);
        }
        
        for(i=remaining_bytes;i<16;i++)
        {
          fprintf(file_out,"00");
        }
        fprintf(file_out,"\n");
        
        remaining_bytes=0;
      }
    }
    
    fclose(file_in);
    
    s=strtok(0,":");
    if(!s) break;
  }
  fclose(file_out);
  free(buffer_argv);
}
