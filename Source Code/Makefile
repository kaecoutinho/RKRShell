# Makefile
# RKRShell
# Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
# GNU GPL V2

# Constants

PROJECT = RKRCommands
OBJECTS = lex.yy.o lex.yy.c $(PROJECT).tab.o $(PROJECT).tab.c $(PROJECT).tab.h *.log
CC = g++
CFLAGS = -w
LDFLAGS = -ll
LEX = flex
YACC = bison
YFLAGS = -d

# Default target

all: lex.yy.o $(PROJECT).tab.o
	$(CC) $(CFLAGS) lex.yy.o $(PROJECT).tab.o -o $(PROJECT) $(LDFLAGS)

# File targets

# Bison files

$(PROJECT).tab.c $(PROJECT).tab.h: $(PROJECT).y
	$(YACC) $(YFLAGS) $<

# Flex files

lex.yy.c: $(PROJECT).l $(PROJECT).tab.h
	$(LEX) $<

# Object files

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c $<

$(PROJECT).tab.o: $(PROJECT).tab.c $(PROJECT).tab.h
	$(CC) $(CFLAGS) -c $<

# Clean targets

clean:
	rm -rf $(OBJECTS)

cleanall:
	rm -rf $(OBJECTS) $(PROJECT) 