#!/bin/bash

image="Images"

flag_character=false
flag_people=false
flag_anime=false
flag_manga=false
flag_ZipAndMove=false
flag_Zip=false
flag_Verbose=false

usage(){
	echo -e "Usage:  $0 <TYPE> [IDStart] [IDEnd] \n\
	$0 -h : For help\n\
	$0 --help : For help\n\
	$0 -usage : For help\n\
	$0 <TYPE> [OPTION] \n\
	[OPTION] : \n\
	-z : Zip the directory \n\
	-zm : Zip the directory and delete it\n\
	<TYPE> = -m = manga, -a = anime, -c = character, -p = people\n\
	"
	exit 1;
}

validate_url(){
	if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]];then 
		return 0; 
	else 
		return 1; 
	fi
}

zip_file(){
	directoryName="${1}"
	firstFileName=$(ls "${image}/${directoryName}" | head -n 1)
	lastFileName=$(ls "${image}/${directoryName}" | tail -n 1)
	zipName="${image}_${directoryName}_${firstFileName}-${lastFileName}.zip"
	if ${flag_ZipAndMove} ;then
		zip -r -m "${zipName}" "${image}/${directoryName}"
	else
		zip -r "${zipName}" "${image}/${directoryName}"
	fi
}

imageDownload() {
	file="${1}"
	searchName="${2}"
	name="${3}"
	images="${image}/${4}"
	name=$(./parseJson.sh ${1} "${3}")
	name="${name//\./}"
	name="${name//\//}"
	name="${name/ ,/}"  
	
	link=$(./parseJson.sh ${1} ${searchName})
	link="${link// /}"
	link="${link/,/}"  

	if [ "$name" = 'slug":null,' ];then
		name=$(./parseJson.sh ${1} "name")
		if ${flag_Verbose};then
			echo "${name}"
		fi
	fi
	
	if [ ! -d "${images}/${name}" ];then
		mkdir -p "${images}/${name}"
	fi
	
	if [ ! -f "${images}/${name}/${name}-original.jpg" ];then
		validate_url "$link"
		tmp=$?
		if [ $tmp -eq 0 ];then
			wget -q "${link}" -O "${images}/${name}/${name}-original.jpg"
			if ${flag_Verbose};then
				echo "${images}/${name}/${name}-original.jpg Téléchargé !"
			fi
		else
			if ${flag_character};then
				echo "${5}" >> "missing_character_image.txt"
			elif ${flag_people};then
				echo "${5}" >> "missing_people_image.txt"
			elif ${flag_anime};then
				echo "${5}" >> "missing_anime_image.txt"
			elif ${flag_manga};then
				echo "${5}" >> "missing_manga_image.txt"
			fi
			rmdir "${images}/${name}"
		fi
	fi
}

characterImageDowload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -e "./characters/${i}" ];then
			if ${flag_Verbose};then
				echo  "./characters/${i} not exist !"
			fi
		else
			imageDownload "./characters/${i}" "original" "slug" "Characters" "${i}"
		fi
	done;
	sort -ug missing_character_image.txt -o missing_character_image.txt
}

animeImageDowload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -e "./anime/${i}" ];then
			if ${flag_Verbose};then
				echo  "./anime/${i} not exist !"
			fi
		else
			imageDownload "./anime/${i}" "original" "en_jp" "Animes" "${i}"
		fi
	done;
	sort -ug missing_anime_image.txt -o missing_anime_image.txt
}

mangaImageDownload() {
	for dir in manga0-40692_chapters0-70920		movies.remove(movie);5/mangas/*;do
		if [ -d ${dir} ]; then
			# Will not run if no directories are available
			num="${dir##manga0-40692_chapters0-709205/mangas/}"
			imageDownload "$dir/$num.json" "original" "en_jp" "Mangas" "${i}"
		elif [ -f ${dir} ];then
			imageDownload "$dir" "original" "en_jp" "Mangas" "${i}"
		fi
	done
	sort -ug missing_manga_image.txt -o missing_manga_image.txt
}

peopleImageDownload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -e "./people/${i}" ];then
			if ${flag_Verbose};then
				echo  "./people/${i} not exist !"
			fi
		else
			imageDownload "./people/${i}" "original" "name" "Peoples" "${i}"
		fi
	done;
	sort -ug missing_people_image.txt -o missing_people_image.txt
}

touch "missing_character_image.txt"
touch "missing_people_image.txt"
touch "missing_anime_image.txt"
touch "missing_manga_image.txt"

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-usage" ]; then
	usage
elif [ "${1}" = "-c" ];then
	flag_character=true
elif [ "${1}" = "-a" ];then
	flag_anime=true
elif [ "${1}" = "-m" ];then
	flag_manga=true
elif [ "${1}" = "-p" ];then
	flag_people=true
else
	usage
fi

if [ "${2}" = "-z" ];then
	flag_Zip=true
	
elif [ "${2}" = "-zm" ];then	
	flag_ZipAndMove=true
elif [ "${2}" = "-v" ];then
	flag_Verbose=true
fi

if ${flag_character};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Characters"
	else
		characterImageDowload "${2}" "${3}"
	fi
elif ${flag_people};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Peoples"
	else
		peopleImageDowload "${2}" "${3}"
	fi
elif ${flag_anime};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Animes"
	else
		animeImageDowload "${2}" "${3}"
	fi
elif ${flag_manga};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Mangas"
	else
		mangaImageDowload
	fi
fi

exit 0
