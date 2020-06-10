/*********************************************************************
* 
* S3MO5 model -  dither
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

void put_pixel(unsigned int,unsigned int,unsigned int,unsigned int);


unsigned char buffer_in[336*216*3];
unsigned char buffer_out[336*216*3*4];

int main(int argc,char **argv)
{
  unsigned int x,y,color;
  FILE *file;
  
  file=fopen(argv[1],"rb");
  if(!file)
  {
    printf("error: unable to open source file !\n");
    exit(-1);
  }
  
  fgets(buffer_in,128,file); /* drop header */
  if(strcmp(buffer_in,"P6\n"))
  {
    printf("error: unexpected ppm header file found !\n");
    exit(-1);
  }
 
  fgets(buffer_in,128,file);
  if(strcmp(buffer_in,"336 216\n"))
  {
    printf("error: unexpected picture dimension found !\n");
    exit(-1);
  }
  
  fgets(buffer_in,128,file);
  if(strcmp(buffer_in,"255\n"))
  {
    printf("error: unexpected ppm header file found !\n");
    exit(-1);
  }

  if(fread(buffer_in,1,336*216*3,file)!=336*216*3)
  {
    printf("error: bad number of bytes read !\n");
    exit(-1);
  }
  
  fclose(file);

  /*
   *   make dithering
   */

  for(y=0;y<216;y++)
  {
    for(x=0;x<336;x++)
    {
      color  = buffer_in[3*(y*336+x)]<<16;
      color |= buffer_in[3*(y*336+x)+1]<<8;
      color |= buffer_in[3*(y*336+x)+2];
      
      switch(color)
      {
        case 0x000000: put_pixel(x,y,0x000000,0x000000); break;
        case 0xff0000: put_pixel(x,y,0xff0000,0xff0000); break;
        case 0x00ff00: put_pixel(x,y,0x00ff00,0x00ff00); break;
        case 0xffff00: put_pixel(x,y,0xffff00,0xffff00); break;
        case 0x0000ff: put_pixel(x,y,0x0000ff,0x0000ff); break;
        case 0xff00ff: put_pixel(x,y,0xff00ff,0xff00ff); break;
        case 0x00ffff: put_pixel(x,y,0x00ffff,0x00ffff); break;
        case 0xffffff: put_pixel(x,y,0xffffff,0xffffff); break;
        case 0xb0b0b0: put_pixel(x,y,0x000000,0xffffff); break;
        case 0xffb0b0: put_pixel(x,y,0xff0000,0xffffff); break;
        case 0xb0ffb0: put_pixel(x,y,0x00ff00,0xffffff); break;
        case 0xffffb0: put_pixel(x,y,0xffff00,0xffffff); break;
        case 0xb0b0ff: put_pixel(x,y,0x0000ff,0xffffff); break;
        case 0xffb0ff: put_pixel(x,y,0xff00ff,0xffffff); break;
        case 0xb0ffff: put_pixel(x,y,0x00ffff,0xffffff); break;
        case 0xffb000: put_pixel(x,y,0xffff00,0xff0000); break;
        default:
        
          printf("error:unknown color !\n");
          exit(-1);
      }
      
    }
  }
  
  file=fopen(argv[2],"wb");
  if(!file)
  {
    printf("error: unable to open target file !\n");
    exit(-1);
  }
  
  fprintf(file,"P6\n672 432\n255\n");
  if(fwrite(buffer_out,1,336*216*3*4,file)!=336*216*3*4)
  {
    printf("error: bad number of bytes written !\n");
    exit(-1);
  }
  fclose(file);
  
}


void put_pixel(unsigned int x,unsigned int y,unsigned rgb0,unsigned rgb1)
{
  y = y*2;
  x = x*2;
  
  buffer_out[3*(y*672+x)]       = buffer_out[3*((y+1)*672+(x+1))]    = rgb0>>16;
  buffer_out[3*(y*672+x)+1]     = buffer_out[3*((y+1)*672+(x+1))+1] = (rgb0>>8)&0xff;
  buffer_out[3*(y*672+x)+2]     = buffer_out[3*((y+1)*672+(x+1))+2] = (rgb0)&0xff;
 
  buffer_out[3*(y*672+(x+1))]   = buffer_out[3*((y+1)*672+x)]   = rgb1>>16;
  buffer_out[3*(y*672+(x+1))+1] = buffer_out[3*((y+1)*672+x)+1] = (rgb1>>8)&0xff;
  buffer_out[3*(y*672+(x+1))+2] = buffer_out[3*((y+1)*672+x)+2] = (rgb1)&0xff;

}
