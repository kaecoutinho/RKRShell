# BuildRKRShell.sh
# RKRShell
# Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
# GNU GPL V2

#!/bin/bash

# Default file name
file="RKRCommands"
output="RKRShell"
logFile="RKRLog.log"

# Arguments count
if (("$#" <= 0))
then
	# Compiles using Flex & Bison and the g++ compiler
	sh FlexBisonWrapper.sh $file $output

	# Removes generated Flex file
	if [ -f "lex.yy.c" ]
	then
		rm lex.yy.c
	fi

	# Removes generated Bison files
	if [ -f "$file.tab.c" ] && [ -f "$file.tab.h" ]
	then
		rm $file.tab.*
	fi

	# Removes generated RKRShell's log file
	if [ -f "$logFile" ]
	then
		rm $logFile
	fi
else
	# Shows error message
	printf '\nToo much arguments, expected none\n\n'
fi