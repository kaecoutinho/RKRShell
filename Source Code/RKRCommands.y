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
    #include <boost/algorithm/string/replace.hpp>
    #define EXIT_SUCCESS 0
    #define EXIT_ERROR 1
    #define OS_WINDOWS 0
    #define OS_MAC_OS 1
    #define OS_LINUX 2
    #define OPERATION_BUFFER_SIZE 256
    #define RKR_SHELL_VERSION 1.0
    #define UNIX_USER_ENVIRONMENT_VARIABLE "USER"
    #define NT_USER_ENVIRONMENT_VARIABLE "USERNAME"
    #define UNIX_CURRENT_PATH_ENVIRONMENT_VARIABLE "PWD"
    #define NT_CURRENT_PATH_ENVIRONMENT_VARIABLE "CD"
    #define UNIX_HOME_DIRECTORY_ENVIRONMENT_VARIABLE "HOME"
    #define NT_HOME_DIRECTORY_ENVIRONMENT_VARIABLE "USERPROFILE"
    #define RCOMANDS_ARRAY_SIZE 10
    #define EQUAL_STRINGS 0
    #define EMPTY_STRING ""
    #define LOG_FILE_NAME "RKRLog.log"
    #define WHITESPACE_SPECIAL_IDENTIFIER "+_+"
    #define WHITESPACE_SPECIAL_CHARACTER " "
    #define NOT_SUPPORTED_COMMAND "nscommand"

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

    // Recent commands data structure
    typedef struct recentCommands
    {
        string * data;
        int size, currentIndex;
    }
    recentCommands;

    // Flex externs
    extern "C" int yylex();
    extern "C" int yyparse();
    extern "C" FILE *yyin;

    // Global variables
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
    void logToFile(string message, fstream & logFile);
    void logCommandToFile(char * command, fstream & logFile);
    void logCommandToFile(string command, fstream & logFile);
    void logErrorToFile(char * error, fstream & logfile);
    void logErrorToFile(string error, fstream & logfile);
    string getCurrentDate();
    void initializeRecentCommands(recentCommands & instance, int size);
    string getRecentCommands(recentCommands instance);
    bool recentCommandsNeedShift(recentCommands instance);
    void shiftRecentCommands(recentCommands & instance);
    void addRecentCommand(string command, recentCommands & instance);
    void destroyRecentCommands(recentCommands & instance);
    string decodeFileName(char * fileName);
    string decodeFileName(string fileName);
    void executeCommand(string command);
    string convertUnixOptionsIntoNTOptions(string options);
    string convertNTOptionsIntoUnixOptions(string options);
    void yyerror(const char * errorMessage);
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
%token DIR
%token CD
%token PWD
%token MKDIR
%token RM
%token DEL
%token TOUCH
%token DATE
%token WHO
%token WHOIS
%token WHOAMI
%token RCOMMANDS
%token HELP
%token VERSION
%token CLEAR
%token CLS
%token NEW_LINE
%token EXIT
%token QUIT
%token <stringValue> UNIX_OPTIONS
%token <stringValue> NT_OPTIONS
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
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir" : "ls");
        executeCommand(command.str());
        showInput();
    }
    | LS UNIX_OPTIONS NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir " : "ls ") << ((isCurrentOSWindows()) ? convertUnixOptionsIntoNTOptions(string($2)) : $2);
        executeCommand(command.str());
        showInput();
    }
    | LS UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir " : "ls ") << ((isCurrentOSWindows()) ? convertUnixOptionsIntoNTOptions(string($2)) : $2) << " " << decodeFileName($3);
        executeCommand(command.str());
        showInput();
    }
    | LS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir " : "ls ") << decodeFileName($2);
        executeCommand(command.str());
        showInput();
    }
    | DIR NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir" : "ls");
        executeCommand(command.str());
        showInput();
    }
    | DIR NT_OPTIONS NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir " : "ls ") << ((isCurrentOSWindows()) ? $2 : convertNTOptionsIntoUnixOptions(string($2)));
        executeCommand(command.str());
        showInput();
    }
    | DIR NT_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir " : "ls ") << ((isCurrentOSWindows()) ? $2 : convertNTOptionsIntoUnixOptions(string($2))) << " " << decodeFileName($3);
        cout << command.str();
        executeCommand(command.str());
        showInput();
    }
    | DIR FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir " : "ls ") << decodeFileName($2);
        executeCommand(command.str());
        showInput();
    }
    | CD NEW_LINE
    {
        ostringstream command;
        command << "cd";
        executeCommand(command.str());
        chdir(getenv((((isCurrentOSWindows()) ? NT_HOME_DIRECTORY_ENVIRONMENT_VARIABLE : UNIX_HOME_DIRECTORY_ENVIRONMENT_VARIABLE))));
        showInput();
    }
    | CD FILE_NAME NEW_LINE
    {
        ostringstream command;
        string fileName = decodeFileName($2);
        command << "cd " << fileName;
        executeCommand(command.str());
        chdir(fileName.c_str());
        showInput();
    }
    | PWD NEW_LINE
    {   
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir" : "pwd");
        executeCommand(command.str());
        showInput();
    }
    | PWD UNIX_OPTIONS NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "dir" : "pwd ") << ((isCurrentOSWindows()) ? EMPTY_STRING : $2);
        executeCommand(command.str());
        showInput();
    }
    | MKDIR FILE_NAME NEW_LINE
    {   
        ostringstream command;
        command << "mkdir " << decodeFileName($2);
        executeCommand(command.str());
        showInput();
    }
    | MKDIR UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << "mkdir" << ((isCurrentOSWindows()) ? EMPTY_STRING : $2) << " " << decodeFileName($3);
        executeCommand(command.str());
        showInput();
    }
    | RM FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "del " : "rm ") << decodeFileName($2);
        executeCommand(command.str());
        showInput();
    }
    | RM UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "del " : "rm ") << ((isCurrentOSWindows()) ? convertUnixOptionsIntoNTOptions(string($2)) : $2) << " " << decodeFileName($3);
        executeCommand(command.str());
        showInput();
    }
    | DEL FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "del " : "rm ") << decodeFileName($2);
        executeCommand(command.str());
        showInput();
    }
    | DEL NT_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? "del " : "rm ") << ((isCurrentOSWindows()) ? $2 : convertNTOptionsIntoUnixOptions(string($2))) << " " << decodeFileName($3);
        executeCommand(command.str());
        showInput();
    }
    | TOUCH FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "touch ") << ((isCurrentOSWindows()) ? EMPTY_STRING : decodeFileName($2));
        executeCommand(command.str());
        showInput();
    }
    | TOUCH UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "touch ") << ((isCurrentOSWindows()) ? EMPTY_STRING : $2) << ((isCurrentOSWindows()) ? EMPTY_STRING : " ") << ((isCurrentOSWindows()) ? EMPTY_STRING : decodeFileName($3));
        executeCommand(command.str());
        showInput();
    }
    | DATE NEW_LINE
    {
        ostringstream command;
        command << "date";
        executeCommand(command.str());
        showInput();
    }
    | DATE UNIX_OPTIONS NEW_LINE
    {
        ostringstream command;
        command << "date " << ((isCurrentOSWindows()) ? convertUnixOptionsIntoNTOptions($2) : $2);
        executeCommand(command.str());
        showInput();
    }
    | DATE NT_OPTIONS NEW_LINE
    {
        ostringstream command;
        command << "date " << ((isCurrentOSWindows()) ? $2 : convertNTOptionsIntoUnixOptions($2));
        executeCommand(command.str());
        showInput();
    }
    | WHO NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "who");
        executeCommand(command.str());
        showInput();
    }
    | WHO UNIX_OPTIONS NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "who ") << ((isCurrentOSWindows()) ? EMPTY_STRING : $2);
        executeCommand(command.str());
        showInput();
    }
    | WHOIS NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "whois");
        executeCommand(command.str());
        showInput();
    }
    | WHOIS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "whois ") << ((isCurrentOSWindows()) ? EMPTY_STRING : decodeFileName($2));
        executeCommand(command.str());
        showInput();
    }
    | WHOIS UNIX_OPTIONS FILE_NAME NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "whois ") << ((isCurrentOSWindows()) ? EMPTY_STRING : $2) << ((isCurrentOSWindows()) ? EMPTY_STRING : " ") << ((isCurrentOSWindows()) ? EMPTY_STRING : decodeFileName($3));
        executeCommand(command.str());
        showInput();
    }
    | WHOAMI NEW_LINE
    {
        ostringstream command;
        command << ((isCurrentOSWindows()) ? NOT_SUPPORTED_COMMAND : "whoami");
        executeCommand(command.str());
        showInput();
    }
    | RCOMMANDS NEW_LINE
    {
        ostringstream command;
        command << "rcommands";
        executeCommand(command.str());
        showInput();
    }
    | HELP NEW_LINE
    {
        ostringstream command;
        command << "help";
        executeCommand(command.str());
        showInput();
    }
    | VERSION NEW_LINE
    {
        ostringstream command;
        command << "version";
        executeCommand(command.str());
        showInput();
    }
    | CLEAR NEW_LINE
    {
        ostringstream command;
        command  << ((isCurrentOSWindows()) ? "cls" : "clear");
        executeCommand(command.str());
        showInput();
    }
    | CLS NEW_LINE
    {
        ostringstream command;
        command  << ((isCurrentOSWindows()) ? "cls" : "clear");
        executeCommand(command.str());
        showInput();
    }
    | NEW_LINE
    {
        showInput();
    }
    | EXIT NEW_LINE
    {
        ostringstream command;
        command << "exit";
        executeCommand(command.str());
        return EXIT_SUCCESS;
    }
    | QUIT NEW_LINE
    {
        ostringstream command;
        command << "quit";
        executeCommand(command.str());
        return EXIT_SUCCESS;
    }
    | error NEW_LINE
    {
        yyerrok;
        yyclearin;
    }
%%

// Shell lifecycle
int main(int argumentsCount, char ** argumentsList)
{
    setup();
    yyparse();
}

// Shell main setup routine
void setup()
{
    ostringstream message;
    initializeRecentCommands(rcomands,RCOMANDS_ARRAY_SIZE);
    initializeLogFile(logFile);
    message << "Started RKRShell (V" << fixed << setw(2) << setprecision(1) << RKR_SHELL_VERSION << ") logged as " << getenv(((isCurrentOSWindows()) ? NT_USER_ENVIRONMENT_VARIABLE : UNIX_USER_ENVIRONMENT_VARIABLE)) << " on " << getCurrentDate();
    logToFile(message.str(),logFile);
    showWelcomeMessage();
    showInput();
}

// Shell dealloc routine
void dealloc()
{
    ostringstream message;
    destroyRecentCommands(rcomands);
    message << "Ended RKRShell (V" << fixed << setw(2) << setprecision(1) << RKR_SHELL_VERSION << ") logged as " << getenv(((isCurrentOSWindows()) ? NT_USER_ENVIRONMENT_VARIABLE : UNIX_USER_ENVIRONMENT_VARIABLE)) << " on " << getCurrentDate();
    logToFile(message.str(),logFile);
    logFile.close();
}

// Shows a message when the shell starts up
void showWelcomeMessage()
{
    cout << "RKRShell V" << fixed << setw(2) << setprecision(1) << RKR_SHELL_VERSION << endl;
    cout << "Logged in as: " << getenv(((isCurrentOSWindows()) ? NT_USER_ENVIRONMENT_VARIABLE : UNIX_USER_ENVIRONMENT_VARIABLE)) << endl;
}

// Shows the cursor carriage with user and path info
void showInput()
{
    cout << getenv(((isCurrentOSWindows()) ? NT_USER_ENVIRONMENT_VARIABLE : UNIX_USER_ENVIRONMENT_VARIABLE)) << " @ [" << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << "] > ";
}

// Detects if the current O.S. is Windows-based
bool isCurrentOSWindows()
{
    return (CURRENT_OS == OS_WINDOWS);
}

// Detects if the current O.S. is Mac OS-based (Unix)
bool isCurrentOSMacOS()
{
    return (CURRENT_OS == OS_MAC_OS);
}

// Detects if the current O.S. is Linux-based (Unix)
bool isCurrentOSLinux()
{
    return (CURRENT_OS == OS_LINUX);
}

// Initializes a given log file
void initializeLogFile(fstream & logFile)
{
    logFile.open(LOG_FILE_NAME,fstream::out | std::ios_base::app);
}

// Logs a message to a given log file
void logToFile(char * message, fstream & logFile)
{
    return logToFile(string(message),logFile);
}

// Logs a message to a given log file
void logToFile(string message, fstream & logFile)
{
    logFile << "* " << message << endl;;
}

// Logs a command to a given log file
void logCommandToFile(char * command, fstream & logFile)
{
    return logCommandToFile(string(command),logFile);
}

// Logs a command to a given log file
void logCommandToFile(string command, fstream & logFile)
{
    logFile << "* " << getenv(((isCurrentOSWindows()) ? NT_USER_ENVIRONMENT_VARIABLE : UNIX_USER_ENVIRONMENT_VARIABLE)) << " [" << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << "] on " << getCurrentDate() << " - [OK] - Command \"" << command << "\" executed successfully" << endl;
}

// Logs an error to a given log file
void logErrorToFile(char * error, fstream & logfile)
{
    return logErrorToFile(string(error),logFile);
}

// Logs an error to a given log file
void logErrorToFile(string error, fstream & logfile)
{
    logFile << "* " << getenv(((isCurrentOSWindows()) ? NT_USER_ENVIRONMENT_VARIABLE : UNIX_USER_ENVIRONMENT_VARIABLE)) << " [" << getcwd(operationBuffer,OPERATION_BUFFER_SIZE) << "] on " << getCurrentDate() << " - [ERROR] - Error happened: " << error << endl;
}

// Calculates the current date and time
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

// Initializes a given recent commands data structure
void initializeRecentCommands(recentCommands & instance, int size)
{
    instance.data = new string[size];
    for(int index = 0; index < size; index++)
    {
        instance.data[index] = EMPTY_STRING;
    }
    instance.size = size;
    instance.currentIndex = 0;
}

// Concatenates all recent commands into a string
string getRecentCommands(recentCommands instance)
{
    ostringstream aux;
    for(int index = 0; index < instance.size; index++)
    {
        if(instance.data[index].compare(EMPTY_STRING) != EQUAL_STRINGS)
        {
            aux << instance.data[index] << endl;
        }
    }
    return aux.str();
}

// Checks if a given recent commands data structure needs to shift down
bool recentCommandsNeedShift(recentCommands instance)
{
    return (instance.currentIndex == instance.size);
}

// Shifts down a given recent commands data structure
void shiftRecentCommands(recentCommands & instance)
{
    for(int index = 0; index < instance.size - 1; index++)
    {
        instance.data[index] = instance.data[index + 1];
    }
}

// Adds a command to a given recent commands data structure
void addRecentCommand(string command, recentCommands & instance)
{
    if(recentCommandsNeedShift(instance))
    {
        instance.currentIndex--;
        shiftRecentCommands(instance);
    }
    instance.data[instance.currentIndex++] = command;
}

// Destroys a given recent commands data structure
void destroyRecentCommands(recentCommands & instance)
{
    delete [] instance.data;
}

// Decodes a given file name with / without the whitespace special identifier ("+_+")
string decodeFileName(char * fileName)
{
    return decodeFileName(string(fileName));
}

// Decodes a given file name with / without the whitespace special identifier ("+_+")
string decodeFileName(string fileName)
{
    boost::replace_all(fileName,WHITESPACE_SPECIAL_IDENTIFIER,WHITESPACE_SPECIAL_CHARACTER);
    return fileName;
}

// Executes a given command (Command executer manager)
void executeCommand(string command)
{
    if(command.compare(NOT_SUPPORTED_COMMAND) == EQUAL_STRINGS)
    {
        // YET   
    }
    else if(command.compare("rcommands") == EQUAL_STRINGS)
    {
        addRecentCommand(command,rcomands);
        cout << getRecentCommands(rcomands);
        logCommandToFile(command,logFile);
    }
    else if(command.compare("help") == EQUAL_STRINGS)
    {
        cout << "RKRShell V" << fixed << setw(2) << setprecision(1) << RKR_SHELL_VERSION << endl << endl;
        cout << "\t Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda" << endl;
        cout << "\t GNU GPL V2" << endl << endl;
        cout << "\t Available actions" << endl;
        cout << "\t\t ls\t\t->\t List files" << endl;
        cout << "\t\t dir\t\t->\t List files" << endl;
        cout << "\t\t cd\t\t->\t Change directory" << endl;
        cout << "\t\t pwd\t\t->\t Get current directory" << endl;
        cout << "\t\t mkdir\t\t->\t Make directory" << endl;
        cout << "\t\t rm\t\t->\t Remove file or directory" << endl;
        cout << "\t\t del\t\t->\t Remove file or directory" << endl;
        cout << "\t\t touch\t\t->\t Create new file" << endl;
        cout << "\t\t date\t\t->\t Show current date" << endl;
        cout << "\t\t who\t\t->\t Display who is logged in" << endl;
        cout << "\t\t whois\t\t->\t Display and address domain owner" << endl;
        cout << "\t\t whoami\t\t->\t Display effective user id" << endl;
        cout << "\t\t rcommands\t->\t Show recent used commands" << endl;
        cout << "\t\t help\t\t->\t Show this help menu" << endl;
        cout << "\t\t version\t->\t Show the current shell's version" << endl;
        cout << "\t\t clear\t\t->\t Clear output" << endl;
        cout << "\t\t cls\t\t->\t Clear output" << endl;
        cout << "\t\t exit\t\t->\t Exit the shell" << endl;
        cout << "\t\t quit\t\t->\t Exit the shell" << endl;
        addRecentCommand(command,rcomands);
        logCommandToFile(command,logFile);
    }
    else if(command.compare("version") == EQUAL_STRINGS)
    {
        cout << "RKRShell V" << fixed << setw(2) << setprecision(1) << RKR_SHELL_VERSION << endl;
        addRecentCommand(command,rcomands);
        logCommandToFile(command,logFile);
    }
    else if(command.compare("exit") == EQUAL_STRINGS || command.compare("quit") == EQUAL_STRINGS)
    {
        cout << "Bye, thanks for using RKRShell!" << endl;
        logCommandToFile(command,logFile);
        dealloc();
    }
    else
    {
        system(command.c_str());
        addRecentCommand(command,rcomands);
        logCommandToFile(command,logFile);
    }
}

// Converts Unix-based parameter into NT-based parameters
string convertUnixOptionsIntoNTOptions(string options)
{
    ostringstream aux;
    aux << "/";
    for(int index = 1; index < options.length(); index++)
    {
        aux << options[index];
    }
    return aux.str();
}

// Converts NT-based parameter into Unix-based parameters
string convertNTOptionsIntoUnixOptions(string options)
{
    ostringstream aux;
    aux << "-";
    for(int index = 1; index < options.length(); index++)
    {
        aux << options[index];
    }
    return aux.str();
}

// Properly treats an error when found
void yyerror(const char * errorMessage)
{
    cout << "Unrecognizable command detected by RKRShell" << endl;
    logErrorToFile(string(errorMessage),logFile);
    showInput();
}