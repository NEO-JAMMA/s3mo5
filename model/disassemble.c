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
#include "s3mo5.h"

#define index_reg(a)  ((a&0x40)?((a&0x20)?'s':'u'):((a&0x20)?'y':'x'))

unsigned int disassemble(unsigned int pos)
{
  unsigned int orig_pos,opc,op1,mode,m0,postbyte,orig_verbose,orig_memtraffic;
  unsigned int dp,i,j;
  char         db[512];
  char         *mnem;
  
  orig_verbose         = verbose;
  orig_memtraffic      = display_memtraffic;
  verbose              = 0;
  display_memtraffic   = 0;
  
  dp=sprintf(db,"%-.4x:                    ",pos);
  
  orig_pos = pos;
  
  opc      = get_mem8(pos++);
  
  
  if(opcode[opc].mode==OPCODE10)
  {
    opc    = get_mem8(pos++);
    mnem   = opcode10[opc].mnemonic;
    op1    = opcode10[opc].op1;
    mode   = opcode10[opc].mode;
  }
  else if(opcode[opc].mode==OPCODE11)
  {
    opc    = get_mem8(pos++);
    mnem   = opcode11[opc].mnemonic;
    op1    = opcode11[opc].op1;
    mode   = opcode11[opc].mode;
  }
  else
  {
    mnem   = opcode[opc].mnemonic;
    op1    = opcode[opc].op1;
    mode   = opcode[opc].mode;
  }
  
  dp+=sprintf(db+dp,"%s  ",mnem);
  
  switch(mode)
  {
    case DIRECT:
    
      m0 = get_mem8(pos++);
      dp+=sprintf(db+dp,"$%-.2x\n",m0);;
      break;
    
    case EXTENDED: 
    
      m0  = get_mem8(pos++)<<8;
      m0 |= get_mem8(pos++);
      dp+=sprintf(db+dp,"$%-.4x\n",m0);
      break;
    
    case IMMEDIATE8:
    
      m0 = get_mem8(pos++);
      dp+=sprintf(db+dp,"#$%-.2x\n",m0);
      break;
    
    case IMMEDIATE16:
    
      m0  = get_mem8(pos++)<<8;
      m0 |= get_mem8(pos++);
      dp+=sprintf(db+dp,"#$%-.4x\n",m0);
      break;
    
    case INHERENT2:
    
      m0=get_mem8(pos++);
      
      for(i=0;i<2;i++)
      {
        switch((m0>>(4*(1-i)))&0xf)
        {
          case 0:  dp+=sprintf(db+dp,"d");  break;
          case 1:  dp+=sprintf(db+dp,"x");  break;
          case 2:  dp+=sprintf(db+dp,"y");  break;
          case 3:  dp+=sprintf(db+dp,"u");  break;
          case 4:  dp+=sprintf(db+dp,"s");  break;
          case 5:  dp+=sprintf(db+dp,"pc"); break; 
          case 8:  dp+=sprintf(db+dp,"a");  break; 
          case 9:  dp+=sprintf(db+dp,"b");  break; 
          case 10: dp+=sprintf(db+dp,"cc"); break; 
          case 11: dp+=sprintf(db+dp,"dp"); break; 
          default: dp+=sprintf(db+dp,"?");  break; 
        }
        if(!i) dp+=sprintf(dp+db,",");
      }
      dp+=sprintf(dp+db,"\n");
      break;
    
    case INHERENT3S:
    case INHERENT3U:
    
      m0=get_mem8(pos++);
      j=0;
      for(i=0;i<8;i++)
      {
        if(m0&(1<<(7-i)))
        {
          if(j) dp+=sprintf(db+dp,",");
          switch(i)
          {
            case 1:  
              if(mode==INHERENT3S)
                dp+=sprintf(db+dp,"u");
              else
                dp+=sprintf(db+dp,"s"); 
              break;
            
            case 7:  dp+=sprintf(db+dp,"cc"); break;
            case 2:  dp+=sprintf(db+dp,"y"); break;
            case 3:  dp+=sprintf(db+dp,"x"); break;
            case 4:  dp+=sprintf(db+dp,"dp"); break;
            case 5:  dp+=sprintf(db+dp,"b"); break;
            case 6:  dp+=sprintf(db+dp,"a"); break;
            default: dp+=sprintf(db+dp,"pc"); break;
          }
          j=1;
        }  
      
      }
      dp+=sprintf(db+dp,"\n"); 
      break;
    
    case RELATIVE:
    
      m0 = get_mem8(pos++);
      dp+=sprintf(db+dp,"$%-.4x\n",(pos+(char)m0)&0xffff);
      break;
     
    case RELATIVE2: 
    
      m0  = get_mem8(pos++)<<8;
      m0 |= get_mem8(pos++);
      dp+=sprintf(db+dp,"$%-.4x\n",(pos+(short)m0)&0xffff);
      break;
    
    case INHERENT: 
    
      dp+=sprintf(db+dp,"\n");
      break;
    
    case INDEXED:
    
      postbyte = get_mem8(pos++);
      
      if(postbyte&0x80)
      {
        switch(postbyte&0x1f)
        {
          case 0x00: /* ,R+       */
            dp+=sprintf(db+dp,",%c+\n",index_reg(postbyte));
            break;
          
          case 0x01: /* ,R++      */
            dp+=sprintf(db+dp,",%c++\n",index_reg(postbyte));
            break;
          
          case 0x11: /* [,R++]    */
            dp+=sprintf(db+dp,"[,%c++]\n",index_reg(postbyte));
            break;
          
          case 0x02: /* ,-R       */
            dp+=sprintf(db+dp,",-%c\n",index_reg(postbyte));
            break;
          
          case 0x03: /* ,--R      */
            dp+=sprintf(db+dp,",--%c\n",index_reg(postbyte));
            break;
          
          case 0x13: /* [,--R]    */
            dp+=sprintf(db+dp,"[,--%c]\n",index_reg(postbyte));
            break;
          
          case 0x04: /* ,R        */
            dp+=sprintf(db+dp,",%c\n",index_reg(postbyte));
            break;
          
          case 0x14: /* [,R]      */
            dp+=sprintf(db+dp,"[,%c]\n",index_reg(postbyte));
            break;
          
          case 0x05: /* B,R       */
            dp+=sprintf(db+dp,"b,%c\n",index_reg(postbyte));
            break;
          
          case 0x15: /* [B,R]     */
            dp+=sprintf(db+dp,"[b,%c]\n",index_reg(postbyte));
            break;
            
          case 0x06: /* A,R       */
            dp+=sprintf(db+dp,"a,%c\n",index_reg(postbyte));
            break;
          
          case 0x16: /* [A,R]     */
            dp+=sprintf(db+dp,"[a,%c]\n",index_reg(postbyte));
            break;
          
          case 0x08: /* 8b,R      */
            m0=get_mem8(pos++);
            dp+=sprintf(db+dp,"$%-.2x,%c\n",(char)m0,index_reg(postbyte));
            break;
          
          case 0x18: /* [8b,R]    */
            m0=get_mem8(pos++);
            dp+=sprintf(db+dp,"[$%-.2x,%c]\n",(char)m0,index_reg(postbyte));
            break;
          
          case 0x09: /* 16b,R     */
            m0  = get_mem8(pos++)<<8;
            m0 |= get_mem8(pos++);
            dp+=sprintf(db+dp,"$%-.4x,%c\n",m0,index_reg(postbyte));
            break;
          
          case 0x19: /* [16b,R]   */
            m0  = get_mem8(pos++)<<8;
            m0 |= get_mem8(pos++);
            dp+=sprintf(db+dp,"[$%-.4x,%c]\n",m0,index_reg(postbyte));
            break;
          
          case 0x0b: /* D,R       */
            dp+=sprintf(db+dp,"d,%c\n",index_reg(postbyte));
            break;
          
          case 0x1b: /* [D,R]     */
            dp+=sprintf(db+dp,"[d,%c]\n",index_reg(postbyte));
            break;
          
          case 0x0c: /* 8b,PC     */
            m0 = get_mem8(pos++);
            dp+=sprintf(db+dp,"$%-.2x,pc\n",(int)pos + (char)m0);
            break;
          
          case 0x1c: /* [8b,PC]   */
            m0 = get_mem8(pos++);
            dp+=sprintf(db+dp,"[$%-.2x,pc]\n",(int)pos + (char)m0);
            break;
          
          case 0x0d: /* 16b,PC    */
            m0  = get_mem8(pos++)<<8;
            m0 |= get_mem8(pos++);
            dp+=sprintf(db+dp,"$%-.4x,pc\n",(int)pos + (short)m0);
            break;
          
          case 0x1d: /* [16b,PC]  */
            m0  = get_mem8(pos++)<<8;
            m0 |= get_mem8(pos++);
            dp+=sprintf(db+dp,"[$%-.4x,pc]\n",(int)pos + (short)m0);
            break;
            
          case 0x1f: /* [16b]     */
            m0  = get_mem8(pos++)<<8;
            m0 |= get_mem8(pos++);
            dp+=sprintf(db+dp,"[$%-.4x]\n",m0);
            break;
            
          default:
            dp+=sprintf(db+dp,"?\n",m0);
            break;
        }
      }
      else
      {
        /* 5b,R */
        if(postbyte&0x10) 
          dp+=sprintf(db+dp,"-%d",((postbyte^0xf)+1)&0xf);
        else
          dp+=sprintf(db+dp,"+%d",postbyte&0xf);
       
        dp+=sprintf(db+dp,",%c\n",index_reg(postbyte));
      } 
      break;
     
    case UNKNOW:   
      dp+=sprintf(db+dp,"%-.2x\n",opc);
      break;
    
    case OPCODE10: 
    case OPCODE11: 
    default:
      printf("error:disassemble: unknown mode %d\n",mode);
      exit(-1);
  }
  
  /* display hexa opcodes */
  
  for(i=0;i<(pos-orig_pos);i++)
  {
    m0=get_mem8(orig_pos+i);
    
    if((m0>>4)>9)
      db[6+3*i]=(m0>>4)-10+'a';
    else
      db[6+3*i]=(m0>>4)+'0';
 
    if((m0&0xf)>9)
      db[6+3*i+1]=(m0&0xf)-10+'a';
    else
      db[6+3*i+1]=(m0&0xf)+'0';
  }
  
  verbose            = orig_verbose;
  display_memtraffic = orig_memtraffic;
  
  COLOR(WHITE);printf(db);COLOR(NORM);
  
  return pos;

}

void display_registers(void)
{
  int i;
  COLOR(a!=pa?RED:NORM); printf(" A=  %-.2x        ",a);  COLOR(NORM);
  COLOR(b!=pb?RED:NORM); printf("B=  %-.2x        ",b);   COLOR(NORM);
  COLOR((a!=pa||b!=pb)?RED:NORM); printf("D=%-.4x\n",(a<<8)|b);    COLOR(NORM);
  COLOR(x!=px?RED:NORM); printf(" X=%-.4x        ",x);    COLOR(NORM);
  COLOR(y!=py?RED:NORM); printf("Y=%-.4x        ",y);     COLOR(NORM);
  COLOR(s!=ps?RED:NORM); printf("S=%-.4x      ",s);       COLOR(NORM);
  COLOR(u!=pu?RED:NORM); printf("U=%-.4x\n",u);           COLOR(NORM);
  COLOR(pc!=ppc?RED:NORM); printf("PC=%-.4x       ",pc);    COLOR(NORM);
  COLOR(dp!=pdp?RED:NORM); printf("DP=  %-.2x       ",dp);  COLOR(NORM);
  COLOR(cc!=pcc?RED:NORM); printf("CC=  %-.2x      ",cc);   COLOR(NORM);
  
  for(i=7;i>=0;i--)
  {
    if(BTST(cc,i))
    {
      if( BTST(cc,i)!=BTST(pcc,i))
      {
        COLOR(RED);
      }
      else
      {
        COLOR(NORM);
      }
      switch(i)
      {
        case  7: printf("E");break; 
        case  6: printf("F");break; 
        case  5: printf("H");break; 
        case  4: printf("I");break; 
        case  3: printf("N");break; 
        case  2: printf("Z");break; 
        case  1: printf("V");break; 
        default: printf("C");break;
      }
    }
    else
    {
      if( BTST(cc,i)!=BTST(pcc,i))
      {
        COLOR(RED);
      }
      else
      {
        COLOR(NORM);
      }
      printf(".");
    }
    COLOR(NORM);
  }
  printf("\n");
}

void display_registers_change(void)
{
  if(ppc!=pc)
  {
    printf("PC=%-.4X ",pc);
  }

  if(pa!=a)
  {
    printf("A=%-.2X ",a);
  }

  if(pb!=b)
  {
    printf("B=%-.2X ",b);
  }

  if(px!=x)
  {
    printf("X=%-.4X ",x);
  }

  if(py!=y)
  {
    printf("Y=%-.4X ",y);
  }

  if(pu!=u)
  {
    printf("U=%-.4X ",u);
  }

  if(ps!=s)
  {
    printf("S=%-.4X ",s);
  }
  
  if(pdp!=dp)
  {
    printf("DP=%-.2X ",dp);
  }
 
  if(pcc!=cc)
  {
    printf("CC=%-.2X ",cc);
  }
  printf("\n");
}

unsigned get_instr_cycles(unsigned int prog_pointer)
{
  unsigned int orig_verbose,orig_memtraffic;
  unsigned int op1,opc_type,opc,mode,instr_cycles,postcode,i;
  unsigned int (*exec)(unsigned int,unsigned int); 

  /* save options */
  orig_verbose         = verbose;
  orig_memtraffic      = display_memtraffic;
  
  verbose            = 0;
  display_memtraffic = 0;
  postcode           = 0xff;
  
  /* compute number of cycles */
  opc = get_mem8(prog_pointer);                                                   
  if(opcode[opc].mode==OPCODE10)                                          
  {                                                                       
    opc_type = 10;
    opc      = get_mem8(prog_pointer+1);                                                
    mode     = opcode10[opc].mode;                                            
    op1      = opcode10[opc].op1; 
    exec     = (void*)0;                       
                                                                          
    if(mode==UNKNOW)                                                      
    {                                                                     
      printf("mtpack_new_instr:unknown instruction pc=%-.4x!\n",prog_pointer);             
      exit(-1);                                                           
    }                                                                     
   
    postcode     = get_mem8(prog_pointer+2); 
    instr_cycles = opcode10[opc].cycle;  
  }                                                                       
  else if(opcode[opc].mode==OPCODE11)                                     
  {                                                                       
    opc_type = 11;
    opc      = get_mem8(prog_pointer+1);                                       
    mode     = opcode11[opc].mode;                                            
    op1      = opcode11[opc].op1;                        
    exec     = (void*)0;                       
                                                                          
    if(mode==UNKNOW)                                                      
    {                                                                     
      printf("mtpack_new_instr:unknown instruction pc=%-.4x!\n",prog_pointer);             
      exit(-1);                                                           
    }                                                                     
   
    postcode     = get_mem8(prog_pointer+2); 
    instr_cycles = opcode11[opc].cycle;                                  
  }                                                                       
  else if(opcode[opc].mode==UNKNOW)                                       
  {                                                                       
    printf("mtpack_new_instr:unknown instruction pc=%-.4x!\n",prog_pointer);             
    exit(-1);                                                             
  }                                                                       
  else                                                                    
  {                                                                       
    opc_type     = 0;
    mode         = opcode[opc].mode;                                        
    op1          = opcode[opc].op1;                    
    postcode     = get_mem8(prog_pointer+1); 
    instr_cycles = opcode[opc].cycle;                                    
    exec         = opcode[opc].exec_opcode;                   
  }                                                                       
  
  switch(mode)
  {
    case INDEXED:
  
      if(!(postcode&0x80))
      {
        /* non-indirect 5b offset*/
        instr_cycles++;
      }
      else
      {
        switch(postcode&0x1f)
        {
          case 0x04: /* ,R */
            
            break;
            
          case 0x08: /* 8b,R */
            
            instr_cycles++;
            break;
          
          case 0x09: /* 16b,R */
            
            instr_cycles+=4;
            break;

          case 0x06: /* A,R */
          case 0x05: /* B,R */
            
            instr_cycles+=1;
            break;
         
          case 0x0b: /* D,R */
            
            instr_cycles+=4;
            break;
 
          case 0x00: /* ,R+ */
            
            instr_cycles+=2;
            break;
    
          case 0x01: /* ,R++ */
            
            instr_cycles+=3;
            break;

          case 0x02: /* ,-R */
            
            instr_cycles+=2;
            break;

          case 0x03: /* ,--R */
            
            instr_cycles+=3;
            break;
        
          case 0x0c: /* 8b,PC */
            
            instr_cycles+=1;
            break;

          case 0x0d: /* 16b,PC */
            
            instr_cycles+=5;
            break;

          case 0x14: /* [,R] */
            
            instr_cycles+=3;
            break;
         
          case 0x18: /* [8b,R] */
            
            instr_cycles+=4;
            break;
            
          case 0x19: /* [16b,R] */
            
            instr_cycles+=7;
            break;

          case 0x16: /* [A,R] */
          case 0x15: /* [B,R] */
            
            instr_cycles+=4;
            break;

          case 0x1b: /* [D,R] */
            
            instr_cycles+=7;
            break;
          
          case 0x11: /* [,R++] */
            
            instr_cycles+=6;
            break;

          case 0x13: /* [,--R] */
            
            instr_cycles+=6;
            break;

          case 0x1c: /* [8b,PC] */
            
            instr_cycles+=4;
            break;

          case 0x1d: /* [16b,PC] */
            
            instr_cycles+=8;
            break;
          
          case 0x1f: /* [n] */
            
            instr_cycles+=5;
            break;
            
          default:
          
            printf("mtpack_new_instr:unknown postcode pc=%-.4x!\n",prog_pointer);  
            exit(-1);   
        } 
      }             
      break;
    
    case INHERENT3U:
    case INHERENT3S:
    
      for(i=0;i<8;i++)                           
      {                                           
        if(BTST(postcode,i))                      
        {                                         
          switch(i)                               
          {                                       
            case 0: instr_cycles++;  break;       
            case 1: instr_cycles++;  break;       
            case 2: instr_cycles++;  break;       
            case 3: instr_cycles++;  break;       
            case 4: instr_cycles+=2; break;       
            case 5: instr_cycles+=2; break;       
            case 6: instr_cycles+=2; break;       
            default:instr_cycles+=2; break;       
          }                                       
        }                                         
      }     
      break;                                      
    
    case INHERENT:
        
      if(exec==exec_rti)     
      {                      
        if(BTST(cc,E))       
        {                    
          instr_cycles+=13;  
        }                    
        else                 
        {                    
          instr_cycles+=4;   
        }                    
      }                      
      break;
    
    case RELATIVE2:
    
      switch(op1)                                                                                                                        
      {                                                                                                                                  
        case RA: /* 1     */     break;                                                                                                  
        case RN: /* 0     */     break;                                                                                                  
        case HI: /* C|Z=0 */     if(!(BTST(cc,Z) || BTST(cc,C))) instr_cycles++; break;                                                  
        case LS: /* C|Z=1 */     if(  BTST(cc,Z) || BTST(cc,C)) instr_cycles++; break;                                                   
        case HS: /* C=0   */     if(!BTST(cc,C)) instr_cycles++; break;                                                                  
        case CS: /* C=1   */     if( BTST(cc,C)) instr_cycles++; break;                                                                  
        case NE: /* Z=0   */     if(!BTST(cc,Z)) instr_cycles++; break;                                                                  
        case EQ: /* Z=1   */     if( BTST(cc,Z)) instr_cycles++; break;                                                                  
        case VC: /* V=0   */     if(!BTST(cc,V)) instr_cycles++; break;                                                                  
        case VS: /* V=1   */     if( BTST(cc,V)) instr_cycles++; break;                                                                  
        case PL: /* N=0   */     if(!BTST(cc,N)) instr_cycles++; break;                                                                  
        case MI: /* N=1   */     if( BTST(cc,N)) instr_cycles++; break;                                                                  
        case GE: /* N^V=0 */     if(!((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V)))) instr_cycles++; break;                  
        case LT: /* N^V=1 */     if((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V))) instr_cycles++; break;                     
        case GT: /* Z|(N^V)=0 */ if(!(BTST(cc,Z)||((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V))))) instr_cycles++; break;    
        case LE: /* Z|(N^V)=1 */ if(BTST(cc,Z)||((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V)))) instr_cycles++; break;       
        default: break;                                                                                                                         
      }                                                                                                                                 
      break;
      
    default:
    
      break;
  }
  
  /* restore options */
  verbose            = orig_verbose;
  display_memtraffic = orig_memtraffic;

  return instr_cycles;
}
