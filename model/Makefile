######################################################################
# 
#  s3mo5 model -  emulateur MO5
#  (c) Olivier Ringot - October 15 , 2004
# 
#  $Revision: $
#  $Date: $
#  $Source: $
#  $Log: $
# 
######################################################################

#CFLAGS = -fprofile-arcs -ftest-coverage -pg -O0
CFLAGS = -O3

all:s3mo5 mtpack-cat extractk7 genfs s3_init s3_peek s3_poke bintos19 bintoram16 s3mo5.s19 dump2ppm

s3mo5: s3mo5.o opcode.o exec.o disassemble.o memory.o alu.o mtpack.o s19.o
	gcc $(CFLAGS) -L/usr/X11R6/lib -lX11 -lz -o s3mo5 s3mo5.o opcode.o exec.o disassemble.o memory.o alu.o mtpack.o s19.o

s3mo5.o: s3mo5.c s3mo5.h
	gcc $(CFLAGS) -I/usr/X11R6/include -c s3mo5.c

opcode.o: opcode.c s3mo5.h
	gcc $(CFLAGS) -c opcode.c

exec.o: exec.c s3mo5.h
	gcc $(CFLAGS) -c exec.c

alu.o: alu.c s3mo5.h
	gcc $(CFLAGS) -c alu.c

disassemble.o: disassemble.c s3mo5.h
	gcc $(CFLAGS) -c disassemble.c

memory.o: memory.c s3mo5.h
	gcc $(CFLAGS) -c memory.c

mtpack.o: mtpack.c mtpack.h
	gcc $(CFLAGS) -c mtpack.c

das6809: das6809.o disassemble.o opcode.c exec.c
	gcc $(CFLAGS) -o das6809 das6809.o disassemble.o opcode.c exec.c
    
das6809.o: das6809.c
	gcc $(CFLAGS) -c das6809.c

extractk7: extractk7.c
	gcc $(CFLAGS) -o extractk7 extractk7.c

mtpack-cat: mtpack-cat.o mtpack.o
	gcc $(CFLAGS) -lz -o mtpack-cat mtpack-cat.o mtpack.o

mtpack-cat.o: mtpack-cat.c mtpack.h
	gcc $(CFLAGS) -c mtpack-cat.c

genfs: genfs.c
	gcc $(CFLAGS) -o genfs genfs.c

s3_peek: s3_peek.c
	gcc $(CFLAGS) -o s3_peek s3_peek.c

s3_poke: s3_poke.c
	gcc $(CFLAGS) -o s3_poke s3_poke.c

s3_init: s3_init.c
	gcc $(CFLAGS) -o s3_init s3_init.c

dump2ppm: dump2ppm.c
	gcc $(CFLAGS) -o dump2ppm dump2ppm.c

s19.o: s19.c s19.h
	gcc $(CFLAGS) -c s19.c

bintos19.o: bintos19.c s19.c s19.h
	gcc $(CFLAGS) -c bintos19.c

bintos19: bintos19.o s19.o 
	gcc $(CFLAGS) -o bintos19 bintos19.o s19.o

bintoram16: bintoram16.c
	gcc $(CFLAGS) -o bintoram16 bintoram16.c

clean:
	rm -f *.o *.g* *.bb* *.da* gmon.out s3mo5 das6809 dump.ppm mtpack-cat genfs 
	rm -f extractk7 fs.bin sounddump.bin s3_peek s3_poke s3_init bintos19 s3_init
	rm -f s3mo5.s19 bintoram16 dump2ppm mo5rom_patch_bios.bin mo5rom.txt
	rm -f *.lst obj2bin coverage.bin coverage.o s3bios.o s3bios.bin s3bios.lst

fs.bin: genfs fs.txt
	genfs fs.txt

s3bios.bin: s3bios.o obj2bin
	obj2bin s3bios.o s3bios.bin 0xa900 0xafff

s3bios.o: s3bios.s
	as6809 -l s3bios.s

obj2bin: obj2bin.c
	gcc -o obj2bin obj2bin.c

mo5rom_patch_bios.bin:
	@test -e  mo5monitor.bin || (\
      echo "error: unable to find the monitor file" ;\
      echo "  1) You need first to get the MO5 rom" ;\
      echo "  2) Check the md5 checksum, it must be cb15b8d3423acc09edc2b2a08fda3824" ;\
      echo "  3) Name it 'mo5monitor.bin'" ; exit 1)
	xxd mo5monitor.bin > mo5rom.txt
	cat mo5rom.txt | patch -p0 < monitor.patch
	xxd -r mo5rom.txt mo5rom_patch_bios.bin

s3mo5.s19: mo5rom_patch_bios.bin s3bios.bin fs.bin
	bintos19 0x18000:mo5rom_patch_bios.bin,0x1c900:s3bios.bin,0x1e000:fs.bin s3mo5.s19

update_ram: mo5rom_patch_bios.bin fs.bin s3bios.bin
	echo "9999999999999999" > floppy.bin
	dd if=/dev/zero of=null.bin bs=1024 count=32
	dd if=fs.bin    of=fs_0.bin bs=1    count=401408
	dd if=fs.bin    of=fs_1.bin bs=1    count=524288 skip=401408
	bintoram16 0x4000:null.bin,0xc000:mo5rom_patch_bios.bin,0xe000:floppy.bin,0xe480:s3bios.bin,0xf000:fs_0.bin ../fpga/sim/stimuli/tb_s3mo5_ram0.txt	
	bintoram16 0x0000:fs_1.bin ../fpga/sim/stimuli/tb_s3mo5_ram1.txt
	rm -f floppy.bin null.bin fs_0.bin fs_1.bin

coverage: s3mo5
	s3mo5 fullrom 1 > log
	gcov s3mo5.c         
	gcov disassemble.c         
	gcov memory.c         
	gcov opcode.c         
	gcov exec.c         
