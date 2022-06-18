#!/bin/bash

#true or false options.
options=("-h" "--help" "-reset" "-f")

#Options that must be followed with one argument
optionsWithArgument=(-dir -codedir -appdir -appname)

#Options that must be provided by the user
optionsRequired=(-dir -codedir -appdir)

#Set to true you want to allow any arguments to be given
#Set to false if you only want to allow options in  "options" and "optionsWithArgument"
ALLOW_UNPROCESSED="false"
APPNAME="appliction"

printHelp() {
    printf 'Usage: %s [OPTIONS]...\n' "$(basename "$0")"
    printf 'Usage: %s [OPTIONS]... (-dir <directory> -appdir <application_directory> -codedir <code_directory>)\n' "$(basename "$0")"
    echo "  Creates a test environment"
    echo
    echo "OPTIONS     Option description"
    echo "  --help    Prints this help page"
    echo "  -reset    if test environment has already been create it will be removed and a new one will be created "
    echo "  -f        When used with -reset option, tests directory will be removed without asking."
    echo "  -dir      The project root directory.  A sub folder tests will be created"
    echo "  -codedir  The code directory.  The directory that contains the header files to be tested"
    echo "  -appdir   Application directory"
    echo "  -appname  Name of the application"
    echo
    echo "ARGUMENTS               Option argument description"
    echo " directory              Project directory"
    echo " code_directory         Directory containing header and source files to be tested"
    echo " application_directory  Directory containing Makefile of the application to be tested"
    
    echo
    exit 0
}

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
        if [ ${#_options[@]} -eq 0 ]; then
            echo "${errorColor}No options provided${norm}, quitting"
            exit 1
        fi
        shift
    fi
    if [[ "$1" == "-optsArg" ]]; then
        shift
        declare -a _optionsWithArgument=("${!1}")
        if [ ${#_optionsWithArgument[@]} -eq 0 ]; then
            echo "${errorColor}No options with arguments provided${norm}, quitting"
            exit 1
        fi
        shift
    fi
    if [[ "$1" == "-optsReq" ]]; then
        shift
        declare -a _optionsRequired=("${!1}")
        shift

    fi

    declare -a _optionsFound
    declare tmp tmpName
    while (("$#")); do # While there are arguments still to be shifted
        if containsElement "$1" "${_options[@]}"; then
            #removing prefix - and -- and assigning value to uppercased variable.
            _optionsFound+=("$1")
            tmp=${1#"-"}
            tmp=${tmp#"-"}
            tmp=$(echo "$tmp" | tr a-z A-Z)
            printf -v "$tmp" "true"
        elif containsElement "$1" "${_optionsWithArgument[@]}"; then
            #removing prefix - and -- and assigning value to uppercased variable.
            _optionsFound+=("$1")
            tmpName=$1
            tmp=${1#"-"}
            tmp=${tmp#"-"}
            tmp=$(echo "$tmp" | tr a-z A-Z)
            shift
            if [[ -z "$1" ]]; then
                echo "Value missing for $tmpName"
                return 1
            fi
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
    if [[ "${_optionsRequired[*]}" == "0" ]]; then return 0; fi
    #Check if all required options have been provided.
    for arg in "${_optionsRequired[@]}"; do
        if ! containsElement "$arg" "${_optionsFound[@]}"; then
            echo -e "${errorColor}Required option missing ${norm} $arg"
            return 1
        fi
    done

}

#Function: makeFileTestsMain()
#
#Brief: Creates a main.cpp test file
#
#Argument 1($1): directory path to where to create the main.cpp file
makeFileTestsMain() {
    declare FILE="$1"/main.cpp
    echo "Creating $FILE"
    CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    read -r -d '' VAR <<EOM
//  File main.cpp, created $CURRENT.
//
#include "CppUTest/CommandLineTestRunner.h"

int main(int ac, char** av)
{
    return CommandLineTestRunner::RunAllTests(ac, av);
}
EOM
    echo "$VAR" >"$FILE"
}

#Function: makeFileTestsTest()
#
#Brief: Creates a test.cpp test file
#
#Argument 1($1): directory path to where to create the main.cpp file
makeFileTestsTest() {
    declare FILE="$1"/test.cpp
    echo "Creating $FILE"
    CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    read -r -d '' VAR <<EOM
//  File main.cpp, created $CURRENT.
//
#include "CppUTest/TestHarness.h"
#include "testCodeExample.h"

TEST_GROUP(AwesomeExamples)
{
};

TEST(AwesomeExamples, FirstExample)
{
  int x = test_func();
  CHECK_EQUAL(1, x);
}
EOM
    echo "$VAR" >"$FILE"
}

makeFileTestsGitIgnore() {
    declare FILE="$1"/.gitignore
    echo "Creating $FILE"
    CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    read -r -d '' VAR <<EOM
# File .gitignore, created $CURRENT.
coverage
objs
app
EOM
    echo "$VAR" >"$FILE"
}

#Function: makeFileTestsTest()
#
#Brief: Creates a test.cpp test file
#
#Argument 1($1): directory path to where to create the main.cpp file
makeFileTestsCodeExample() {
    declare DIR="$1"
    declare FILE_NAME="testCodeExample"
    CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    read -r -d '' CONTENT_H <<EOM
//  File $FILE_NAME.h, created $CURRENT.
//
#ifndef __code_h__
#define __code_h__
int test_func();
int test_func2();
int test_func3();
#endif
EOM

read -r -d '' CONTENT_CPP <<EOM
//  File $FILE_NAME.cpp, created $CURRENT.
//
#include <stdlib.h>
#include "testCodeExample.h"

int test_func()
{
    return 1;
}

int test_func2()
{
    return 2;
}
int test_func3()
{
    return 3;
}

EOM
    echo "Creating $DIR/$FILE_NAME.h"
    echo "$CONTENT_H" >"$DIR/$FILE_NAME.h"
    echo "Creating $DIR/$FILE_NAME.cpp"
    echo "$CONTENT_CPP" >"$DIR/$FILE_NAME.cpp"
}

#Function: makeFileTestsMakefile()
#
#Brief: Creates a main.cpp test file
#
#Argument 1($1): directory path to where to create the file
#Argument 2($2): Source directory
#Argument 3($3): TEST directory
#Argument 4($4): include directory
#Argument 5($5): Test target        (output file)
#Argument 6($6): Application target (output file)
makeFileMakefile() {
    declare FILE="$1"/Makefile
    declare CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    echo "Creating $FILE"
    read -r -d '' VAR <<EOM
#  File Makefile, created $CURRENT.
PROJECT_DIR=$1
SRC_DIR=$2
TEST_DIR=$3
CODE_DIR=$4
OUT=$6
TEST_TARGET=$5
COVERAGE_DIR=\$(TEST_DIR)/coverage
CPPUTEST_USE_GCOV=Y

\$(info    PROJECT_DIR:\$(PROJECT_DIR))
\$(info    SRC_DIR:\$(SRC_DIR))
\$(info    TEST_DIR:\$(TEST_DIR))
\$(info    CODE_DIR:\$(CODE_DIR))
\$(info    OUT:\$(OUT))
\$(info    TEST_TARGET:\$(TEST_TARGET))
\$(info    COVERAGE_DIR:\$(COVERAGE_DIR))

test:
	make -C \$(TEST_DIR)

test_clean:
	make -C \$(TEST_DIR) clean

testCodeExample.o:
	gcc -c -I\$(CODE_DIR) \$(CODE_DIR)/testCodeExample.cpp -o \$(CODE_DIR)/testCodeExample.o

build:
	make -C $5

main: testCodeExample.o
	gcc -I\$(CODE_DIR) \$(CODE_DIR)/testCodeExample.o \$(SRC_DIR)/\$(OUT).cpp -o \$(SRC_DIR)/\$(OUT)

all: test main

testcov: test coverage
	xdg-open \$(COVERAGE_DIR)/index.html

clean_coverage:
	rm -rf \$(COVERAGE_DIR)
coverage: clean_coverage
	mkdir \$(COVERAGE_DIR); lcov --capture --directory . --output-file \$(COVERAGE_DIR)/coverage.info; genhtml \$(COVERAGE_DIR)/coverage.info --output-directory \$(COVERAGE_DIR) && echo -ne "To open report give command\n  xdg-open \$(COVERAGE_DIR)/index.html\n"

clean: test_clean
	rm \$(SRC_DIR)/*.o \$(CODE_DIR)/*.o \$(OUT)
EOM
    echo "$VAR" >"$FILE"
}

#Function: makeFileTestsMakefile()
#
#Brief: Creates a main.cpp test file
#
#Argument 1($1): directory path to where to create the file
#Argument 2($2): PROJECT directory
#Argument 3($3): Source directory
#Argument 4($4): TEST directory
#Argument 5($5): include directory
#Argument 6($6): Source directores
#Argument 7($7): Test target (output file)
makeFileTestsMakefile() {
    declare FILE="$1"/Makefile
    declare CURRENT=$(date +"%Y-%m-%d %H:%M:%S")
    echo "Creating $FILE"
    read -r -d '' VAR <<EOM
#  File Makefile, created $CURRENT.
# we don’t want to use relative paths, so we set these variables
PROJECT_DIR=$2
SRC_DIR=$3
TEST_DIR=$4
# specify where the source code and includes are located
INCLUDE_DIRS=$5
SRC_DIRS=$6
TEST_SRC_DIRS = \$(TEST_DIR)
\$(info    FILE         : $FILE)
\$(info    PROJECT_DIR  :\$(PROJECT_DIR))
\$(info    TEST_DIR     :\$(TEST_DIR))
\$(info    INCLUDE_DIRS :\$(INCLUDE_DIRS))
\$(info    SRC_DIRS     :\$(SRC_DIRS))
\$(info    TEST_SRC_DIRS:\$(TEST_SRC_DIRS))
# specify where the test code is located

# what to call the test binary
TEST_TARGET=$7

# where the cpputest library is located
CPPUTEST_HOME=/usr/local
CPPUTEST_USE_GCOV=Y
# run MakefileWorker.mk with the variables defined here
include MakefileWorker.mk
EOM
    echo "$VAR" >"$FILE"
}

# You could test code below by running this script with these Arguments
#   ./thisScript.sh -reset -"-dir" ~/Downloads -weird
if ! parseOptions -opts "options[@]" -optsArg "optionsWithArgument[@]" -optsReq "optionsRequired[@]" "$@"; then exit 1; fi
for arg in "${UNPROCESSED[@]}"; do
    echo "${warningColor}Unprocessed argument${norm} $arg "
done

if [[ -n "$DIR" ]]; then
    DIR=$(readlink -m $DIR)
    if ! test -d "$DIR"; then
        echo "${errorColor}Directory ${highlight}$DIR${norm} ${errorColor}does not exist${norm}, quitting"
        exit 1
    fi
    echo "-dir=\"$DIR\""
fi
TEST_DIR="$DIR"/tests
CODE_DIR=$(readlink -m $CODEDIR)
APP_DIR=$(readlink -m $APPDIR)

if ! test -d "$CODE_DIR"; then
    echo "${errorColor}-codedir directory ${highlight}$CODE_DIR${norm} ${errorColor}does not exist${norm}, quitting"
    exit 1
fi

if ! test -d "$APP_DIR"; then
    echo "${errorColor}-appdir directory ${highlight}$APP_DIR${norm} ${errorColor}does not exist${norm}, quitting"
    exit 1
fi

if [[ -n "$RESET" ]]; then
    if test -d "$TEST_DIR"; then
        if [[ -n "$F" ]]; then
            echo "removing directory ${highlight}$TEST_DIR${norm}"
            rm -rf "$TEST_DIR"
        else
            echo "Directory ${highlight}$TEST_DIR${norm} already exists,"
            read -r -p "${warningColor} are you sure you want to remove it [y/N] ${norm} " response
            case "$response" in
            [yY][eE][sS] | [yY])
                rm -rf "$TEST_DIR"
                ;;
            *)
                echo "cancelling"
                exit 0
                ;;
            esac
        fi
    fi
else
    if test -d "$TEST_DIR"; then
        echo "Directory ${highlight}$TEST_DIR${norm} already exists."
        echo "run this script with switch ${warningColor}-reset${norm} to remove it and create a new one!"
        exit 1
    fi
fi

#Function: downloadOrCopyFromExtras()
#
#Brief: Downloads a file, if it is not found the file is coped from /usr/share/gpputest/extras directory
#
#Argument 1($1): Url to a file to download (including the file name)
#Argument 2($2): Destination directory
#Argument 3($3): Destination file name
#Returns 0 if success, otherwise 1
downloadOrCopyFromExtras(){
    if [ $# -ne 3 ]; then echo "Invalid number of parameters provided to $FUNCNAME"; exit 1; fi
    declare BACKUP_DIR=/usr/share/gpputest/extras
    declare URL="$1"
    declare TO_DIR="$2"
    declare FILE="$3"
    declare FROM_FILE=$(basename "$1")
    # if ! wget "$URL" -P "$TO_DIR"; then
    declare CURRENT=$( pwd )
    if curl "$URL"  --raw -s -o "$FILE"  ; then
        cd "$CURRENT"
        exit 0
    else
        cd "$CURRENT"
        echo "Error saving downloaded file, using offline version"
        
    fi
    cp "$BACKUP_DIR/$FROM_FILE" "$TO_DIR/$FILE"
    if test -f "$TO_DIR/$FILE"
    then
        return 0
    else
        return 1
    fi
    
}

APP_EXECUTABLE="$(basename $APP_DIR)"
TEST_EXECUTABLE="app"
echo "APP_EXECUTABLE: $APP_EXECUTABLE"
echo "TEST_EXECUTABLE: $TEST_EXECUTABLE"
declare LINK="https://raw.githubusercontent.com/cpputest/cpputest/master/build/MakefileWorker.mk"
# wget -q "$LINK" -P "$TEST_DIR" && echo "Downloaded MakefileWorker.mk test helper" || echo "${errorColor}Error downloading ${norm}$LINK"
mkdir -p "$TEST_DIR"
downloadOrCopyFromExtras "$LINK" "$TEST_DIR" MakefileWorker.mk
makeFileTestsMain "$TEST_DIR"
makeFileTestsTest "$TEST_DIR"
makeFileTestsGitIgnore "$TEST_DIR"
makeFileTestsCodeExample "$CODE_DIR"
makeFileTestsMakefile "$TEST_DIR" "$DIR" "$CODE_DIR" "$TEST_DIR" "$CODE_DIR" "$CODE_DIR" "$TEST_EXECUTABLE"
makeFileMakefile "$DIR" "$APP_DIR" "$TEST_DIR" "$CODE_DIR" "$TEST_EXECUTABLE" "$APPNAME"
CURRENT_DIR=$( pwd )
echo "current dir:$CURRENT_DIR"
if ! make test; then
    exit 1
fi