%{
    // RKRCommands.y
    // RKRShell
    // Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
    // GNU GPL V2

    #include <cstdio>
    #include <iostream>
    #include <iomanip>
    #include <string>
    #include <cstring>
    #include <unistd.h>
    #define EXIT_SUCCESS 0
    #define EXIT_ERROR 1
    #define OS_WINDOWS 0
    #define OS_MAC_OS 1
    #define OS_LINUX 2
    #define OPERATION_BUFFER_SIZE 256
    #define RKR_SHELL_VERSION 1.0
    #define USER_ENVIRONMENT_VARIABLE "USER"
    #define CURRENT_PATH_ENVIRONMENT_VARIABLE "PWD"
    #define RCOMANDS_ARRAY_SIZE 10
    #define EQUAL_STRING 0
    #define EMPTY_STRING ""

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

    typedef struct recentCommands
    {
        char ** data;
        int size, currentIndex;
    }
    recentCommands;

    // Flex externs
    extern "C" int yylex();
    extern "C" int yyparse();
    extern "C" FILE *yyin;

    // global variables
    recentCommands rcomands;
    char operationBuffer[OPERATION_BUFFER_SIZE];

    // Function prototypes
    void setup();
    void dealloc();
    void showWelcomeMessage();
    void showInput();
    bool isCurrentOSWindows();
    bool isCurrentOSMacOS();
    bool isCurrentOSLinux();
    void initializeRecentCommands(recentCommands * instance, int size);
    char * getRecentCommands(recentCommands instance);
    bool recentCommandsNeedShift(recentCommands instance);
    void shiftRecentCommands(recentCommands * instance);
    void addRecentCommand(char * command, recentCommands * instance);
    void destroyRecentCommands(recentCommands * instance);
    void yyerror(const char *s);
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
%token CD
%token PWD
%token MKDIR
%token <stringValue> UNIX_OPTIONS
%token <stringValue> FILE_NAME
%token RCOMMANDS
%token HELP
%token CLEAR
%token NEW_LINE
%token EXIT
%token QUIT

%%
// Productions (a.k.a. P or R set)
// "commands" is the starting non-terminal symbol (S symbol)
commands:
    command
    | commands command

command:
    LS NEW_LINE
    {
        char * command = "ls";
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | LS UNIX_OPTIONS NEW_LINE
    {
        char * command = strcat("ls ",$2);
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | LS UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        char * aux = strcat(strdup("ls "),$2);
        aux = strcat(aux,strdup(" "));
        char * command = strcat(aux,$3);
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | LS FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("ls "),$2);
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | CD NEW_LINE
    {
        char * command = "cd";
        addRecentCommand(command,&rcomands);
        system(command);
        chdir(strcat(strdup("/Users/"),getenv(USER_ENVIRONMENT_VARIABLE)));
        showInput();
    }
    | CD FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("cd "),$2);
        addRecentCommand(command,&rcomands);
        system(command);
        chdir($2);
        showInput();
    }
    | PWD NEW_LINE
    {   
        char * command = "pwd";
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | PWD UNIX_OPTIONS NEW_LINE
    {
        char * command = strcat(strdup("pwd "),$2);
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | MKDIR FILE_NAME NEW_LINE
    {

    }
    | MKDIR UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        
    }
    | RCOMMANDS NEW_LINE
    {
        addRecentCommand("rcommands",&rcomands);
        cout << getRecentCommands(rcomands);
        showInput();
    }
    | HELP NEW_LINE
    {
        // YET TO IMPLEMENT
        addRecentCommand("help",&rcomands);
        showInput();
    }
    | CLEAR NEW_LINE
    {
        char * command = "clear";
        addRecentCommand(command,&rcomands);
        system(command);
        showInput();
    }
    | NEW_LINE
    {
        showInput();
    }
    | EXIT NEW_LINE
    {
        dealloc();
        return EXIT_SUCCESS;
    }
    | QUIT NEW_LINE
    {
        dealloc();
        return EXIT_SUCCESS;
    }
%%

// Shell lifecycle
int main(int argumentsCount, char ** argumentsList)
{
    setup();
    showWelcomeMessage();
    showInput();
    yyparse();
}

//
void setup()
{
    initializeRecentCommands(&rcomands,RCOMANDS_ARRAY_SIZE);
}

//
void dealloc()
{
    destroyRecentCommands(&rcomands);
}

//
void showWelcomeMessage()
{
    cout << "RKRShell V" << fixed << setw(2) << setprecision(1) << RKR_SHELL_VERSION << endl;
    cout << "Logged in as: " << getenv(USER_ENVIRONMENT_VARIABLE) << endl;
}

//
void showInput()
{
    cout << getenv(USER_ENVIRONMENT_VARIABLE) << " " << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << " $>> ";
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

//
void initializeRecentCommands(recentCommands * instance, int size)
{
    instance->data = (char **)malloc(sizeof(char *) * size);
    for(int index = 0; index < size; index++)
    {
        instance->data[index] = EMPTY_STRING;
    }
    instance->size = size;
    instance->currentIndex = 0;
}

//
char * getRecentCommands(recentCommands instance)
{
    int size = 0;
    char * aux;
    for(int index = 0; index < instance.size; index++)
    {
        size += strlen(instance.data[index]);
    }
    aux = (char *)malloc(sizeof(char) * size);
    for(int index = 0; index < instance.size; index++)
    {
        if(strcmp(instance.data[index],EMPTY_STRING) != EQUAL_STRING)
        {
            sprintf(aux,"%s%s\n",aux,instance.data[index]);
        }
    }
    if(strlen(aux) == 0)
    {
        aux = "There are no recent commands yet\n";
    }
    return aux;
}

//
bool recentCommandsNeedShift(recentCommands instance)
{
    return (instance.currentIndex == instance.size);
}

//
void shiftRecentCommands(recentCommands * instance)
{
    for(int index = 0; index < instance->size - 1; index++)
    {
        instance->data[index] = instance->data[index + 1];
    }
}

void addRecentCommand(char * command, recentCommands * instance)
{
    if(recentCommandsNeedShift((*instance)))
    {
        instance->currentIndex--;
        shiftRecentCommands(instance);
    }
    instance->data[instance->currentIndex++] = command;
}

//
void destroyRecentCommands(recentCommands * instance)
{
    free(instance->data);
}

//
void yyerror(const char * errorMessage)
{
    cout << "EEK, parse error!  Message: " << errorMessage << endl;
    exit(EXIT_ERROR);
}