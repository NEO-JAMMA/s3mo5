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
*   0000-1fff  8192   Video Banks  (user)      |  Video Banks (bios) 
*   -------------------------------------------+----------------------
*   2000-20ff   256   Page zero monitor        |
*   -------------------------------------------+
*   2100-21ff   256   Page zero basic          |  Bios ram
*   -------------------------------------------+
*   2200-9fff 32256   User ram                 |
*   ------------------------------------------------------------------
*   a000-a7bf  1984   Floppy 
*   ------------------------------------------------------------------
*   a7c0-a7c3     4   PIA6821      a7c0 PRA0 
*                                         0          O Point/Color
*                                         1          O RT  rouge cadre
*                                         2          O VT   vert  "
*                                         3          O BT   bleu  "
*                                         4          O PT pastel  "
*                                         5          I Switch light pen
*                                         6          0 K7 out
*                                         7          I K7 in
*                     System       a7c1 PRB0
*                                         0          O Sound Output
*                                         1          O Keyboard  col0      
*                                         2          O Keyboard  col1      
*                                         3          O Keyboard  col2      
*                                         4          O Keyboard  row1      
*                                         5          O Keyboard  row2      
*                                         6          O Keyboard  row3      
*                                         7          I Keyboard  read state
*                                  a7c2 CRA0
*                                         0   
*                                         1    
*                                         2  
*                                         3          | 1
*                                         4          | 1
*                                         5  CA2=OUT | X Moteur K7 (0=on/1=off)
*                                         6  IRQ2
*                                         7  IRQ1    Light-pen spot
*                                  a7c3 CRB0
*                                         0  
*                                         1  
*                                         2  
**                                        3          | 1
*                                         4          | 1
*                                         5  CB2=OUT | X Mux Clock H16
*                                         6  IRQ2
*                                         7  IRQ1    VSync (20 ms)
*   ------------------------------------------------------------------
*   a7c4-a7ca     7   Free
*        a7cb     1   EXT64K    
*                                         0  bank(0)
*                                         1  bank(1)
*                                         2  1=RAM/0=ROM
*                                         3  1=RW/0=RO
*                                         4  unused
*                                         5  unused
*                                         6  unused
*                                         7  unused
*   ------------------------------------------------------------------
*   a7cc-a7cf     4   PIA6821      a7cc PRA1
*                     Game                0  Joy0 - Forward
*                                         1  Joy0 - Back
*                                         2  Joy0 - Left
*                                         3  Joy0 - Right
*                                         4  Joy1 - Forward
*                                         5  Joy1 - Back
*                                         6  Joy1 - Left
*                                         7  Joy1 - Right
*                                  a7cd PRB1
*                                         0  Sound - B0     
*                                         1  Sound - B1     
*                                         2  Sound - B2     
*                                         3  Sound - B3     
*                                         4  Sound - B4     
*                                         5  Sound - B5     
*                                         6  Joy0  - Button 
*                                         7  Joy1  - Button 
*                                  a7ce CRA1
*                                         0
*                                         1
*                                         2
*                                         3   
*                                         4   
*                                         5
*                                         6  IRQ2  CA2 Joy1 - Button
*                                         7  IRQ1  CA1 Joy0 - Button
*                                  a7cf CRB1
*   ------------------------------------------------------------------
*   a7d0-a7df    16   Mini-floppy 
*   ------------------------------------------------------------------
*   a7e0-a7e3     4   PIA6821      a7e0 PRA2
*                     Parallel     a7e1 PRB2
*                                  a7e2 CRA2
*                                  a7e3 CRB2
*   ------------------------------------------------------------------
*   a7e4-a7e7     4   Gate-Array
*   ------------------------------------------------------------------
*   a7e8-a7ff   S3MO5 BIOS control registers
*
*   a7fc          1   Sliding window index (high)
*   a7fd          1   Sliding window index (low)
*   a7fe          1   s3mo5 control
*                     [0]   speed (0=true cycle mode,1=enhanced mode)
*                     [1]   NMI acknowledge
*                     [2]   video/user bank select (0=normal mode, 1=s3mo5 bios)
*                     [3]   reserved
*                     [6:4] frequency (n=0..7 where F = (n+1) MHz) 
*                     [7]   (1=hard reset/quit)
*   a7ff          1   reserved         
*
*   ------------------------------------------------------------------
*   a800-afff   S3MO5 BIOS memories (512 + 1536)
*
*   a800-a8ff   256   Sliding window
*   a900-afff  1792   S3MO5 BIOS code
*
*   ------------------------------+-----------------------------------
*   b000-bfff  4096   ROM (MEMO5) | Free
*   ------------------------------+-----------------------------------
*   c000-efff 12288   ROM - BASIC
*   f000-ffff  4096   ROM - Monitor
*
*********************************************************************/

#include "s3mo5.h"
#include "mtpack.h"

/*********************************************************************
*
* get_mem8
*
*********************************************************************/

unsigned int k7_timestep,last_event;

unsigned int get_mem8(unsigned int addr)
{
  unsigned int val;
  
  addr &= 0xffff;
  
  if(addr<0x2000)
  {
    /*****************************************************************
    * video banks
    *****************************************************************/
    if(pia0_pra&1)
    {
      if(bios_control&0x04)
      {
        val=memory[0x4000+2*addr];
        if(verbose){COLOR(GREEN);printf("rd bios_fore_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
      else
      {
        val=memory[2*addr];
        if(verbose){COLOR(GREEN);printf("rd fore_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
    }
    else
    {
      if(bios_control&0x04)
      {
        val=memory[0x4001+2*addr];
        if(verbose){COLOR(GREEN);printf("rd bios_back_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
      else
      {
        val=memory[1+2*addr];
        if(verbose){COLOR(GREEN);printf("rd back_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
    }
  }
  else if(addr<0xa000)
  {
    /*****************************************************************
    * user ram
    *****************************************************************/
    if(bios_control&0x04)
    {
      val=memory[0x10000+addr-0x2000];
      if(verbose){COLOR(GREEN);printf("rd bios_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
    }
    else
    {
      val=memory[0x8000+addr-0x2000];
      if(verbose){COLOR(GREEN);printf("rd user_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
    }
  }
  else if(addr<0xa7c0)
  {
    /*****************************************************************
    * floppy
    *****************************************************************/
    val=memory[0x1c000+addr-0xa000];
    if(verbose){COLOR(GREEN);printf("rd flop_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7c4)
  {
    /*****************************************************************
    * PIA6821 System
    *****************************************************************/
    switch(addr&0x3)
    {
      case 0:  /* PRA */
      
        if(BTST(pia0_cra,2))
        {
          val       = (pia0_pra&0xff) | 0x80;
          pia0_cra &= 0x3f;  /* pr[ab] read access clears the IRQ bits */
        }
        else
          val = pia0_ddra&0xff;
        
        break;
      
      case 1:  /* PRB */
        
        if(BTST(pia0_crb,2))
        {
          val       = (pia0_prb&0xff);
          
          /* keyboard */
          if(keyboard_mo5[((val>>4)&0x7) |((val<<2)&0x38)])
          {
            pia0_prb=val&0x7f;
          }
          else
          {
            pia0_prb=(val&0x7f)|0x80;
          }

          pia0_crb &= 0x3f;  /* pr[ab] read access clears the IRQ bits */
        }
        else
          val = pia0_ddrb&0xff;
          
        break;
      
      case 2:  /* CRA */
      
        val = pia0_cra&0xff;
        break;
      
      default: /* CRB */
     
        val = pia0_crb&0xff;
        break;
    }
    if(verbose){COLOR(GREEN);printf("rd pia0[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7cb)
  {
    /*****************************************************************
    * EXT64K control
    *****************************************************************/
    val = cnt_ext64k&0xff;
    if(verbose){COLOR(GREEN);printf("rd cnt_ext64k[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7cc)
  {
    /*****************************************************************
    * Free
    *****************************************************************/
    val=0x00;
    if(verbose){COLOR(GREEN);printf("rd free[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7d0)
  {
    /*****************************************************************
    * PIA6821 Game
    *****************************************************************/
    switch(addr&0x3)
    {
      case 0:  /* PRA */
      
        if(BTST(pia1_cra,2))
        {
          val       =  (pia1_pra&0xff)|0xff;
          pia1_cra &= 0x3f;  /* pr[ab] read access clears the IRQ bits */
        }
        else
          val = pia1_ddra&0xff;
          
        break;
      
      case 1:  /* PRB */
        
        if(BTST(pia1_crb,2))
        {
          val       = (pia1_prb&0xff)|0xc0;
          pia1_crb &= 0x3f;  /* pr[ab] read access clears the IRQ bits */
        }
        else
          val = pia1_ddrb&0xff;
          
        break;
      
      case 2:  /* CRA */
      
        val = pia1_cra&0xff;
        break;
      
      default: /* CRB */
     
        val = pia1_crb&0xff;
        break;
    }
    if(verbose){COLOR(GREEN);printf("rd pia1[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7e0)
  {
    /*****************************************************************
    * Mini-Floppy
    *****************************************************************/
    val=0x00;
    if(verbose){COLOR(GREEN);printf("rd mini_floppy[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7e4)
  {
    /*****************************************************************
    * PIA6821 Parallel
    *****************************************************************/
    switch(addr&0x3)
    {
      case 0:  /* PRA */
      
        if(BTST(pia2_cra,2))
        {
          val       = pia2_pra&0xff;
          pia2_cra &= 0x3f;  /* pr[ab] read access clears the IRQ bits */
        }
        else
          val = pia2_ddra&0xff;
          
        break;
      
      case 1:  /* PRB */
        
        if(BTST(pia2_crb,2))
        {
          val       = pia2_prb&0xff;
          pia2_crb &= 0x3f;  /* pr[ab] read access clears the IRQ bits */
        }
        else
          val = pia2_ddrb&0xff;
          
        break;
      
      case 2:  /* CRA */
      
        val = pia2_cra&0xff;
        break;
      
      default: /* CRB */
     
        val = pia2_crb&0xff;
        break;
    }
    if(verbose){COLOR(GREEN);printf("rd pia2[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7e8)
  {
    /*****************************************************************
    * Gate-Array
    *****************************************************************/
    gate_array[addr&0x3]^=0xff;
    val=gate_array[addr&0x3]&0xff;
    if(verbose){COLOR(GREEN);printf("rd gate_array[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa800)
  {
    /*****************************************************************
    * S3MO5 BIOS control registers
    *****************************************************************/
    switch(addr)
    {
      case 0xa7fc: val=bios_slide_index_h; break;
      case 0xa7fd: val=bios_slide_index_l; break;
      case 0xa7fe: val=bios_control;       break;
      case 0xa7ff: val=bios_control2;      break;
      default:     val=0x00; break;
    }
    if(verbose){COLOR(GREEN);printf("rd bios_registers[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  
  else if(addr<0xb000)
  {
    /*****************************************************************
    * S3MO5 BIOS memories
    *****************************************************************/
    if(addr<0xa900)                                                                             
    {                                                                                           
      val=memory[(bios_slide_index_h<<16)|(bios_slide_index_l<<8)|(addr&0xff)];           
      if(verbose){COLOR(GREEN);printf("rd slide_window[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}  
    }                                                                                           
    else                                                                                        
    {                                                                                           
      val=memory[0x1c000+addr-0xa000];                                                                 
      if(verbose){COLOR(GREEN);printf("rd bios_rom[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);} 
    }                                                                                           
  }
  else if(addr<0xc000)
  {
    /*****************************************************************
    * ROM - Free
    *****************************************************************/
    val=0x00;
    if(verbose){COLOR(GREEN);printf("rd rom_free[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xf000)
  {
    /*****************************************************************
    * ROM - Basic 
    *****************************************************************/
    val=memory[0x18000+addr-0xc000];
    if(verbose){COLOR(GREEN);printf("rd rom_basic[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else
  {
    /*****************************************************************
    * ROM - Moniteur 
    *****************************************************************/
    val=memory[0x18000+addr-0xc000];
    if(verbose){COLOR(GREEN);printf("rd rom_monitor[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  
  if(display_memtraffic) mtpack_read_access(addr,val);
  return val;
}

/*********************************************************************
*
* get_mem16
*
*********************************************************************/
unsigned int get_mem16(unsigned int mode,unsigned int addr)
{
  unsigned int tmp;
  
  tmp  = get_mem8(addr)<<8;
  
  if(mode==DIRECT)
  {
    if((addr&0xff)==0xff)
    {
      printf("note:get_mem16: 16-bits direct addressing overlaps the page (pc=%-.4x  addr=0x%-.4x)\n",pc,addr);
    }
    tmp |= get_mem8((addr&0xff00)|((addr+1)&0x00ff));
  }
  else
  {
    tmp |= get_mem8(addr+1);
  }
  
  return tmp;
}

/*********************************************************************
*
* put_mem8
*
*********************************************************************/
void put_mem8(unsigned int addr, unsigned int val)
{
  unsigned i,j,k,col_cad,col_back,col_fore,tmp;
  
  addr &= 0xffff;
  
  if(display_memtraffic) mtpack_write_access(addr,val);
  
  if(addr<0x2000)
  {
    /*****************************************************************
    * video banks
    *****************************************************************/
    if(pia0_pra&1)
    {
      if(bios_control&4)
      {
        memory[0x4000+2*addr]=val;
        if(verbose){COLOR(GREEN);printf("wr bios_fore_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
      else
      {
        memory[2*addr]=val;
        if(verbose){COLOR(GREEN);printf("wr fore_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
    }
    else
    {
      if(bios_control&4)
      {
        memory[0x4001+2*addr]=val;
        if(verbose){COLOR(GREEN);printf("wr bios_back_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
      else
      {
        memory[1+2*addr]=val;
        if(verbose){COLOR(GREEN);printf("wr back_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
      }
    }
    
    /* update X11 frame buffer (0x0000 - 0x1f40) - main area*/
    
    if(addr<0x1f40)
    {
      if(bios_control&4)
        tmp      = memory[0x4001+2*addr];
      else
        tmp      = memory[1+2*addr];
      col_fore = color_bgr_mo5[(tmp>>4)&0x0f];
      col_back = color_bgr_mo5[tmp&0x0f];
    
      i = addr/40;
      j = addr%40;
    
      for(k=0;k<8;k++)
      {
        if(bios_control&0x04)
        {
          if(BTST(memory[0x4000+2*addr],(7-k)))              
            ((unsigned int *)bios_frame)[336*8 + 8 + i*336 + j*8 + k] = col_fore;  
          else                                                  
            ((unsigned int *)bios_frame)[336*8 + 8 + i*336 + j*8 + k] = col_back;
        }
        else
        {
          if(BTST(memory[2*addr],(7-k)))              
            ((unsigned int *)frame)[336*8 + 8 + i*336 + j*8 + k] = col_fore;  
          else                                                  
            ((unsigned int *)frame)[336*8 + 8 + i*336 + j*8 + k] = col_back;
        }  
      }
    }
  }
  else if(addr<0xa000)
  {
    /*****************************************************************
    * user ram
    *****************************************************************/
    if(bios_control&0x04)
    {
      memory[0x10000+addr-0x2000]=val;
      if(verbose){COLOR(GREEN);printf("wr bios_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
    }
    else
    {
      memory[0x08000+addr-0x2000]=val;
      if(verbose){COLOR(GREEN);printf("wr user_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
    }
  }
  else if(addr<0xa7c0)
  {
    /*****************************************************************
    * floppy
    *****************************************************************/
    /*flop_ram[addr-0xa000]=val&0xff;*/
    if(verbose){COLOR(GREEN);printf("wr flop_ram[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7c4)
  {
    /*****************************************************************
    * PIA6821 System
    *****************************************************************/
    switch(addr&0x3)
    {
      case 0:  /* PRA */
      
        if(BTST(pia0_cra,2))
        {
          /* update X11 frame buffer - border area */
          if((val&0x1e)!=(pia0_pra&0x1e))
          {
            col_cad  = color_bgr_mo5[(val>>1)&0x0f];
            for(i=0;i<216;i++)
              for(j=0;j<42;j++)
                for(k=0;k<8;k++)
                  if((i<8) || (i>=208) || (j<1) || (j>=41))
                  {
                    if(bios_control&0x04)
                      ((unsigned int *)bios_frame)[i*336+j*8+k] = col_cad;
                    else
                      ((unsigned int *)frame)[i*336+j*8+k] = col_cad;
                   
                  }
          } 
          
          pia0_pra=(val&0xff) | 0x80;
        }
        else
          pia0_ddra=val&0xff;
          
        break;
      
      case 1:  /* PRB */
        
        if(BTST(pia0_crb,2))
        { 
          /* sound */
          if((val&1) ^ (pia0_prb&1))
          {
            sound_put_bit();
            //printf("%d %d\n",val&1,cpu_timestep-last_event);
            //last_event=cpu_timestep;
          }
          
          /* keyboard */
          if(keyboard_mo5[((val>>4)&0x7) |((val<<2)&0x38)])
          {
            pia0_prb=val&0x7f;
          }
          else
          {
            pia0_prb=(val&0x7f)|0x80;
          }
        }
        else
          pia0_ddrb=val&0xff;
          
        break;
      
      case 2:  /* CRA */
      
        pia0_cra=val&0xff;
        break;
      
      default: /* CRB */
        
        pia0_crb=val&0xff;
        break;
    }
    if(verbose){COLOR(GREEN);printf("wr pia0[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7cb)
  {
    /*****************************************************************
    * EXT64K control
    *****************************************************************/
    val = cnt_ext64k&0xff;
    if(verbose){COLOR(GREEN);printf("wr cnt_ext64k[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7cc)
  {
    /*****************************************************************
    * Free
    *****************************************************************/
    if(verbose){COLOR(GREEN);printf("wr free[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7d0)
  {
    /*****************************************************************
    * PIA6821 Game
    *****************************************************************/
    switch(addr&0x3)
    {
      case 0:  /* PRA */
      
        if(BTST(pia1_cra,2))
          pia1_pra=val&0xff;
        else
          pia1_ddra=val&0xff;
          
        break;
      
      case 1:  /* PRB */
        
        if(BTST(pia1_crb,2))
          pia1_prb=val&0xff;
        else
          pia1_ddrb=val&0xff;
          
        break;
      
      case 2:  /* CRA */
      
        pia1_cra=val&0xff;
        break;
      
      default: /* CRB */
     
        pia1_crb=val&0xff;
        break;
    }
    if(verbose){COLOR(GREEN);printf("wr pia1[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7e0)
  {
    /*****************************************************************
    * Mini-Floppy
    *****************************************************************/
    if(verbose){COLOR(GREEN);printf("wr mini_floppy[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7e4)
  {
    /*****************************************************************
    * PIA6821 Parallel
    *****************************************************************/
    switch(addr&0x3)
    {
      case 0:  /* PRA */
      
        if(BTST(pia2_cra,2))
          pia2_pra=val&0xff;
        else
          pia2_ddra=val&0xff;
        
        break;
      
      case 1:  /* PRB */
        
        if(BTST(pia2_crb,2))
          pia2_prb=val&0xff;
        else
          pia2_ddrb=val&0xff;
        
        break;
      
      case 2:  /* CRA */
      
        pia2_cra=val&0xff;
        break;
      
      default: /* CRB */
     
        pia2_crb=val&0xff;
        break;
    }
    if(verbose){COLOR(GREEN);printf("wr pia2[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa7e8)
  {
    /*****************************************************************
    * Gate-Array
    *****************************************************************/
    /*gate_array[addr&0x3]=val&0xff;*/
    if(verbose){COLOR(GREEN);printf("wr gate_array[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xa800)
  {
    /*****************************************************************
    * S3MO5 BIOS control registers
    *****************************************************************/
    switch(addr)                                                                                
    {                                                                                           
      case 0xa7fc: bios_slide_index_h = val; break;                                        
      case 0xa7fd: bios_slide_index_l = val; break;                                        
      case 0xa7fe: bios_control       = val; break;                                        
      case 0xa7ff: bios_control2      = val; break;                                        
      default: break;                                                                           
    }                                                                                           
    if(verbose){COLOR(GREEN);printf("wr bios_registers[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}  
  }
  else if(addr<0xb000)
  {
    /*****************************************************************
    * S3MO5 BIOS memories
    *****************************************************************/
    if(addr<0xa900)                                                                             
    {                                                                                           
      memory[(bios_slide_index_h<<16)|(bios_slide_index_l<<8)|(addr&0xff)]=val;      
      if(verbose){COLOR(GREEN);printf("wr slide_window[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}  
    }                                                                                           
    else                                                                                        
    {                                                                                           
      memory[0x1c000+addr-0xa000]=val;                                                                 
      if(verbose){COLOR(GREEN);printf("wr bios_rom[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}      
    }                                                                                           
  }
  else if(addr<0xc000)
  {
    /*****************************************************************
    * ROM - Free
    *****************************************************************/
    if(verbose){COLOR(GREEN);printf("wr rom_free[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else if(addr<0xf000)
  {
    /*****************************************************************
    * ROM - Basic 
    *****************************************************************/
    if(bios_control2&1)
    {
      memory[0x18000+addr-0xc000];    
    }
    if(verbose){COLOR(GREEN);printf("wr rom_basic[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
  else
  {
    /*****************************************************************
    * ROM - Moniteur 
    *****************************************************************/
    if(bios_control2&1)
    {
      memory[0x18000+addr-0xc000]=val;
    }
    if(verbose){COLOR(GREEN);printf("wr rom_monitor[%-.4x]=%-.2x\n",addr,val);COLOR(NORM);}
  }
}

/*********************************************************************
*
* put_mem16
*
*********************************************************************/
void put_mem16(unsigned int mode,unsigned int addr, unsigned int val)
{
  put_mem8(addr,val>>8);
  if(mode==DIRECT)
  {
    if((addr&0xff)==0xff)
    {
      printf("note:put_mem16: 16-bits direct addressing overlaps the page (pc=0x%-.4x  addr=0x%-.4x)\n",pc,addr);
    }
    put_mem8((addr&0xff00)|((addr+1)&0x00ff),val&0xff);
  }
  else
  {
    put_mem8(addr+1,val&0xff);
  }
}
