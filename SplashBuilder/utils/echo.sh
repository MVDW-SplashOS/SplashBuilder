# Formatting functions
separator() {
	echo "--------------------------------------------------------------------"
}

echo_ok() {
	printf "[ \e[32mOK\e[0m ] $1\n"
}

echo_fail() {
	printf "[\e[31m\e[1mFAIL\e[0m] \e[1m%s\e[0m\n" "$*"
}

echo_warn() {
	printf "[\e[0;93mWARN\e[0m] $1\n" ""
}

echo_info() {
	printf "[INFO] $1\n"
}
