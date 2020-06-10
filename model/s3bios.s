;*********************************************************************
; 
; S3MO5 BIOS
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
; 
; $Revision:$
; $Date: $
; $Source: $
; $Log: $
; 
;*********************************************************************
;
; 0xa900 - 0xaeff 1536 code
;
; 0xaf00             1 slinding window index
; 0xaf01             1 k7_preambule
; 0xaf02             1 number of available files
; 0xaf03             1 selected file
; 0xaf04 - 0xaf05    1 old S stack          
; 0xaf40 - 0xafef  176 stack
; 0xaff0 - 0xafff   16 Hook table (5 jumps)
;
;

;*********************************************************************

  .title   S3MO5 BIOS
  .area    _S3MO5 (ABS)
  .org     0ha900

_s3_boot:

  ;*******************************************************************
  ; set stack register
  ;*******************************************************************
  
  lds    #0haff0           ; set stack
  clr   0haf01             ; clear k7_preambule
  
  ;*******************************************************************
  ; switch to bios user/video ram
  ;*******************************************************************
  lda    0ha7fe
  ora    #0h04
  sta    0ha7fe   
  
  ;*******************************************************************
  ; init PIA6821 system
  ;*******************************************************************
  ldy    #0ha7c0           ; PIA system
  
  lda    #0h5f             ; set up DDRA
  sta    ,y
  lda    #0h04             ; switch to PRA
  sta    2,y
  lda    #0h8c             ; cyan for border
  sta    ,y                ; PRA=0x00
 
  lda    #0h7f
  sta    1,y
  lda    #0h04
  sta    3,y
  
  ;*******************************************************************
  ; copy fs fat to 0x2200 (1024 bytes)
  ;*******************************************************************
  
  ldb #0h01
  stb 0xa7fc
  ldb #0he0
  stb 0xa7fd
  
  ldy #0h2200
  ldb #0h04
  
_copy_fat:
  
  ldx #0ha800
  
_loop_copy_fat:  
  
  lda ,x+
  sta ,y+
  cmpx #0ha900
  bne _loop_copy_fat
  inc  0ha7fd
  decb
  bne _copy_fat
  
  lda #0h01
  sta 0xa7fc
  lda #0he0
  sta 0xa7fd
  
  ;*******************************************************************
  ; display bios menu
  ;*******************************************************************

  ldy    #0ha7c0
  ldx    #0h1f40
  lda    #0h34
  
_fill_background:

  sta    ,-x
  cmpx   #0h1cc0
  bgt    _fill3
  lda    #0h46
  cmpx   #0h0280
  bgt    _fill3
  lda    #0h34
  
_fill3:

  cmpx   #0
  bne    _fill_background

  inc    ,y  
  ldx    #0h1f40

_fill_foreground:

  clr    ,-x
  cmpx   #0
  bne    _fill_foreground

_display_menu:

  ldx  #_string
  jsr  _s3print0
  
  clr   0haf00             ; clear slide window index
  clr   0haf02             ; clear number of availables files
  clr   0haf03             ; clear selected files

  ldu   #0h2200            ; begining of sliding window
  ldy   #0h0280

_display_loop:
  
  leau  1,u
  ldx   ,u++
  beq   _select_menu
  leax  0h2200,x
  jsr    _s3print1 
  
  leau  3,u
  leay  0h0140,y
  inc   0haf02
  
  bra _display_loop

_pra0_backup: .db 0h00
_pra1_backup: .db 0h00

_select_menu:

  ldy  #0ha7c0
  lda  ,y                  ; preserve pra0 state
  sta  _pra0_backup
  lda  #0h0c
  sta  ,y
  
  lda  1,y                 ; preserve pra1 state
  sta  _pra1_backup
  
  lda  #0h31
  jsr  _fill_select
  clra

_menu_loop:

  anda #0h7e
  sta  1,y
  ldb  1,y
  bitb #0h80  
  beq  _keyboard_hit
  inca
  inca
  bra _menu_loop

_keyboard_hit:

  ;
  ;  DOWN  0h42
  ;    UP  0h62
  ; ENTER  0h68
  ;     Q  0h56
  ;     R  0h2a
  ;     X  0h50
  
  cmpa #0h50
  beq  _s3mo5_model_exit
  cmpa #0h68
  beq  _end_menu_select
  cmpa #0h62
  beq  _select_up
  cmpa #0h42
  beq  _select_down
  cmpa #0h2a
  beq  _hard_reset
  cmpa #0h56
  lbeq _wait_key_release
  bra  _menu_loop

_s3mo5_model_exit:
  lda #0h80
  sta 0ha7ff
  bra _s3mo5_model_exit

_hard_reset:

  clr   0ha7fe
  ldx   #0h2000

_clear_user_pages:
 
  clr   ,x+
  cmpx  #0ha000
  bne   _clear_user_pages
  
  lda   #0h80
  sta   0ha7fe

_endless_loop:
  bra   _endless_loop

_select_down:

  lda   0ha7c1
  anda  #0h80
  beq   _select_down

  lda   0haf02
  deca
  cmpa  0haf03
  beq   _menu_loop
  
  lda   #0h46
  jsr   _fill_select
  inc   0haf03
  lda   #0h31
  jsr   _fill_select
  bra   _menu_loop
  
_select_up:  

  lda   0ha7c1
  anda  #0h80
  beq   _select_up

  clra
  cmpa  0haf03
  beq   _menu_loop
  lda   #0h46
  jsr   _fill_select
  dec   0haf03
  lda   #0h31
  jsr   _fill_select
  bra   _menu_loop

_end_menu_select:

  ; back to first page of fs (0x01e0)
  
  ldb #0h01
  stb 0xa7fc
  ldb #0he0
  stb 0xa7fd

  lda  0haf03
  ldb  #0h06
  mul
  addd #0h03
  ldx  #0ha800
  leax d,x
  ldy  ,x++
  lda  ,x
  
  
  leay 0hff,y   ; first page @0x1e0
  leay 0he1,y
  sty  0ha7fc
  sta  0haf00
  
  ; prevent to get a key typed after return
_wait_key_release:

  lda  0ha7c1
  anda #0h80
  beq  _wait_key_release
  
  ; switch to monitor video ram
  lda    0ha7fe
  anda   #0hfb
  sta    0ha7fe   
  
  lda    0ha7fe ;  test nmi ack
  tfr    a,b
  anda   #0h02
  bne    _return_from_nmi
  jmp  0hf003
  
_return_from_nmi:

  andb   #0hfd          ;  acknowledge nmi
  stb    0ha7fe
  ldb    _pra0_backup    ; restore pra0
  stb    0ha7c0         
  ldb    _pra1_backup    ; restore pra0
  stb    0ha7c1         
  lds    0haf04
  rti

_fill_select:
  pshs a,b,y,x
  pshs a
  ldy  #0ha7c0
  lda  ,y
  anda  #0hfe
  sta  ,y
  
  ldb   0haf03
  aslb
  aslb
  aslb
  lda   #0h28
  mul
  tfr   d,x
  leax  0h0280,x
  ldy   #0h0000 
  puls  a
  
_fill_select_loop:    
  sta  ,x+
  leay 1,y
  cmpy #0h140
  bne  _fill_select_loop
  puls a,b,y,x
  rts

_nmi:

  tfr    s,d                ; already in bios ?
  cmpa   #0haf
  beq    _already_in_bios
  sts    0haf04
  lds    #0haff0           ; set stack
  
  ; switch to bios video ram
  lda    0ha7fe
  ora    #0h04
  sta    0ha7fe   
  jmp    _select_menu



_already_in_bios:
  lda    0ha7fe ;  test nmi ack
  anda   #0hfd   ; acknowledge nmi
  sta    0ha7fe
  rti

_string:
  .dw     0h0000
  .ascii  /S3MO5 BIOS V1.0/
  .db     0hff 
  .dw     0h0140
  .ascii  /(c) 2005 - Olivier Ringot /
  .db     0hff 
  .dw     0h1cc0
  .ascii  /UP & DOWN to select ; ENTER to validate/
  .db     0hff
  .dw     0h1e00
  .ascii  /R to reset ; Q to leave bios/
  .db     0h00


;********************************************************************
; 
;
;
;********************************************************************
_s3print0:

  pshs  y,u,a,b,cc

_s3print_restart0:  
  
  ldu   ,x++
  
_s3print_loop0:

  lda     ,x+
  bita    #0hff
  beq     _s3print_end0
  bmi     _s3print_restart0
  suba    #0h1f
  ldb     #0h08
  mul
  
  ldy     #0hfc9e
  leay    d,y
  
  ldb     #0h08

_s3print_copy0:
  
  lda     ,-y
  sta     ,u
  leau    0h28,u
  decb
  bne      _s3print_copy0
  
  leau    0hfec1,u
  bra      _s3print_loop0
  
_s3print_end0:  
  puls    y,u,a,b,cc
  rts

_s3print1:

  pshs  y,u,a,b,cc

_s3print_restart1:  
  
  tfr   y,u
  
_s3print_loop1:

  lda     ,x+
  bita    #0hff
  beq     _s3print_end1
  bmi     _s3print_restart1
  suba    #0h1f
  ldb     #0h08
  mul
  
  ldy     #0hfc9e
  leay    d,y
  
  ldb     #0h08

_s3print_copy1:
  
  lda     ,-y
  sta     ,u
  leau    0h28,u
  decb
  bne      _s3print_copy1
  
  leau    0hfec1,u
  bra      _s3print_loop1
  
_s3print_end1:  
  puls    y,u,a,b,cc
  rts

;********************************************************************
; Hook routines
;
;
;********************************************************************

; skip k7 synchro
_hook_f168:

  pshs   cc,b
  
  lda  0haf01
  eora #0h01
  beq  _hook_f168_ff
  
  lda  #0h01
  sta  0h2045
  
  lda  0haf01
  inca
  tfr a,b
  eorb #0h09
  beq _hook_f168_reset_counter
  sta 0haf01

_hook_f168_00:
  clra  
  puls   cc,b
  rts

_hook_f168_reset_counter:

  clr 0haf01
  bra _hook_f168_00

_hook_f168_ff:

  lda    #0hff
  inc    0haf01
  puls   cc,b
  rts
  
; read k7 byte
_hook_f181:
  
  pshs  cc,x,b  
  ldb   0haf00
  clra
  ldx   #0ha800
  lda   d,x
  sta   0h2045
  incb
  bne   _hook_f181_end
  
  ; select next file system page
  
  ldx  0ha7fc
  leax 1,x
  stx  0ha7fc
  
_hook_f181_end:

  stb  0haf00
  puls cc,x,b
  rts  

;********************************************************************
; Hook Table
;
;
;********************************************************************

  .org 0haff0

  jmp _hook_f168 ; aff0
  jmp _hook_f181 ; aff3
  jmp _nmi       ; aff6
