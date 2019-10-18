#!/bin/bash

image="Images"

flag_character=false
flag_people=false
flag_anime=false
flag_manga=false
flag_ZipAndMove=false
flag_Zip=false
flag_Verbose=false
gDriveDirectory=""

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
	firstFileName="${2}"
	lastFileName="${3}"
	zipName="${image}_${directoryName}_${firstFileName}-${lastFileName}.zip"
	if ${flag_ZipAndMove} ;then
		zip -r -m "${zipName}" "${image}/${directoryName}"
	else
		zip -r "${zipName}" "${image}/${directoryName}"
	fi
	./../gdrive upload --parent "1vSt86OMcRcFvs0l_03M_YFRqzzUOk5JY" "${zipName}"
	rm "${zipName}"
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

characterImageDownload() {
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

animeImageDownload() {
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
	for dir in manga0-40692_chapters0-709205/mangas/*;do
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
	exit 0
elif [ "${1}" = "-c" ];then
	flag_character=true
	gDriveDirectory="Images_Characters"
elif [ "${1}" = "-a" ];then
	flag_anime=true
	gDriveDirectory="Images_Animess"
elif [ "${1}" = "-m" ];then
	flag_manga=true
	gDriveDirectory="Images_Mangas"
elif [ "${1}" = "-p" ];then
	flag_people=true
	gDriveDirectory="Images_Peoples"
else
	usage
	exit 0
fi

if [ "${2}" = "-m" ];then
	firstId="${3}"
	lastId="${4}"
	range=$(((lastId - firstId)/4))
	./dlImage.sh "${1}" "-v" "${3}" $((firstId + range)) &
	./dlImage.sh "${1}" "-v" $((firstId + range + 1)) $(( firstId + (2 * range) - 1)) &
	./dlImage.sh "${1}" "-v" $(( firstId + (2 * range) + 1)) $(( firstId + (3 * range) - 1)) &
	./dlImage.sh "${1}" "-v" $(( firstId + (3 * range) + 1)) "${4}" &
	wait
	./dlImage.sh "${1}" "-zm" "${3}" "${4}"
	exit 0
fi

if [ "${2}" = "-mi" ];then
	firstId="${3}"
	lastId="${4}"
	range=$(((lastId - firstId)/4))
	./dlImage.sh "${1}" "-v" "${3}" $((firstId + range)) &
	./dlImage.sh "${1}" "-v" $((firstId + range + 1)) $(( firstId + (2 * range))) &
	./dlImage.sh "${1}" "-v" $(( firstId + (2 * range) + 1)) $(( firstId + (3 * range) )) &
	./dlImage.sh "${1}" "-v" $(( firstId + (3 * range) + 1)) "${4}" &
	wait
	./dlImage.sh "${1}" "-zm" "${3}" "${4}"
	newFirstId=$((lastId + 1))
	newLastId=$(((lastId - firstId) - 1))
	./dlImage.sh "${1}" "-mi" "${newFirstId}" "${newLastId}"
fi

if [ "${2}" = "-mia" ];then
	firstId="$(./gdrive list | grep -E "${gDriveDirectory}_[0-9]+-[0-9]+.zip" | sed -r 's/.*-([0-9]*)\..*/\1/g' | head -1)"
	firstId=${firstId:=1}
	range="${3}"
	lastId=$((firstId + range))	
	range=$(((lastId - firstId)/4))
	echo "Start dowload at ${firstId}"
	echo "Range will be : ${range}"
	echo "${firstId} $((firstId + range))"
	echo "$((firstId + range + 1)) $(( firstId + (2 * range)))"
	echo "$(( firstId + (2 * range) + 1)) $(( firstId + (3 * range)))"
	echo "$(( firstId + (3 * range) + 1)) ${lastId}"
	./dlImage.sh "${1}" "-v" "${firstId}" $((firstId + range)) &
	./dlImage.sh "${1}" "-v" $((firstId + range + 1)) $(( firstId + (2 * range))) &
	./dlImage.sh "${1}" "-v" $(( firstId + (2 * range) + 1)) $(( firstId + (3 * range))) &
	./dlImage.sh "${1}" "-v" $(( firstId + (3 * range) + 1)) "${lastId}" &
	wait
	./dlImage.sh "${1}" "-zm" "${firstId}" "${lastId}"
	newFirstId=$((lastId + 1))
	newLastId=$(((lastId - firstId) - 1))
	./dlImage.sh "${1}" "-mia" "${3}"
	exit 0
fi

if [ "${2}" = "-z" ];then
	flag_Zip=true
	shift
elif [ "${2}" = "-zm" ];then	
	flag_ZipAndMove=true
	shift
elif [ "${2}" = "-v" ];then
	flag_Verbose=true
	shift
fi

if ${flag_character};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Characters" "${2}" "${3}"
	else
		characterImageDownload "${2}" "${3}"
	fi
elif ${flag_people};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Peoples" "${2}" "${3}"
	else
		peopleImageDownload "${2}" "${3}"
	fi
elif ${flag_anime};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Animes" "${2}" "${3}"
	else
		animeImageDownload "${2}" "${3}"
	fi
elif ${flag_manga};then
	if ${flag_Zip} || ${flag_ZipAndMove} ;then
		zip_file "Mangas" "${2}" "${3}"
	else
		mangaImageDownload
	fi
fi

exit 0
