%{
	// RKRCommands.l
	// RKRShell
	// Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
	// GNU GPL V2

    #include <cstdio>
    #include <iostream>
    #include "RKRCommands.tab.h"

	// Flex analyser constant declaration
    #ifndef YY_DECL
    #define YY_DECL extern "C" int yylex()
    #endif

    // Default namespace
    using namespace std;
%}

%%
[ \t]							;
"ls"|"LS"						{
									return LS;
								}
"dir"|"DIR"						{
									return DIR;
								}
"cd"|"CD"						{
									return CD;
								}
"pwd"|"PWD"						{
									return PWD;
								}
"mkdir"|"MKDIR"					{
									return MKDIR;
								}
"rm"|"RM"						{
									return RM;
								}
"del"|"DEL"						{
									return DEL;
								}
"touch"|"TOUCH"					{
									return TOUCH;
								}
"date"|"DATE"					{
									return DATE;
								}
"who"|"WHO"						{
									return WHO;
								}
"whois"|"WHOIS"					{
									return WHOIS;
								}
"whoami"|"WHOAMI"				{
									return WHOAMI;
								}
"cp"|"CP"						{
									return CP;
								}
"xcopy"|"XCOPY"					{
									return XCOPY;
								}
"mv"|"MV"						{
									return MV;
								}
"move"|"MOVE"					{
									return MOVE;
								}
"cat"|"CAT"						{
									return CAT;
								}
"type"|"TYPE"					{
									return TYPE;
								}
"rmdir"|"RMDIR"					{
									return RMDIR;
								}
"nano"|"NANO"					{
									return NANO;
								}
"rcommands"|"RCOMMANDS"			{
									return RCOMMANDS;
								}
"help"|"HELP"					{
									return HELP;
								}	
"version"|"VERSION"				{
									return VERSION;
								}
"clear"|"CLEAR"					{
									return CLEAR;
								}
"cls"|"CLS"						{
									return CLS;
								}
"exit"|"EXIT"					{
									return EXIT;
								}
"quit"|"QUIT"					{
									return QUIT;
								}
-[a-zA-Z]+						{
									yylval.stringValue = strdup(yytext);
									return UNIX_OPTIONS;
								}
\/-?[a-zA-Z]:?-?[a-zA-Z]?		{
									yylval.stringValue = strdup(yytext);
									return NT_OPTIONS;
								}
[a-zA-Z0-9*:~_@!-<>\/\\\.]+		{
									yylval.stringValue = strdup(yytext);
									return FILE_NAME;
								}
[\n]							{
									return NEW_LINE;
								}
.								;
%%