#!/bin/bash

# Scripting Assignment
# Richard Cummings
# 991 226 908

# default dictionary file
dict=$HOME/dictionaries/dict
# backup set to true if parameter '-b' passed
backup='false'

# check parameters
if [ "$1" != "" ]; then
	case $1 in
		# param '-n' specifies a new dictionary file
		-n)	if [ $2 != "" ]; then
				# if file does not exist set it as dict
				if [ ! -f "$2" ]; then
					dict="$2"
				else
				# allow user to re-enter filepath if file exists
					while [ -f "$2" ]
					do
						echo "File $2 already exists"
						echo "Enter new file path or "
						echo "q to exit"
						read yesno
						if [ "$yesno" != 'q' ]; then
							$2 = $yesno
						else
							exit 0
						fi
					done
					# set dictionary to filepath
					dict="$2"
				fi
			else
				# empty parameter
				echo "Filepath not specified"
				exit 1
			fi
			;;
		# param '-f' specifies an existing dictionary file
		-f)	if [ $2 != "" ]; then
				# if file exists set it as dict
				if [ -f "$2" ]; then
					dict=$2
				else
					echo "File $2 not found"
					exit 1
				fi
			else
				# filepath not entered
				echo "File not specified"
				exit 1
			fi
			;;
		# param '-l' lists existing dictionaries
		-l)	ls $HOME/dictionaries
			;;
		# param '-h' shows legal parameters for this script
		-h)	cat <<_EOF_
assign2.sh help
Legal parameters: [-n path_to_new_file | f path_to_existing_file | -l | -h] [-b]
			
			-n path_to_new_file
				Start a new dictionary with an empty file.
			
			-f path_to_existing_file
				Open an existing dictionary file.

			-l
				List existing dictionary files.
			
			-b
				Create backup tarball upon exit.

			-h
				Help
_EOF_
			exit 0
			;;
		# param '-b' creates a backup upon exit
		-b)	backup='true'
			;;
	esac
	# check if '-b' was entered as an extra parameter
	#if [ $* == "-b" ]; then
	#	backup='true'
	#fi
fi

loopgo="y"

# function for printing formatted dictionary file information (option 4)
print_com ()
{	
	# output replaces spaces that were transliterated during function call
	output=$(echo "$1" | tr '_' ' ')
	# store each field in a variable, delimiter is ';'		
	comName=$(echo "$output" | cut -f1 -d';')
	comDes=$(echo "$output" | cut -f2 -d';')
	comTyp=$(echo "$output" | cut -f3 -d';')
	# display info
	echo "Command:		$comName"
	echo "Type:			$comTyp"
	echo "Description:		$comDes"
	echo "------------------------------------"
}

until [ $loopgo == "n" ]
do
# display menu
cat <<_EOF_
1. Store a command
2. Show man page for a command
3. List commands
4. Show all
5. Types
6. Coders
7. Exit
_EOF_
	# get input
	read choice
	case $choice in
		# Store a command
		1)	echo "Enter command:"
			read com
			# if command is not found prompt for re-entry
			while [ "$(type -t $com)" == "" ]
			do
				echo "Command $com not found"
				echo "Enter new command or exit (q)"
				read com
				if [ "$com" == "q" ]; then
					exit 0
				fi
			done
			# get description
			echo "Enter description for $com:"
			read desc
			case $(type -t $com) in
			"builtin")
				comType="shell builtin"
				;;
			"file")
				comType="system binary"
				;;
			"alias")
				comType="alias"
				;;
			"function")
				comType="function"
				;;
			"keyword")
				comType="keword"
				;;
			*)
				comType="other"
				;;
			esac
			# append to flat file databyse, delimiter is ;
			echo "$com;$desc;$comType;" | tee -a $dict
			echo "Press <ENTER> to return to menu"
			read
			;;
		# Show man page for a command
		2)	echo "Show man page for: "
			echo "(p)Previously stored command"
			echo "(n)New command"
			read choice
			if [ "$choice" == "p" ]; then
				echo "$(man $com)"
			else
				echo "Enter command: "
				read manCom
				echo "$(man $manCom)"
			fi
			;;
		# List commands
		3)	# arrays to store commands and sorted commands
			commands=()
			sorted_commands=()
			while read line
			do	# cut command(field 1) from line (delimeter;)
				cmd=$(echo $line | cut -f1 -d';')
				commands+=($cmd)
			done < $dict
			# sort commands uniquely, each command on new line
			sorted_commands=$(echo "${commands[@]}" | tr ' ' '\n' | sort -u)
			# print sorted commands to screen
			echo "${sorted_commands[@]}"
			;;
		# Show all
		4)	# read each line of dictionary
			while read comline
			do
				# replace ' ' with '_' so each line can be
				# passed as a single parameter
				passline=$(echo "$comline" | tr ' ' '_')
				# call function print_com for line
				print_com $passline
			done < $dict
			;;
		# Types	
		5)	# display count of each type of command stored
			types=()
			while read typeline
			do	
				# typeln is the third field (type)
				# replace space with underscore
				typeln=$(echo $typeline | cut -f3 -d';' | tr ' ' '_')
				# add tyepln to types
				types+=($typeln)
			done < $dict
			# variables to store amounts of each type
			built=0
			binary=0
			ali=0
			fnct=0
			kywrd=0
			other=0
			# increment each type variable when type is found 
			# in {types[]}
			for i in "${types[@]}"
			do
				if [ "$i" == "shell_builtin" ]; then
					((built++))
				elif [ "$i" == "system_binary" ]; then
					((binary++))
				elif [ "$i" == "alias" ]; then
					((ali++))
				elif [ "$i" == "function" ]; then
					((fnct++))
				elif [ "$i" == "keyword" ]; then
					((kywrd++))
				else
					((other++))
				fi
			done
			# display types only if their amount is greater than 0
			echo "-----------------------------------"
			echo
			if [ "$built" -gt 0 ]; then
				printf "Shell Builtins: \t$built\n\n"
			fi
			if [ "$binary" -gt 0 ]; then
				printf "System Binaries: \t$binary\n\n"
			fi
			if [ "$ali" -gt 0 ]; then
				printf "Aliases: \t$ali\n\n"
			fi
			if [ "$fnct" -gt 0 ]; then
				printf "Shell Functions: \t$fnct\n\n"
			fi
			if [ "$kywrd" -gt 0 ]; then
				printf "Keywords: \t$kywrd\n\n"
			fi
			if [ "$other" -gt 0 ]; then
				printf "Others: \t$other\n\n"
			fi
			echo "-----------------------------------"
			;;
		# coders
		6)	
			# display personal info
			cat << _EOM_
Name: 			Richard Cummings
Program: 		Computer Programmer
_EOM_
			;;
		7)	echo "Goodbye"
			if [ $backup == "true" ]; then
				echo $(tar cvf a2.tar a2.sh $HOME/public/README)
				echo $(tar rvf a2.tar $HOME/dictionaries/)
			fi 	
			exit 0
			;;
	esac
done
