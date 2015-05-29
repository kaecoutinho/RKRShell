%{
    // RKRCommands.y
    // RKRShell
    // Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
    // GNU GPL V2

    #include <cstdio>
    #include <iostream>
    #include <fstream>
    #include <iomanip>
    #include <string>
    #include <sstream>
    #include <cstring>
    #include <unistd.h>
    #include <time.h>
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
    #define LOG_FILE_NAME "RKRLog.log"

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

    //
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
    fstream logFile;

    // Function prototypes
    void setup();
    void dealloc();
    void showWelcomeMessage();
    void showInput();
    bool isCurrentOSWindows();
    bool isCurrentOSMacOS();
    bool isCurrentOSLinux();
    void initializeLogFile(fstream & logFile);
    void logToFile(char * message, fstream & logFile);
    void logCommandToFile(char * command, fstream & logFile);
    void logErrorToFile(char * error, fstream & logfile);
    string getCurrentDate();
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
%token RM
%token TOUCH
%token DATE
%token WHO
%token WHOIS
%token WHOAMI
%token RCOMMANDS
%token HELP
%token CLEAR
%token NEW_LINE
%token EXIT
%token QUIT
%token <stringValue> OPTIONS
%token <stringValue> FILE_NAME

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
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | LS OPTIONS NEW_LINE
    {
        char * command = strcat("ls ",$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | LS OPTIONS FILE_NAME NEW_LINE
    {
        char * aux = strcat(strdup("ls "),$2);
        aux = strcat(aux,strdup(" "));
        char * command = strcat(aux,$3);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | LS FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("ls "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | CD NEW_LINE
    {
        char * command = "cd";
        system(command);
        chdir(strcat(strdup("/Users/"),getenv(USER_ENVIRONMENT_VARIABLE)));
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | CD FILE_NAME NEW_LINE
    {
        cout << "TESTING";
        char * command = strcat(strdup("cd "),$2);
        system(command);
        chdir($2);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | PWD NEW_LINE
    {   
        char * command = "pwd";
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | PWD OPTIONS NEW_LINE
    {
        char * command = strcat(strdup("pwd "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | MKDIR FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("mkdir "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | MKDIR OPTIONS FILE_NAME NEW_LINE
    {
        char * aux = strcat(strdup("mkdir "),$2);
        aux = strcat(aux,strdup(" "));
        char * command = strcat(aux,$3);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | RM FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("rm "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | RM OPTIONS FILE_NAME NEW_LINE
    {
        char * aux = strcat(strdup("rm "),$2);
        aux = strcat(aux,strdup(" "));
        char * command = strcat(aux,$3);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | TOUCH FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("touch "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | TOUCH OPTIONS FILE_NAME NEW_LINE
    {
        char * aux = strcat(strdup("touch "),$2);
        aux = strcat(aux,strdup(" "));
        char * command = strcat(aux,$3);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | DATE NEW_LINE
    {
        char * command = "date";
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | DATE OPTIONS NEW_LINE
    {
        char * command = strcat(strdup("date "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | WHO NEW_LINE
    {
        char * command = "who";
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | WHO OPTIONS NEW_LINE
    {
        char * command = strcat(strdup("who "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | WHOIS NEW_LINE
    {
        char * command = "whois";
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | WHOIS FILE_NAME NEW_LINE
    {
        char * command = strcat(strdup("whois "),$2);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | WHOIS OPTIONS FILE_NAME NEW_LINE
    {
        char * aux = strcat(strdup("whois "),$2);
        aux = strcat(aux,strdup(" "));
        char * command = strcat(aux,$3);
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();   
    }
    | WHOAMI NEW_LINE
    {
        char * command = "whoami";
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | RCOMMANDS NEW_LINE
    {
        char * command = "rcommands";
        addRecentCommand(command,&rcomands);
        cout << getRecentCommands(rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | HELP NEW_LINE
    {
        char * command = "help";
        cout << "YET TO IMPLEMENT" << endl;
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | CLEAR NEW_LINE
    {
        char * command = "clear";
        system(command);
        addRecentCommand(command,&rcomands);
        logCommandToFile(command,logFile);
        showInput();
    }
    | NEW_LINE
    {
        showInput();
    }
    | EXIT NEW_LINE
    {
        char * command = "exit";
        dealloc();
        logCommandToFile(command,logFile);
        return EXIT_SUCCESS;
    }
    | QUIT NEW_LINE
    {
        char * command = "quit";
        dealloc();
        logCommandToFile(command,logFile);
        return EXIT_SUCCESS;
    }

    // // TEST PURPOSE ONLY
    // | FILE_NAME NEW_LINE
    // {
    //     cout << "READ: " << $1 << endl;
    // }
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
    char * message;
    initializeRecentCommands(&rcomands,RCOMANDS_ARRAY_SIZE);
    initializeLogFile(logFile);
    message = "Started RKRShell logged as ";
    // message = strcat(message,getenv(USER_ENVIRONMENT_VARIABLE));
    // message = strcat(message," on ");
    // message = strcat(message,getCurrentDate().c_str());
    // logToFile(message,logFile);
}

//
void dealloc()
{
    char * message;
    destroyRecentCommands(&rcomands);
    message = "Ended RKRShell logged as ";
    // message = strcat(message,getenv(USER_ENVIRONMENT_VARIABLE));
    // message = strcat(message," on ");
    // message = strcat(message,getCurrentDate().c_str());
    // logToFile(message,logFile);
    logFile.close();
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
    cout << getenv(USER_ENVIRONMENT_VARIABLE) << " @ [" << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << "] $>> ";
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
void initializeLogFile(fstream & logFile)
{
    logFile.open(LOG_FILE_NAME,fstream::out | std::ios_base::app);
}

void logToFile(char * message, fstream & logFile)
{
    logFile << "* " << message << endl;;
}

//
void logCommandToFile(char * command, fstream & logFile)
{
    logFile << "* " << getenv(USER_ENVIRONMENT_VARIABLE) << " [" << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << "] on " << getCurrentDate() << " - [OK] - Command \"" << command << "\" executed successfully" << endl;
}

//
void logErrorToFile(char * error, fstream & logfile)
{
    logFile << "* " << getenv(USER_ENVIRONMENT_VARIABLE) << " [" << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << "] on " << getCurrentDate() << " - [ERROR] - Error happened: " << error << endl;
}

//
string getCurrentDate()
{
    time_t rawTime;
    struct tm * timeInfo;
    ostringstream aux;
    rawTime = time(NULL);
    timeInfo = localtime(&rawTime);
    aux << timeInfo->tm_mday << "/" << timeInfo->tm_mon + 1 << "/" << timeInfo->tm_year + 1900 << " @ ";
    if(timeInfo->tm_hour < 10)
    {
        aux << "0" << timeInfo->tm_hour << ":";
    }
    else
    {
        aux << timeInfo->tm_hour << ":";
    }
    if(timeInfo->tm_min < 10)
    {
        aux << "0" << timeInfo->tm_min << ":";
    }
    else
    {
        aux << timeInfo->tm_min << ":";
    }
    if(timeInfo->tm_sec < 10)
    {
        aux << "0" << timeInfo->tm_sec;
    }
    else
    {
        aux << timeInfo->tm_sec;
    }
    return aux.str();
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
    char * aux = EMPTY_STRING;
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

//
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
    cout << "Unrecognizable command detected, exiting now" << endl;
    logErrorToFile((char *)errorMessage,logFile);
    exit(EXIT_ERROR);
}