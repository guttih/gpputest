#!/usr/bin/env bash

DIR=$( echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )
echo "DIR: $DIR"
if [[ $(basename "$DIR") == "scripts" && ! -f "$DIR"/Makefile ]]; then
     DIR=$(dirname "$DIR");
fi

#Function: downloadIfNotFound()
#
#Brief: Downloads a script if it is not found in subdirectory scripts
#
#Argument 1($1): directory name
#Argument 1($1): script name
downloadIfNotFound(){
    if [ $# -ne 2 ]; then echo "Invalid number of parameters provided to $FUNCNAME"; exit 1; fi
    declare DIR="$1"
    declare FILE="$2"
    if ! test -f "$DIR/$FILE"; then
        if wget "https://raw.githubusercontent.com/guttih/cpputest-example/main/$DIR/$FILE" -P "$DIR"; then
            chmod +x "$DIR/$FILE"
            return
        fi
    fi
    return 1
}


#Function: downloadScripts()
#
#Brief: Downloads scripts to sub directory called scripts
#
downloadScripts(){
    declare SCRIPTS="scripts"
    # wget -O - https://raw.githubusercontent.com/guttih/cpputest-example/main/scripts/install.sh | bash
    downloadIfNotFound "$SCRIPTS" setupTest.sh
    downloadIfNotFound "$SCRIPTS" newQtProject.sh
    
    if downloadIfNotFound "$SCRIPTS" install.sh; then
        if test -f "$DIR/install.sh"; then
            #running the newest version of install.sh
            rm "$DIR/install.sh"
            "$SCRIPTS/install.sh"
            exit
        fi
    fi
}


downloadScripts
echo "replacing ~ dirs in Makefiles of $DIR"
errorColor=$(echo -en '\033[01;31m')
norm=$(echo -en '\033[0m')


#Function: replaceProjectDir()
#
#Brief: Sets a new project directory in a make file
#
#Argument 1($1): File to change
#Argument 2($2): new value
replaceProjectDir(){
    if [ $# -ne 2 ]; then echo "${errorColor}Invalid number of parameters provided to $FUNCNAME${norm}"; exit 1; fi

    declare FILE=$1
    if [[  ! -f $FILE  ]]; then
        echo "${errorColor}File \"$FILE\" does not exist${norm}"; exit 1;
    fi

    sed -i 's,^\s*PROJECT_DIR=.*$,PROJECT_DIR='"$2"',g' $1
}


replaceProjectDir "$DIR"/Makefile "$DIR"
replaceProjectDir "$DIR"/tests/Makefile "$DIR"
