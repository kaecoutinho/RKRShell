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
"ls"							{
									return LS;
								}
"dir"|"DIR"						{
									return DIR;
								}
"cd"							{
									return CD;
								}
"pwd"							{
									return PWD;
								}
"mkdir"							{
									return MKDIR;
								}
"rm"							{
									return RM;
								}
"touch"							{
									return TOUCH;
								}
"date"							{
									return DATE;
								}
"who"							{
									return WHO;
								}
"whois"							{
									return WHOIS;
								}
"whoami"						{
									return WHOAMI;
								}
"rcommands"						{
									return RCOMMANDS;
								}
"help"							{
									return HELP;
								}	
"version"						{
									return VERSION;
								}
"clear"							{
									return CLEAR;
								}
"cls"							{
									return CLS;
								}
"exit"							{
									return EXIT;
								}
"quit"							{
									return QUIT;
								}
-[a-zA-Z]+						{
									yylval.stringValue = strdup(yytext);
									return UNIX_OPTIONS;
								}
\/-?[a-zA-Z]:?-?[a-zA-Z]?]		{
									yylval.stringValue = strdup(yytext);
									return NT_OPTIONS;
								}
[a-zA-Z0-9:~_@!-\/\\\.]+		{
									yylval.stringValue = strdup(yytext);
									return FILE_NAME;
								}
[\n]							{
									return NEW_LINE;
								}
.								;
%%