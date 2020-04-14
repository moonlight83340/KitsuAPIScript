#!/bin/bash

sort -g -u "${1}" >| ".temp_${1}"
mv ".temp_${1}" "${1}"