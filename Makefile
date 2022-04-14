# Copyright 2022 Geert Janssen

INCLUDES = -Iinclude
FPCFLAGS = $(INCLUDES) -g -O2

PROG = parser

.PHONY: all
all: $(PROG)

parser: parser.p
	fpc $(FPCFLAGS) $<

.PHONY: test
test: $(PROG)
	./parser < ex/newll1.test

.PHONY: clean
clean:
	@-rm -f *.o *.ppu
	@-rm -f $(PROG) listing
