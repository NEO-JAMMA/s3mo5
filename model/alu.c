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

/*********************************************************************
*
* ALU model
*
*********************************************************************/
unsigned int alu(unsigned int op1,unsigned op2,unsigned int mode)
{
  unsigned int res;

  switch(mode)
  {
     case INC8:
     
       res = (op1 + 1)&0xff;
       /* Z flag */
       if((res&0xff)==0)
         SET_CC(Z); 
       else 
         CLEAR_CC(Z);
       
       /* N flag */
       if(BTST(res,7)) 
         SET_CC(N); 
       else 
         CLEAR_CC(N);
       
       /* V flag */
       if(!BTST(op1,7) && BTST(res,7))
         SET_CC(V); 
       else 
         CLEAR_CC(V);
         
       break;

     case PLUS8: 
     
       res = (op1 + op2)&0xff;
       /* Z flag */
       if((res&0xff)==0)
         SET_CC(Z); 
       else 
         CLEAR_CC(Z);
       
       /* N flag */
       if(BTST(res,7)) 
         SET_CC(N); 
       else 
         CLEAR_CC(N);
       
       /* V flag */
       if(( BTST(op1,7) && BTST(op2,7) && !BTST(res,7)) ||
          (!BTST(op1,7) && !BTST(op2,7) && BTST(res,7)) )
         SET_CC(V); 
       else 
         CLEAR_CC(V);
         
       /* C flag */
       if((BTST(op1,7) && BTST(op2,7)) ||
          (BTST(op1,7) && !BTST(res,7)) ||
          (BTST(op2,7) && !BTST(res,7)))
         SET_CC(C);
       else
         CLEAR_CC(C);
     
       /* H flag */
       if((BTST(op1,3) && BTST(op2,3)) ||
          (BTST(op1,3) && !BTST(res,3)) ||
          (BTST(op2,3) && !BTST(res,3)))
         SET_CC(H);
       else
         CLEAR_CC(H);
       
       break;
     
     case PLUS8C: 
     
       res = (op1 + op2 + BTST(cc,C))&0xff;
       
       /* Z flag */
       if((res&0xff)==0)
         SET_CC(Z); 
       else 
         CLEAR_CC(Z);
       
       /* N flag */
       if(BTST(res,7)) 
         SET_CC(N); 
       else 
         CLEAR_CC(N);
       
       /* V flag */
       if(( BTST(op1,7) && BTST(op2,7) && !BTST(res,7)) ||
          (!BTST(op1,7) && !BTST(op2,7) && BTST(res,7)) )
         SET_CC(V); 
       else 
         CLEAR_CC(V);
         
       /* C flag */
       if((BTST(op1,7) && BTST(op2,7)) ||
          (BTST(op1,7) && !BTST(res,7)) ||
          (BTST(op2,7) && !BTST(res,7)))
         SET_CC(C);
       else
         CLEAR_CC(C);
     
       /* H flag */
       if((BTST(op1,3) && BTST(op2,3)) ||
          (BTST(op1,3) && !BTST(res,3)) ||
          (BTST(op2,3) && !BTST(res,3)))
         SET_CC(H);
       else
         CLEAR_CC(H);
       
       break;
     
     case PLUS16:
     
       res = (op1 + op2)&0xffff;
       /* Z flag */
       if((res&0xffff)==0)
         SET_CC(Z); 
       else 
         CLEAR_CC(Z);
       
       /* N flag */
       if(BTST(res,15)) 
         SET_CC(N); 
       else 
         CLEAR_CC(N);
       
       /* V flag */
       if(( BTST(op1,15) && BTST(op2,15) && !BTST(res,15)) ||
          (!BTST(op1,15) && !BTST(op2,15) && BTST(res,15)) )
         SET_CC(V); 
       else 
         CLEAR_CC(V);
         
       /* C flag */
       if((BTST(op1,15) && BTST(op2,15)) ||
          (BTST(op1,15) && !BTST(res,15)) ||
          (BTST(op2,15) && !BTST(res,15)))
         SET_CC(C);
       else
         CLEAR_CC(C);
         
       break;
     
     case MINUS8:
     
       res = (op1 - op2)&0xff;
       /* Z flag */
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);

       /* N flag */
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
         
       /* V flag */
       
       if((!BTST(op1,7) &&  BTST(op2,7) &&  BTST(res,7))||
          ( BTST(op1,7) && !BTST(op2,7) && !BTST(res,7)))
         SET_CC(V);
       else
         CLEAR_CC(V);
         
       /* C flag */
       if((!BTST(op1,7) && BTST(op2,7)) ||
          (!BTST(op1,7) && BTST(res,7)) ||
          ( BTST(op2,7) && BTST(res,7)))
         SET_CC(C);
       else
         CLEAR_CC(C);
         
       break;

     case MINUS8C:
     
       res = (op1 - op2 - BTST(cc,C))&0xff;
       
       /* Z flag */
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);

       /* N flag */
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
         
       /* V flag */
       
       if((!BTST(op1,7) &&  BTST(op2,7) &&  BTST(res,7))||
          ( BTST(op1,7) && !BTST(op2,7) && !BTST(res,7)))
         SET_CC(V);
       else
         CLEAR_CC(V);
         
       /* C flag */
       if((!BTST(op1,7) && BTST(op2,7)) ||
          (!BTST(op1,7) && BTST(res,7)) ||
          ( BTST(op2,7) && BTST(res,7)))
         SET_CC(C);
       else
         CLEAR_CC(C);
         
       break;

     case DEC8:
     
       res = (op1 - 1)&0xff;
       /* Z flag */
       if((res&0xff)==0)
         SET_CC(Z); 
       else 
         CLEAR_CC(Z);
       
       /* N flag */
       if(BTST(res,7)) 
         SET_CC(N); 
       else 
         CLEAR_CC(N);
       
       /* V flag */
       if(BTST(op1,7) && !BTST(res,7))
         SET_CC(V); 
       else 
         CLEAR_CC(V);
         
       break;
      
     case MINUS16:
     
       res = (op1 - op2)&0xffff;
       /* Z flag */
       if((res&0xffff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);

       /* N flag */
       if(BTST(res,15))
         SET_CC(N);
       else
         CLEAR_CC(N);
         
       /* V flag */
       
       if((!BTST(op1,15) &&  BTST(op2,15) &&  BTST(res,15))||
          ( BTST(op1,15) && !BTST(op2,15) && !BTST(res,15)))
         SET_CC(V);
       else
         CLEAR_CC(V);
         
       /* C flag */
       if((!BTST(op1,15) && BTST(op2,15)) ||
          (!BTST(op1,15) && BTST(res,15)) ||
          ( BTST(op2,15) && BTST(res,15)))
         SET_CC(C);
       else
         CLEAR_CC(C);
       
       break;
     
     case OR8:
     
       res = (op1|op2)&0xff;
       
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
       
       CLEAR_CC(V);
       break;
     
     case AND8:
     
       res = (op1&op2)&0xff;
       
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
       
       CLEAR_CC(V);
       break;
     
     case ROL8: 
     
       res=(op1<<1)&0xff;
       
       if(BTST(cc,C))
         res |= 1;
       
       if(BTST(op1,7))
         SET_CC(C);
       else
         CLEAR_CC(C);
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       if((!BTST(op1,7) &&  BTST(res,7))||
          ( BTST(op1,7) && !BTST(res,7)))
         SET_CC(V);
       else
         CLEAR_CC(V);
       
       break;
       
     case ROR8: 
     
       res=(op1>>1)&0x7f;
       
       if(BTST(cc,C))
         res |= 0x80;
       
       if(BTST(op1,0))
         SET_CC(C);
       else
         CLEAR_CC(C);
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       break;
       
     case ASR8:   
     
       res = (op1>>1)&0x7f;
       
       if(BTST(op1,7))
         res |= 0x80;
         
       if(BTST(op1,0))
         SET_CC(C);
       else
         CLEAR_CC(C);
         
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       break;
     
     case LSL8:   
       
       res = (op1<<1)&0xff;
       
       if(BTST(op1,7))
         SET_CC(C);
       else
         CLEAR_CC(C);
         
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       /* V flag */
       
       if((!BTST(op1,7) &&  BTST(res,7))||
          ( BTST(op1,7) && !BTST(res,7)))
         SET_CC(V);
       else
         CLEAR_CC(V);
       
       break;
    
     case LSR8:
     
       res = (op1>>1)&0x7f;
       
       if(BTST(op1,0))
         SET_CC(C);
       else
         CLEAR_CC(C);
         
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       CLEAR_CC(N);
       
       break;
     
     case MULT:
     
       res=(op1*op2)&0xffff;
       
       if((res&0xffff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
       
       if(BTST(res,7))
       {
         SET_CC(C);
       }
       else
       {
         CLEAR_CC(C); 
       }
       break; 
     
     case ASSIGN8:
     
       res = op1&0xff;
       
       /* Z flag */
       if((op1&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
  
       /* N flag */
       if(BTST(op1,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
      
       /* V flag */
       CLEAR_CC(V);
       
       break;
     
     case ASSIGN16:
       
       res = op1;
       
       /* Z flag */
       if((op1&0xffff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
  
       /* N flag */
       if(BTST(op1,15))
         SET_CC(N);
       else
         CLEAR_CC(N);
      
       /* V flag */
       CLEAR_CC(V);
       
       break;
       
     case TST8:
     
       res = op1&0xff;
       
       if((op1&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
  
       /* N flag */
       if(BTST(op1,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       CLEAR_CC(V);
       break;
     
     case NEG8:
     
       res = ((op1^0xff)+1)&0xff;
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
      
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
         
       if((op1&0xff)==0)
         SET_CC(C);
       else
         CLEAR_CC(C);

       if((op1&0xff)==0xff)
         SET_CC(V);
       else
         CLEAR_CC(V);
       
       break;
       
     case CLR:
     
       res=0;
       SET_CC(Z);
       CLEAR_CC(V);
       CLEAR_CC(N);
       CLEAR_CC(C);
       break;

     case COM8:
     
       res= (op1^0xff)&0xff;
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       CLEAR_CC(V);
       SET_CC(C);
       break;
    
     case EOR8:
     
       res= (op1^op2)&0xff;
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       CLEAR_CC(V);
       break;
       
     case TSTZ:
     
       res=op1;
       
       if((res&0xffff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
       
       break;
       
     case SEX8:
     
       if(BTST(op1,7))
       {
         res=0xff;
         CLEAR_CC(Z);
         SET_CC(N);
       }
       else
       {
         res=0x00;
         SET_CC(Z);
         CLEAR_CC(N);
       } 
       break;
     
     case DADJ8:
       
       res = (op1)&0xff;
       
       if((res&0xf)>9 || BTST(cc,H))
         res = res + 0x06;
         
       if((res>>4)>9  || BTST(cc,C))
         res = res + 0x60;
       
       if(res&0x100)
       {
         SET_CC(C);
       }  
       res = res&0xff;
       
       if((res&0xff)==0)
         SET_CC(Z);
       else
         CLEAR_CC(Z);
         
       if(BTST(res,7))
         SET_CC(N);
       else
         CLEAR_CC(N);
       
       CLEAR_CC(V);
       
       break;
     
     default:
       printf("alu: unknown mode %d !\n",mode);
       exit(-1);       
  }
  
  return res;
}

