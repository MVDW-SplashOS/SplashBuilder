f_prompt() {
	printf $UBlue
	#printf "${1/""/"_"}" 
	printf ${1}
	printf $White 
	printf " "
	read choice
	
	case "$choice" in 
		y|Y )
			printf "Continueing operation...\n\n";;
			
		n|N )
			printf "Quitting...\n\n"
			
			exit 1;;
		* )
			printf "invalid awnser\n\n" 
			f_prompt $0;;
	esac
}
