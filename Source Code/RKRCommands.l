%{
	// RKRCommands.l
	// RKRShell
	// Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
	// GNU GPL V2

    #include <cstdio>
    #include <iostream>
    #include "RKRCommands.tab.h"
    #define YY_DECL extern "C" int yylex()

    // Default namespace
    using namespace std;
%}

%%
[ \t]							;
"ls"							{
									return LS;
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
"clear"							{
									return CLEAR;
								}
"exit"							{
									return EXIT;
								}
"quit"							{
									return QUIT;
								}
-[a-zA-Z]+						{
									yylval.stringValue = strdup(yytext);
									return OPTIONS;
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