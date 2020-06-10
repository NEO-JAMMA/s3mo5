/*********************************************************************
* 
* S3MO5 - obj2bin
* Copyright (C) 2005 - Olivier Ringot <oringot@gmail.com>
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
*********************************************************************
* 
* $Revision:$
* $Date: $
* $Source: $
* $Log: $
* 
*********************************************************************/
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char**argv)
{
  FILE *file;   
  unsigned int i,state,addr,data,start,stop;                                       
  unsigned char buffer[65536],*token;
  char line[256];
                                                       
  if(argc!=5)                                          
  {                                                    
    printf("error: bad argument number !\n");          
    printf("usage: %s <file.o> <file.bin> <0xXXXX> <0xXXXX>\n",argv[0]); 
    exit(-1);                                          
  }                                                    

  file=fopen(argv[1],"rb");
  if(!file)
  {
    printf("error: unable to open file %s!\n",argv[1]);     
    exit(-1);     
  }
  
  for(i=0;i<65536;i++)
  {
    buffer[i]=0;
  }
  
  state=0;
  
  while(!feof(file))
  {
    switch(state)
    {
      /* read a new line */
      case 0:
       
        fgets(line,256,file);
        state=1;
        break;
      
      /* parse the first character */
      case 1:
       
        if(line[0]=='T')
          state=2;
        else
          state=0;
        break;
      
      /* read address */
      case 2:
      
        if(line[2]>='A')
          addr=((line[2]-'A'+10)&0x0f)<<12;
        else
          addr=((line[2]-'0')&0x0f)<<12;
    
        if(line[3]>='A')
          addr|=((line[3]-'A'+10)&0x0f)<<8;
        else
          addr|=((line[3]-'0')&0x0f)<<8;
          
        if(line[5]>='A')
          addr|=((line[5]-'A'+10)&0x0f)<<4;
        else
          addr|=((line[5]-'0')&0x0f)<<4;
          
        if(line[6]>='A')
          addr|=((line[6]-'A'+10)&0x0f);
        else
          addr|=((line[6]-'0')&0x0f);
          
        //printf("addr %-.4x\n",addr);
        i=8;
        state=3;
        break;

       /* read data */
       case 3:
       
        if(line[i]>='A')
          data=((line[i]-'A'+10)&0x0f)<<4;
        else
          data=((line[i]-'0')&0x0f)<<4;
    
        if(line[i+1]>='A')
          data|=(line[i+1]-'A'+10)&0x0f;
        else
          data|=(line[i+1]-'0')&0x0f;

        if(line[i+2]=='\n')
        {
          buffer[addr++]=data;
          //printf("%-.2x\n",data);
          state=0;
        }
        else
        {
          buffer[addr++]=data;
          //printf("%-.2x ",data);
          i+=3;
        }
        break;
      
      default:
        printf("error: unknown state %d !\n");
        exit(-1);
    }
  }
  fclose(file);
  
  file=fopen(argv[2],"wb");
  if(!file)
  {
    printf("error: unable to create file %s!\n",argv[2]);     
    exit(-1);     
  }
  
  start=strtoul(argv[3],(char**)NULL,16);
  stop=strtoul(argv[4],(char**)NULL,16);
  if(stop-start<=0)
  {
    printf("error: start address must be lower than stop address !\n");     
    exit(-1);     
  }
  
  data=fwrite(buffer+start,1,(stop-start+1),file);
  
  if(data<=0)
  {
    printf("error: problem during file writing !\n");     
    exit(-1);     
  
  }
  else
  {
    printf("%d bytes written\n",data);
  }
  fclose(file);
  return 0;
}

