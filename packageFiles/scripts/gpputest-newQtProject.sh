#!/bin/bash

#true or false options.
options=( "-h" "--help" "-reset" ) 

#Options that must be followed with one argument
optionsWithArgument=( "-appname" ) 

#Options that must be provided by the user
optionsRequired=( "-appname" ) 

#Set to true you want to allow any arguments to be given
#Set to false if you only want to allow options in  "options" and "optionsWithArgument"
ALLOW_UNPROCESSED="false" 

printHelp() {
    printf 'Usage: %s [OPTIONS]...\n' "$(basename "$0")"
    printf 'Usage: %s [OPTIONS]... (-appname <name>)\n' "$(basename "$0")"
    echo "  Creates a new Qt widget application setup with CppUTest tests"
    echo 
    echo "OPTIONS    Option description"
    echo "  --help   Prints this help page"
    echo "  -reset   Remove previous src and test dirs and create a new setup "
    echo "  -appname Name of the Qt application "
    echo
    echo "ARGUMENTS  Option argument description"
    echo " name      Name of the Qt (binary) application "  
    echo
    echo "Example"
    printf '  %s -appname myQtApp -reset\n' "$(basename "$0")"
    exit 0
}

REPO_DIR=$( pwd  )
SCRIPT_DIR=$( echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )
echo "REPO_DIR  : $REPO_DIR"
echo "SCRIPT_DIR: $SCRIPT_DIR"

#Text Color commands
#Brief: Commands to change the color of a text
highlight=$(echo -en '\033[01;37m')
purpleColor=$(echo -en '\033[01;35m')
cyanColor=$(echo -en '\033[01;36m')
errorColor=$(echo -en '\033[01;31m')
warningColor=$(echo -en '\033[00;33m')
successColor=$(echo -en '\033[01;32m')
norm=$(echo -en '\033[0m')

#Function: parseOptions()
#
#Brief: Checks if all options are correct and saves each in a variable.
#After: Value of each options given, is stored in a uppercase named variable.
#       f. example -express will be stored in a global variable called EXPRESS
#Returns:
#      0 : (success) All paramters are valid
#      1 : (error) One or more parameters are invalid
#
# Usage: parseOptions  (-opts <stringArray>) [string]...
#        parseOptions  (-optsArg <stringArray>) [string]...
#        parseOptions  (-opts <stringArray> -optsArg <stringArray>) [string]...
#        parseOptions  (-opts <stringArray> -optsReq <stringArray>) [string]...
#        parseOptions  (-optsArg <stringArray> -optsReq <stringArray>) [string]...
#        parseOptions  (-opts <stringArray> -optsArg <stringArray> -optsReq <stringArray>) [string]...
# Options     Option description
#   -opts     Array of options
#   -optsArg  Array of options which take one argument
#   -optsReq  Array of required options
# Arguments      Argument description
#   stringArray  Array of options, where each option starts with '-'
#   string       Any string
#
declare -a UNPROCESSED
parseOptions() {
    containsElement() { #if function arrayContains exists, it can be used instead of containsElement
        local e match="$1"
        shift
        for e; do [[ "$e" == "$match" ]] && return 0; done
        return 1
    }

    if [[ "$1" == "-opts" ]]; then
        shift
        declare -a _options=("${!1}")
         if [ ${#_options[@]} -eq 0 ]; then echo "${errorColor}No options provided${norm}, quitting"; exit 1; fi
        shift
    fi
    if [[ "$1" == "-optsArg" ]]; then
        shift
        declare -a _optionsWithArgument=("${!1}")
        if [ ${#_optionsWithArgument[@]} -eq 0 ]; then echo "${errorColor}No options with arguments provided${norm}, quitting"; exit 1; fi
        shift
    fi
    if [[ "$1" == "-optsReq" ]]; then
        shift
        declare -a _optionsRequired=("${!1}")
        shift
        
    fi

    declare -a  _optionsFound
    declare tmp tmpName
    while (("$#")); do # While there are arguments still to be shifted
        if containsElement "$1" "${_options[@]}"; then
            #removing prefix - and -- and assigning value to uppercased variable.
            _optionsFound+=("$1")
            tmp=${1#"-"};tmp=${tmp#"-"};tmp=$( echo "$tmp" | tr a-z A-Z )
            printf -v "$tmp" "true"
        elif containsElement "$1" "${_optionsWithArgument[@]}"; then
            #removing prefix - and -- and assigning value to uppercased variable.
            _optionsFound+=("$1")
            tmpName=$1
            tmp=${1#"-"};tmp=${tmp#"-"};tmp=$( echo "$tmp" | tr a-z A-Z )
            shift
            if [[ -z "$1" ]];then echo "Value missing for $tmpName";return 1; fi
            printf -v "$tmp" "$1"
        else
            if [[ "$ALLOW_UNPROCESSED" == "true" ]]; then
                UNPROCESSED+=("$1")
                _optionsFound+=("$1")
            else
                echo "${errorColor}Error: ${highlight}$1${norm} is an invalid argument."
                return 1
            fi
        fi
        shift
    done

    if [[ -n "$HELP" || -n "$H" ]]; then printHelp; fi
    if [[ "${_optionsRequired[*]}" == "0" ]]; then return 0; fi;
    #Check if all required options have been provided.
    for arg in "${_optionsRequired[@]}"; do
        if ! containsElement "$arg" "${_optionsFound[@]}"; then
            echo  "${errorColor}Required option missing ${norm} $arg "
            return 1
        fi
    done
}

# You could test code below by running this script with these Arguments
#   ./thisScript.sh -reset -"-appname" ~/Downloads -weird
if ! parseOptions -opts "options[@]" -optsArg "optionsWithArgument[@]" -optsReq "optionsRequired[@]" "$@"; then exit 1; fi
if [[ -n "$APPNAME" ]]; then echo "-appname=\"$APPNAME\""; fi

for arg in "${UNPROCESSED[@]}"; do
    echo  "${warningColor}Unprocessed argument${norm} $arg "
done

if [[ -n "$RESET" ]]; then 
    echo "Removing removing folders"; 
    rm -rf "$REPO_DIR"/src
    rm -rf "$REPO_DIR"/tests
fi

#Function: createQtApp()
#
#Brief: Creates a Qt widget application
#
#Requirements  : Qt must be installed and in path
#Argument 1($1): Root of the repository directory
#Argument 2($2): Directory where to create the application
#Argument 3($3): name of the output binary file
createQtApp(){
    if [ $# -ne 3 ]; then echo "Invalid number of parameters provided to $FUNCNAME"; exit 1; fi
    
    declare REPOSITORY_DIR="$1"
    declare DIR="$2"
    declare NAME="$3"
    declare CPP_FILE="$DIR"/"$NAME".cpp
    mkdir -p "$DIR"/code
    echo "Creating $CPP_FILE"
    CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    read -r -d '' VAR <<EOM
// File $NAME.cpp created $CURRENT.
#include <QApplication>
#include <QPushButton>

int main( int argc, char **argv )
{
    QApplication a( argc, argv );

    QPushButton hello( "Hello world!", 0 );
    hello.resize( 100, 30 );

    hello.show();
    return a.exec();
}
EOM
    echo "$VAR" >"$CPP_FILE"
    cd "$DIR" || exit
    echo "qmake -project -o "$NAME.pro" && echo 'QT += widgets' | cat - "$NAME.pro" > temp && mv temp "$NAME.pro" && qmake && make"
    qmake -project -o "$NAME.pro" && echo 'QT += widgets' | cat - "$NAME.pro" > temp && mv temp "$NAME.pro" && qmake && make
    declare LINK="https://raw.githubusercontent.com/github/gitignore/main/Qt.gitignore"
    wget -q  "$LINK" -O .gitignore && echo "Downloaded .gitignore for QT" || echo "${errorColor}Error downloading ${norm}$LINK"
    cd "$REPOSITORY_DIR" || exit
   declare APP="$DIR/$NAME"
   if test -f "$APP"
   then
       echo "${successColor}App created${norm}, You can run the app with command: ${highlight}$APP${norm}"
   else
       echo "Unable to make the app"
   fi
   
}

declare APP_DIR="$REPO_DIR"/src
declare CODE_DIR="$APP_DIR"/code
createQtApp "$SCRIPT_DIR" "$APP_DIR" "$APPNAME"
"$SCRIPT_DIR"/setupTest.sh -reset -dir "$REPO_DIR" -appdir "$APP_DIR" -codedir "$CODE_DIR"
echo "All source code is here   : ${highlight}$APP_DIR${norm}"
echo "Code to be tested is here : ${highlight}$CODE_DIR${norm}"
echo -ne "Now try to run the tests and get the code coverage with command\n${highlight}make testcov${norm}\n"
