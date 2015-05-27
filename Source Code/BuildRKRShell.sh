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

	# Removes all useless files
	rm lex.yy.c
	rm $file.tab.*
	rm $logFile
else
	# Shows error message
	printf '\nToo much arguments, expected none\n\n'
fi