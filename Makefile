ASM=nasm
ASMFLAGS=-f macho64 -g
CC=clang
LDFLAGS=-Wl,-no_pie -lc -lSystem
CFLAGS=-Wall -Wextra -Wno-incompatible-library-redeclaration -nostdlib -g

LIBS=mac64io.o
HEADERS=mac64io.h
CBINS=hello_c

ASMSRC=$(wildcard *.S)
CSRC=$(wildcard *.c)
SRC=$(ASMSRC) $(CSRC)
ASMHEADERS=$(wildcard *.inc)
ASMOBJS=$(patsubst %.S, %.o, $(ASMSRC))
COBJS=$(patsubst %.c, %.o, $(CSRC))
OBJS=$(ASMOBJS) $(COBJS)
BIN=$(patsubst %.o, %, $(filter-out $(LIBS), $(OBJS)))

all: $(BIN)

$(ASMOBJS): %.o: %.S $(ASMHEADERS)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(COBJS): %.o: %.c $(HEADERS)
	$(CC) -c $< -o $@ $(CFLAGS)

$(CBINS): %: %.o $(LIBS)
	$(CC) $< -o $@ $(LIBS) $(LDFLAGS) $(CFLAGS)

%: %.o $(LIBS)
	$(CC) $< -o $@ $(LIBS) $(LDFLAGS)

.PHONY: clean

clean:
	rm -f $(BIN) $(OBJS)
