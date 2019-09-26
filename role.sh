#!/bin/bash

castingDIR="casting"
casting="${castingDIR}/casting"
castingmedia="${castingDIR}/castingmedia"
castingperson="${castingDIR}/castingperson"
castingcharacter="${castingDIR}/castingcharacter"

artist_roleSQL="artist_role.sql"
artist_langSQL="artist_lang.sql"

artistRoleSQL(){
	local file="${1}"
	local artistID="${2}"
	local role=$(./parseJson.sh "${file}" "role")
	roleID=0
	role="${role// ,}"
	if [[ "${role}" == "2nd Key Animation" ]] ; then
		roleID=1
	elif [[ "${role}" == "ADR Director" ]] ; then
		roleID=2
	elif [[ "${role}" == "Animation Check" ]] ; then
		roleID=3
	elif [[ "${role}" == "Animation Director" ]] ; then
		roleID=4
	elif [[ "${role}" == "Art" ]] ; then
		roleID=5
	elif [[ "${role}" == "Art Director" ]] ; then
		roleID=6
	elif [[ "${role}" == "Assistant Animation Director" ]] ; then
		roleID=7
	elif [[ "${role}" == "Assistant Director" ]] ; then
		roleID=8
	elif [[ "${role}" == "Assistant Engineer" ]] ; then
		roleID=9
	elif [[ "${role}" == "Assistant Producer" ]] ; then
		roleID=10
	elif [[ "${role}" == "Assistant Production Coordinat" ]] ; then
		roleID=11
	elif [[ "${role}" == "Associate Producer" ]] ; then
		roleID=12
	elif [[ "${role}" == "Background Art" ]] ; then
		roleID=13
	elif [[ "${role}" == "Casting Director" ]] ; then
		roleID=14
	elif [[ "${role}" == "Character Design" ]] ; then
		roleID=15
	elif [[ "${role}" == "1Chief Animation Director" ]] ; then
		roleID=16
	elif [[ "${role}" == "Chief Producer" ]] ; then
		roleID=17
	elif [[ "${role}" == "Co-Director" ]] ; then
		roleID=18
	elif [[ "${role}" == "Color Design" ]] ; then
		roleID=19
	elif [[ "${role}" == "Color Setting" ]] ; then
		roleID=20
	elif [[ "${role}" == "Co-Producer" ]] ; then
		roleID=21
	elif [[ "${role}" == "Creator" ]] ; then
		roleID=22
	elif [[ "${role}" == "Dialogue Editing" ]] ; then
		roleID=23
	elif [[ "${role}" == "Digital Paint" ]] ; then
		roleID=24
	elif [[ "${role}" == "Director" ]] ; then
		roleID=25
	elif [[ "${role}" == "Director of Photography" ]] ; then
		roleID=26
	elif [[ "${role}" == "Editing" ]] ; then
		roleID=27
	elif [[ "${role}" == "Episode Director" ]] ; then
		roleID=28
	elif [[ "${role}" == "Executive Producer" ]] ; then
		roleID=29
	elif [[ "${role}" == "In-Between Animation" ]] ; then
		roleID=30
	elif [[ "${role}" == "Inserted Song Performance" ]] ; then
		roleID=31
	elif [[ "${role}" == "Key Animation" ]] ; then
		roleID=32
	elif [[ "${role}" == "Layout" ]] ; then
		roleID=33
	elif [[ "${role}" == "Main" ]] ; then
		roleID=34
	elif [[ "${role}" == "Mechanical Design" ]] ; then
		roleID=35
	elif [[ "${role}" == "Music" ]] ; then
		roleID=36
	elif [[ "${role}" == "Online Editor" ]] ; then
		roleID=37
	elif [[ "${role}" == "Original Character Design" ]] ; then
		roleID=38
	elif [[ "${role}" == "Original Creator" ]] ; then
		roleID=39
	elif [[ "${role}" == "Planning" ]] ; then
		roleID=40
	elif [[ "${role}" == "Planning Producer" ]] ; then
		roleID=41
	elif [[ "${role}" == "Post-Production Assistant" ]] ; then
		roleID=42
	elif [[ "${role}" == "Principle Drawing" ]] ; then
		roleID=43
	elif [[ "${role}" == "Producer" ]] ; then
		roleID=44
	elif [[ "${role}" == "Production Assistant" ]] ; then
		roleID=45
	elif [[ "${role}" == "Production Coordination" ]] ; then
		roleID=46
	elif [[ "${role}" == "Production Manager" ]] ; then
		roleID=47
	elif [[ "${role}" == "Publicity" ]] ; then
		roleID=48
	elif [[ "${role}" == "Recording" ]] ; then
		roleID=49
	elif [[ "${role}" == "Recording Assistant" ]] ; then
		roleID=50
	elif [[ "${role}" == "Recording Engineer" ]] ; then
		roleID=51
	elif [[ "${role}" == "Screenplay" ]] ; then
		roleID=52
	elif [[ "${role}" == "Script" ]] ; then
		roleID=53
	elif [[ "${role}" == "Series Composition" ]] ; then
		roleID=54
	elif [[ "${role}" == "Series Production Director" ]] ; then
		roleID=55
	elif [[ "${role}" == "Setting" ]] ; then
		roleID=56
	elif [[ "${role}" == "Setting Manager" ]] ; then
		roleID=57
	elif [[ "${role}" == "5Sound Director" ]] ; then
		roleID=58
	elif [[ "${role}" == "Sound Effects" ]] ; then
		roleID=59
	elif [[ "${role}" == "Sound Manager" ]] ; then
		roleID=60
	elif [[ "${role}" == "Sound Supervisor" ]] ; then
		roleID=61
	elif [[ "${role}" == "Special Effects" ]] ; then
		roleID=62
	elif [[ "${role}" == "Spotting" ]] ; then
		roleID=63
	elif [[ "${role}" == "Story" ]] ; then
		roleID=64
	elif [[ "${role}" == "Story & Art" ]] ; then
		roleID=65
	elif [[ "${role}" == "Storyboard" ]] ; then
		roleID=66
	elif [[ "${role}" == "Theme Song Arrangement" ]] ; then
		roleID=67
	elif [[ "${role}" == "Theme Song Composition" ]] ; then
		roleID=68
	elif [[ "${role}" == "Theme Song Lyrics" ]] ; then
		roleID=69
	elif [[ "${role}" == "Theme Song Performance" ]] ; then
		roleID=70
	elif [[ "${role}" == "Voice Actor" ]] || [[ "${role}" == "Japanese" ]] || [[ "${role}" == "French" ]] || [[ "${role}" == "English" ]] || [[ "${role}" == "Spanish" ]] || [[ "${role}" == "Italian" ]] || [[ "${role}" == "German" ]] || [[ "${role}" == "Hungarian" ]]; then
		roleID=71
	else
		echo "${role} = ${role}" >> roleBug
	fi
	
	#language of voice actor
	local lang=""
	local langID=0
	if [ $roleID -eg 71 ];then
		if [[ "${role}" == "Japanese" ]] || [[ "${role}" == "French" ]] || [[ "${role}" == "English" ]] || [[ "${role}" == "Spanish" ]] || [[ "${role}" == "Italian" ]] || [[ "${role}" == "German" ]] || [[ "${role}" == "Hungarian" ]];then
			lang=$(./parseJson.sh "${file}" "role")
		else
			lang=$(./parseJson.sh "${file}" "language")
		fi
		lang="${lang// ,}"
		if [[ "${lang}" == "Japanese" ]];then
			langID=1
		elif [[ "${role}" == "French" ]];then
			langID=2
		elif [[ "${role}" == "English" ]];then
			langID=3
		elif [[ "${role}" == "Spanish" ]];then
			langID=4
		elif [[ "${role}" == "Italian" ]]; then
			langID=5
		elif [[ "${role}" == "German" ]]; then
			langID=6
		elif [[ "${role}" == "Hungarian" ]]; then
			langID=7
		else
			echo "artist  = $artistID , ${lang}" >> role_langBug
		fi	
		if [ ! $langID -eg 0 ];then
			echo "INSERT INTO artist_lang (id_artist,id_lang) VALUE($artistID,$langID)"	#>> artist_langSQL
		fi
	fi
	if [ ! roleID -eg 0 ];then
		echo "INSERT INTO artist_artist_role  (id_artist,id_artist_role) VALUE($artistID,$roleID)"	#>> artist_roleSQL
	fi
}

castingMedia(){
	local file="${1}"
	local artistID="${2}"
	kitsumediaID=$(./parseJson.sh "${file}" "id")
	local mediaType=$(./parseJson.sh "${file}" "type")
	mediaType="${mediaType// ,}"
	if [[ "${mediaType}" == "anime" ]];then
		idartist=`searchWithKitsuIdInTXT "$animeTXT" "$artistID"`
	elif [[ "${mediaType}" == "manga" ]];then
		idartist=`searchWithKitsuIdInTXT "$mangaTXT" "$artistID"`
		if [[ idartist == '' ]];then
			idartist=`searchWithKitsuIdInTXT "$lastLightNovelTXT" "$artistID"`
		fi 
	fi
}

castingCharacterSQL(){
	local file="${1}"
	local artistID="${2}"
	local kitsucharacterID=$(./parseJson.sh "${file}" "id")
}

castingPeopleSQL(){
	local file="${1}"
	local artistID="${2}"
	local kitsupeopleID=$(./parseJson.sh "${file}" "id")
}
