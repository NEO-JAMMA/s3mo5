/*********************************************************************
* 
* S3MO5 model -  dump2ppm
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

unsigned int  color_bgr_mo5[16]=
{                            
  0x000000, /*  0 noir          */
  0xff0000, /*  1 rouge         */
  0x00ff00, /*  2 vert          */
  0xffff00, /*  3 jaune         */
  0x0000ff, /*  4 bleu          */
  0xff00ff, /*  5 magenta       */
  0x00ffff, /*  6 cyan          */
  0xffffff, /*  7 blanc         */
  0xb0b0b0, /*  8 gris          */
  0xffb0b0, /*  9 rose          */
  0xb0ffb0, /* 10 vert clair    */
  0xffffb0, /* 11 jaune poussin */ 
  0xb0b0ff, /* 12 bleu clair    */
  0xffb0ff, /* 13 rose parme    */
  0xb0ffff, /* 14 cyan clair    */
  0xffb000  /* 15 orange        */
};

int main(int argc,char **argv)
{
  FILE *file;
  unsigned char frame[40*200*2];
  unsigned char buffer[16];
  unsigned char line[256];
  unsigned int count,i,pixel,fore,back,pic_count;
  
  if(argc!=4)
  {
    printf("error: bad argument number !\n");
    printf("usage: %s <dump.txt> <picture.ppm> <image pos>\n",argv[0]);
    exit(-1);
  }
  
  file=fopen(argv[1],"rb");
  if(!file)
  {
    printf("error: unable to open file !\n");
    exit(-1);
  }

  count=0;
  pic_count=0;
  
  /* find the right image */
  do
  {
    if(feof(file)) break;
    fgets(line,256,file);
    if(line[0]=='d')
    {
      pic_count++;
    }
  }
  while(pic_count!=(atoi(argv[3])+1));
  
  if(pic_count!=(atoi(argv[3])+1))
  {
    printf("picture not found !\n");
    exit(-1);
  }
  else
  {
    printf(line);
  }
  
  
  
  /* extrace the image */
  while(count<40*200*2)
  {
    if(feof(file)) break;
    fgets(line,256,file);
    for(i=0;i<16;i++) 
    {
      buffer[0]=line[7+2*i];
      buffer[1]=line[8+2*i];
      buffer[2]=0;
      frame[count++]=strtoul(buffer,(char**)NULL,16);
    }
  }
  fclose(file);
  
  file=fopen(argv[2],"wb");
  if(!file)
  {
    printf("error: unable to open file !\n");
    exit(-1);
  }
  
  fprintf(file,"P6\n320 200\n255\n");
  count=0;
  while(count<40*200)
  {
    pixel=frame[2*count];
    fore=color_bgr_mo5[(frame[2*count+1]>>4)&0x0f];
    back=color_bgr_mo5[frame[2*count+1]&0x0f];
    
    for(i=0;i<8;i++)
    {
      if(pixel&(1<<(7-i)))
      {
        fputc((fore>>16)&0xff,file);
        fputc((fore>>8)&0xff,file);
        fputc(fore&0xff,file);
      }
      else
      {
        fputc((back>>16)&0xff,file);
        fputc((back>>8)&0xff,file);
        fputc(back&0xff,file);
      }
    }
    count+=1;
  }
  fclose(file);
  
}
