%{
    #include <cstdio>
    #include <iostream>
    #include <string>
    #include "RKRCommands.tab.h"
    #define YY_DECL extern "C" int yylex()

    // Default namespace
    using namespace std;
%}

%%
[ \t];
"ls"
{			
	return LS;
}
-[a-zA-Z]+
{
	yylval.stringValue = strdup(yytext);
	return UNIX_OPTIONS;
}
[a-zA-Z]+				
{
	yylval.stringValue = strdup(yytext);
	return FILE_NAME;
}
[\n]
{
	return EXIT;
}
.;
%%