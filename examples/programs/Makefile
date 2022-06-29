all: irqbtn music
.PHONY: all

.PHONY: irqbtn
irqbtn:
	ca65 -I ../../io -I ../../stdlib irqbtn.s
	ld65 -C load.cfg -o irqbtn.raw irqbtn.o
	printf "\x00\x10" | cat - irqbtn.raw > irqbtn.bin

.PHONY: music
music:
	ca65 -I ../../io -I ../../stdlib music.s
	ld65 -C load.cfg -o music.raw music.o
	printf "\x00\x10" | cat - music.raw > music.bin

clean:
	rm *.o
	rm *.raw
	rm *.bin
