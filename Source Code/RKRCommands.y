%{
    #include <cstdio>
    #include <iostream>
    #include <string>
    #define EXIT_SUCCESS 0
    #define EXIT_ERROR 1
    #define OS_WINDOWS 0
    #define OS_MAC_OS 1
    #define OS_LINUX 2

    // OS detection
    #if (defined _WIN32 || defined _WIN64 || defined __TOS_WIN__ || defined __WIN32__ || defined __WINDOWS__)
        #define CURRENT_OS OS_WINDOWS
    #elif (defined __APPLE__ || defined __MACH__ || defined Macintosh || defined macintosh)
        #define CURRENT_OS OS_MAC_OS
    #elif (defined __gnu_linux__ || defined __linux__ || defined __linux || defined linux)
        #define CURRENT_OS OS_LINUX
    #endif

    // Default namespace
    using namespace std;

    // Flex externs
    extern "C" int yylex();
    extern "C" int yyparse();
    extern "C" FILE *yyin;

    // Function prototypes
    void yyerror(const char *s);
    void showInput();
    bool isCurrentOSWindows();
    bool isCurrentOSMacOS();
    bool isCurrentOSLinux();
%}

// Union structure's definition
%union
{
    int integerValue;
    float floatValue;
    char * stringValue;
}

// Recognizable tokens (terminal symbols a.k.a. T set)
%token LS
%token <stringValue> UNIX_OPTIONS
%token <stringValue> FILE_NAME
%token NEW_LINE
%token EXIT

%%
// Productions (a.k.a. P or R set)
// "commands" is the starting non-terminal symbol (S symbol)

commands:
    command NEW_LINE
    | commands command NEW_LINE

command:
    LS
    {
        system("ls");
        showInput();
    }
    | LS UNIX_OPTIONS
    {
        const char *c = strcat(strdup("ls "),$2);
        system(c);
        showInput();
    }
    | LS UNIX_OPTIONS FILE_NAME 
    {
        char *p1 = strcat(strdup("ls "),$2);
        char *p2 = strcat(p1,strdup(" "));
        const char *p3 = strcat(p2,$3);
        system(p3);
        showInput();   
    }
    | LS FILE_NAME
    {
        const char *c = strcat(strdup("ls "),$2);
        system(c);
        showInput();
    }
    | EXIT
    {
        return EXIT_SUCCESS;
    }
%%

// Shell lifecycle
int main(int argumentsCount, char ** argumentsList)
{
    cout << "MOTHERFUCKER IM USING THIS SYSTEM " << CURRENT_OS << endl;
    showInput();
    yyparse();
    return EXIT_SUCCESS;
}

//
void yyerror(const char * errorMessage)
{
    cout << "EEK, parse error!  Message: " << errorMessage << endl;
    exit(EXIT_ERROR);
}

//
void showInput()
{
    cout << "$>> ";
}

//
bool isCurrentOSWindows()
{
    return (CURRENT_OS == OS_WINDOWS);
}

//
bool isCurrentOSMacOS()
{
    return (CURRENT_OS == OS_MAC_OS);
}

//
bool isCurrentOSLinux()
{
    return (CURRENT_OS == OS_LINUX);
}