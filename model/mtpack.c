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
#include "mtpack.h"

unsigned int mtpack_buffer;
unsigned int mtpack_count;
unsigned int paddr,instr_count=0;
gzFile       mtpack_file;
unsigned int mtpack_is_init=0;

/* bits are packed from left to right into the buffer */
void mtpack_put_bits(unsigned int val,unsigned int count)
{
  while(mtpack_count>=8)
  {
    gzputc(mtpack_file,(mtpack_buffer>>24)&0xff);
    mtpack_buffer =  mtpack_buffer<<8;
    mtpack_count  -= 8;
  }
  
  mtpack_buffer |= (val&((1<<count)-1))<<(32-(count+mtpack_count));
  mtpack_count  += count;
}

void mtpack_flush_buffer(void)
{
  mtpack_put_bits(0x10,5);
  mtpack_put_bits(0x10,5);
  mtpack_put_bits(0x10,5);
  mtpack_put_bits(0x10,5);
}

void mtpack_put_register_changes(void)
{
  /* check PC */
  if(mtpack_is_init)
  {
    if(pc!=ppc)
    {
      mtpack_put_bits(0x0,1);
      
      if(pc==(paddr+1))
      {
        mtpack_put_bits(0x0,2);
      }
      else
      {
        mtpack_put_bits(0x1,2);
        mtpack_put_bits(pc,16);
      }
    }
  
    /* check A */
    if(a!=pa)
    {
      mtpack_put_bits(0x4,4);
      mtpack_put_bits(a,8);
    }
  
    /* check B */
    if(b!=pb)
    {
      mtpack_put_bits(0x5,4);
      mtpack_put_bits(b,8);
    }
  
    /* check X */
    if(x!=px)
    {
      mtpack_put_bits(0xc,5);
      mtpack_put_bits(x,16);
    }
  
    /* check Y */
    if(y!=py)
    {
      mtpack_put_bits(0xd,5);
      mtpack_put_bits(y,16);
    }
  
    /* check CC */
    if(cc!=pcc)
    {
      mtpack_put_bits(0xe,5);
      mtpack_put_bits(cc,8);
    }
  
    /* check U */
    if(u!=pu)
    {
      mtpack_put_bits(0x3c,7);
      mtpack_put_bits(u,16);
    }
 
    /* check S */
    if(s!=ps)
    {
      mtpack_put_bits(0x3d,7);
      mtpack_put_bits(s,16);
    }

    /* check DP */
    if(dp!=pdp)
    {
      mtpack_put_bits(0x3e,7);
      mtpack_put_bits(dp,8);
    }
  }
  else
  {
    mtpack_is_init=1;
    
    /* PC */
    mtpack_put_bits(0x1,3);
    mtpack_put_bits(pc,16);
    /* A */
    mtpack_put_bits(0x4,4);
    mtpack_put_bits(a,8);
    /* B */
    mtpack_put_bits(0x5,4);
    mtpack_put_bits(b,8);
    /* X */
    mtpack_put_bits(0xc,5);
    mtpack_put_bits(x,16);
    /* Y */
    mtpack_put_bits(0xd,5);
    mtpack_put_bits(y,16);
    /* CC */
    mtpack_put_bits(0xe,5);
    mtpack_put_bits(cc,8);
    /* U */
    mtpack_put_bits(0x3c,7);
    mtpack_put_bits(u,16);
    /* S */
    mtpack_put_bits(0x3d,7);
    mtpack_put_bits(s,16);
    /* DP */
    mtpack_put_bits(0x3e,7);
    mtpack_put_bits(dp,8);
  }
}

void mtpack_read_access(unsigned int addr,unsigned int val)
{
  if(addr==(paddr+1))          
  {                            
    mtpack_put_bits(0x6,3);    
    mtpack_put_bits(val,8);    
  }                            
  else                         
  {                            
    mtpack_put_bits(0xe,4);    
    mtpack_put_bits(addr,16);  
    mtpack_put_bits(val,8);    
  }                            
  paddr=addr&0xffff;           
}

void mtpack_write_access(unsigned int addr,unsigned int val)
{
  mtpack_put_bits(0xf,4);
  mtpack_put_bits(addr,16);
  mtpack_put_bits(val,8);
}

void mtpack_nmi(unsigned int state)
{
  mtpack_put_bits(0x3fc|(state&1),11);
}

void mtpack_irq(unsigned int state)
{
  mtpack_put_bits(0x3fa|(state&1),11);
}

void mtpack_fiq(unsigned int state)
{
  mtpack_put_bits(0x3f8|(state&1),11);
}

void mtpack_new_instr(unsigned int n)
{
  unsigned int  orig_verbose,orig_memtraffic;
  unsigned int  opc,mode;
  
  mtpack_put_bits(0x2,2);
 
  if(n<2)
  {
    printf("mtpack_new_instr: unexpected number of cycles (<2)\n");
    exit(-1);
  }
  else if(n<6)
  {
    mtpack_put_bits(0x0,1);
    mtpack_put_bits((n-2),2);
  }
  else
  {
    mtpack_put_bits(0x1,1);
    mtpack_put_bits((n-6),5);
  }
}

unsigned int mtpack_get_bits(unsigned int count)
{
  unsigned int data;
  
  while(mtpack_count<24)                       
  {                                            
    data=gzgetc(mtpack_file)&0xff;              
    mtpack_buffer |= data<<(32-mtpack_count-8);  
    mtpack_count  += 8;                        
  }                                            
  
  data=(mtpack_buffer>>(32-count))&((1<<count)-1);
  mtpack_buffer =  mtpack_buffer<<count;
  mtpack_count  -= count;
  
  /*mtpack_print_vlc(data,count);*/
  
  return data;
}

void mtpack_cat()
{
  unsigned int i;
  
  /* extract */
  while(!gzeof(mtpack_file))
  {
    if(mtpack_get_bits(1))
    {
      if(mtpack_get_bits(1))
      {
        if(mtpack_get_bits(1)) /*111*/
        {
          if(mtpack_get_bits(1)) /*1111*/
          {
            i=mtpack_get_bits(16);
            printf("w  %-.4x %-.2x\n",i,mtpack_get_bits(8));
          }
          else /*1110*/
          {
            paddr=mtpack_get_bits(16);
            printf("r  %-.4x %-.2x\n",paddr,mtpack_get_bits(8));
          }
        }
        else /* 110 */
        {
            paddr++;
            printf("r  %-.4x %-.2x\n",paddr,mtpack_get_bits(8));
        }
      }
      else /*10*/
      {
        if(mtpack_get_bits(1)) /*1*/
        {
          i=mtpack_get_bits(5)+6;
        }
        else /*0*/
        {
          i=mtpack_get_bits(2)+2;
        }
        printf("- %d %d\n",instr_count,i);
        instr_count++;
      }
    }
    else
    {
      if(mtpack_get_bits(1)) /*01*/
      {
        if(mtpack_get_bits(1)) /*011*/
        {
          switch(mtpack_get_bits(2))
          {
            case 0: /*01100*/
              
              printf("x  %-.4x\n",mtpack_get_bits(16));
              break;
              
            case 1: /*01101*/
              
              printf("y  %-.4x\n",mtpack_get_bits(16));
              break;
            
            case 2: /*01110*/
              
              printf("cc %-.2x\n",mtpack_get_bits(8));
              break;
            
            default: /* 01111*/
            
              switch(mtpack_get_bits(2))
              {
                case 0: /*0111100*/
                
                  printf("u  %-.4x\n",mtpack_get_bits(16));
                  break;
                
                case 1: /*0111101*/
                 
                  printf("s  %-.4x\n",mtpack_get_bits(16));
                  break;
                
                case 2: /*0111110*/
                
                  printf("dp %-.2x\n",mtpack_get_bits(8));
                  break;
                
                default:/*0111111*/
                
                  if(mtpack_get_bits(1))
                  {
                    switch(mtpack_get_bits(2))
                    {
                      case 0: /*011111100*/
                      
                        printf("it f %d\n",mtpack_get_bits(1));
                        break;
                      
                      case 1: /*011111101*/
                      
                        printf("it i %d\n",mtpack_get_bits(1));
                        break;
                      
                      case 2: /*011111110*/
                      
                        printf("it n %d\n",mtpack_get_bits(1));
                        break;
                      
                      default:/*011111111*/
                        
                        printf("error: reserved codword 01111110 !\n");
                        exit(-1);
                    }
                  }
                  else
                  {
                    printf("error: reserved codword 01111110 !\n");
                    exit(-1);
                  }
                  break;
              }
              break;
          }
        }
        else /*010*/
        {
          if(mtpack_get_bits(1)) /*0101*/
          {
            printf("b  %-.2x\n",mtpack_get_bits(8));
          }
          else /*0100*/
          {
            printf("a  %-.2x\n",mtpack_get_bits(8));
          }
        }
      }
      else
      {
        if(mtpack_get_bits(1)) /*001*/
        {
          printf("pc %-.4x\n",mtpack_get_bits(16));
        }
        else /*000*/
        {
          printf("pc %-.4x\n",paddr+1);
        }
      }
    }
  }
}

void mtpack_print_vlc(unsigned int val,unsigned int count)
{
  unsigned int i;
  
  for(i=0;i<count;i++)
    if((val>>(count-i-1))&1)
      printf("1");
    else
      printf("0");

  printf("\n");
}
