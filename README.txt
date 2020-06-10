================================================================================
= S3MO5 - a MO5 computer redesign for the Spartan 3 starter kit
================================================================================

Copyright (C) 2005 - Olivier Ringot <oringot@gmail.com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, 
Boston, MA  02110-1301, USA.

================================================================================
= RELEASE V1.0
================================================================================

================================================================================
= Directory structure
================================================================================

I) The behavioural C model of the S3MO5 is located in the ./model directory

  o the model itself :
  
    s3mo5.h         S3MO5 model
    s3mo5.c
    memory.c        
    
    alu.c           CPU6809 model
    opcode.c
    exec.c
    
    disassemble.c   CPU6809 disassembler
    
    mtpack.h        compression routine for cpu logging 
    mtpack.c
    
    s19.h           S19 file format routines
    s19.c

  o Some utilities :
  
    bin2ram16.c     convert .bin file to memory file suitable for testbench memory model
    bintos19.c      convert .bin file to .s19 file
    dither.c        convert a 16 true color .ppm picture to a dithered 8 color .ppm picture
    genfs.c         generate a file system suitable for the S3MO5 bios
    genmire.c       generate a test dithered picture
    mtpack-cat.c    uncompress cpu log file
    s3_peek.c       read a byte from the S3MO5 through the UART link
    s3_poke.c       write a byte to the S3MO5 though the UART link
    s3_init         upload monitor, s3bios and filesystem to the S3MO5 through the UART link
 
  o the S3MO5 bios
  
    s3bios.s
    
 
II) The synthesizable S3MO5 VHDL design is located into the ./fpga/hdl directory

  o the processor opcode compatible with the 6809

    cpu_package.vhd
    cpu6809.vhd     processor top
    alu.vhd         arithmetic and logic unit
    datapath.vhd    processor datapath
    sequencer.vhd   processor state machine

  o the PS/2 keyboard controller

    keyboard_package.vhd
    keyboard.vhd

  o the memory controller

    memcntl_package.vhd
    memcntl.vhd

  o a minimum uart
  
    uart.vhd
  
  o a SVGA display controller 
  
    videocntl_package.vhd
    videocntl.vhd

  o the S3MO5 top

    s3mo5_package.vhd
    s3mo5.vhd

  o configurations for RTL or GL simulation
  
    s3mo5_rtl_conf.vhd
    s3mo5_gate_conf.vhd
  
  o testbenches

    ram256kx16.vhd
    testbench_alu.vhd
    testbench_cpu6809.vhd
    testbench_datapath.vhd
    testbench_keyboard.vhd
    testbench_memcntl.vhd
    testbench_s3mo5.vhd
    testbench_s3mo5_package.vhd
    testbench_uart.vhd
    testbench_videocntl.vhd

  o the constraint file for PAR
  
    s3mo5.ucf

================================================================================
= Terminal configuration
================================================================================

RS232: 115200 bauds, 8 bits, no parity, 1 start, 1 stop

stty -F $SERIAL_DEVICE 115200 -parenb -clocal -crtscts -cstopb -icrnl -ixon -ixoff \
     -parmrk -onlcr -opost -isig -icanon -echo -echok -iexten -echoe -echok \
     -echoctl -echoke

when $SERIAL_DEVICE can be /dev/ttyS0 , /dev/ttyS1 , etc...

================================================================================
= Model building
================================================================================

O) Required tools

  o as6809 (http://nostalgies.thomsonistes.org/dev/asm-thomson.tar.gz)
  o GNU development suit
  o Perl

I) Monitor preparation

  1)The MO5 monitor rom is not included in this package, you have first to download 
    it from the web. 

  2)Once downloaded, verify the file MD5 hash. 
    The expected signature is cb15b8d3423acc09edc2b2a08fda3824.

  3)copy the monitor file into the ./model directory with the file name 'mo5monitor.bin'.

II) File system preparation

  1) In ./model directory, edit the 'fs.txt' file to populate the filesystem with the .k7 images.
     Each entry is described by a group of two lines, the first one indicating the .k7 file path,
     and the second one defining the title entry displayed under the S3MO5 bios.
  
III) Model compilation 

  Once steps I) & II) done, type 'make' in the ./model directory. This will build the s3mo5 model
  , the s3mo5 bios, all the related utilities and patch the monitor rom.
  
================================================================================
= Running the C model
================================================================================
  
  In ./model, type 's3mo5 --s19=s3mo5.s19' to execute the C model.
  The model options can be displayed by typing 's3mo5 --help'
  
================================================================================
= Programming the S3MO5 FPGA
================================================================================

  Plug a SVGA screen, a PS/2 keyboard to the Spartan3 Starter Kit and a RS-232
  cable in between the S3SK and the PC.
  (At this time, a random pattern is displayed on the SVGA screen)
  
  Once the terminal configured and the RS232 cable plugged, verify if the S3MO5
  memory is accessible by performing some memory accesses :
  
  ie: 
  
  '>s3_poke 0x0000 0xae'
  '>s3_peek 0x0000' should return 0xae   
  
  The memory upload is performed with the 's3_init' command :
  
  '>s3_init mo5rom_patch_bios.bin s3bios.bin fs.bin'
  
  After the uploading completion, the S3MO5 is ready.
  
================================================================================
= Switches and buttons meaning
================================================================================
  pbutton(3) : reset
  switch(7)  : irq_sel (timer 20 ms or vsync 13.3 ms)
  switch(2)  : time average for color display
  switch(1)  : 7 segments display (ps2=0;uart=1)
  switch(0)  : turbo (8.33 MHz or 1 MHz)

================================================================================
= TO DO
================================================================================

  o Optical pen
  o Improve s3mo5 bios in order to support write access to FS
  o Keyboard support for multiple key pressed
  
  
