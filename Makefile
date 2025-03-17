ALL_ASM = $(wildcard src/*.asm) $(wildcard src/*.inc)

all: bosconian checkerboard

runcheckerboard: checkerboard $(ALL_ASM)
	~/emu/x16/x16-47/x16emu -prg CHECKER.PRG -run

checkerboard: $(ALL_ASM)
	cl65 -C cx16-asm.cfg -t cx16 -o CHECKER.PRG -l ./listings/aider.list ./src/aider.asm

bosconian: buildbosconian $(ALL_ASM) 
	~/emu/x16/x16-47/x16emu -prg BOSCONIAN.PRG -run

buildbosconian: $(ALL_ASM)
	cl65 -t cx16 -o BOSCONIAN.PRG -l ./listings/bosconian.list ./src/bosconian.asm

clean:
	rm -f *.PRG listings/*.list *.o
