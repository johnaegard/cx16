ALL_ASM = $(wildcard *.asm) $(wildcard *.inc)

all: $(ALL_ASM)
	cl65 -t cx16 -o BOSCONIAN.PRG -l ./listings/bosconian.list ./src/bosconian.asm

clean:
	rm -f *.PRG list/*.list *.o