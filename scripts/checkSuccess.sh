# Escape Characters for nice output
#    \033          ascii ESCape
#    \033[<NUM>G   move to column <NUM> (linux console, xterm, not vt100)
#    \033[<NUM>C   move <NUM> columns forward but only upto last column
#    \033[<NUM>D   move <NUM> columns backward but only upto first column
#    \033[<NUM>A   move <NUM> rows up
#    \033[<NUM>B   move <NUM> rows down
#    \033[1m       switch on bold
#    \033[31m      switch on red
#    \033[32m      switch on green
#    \033[33m      switch on yellow
#    \033[m        switch off color/bold
#    \017          exit alternate mode (xterm, vt100, linux console)
#    \033[10m      exit alternate mode (linux console)
#    \015          carriage return (without newline)
#

WIDTH=120
POSITION=0


##############################################################################
# Split strings if no color is used for nicer alignement
##############################################################################
function split_string {
s="${1}"
COUNT=0
for i in $(seq 0 $((${#s}-1))); do
    c=${s:$i:1}
    if [ $i -eq $(($WIDTH-2)) ]
	then
	echo "\\"
	echo -n "$c"
	COUNT=1
    else
	echo  -n "$c"
	COUNT=$(($COUNT+1))
    fi
done
POSITION=$(($WIDTH-$COUNT))
}

##############################################################################
# Check if colors should be used
# default: with terminal -> use colors
#          without terminal (e.g. pipe, redirection to file) -> no colors
##############################################################################
[[ ! $DO_COLOR ]] && {
    DO_COLOR=0
    if [ -t 1 ]; then
        DO_COLOR=1
    fi
}

##############################################################################
#Pre formated colord output
##############################################################################
OK="\033[1m\033[1000C\033[5D\033[34m[\033[32m Ok \033[34m]\033[m";
FAILED="\033[1m\033[1000C\033[9D\033[34m[\033[31m Failed \033[34m]\033[m";
GREEN="\033[1m\033[32m"
RED="\033[1m\033[31m"
OFF="\033[m"

NO_COLOR_OK="OK"
NO_COLOR_FAILED="FAILED"

##############################################################################
# switch between colored and non colored output
##############################################################################
function checkSuccess {
    if [ $DO_COLOR -eq 1 ]; then
	colorCheckSuccess $1 "$2" "$3"
    else
	noColorCheckSuccess $1 "$2" "$3"
    fi

}

#############################################################################
# Check if a command was successfull
#############################################################################
function noColorCheckSuccess {
    if [ $1 -eq 0 ]; then
	split_string "${2}"
	printf "%-${POSITION}s %s\n" "" $NO_COLOR_OK
    else
	split_string "${2}"
	printf "%-${POSITION}s %s\n" "" $NO_COLOR_FAILED
	printf "%s\n" "${3}"
	exit 1 
    fi

}

#############################################################################
# Check if a command was successfull
#############################################################################
function colorCheckSuccess {
    if [ $1 -eq 0 ]; then
	echo -ne ${GREEN}${2} $OFF $OK
    else
	echo -ne ${RED}${2} $OFF $FAILED
	echo -e  ${RED}${3} $OFF
	exit 1
    fi

}
