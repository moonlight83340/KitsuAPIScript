#!/bin/bash
 
function readJson {  
  UNAMESTR=`uname`
  if [[ "$UNAMESTR" == 'Linux' ]]; then
    SED_EXTENDED='-r'
  elif [[ "$UNAMESTR" == 'Darwin' ]]; then
    SED_EXTENDED='-E'
  fi; 

  VALUE=` cat ${1} | sed -e "s/,\"/ ,\n\"/g" | sed -e "s/}/\n}\n/g" | sed -e "s/{/\n{\n/g" | sed -e "s/:/ : /g" | grep -e "\"${2}\".*" | sed ${SED_EXTENDED} 's/^ *//;s/.*: *"//;s/",?//'`

  if [ ! "$VALUE" ]; then
    echo "Error: Cannot find \"${2}\" in ${1}" >&2;
    exit 1;
  else
    echo -e $VALUE ;
  fi; 
}

file="${1}"
word="${2}"
NAME=`readJson ${1} ${2}` || exit 1;  
echo -e $NAME
exit 0
