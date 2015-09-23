# Makefile
# RKRShell
# Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
# GNU GPL V2

# Constants

PREFIX = RKRCommands
OBJECTS = lex.yy.o lex.yy.c $(PREFIX).tab.o $(PREFIX).tab.c $(PREFIX).tab.h *.log
CC = g++
CFLAGS = -w
LDFLAGS = -ll
LEX = flex
YACC = bison
YFLAGS = -d
OUTPUT = RKRShell

# Default target

all: lex.yy.o $(PREFIX).tab.o
	$(CC) $(CFLAGS) lex.yy.o $(PREFIX).tab.o -o $(OUTPUT) $(LDFLAGS)

# File targets

# Bison files

$(PREFIX).tab.c $(PREFIX).tab.h: $(PREFIX).y
	$(YACC) $(YFLAGS) $<

# Flex files

lex.yy.c: $(PREFIX).l $(PREFIX).tab.h
	$(LEX) $<

# Object files

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c $<

$(PREFIX).tab.o: $(PREFIX).tab.c $(PREFIX).tab.h
	$(CC) $(CFLAGS) -c $<

# Clean targets

clean:
	rm -rf $(OBJECTS)

cleanall:
	rm -rf $(OBJECTS) $(PREFIX) 