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

#ifndef __MTPACK_H_
#define __MTPACK_H_

#include <stdio.h>
#include <zlib.h>
#include "s3mo5.h"
#include "memory.h"


extern gzFile   mtpack_file;
extern unsigned int mtpack_buffer;
extern unsigned int mtpack_count;
extern unsigned int paddr;

extern unsigned int  a,b,x,y,u,s,dp,cc,pc;
extern unsigned int  pa,pb,px,py,pu,ps,pdp,pcc,ppc;

void mtpack_put_bits(unsigned val,unsigned int count);
void mtpack_flush_buffer(void);
void mtpack_read_access(unsigned int addr,unsigned int val);
void mtpack_write_access(unsigned int addr,unsigned int val);
void mtpack_nmi(unsigned int state);
void mtpack_irq(unsigned int state);
void mtpack_fiq(unsigned int state);
void mtpack_cat(void);
void mtpack_print_vlc(unsigned int val,unsigned int count);
void mtpack_new_instr(unsigned int n);

#endif
