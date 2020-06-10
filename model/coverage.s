;*********************************************************************
; 
; S3MO5 - instructions coverage
; Copyright (C) 2005 - Olivier Ringot <oringot@gmail.com>
; 
; This file is part of the S3MO5 project
;
; The S3MO5 project is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
; 
; The S3MO5 project is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this S3MO5 project; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, 
; Boston, MA  02110-1301, USA.
; 
;*********************************************************************

  .title   S3MO5 COVERAGE
  .area    _S3MO5 (ABS)
  .org     0hf000


_reset_entry:

; load stacks

  lds  #0h9fff
  ldu  #0h8fff

;**********************************************************************
;
; ABX 
;
;**********************************************************************

_abx_test:
  
  lda #0h40
  tfr a,dp
  ldx #0hffff
  ldb #0h01
  abx
  cmpx #0h0000
  beq _adca_test
  jmp _bad

;**********************************************************************
;
; ADC 
;
;**********************************************************************
  
_adca_test:

_adca_direct_test:

  lda #0h47
  sta *0h10   ; store 0h47 @ 0h4010
  lda #0hff
  sta *0h11   ; store 0hff @ 0h4011
 
  lda  #0h89
  ldb  #0hef
  orcc #0h51
  adca *0h10
  orcc #0h51
  adcb *0h11
  
  cmpa #0hd1
  beq _adca_1
  jmp _bad
_adca_1:
  cmpb #0hef
  beq _addressing
  jmp _bad
  
  
;**********************************************************************
;
; addressing 
;
;**********************************************************************
_addressing:

  ldx #0h4000
  ldx #0h8000
  lda #0h40
  ldb #0h18
  std ,x
  std ,x+
  std ,-x
  std ,--x
  std [,x]
  std [,x++]
  std [,--x]
  std ,y
  std ,y+
  std ,-y
  std ,--y
  std [,y]
  std [,y++]
  std [,--y]
  std ,u
  std ,u+
  std ,-u
  std ,--u
  std [,u]
  std [,u++]
  std [,--u]
  std ,s
  std ,s+
  std ,-s
  std ,--s
  std [,s]
  std [,s++]
  std [,--s]
  std [0h4010]
  std 4,x
  std -4,x
  std 40,x
  std -40,x
  std 400,x
  std -400,x
  std 4,y
  std -4,y
  std 40,y
  std -40,y
  std 400,y
  std -400,y
  std 4,u
  std -4,u
  std 40,u
  std -40,u
  std 400,u
  std -400,u
  std 4,s
  std -4,s
  std 40,s
  std -40,s
  std 400,s
  std -400,s
  std [40,x]
  std [-40,x]
  std [400,x]
  std [-400,x]
  std [40,y]
  std [-40,y]
  std [400,y]
  std [-400,y]
  std [40,u]
  std [-40,u]
  std [400,u]
  std [-400,u]
  std [40,s]
  std [-40,s]
  std [400,s]
  std [-400,s]
  std a,x
  std b,x
  std d,x
  std [a,x]
  std [b,x]
  std [d,x]
  std a,y
  std b,y
  std d,y
  std [a,y]
  std [b,y]
  std [d,y]
  std a,u
  std b,u
  std d,u
  std [a,u]
  std [b,u]
  std [d,u]
  std a,s
  std b,s
  std d,s
  std [a,s]
  std [b,s]
  std [d,s]
  std 45,pc
  std -45,pc
  std 450,pc
  std -450,pc
  std [45,pc]
  std [-45,pc]
  std [450,pc]
  std [-450,pc]
 
  ldd ,x
  ldd ,x+
  ldd ,-x
  ldd ,--x
  ldd [,x]
  ldd [,x++]
  ldd [,--x]
  ldd ,y
  ldd ,y+
  ldd ,-y
  ldd ,--y
  ldd [,y]
  ldd [,y++]
  ldd [,--y]
  ldd ,u
  ldd ,u+
  ldd ,-u
  ldd ,--u
  ldd [,u]
  ldd [,u++]
  ldd [,--u]
  ldd ,s
  ldd ,s+
  ldd ,-s
  ldd ,--s
  ldd [,s]
  ldd [,s++]
  ldd [,--s]
  ldd [0h4010]
  ldd 4,x
  ldd -4,x
  ldd 40,x
  ldd -40,x
  ldd 400,x
  ldd -400,x
  ldd 4,y
  ldd -4,y
  ldd 40,y
  ldd -40,y
  ldd 400,y
  ldd -400,y
  ldd 4,u
  ldd -4,u
  ldd 40,u
  ldd -40,u
  ldd 400,u
  ldd -400,u
  ldd 4,s
  ldd -4,s
  ldd 40,s
  ldd -40,s
  ldd 400,s
  ldd -400,s
  ldd [40,x]
  ldd [-40,x]
  ldd [400,x]
  ldd [-400,x]
  ldd [40,y]
  ldd [-40,y]
  ldd [400,y]
  ldd [-400,y]
  ldd [40,u]
  ldd [-40,u]
  ldd [400,u]
  ldd [-400,u]
  ldd [40,s]
  ldd [-40,s]
  ldd [400,s]
  ldd [-400,s]
  ldd a,x
  ldd b,x
  ldd d,x
  ldd [a,x]
  ldd [b,x]
  ldd [d,x]
  ldd a,y
  ldd b,y
  ldd d,y
  ldd [a,y]
  ldd [b,y]
  ldd [d,y]
  ldd a,u
  ldd b,u
  ldd d,u
  ldd [a,u]
  ldd [b,u]
  ldd [d,u]
  ldd a,s
  ldd b,s
  ldd d,s
  ldd [a,s]
  ldd [b,s]
  ldd [d,s]
  ldd 45,pc
  ldd -45,pc
  ldd 450,pc
  ldd -450,pc
  ldd [45,pc]
  ldd [-45,pc]
  ldd [450,pc]
  ldd [-450,pc]
  
  lda ,x
  lda ,x+
  lda ,-x
  lda ,--x
  lda [,x]
  lda [,x++]
  lda [,--x]
  lda ,y
  lda ,y+
  lda ,-y
  lda ,--y
  lda [,y]
  lda [,y++]
  lda [,--y]
  lda ,u
  lda ,u+
  lda ,-u
  lda ,--u
  lda [,u]
  lda [,u++]
  lda [,--u]
  lda ,s
  lda ,s+
  lda ,-s
  lda ,--s
  lda [,s]
  lda [,s++]
  lda [,--s]
  lda [0h4010]
  lda 4,x
  lda -4,x
  lda 40,x
  lda -40,x
  lda 400,x
  lda -400,x
  lda 4,y
  lda -4,y
  lda 40,y
  lda -40,y
  lda 400,y
  lda -400,y
  lda 4,u
  lda -4,u
  lda 40,u
  lda -40,u
  lda 400,u
  lda -400,u
  lda 4,s
  lda -4,s
  lda 40,s
  lda -40,s
  lda 400,s
  lda -400,s
  lda [40,x]
  lda [-40,x]
  lda [400,x]
  lda [-400,x]
  lda [40,y]
  lda [-40,y]
  lda [400,y]
  lda [-400,y]
  lda [40,u]
  lda [-40,u]
  lda [400,u]
  lda [-400,u]
  lda [40,s]
  lda [-40,s]
  lda [400,s]
  lda [-400,s]
  lda a,x
  lda b,x
  lda d,x
  lda [a,x]
  lda [b,x]
  lda [d,x]
  lda a,y
  lda b,y
  lda d,y
  lda [a,y]
  lda [b,y]
  lda [d,y]
  lda a,u
  lda b,u
  lda d,u
  lda [a,u]
  lda [b,u]
  lda [d,u]
  lda a,s
  lda b,s
  lda d,s
  lda [a,s]
  lda [b,s]
  lda [d,s]
  lda 45,pc
  lda -45,pc
  lda 450,pc
  lda -450,pc
  lda [45,pc]
  lda [-45,pc]
  lda [450,pc]
  lda [-450,pc]

  adda #0h10
  adda 0h8000
  adda [0h8000]
  addb #0h14
  addb 0h8000
  addb [0h8000]
  addd #0h7889
  addd 0h8000
  addd [0h8000]
  
  asla
  aslb
  asl  0h4010

  asra
  asrb
  asr  0h4010

  rola
  rolb
  rol  0h4010

  rora
  rorb
  ror  0h4010
  
  clra
  clrb
  clr  0h4010
  
  cmpa #0hff
  cmpa #0h00
  cmpb #0hff
  cmpb #0h00
  cmpd #0h0000
  cmpd #0hffff
  cmps #0h0000
  cmps #0hffff
  cmpu #0h0000
  cmpu #0hffff
  cmpx #0h0000
  cmpx #0hffff
  cmpy #0h0000
  cmpy #0hffff

  cmpa [0h8000]
  cmpa 0h8000
  cmpb [0h8000] 
  cmpb 0h8000   
  cmpd [0h8000] 
  cmpd 0h8000   
  cmps [0h8000] 
  cmps 0h8000   
  cmpu [0h8000] 
  cmpu 0h8000   
  cmpx [0h8000] 
  cmpx 0h8000   
  cmpy [0h8000]  
  cmpy 0h8000    
  
  lda #0h00
  coma
  lda #0hff
  coma
  lda #0h80
  coma
  ldb #0h00
  comb
  ldb #0hff
  comb
  ldb #0h80
  comb
  ldx  #0h4010
  lda  #0h00
  sta  ,x
  com  0h4010
  ldx  #0h4010
  lda  #0hff
  sta  ,x
  com  0h4010
  ldx  #0h4010
  lda  #0h80
  sta  ,x
  com  0h4010
  
  lda #0h00
  daa
  lda #0h09
  daa
  lda #0h11
  daa
  lda #0h51
  daa
  lda #0hf1
  daa
  
  lda #0h80
  deca
  lda #0h7f
  deca
  lda #0h00
  deca
  lda #0hff
  deca
  ldb #0h80
  decb
  ldb #0h7f
  decb
  ldb #0h00
  decb
  ldb #0hff
  decb
 
  dec  0h8000
  dec  [0h8000]
 
 
  lda #0h80
  eora #0h55
  lda #0h7f
  eora #0h55
  lda #0h00
  eora #0h55
  lda #0hff
  eora #0h55
  ldb #0h80
  eorb #0h55
  ldb #0h7f
  eorb #0h55
  ldb #0h00
  eorb #0h55
  ldb #0hff
  eorb #0h55

  eora  0h8000
  eora  [0h8000]
  eorb  0h8000
  eorb  [0h8000]


  lda #0h0a
  ldb #0h0b
  ldx #0h1011
  ldy #0h2021
  lds #0h3031
  ldu #0h4041
  
  exg a,b
  exg d,y
  exg x,y
  exg y,u
  exg u,s
  exg s,d
  exg a,dp
  exg dp,b
  exg dp,cc
  exg u,s
  exg s,d
  exg b,a
  exg cc,a
  
  inca
  incb
  inc 0h4010
  
  lda #0h40
  exg a,dp
  inc *0h10
  
  leax ,x
  leax ,x+
  leax ,x++
  leax ,-x
  leax ,--x
  leax 4,x
  leax -4,x
  leax 40,x
  leax -40,x
  leax 400,x
  leax -400,x
  leax a,x
  leax b,x
  leax d,x
  leax 4,pc
  leax -4,pc
  leax 40,pc
  leax -40,pc
  leax 400,pc
  leax -400,pc
  leax [,x]
  leax [,x++]
  leax [,--x]
  leax [,--x]
  leax [40,x]
  leax [-40,x]
  leax [400,x]
  leax [-400,x]
  leax [a,x]
  leax [b,x]
  leax [d,x]
  leax [40,pc]
  leax [-40,pc]
  leax [400,pc]
  leax [-400,pc]
  leax [0h4010]
  
  leay ,x
  leay ,x+
  leay ,x++
  leay ,-x
  leay ,--x
  leay 4,x
  leay -4,x
  leay 40,x
  leay -40,x
  leay 400,x
  leay -400,x
  leay a,x
  leay b,x
  leay d,x
  leay 4,pc
  leay -4,pc
  leay 40,pc
  leay -40,pc
  leay 400,pc
  leay -400,pc
  leay [,x]
  leay [,x++]
  leay [,--x]
  leay [,--x]
  leay [40,x]
  leay [-40,x]
  leay [400,x]
  leay [-400,x]
  leay [a,x]
  leay [b,x]
  leay [d,x]
  leay [40,pc]
  leay [-40,pc]
  leay [400,pc]
  leay [-400,pc]
  leay [0h4010]
 
  leau ,x
  leau ,x+
  leau ,x++
  leau ,-x
  leau ,--x
  leau 4,x
  leau -4,x
  leau 40,x
  leau -40,x
  leau 400,x
  leau -400,x
  leau a,x
  leau b,x
  leau d,x
  leau 4,pc
  leau -4,pc
  leau 40,pc
  leau -40,pc
  leau 400,pc
  leau -400,pc
  leau [,x]
  leau [,x++]
  leau [,--x]
  leau [,--x]
  leau [40,x]
  leau [-40,x]
  leau [400,x]
  leau [-400,x]
  leau [a,x]
  leau [b,x]
  leau [d,x]
  leau [40,pc]
  leau [-40,pc]
  leau [400,pc]
  leau [-400,pc]
  leau [0h4010]
 
  leas ,x
  leas ,x+
  leas ,x++
  leas ,-x
  leas ,--x
  leas 4,x
  leas -4,x
  leas 40,x
  leas -40,x
  leas 400,x
  leas -400,x
  leas a,x
  leas b,x
  leas d,x
  leas 4,pc
  leas -4,pc
  leas 40,pc
  leas -40,pc
  leas 400,pc
  leas -400,pc
  leas [,x]
  leas [,x++]
  leas [,--x]
  leas [,--x]
  leas [40,x]
  leas [-40,x]
  leas [400,x]
  leas [-400,x]
  leas [a,x]
  leas [b,x]
  leas [d,x]
  leas [40,pc]
  leas [-40,pc]
  leas [400,pc]
  leas [-400,pc]
  leas [0h4010]
  
  
  lsla
  lslb
  lsl  0h4010

  lsra
  lsrb
  lsr  0h4010
 
  ldd #0h00ff
  mul
  ldd #0hff00
  mul
  ldd #0h0000
  mul
  ldd #0h8001
  mul
  ldd #0h7f01
  mul
  ldd #0h7f7f
  mul
  ldd #0h8080
  mul
  ldd #0hffff
  mul
  ldd #0hff10
  mul
  ldd #0h10ff
  mul
  
  nega
  negb
  neg 0h4010
  
  nop
  
  ora  #0h55
  ora [0h8000] 
  ora 0h8000   
  orb  #0h55
  orb [0h8000] 
  orb 0h8000   

  andcc #0h00
  orcc  #0h00
  orcc  #0h01
  orcc  #0h02
  orcc  #0h04
  orcc  #0h08
  orcc  #0h10
  orcc  #0h20
  orcc  #0h40
  orcc  #0h80
  orcc  #0h00
 
  orcc   #0hff
  andcc  #0hfe
  andcc  #0hfd
  andcc  #0hfb
  andcc  #0hf7
  andcc  #0hef
  andcc  #0hdf
  andcc  #0hbf
  andcc  #0h7f
  andcc  #0h00
  
  lds    #0h8000
  bsr    _subroutine0
  jmp    _next
 
_subroutine0:
  nop
  bsr _subroutine1
  nop
  rts
_subroutine1:
  nop
  bsr _subroutine2
  nop
  rts
_subroutine2:
  nop
  bsr _subroutine3
  nop
  rts
_subroutine3:
  nop
  bsr _subroutine4
  nop
  rts
_subroutine4:
  nop
  nop
  rts

_next:

  
  lds    #0h8000
  ldu    #0h7000
  
  lda    #0hae
  exg    dp,a
  
  lda    #0h45
  ldb    #0h89
  ldx    #0h1234
  ldy    #0h5678
  
  
  
  pshs a
  pshs a,b
  pshs a,b,x
  pshs a,b,x,y
  pshs a,b,x,y,dp
  pshs a,b,x,y,dp,cc
  pshs a,b,x,y,dp,cc,u

  puls a,b,x,y,dp,cc,u
  puls a,b,x,y,dp
  puls a,b,x,y
  puls a,b,x
  puls a,b
  puls a

  lds    #0h8000
  ldu    #0h7000
  
  lda    #0h7e
  exg    dp,a
  
  lda    #0h98
  ldb    #0h87
  ldx    #0hef1a
  ldy    #0hb25e

  pshu a
  pshu a,b
  pshu a,b,x
  pshu a,b,x,y
  pshu a,b,x,y,dp
  pshu a,b,x,y,dp,cc,s

  pulu a,b,x,y,dp,cc,s
  pulu a,b,x,y,dp
  pulu a,b,x,y
  pulu a,b,x
  pulu a,b
  pulu a
  
  andcc #0h00
  ldx  #0h4010
  lda  #0h7f
  lda  #0h80
  sta  ,x
  stb  ,x+
  sbca 0h4010
  sbcb 0h4011
  sbca #0hff
  sbcb #0h01

  adca 0h4010
  adcb 0h4011
  adca #0hff
  adcb #0h01
 
  orcc #0h01
  ldx  #0h4010
  lda  #0h7f
  lda  #0h80
  sta  ,x
  stb  ,x+
  sbca 0h4010
  sbcb 0h4011
  
  ldb #0h00
  sex
  ldb #0h01
  sex
  ldb #0h7f
  sex
  ldb #0h80
  sex
  ldb #0hff
  sex
  
  lda    #0h45
  ldb    #0h89
  ldx    #0h1234
  ldy    #0h5678
  lds    #0h8000
  ldu    #0h7000
  
  
  sta    0h8000
  stb    0h8001
  stx    0h8002
  sty    0h8004
  stu    0h8008
  sts    0h800c
  std    0h8010
  
  suba   #0h10
  subb   #0h20
  subd   #0hffff

  suba   0h8000
  subb   0h8001
  subd   0h8002
  
  swi 
  swi2
  swi3
  
  tfr a,b
  tfr b,a
  tfr d,y
  tfr y,d
  tfr x,y
  tfr y,u
  tfr y,u
  tfr u,y
  tfr u,s
  tfr s,u
  tfr s,d
  tfr d,s
  tfr dp,a
  tfr a,dp
  tfr dp,b
  tfr b,dp
  tfr dp,cc
  tfr cc,dp
  tfr pc,x
  
  tsta
  tstb
  tst  0h8000
  
  ldx  #0h8040
  stx 0h8000
  tst [0h8000]

  anda  #0h55
  anda  0h8000
  anda  [0h8000]
  andb  #0h55
  andb  0h8000
  andb  [0h8000]
  
  bita  #0h00
  bita  #0h55
  bita  #0hff
  bitb  #0h00
  bitb  #0h55
  bitb  #0hff
  
  bita  [0h8000]
  bitb  [0h8000]
  
  ldx   #_jmp_direct
  lda   #0h7e
  sta   0h8000
  stx   0h8001
  lda   #0h80
  exg   a,dp
  jmp   *0h00
  nop
  nop
  nop
_jmp_direct:  
  
  lda *0h10
  ldb *0h10
  ldd *0h10
  ldx *0h10
  ldy *0h10
  ldu *0h10
  lds *0h10
 
  lbsr _subroutine0
  nop
  nop
  jsr  _subroutine0
 
  lbra _next2
  nop
  nop







  
_next2: 
 
  ldx #_next3
  exg pc,x
  nop
  nop
  nop

_next3: 
 
  ldx #_next4
  exg x,pc
  nop
  nop
  nop

  
_next4: 
 
  ldx #_next5
  tfr x,pc
  nop
  nop
  nop
 
_next5:

  stx *0h10 

  
;
; from bit fixed
;

  clr 0h8000
  lda #0hf0
  ldb #0h0f
  bita 0h8000
  bitb 0h8000
  
  com 0h8000
  lda #0hf0
  ldb #0h0f
  bita 0h8000
  bitb 0h8000
  
;
;
;
  ;brn _test_endless_loop
  nop
  
_test_hi:

  lda #0h01
  tfr a,cc
  lbhi _test_endless_loop
  lda #0h00
  tfr a,cc
  lbhi _test_ls
  lbra _test_endless_loop

_test_ls:

  lda #0h00
  tfr a,cc
  lbls _test_endless_loop
  lda #0h01
  tfr a,cc
  lbls _test_hs
  lbra _test_endless_loop

_test_hs:

  lda #0h01
  tfr a,cc
  lbhs _test_endless_loop
  lda #0h00
  tfr a,cc
  lbhs _test_cs
  lbra _test_endless_loop

_test_cs:

  lda #0h00
  tfr a,cc
  lbcs _test_endless_loop
  lda #0h01
  tfr a,cc
  lbcs _test_ne
  lbra _test_endless_loop

_test_ne:

  lda #0h04
  tfr a,cc
  lbne _test_endless_loop
  lda #0h00
  tfr a,cc
  lbne _test_eq
  lbra _test_endless_loop

_test_eq:

  lda #0h00
  tfr a,cc
  lbeq _test_endless_loop
  lda #0h04
  tfr a,cc
  lbeq _test_vc
  lbra _test_endless_loop

_test_vc:

  lda #0h02
  tfr a,cc
  lbvc _test_endless_loop
  lda #0h00
  tfr a,cc
  lbvc _test_vs
  lbra _test_endless_loop

_test_vs:

  lda #0h00
  tfr a,cc
  lbvs _test_endless_loop
  lda #0h02
  tfr a,cc
  lbvs _test_pl
  lbra _test_endless_loop

_test_pl:

  lda #0h08
  tfr a,cc
  lbpl _test_endless_loop
  lda #0h00
  tfr a,cc
  lbpl _test_mi
  lbra _test_endless_loop

_test_mi:

  lda #0h00
  tfr a,cc
  lbmi _test_endless_loop
  lda #0h08
  tfr a,cc
  lbmi _test_ge
  lbra _test_endless_loop

_test_ge:

  lda #0h08
  tfr a,cc
  lbge _test_endless_loop
  lda #0h00
  tfr a,cc
  lbge _test_lt
  lbra _test_endless_loop

_test_lt:

  lda #0h00
  tfr a,cc
  lblt _test_endless_loop
  lda #0h08
  tfr a,cc
  lblt _test_gt
  lbra _test_endless_loop

_test_gt:

  lda #0h04
  tfr a,cc
  lbgt _test_endless_loop
  lda #0h00
  tfr a,cc
  lbgt _test_le
  lbra _test_endless_loop

_test_le:

  lda #0h00
  tfr a,cc
  lble _test_endless_loop
  lda #0h04
  tfr a,cc
  lble _test_le2
  lbra _test_endless_loop

_test_le2:

  lda #0h00
  tfr a,cc
  ble _test_endless_loop
  lda #0h04
  tfr a,cc
  ble _sync
  bra _test_endless_loop




_test_endless_loop:
  bra _test_endless_loop

_sync:

  ldx #0ha7c3
  lda ,x
  ora #0h01
  sta ,x
  
  lda #0hff

_loop_sync:
  sync
  
  deca
  tsta
  bne _loop_sync
   
  bra _ok


;**********************************************************************
;
; EPILOG 
;
;**********************************************************************
 
_bad:
  ldx #0h0000
  lda #0hff
  sta ,x
  bra _coverage_done

_ok:

  ldx #0h0000
  lda #0h00
  sta ,x
  bra _coverage_done


  
_coverage_done:
  nop
  nop
  nop
  nop
  nop
  nop
  lda #0h80
  ldx #0ha7fe
  nop
  nop
  nop
  nop
  sta ,x

_dead:
  bra _dead  


_swi3_entry:    
_swi2_entry: 

  rti
   
_firq_entry:    
_irq_entry:  

  ldx #0ha7c3
  lda ,x
  anda #0h3f
  sta ,x
  rti
   
_nmi_entry:

  ldx #0ha7fe
  lda ,x
  anda #0hfd
  sta ,x
  nop
  nop
  nop
  nop
  rti       

_swi_entry:     
  rti


   .org     0hfff2

_swi3_vector:   .dw  _swi3_entry    
_swi2_vector:   .dw  _swi2_entry    
_firq_vector:   .dw  _firq_entry    
_irq_vector:    .dw  _irq_entry     
_swi_vector:    .dw  _swi_entry     
_nmi_vector:    .dw  _nmi_entry     
_reset_vector:  .dw  _reset_entry  

