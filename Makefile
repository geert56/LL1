# Copyright 2022 Geert Janssen

INCLUDES = -Iinclude
FPCFLAGS = $(INCLUDES) -g -O2

PROG = ll1

.PHONY: all
all: $(PROG)

ll1: ll1.p
	fpc $(FPCFLAGS) $<

.PHONY: test
test: $(PROG)
	./$(PROG) ex/ella.tax

.PHONY: clean
clean:
	@-rm -f *.o *.ppu
	@-rm -f $(PROG) listing
