# FlexBisonWrapper.sh
# RKRShell
# Created by Kaê Angeli Coutinho, Ricardo Oliete Ogata and Rafael Hieda
# GNU GPL V2

# Parameters
# 	string {1} -> .l & .y file name
# 	string {2} -> generated output name (optional)

#!/bin/bash

# Arguments count
if (("$#" <= 2))
then
	# Gets the Flex & Bison file name and its generated output file name
	file="${1}"
	output="${2}"

	# Checks if the file name is empty
	if [ -z "$file" ]
	then
		# Shows error message
		printf '\nExpects argument \n\n\t[file : string [, output : string]]\n\n'
	else
		# Generates the Flex .l file
		flex $file.l

		# Generates the Bison .y file
		bison -d $file.y

		# Checks if the generated output file name is empty
		if [ -z "$output" ]
		then
			output="FlexBisonExecutable"
		fi

		# Compiles the generated Flex & Bison files via g++ compiler
		g++ lex.yy.c $file.tab.c -ll -o $output -w
	fi
else
	# Shows error message
	printf '\nToo much arguments, expected only one\n\n\t[file : string [, output : string]]\n\n'
fi