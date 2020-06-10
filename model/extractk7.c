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
#include <stdlib.h>

unsigned int skip_synchro(unsigned char *buffer,unsigned int pos);

int main(int argc,char**argv)
{
  FILE          *file_in;
  unsigned int  count,state,pos,i;
  unsigned char *buffer;
  
  if(argc!=2)
  {
    printf("error: bad argument number !\n");
    printf("syntax: %s <file.k7>\n",argv[0]);
    exit(-1);
  }
  
  buffer=(unsigned char *)malloc(512*1024);
  if(!buffer)
  {
    printf("error: unable to allocate enough memory !\n");
    exit(-1);
  }
  
  file_in=fopen(argv[1],"rb");
  if(!file_in)
  {
    printf("error: unable to open file !\n");
    exit(-1);
  }
  
  count=fread(buffer,1,512*1024,file_in);
  fclose(file_in);
  
  printf("%d bytes read.\n",count);  
  
  
  /* main loop */
  
  pos=0;
  pos+=skip_synchro(buffer,pos);
  
  printf("bloc at %-.4x\n",pos);
  i=buffer[pos++];
  
  printf("type %-.2x\n",buffer[pos++]);
  
  
  free(buffer);
}



unsigned int skip_synchro(unsigned char *buffer,unsigned int pos)
{
  unsigned int state,i;
  
  state=0;
  
  while(1)
  {
    switch(state)
    {
      /*************************************************************************
      * detect synchro
      *************************************************************************/
      case 0:
      
        if(buffer[pos]==0x01)
        {
          state=1;
          i=1;
        }
        else
        {
          i=0;
        }
        break;
      
      /*************************************************************************
      * 
      *************************************************************************/
      case 1:
      
        if(buffer[pos]==0x01)
        {
          i++;
          if(i>=9)
          {
            state=2;
          }
        }
        else
        {
          state=0;
        }
        break;
     
      /*************************************************************************
      * 
      *************************************************************************/
      case 2:
      
        if(buffer[pos]==0x3c)
        {
          state=3;
        }
        else
        {
          if(buffer[pos]!=0x01)
          {
            state=0;
          }
        }
        break;
    
      /*************************************************************************
      * 
      *************************************************************************/
      case 3:
      
        if(buffer[pos]==0x5a)
        {
          return pos+1;
        }
        else
        {
          state=0;
        }
        break;
     
      default:
        break;
    }
    if(pos==512*1024)
    {
      printf("no more synchro found !\n");
      exit(0);
    }
    pos++;
  }
}
