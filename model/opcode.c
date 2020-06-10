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
#include "s3mo5.h"

/*********************************************************************
* Opcode names
*********************************************************************/

char name_neg[]    = "neg   ";
char name_nega[]   = "nega  ";
char name_negb[]   = "negb  ";
char name_unknow[] = "unknow"; 
char name_com[]    = "com   "; 
char name_coma[]   = "coma  "; 
char name_comb[]   = "comb  "; 
char name_lsr[]    = "lsr   "; 
char name_lsra[]   = "lsra  "; 
char name_lsrb[]   = "lsrb  "; 
char name_ror[]    = "ror   "; 
char name_rora[]   = "rora  "; 
char name_rorb[]   = "rorb  "; 
char name_rol[]    = "rol   "; 
char name_rola[]   = "rola  "; 
char name_rolb[]   = "rolb  "; 
char name_asr[]    = "asr   "; 
char name_asra[]   = "asra  "; 
char name_asrb[]   = "asrb  "; 
char name_lsl[]    = "lsl   "; 
char name_lsla[]   = "lsla  "; 
char name_lslb[]   = "lslb  "; 
char name_dec[]    = "dec   "; 
char name_deca[]   = "deca  "; 
char name_decb[]   = "decb  "; 
char name_inc[]    = "inc   "; 
char name_inca[]   = "inca  "; 
char name_incb[]   = "incb  "; 
char name_tst[]    = "tst   "; 
char name_tsta[]   = "tsta  "; 
char name_tstb[]   = "tstb  "; 
char name_jmp[]    = "jmp   "; 
char name_jsr[]    = "jsr   "; 
char name_clr[]    = "clr   "; 
char name_clra[]   = "clra  "; 
char name_clrb[]   = "clrb  "; 
char name_nop[]    = "nop   "; 
char name_sync[]   = "sync  "; 
char name_lbsr[]   = "lbsr  "; 
char name_daa[]    = "daa   "; 
char name_orcc[]   = "orcc  "; 
char name_andcc[]  = "andcc "; 
char name_sex[]    = "sex   "; 
char name_exg[]    = "exg   "; 
char name_tfr[]    = "tfr   ";
char name_bra[]    = "bra   ";
char name_brn[]    = "brn   ";
char name_bhi[]    = "bhi   ";
char name_bls[]    = "bls   ";
char name_bhs[]    = "bhs   ";
char name_bcs[]    = "bcs   ";
char name_bne[]    = "bne   ";
char name_beq[]    = "beq   ";
char name_bvc[]    = "bvc   ";
char name_bvs[]    = "bvs   ";
char name_bpl[]    = "bpl   ";
char name_bmi[]    = "bmi   ";
char name_bge[]    = "bge   ";
char name_blt[]    = "blt   ";
char name_bgt[]    = "bgt   ";
char name_ble[]    = "ble   ";
char name_lea[]    = "lea   ";
char name_leax[]   = "leax  ";
char name_leay[]   = "leay  ";
char name_leas[]   = "leas  ";
char name_leau[]   = "leau  ";
char name_pshu[]   = "pshu  ";
char name_pulu[]   = "pulu  ";
char name_pshs[]   = "pshs  ";
char name_puls[]   = "puls  ";
char name_rts[]    = "rts   ";
char name_abx[]    = "abx   ";
char name_rti[]    = "rti   ";
char name_cwai[]   = "cwai  ";
char name_mul[]    = "mul   ";
char name_swi[]    = "swi   ";
char name_swi2[]   = "swi2  ";
char name_swi3[]   = "swi3  ";
char name_sub[]    = "sub   "; 
char name_suba[]   = "suba  "; 
char name_subb[]   = "subb  "; 
char name_subd[]   = "subd  "; 
char name_cmp[]    = "cmp   "; 
char name_cmpa[]   = "cmpa  "; 
char name_cmpb[]   = "cmpb  "; 
char name_cmpd[]   = "cmpd  "; 
char name_cmpx[]   = "cmpx  "; 
char name_cmpy[]   = "cmpy  "; 
char name_cmpu[]   = "cmpu  "; 
char name_cmps[]   = "cmps  "; 
char name_sbca[]   = "sbca  "; 
char name_sbcb[]   = "sbcb  "; 
char name_anda[]   = "anda  "; 
char name_andb[]   = "andb  "; 
char name_bita[]   = "bita  "; 
char name_bitb[]   = "bitb  "; 
char name_lda[]    = "lda   ";  
char name_ldb[]    = "ldb   ";  
char name_ldd[]    = "ldd   ";  
char name_ldx[]    = "ldx   ";  
char name_ldy[]    = "ldy   ";  
char name_ldu[]    = "ldu   ";  
char name_lds[]    = "lds   ";  
char name_sta[]    = "sta   ";  
char name_stb[]    = "stb   ";  
char name_std[]    = "std   ";  
char name_stx[]    = "stx   ";  
char name_sty[]    = "sty   ";  
char name_stu[]    = "stu   ";  
char name_sts[]    = "sts   ";  
char name_eora[]   = "eora  "; 
char name_eorb[]   = "eorb  "; 
char name_adca[]   = "adca  "; 
char name_adcb[]   = "adcb  "; 
char name_ora[]    = "ora   ";     
char name_orb[]    = "orb   ";     
char name_adda[]   = "adda  "; 
char name_addb[]   = "addb  "; 
char name_addd[]   = "addd  "; 
char name_bsr[]    = "bsr   "; 
char name_lbra[]   = "lbra  ";
char name_lbrn[]   = "lbrn  ";
char name_lbhi[]   = "lbhi  ";
char name_lbls[]   = "lbls  ";
char name_lbhs[]   = "lbhs  ";
char name_lbcs[]   = "lbcs  ";
char name_lbne[]   = "lbne  ";
char name_lbeq[]   = "lbeq  ";
char name_lbvc[]   = "lbvc  ";
char name_lbvs[]   = "lbvs  ";
char name_lbpl[]   = "lbpl  ";
char name_lbmi[]   = "lbmi  ";
char name_lbge[]   = "lbge  ";
char name_lblt[]   = "lblt  ";
char name_lbgt[]   = "lbgt  ";
char name_lble[]   = "lble  ";

/*********************************************************************
* Single or First OpCode
*********************************************************************/
struct s_instr opcode[256]=
{
  { name_neg    ,NULL  ,DIRECT      ,exec_neg    , 6 }, /* 0x00 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x01 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x02 */    
  { name_com    ,NULL  ,DIRECT      ,exec_com    , 6 }, /* 0x03 */    
  { name_lsr    ,NULL  ,DIRECT      ,exec_lsr    , 6 }, /* 0x04 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 6 }, /* 0x05 */    
  { name_ror    ,NULL  ,DIRECT      ,exec_ror    , 6 }, /* 0x06 */    
  { name_asr    ,NULL  ,DIRECT      ,exec_asr    , 6 }, /* 0x07 */    
  { name_lsl    ,NULL  ,DIRECT      ,exec_lsl    , 6 }, /* 0x08 */    
  { name_rol    ,NULL  ,DIRECT      ,exec_rol    , 6 }, /* 0x09 */    
  { name_dec    ,NULL  ,DIRECT      ,exec_dec    , 6 }, /* 0x0a */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x0b */    
  { name_inc    ,NULL  ,DIRECT      ,exec_inc    , 6 }, /* 0x0c */    
  { name_tst    ,NULL  ,DIRECT      ,exec_tst    , 6 }, /* 0x0d */    
  { name_jmp    ,NULL  ,DIRECT      ,exec_jmp    , 3 }, /* 0x0e */    
  { name_clr    ,NULL  ,DIRECT      ,exec_clr    , 6 }, /* 0x0f */    
  
  { NULL        ,NULL  ,OPCODE10    ,0           , 0 }, /* 0x10 */
  { NULL        ,NULL  ,OPCODE11    ,0           , 0 }, /* 0x11 */
  { name_nop    ,NULL  ,INHERENT    ,exec_nop    , 2 }, /* 0x12 */ 
  { name_sync   ,NULL  ,INHERENT    ,exec_sync   , 2 }, /* 0x13 */ 
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x14 */     
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x15 */     
  { name_lbra   ,RA    ,RELATIVE2   ,exec_lb     , 5 }, /* 0x16 */   
  { name_lbsr   ,NULL  ,RELATIVE2   ,exec_lbsr   , 9 }, /* 0x17 */   
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x18 */    
  { name_daa    ,NULL  ,INHERENT    ,exec_daa    , 2 }, /* 0x19 */    
  { name_orcc   ,NULL  ,IMMEDIATE8  ,exec_orcc   , 3 }, /* 0x1a */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x1b */    
  { name_andcc  ,NULL  ,IMMEDIATE8  ,exec_andcc  , 3 }, /* 0x1c */     
  { name_sex    ,NULL  ,INHERENT    ,exec_sex    , 2 }, /* 0x1d */     
  { name_exg    ,NULL  ,INHERENT2   ,exec_exg    , 8 }, /* 0x1e */     
  { name_tfr    ,NULL  ,INHERENT2   ,exec_tfr    , 6 }, /* 0x1f */     
 
  { name_bra    ,RA    ,RELATIVE    ,exec_b      , 3 }, /* 0x20 */
  { name_brn    ,RN    ,RELATIVE    ,exec_b      , 3 }, /* 0x21 */
  { name_bhi    ,HI    ,RELATIVE    ,exec_b      , 3 }, /* 0x22 */
  { name_bls    ,LS    ,RELATIVE    ,exec_b      , 3 }, /* 0x23 */
  { name_bhs    ,HS    ,RELATIVE    ,exec_b      , 3 }, /* 0x24 */
  { name_bcs    ,CS    ,RELATIVE    ,exec_b      , 3 }, /* 0x25 */
  { name_bne    ,NE    ,RELATIVE    ,exec_b      , 3 }, /* 0x26 */
  { name_beq    ,EQ    ,RELATIVE    ,exec_b      , 3 }, /* 0x27 */
  { name_bvc    ,VC    ,RELATIVE    ,exec_b      , 3 }, /* 0x28 */
  { name_bvs    ,VS    ,RELATIVE    ,exec_b      , 3 }, /* 0x29 */
  { name_bpl    ,PL    ,RELATIVE    ,exec_b      , 3 }, /* 0x2a */
  { name_bmi    ,MI    ,RELATIVE    ,exec_b      , 3 }, /* 0x2b */
  { name_bge    ,GE    ,RELATIVE    ,exec_b      , 3 }, /* 0x2c */
  { name_blt    ,LT    ,RELATIVE    ,exec_b      , 3 }, /* 0x2d */
  { name_bgt    ,GT    ,RELATIVE    ,exec_b      , 3 }, /* 0x2e */
  { name_ble    ,LE    ,RELATIVE    ,exec_b      , 3 }, /* 0x2f */
 
  { name_leax   ,X     ,INDEXED     ,exec_lea    , 4 }, /* 0x30 */
  { name_leay   ,Y     ,INDEXED     ,exec_lea    , 4 }, /* 0x31 */
  { name_leas   ,S     ,INDEXED     ,exec_lea    , 4 }, /* 0x32 */
  { name_leau   ,U     ,INDEXED     ,exec_lea    , 4 }, /* 0x33 */
  { name_pshs   ,S     ,INHERENT3S  ,exec_psh    , 5 }, /* 0x34 */
  { name_puls   ,S     ,INHERENT3S  ,exec_pul    , 5 }, /* 0x35 */
  { name_pshu   ,U     ,INHERENT3U  ,exec_psh    , 5 }, /* 0x36 */
  { name_pulu   ,U     ,INHERENT3U  ,exec_pul    , 5 }, /* 0x37 */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x38 */
  { name_rts    ,NULL  ,INHERENT    ,exec_rts    , 5 }, /* 0x39 */
  { name_abx    ,NULL  ,INHERENT    ,exec_abx    , 3 }, /* 0x3a */
  { name_rti    ,NULL  ,INHERENT    ,exec_rti    , 2 }, /* 0x3b */
  { name_cwai   ,NULL  ,INHERENT    ,exec_cwai   ,20 }, /* 0x3c */
  { name_mul    ,NULL  ,INHERENT    ,exec_mul    ,11 }, /* 0x3d */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x3e */
  { name_swi    ,ONE   ,INHERENT    ,exec_swi    ,19 }, /* 0x3f */
  
  { name_nega   ,A     ,INHERENT    ,exec_neg    , 2 }, /* 0x40 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x41 */  
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x42 */  
  { name_coma   ,A     ,INHERENT    ,exec_com    , 2 }, /* 0x43 */    
  { name_lsra   ,A     ,INHERENT    ,exec_lsr    , 2 }, /* 0x44 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x45 */  
  { name_rora   ,A     ,INHERENT    ,exec_ror    , 2 }, /* 0x46 */  
  { name_asra   ,A     ,INHERENT    ,exec_asr    , 2 }, /* 0x47 */  
  { name_lsla   ,A     ,INHERENT    ,exec_lsl    , 2 }, /* 0x48 */  
  { name_rola   ,A     ,INHERENT    ,exec_rol    , 2 }, /* 0x49 */  
  { name_deca   ,A     ,INHERENT    ,exec_dec    , 2 }, /* 0x4a */  
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x4b */  
  { name_inca   ,A     ,INHERENT    ,exec_inc    , 2 }, /* 0x4c */   
  { name_tsta   ,A     ,INHERENT    ,exec_tst    , 2 }, /* 0x4d */   
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x4e */  
  { name_clra   ,A     ,INHERENT    ,exec_clr    , 2 }, /* 0x4f */    
  
  { name_negb   ,B     ,INHERENT    ,exec_neg    , 2 }, /* 0x50 */ 
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x51 */ 
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x52 */ 
  { name_comb   ,B     ,INHERENT    ,exec_com    , 2 }, /* 0x53 */ 
  { name_lsrb   ,B     ,INHERENT    ,exec_lsr    , 2 }, /* 0x54 */ 
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x55 */ 
  { name_rorb   ,B     ,INHERENT    ,exec_ror    , 2 }, /* 0x56 */
  { name_asrb   ,B     ,INHERENT    ,exec_asr    , 2 }, /* 0x57 */
  { name_lslb   ,B     ,INHERENT    ,exec_lsl    , 2 }, /* 0x58 */
  { name_rolb   ,B     ,INHERENT    ,exec_rol    , 2 }, /* 0x59 */
  { name_decb   ,B     ,INHERENT    ,exec_dec    , 2 }, /* 0x5a */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x5b */
  { name_incb   ,B     ,INHERENT    ,exec_inc    , 2 }, /* 0x5c */
  { name_tstb   ,B     ,INHERENT    ,exec_tst    , 2 }, /* 0x5d */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x5e */
  { name_clrb   ,B     ,INHERENT    ,exec_clr    , 2 }, /* 0x5f */
 
  { name_neg    ,NULL  ,INDEXED     ,exec_neg    , 6 }, /* 0x60 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x61 */ 
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x62 */ 
  { name_com    ,NULL  ,INDEXED     ,exec_com    , 6 }, /* 0x63 */    
  { name_lsr    ,NULL  ,INDEXED     ,exec_lsr    , 6 }, /* 0x64 */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x65 */ 
  { name_ror    ,NULL  ,INDEXED     ,exec_ror    , 6 }, /* 0x66 */    
  { name_asr    ,NULL  ,INDEXED     ,exec_asr    , 6 }, /* 0x67 */    
  { name_lsl    ,NULL  ,INDEXED     ,exec_lsl    , 6 }, /* 0x68 */    
  { name_rol    ,NULL  ,INDEXED     ,exec_rol    , 6 }, /* 0x69 */    
  { name_dec    ,NULL  ,INDEXED     ,exec_dec    , 6 }, /* 0x6a */    
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x6b */ 
  { name_inc    ,NULL  ,INDEXED     ,exec_inc    , 6 }, /* 0x6c */    
  { name_tst    ,NULL  ,INDEXED     ,exec_tst    , 6 }, /* 0x6d */    
  { name_jmp    ,NULL  ,INDEXED     ,exec_jmp    , 3 }, /* 0x6e */    
  { name_clr    ,NULL  ,INDEXED     ,exec_clr    , 6 }, /* 0x6f */    
 
  { name_neg    ,NULL  ,EXTENDED    ,exec_neg    , 7 }, /* 0x70 */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x71 */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x72 */
  { name_com    ,NULL  ,EXTENDED    ,exec_com    , 7 }, /* 0x73 */
  { name_lsr    ,NULL  ,EXTENDED    ,exec_lsr    , 7 }, /* 0x74 */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x75 */
  { name_ror    ,NULL  ,EXTENDED    ,exec_ror    , 7 }, /* 0x76 */
  { name_asr    ,NULL  ,EXTENDED    ,exec_asr    , 7 }, /* 0x77 */
  { name_lsl    ,NULL  ,EXTENDED    ,exec_lsl    , 7 }, /* 0x78 */
  { name_rol    ,NULL  ,EXTENDED    ,exec_rol    , 7 }, /* 0x79 */
  { name_dec    ,NULL  ,EXTENDED    ,exec_dec    , 7 }, /* 0x7a */
  { name_unknow ,NULL  ,UNKNOW      ,exec_unknow , 0 }, /* 0x7b */
  { name_inc    ,NULL  ,EXTENDED    ,exec_inc    , 7 }, /* 0x7c */
  { name_tst    ,NULL  ,EXTENDED    ,exec_tst    , 7 }, /* 0x7d */
  { name_jmp    ,NULL  ,EXTENDED    ,exec_jmp    , 4 }, /* 0x7e */
  { name_clr    ,NULL  ,EXTENDED    ,exec_clr    , 7 }, /* 0x7f */
  
  { name_suba   , A    ,IMMEDIATE8  ,exec_sub    , 2 }, /* 0x80 */
  { name_cmpa   , A    ,IMMEDIATE8  ,exec_cmp    , 2 }, /* 0x81 */
  { name_sbca   , A    ,IMMEDIATE8  ,exec_sbc    , 2 }, /* 0x82 */
  { name_subd   , D    ,IMMEDIATE16 ,exec_sub    , 4 }, /* 0x83 */
  { name_anda   , A    ,IMMEDIATE8  ,exec_and    , 2 }, /* 0x84 */
  { name_bita   , A    ,IMMEDIATE8  ,exec_bit    , 2 }, /* 0x85 */
  { name_lda    , A    ,IMMEDIATE8  ,exec_ld     , 2 }, /* 0x86 */
  { name_unknow , NULL ,UNKNOW      ,exec_unknow , 0 }, /* 0x87 */ 
  { name_eora   , A    ,IMMEDIATE8  ,exec_eor    , 2 }, /* 0x88 */
  { name_adca   , A    ,IMMEDIATE8  ,exec_adc    , 2 }, /* 0x89 */
  { name_ora    , A    ,IMMEDIATE8  ,exec_or     , 2 }, /* 0x8a */
  { name_adda   , A    ,IMMEDIATE8  ,exec_add    , 2 }, /* 0x8b */
  { name_cmpx   , X    ,IMMEDIATE16 ,exec_cmp    , 4 }, /* 0x8c */
  { name_bsr    , NULL ,RELATIVE    ,exec_bsr    , 7 }, /* 0x8d */
  { name_ldx    , X    ,IMMEDIATE16 ,exec_ld     , 3 }, /* 0x8e */
  { name_unknow , NULL ,UNKNOW      ,exec_unknow , 0 }, /* 0x8f */ 
  
  { name_suba   , A    ,DIRECT      ,exec_sub    , 4 }, /* 0x90 */
  { name_cmpa   , A    ,DIRECT      ,exec_cmp    , 4 }, /* 0x91 */
  { name_sbca   , A    ,DIRECT      ,exec_sbc    , 4 }, /* 0x92 */
  { name_subd   , D    ,DIRECT      ,exec_sub    , 6 }, /* 0x93 */
  { name_anda   , A    ,DIRECT      ,exec_and    , 4 }, /* 0x94 */
  { name_bita   , A    ,DIRECT      ,exec_bit    , 4 }, /* 0x95 */
  { name_lda    , A    ,DIRECT      ,exec_ld     , 4 }, /* 0x96 */
  { name_sta    , A    ,DIRECT      ,exec_st     , 4 }, /* 0x97 */
  { name_eora   , A    ,DIRECT      ,exec_eor    , 4 }, /* 0x98 */
  { name_adca   , A    ,DIRECT      ,exec_adc    , 4 }, /* 0x99 */
  { name_ora    , A    ,DIRECT      ,exec_or     , 4 }, /* 0x9a */
  { name_adda   , A    ,DIRECT      ,exec_add    , 4 }, /* 0x9b */
  { name_cmpx   , X    ,DIRECT      ,exec_cmp    , 6 }, /* 0x9c */
  { name_jsr    , NULL ,DIRECT      ,exec_jsr    , 7 }, /* 0x9d */
  { name_ldx    , X    ,DIRECT      ,exec_ld     , 5 }, /* 0x9e */
  { name_stx    , X    ,DIRECT      ,exec_st     , 5 }, /* 0x9f */
 
  { name_suba   , A    ,INDEXED     ,exec_sub    , 4 }, /* 0xa0 */
  { name_cmpa   , A    ,INDEXED     ,exec_cmp    , 4 }, /* 0xa1 */
  { name_sbca   , A    ,INDEXED     ,exec_sbc    , 4 }, /* 0xa2 */
  { name_subd   , D    ,INDEXED     ,exec_sub    , 6 }, /* 0xa3 */
  { name_anda   , A    ,INDEXED     ,exec_and    , 4 }, /* 0xa4 */
  { name_bita   , A    ,INDEXED     ,exec_bit    , 4 }, /* 0xa5 */
  { name_lda    , A    ,INDEXED     ,exec_ld     , 4 }, /* 0xa6 */
  { name_sta    , A    ,INDEXED     ,exec_st     , 4 }, /* 0xa7 */
  { name_eora   , A    ,INDEXED     ,exec_eor    , 4 }, /* 0xa8 */
  { name_adca   , A    ,INDEXED     ,exec_adc    , 4 }, /* 0xa9 */
  { name_ora    , A    ,INDEXED     ,exec_or     , 4 }, /* 0xaa */
  { name_adda   , A    ,INDEXED     ,exec_add    , 4 }, /* 0xab */
  { name_cmpx   , X    ,INDEXED     ,exec_cmp    , 6 }, /* 0xac */
  { name_jsr    , NULL ,INDEXED     ,exec_jsr    , 4 }, /* 0xad */
  { name_ldx    , X    ,INDEXED     ,exec_ld     , 5 }, /* 0xae */
  { name_stx    , X    ,INDEXED     ,exec_st     , 5 }, /* 0xaf */
 
  { name_suba   , A    ,EXTENDED    ,exec_sub    , 5 }, /* 0xb0 */
  { name_cmpa   , A    ,EXTENDED    ,exec_cmp    , 5 }, /* 0xb1 */
  { name_sbca   , A    ,EXTENDED    ,exec_sbc    , 5 }, /* 0xb2 */
  { name_subd   , D    ,EXTENDED    ,exec_sub    , 7 }, /* 0xb3 */
  { name_anda   , A    ,EXTENDED    ,exec_and    , 5 }, /* 0xb4 */
  { name_bita   , A    ,EXTENDED    ,exec_bit    , 5 }, /* 0xb5 */
  { name_lda    , A    ,EXTENDED    ,exec_ld     , 5 }, /* 0xb6 */
  { name_sta    , A    ,EXTENDED    ,exec_st     , 5 }, /* 0xb7 */
  { name_eora   , A    ,EXTENDED    ,exec_eor    , 5 }, /* 0xb8 */
  { name_adca   , A    ,EXTENDED    ,exec_adc    , 5 }, /* 0xb9 */
  { name_ora    , A    ,EXTENDED    ,exec_or     , 5 }, /* 0xba */
  { name_adda   , A    ,EXTENDED    ,exec_add    , 5 }, /* 0xbb */
  { name_cmpx   , X    ,EXTENDED    ,exec_cmp    , 7 }, /* 0xbc */
  { name_jsr    , NULL ,EXTENDED    ,exec_jsr    , 8 }, /* 0xbd */
  { name_ldx    , X    ,EXTENDED    ,exec_ld     , 6 }, /* 0xbe */
  { name_stx    , X    ,EXTENDED    ,exec_st     , 6 }, /* 0xbf */
  
  { name_subb   , B    ,IMMEDIATE8  ,exec_sub    , 2 }, /* 0xc0 */
  { name_cmpb   , B    ,IMMEDIATE8  ,exec_cmp    , 2 }, /* 0xc1 */
  { name_sbcb   , B    ,IMMEDIATE8  ,exec_sbc    , 2 }, /* 0xc2 */
  { name_addd   , D    ,IMMEDIATE16 ,exec_add    , 4 }, /* 0xc3 */
  { name_andb   , B    ,IMMEDIATE8  ,exec_and    , 2 }, /* 0xc4 */
  { name_bitb   , B    ,IMMEDIATE8  ,exec_bit    , 2 }, /* 0xc5 */
  { name_ldb    , B    ,IMMEDIATE8  ,exec_ld     , 2 }, /* 0xc6 */
  { name_unknow , NULL ,UNKNOW      ,exec_unknow , 0 }, /* 0xc7 */
  { name_eorb   , B    ,IMMEDIATE8  ,exec_eor    , 2 }, /* 0xc8 */
  { name_adcb   , B    ,IMMEDIATE8  ,exec_adc    , 2 }, /* 0xc9 */
  { name_orb    , B    ,IMMEDIATE8  ,exec_or     , 2 }, /* 0xca */
  { name_addb   , B    ,IMMEDIATE8  ,exec_add    , 2 }, /* 0xcb */
  { name_ldd    , D    ,IMMEDIATE16 ,exec_ld     , 3 }, /* 0xcc */
  { name_unknow , NULL ,UNKNOW      ,exec_unknow , 0 }, /* 0xcd */
  { name_ldu    , U    ,IMMEDIATE16 ,exec_ld     , 3 }, /* 0xce */
  { name_unknow , NULL ,UNKNOW      ,exec_unknow , 0 }, /* 0xcf */
  
  { name_subb   , B    ,DIRECT      ,exec_sub    , 4 }, /* 0xd0 */
  { name_cmpb   , B    ,DIRECT      ,exec_cmp    , 4 }, /* 0xd1 */
  { name_sbcb   , B    ,DIRECT      ,exec_sbc    , 4 }, /* 0xd2 */
  { name_addd   , D    ,DIRECT      ,exec_add    , 6 }, /* 0xd3 */
  { name_andb   , B    ,DIRECT      ,exec_and    , 4 }, /* 0xd4 */
  { name_bitb   , B    ,DIRECT      ,exec_bit    , 4 }, /* 0xd5 */
  { name_ldb    , B    ,DIRECT      ,exec_ld     , 4 }, /* 0xd6 */
  { name_stb    , B    ,DIRECT      ,exec_st     , 4 }, /* 0xd7 */
  { name_eorb   , B    ,DIRECT      ,exec_eor    , 4 }, /* 0xd8 */
  { name_adcb   , B    ,DIRECT      ,exec_adc    , 4 }, /* 0xd9 */
  { name_orb    , B    ,DIRECT      ,exec_or     , 4 }, /* 0xda */
  { name_addb   , B    ,DIRECT      ,exec_add    , 4 }, /* 0xdb */
  { name_ldd    , D    ,DIRECT      ,exec_ld     , 5 }, /* 0xdc */
  { name_std    , D    ,DIRECT      ,exec_st     , 5 }, /* 0xdd */
  { name_ldu    , U    ,DIRECT      ,exec_ld     , 5 }, /* 0xde */
  { name_stu    , U    ,DIRECT      ,exec_st     , 5 }, /* 0xdf */

  { name_subb   , B    ,INDEXED     ,exec_sub    , 4 }, /* 0xe0 */ 
  { name_cmpb   , B    ,INDEXED     ,exec_cmp    , 4 }, /* 0xe1 */ 
  { name_sbcb   , B    ,INDEXED     ,exec_sbc    , 4 }, /* 0xe2 */ 
  { name_addd   , D    ,INDEXED     ,exec_add    , 6 }, /* 0xe3 */ 
  { name_andb   , B    ,INDEXED     ,exec_and    , 4 }, /* 0xe4 */ 
  { name_bitb   , B    ,INDEXED     ,exec_bit    , 4 }, /* 0xe5 */ 
  { name_ldb    , B    ,INDEXED     ,exec_ld     , 4 }, /* 0xe6 */ 
  { name_stb    , B    ,INDEXED     ,exec_st     , 4 }, /* 0xe7 */ 
  { name_eorb   , B    ,INDEXED     ,exec_eor    , 4 }, /* 0xe8 */ 
  { name_adcb   , B    ,INDEXED     ,exec_adc    , 4 }, /* 0xe9 */ 
  { name_orb    , B    ,INDEXED     ,exec_or     , 4 }, /* 0xea */ 
  { name_addb   , B    ,INDEXED     ,exec_add    , 4 }, /* 0xeb */ 
  { name_ldd    , D    ,INDEXED     ,exec_ld     , 5 }, /* 0xec */ 
  { name_std    , D    ,INDEXED     ,exec_st     , 5 }, /* 0xed */ 
  { name_ldu    , U    ,INDEXED     ,exec_ld     , 5 }, /* 0xee */ 
  { name_stu    , U    ,INDEXED     ,exec_st     , 5 }, /* 0xef */ 
 
  { name_subb   , B    ,EXTENDED    ,exec_sub    , 5 }, /* 0xf0 */
  { name_cmpb   , B    ,EXTENDED    ,exec_cmp    , 5 }, /* 0xf1 */
  { name_sbcb   , B    ,EXTENDED    ,exec_sbc    , 5 }, /* 0xf2 */
  { name_addd   , D    ,EXTENDED    ,exec_add    , 7 }, /* 0xf3 */
  { name_andb   , B    ,EXTENDED    ,exec_and    , 5 }, /* 0xf4 */
  { name_bitb   , B    ,EXTENDED    ,exec_bit    , 5 }, /* 0xf5 */
  { name_ldb    , B    ,EXTENDED    ,exec_ld     , 5 }, /* 0xf6 */
  { name_stb    , B    ,EXTENDED    ,exec_st     , 5 }, /* 0xf7 */
  { name_eorb   , B    ,EXTENDED    ,exec_eor    , 5 }, /* 0xf8 */
  { name_adcb   , B    ,EXTENDED    ,exec_adc    , 5 }, /* 0xf9 */
  { name_orb    , B    ,EXTENDED    ,exec_or     , 5 }, /* 0xfa */
  { name_addb   , B    ,EXTENDED    ,exec_add    , 5 }, /* 0xfb */
  { name_ldd    , D    ,EXTENDED    ,exec_ld     , 6 }, /* 0xfc */
  { name_std    , D    ,EXTENDED    ,exec_st     , 6 }, /* 0xfd */
  { name_ldu    , U    ,EXTENDED    ,exec_ld     , 6 }, /* 0xfe */
  { name_stu    , U    ,EXTENDED    ,exec_st     , 6 }  /* 0xff */
};

/*********************************************************************
* Second OpCode (first opcode = 0x10)
*********************************************************************/
struct s_instr opcode10[256]=
{
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x00 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x01 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x02 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x03 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x04 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x05 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x06 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x07 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x08 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x09 */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0a */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0b */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0c */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0d */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0e */ 
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0f */ 
              
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x10 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x11 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x12 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x13 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x14 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x15 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x16 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x17 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x18 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x19 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x20 */
  { name_lbrn     ,RN     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x21 */
  { name_lbhi     ,HI     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x22 */
  { name_lbls     ,LS     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x23 */
  { name_lbhs     ,HS     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x24 */
  { name_lbcs     ,CS     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x25 */
  { name_lbne     ,NE     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x26 */
  { name_lbeq     ,EQ     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x27 */
  { name_lbvc     ,VC     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x28 */
  { name_lbvs     ,VS     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x29 */
  { name_lbpl     ,PL     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x2a */
  { name_lbmi     ,MI     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x2b */
  { name_lbge     ,GE     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x2c */
  { name_lblt     ,LT     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x2d */
  { name_lbgt     ,GT     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x2e */
  { name_lble     ,LE     ,RELATIVE2   ,exec_lb  , 5 }, /* 0x2f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x30 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x31 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x32 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x33 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x34 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x35 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x36 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x37 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x38 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x39 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3e */
  { name_swi2     ,TWO    ,INHERENT    ,exec_swi ,20 }, /* 0x3f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x40 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x41 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x42 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x43 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x44 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x45 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x46 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x47 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x48 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x49 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x50 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x51 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x52 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x53 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x54 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x55 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x56 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x57 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x58 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x59 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x60 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x61 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x62 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x63 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x64 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x65 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x66 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x67 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x68 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x69 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6f */

  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x70 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x71 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x72 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x73 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x74 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x75 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x16 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x77 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x78 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x79 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7f */

  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x80 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x81 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x82 */
  { name_cmpd     ,D      ,IMMEDIATE16 ,exec_cmp , 5 }, /* 0x83 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x84 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x85 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x86 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x87 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x88 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x89 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8b */
  { name_cmpy     ,Y      ,IMMEDIATE16 ,exec_cmp , 5 }, /* 0x8c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8d */
  { name_ldy      ,Y      ,IMMEDIATE16 ,exec_ld  , 4 }, /* 0x8e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x90 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x91 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x92 */
  { name_cmpd     ,D      ,DIRECT      ,exec_cmp , 7 }, /* 0x93 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x94 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x95 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x96 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x97 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x98 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x99 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9b */
  { name_cmpy     ,Y      ,DIRECT      ,exec_cmp , 7 }, /* 0x9c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9d */
  { name_ldy      ,Y      ,DIRECT      ,exec_ld  , 6 }, /* 0x9e */
  { name_sty      ,Y      ,DIRECT      ,exec_st  , 6 }, /* 0x9f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa2 */
  { name_cmpd     ,D      ,INDEXED     ,exec_cmp , 7 }, /* 0xa3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xaa */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xab */
  { name_cmpy     ,Y      ,INDEXED     ,exec_cmp , 7 }, /* 0xac */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xad */
  { name_ldy      ,Y      ,INDEXED     ,exec_ld  , 6 }, /* 0xae */
  { name_sty      ,Y      ,INDEXED     ,exec_st  , 6 }, /* 0xaf */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb2 */
  { name_cmpd     ,D      ,EXTENDED    ,exec_cmp , 8 }, /* 0xb3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xba */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xbb */
  { name_cmpy     ,Y      ,EXTENDED    ,exec_cmp , 8 }, /* 0xbc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xbd */
  { name_ldy      ,Y      ,EXTENDED    ,exec_ld  , 7 }, /* 0xbe */
  { name_sty      ,Y      ,EXTENDED    ,exec_st  , 7 }, /* 0xbf */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xca */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcd */
  { name_lds      ,S      ,IMMEDIATE16 ,exec_ld  , 4 }, /* 0xce */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcf */
   
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xda */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdd */
  { name_lds      ,S      ,DIRECT      ,exec_ld  , 6 }, /* 0xde */ 
  { name_sts      ,S      ,DIRECT      ,exec_st  , 6 }, /* 0xdf */ 
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xea */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xeb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xec */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xed */
  { name_lds      ,S      ,INDEXED     ,exec_ld  , 6 }, /* 0xee */
  { name_sts      ,S      ,INDEXED     ,exec_st  , 6 }, /* 0xef */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfa */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfd */
  { name_lds      ,S      ,EXTENDED    ,exec_ld  , 7 }, /* 0xfe */ 
  { name_sts      ,S      ,EXTENDED    ,exec_st  , 7 }  /* 0xff */
};

/*********************************************************************
* Second OpCode (first opcode = 0x11)
*********************************************************************/
struct s_instr opcode11[256]=
{
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x00 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x01 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x02 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x03 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x04 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x05 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x06 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x07 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x08 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x09 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x0f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x10 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x11 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x12 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x13 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x14 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x15 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x16 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x17 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x18 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x19 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x1f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x20 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x21 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x22 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x23 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x24 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x25 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x26 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x27 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x28 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x29 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x2a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x2b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x2c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x2d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x2e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x2f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x30 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x31 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x32 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x33 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x34 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x35 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x36 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x37 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x38 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x39 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x3e */
  { name_swi3     ,THREE  ,INHERENT    ,exec_swi ,20 }, /* 0x3f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x40 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x41 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x42 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x43 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x44 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x45 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x46 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x47 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x48 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x49 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x4f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x50 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x51 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x52 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x53 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x54 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x55 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x56 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x57 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x58 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x59 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x5f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x60 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x61 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x62 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x63 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x64 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x65 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x66 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x67 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x68 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x69 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x6f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x70 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x71 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x72 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x73 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x74 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x75 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x76 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x77 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x78 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x79 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7b */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x7f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x80 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x81 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x82 */
  { name_cmpu     ,U      ,IMMEDIATE16 ,exec_cmp , 5 }, /* 0x83 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x84 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x85 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x86 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x87 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x88 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x89 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8b */
  { name_cmps     ,S      ,IMMEDIATE16 ,exec_cmp , 5 }, /* 0x8c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x8f */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x90 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x91 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x92 */
  { name_cmpu     ,U      ,DIRECT      ,exec_cmp , 7 }, /* 0x93 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x94 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x95 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x96 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x97 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x98 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x99 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9a */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9b */
  { name_cmps     ,S      ,DIRECT      ,exec_cmp , 7 }, /* 0x9c */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9d */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9e */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0x9f */
  
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa2 */
  { name_cmpu     ,U      ,INDEXED     ,exec_cmp , 7 }, /* 0xa3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xa9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xaa */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xab */
  { name_cmps     ,S      ,INDEXED     ,exec_cmp , 7 }, /* 0xac */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xad */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xae */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xaf */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb2 */
  { name_cmpu     ,U      ,EXTENDED    ,exec_cmp , 8 }, /* 0xb3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xb9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xba */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xbb */
  { name_cmps     ,S      ,EXTENDED    ,exec_cmp , 8 }, /* 0xbc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xbd */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xbe */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xbf */

  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xc9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xca */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcd */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xce */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xcf */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xd9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xda */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdd */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xde */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xdf */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xe9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xea */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xeb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xec */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xed */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xee */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xef */
  
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf0 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf1 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf2 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf3 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf4 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf5 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf6 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf7 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf8 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xf9 */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfa */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfb */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfc */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfd */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xfe */
  { name_unknow   ,NULL   ,NULL        ,NULL     , 0 }, /* 0xff */

};
