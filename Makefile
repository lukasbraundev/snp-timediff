#=============================================================================
#
# Makefile
#
#-----------------------------------------------------------------------------
#
# DHBW Ravensburg - Campus Friedrichshafen
#
# Vorlesung Systemnahe Programmierung
#
# Author: Ralf Reutemann
#
#=============================================================================

CC          = gcc
LD          = ld
NASM        = nasm
NASMOPT64   = -g -f elf64 -F dwarf
LDOPT64     = 
CFLAGS      = -Wall -g -std=gnu11 -O2 -static
INCDIR      = ./

TARGETS     = timediff list_test

.PHONY: all
all: $(TARGETS)

timediff : timediff.o list.o error_handler.o ASCII_to_timeval.o timeval_to_ASCII.o timeval_to_daystring.o uint_to_ASCII.o
	$(LD) $(LDOPT64) -o $@ $^

timediff.o : $(INCDIR)/syscall.inc

list_test : list_test.o list.o
	$(CC) $(CFLAGS) -o $@ $^

%.o : %.asm
	$(NASM) $(NASMOPT64) -I$(INCDIR) -l $(basename $<).lst -o $@ $<

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f *.o *.lst $(TARGETS)

