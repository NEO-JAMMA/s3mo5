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
#include <stdlib.h>
#include "s19.h"

unsigned int s19_get_bytes(FILE*file,unsigned size)
{
  unsigned char b;
  unsigned int  r,i,j;

  r=0;

  if((size<1) || (size>3))
  {
    printf("error:s19_get_bytes: illegal size value (%d) !\n",size);
    exit(-1);
  } 

  for(i=0;i<size;i++)
  {
    for(j=0;j<2;j++)
    {
      r=r<<4;
      if(feof(file))
      {
        printf("error:s19_get_bytes: unexpected end of file !\n");
        exit(-1);
      }
      b=fgetc(file);
      
      if((b>='0') && (b<='9'))
        b=b-'0';
      else if((b>='A') && (b<='F'))
        b=b-'A'+10;
      else
      {
        printf("error:s19_get_bytes: unexpected charcter found instead hex (0x%-.2x) !\n",b&0xff);
        exit(-1);
      }
      r|=b&0x0f;
    }
  } 
  return r;
}

void s19_read(FILE*file,unsigned char*buffer,unsigned int buffer_size)
{
  unsigned int  s19_state,i,line_length,base,checksum,line_pos;
  unsigned char c;
  
  line_pos=1;
  s19_state=0;                     
  while(1)                         
  {                                
    if(feof(file)) return;
    switch(s19_state)              
    {                              
      case 0:                      
                                   
        do
        {
          c=fgetc(file); 
        }
        while(c=='\n');
        line_pos++;         
        
        if(c!='S')
        {
          printf("error:s19_read:line=%d: leading 'S' character missing !\n",line_pos);
          exit(-1);
        }
        s19_state=1;                 
        break;                     
                                   
      case 1: 
      
        c=fgetc(file); 
        switch(c)
        {
          case '1':
          
            checksum    = s19_get_bytes(file,1);
            line_length = checksum-3;
            base        = s19_get_bytes(file,2);
            s19_state   = 2;
            break;
          
          case '2':
          
            checksum    = s19_get_bytes(file,1);
            line_length = checksum-4;
            base        = s19_get_bytes(file,3);
            s19_state   = 2;
            break;
          
          case '3':
            
            checksum    = s19_get_bytes(file,1);
            line_length = checksum-5;
            base        = s19_get_bytes(file,4);
            s19_state   = 2;
            break;
          
          case '7':
          case '8':
          case '9':
            
            return;
            
          default:
          
            printf("error:s19_read:line=%d: unsupported S%d command !\n",line_pos,c);
            exit(-1);
        }
                           
      case 2:
      
        for(i=0;i<4;i++)
        {
          checksum+=(base>>(i*8))&0xff;
        }
        
        for(i=0;i<line_length;i++)
        {
          c=s19_get_bytes(file,1);
          checksum+=c;
          
          if((base+i)>=buffer_size)
          {
            printf("error:s19_read:line=%d: buffer overflow (%x > %x)!\n",line_pos,base+i,buffer_size);
            exit(-1);
          }
          
          buffer[base+i]=c;
        }
        
        i=s19_get_bytes(file,1)&0xff;
        checksum=(checksum^0xff)&0xff;
        if(i!=checksum)
        {
          printf("error:s19_read:line=%d: checksum error (expected=%-.2x;found=%-.2x) !\n",line_pos,i,checksum);
          exit(-1);
        }
        s19_state=0;
        break;
      
      default:  
      
        printf("error:s19_read:line=%d:internal error, unexpected state %d\n",line_pos,s19_state);
        exit(-1);                  
    }                              
  }                                
}

void s19_write(unsigned int base,unsigned int size,FILE*file_in,FILE*file_out)
{
  char          *s;
  unsigned char *memory;
  unsigned int current_pos,all_bytes_null,line_size;
  unsigned int checksum,remaining_bytes,i,count;

  memory=(unsigned char*)malloc(size);                                      
  if(!memory)                                                                           
  {                                                                                     
    printf("error: unable to allocate %d bytes for '%s' file !\n",size,s);  
    exit(-1);                                                                           
  }                                                                                     
                                                                                        
  count=fread(memory,1,size,file_in);                                       
  if(count!=size)                                                           
  {                                                                                     
    printf("error: bad read bytes number (%d)!\n",count);                               
    exit(-1);                                                                           
  }                                                                                     
                                                                                        
  remaining_bytes = size;                                                   
  current_pos     = 0;                                                                  
                                                                                        
  /* extraction loop */                                                                 
                                                                                        
                                                                                        
  while(remaining_bytes)                                                                
  {                                                                                     
    /* line size in bytes */                                                            
    if(remaining_bytes>16)                                                              
    {                                                                                   
      line_size=16;                                                                     
    }                                                                                   
    else                                                                                
    {                                                                                   
      line_size=remaining_bytes;                                                        
    }                                                                                   
                                                                                        
    /* count the number of non-null bytes within the line */                            
    all_bytes_null=1;                                                                   
    for(i=0;i<line_size;i++)                                                            
    {                                                                                   
      if(memory[current_pos+i])                                                         
      {                                                                                 
        all_bytes_null=0;                                                               
        break;                                                                          
      }                                                                                 
    }                                                                                   
                                                                                        
    if(!all_bytes_null)                                                                 
    {                                                                                   
      fprintf(file_out,"S2%-.2X%-.6X",line_size+4,base&0xffffff);                       
      checksum=(line_size&0xff)+((base>>16)&0xff)+((base>>8)&0xff)+(base&0xff)+4;       
      for(i=0;i<line_size;i++)                                                          
      {                                                                                 
        checksum+=memory[current_pos+i]&0xff;                                           
        fprintf(file_out,"%-.2X",memory[current_pos+i]&0xff);
      }                                                                                 
      fprintf(file_out,"%-.2X\n",(checksum^0xff)&0xff);
                                                                                        
    }
    current_pos     += line_size;
    base            += line_size;
    remaining_bytes -= line_size;
                                                                                        
  }
                                                                                        
  free(memory);
}
