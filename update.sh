#!/bin/bash


#	VV       VV	    AAA			RRRRRRR		IIIIII	    AAA			BBBBBB		LL			EEEEEEEE
#	 VV     VV	   AA AA		RR    RR	  II	   AA AA		BB   BB		LL			EE
#	  VV   VV	AAAAAAAAAAA		RRRRRRR		  II	AAAAAAAAAAA		BBBBBB		LL			EEEEE
#	   VV VV	 AA     AA		RR  RR		  II	 AA     AA		BB    BB	LL			EE
#	    VVV 	AA       AA		RR    RR	IIIIII	AA       AA		BBBBBBB		LLLLLLLL	EEEEEEEE

#Global variable and flag

flag_casting=false
flag_oeuvre=false
flag_other=false
flag_update=false
flag_list=false
flag_borne=false
flag_pause=false
flag_force=false
flag_debug=false

use_kitsulast=true 			#kitsu last only
flag_kitsulast=true 		#size update check + kitsu last

timer=5
compteur=0
size_update=10
size_compression=10
url="https://kitsu.io/api/edge/"

usage(){
	echo -e "Usage: \t \"$0 <TYPE> ( [listfilename.txt], [IDSTART] [IDEND] ) <FLAG> \" \n\
	  $0 -h | --help | -u | --usage : For help\n\n\
	(-ua\t/ --updateall (/!\\ don't edit $0 until it end) )\n\n\
	<TYPE> :\n\
	\t-m\t/ --manga \t\tfor manga and chapters\n\
	\t-a\t/ --anime \t\tfor anime and episodes\n\
	\t-cas\t/ --casting \t\tfor casting and their relation\n\
	\t-c\t/ --character \t\tfor character\n\
	\t-cat\t/ --categorie \t\tfor categorie\n\
	\t-g\t/ --genre \t\tfor genre\n\
	\t-p\t/ --people \t\tfor people\n\n\
	<FLAG> :\n\
	\t-u\t/ --update \t\t(then the size_update or nothing base is 500)\n\
	\t-sc\t/ --size_compression \t(then a number or nothing  base is 500)\n\
	\t-f\t/ --force  \t\t(to force dl ignore allready have)\n\
	\t-p\t/ --pause  \t\t(pause on lost connection)\n\n\
	ctrl + C to pause then :\n\
	\t-ctrl+C in less than 2 secondes to end\n\
	\t-ctrl+C in more than 2 secondes to continue\n\
	"
}

#double capter SIGINT to leave
leave(){
	echo -e "\nwe interupt now"
	exit 0;
}

#capter SIGINT
capterint(){
	[ -f "pause" ] && rm pause >/dev/null || touch pause
}

#touch pause to pause rm pause to play
pause(){
	if [ -f "pause" ]; then
		echo -e -n "\033[35;1mpause detected.\033[0m" >&2
		trap leave SIGINT
		sleep 2
		trap capterint SIGINT
		echo -e "\033[35;1mwaiting...\033[0m" >&2
		while [ -f "pause" ]; do
			sleep 2
		done
	fi
}

trap capterint SIGINT
case $1 in
	-h|--help|-u|--usage)		usage;
								exit 0;;
esac

if [ "$1" == "-ua" ] || [ "$1" == --updateall ]; then
	! $use_kitsulast && echo "use_kitsulast is false set it true" && exit 1
	for i in "-p" "-c" "-cas" "-a" "-m"; do 		# "-g" "-cat" "-p" "-c" "-cas" "-a" "-m"
		"$0" $i -u
	done
	exit 0
fi

if [ $# -lt 2 ]; then
	usage > /dev/stderr
	exit 1
fi

tmpfilename=1
findtmpfilename(){
	while [ -f ".tmp$tmpfilename.txt" ]; do
		((tmpfilename++))
	done
	touch ".tmp$tmpfilename.txt"
}

#	$1=filename 	$2=patern
parseJson(){
	local filename="${1}" patern="${2}"
	VALUE=`cat ${filename} | sed -e "s/,\"/\n\"/g" | sed -e "s/}/\n}\n/g" | sed -e "s/{/\n{\n/g" | sed -e "s/\":\"/\" : \"/g" | grep -e "^ *\"${patern}\".*$" | sed -e "s/^ *\"${patern}\" *: *//g" | sed -e "s/^\"\(.*\)\"$/\1/g"`
	if [ ! "$VALUE" ]; then
		echo "Error: Cannot find \"${2}\" in ${1}" >&2
		return 1
	else
		echo -e $VALUE
	fi
}

#	$1=file path and name
removeifempty(){
	local path=${1}
	if [ -f "${path}" ] && [ `du -b "${path}" | sed 's/\([0-9]*\).*/\1/'` -eq 0 ]; then
		echo "${path} empty removing..."																										#here
		rm "${path}"
	fi
}

#	$1=ulr 	$2=path 	$3=filename
dl(){
	local url=${1} path=${2} filename=${3}
	wget -q "${url}" -O "${path}/${filename}"
}

#	$1=ulr 	$2=path 	$3=filename (ak number) 	$4=category (for the .txt) 	$5=number
trydl(){
	local url=${1} path=${2} filename=${3} category=${4} number=${5}
	pause
	removeifempty "${path}/${filename}"
	if ! $flag_force && [ -f "${path}/${filename}" ]; then
		echo -e "allready have \033[34m${category} \033[1m${filename}\033[0m"
		return
	fi
	echo -e -n "try dl  \033[1m${filename}\033[0m ...   "
	dl "${url}" "${path}" "${filename}"
	local tmp=$?
	if [ $tmp -eq 0 ]; then
		echo -e "\033[36msuccess !\033[0m"
		echo "${number}" >> "newID_${category}.txt"
		if [ ${number} -gt `cat "last_${category}.txt"` ]; then
			echo "${number}" >| "last_${category}.txt"
		fi
		timer=5
	elif [ $tmp -eq 4 ]; then
		echo -e "\033[35;1mlost connection\033[0m"
		rm "${path}/${filename}" >/dev/null
		if ${flag_pause} ; then
			touch pause
		else
			echo -e "\033[32mretrying in \033[1m${timer}\033[32m secondes ...\033[0m"
			sleep ${timer}
			((timer+=5))
		fi
		trydl ${url} ${path} ${filename} ${category} ${number}
	elif [ $tmp -eq 130 ]; then
		echo -e "\033[33;1mInterrupted !\033[0m"
		rm "${path}/${filename}" >/dev/null
		trydl ${url} ${path} ${filename} ${category} ${number}
	else									#construction de la liste des éléments manquants
		$flag_debug && echo "erreur $tmp"
		echo -e "\033[31mfailed.\033[0m"
		echo "${number}" >> "missing_${category}.txt"
		rm "${path}/${filename}" >/dev/null
		timer=5
	fi
}

getkitsulast(){
	local last
	pause
	findtmpfilename
	echo -n "try dl ${element} first page...  " >&2
	dl "${url}${element}" "." ".tmp${tmpfilename}.txt"
	local tmp=$?
	if [ $tmp != 0 ] ; then
		rm ".tmp$tmpfilename.txt"
		echo -e "\033[32mretrying in \033[1m${timer}\033[32m secondes ...\033[0m" >&2
		sleep ${timer}
		((timer+=5))
		getkitsulast
		return
	fi
	timer=5
	echo -e "\033[36msuccess !\033[0m" >&2
	local lasturl=`parseJson ".tmp$tmpfilename.txt" last | sed -e "s/%5B/[/g" | sed -e "s/%5D/]/g"`
	echo -n "try dl ${element} last  page...  " >&2
	dl "${lasturl}" "." ".tmp${tmpfilename}.txt"
	local tmp=$?
	if [ $tmp != 0 ] ; then
		echo -e "\033[31mfailed.\033[0m" >&2
		rm ".tmp$tmpfilename.txt"
		getkitsulast
		return
	fi
	echo -e "\033[36msuccess !\033[0m" >&2
	parseJson ".tmp$tmpfilename.txt" id | sed -e "s/^.* //g"
	rm ".tmp${tmpfilename}.txt"
 }

other(){
	local ID=${1}
	trydl "${url}${element}/${ID}" "${element}" "${ID}" "${element}" "${ID}"
}

#	$1=ID
casting(){
	local ID=${1}
	trydl "${url}castings/${ID}" 							"casting" 			"${ID}" "castings"			"${ID}"
	trydl "${url}castings/${ID}/relationships/character" 	"castingcharacter" 	"${ID}" "castingcharacter"	"${ID}"
	trydl "${url}castings/${ID}/relationships/media" 		"castingmedia" 		"${ID}" "castingmedia"		"${ID}"
	trydl "${url}castings/${ID}/relationships/person" 		"castingperson"		"${ID}" "castingperson"		"${ID}"
	if [ -f casting/${ID} ]; then
		echo ""
		flag_newfound=true
	else
		echo ""
	fi
}

#	$1=ID
oeuvres(){
	local ID=${1}
	trydl "${url}${element}/${ID}/relationships/${therelation}" "relation${element}" "${ID}" "relation${element}" "${ID}"						#relation element
	if [ -f "relation${element}/${ID}" ]; then																									#on a la relation
		sed -i 's/.*"data/"data"/g' "relation${element}/${ID}"
		sed -i 's/}}$/}/g' "relation${element}/${ID}"
		dir=`parseJson "relation${element}/${ID}" "id"`
		if [ $? -eq 0 ]; then 																													#on a réussi a lire la relation
			removeifempty "${oeuvre}s/${dir}/${ID}"
			if ! $flag_force && [ -f "${oeuvre}s/${dir}/${ID}" ]; then
				echo -e "allready sort \033[34m${element} \033[1m${ID}\033[0m"
				flag_newfound=true
				return
			fi
		else																																	#on a pas réussi a lire la relation
			echo "${ID}" >> "badrelation${element}.kitsu"
			echo "${ID}" >> "newID${element}.txt"
			trydl "${url}${element}/${ID}" "${element}" "${ID}" "${element}" "${ID}"
			return
		fi
	fi

	trydl "${url}${element}/${ID}" "${element}" "${ID}" "${element}" "${ID}"																	#element
	if [ -f "relation${element}/${ID}" ]; then																									#on a la relation
		if [ -f "${element}/${ID}" ]; then																										#on a le l'element
			if [ ! -d "${oeuvre}s/${dir}" ]; then																								#gestion premier element de l'oeuvre
				mkdir "${oeuvre}s/${dir}"
				trydl "${url}${oeuvre}/${dir}" "${oeuvre}s" "${dir}.json" "${oeuvre}" "${dir}" 													#dl oeuvre																				#ou dl oeuvre par element
				[ ! -f "${oeuvre}s/${dir}.json" ] && trydl "${url}${element}/${ID}/${therelation}" "${oeuvre}s" "${dir}.json" "${oeuvre}" "${dir}"  #ou par element

				if [ -f "${oeuvre}s/${dir}.json" ]; then																						#on a trouver l'oeuvre
					mv "${oeuvre}s/${dir}.json" "${oeuvre}s/${dir}/${dir}.json"
					echo -e "\n\t\033[30;42mnew ${oeuvre} add \033[1m${dir}\033[0m\n"
				else																															#on a pas trouver l'oeuvre
					echo "${dir}" >> "${element}missing${oeuvre}.txt"
					echo -e "\n\t\033[30;41mmissing ${oeuvre} \033[1m${dir}\033[0m\n"
				fi

				trydl "${url}${oeuvre}/${dir}/relationships/genres" "${oeuvre}s" "${dir}.genre" "genre${oeuvre}" "${dir}" 						#dl genre oeuvre
				if [ -f "${oeuvre}s/${dir}.genre" ]; then																						#on a trouver les genre
					mv "${oeuvre}s/${dir}.genre" "${oeuvre}s/${dir}/${dir}.genre"
					echo -e "\033[32;4msuccessfully added genre to ${oeuvre} \033[1m${dir}\033[0m\n"
				else																															#on a pas trouver les genre
					echo "${dir}" >> "missinggenre${oeuvre}.txt"
					echo -e "\n\t\033[30;41mmissing genre \033[1m${dir}\033[0m\n"
				fi
			fi
			mv "${element}/${ID}" "${oeuvre}s/${dir}/${ID}"
			if [ ${ID} -gt `cat "last_Sort${element}${oeuvre}.txt"` ]; then
				echo "${ID}" >| "last_Sort${element}${oeuvre}.txt"
			fi
			echo -e "\033[32;4msuccessfully added ${element} \033[1m${ID}\033[0;32;4m to ${oeuvre} \033[1m${dir}\033[0m"
			echo "${ID}" >> "newID${element}.txt"
			flag_newfound=true
		else																																	#on a pas le chapitre/episode
			if [ -f "${oeuvre}s/${dir}/${ID}" ]; then
				echo -e "allready sort \033[34m${element} \033[1m${ID}\033[0m"
				echo "pas normal d'etre ici"
				echo "${ID}" >> "WHAT.txt"
			else
				echo -e "relation but no \033[31m${element} \033[1m${ID}\033[0m"
				echo "${ID}" >> "relationmissing${element}.txt"
			fi
		fi
	else																																		#on a pas la relation
		if [ -f "${element}/${ID}" ]; then
			echo -e "no \033[31mrelation\033[0m for \033[31m${element} \033[1m${ID}\033[0m"
			echo "${ID}" >> "${element}missingrelation.txt"
		else
			echo -e "\033[31mno ${element} \033[1m${ID}\033[0m"
			echo "${ID}" >> "missing${element}.txt"
		fi
	fi
}

#	$1=ID
dlid(){
	if ${flag_oeuvre}; then
		oeuvres $1
	elif ${flag_casting}; then
		casting $1
	elif ${flag_other}; then
		other $1
	else
		echo -e "\033[31mERROR flag_to_dl\033[0m" >&2
		exit 1
	fi
}

#	$1=IDSTART 	$2=IDEND
loopdl(){
	local IDSTART=${1} IDEND=${2} i
	for (( i = ${IDSTART}; i <= ${IDEND}; i++ )); do
		dlid $i
		((compteur++))
		if [ $compteur -ge $size_compression ]; then
			compteur=0
			compression
		fi
	done
}


updatekitsulast(){
	echo ${url}${element} >&2
	kitsulast=`getkitsulast`
	echo "kitsulast = $kitsulast"
	IDSTART=${IDEND}
	((++IDSTART))
	IDEND=$kitsulast
	echo -e "\033[33;46mtry dl \033[1m${IDSTART}\033[0;33;46m to \033[1m${IDEND}\033[0m"
	loopdl ${IDSTART} ${IDEND}
}

oldupdate(){
	((size_update--))
	flag_newfound=true
	$flag_kitsulast && kitsulast=`getkitsulast`
	$flag_kitsulast && echo "kitsulast = $kitsulast"
	while ${flag_newfound}; do
		IDSTART=${IDEND}
		((++IDSTART))
		((IDEND=${IDSTART}+${size_update}))
		flag_newfound=false
		echo -e "\033[33;46mtry dl \033[1m${IDSTART}\033[0;33;46m to \033[1m${IDEND}\033[0m"
		loopdl ${IDSTART} ${IDEND}
		if $flag_kitsulast && [ ${IDEND} -lt ${kitsulast} ]; then
			flag_newfound=true
		fi
		echo -n "last searsh found nothing "
	done
}

#	$1=filename
initialisefile(){
	[ -f "${1}" ] || echo 0 >| "${1}"
}

#	$1=dirname
initialisedir(){
	[ -d "${1}" ] || mkdir "${1}"
}

firstrun(){
	if ${flag_oeuvre} ; then
		initialisedir "relation${element}"
		initialisedir "${element}"
		for filename in "last_${element}.txt" "last_relation${element}.txt" "last_Sort${element}${oeuvre}.txt" "last_${element}.kitsu" "last_${oeuvre}.txt" "last_${oeuvre}.kitsu"; do
			initialisefile "${filename}"
		done
	elif ${flag_casting} ; then
		initialisefile "last_castings.kitsu"
		for i in "s" "character" "media" "person" ; do
			initialisefile "last_casting$i.txt"
			initialisedir "casting$i"
		done
	elif ${flag_other} ;then
		initialisedir "${element}"
		for filename in "last_${element}.txt" "last_${element}.kitsu"; do
			initialisefile "${filename}"
		done
	else
		echo -e "\033[31mERROR flag_to_dl\033[0m" >&2
		exit 1
	fi
}

decompression(){
	if ${flag_oeuvre} ; then
		for filename in "last_${element}.txt" "last_relation${element}.txt" "last_Sort${element}${oeuvre}.txt"; do
			if [ -f "last_${element}.kitsu" ] && [ ! -f ${filename} ] ; then
				cp "last_${element}.kitsu" ${filename}
			fi
		done
		if [ -f "last_${oeuvre}.kitsu" ] && [ ! -f "last_${oeuvre}.txt" ]; then
			cp "last_${oeuvre}.kitsu" "last_${oeuvre}.txt"
		fi
		if [ -f "last_${oeuvre}.kitsu" ] && [ ! -f "last_genre${oeuvre}.txt" ]; then
			cp "last_${oeuvre}.kitsu" "last_genre${oeuvre}.txt"
		fi
	elif ${flag_casting};then
		for filename in "last_castings.txt" "last_castingcharacter.txt" "last_castingmedia.txt" "last_castingperson.txt" ; do
			if [ -f "last_castings.kitsu" ] && [ ! -f ${filename} ] ; then
				cp "last_castings.kitsu" ${filename}
			fi
		done
	elif ${flag_other}; then
		cp "last_${element}.kitsu" "last_${element}.txt"
	else
		echo  -e "\033[31mERROR flag_to_dl\033[0m" >&2
		exit 1
	fi
}

compression(){
	local last i
	echo "compression .txt ..." >&2
	if ${flag_oeuvre} ; then
		if [ `cat last_${element}.txt` -eq `cat last_relation${element}.txt` ] && [ `cat last_${element}.txt` -eq `cat last_Sort${element}${oeuvre}.txt` ]; then
			echo "all last_${element} are equal" >&2
			[ `cat last_${element}.txt` -ge `cat last_${element}.kitsu` ] && cp "last_${element}.txt" "last_${element}.kitsu"
		else
			echo -e "\033[31mERROR last_${element}\033[0m" >&2
			#exit 1
		fi
		last=`cat last_${element}.kitsu`
		for listype in "missing" "newID"; do
			if [ -f "${listype}${element}.txt" ] && [ -f "${listype}_${element}.txt" ] && [ -f "${listype}_relation${element}.txt" ]; then
				for filename in "${listype}${element}.txt" "${listype}_${element}.txt" "${listype}_relation${element}.txt"; do
					./exec/USort.sh $filename
				done
				if [ `du -b "${listype}${element}.txt" | sed 's/\([0-9]*\).*/\1/'` -eq `du -b "${listype}_${element}.txt" | sed 's/\([0-9]*\).*/\1/'` ] && [ `du -b "${listype}${element}.txt" | sed 's/\([0-9]*\).*/\1/'` -eq `du -b "${listype}_relation${element}.txt" | sed 's/\([0-9]*\).*/\1/'` ]; then
					echo -n "all ${listype}_${element} are equal start compression ...  " >&2
					for i in `cat "${listype}${element}.txt"`; do
						[ $i -le $last ] && echo $i >> "${listype}_${element}.kitsu"
					done
					rm "${listype}${element}.txt"
					rm "${listype}_${element}.txt"
					rm "${listype}_relation${element}.txt"
					echo -e "\033[32mok!\033[0m" >&2
					./exec/USort.sh "${listype}_${element}.kitsu"
				else
					echo -e "\033[31mERROR ${listype}_${element}\033[0m" >&2
					#exit 1
				fi
			fi
		done
		if [ `cat last_${oeuvre}.txt` -eq `cat last_genre${oeuvre}.txt` ]; then
			echo "all last_${oeuvre} are equal" >&2
			[ `cat last_${oeuvre}.txt` -ge `cat last_${oeuvre}.kitsu` ] && cp "last_${oeuvre}.txt" "last_${oeuvre}.kitsu"
		elif [ `cat last_${oeuvre}.txt` -gt `cat last_genre${oeuvre}.txt` ]; then
			echo "last_${oeuvre} `cat last_${oeuvre}.txt` last_genre${oeuvre} `cat last_genre${oeuvre}.txt`" >&2
			[ `cat last_${oeuvre}.txt` -ge `cat last_${oeuvre}.kitsu` ] && cp "last_${oeuvre}.txt" "last_${oeuvre}.kitsu"
		else
			echo -e "\033[31mERROR last_${oeuvre}\033[0m" >&2
			#exit 1
		fi
		last=`cat last_${oeuvre}.kitsu`
		if [ -f "missinggenre${oeuvre}.txt" ] && [ -f "missing_genre${oeuvre}.txt" ]; then
			for filename in "missinggenre${oeuvre}.txt" "missing_genre${oeuvre}.txt"; do
				[ -f $filename ] && ./exec/USort.sh "$filename"
			done
			if [ `du -b "missinggenre${oeuvre}.txt" | sed 's/\([0-9]*\).*/\1/'` -eq `du -b "missing_genre${oeuvre}.txt" | sed 's/\([0-9]*\).*/\1/'` ]; then
				echo -n "all missinggenre${oeuvre} are equal start compression ...  " >&2
				for i in `cat "missinggenre${oeuvre}.txt"`; do
					[ $i -le $last ] && echo $i >> "missing_genre${oeuvre}.kitsu"
				done
				rm "missinggenre${oeuvre}.txt"
				rm "missing_genre${oeuvre}.txt"
				echo -e "\033[32mok!\033[0m" >&2
				./exec/USort.sh "missing_genre${oeuvre}.kitsu"
			else
				echo -e "\033[31mERROR missinggenre${oeuvre}\033[0m" >&2
				#exit 1
			fi
		fi
		if [ -f "newID_${oeuvre}.txt" ]; then
			./exec/USort.sh "newID_${oeuvre}.txt"
			echo -n "newID_${oeuvre} start compression ...  " >&2
			for i in `cat "newID_${oeuvre}.txt"`; do
				[ $i -le $last ] && echo $i >> "newID_${oeuvre}.kitsu"
			done
			rm "newID_${oeuvre}.txt"
			echo -e "\033[32mok!\033[0m" >&2
			./exec/USort.sh "newID_${oeuvre}.kitsu"
		fi
	elif $flag_casting ; then
		if [ `cat last_castings.txt` -eq `cat last_castingcharacter.txt` ] && [ `cat last_castings.txt` -eq `cat last_castingmedia.txt` ] && [ `cat last_castings.txt` -eq `cat last_castingperson.txt` ]; then
			echo "all last_casting are equal" >&2
			[ `cat last_castings.txt` -ge `cat last_castings.kitsu` ] && cp "last_castings.txt" "last_castings.kitsu"
		else
			echo -e "\033[31mERROR last_castings\033[0m" >&2
			exit 1
		fi
		last=`cat last_castings.kitsu`
		for listype in "missing" "newID"; do
			if [ -f "${listype}_castings.txt" ] && [ -f "${listype}_castingcharacter.txt" ] && [ -f "${listype}_castingmedia.txt" ] && [ -f "${listype}_castingperson.txt" ]; then
				for filename in "${listype}_castings.txt" "${listype}_castingcharacter.txt" "${listype}_castingmedia.txt" "${listype}_castingperson.txt"; do
					./exec/USort.sh "$filename"
				done
				if [ `du -b "${listype}_castings.txt" | sed 's/\([0-9]*\).*/\1/'` -eq `du -b "${listype}_castingcharacter.txt" | sed 's/\([0-9]*\).*/\1/'` ] && [ `du -b "${listype}_castings.txt" | sed 's/\([0-9]*\).*/\1/'` -eq `du -b "${listype}_castingmedia.txt" | sed 's/\([0-9]*\).*/\1/'` ] && [ `du -b "${listype}_castings.txt" | sed 's/\([0-9]*\).*/\1/'` -eq `du -b "${listype}_castingperson.txt" | sed 's/\([0-9]*\).*/\1/'` ]; then
					echo -n "all ${listype}_castings are equal start compression ...  " >&2
					for i in `cat "${listype}_castings.txt"`; do
						[ $i -le $last ] && echo $i >> "${listype}_castings.kitsu"
					done
					rm "${listype}_castings.txt" 
					rm "${listype}_castingcharacter.txt" 
					rm "${listype}_castingmedia.txt" 
					rm "${listype}_castingperson.txt"
					echo -e "\033[32mok!\033[0m" >&2
					./exec/USort.sh "${listype}_castings.kitsu"
				else
					echo -e "\033[31mERROR ${listype}_castings\033[0m" >&2
					exit 1
				fi
			fi
		done
	elif ${flag_other}; then
		echo -n "last_${element}  " >&2
		[ `cat last_${element}.txt` -ge `cat last_${element}.kitsu` ] && cp "last_${element}.txt" "last_${element}.kitsu"
		echo -e "\033[32mok!\033[0m" >&2
		last=`cat last_${element}.kitsu`
		for listype in "missing" "newID"; do
			if [ -f "${listype}_${element}.txt" ] ;then 
				./exec/USort.sh "${listype}_${element}.txt"
				echo -n "${listype}_${element} start compression ...  " >&2
				for i in `cat "${listype}_${element}.txt"`; do
					[ $i -le $last ] && echo $i >> "${listype}_${element}.kitsu"
				done
				rm "${listype}_${element}.txt"
				echo -e "\033[32mok!\033[0m" >&2
				./exec/USort.sh "${listype}_${element}.kitsu"
			fi
		done
	else
		echo -e "\033[31mERROR flag_to_dl\033[0m" >&2
		exit 1
	fi
}

end_clean(){
	if ${flag_oeuvre}; then
		rm "last_${element}.txt"
		rm "last_relation${element}.txt"
		rm "last_Sort${element}${oeuvre}.txt"
		rm "last_${oeuvre}.txt"
		rm "last_genre${oeuvre}.txt"
		[ -f "newID_genre${oeuvre}.txt" ] && rm "newID_genre${oeuvre}.txt"
	elif ${flag_casting}; then
		rm "last_castings.txt"
		rm "last_castingcharacter.txt"
		rm "last_castingmedia.txt"
		rm "last_castingperson.txt"
	elif ${flag_other}; then
		rm "last_${element}.txt"
	else
		echo -e "\033[31mERROR flag_to_dl\033[0m" >&2
		exit 1
	fi
}
timestart=$(date --rfc-3339=seconds)

case "$1" in 																							#type to dl
	-m|--manga)					oeuvre=manga;
								element=chapters;
								flag_oeuvre=true;
								therelation=manga;;
								
	-a|--anime)					oeuvre=anime;
								element=episodes;
								flag_oeuvre=true;
								therelation=media;;

	-cas|--casting)				element=castings
								flag_casting=true;;
	-c|--character)				element=characters
								flag_other=true;;
	-cat|--categorie)			element=categories
								flag_other=true;;
	-g|--genre)					element=genres
								flag_other=true;;
	-p|--people)				element=people
								flag_other=true;;
	*)							usage > /dev/stderr;
								echo "bad <TYPE>";
								exit 1;;
esac
shift

if [[ "${1}" == *.txt  ]] || [[ "${1}" == *.kitsu  ]] ; then											#detect list.txt or list.kistu
	flag_list=true
	filelist="$1"
	shift
	if [ ! -f ${filelist} ]; then
		echo "file ${filelist} not found"
		usage > /dev/stderr
		exit 1
	fi
	findtmpfilename
	filelistname=".tmp${tmpfilename##*/}.txt"
	sort -g -u "${filelist}" >| "${filelistname}"
fi

if echo "$1" | grep &>/dev/null "^[0-9][0-9]*$" && echo "$2" | grep &>/dev/null "^[0-9][0-9]*$"; then 	#detect borne
	flag_borne=true
	IDSTART="$1"
	IDEND="$2"
	if [ ${IDSTART} -gt ${IDEND} ]; then
		echo IDSTART GT IDEND
		usage > /dev/stderr
		exit 1
	fi
	shift
	shift
fi

while [ $# -gt 0 ]; do 																					#other flag
	case $1 in
		-u|--update)			shift
								if echo "$1" | grep &>/dev/null "^[0-9][0-9]*$" ;then
									size_update=$1
									shift
								fi
								flag_update=true;;

		-sc|--size_compression)	shift
								if echo "$1" | grep &>/dev/null "^[0-9][0-9]*$" ;then
									size_compression=$1
									shift
								fi;;

		-p|--pause)				shift
								flag_pause=true;;

		-f|--force)				shift
								flag_force=true;;

		*)						usage > /dev/stderr
								echo "bad <FLAG>"
								exit 1;;
	esac
done

decompression
firstrun

if ${flag_update} ; then 																				#update button
	IDEND=`cat "last_${element}.txt"`
	$use_kitsulast && updatekitsulast
	! $use_kitsulast && oldupdate
	compression
	IDEND=`cat "last_${element}.txt"`
	echo "we end here ${IDEND}"
elif ${flag_list}; then 																				#with a list
	for i in `cat ${filelistname}`; do
		if ${flag_borne}; then 																			#case list + borne
			if [ $i -lt ${IDSTART} ]; then
				continue
			elif [ $i -gt ${IDEND} ]; then
				break
			fi
		fi
		dlid $i
		((compteur++))
		if [ $compteur -ge $size_compression ]; then
			compteur=0
			compression
		fi
	done
	compression
	echo "done"
	rm "${filelistname}" >/dev/null
elif ${flag_borne}; then 																				#with borne only
	loopdl ${IDSTART} ${IDEND}
	compression
	echo "done"
else
	echo "nothing to do"
	exit 1
fi
timeend=$(date --rfc-3339=seconds)

echo -e "\033[1m${timestart%+*}    ${timeend%+*}\033[0m\n"
end_clean
exit 0
