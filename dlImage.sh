#!/bin/bash

image="Images"

usage(){
	echo -e "Usage:  $0 <TYPE> [IDStart] [IDEnd] \n\
	$0 -h : For help\n\
	$0 --help : For help\n\
	$0 -usage : For help\n\
	<TYPE> = -m = manga, -a = anime, -c = character, -p = people\n\
	"
	exit 1;
}

imageDownload() {
	file="${1}"
	searchName="${2}"
	name="${3}"
	images="${image}/${4}"
	name=$(./parseJson.sh ${1} "${3}")
	link=$(./parseJson.sh ${1} ${searchName})
	name=`echo "$name" | sed -e 's/[.*"<>?:|\/]//g'`
	
	if [ "$name" = 'slug":null,' ];then
		name=$(./parseJson.sh ${1} "name")
		echo "${name}"
	fi
	
	if [ ! -d "${images}/${name}" ];then
		mkdir -p "${images}/${name}"
	#else
	#	echo "${images}/${name} existe !"
	fi

	if [ ! -f "${images}/${name}/${name}-original.jpg" ];then
		wget -q "${link}" -O "${images}/${name}/${name}-original.jpg"
		echo "${images}/${name}/${name}-original.jpg Téléchargé !"
	fi
}

characterImageDowload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -f "./characters/${i}" ];then
			echo  "./characters/${i} not exist !"
		else
			imageDownload "./characters/${i}" "original" "slug" "Characters"
		fi
	done;
	sort -ug missing_character_image.txt -o missing_character_image.txt
}

animeImageDowload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -f "./animes/${i}/${i}.json" ];then
			echo  "./animes/${i}/${i}.json not exist !"
			if [ ! -f "./animes/${i}.json" ];then
				echo  "./animes/${i}.json not exist !"
			else
				imageDownload "./animes/${i}.json" "original" "slug" "Animes"
			fi
		else
			imageDownload "./animes/${i}/${i}.json" "original" "slug" "Animes"
		fi
	done
}

mangaImageDownload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -f "./mangas/${i}/${i}.json" ];then
			echo  "./mangas/${i}/${i}.json not exist !"
			if [ ! -f "./mangas/${i}.json" ];then
				echo  "./mangas/${i}.json not exist !"
			else
				imageDownload "./mangas/${i}.json" "original" "slug" "Mangas"
			fi
		else
			imageDownload "./mangas/${i}/${i}.json" "original" "slug" "Mangas"
		fi
	done
	# for dir in manga0-40692_chapters0-709205/mangas/*;do
	# 	if [ -d ${dir} ]; then
	# 		# Will not run if no directories are available
	# 		num="${dir##manga0-40692_chapters0-709205/mangas/}"
	# 		imageDownload "$dir/$num.json" "original" "en_jp" "Mangas"
	# 	elif [ -f ${dir} ];then
	# 		imageDownload "$dir" "original" "en_jp" "Mangas"
	# 	fi
	# done
}

peopleImageDownload() {
	idStart="${1}"
	idEnd="${2}"
	for(( i="${idStart}"; i<="${idEnd}"; i++ ));do
		if [ ! -f "./people/${i}" ];then
			echo  "./people/${i} not exist !"
		else
			imageDownload "./people/${i}" "image" "name" "Peoples"
		fi
	done;
}

#character case
if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-usage" ]; then
	usage
elif [ "${1}" = "-c" ];then
	characterImageDowload "${2}" "${3}"
elif [ "${1}" = "-a" ];then
	animeImageDowload "${2}" "${3}"
elif [ "${1}" = "-m" ];then
	mangaImageDownload "${2}" "${3}"
elif [ "${1}" = "-p" ];then
	peopleImageDownload "${2}" "${3}"
else
	usage
fi
exit 0
