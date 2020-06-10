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

#ifndef __S3MO5_H_
#define __S3MO5_H_


/*********************************************************************
* macros
*********************************************************************/

#define EXT8(i)      ((int)((i&0x80)?(i|0xffffff00):(i&0xff)))
#define EXT16(i)     ((int)((i&0x8000)?(i|0xffff0000):(i&0xffff)))
#define SET_CC(i)    (cc|=(1<<i))
#define CLEAR_CC(i)  (cc&=(~(1<<i)))
#define BTST(v,i)    ((v&(1<<i))?1:0)

#define COLOR(c) if(!nocolor) printf(c);
#define NORM   "\E[00m"
#define RED    "\E[01;31m"
#define GREEN  "\E[01;32m"
#define WHITE  "\E[01;37m"

/*********************************************************************
* ALU modes
*********************************************************************/

#define PLUS8     0
#define PLUS8C    1
#define PLUS16    2
#define MINUS8    3 
#define MINUS8C   4
#define MINUS16   5
#define OR8       6  
#define AND8      7    
#define ROL8      8
#define ROR8      9
#define ASR8     10
#define LSL8     11
#define LSR8     12
#define ASSIGN8  13
#define ASSIGN16 14
#define TST8     15
#define NEG8     16
#define CLR      17
#define EOR8     18
#define COM8     19
#define INC8     20
#define DEC8     21
#define TSTZ     22
#define SEX8     23
#define DADJ8    24
#define MULT     25

/*********************************************************************
* System MO5
*********************************************************************/

extern unsigned char memory[1024*1024];

extern unsigned char pia0_pra;
extern unsigned char pia0_ddra;
extern unsigned char pia0_cra;
extern unsigned char pia0_prb;
extern unsigned char pia0_ddrb;
extern unsigned char pia0_crb;
extern unsigned char cnt_ext64k;
extern unsigned char pia1_pra;
extern unsigned char pia1_ddra;
extern unsigned char pia1_cra;
extern unsigned char pia1_prb;
extern unsigned char pia1_ddrb;
extern unsigned char pia1_crb;
extern unsigned char pia2_pra;
extern unsigned char pia2_ddra;
extern unsigned char pia2_cra;
extern unsigned char pia2_prb;
extern unsigned char pia2_ddrb;
extern unsigned char pia2_crb;
extern unsigned char gate_array[4];

extern unsigned int  color_bgr_mo5[16];
extern unsigned char keyboard_mo5[64];
extern char          frame[4*336*216];
extern char          bios_frame[4*336*216];
                         
unsigned char        bios_fore_ram[8*1024];
unsigned char        bios_back_ram[8*1024];
unsigned char        bios_rom[1792];
unsigned char        bios_ram[32*1024];
unsigned char        fs_ram[4*1024*1024];

unsigned char        bios_slide_index_h;
unsigned char        bios_slide_index_l;
unsigned char        bios_control;
unsigned char        bios_control2;

/*********************************************************************
* 6809 registers and memory declaration
*********************************************************************/

struct s_instr
{
  char*        mnemonic;
  unsigned int op1;
  unsigned int mode;
  unsigned int (*exec_opcode)(unsigned int,unsigned int); 
  unsigned int cycle;
};


extern struct s_instr opcode[];
extern struct s_instr opcode10[];
extern struct s_instr opcode11[];

extern unsigned int  a,b,x,y,u,s,dp,cc,pc;
extern unsigned int  pa,pb,px,py,pu,ps,pdp,pcc,ppc;
extern unsigned int  cpu_timestep;
extern unsigned int  wait_for_interrupt;

extern unsigned int  nocolor,verbose,display_memtraffic;

#define E           7
#define F           6
#define H           5
#define I           4
#define N           3
#define Z           2
#define V           1
#define C           0


/*********************************************************************
* Addressing modes and operands
*********************************************************************/

#ifndef NULL
#define NULL        0
#endif

#define INHERENT    1
#define INHERENT2   2
#define INHERENT3S  3
#define INHERENT3U  4
#define IMMEDIATE8  5
#define IMMEDIATE16 6
#define DIRECT      7
#define EXTENDED    8
#define INDEXED     9
#define RELATIVE    10
#define RELATIVE2   11
#define OPCODE10    12
#define OPCODE11    13
#define UNKNOW      14

#define ONE         1
#define TWO         2
#define THREE       3

#define A           1
#define B           2
#define D           3
#define X           4 
#define Y           5 
#define U           6 
#define S           7
#define CC          8
#define PC          9
#define DP          10 

#define RA          0 
#define RN          1  
#define HI          2 
#define LS          3
#define HS          4
#define CS          5 
#define NE          6
#define EQ          7
#define VC          8
#define VS          9
#define PL          10
#define MI          11
#define GE          12
#define LT          13
#define GT          14
#define LE          15


/*********************************************************************
* Protypes of 6809 emulation
*********************************************************************/

void enter_reset();
void enter_nmi();
void enter_fiq();
void enter_irq();

unsigned int exec_abx(unsigned int,unsigned int);   
unsigned int exec_adc(unsigned int,unsigned int);  
unsigned int exec_add(unsigned int,unsigned int);  
unsigned int exec_and(unsigned int,unsigned int);  
unsigned int exec_andcc(unsigned int,unsigned int); 
unsigned int exec_lsl(unsigned int,unsigned int);   
unsigned int exec_asr(unsigned int,unsigned int);   
unsigned int exec_b(unsigned int,unsigned int);   
unsigned int exec_lb(unsigned int,unsigned int);   
unsigned int exec_lbsr(unsigned int,unsigned int);   
unsigned int exec_bit(unsigned int,unsigned int);     
unsigned int exec_bsr(unsigned int,unsigned int);   
unsigned int exec_clr(unsigned int,unsigned int);   
unsigned int exec_cmp(unsigned int,unsigned int);  
unsigned int exec_com(unsigned int,unsigned int);  
unsigned int exec_cwai(unsigned int,unsigned int);  
unsigned int exec_daa(unsigned int,unsigned int);  
unsigned int exec_dec(unsigned int,unsigned int);  
unsigned int exec_eor(unsigned int,unsigned int);  
unsigned int exec_exg(unsigned int,unsigned int);  
unsigned int exec_inc(unsigned int,unsigned int);  
unsigned int exec_inca(unsigned int,unsigned int);  
unsigned int exec_incb(unsigned int,unsigned int);  
unsigned int exec_jmp(unsigned int,unsigned int);  
unsigned int exec_jsr(unsigned int,unsigned int); 
unsigned int exec_ld(unsigned int,unsigned int);  
unsigned int exec_lea(unsigned int,unsigned int);  
unsigned int exec_lsr(unsigned int,unsigned int);  
unsigned int exec_mul(unsigned int,unsigned int);  
unsigned int exec_neg(unsigned int,unsigned int);  
unsigned int exec_nop(unsigned int,unsigned int); 
unsigned int exec_or(unsigned int,unsigned int); 
unsigned int exec_orcc(unsigned int,unsigned int); 
unsigned int exec_psh(unsigned int,unsigned int); 
unsigned int exec_pul(unsigned int,unsigned int);  
unsigned int exec_rol(unsigned int,unsigned int);  
unsigned int exec_ror(unsigned int,unsigned int);  
unsigned int exec_rti(unsigned int,unsigned int);  
unsigned int exec_rts(unsigned int,unsigned int);  
unsigned int exec_sbc(unsigned int,unsigned int);  
unsigned int exec_sex(unsigned int,unsigned int);  
unsigned int exec_st(unsigned int,unsigned int);  
unsigned int exec_sub(unsigned int,unsigned int);  
unsigned int exec_swi(unsigned int,unsigned int);    
unsigned int exec_sync(unsigned int,unsigned int);  
unsigned int exec_tfr(unsigned int,unsigned int);    
unsigned int exec_tst(unsigned int,unsigned int);   
unsigned int exec_unknow(unsigned int,unsigned int); 

/*********************************************************************
* 
*********************************************************************/

void         sound_put_bit(void);
void         dump_sound(void);
void         vsync_interrupt(int);

void         refresh_video();
void         dump_video_bank();

void         display_registers();
void         display_registers_change();
void         scan_interrupt(unsigned int,unsigned int,unsigned int,unsigned int);
void         execute();
unsigned int disassemble(unsigned int);
unsigned int alu(unsigned int,unsigned int,unsigned int);

unsigned int get_mem8(unsigned int);
unsigned int get_mem16(unsigned int,unsigned int);
void         put_mem8(unsigned int,unsigned int);
void         put_mem16(unsigned int,unsigned int,unsigned int);
unsigned int get_ea(unsigned int);

#endif
