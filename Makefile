CA = ca65
CFLAGS =
LD = ld65
LDFLAGS = -v
LDCFG = krisos.cfg
LDMAP = krisos.map
CONFIG = config.inc
TARGET = kernel.bin
SERIAL = /dev/tty.usbserial-A50285BI

# Order currently matters to the linker!
OBJS =  zeropage.o \
	kernel.o \
	io/via.o \
	io/lcd.o \
	io/acia.o \
	io/led.o \
	io/beep.o \
	util/binhex.o \
	util/print.o \
	util/delay.o \
	mem/memtest.o \
	mem/peekpoke.o \
	stdlib/stdlib.o \
	term/term.o \
	term/command.o \
	xmodem/xmodem.o \
	util/clock.o

all: $(TARGET)

%.o: %.s $(CONFIG) $(LDCFG)
	$(CA) $(CFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -C $(LDCFG) -m $(LDMAP) -o $(TARGET) $(OBJS) 

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET) $(LDMAP)

.PHONY: burn
burn: $(TARGET)
	minipro -p AT28C256 -w $(TARGET)

.PHONY: terminal
terminal:
	picocom -b 19200 --send-cmd 'lsx -Xb' $(SERIAL)
