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

unsigned int nmi_armed=0,nmi_active=0;
unsigned int nmi_resync=0,irq_resync=0,fiq_resync=0;

/*********************************************************************
* ABX
*********************************************************************/
unsigned int exec_abx(unsigned int mode,unsigned int op1)
{
  get_mem8(pc); /* emulate prefetch during decode */
  x  = (b  + x)&0xffff;
  return 0;
}

/*********************************************************************
* NOP
*********************************************************************/
unsigned int exec_nop(unsigned int mode,unsigned int op1)
{
  get_mem8(pc); /* emulate prefetch during decode */
  return 0;
}

/*********************************************************************
* LD
*********************************************************************/
unsigned int exec_ld(unsigned int mode,unsigned int op1)
{
  unsigned int ea,tmp;
  
  ea = get_ea(mode);
  
  switch(op1)
  {
    case A: 
    
      a   = alu(get_mem8(ea),0,ASSIGN8);
      break;
      
    case B: 
      
      b   = alu(get_mem8(ea),0,ASSIGN8); 
      break; 
      
    case D: 
    
      tmp = alu(get_mem16(mode,ea),0,ASSIGN16); 
      a   = tmp>>8 ; 
      b   = tmp&0xff ; 
      break;
      
    case X: 
    
      x   = alu(get_mem16(mode,ea),0,ASSIGN16);
      break;
      
    case Y: 
    
      y   = alu(get_mem16(mode,ea),0,ASSIGN16);
      break;
      
    case U: 
    
      u   = alu(get_mem16(mode,ea),0,ASSIGN16); 
      break;
    
    case S: 
    
      nmi_armed = 1;
      s   = alu(get_mem16(mode,ea),0,ASSIGN16);
      break;
   
    default:
      printf("exec_ld:invalid op1 %d!\n",op1);
      exit(-1);    
  }
  return 0;
}  
/*********************************************************************
* ST
*********************************************************************/
unsigned int exec_st(unsigned int mode,unsigned int op1)
{
  unsigned int ea,tmp;
  
  ea = get_ea(mode);
  
  switch(op1)
  {
    case A:  
    
      put_mem8(ea,alu(a,0,ASSIGN8));
      break;
      
    case B: 
      
      put_mem8(ea,alu(b,0,ASSIGN8));
      break; 
      
    case D: 
    
      put_mem16(mode,ea,alu((a<<8)|b,0,ASSIGN16));
      break;
      
    case X: 
    
      put_mem16(mode,ea,alu(x,0,ASSIGN16));
      break;
      
    case Y: 
    
      put_mem16(mode,ea,alu(y,0,ASSIGN16));
      break;
      
    case U: 
    
      put_mem16(mode,ea,alu(u,0,ASSIGN16));
      break;
    
    case S: 
    
      put_mem16(mode,ea,alu(s,0,ASSIGN16));
      break;
   
    default:
      printf("exec_st:invalid op1 %d!\n",op1);
      exit(-1);    
  }
  return 0;
}
/*********************************************************************
* TFR
*********************************************************************/
unsigned int exec_tfr(unsigned int mode,unsigned int op1)
{
  unsigned int tmp,postbyte;
  
  postbyte = get_mem8(pc);
  pc       = (pc + 1)&0xffff;
  
  if((BTST(postbyte,7)&& !BTST(postbyte,3))||(!BTST(postbyte,7)&& BTST(postbyte,3)))
  {
    printf("exec_tfr: registers must have the same size !\n");
    exit(-1);    
  }
  
  switch(postbyte>>4)
  {
    case 0x0: tmp = (a<<8) | b; break;
    case 0x1: tmp = x ; break;
    case 0x2: tmp = y ; break; 
    case 0x3: tmp = u ; break;
    case 0x4: tmp = s ; break;
    case 0x5: tmp = pc; break;
    case 0x8: tmp = a ; break;
    case 0x9: tmp = b ; break;
    case 0xa: tmp = cc; break;
    case 0xb: tmp = dp; break;
    default:
      printf("exec_tfr: unknown source register !\n");
      exit(-1); 
  }
 
  switch(postbyte&0x0f)
  {
    case 0x0: a  = (tmp>>8); b = tmp&0xff; break;
    case 0x1: x  = tmp; break;
    case 0x2: y  = tmp; break;
    case 0x3: u  = tmp; break;
    case 0x4: s  = tmp; break;
    case 0x5: pc = tmp; break;
    case 0x8: a  = tmp; break;
    case 0x9: b  = tmp; break;
    case 0xa: cc = tmp; break; 
    case 0xb: dp = tmp; break;
    default:
      printf("exec_tfr: unknown destination register !\n");
      exit(-1); 
  }
  return 0;
}    

/*********************************************************************
* CMP
*********************************************************************/
unsigned int exec_cmp(unsigned int mode,unsigned int op1)
{
  unsigned int ea,res;
  
  ea = get_ea(mode);
  
  switch(op1)
  {
     case A: alu(a,get_mem8(ea),MINUS8); break;
     case B: alu(b,get_mem8(ea),MINUS8); break;
     case D: alu((a<<8)|b,get_mem16(mode,ea),MINUS16); break;
     case X: alu(x,get_mem16(mode,ea),MINUS16); break;
     case Y: alu(y,get_mem16(mode,ea),MINUS16); break;
     case U: alu(u,get_mem16(mode,ea),MINUS16); break;
     case S: alu(s,get_mem16(mode,ea),MINUS16); break;
     default:
       printf("exec_cmp: invalid op1 %d!\n",op1);
       exit(-1);
  }  
  
  return 0;
}  

/*********************************************************************
* B
*********************************************************************/
unsigned int exec_b(unsigned int mode,unsigned int op1)
{
  unsigned int take,offset;
  
  offset = get_mem8(pc);
  pc     = (pc + 1)&0xffff;
  
  take = 0;
  switch(op1)
  {
    case RA: /* 1     */     take=1; break;
    case RN: /* 0     */     break;
    case HI: /* C|Z=0 */     if(!(BTST(cc,Z) || BTST(cc,C))) take=1; break;
    case LS: /* C|Z=1 */     if(  BTST(cc,Z) || BTST(cc,C)) take=1; break;
    case HS: /* C=0   */     if(!BTST(cc,C)) take=1; break;
    case CS: /* C=1   */     if( BTST(cc,C)) take=1; break;
    case NE: /* Z=0   */     if(!BTST(cc,Z)) take=1; break;
    case EQ: /* Z=1   */     if( BTST(cc,Z)) take=1; break;
    case VC: /* V=0   */     if(!BTST(cc,V)) take=1; break;
    case VS: /* V=1   */     if( BTST(cc,V)) take=1; break;
    case PL: /* N=0   */     if(!BTST(cc,N)) take=1; break;
    case MI: /* N=1   */     if( BTST(cc,N)) take=1; break;
    case GE: /* N^V=0 */     if(!((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V)))) take=1; break;
    case LT: /* N^V=1 */     if((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V))) take=1; break;
    case GT: /* Z|(N^V)=0 */ if(!(BTST(cc,Z)||((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V))))) take=1; break;
    case LE: /* Z|(N^V)=1 */ if(BTST(cc,Z)||((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V)))) take=1; break;
    default:
      printf("exec_b: illegal op1 %d !\n",op1);
      exit(-1);
  } 
  if(take) pc = (pc + (short)(EXT8(offset)))&0xffff; 
  return 0;
}   

/*********************************************************************
* CLR
*********************************************************************/
unsigned int exec_clr(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  

  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a = alu(0,0,CLR); 
      break;
    
    case B: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      b = alu(0,0,CLR); 
      break;
   
    default:
    
      ea = get_ea(mode);
      get_mem8(ea); /* dummy read required by cpu vhdl testsbench */
      put_mem8(ea,alu(0,0,CLR));
      break;
  }

  return 0;
}   

/*********************************************************************
* PUL (read and increment)
*********************************************************************/
unsigned int exec_pul(unsigned int mode,unsigned int op1)
{
  unsigned int postbyte,i,p;
  
  postbyte=get_mem8(pc);
  pc = (pc + 1)&0xffff;
  
  if(op1==U)
  {
    p=u;
  }
  else
  {
    p=s;
  }
  
  for(i=0;i<8;i++)
  {
    if(BTST(postbyte,i))
    {
      switch(i)
      {
        case 0: 

          cc = get_mem8(p); 
          p = (p+1)&0xffff;
          cpu_timestep++;
          break;
          
        case 1:  
        
          a = get_mem8(p); 
          p = (p+1)&0xffff;
          cpu_timestep++;
          break;
          
        case 2:  
        
          b = get_mem8(p); 
          p = (p+1)&0xffff;
          cpu_timestep++;
          break;
          
        case 3: 
        
          dp = get_mem8(p); 
          p = (p+1)&0xffff;
          cpu_timestep++;
          break;
          
        case 4:  
        
          x  = get_mem8(p)<<8;
          p  = (p+1)&0xffff;
          x |= get_mem8(p);
          p  = (p+1)&0xffff;
          cpu_timestep+=2;
          break;
          
        case 5:  
        
          y  = get_mem8(p)<<8;
          p  = (p+1)&0xffff;
          y |= get_mem8(p);
          p  = (p+1)&0xffff;
          cpu_timestep+=2;
          break;
          
        case 6:  
          
          if(op1==U)
          {
            s  = get_mem8(p)<<8;
            p  = (p+1)&0xffff;
            s |= get_mem8(p);
            p  = (p+1)&0xffff;
          }
          else
          {
            u  = get_mem8(p)<<8;
            p  = (p+1)&0xffff;
            u |= get_mem8(p);
            p  = (p+1)&0xffff;
          }
          cpu_timestep+=2;
          break;
          
        default:
        
          pc  = get_mem8(p)<<8;
          p   = (p+1)&0xffff;
          pc |= get_mem8(p);
          p   = (p+1)&0xffff;
          cpu_timestep+=2;
          break;
      }
    }
  }
  
  if(op1==U)
  {
    u=p;
  }
  else
  {
    s=p;
  }
  
  return 0;
}  

/*********************************************************************
* COM
*********************************************************************/
unsigned int exec_com(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  
  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a = alu(a,0,COM8); 
      break;
    
    
    case B: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      b = alu(b,0,COM8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,COM8));
      break;
  }
  return 0;
}  

/*********************************************************************
* ADD
*********************************************************************/
unsigned int exec_add(unsigned int mode,unsigned int op1)
{
  unsigned int ea,tmp;
  
  ea  = get_ea(mode);
  
  switch(op1)
  {
    case A: 
    
      a=alu(a,get_mem8(ea),PLUS8); 
      break;
      
    case B: 
      
      b=alu(b,get_mem8(ea),PLUS8); 
      break;
    
    case D:
   
      tmp=alu((a<<8)|b,get_mem16(mode,ea),PLUS16); 
      a=tmp>>8;
      b=tmp&0xff;
      break;
   
    default:
      printf("exec_addb: illegal op1 %d !\n",op1);
      exit(-1);
  }
  return 0;
}  

/*********************************************************************
* LSR
*********************************************************************/
unsigned int exec_lsr(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  
  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,LSR8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,LSR8); 
      break;
    
    default:
   
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,LSR8));
      break;
  }
  return 0;
}  

/*********************************************************************
* LSL
*********************************************************************/
unsigned int exec_lsl(unsigned int mode,unsigned int op1)
{
  unsigned int ea;

  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,LSL8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,LSL8); 
      break;
    
    default:
   
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,LSL8));
      break;
  }
  return 0;
}  

/*********************************************************************
* JSR
*********************************************************************/
unsigned int exec_jsr(unsigned int mode,unsigned int op1)
{
  unsigned int ea,tmp;
  
  ea  = get_ea(mode);
 
  s = (s - 1)&0xffff;
  put_mem8(s,pc&0xff);
  s = (s - 1)&0xffff;
  put_mem8(s,pc>>8);
  
  pc = ea;
  return 0;  
} 

/*********************************************************************
* OR
*********************************************************************/
unsigned int exec_or(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  
  switch(op1)
  {
    case A: 
    
      a=alu(a,get_mem8(get_ea(mode)),OR8); 
      break;
      
    case B: 
      
      b=alu(b,get_mem8(get_ea(mode)),OR8); 
      break;
    
    default:
      printf("exec_addb: illegal op1 %d !\n",op1);
      exit(-1);
  }
  return 0;
} 

/*********************************************************************
* RTS
*********************************************************************/
unsigned int exec_rts(unsigned int mode,unsigned int op1)
{
  unsigned int tmp;

  get_mem8(pc); /* emulate prefetch during decode */

  tmp  = get_mem8(s)<<8;
  s    = (s + 1)&0xffff;
  tmp |= get_mem8(s);
  s    = (s + 1)&0xffff;
  
  pc = tmp;
  return 0;
}

/*********************************************************************
* JMP
*********************************************************************/
unsigned int exec_jmp(unsigned int mode,unsigned int op1)
{
  pc = get_ea(mode);;
  return 0;  
}  

/*********************************************************************
* BSR
*********************************************************************/
unsigned int exec_bsr(unsigned int mode,unsigned int op1)
{
  unsigned int take,offset;
  
  offset = get_mem8(pc);
  pc     = (pc + 1)&0xffff;

  s = (s - 1)&0xffff;
  put_mem8(s,pc&0xff);
  s = (s - 1)&0xffff;
  put_mem8(s,pc>>8);
  
  pc = (pc + (short)(EXT8(offset)))&0xffff; 
  return 0;
}   

/*********************************************************************
* SWI
*********************************************************************/
unsigned int exec_swi(unsigned int mode,unsigned int op1)
{

  get_mem8(pc); /* emulate prefetch during decode */
  
  SET_CC(E);
 
  s = (s-1)&0xffff;
  put_mem8(s,pc&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,pc>>8);
  
  s = (s-1)&0xffff;
  put_mem8(s,u&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,u>>8);
  
  s = (s-1)&0xffff;
  put_mem8(s,y&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,y>>8);

  s = (s-1)&0xffff;
  put_mem8(s,x&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,x>>8);

  s = (s-1)&0xffff;
  put_mem8(s,dp);

  s = (s-1)&0xffff;
  put_mem8(s,b);
  
  s = (s-1)&0xffff;
  put_mem8(s,a);

  
  s = (s-1)&0xffff;
  put_mem8(s,cc);
  
  
  switch(op1)
  {
    case ONE:
      
      SET_CC(F);
      SET_CC(I);
      pc  = get_mem8(0xfffa)<<8;
      pc |= get_mem8(0xfffb);
      break;
    
    case TWO:
    
      pc  = get_mem8(0xfff4)<<8;
      pc |= get_mem8(0xfff5);
      break;
    
    case THREE:
    
      pc  = get_mem8(0xfff2)<<8;
      pc |= get_mem8(0xfff3);
      break;
    
    default:
      printf("exec_swi: illegal operand %d !\n",op1);
      exit(-1);
  }
  return 0;
}    

/*********************************************************************
* AND
*********************************************************************/
unsigned int exec_and(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  
  switch(op1)
  {
    case A: 
    
      a=alu(a,get_mem8(get_ea(mode)),AND8); 
      break;
      
    case B: 
      
      b=alu(b,get_mem8(get_ea(mode)),AND8); 
      break;
    
    default:
      printf("exec_addb: illegal op1 %d !\n",op1);
      exit(-1);
  }
  return 0;
} 

/*********************************************************************
* PSH (decrement and write)
*********************************************************************/
unsigned int exec_psh(unsigned int mode,unsigned int op1)
{
  unsigned int postbyte,p;
  int          i;
  
  postbyte=get_mem8(pc);
  pc = (pc + 1)&0xffff;
  
  if(op1==U)
  {
    p=u;
  }
  else
  {
    p=s;
  }
  
  for(i=7;i>=0;i--)
  {
    if(BTST(postbyte,i))
    {
      switch(i)
      {
        case 0: 

          p = (p-1)&0xffff;
          put_mem8(p,cc); 
          cpu_timestep++;
          break;
          
        case 1:  
        
          p = (p-1)&0xffff;
          put_mem8(p,a); 
          cpu_timestep++;
          break;
          
        case 2:  
        
          p = (p-1)&0xffff;
          put_mem8(p,b); 
          cpu_timestep++;
          break;
          
        case 3: 
        
          p = (p-1)&0xffff;
          put_mem8(p,dp); 
          cpu_timestep++;
          break;
          
        case 4:  
        
          p = (p - 1)&0xffff; 
          put_mem8(p,x&0xff);
          p = (p - 1)&0xffff; 
          put_mem8(p,x>>8);
          cpu_timestep+=2;
          break;
          
        case 5:  
        
          p = (p - 1)&0xffff; 
          put_mem8(p,y&0xff);
          p = (p - 1)&0xffff; 
          put_mem8(p,y>>8);
          cpu_timestep+=2;
          break;
          
        case 6:  
          
          if(op1==U)
          {
            p = (p - 1)&0xffff; 
            put_mem8(p,s&0xff);
            p = (p - 1)&0xffff; 
            put_mem8(p,s>>8);
          }
          else
          {
            p = (p - 1)&0xffff; 
            put_mem8(p,u&0xff);
            p = (p - 1)&0xffff; 
            put_mem8(p,u>>8);
          }
          cpu_timestep+=2;
          break;
          
        default:
        
          p = (p - 1)&0xffff; 
          put_mem8(p,pc&0xff);
          p = (p - 1)&0xffff; 
          put_mem8(p,pc>>8);
          cpu_timestep+=2;
          break;
      }
    }
  }
  
  if(op1==U)
  {
    u=p;
  }
  else
  {
    s=p;
  }
  
  return 0;
}  

/*********************************************************************
* ORCC
*********************************************************************/
unsigned int exec_orcc(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  ea = get_ea(mode);
  cc = (cc | get_mem8(ea))&0xff;
  return 0;
} 

/*********************************************************************
* ANDCC
*********************************************************************/
unsigned int exec_andcc(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  ea = get_ea(mode);
  cc = (cc & get_mem8(ea))&0xff;
  return 0;
} 

/*********************************************************************
* INC
*********************************************************************/
unsigned int exec_inc(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
    

  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,INC8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,INC8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,INC8));
  }
  return 0;
}  

/*********************************************************************
* LEA
*********************************************************************/
unsigned int exec_lea(unsigned int mode,unsigned int op1)
{
  switch(op1)
  {
    case X: x=alu(get_ea(mode),0,TSTZ);break;
    case Y: y=alu(get_ea(mode),0,TSTZ);break;
    case S: s=get_ea(mode);break;
    case U: u=get_ea(mode);break;
    default:
      printf("exec_lea: illegal op1 %d !\n",op1);
      exit(-1);
  }
  return 0;
}  

/*********************************************************************
* tst
*********************************************************************/
unsigned int exec_tst(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      alu(a,0,TST8); 
      break;
      
    case B: 
     
      get_mem8(pc); /* emulate prefetch during decode */
      alu(b,0,TST8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      alu(get_mem8(ea),0,TST8);
  }
  return 0;
}  

/*********************************************************************
* MUL
*********************************************************************/
unsigned int exec_mul(unsigned int mode,unsigned int op1)
{
  unsigned int tmp;
  
  get_mem8(pc); /* emulate prefetch during decode */
  tmp=alu(a,b,MULT);
  a=tmp>>8;
  b=tmp&0xff;
  return 0;
}  

/*********************************************************************
* ROL
*********************************************************************/
unsigned int exec_rol(unsigned int mode,unsigned int op1)
{
  unsigned int ea;

  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,ROL8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,ROL8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,ROL8));
  }
  return 0;
}  

/*********************************************************************
* LBSR
*********************************************************************/
unsigned int exec_lbsr(unsigned int mode,unsigned int op1)
{
  unsigned int offset;
  
  offset = get_mem16(mode,pc);
  pc     = (pc + 2)&0xffff;

  s = (s - 1)&0xffff;
  put_mem8(s,pc&0xff);
  s = (s - 1)&0xffff;
  put_mem8(s,pc>>8);
  
  pc = (pc + (short)(offset))&0xffff; 
  return 0;
}   

/*********************************************************************
* NEG
*********************************************************************/
unsigned int exec_neg(unsigned int mode,unsigned int op1)
{
  unsigned int ea;

  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,NEG8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,NEG8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,NEG8));
  }
  return 0;
}

/*********************************************************************
* DEC
*********************************************************************/
unsigned int exec_dec(unsigned int mode,unsigned int op1)
{
  unsigned int ea;
  

  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,DEC8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,DEC8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,DEC8));
  }
  return 0;
}  

/*********************************************************************
* BIT
*********************************************************************/
unsigned int exec_bit(unsigned int mode,unsigned int op1)    
{
  unsigned int ea,tmp;
  
  ea=get_ea(mode);
  tmp=get_mem8(ea);
  
  switch(op1)
  {
    case A: 
    
      alu(a,tmp,AND8); 
      break;
      
    case B: 
      
      alu(b,tmp,AND8); 
      break;
    
    default:
      printf("exec_bit: illegal op1 %d !\n",op1);
      exit(-1);
    
  }
  return 0;
}

/*********************************************************************
* LB
*********************************************************************/
unsigned int exec_lb(unsigned int mode,unsigned int op1)
{
  unsigned int take,offset;
  
  offset = get_mem16(mode,pc);
  pc     = (pc + 2)&0xffff;

  take = 0;
  switch(op1)
  {
    case RA: /* 1     */     take=1; break;
    case RN: /* 0     */     break;
    case HI: /* C|Z=0 */     if(!(BTST(cc,Z) || BTST(cc,C))) take=1; break;
    case LS: /* C|Z=1 */     if(  BTST(cc,Z) || BTST(cc,C)) take=1; break;
    case HS: /* C=0   */     if(!BTST(cc,C)) take=1; break;
    case CS: /* C=1   */     if( BTST(cc,C)) take=1; break;
    case NE: /* Z=0   */     if(!BTST(cc,Z)) take=1; break;
    case EQ: /* Z=1   */     if( BTST(cc,Z)) take=1; break;
    case VC: /* V=0   */     if(!BTST(cc,V)) take=1; break;
    case VS: /* V=1   */     if( BTST(cc,V)) take=1; break;
    case PL: /* N=0   */     if(!BTST(cc,N)) take=1; break;
    case MI: /* N=1   */     if( BTST(cc,N)) take=1; break;
    case GE: /* N^V=0 */     if(!((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V)))) take=1; break;
    case LT: /* N^V=1 */     if((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V))) take=1; break;
    case GT: /* Z|(N^V)=0 */ if(!(BTST(cc,Z)||((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V))))) take=1; break;
    case LE: /* Z|(N^V)=1 */ if(BTST(cc,Z)||((BTST(cc,N) && !BTST(cc,V))||(!BTST(cc,N) && BTST(cc,V)))) take=1; break;
    default:
      printf("exec_lb: illegal op1 %d !\n",op1);
      exit(-1);
  }
  
  if(take) 
  {
    pc = (pc + (short)(offset))&0xffff; 
    
    if(!(op1==RA || op1==RN))
    {
      cpu_timestep++;
    }
  }
  return 0;
}

/*********************************************************************
* SUB
*********************************************************************/
unsigned int exec_sub(unsigned int mode,unsigned int op1)  
{
  unsigned int ea,tmp;
  
  ea = get_ea(mode);
  
  switch(op1)
  {
     case A: a=alu(a,get_mem8(ea),MINUS8); break;
     case B: b=alu(b,get_mem8(ea),MINUS8); break;
     case D: 
     
       tmp=alu((a<<8)|b,get_mem16(mode,ea),MINUS16); 
       a=(tmp>>8)&0xff;
       b=tmp&0xff;
       break;
     
     default:
       printf("exec_sub: invalid op1 %d!\n",op1);
       exit(-1);
  }  
  
  return 0;
}

/*********************************************************************
* RTI
*********************************************************************/
unsigned int exec_rti(unsigned int mode,unsigned int op1)
{
  unsigned int tmp;

  get_mem8(pc); /* emulate prefetch during decode */


  if(nmi_active) nmi_active=0;
  
  cc   = get_mem8(s);
  s    = (s + 1)&0xffff;
  
  if(BTST(cc,E))
  {
    a    = get_mem8(s);
    s    = (s + 1)&0xffff;

    b    = get_mem8(s);
    s    = (s + 1)&0xffff;

    dp   = get_mem8(s);
    s    = (s + 1)&0xffff;
    
    tmp  = get_mem8(s)<<8;
    s    = (s + 1)&0xffff;
    tmp |= get_mem8(s);
    s    = (s + 1)&0xffff;
    x   = tmp;
   
    tmp  = get_mem8(s)<<8;
    s    = (s + 1)&0xffff;
    tmp |= get_mem8(s);
    s    = (s + 1)&0xffff;
    y   = tmp;
    
    tmp  = get_mem8(s)<<8;
    s    = (s + 1)&0xffff;
    tmp |= get_mem8(s);
    s    = (s + 1)&0xffff;
    u   = tmp;
    
    tmp  = get_mem8(s)<<8;
    s    = (s + 1)&0xffff;
    tmp |= get_mem8(s);
    s    = (s + 1)&0xffff;
    pc   = tmp;
    cpu_timestep += 13;
  }
  else
  {
    tmp  = get_mem8(s)<<8;
    s    = (s + 1)&0xffff;
    tmp |= get_mem8(s);
    s    = (s + 1)&0xffff;
    pc   = tmp;
    cpu_timestep += 4;
  }
  return 0;
}

/*********************************************************************
* EXG
*********************************************************************/
unsigned int exec_exg(unsigned int mode,unsigned int op1)
{
  unsigned int tmp,tmp2,postbyte;
  
  postbyte = get_mem8(pc);
  pc       = (pc + 1)&0xffff;
  
  if((BTST(postbyte,7)&& !BTST(postbyte,3))||(!BTST(postbyte,7)&& BTST(postbyte,3)))
  {
    printf("exec_tfr: registers must have the same size !\n");
    exit(-1);    
  }
  
  switch(postbyte>>4)
  {
    case 0x0: tmp = (a<<8) | b; break;
    case 0x1: tmp = x ; break;
    case 0x2: tmp = y ; break; 
    case 0x3: tmp = u ; break;
    case 0x4: tmp = s ; break;
    case 0x5: tmp = pc; break;
    case 0x8: tmp = a ; break;
    case 0x9: tmp = b ; break;
    case 0xa: tmp = cc; break;
    case 0xb: tmp = dp; break;
    default:
      printf("exec_tfr: unknown source register !\n");
      exit(-1); 
  }
 
  switch(postbyte&0x0f)
  {
    case 0x0: tmp2 = (a<<8)|b ; a  = (tmp>>8); b = tmp&0xff; break;
    case 0x1: tmp2 = x  ; x  = tmp; break;      
    case 0x2: tmp2 = y  ; y  = tmp; break;      
    case 0x3: tmp2 = u  ; u  = tmp; break;      
    case 0x4: tmp2 = s  ; s  = tmp; break;      
    case 0x5: tmp2 = pc ; pc = tmp; break;      
    case 0x8: tmp2 = a  ; a  = tmp; break;      
    case 0x9: tmp2 = b  ; b  = tmp; break;      
    case 0xa: tmp2 = cc ; cc = tmp; break;       
    case 0xb: tmp2 = dp ; dp = tmp; break;      
    default:
      printf("exec_tfr: unknown destination register !\n");
      exit(-1); 
  }

  switch(postbyte>>4)
  {
    case 0x0:  a = tmp2>>8 ; b = tmp2&0xff ; break;
    case 0x1:  x  = tmp2 ; break;       
    case 0x2:  y  = tmp2 ; break;       
    case 0x3:  u  = tmp2 ; break;       
    case 0x4:  s  = tmp2 ; break;       
    case 0x5:  pc = tmp2 ; break;       
    case 0x8:  a  = tmp2 ; break;       
    case 0x9:  b  = tmp2 ; break;       
    case 0xa:  cc = tmp2 ; break;       
    case 0xb:  dp = tmp2 ; break;       
    default:
      printf("exec_tfr: unknown source register !\n");
      exit(-1); 
  }

  return 0;
}    

/*********************************************************************
* EOR
*********************************************************************/
unsigned int exec_eor(unsigned int mode,unsigned int op1) 
{
  unsigned int ea,tmp;
  
  ea=get_ea(mode);
  tmp=get_mem8(ea);
  
  switch(op1)
  {
    case A: 
    
      a=alu(a,tmp,EOR8); 
      break;
      
    case B: 
      
      b=alu(b,tmp,EOR8); 
      break;
    
    default:
      printf("exec_bit: illegal op1 %d !\n",op1);
      exit(-1);
    
  }
  return 0;
}

/*********************************************************************
* ROR
*********************************************************************/
unsigned int exec_ror(unsigned int mode,unsigned int op1)  
{
  unsigned int ea;

  
  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,ROR8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,ROR8); 
      break;
    
    default:
    
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,ROR8));
  }
  return 0;
}  

/*********************************************************************
* ADC
*********************************************************************/
unsigned int exec_adc(unsigned int mode,unsigned int op1) 
{
  unsigned int ea,tmp;
  
  ea=get_ea(mode);
  tmp=get_mem8(ea);
  
  switch(op1)
  {
    case A: 
    
      a=alu(a,tmp,PLUS8C); 
      break;
      
    case B: 
      
      b=alu(b,tmp,PLUS8C); 
      break;
    
    default:
      printf("exec_bit: illegal op1 %d !\n",op1);
      exit(-1);
    
  }
  return 0;
}

/*********************************************************************
* SBC
*********************************************************************/
unsigned int exec_sbc(unsigned int mode,unsigned int op1)
{
  unsigned int ea,tmp;
  
  ea=get_ea(mode);
  tmp=get_mem8(ea);
  
  switch(op1)
  {
    case A: 
    
      a=alu(a,tmp,MINUS8C); 
      break;
      
    case B: 
      
      b=alu(b,tmp,MINUS8C); 
      break;
    
    default:
      printf("exec_bit: illegal op1 %d !\n",op1);
      exit(-1);
    
  }
  return 0;
} 

/*********************************************************************
* ASR
*********************************************************************/
unsigned int exec_asr(unsigned int mode,unsigned int op1)   
{
  unsigned int ea;

  switch(op1)
  {
    case A: 
    
      get_mem8(pc); /* emulate prefetch during decode */
      a=alu(a,0,ASR8); 
      break;
      
    case B: 
      
      get_mem8(pc); /* emulate prefetch during decode */
      b=alu(b,0,ASR8); 
      break;
    
    default:
   
      ea = get_ea(mode);
      put_mem8(ea,alu(get_mem8(ea),0,ASR8));
      break;
  }
  return 0;
}  

/*********************************************************************
* SEX
*********************************************************************/
unsigned int exec_sex(unsigned int mode,unsigned int op1)
{
  get_mem8(pc); /* emulate prefetch during decode */
  a=alu(b,0,SEX8);
  return 0;
}

/*********************************************************************
* DAA
*********************************************************************/
unsigned int exec_daa(unsigned int mode,unsigned int op1)
{
  get_mem8(pc); /* emulate prefetch during decode */
  a=alu(a,0,DADJ8);
  return 0;
}  

/*********************************************************************
* SYNC
*********************************************************************/
unsigned int exec_sync(unsigned int mode,unsigned int op1)
{
  get_mem8(pc); /* emulate prefetch during decode */
  wait_for_interrupt=1;
  return 0;
}  

unsigned int exec_cwai(unsigned int mode,unsigned int op1){return -1;}  
unsigned int exec_unknow(unsigned int mode,unsigned int op1){return -1;} 

/*********************************************************************
*
* Effective Address extraction
*
*********************************************************************/
unsigned int get_ea(unsigned int mode)
{
  unsigned int ea,tmp,postbyte;
  
  switch(mode)
  {
    case IMMEDIATE8:
    
      ea = pc;
      pc = (pc + 1)&0xffff;
      break;
    
    case IMMEDIATE16:
    
      ea = pc;
      pc = (pc + 2)&0xffff;
      break;
    
    case DIRECT:
    
      ea = (dp<<8)|get_mem8(pc++);
      break;
    
    case EXTENDED:
    
      ea = get_mem16(mode,pc);
      pc = (pc + 2)&0xffff;
      break;
    
    case INDEXED:
    
      postbyte = get_mem8(pc++);
      
      if(BTST(postbyte,7))
      {
        switch(postbyte&0x1f)
        {
          case 0x00: /* ,R+       */
           
            cpu_timestep += 2;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = s; 
                s  = (s+1)&0xffff; 
              }
              else
              {  
                ea = u; 
                u  = (u+1)&0xffff; 
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = y;  
                y  = (y+1)&0xffff;
              }
              else
              {
                ea = x;
                x  = (x+1)&0xffff; 
              }
            }
            break;
          
          case 0x01: /* ,R++      */
            
            cpu_timestep += 3;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea  = s;  
                s   = (s + 2)&0xffff;
              }
              else
              {  
                ea  = u;  
                u   = (u + 2)&0xffff;
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = y;  
                y  = (y + 2)&0xffff;
              }
              else
              {
                ea = x; 
                x  = (x + 2)&0xffff;
              }
            }
            break;
         
          case 0x11: /* [,R++]    */
           
            cpu_timestep += 6;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = s;  
                s   = (s+2)&0xffff;
              }
              else
              {  
                tmp = u;  
                u   = (u+2)&0xffff;
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = y;  
                y  = (y + 2)&0xffff;
              }
              else
              {
                tmp = x; 
                x  = (x + 2)&0xffff;
              }
            }
            
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x02: /* ,-R       */
           
            cpu_timestep += 2;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                s  = (s-1)&0xffff;
                ea = s;  
              }
              else
              {  
                u  = (u-1)&0xffff;
                ea = u;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                y  = (y-1)&0xffff;
                ea = y;  
              }
              else
              {
                x  = (x-1)&0xffff;
                ea = x; 
              }
            }
            break;
          
          case 0x03: /* ,--R      */
            
            cpu_timestep += 3;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                s  = (s-2)&0xffff;
                ea = s;  
              }
              else
              {  
                u  = (u-2)&0xffff;
                ea = u;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                y  = (y-2)&0xffff;
                ea = y;  
              }
              else
              {
                x  = (x-2)&0xffff;
                ea = x; 
              }
            }
            break;
          
          case 0x13: /* [,--R]    */
           
            cpu_timestep += 6;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                s  = (s-2)&0xffff;
                tmp= s;  
              }
              else
              {  
                u  = (u-2)&0xffff;
                tmp= u;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                y  = (y-2)&0xffff;
                tmp= y;  
              }
              else
              {
                x  = (x-2)&0xffff;
                tmp= x; 
              }
            }
            
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x04: /* ,R        */
            
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = s;  
              }
              else
              {  
                ea = u;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = y;  
              }
              else
              {
                ea = x; 
              }
            }
            break;
          
          case 0x14: /* [,R]      */
            
            cpu_timestep += 3;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = s;  
              }
              else
              {  
                tmp = u;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = y;  
              }
              else
              {
                tmp = x; 
              }
            }            
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x05: /* B,R       */
            
            cpu_timestep += 1;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = (s + (char)b)&0xffff;  
              }
              else
              {  
                ea = (u + (char)b)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = (y + (char)b)&0xffff;  
              }
              else
              {
                ea = (x + (char)b)&0xffff; 
              }
            }           
            break;
          
          case 0x15: /* [B,R]     */

            cpu_timestep += 4;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = (s + (char)b)&0xffff;  
              }
              else
              {  
                tmp = (u + (char)b)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = (y + (char)b)&0xffff;  
              }
              else
              {
                tmp = (x + (char)b)&0xffff; 
              }
            }           
            
            ea  = get_mem16(mode,tmp);
            break;
            
          case 0x06: /* A,R       */

            cpu_timestep += 1;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = (s + (char)a)&0xffff;  
              }
              else
              {  
                ea = (u + (char)a)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = (y + (char)a)&0xffff;  
              }
              else
              {
                ea = (x + (char)a)&0xffff; 
              }
            }           
            break;          
          
          case 0x16: /* [A,R]     */
            
            cpu_timestep += 4;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = (s + (char)a)&0xffff;  
              }
              else
              {  
                tmp = (u + (char)a)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = (y + (char)a)&0xffff;  
              }
              else
              {
                tmp = (x + (char)a)&0xffff; 
              }
            }           
            
            ea  = get_mem16(mode,tmp);
            break;
                      
          case 0x08: /* 8b,R      */
            
            cpu_timestep += 1;
            tmp=get_mem8(pc++);
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = (s+(char)tmp)&0xffff;  
              }
              else
              {  
                ea = (u+(char)tmp)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = (y+(char)tmp)&0xffff;  
              }
              else
              {
                ea = (x+(char)tmp)&0xffff; 
              }
            }
            break;
           
          case 0x18: /* [8b,R]    */
            
            cpu_timestep += 4;
            tmp=get_mem8(pc++);
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = (s+(char)tmp)&0xffff;  
              }
              else
              {  
                tmp = (u+(char)tmp)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = (y+(char)tmp)&0xffff;  
              }
              else
              {
                tmp = (x+(char)tmp)&0xffff; 
              }
            }
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x09: /* 16b,R     */
            
            cpu_timestep += 4;
            tmp  = get_mem16(mode,pc);
            pc   = pc + 2;

            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = (s+(short)tmp)&0xffff;  
              }
              else
              {  
                ea = (u+(short)tmp)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = (y+(short)tmp)&0xffff;  
              }
              else
              {
                ea = (x+(short)tmp)&0xffff; 
              }
            }
            break;
          
          case 0x19: /* [16b,R]   */
            
            cpu_timestep += 7;
            tmp  = get_mem16(mode,pc);
            pc   = (pc + 2)&0xffff;
            
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = (s+(short)tmp)&0xffff;  
              }
              else
              {  
                tmp = (u+(short)tmp)&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = (y+(short)tmp)&0xffff;  
              }
              else
              {
                tmp = (x+(short)tmp)&0xffff; 
              }
            }
            
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x0b: /* D,R       */
           
            cpu_timestep += 4;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                ea = (s + (short)((a<<8)|b))&0xffff;  
              }
              else
              {  
                ea = (u + (short)((a<<8)|b))&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                ea = (y + (short)((a<<8)|b))&0xffff;  
              }
              else
              {
                ea = (x + (short)((a<<8)|b))&0xffff; 
              }
            }           
            break;
          
          case 0x1b: /* [D,R]     */
            
            cpu_timestep += 7;
            if(BTST(postbyte,6))
            {
              if(BTST(postbyte,5))
              {  
                tmp = (s + (short)((a<<8)|b))&0xffff;  
              }
              else
              {  
                tmp = (u + (short)((a<<8)|b))&0xffff;  
              }
            }
            else
            {
              if(BTST(postbyte,5))
              {  
                tmp = (y + (short)((a<<8)|b))&0xffff;  
              }
              else
              {
                tmp = (x + (short)((a<<8)|b))&0xffff; 
              }
            }           
         
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x0c: /* 8b,PC     */
            cpu_timestep += 1;
            tmp = get_mem8(pc++);
            ea = ((int)pc + (char)tmp)&0xffff;
            break;
          
          case 0x1c: /* [8b,PC]   */
            cpu_timestep += 4;
            tmp = get_mem8(pc++);
            tmp = ((int)pc + (char)tmp)&0xffff;
            ea  = get_mem16(mode,tmp);
            break;
          
          case 0x0d: /* 16b,PC    */
            cpu_timestep += 5;
            tmp  = get_mem16(mode,pc);
            pc   = (pc + 2)&0xffff;
            ea   = (int)pc + (short)tmp;
            break;
          
          case 0x1d: /* [16b,PC]  */
            cpu_timestep += 8;
            tmp  = get_mem16(mode,pc);
            pc   = (pc + 2)&0xffff;
            tmp  = ((int)pc + (short)tmp)&0xffff;
            ea  = get_mem16(mode,tmp);
            break;
            
          case 0x1f: /* [16b]     */
            cpu_timestep += 5;
            tmp  = get_mem16(mode,pc);
            pc   = (pc + 2)&0xffff;
            ea  = get_mem16(mode,tmp);
            break;
            
          default:
            printf("error:get_ea: incompatible mode for effective address (%d)!\n",mode);
            exit(-1);
        }
      }
      else
      {
        /* 5b,R */
        cpu_timestep += 1;
        
        if(BTST(postbyte,4))
        {
          tmp = postbyte|0xe0;
        }
        else
        {
          tmp = postbyte&0x0f;
        }
        
        if(BTST(postbyte,6))          
        {                          
          if(BTST(postbyte,5))        
          {                        
            ea = (s+(char)tmp)&0xffff;      
          }                        
          else                     
          {                        
            ea = (u+(char)tmp)&0xffff;      
          }                        
        }                          
        else                       
        {                          
          if(BTST(postbyte,5))        
          {                        
            ea = (y+(char)tmp)&0xffff;      
          }                        
          else                     
          {                        
            ea = (x+(char)tmp)&0xffff;      
          }                        
        }                          
        break;                     
      } 
      break;
    
    
    default:
      printf("error:get_ea: incompatible mode for effective address (%d)!\n",mode);
      exit(-1);
  }
  return ea;
}

/*********************************************************************
*
* 6809 instruction execution
*
*********************************************************************/
void enter_reset(void)
{
  if(verbose)
  {
    COLOR(GREEN);
    printf("Entering in RESET\n");
    COLOR(NORM);
  }
  
  nmi_armed = 0 ;
  cc        = 0x50;
  a         = 0x00; 
  b         = 0x00;
  x         = 0x0000;
  y         = 0x0000;
  s         = 0x0000;
  dp        = 0x0000;
  pc  = get_mem8(0xfffe)<<8;
  pc |= get_mem8(0xffff)&0xff;
}

void enter_nmi(void)
{
  if(!nmi_active)
  {
    if(verbose)
    {
      COLOR(GREEN);
      printf("Entering in NMI\n");
      COLOR(NORM);
    }
  
    nmi_active = 1;
    wait_for_interrupt=0;
  
    SET_CC(E);
  
    s = (s-1)&0xffff;
    put_mem8(s,pc&0xff);
    s = (s-1)&0xffff;
    put_mem8(s,pc>>8);
  
    s = (s-1)&0xffff;
    put_mem8(s,u&0xff);
    s = (s-1)&0xffff;
    put_mem8(s,u>>8);
  
    s = (s-1)&0xffff;
    put_mem8(s,y&0xff);
    s = (s-1)&0xffff;
    put_mem8(s,y>>8);

    s = (s-1)&0xffff;
    put_mem8(s,x&0xff);
    s = (s-1)&0xffff;
    put_mem8(s,x>>8);

    s = (s-1)&0xffff;
    put_mem8(s,dp);

    s = (s-1)&0xffff;
    put_mem8(s,b);
  
    s = (s-1)&0xffff;
    put_mem8(s,a);

    s = (s-1)&0xffff;
    put_mem8(s,cc);
  
    SET_CC(I);
    SET_CC(F);
  
    pc  = get_mem8(0xfffc)<<8;
    pc |= get_mem8(0xfffd)&0xff;
  }
}

void enter_irq(void)
{

  if(verbose)
  {
    COLOR(GREEN);
    printf("Entering in IRQ\n");
    COLOR(NORM);
  }

  wait_for_interrupt=0;

  SET_CC(E);
  
  s = (s-1)&0xffff;
  put_mem8(s,pc&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,pc>>8);
  
  s = (s-1)&0xffff;
  put_mem8(s,u&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,u>>8);
  
  s = (s-1)&0xffff;
  put_mem8(s,y&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,y>>8);

  s = (s-1)&0xffff;
  put_mem8(s,x&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,x>>8);

  s = (s-1)&0xffff;
  put_mem8(s,dp);

  s = (s-1)&0xffff;
  put_mem8(s,b);
  
  s = (s-1)&0xffff;
  put_mem8(s,a);

  s = (s-1)&0xffff;
  put_mem8(s,cc);
  
  SET_CC(I);
  
  pc  = get_mem8(0xfff8)<<8;
  pc |= get_mem8(0xfff9)&0xff;
}

void enter_fiq(void)
{
  if(verbose)
  {
    COLOR(GREEN);
    printf("Entering in FIQ\n");
    COLOR(NORM);
  }

  wait_for_interrupt=0;

  CLEAR_CC(E);
  
  s = (s-1)&0xffff;
  put_mem8(s,pc&0xff);
  s = (s-1)&0xffff;
  put_mem8(s,pc>>8);
  
  s = (s-1)&0xffff;
  put_mem8(s,cc);
  
  SET_CC(F); 
  SET_CC(I); 
  
  pc  = get_mem8(0xfff6)<<8;
  pc |= get_mem8(0xfff7)&0xff;
}


void scan_interrupt(unsigned int reset,unsigned int nmi,unsigned int irq,unsigned int fiq)
{
  /* test event */
  if(reset)
    enter_reset();
  else if(nmi_resync && nmi_armed && !nmi_active)
    enter_nmi();
  else if(fiq_resync && (!BTST(cc,F) || wait_for_interrupt))
    enter_fiq();
  else if(irq_resync && (!BTST(cc,I) || wait_for_interrupt))
    enter_irq();
    
  nmi_resync=nmi;
  fiq_resync=fiq;
  irq_resync=irq;
}

void execute(void)
{
  unsigned int  opc,mode,op1,(*exec)(unsigned int,unsigned int);
  
  if(!wait_for_interrupt)
  {
    /* fetch opcodes */
    opc = get_mem8(pc++);                                     
    if(opcode[opc].mode==OPCODE10)                            
    {                                                         
      opc  = get_mem8(pc++);                                  
      mode = opcode10[opc].mode;                              
      
      if(mode==UNKNOW)
      {                                                         
        printf("execute:unknown instruction pc=%-.4x!\n",pc-2);           
        exit(-1);                                               
      }                                                         
      
      op1           = opcode10[opc].op1;                               
      exec          = opcode10[opc].exec_opcode;
      cpu_timestep += opcode10[opc].cycle;                       
    }                                                         
    else if(opcode[opc].mode==OPCODE11)                       
    {                                                         
      opc           = get_mem8(pc++);                         
      mode          = opcode11[opc].mode;                     
      
      if(mode==UNKNOW)
      {                                                         
        printf("execute:unknown instruction pc=%-.4x!\n",pc-2);           
        exit(-1);                                               
      }                                                         
      
      op1  = opcode11[opc].op1;                               
      exec = opcode11[opc].exec_opcode;                       
      cpu_timestep += opcode11[opc].cycle;                       
    }                                                         
    else if(opcode[opc].mode==UNKNOW)                         
    {                                                         
        printf("execute:unknown instruction pc=%-.4x!\n",pc-1);           
      exit(-1);                                               
    }                                                         
    else                                                      
    {                                                         
      mode          = opcode[opc].mode;                       
      op1           = opcode[opc].op1;                        
      exec          = opcode[opc].exec_opcode;                
      cpu_timestep += opcode[opc].cycle;                       
    }                                                         
                                                              
    if(exec(mode,op1)==-1)                                    
    {                                                         
      printf("execute: opcode %-.2x not implemented !\n",opc);   
      exit(-1);                                               
    } 
  }                                                        
}

