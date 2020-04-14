#!/bin/bash

#Variable globale et initialisation
image="Images"
charactersDIR="characters"
animeDIR="animes"
descriptionDIR="Description"
peopleDIR="peoples"
mangaDIR="manga0-40692_chapters0-709205/mangas"

lastArtworkTXT="last_artwork.txt"
lastAnimeTXT="last_anime.txt"
lastMangaTXT="last_manga.txt"
lastLightNovelTXT="last_light_novel.txt"
lastCharacterTXT="last_character.txt"
lastEpisodeTXT="last_episode.txt"
lastChapterTXT="last_chapter.txt"
lastPeopleTXT="last_people.txt"

lastArtwork="0"
lastAnime="0"
lastManga="0"
lastLightNovel="0"
lastCharacter="0"
lastEpisode="0"
lastChapter="0"
lastPeople="0"

mangaTXT="manga.txt"
chapterTXT="chapter.txt"
characterTXT="character.txt"
animeTXT="anime.txt"
episodeTXT="episode.txt"
peopleTXT="people.txt"
lightNovelTXT="light_novel.txt"
peopleTXT="people.txt"

artworkMangaTXT="artworkManga.txt"
artworkAnimeTXT="artworkAnime.txt"
artworkLightNovelTXT="artworkLightNovel.txt"

artworkSQL="artwork.sql"
artworkCharacterSQL="artwork_character.sql"
artworkGenreSQL="artwork_genre.sql"

mangaSQL="manga.sql"
mangaChapterSQL="manga_chapter.sql"

animeSQL="anime.sql"
animeEpisodeSQL="anime_episode.sql"
episodeSQL="episode.sql"

lightNovelSQL="light_novel.sql"
lightNovelChapterSQL="light_novel_chapter.sql"

characterSQL="character.sql"

peopleSQL="people.sql"

chapterSQL="chapter.sql"

#pause
pause(){
	if [ -f "pause" ]; then												
		echo "pause detected. waiting..."
		while [ -f "pause" ]; do
			sleep 2
		done
	fi
}

#fonction d'initialisation des txt
initLastTXT(){
	if [ ! -e "$lastMangaTXT" ];then
		echo "0" >| $lastMangaTXT
	fi
	
	if [ ! -e "$lastLightNovelTXT" ];then
		echo "0" >| $lastLightNovelTXT
	fi
	
	if [ ! -e "$lastArtworkTXT" ];then
		echo "0" >| $lastArtworkTXT
	fi
	
	if [ ! -e "$lastAnimeTXT" ];then
		echo "0" >| $lastAnimeTXT
	fi
	
	if [ ! -e "$lastCharacterTXT" ];then
		echo "0" >| $lastCharacterTXT
	fi
	
	if [ ! -e "$lastEpisodeTXT" ];then
		echo "0" >| $lastEpisodeTXT
	fi
	
	if [ ! -e "$lastChapterTXT" ];then
		echo "0" >| $lastChapterTXT
	fi
	
	if [ ! -e "$lastPeopleTXT" ];then
		echo "0" >| $lastPeopleTXT
	fi
	
	lastArtwork=`cat $lastArtworkTXT`
	lastAnime=`cat $lastAnimeTXT`
	lastManga=`cat $lastMangaTXT`
	lastLightNovel=`cat $lastLightNovelTXT`
	lastCharacter=`cat $lastCharacterTXT`
	lastEpisode=`cat $lastEpisodeTXT`
	lastChapter=`cat $lastChapterTXT`
	lastPeople=`cat $lastPeopleTXT`
}

#$1 premier id = notre id, $2 deuxieme id = id de kitsu, $3 le fichier txt
idToTXT(){
	local file="${3}"
	echo "$1=$2" >> $file
}

searchIdKitsuInTXT(){
	local file="${2}"
	local id="${1}"
	local result=`grep -e "${id}=" ${file} | sed -e 's/^.*=//'`
	echo "$result"
}

searchWithKitsuIdInTXT(){
	local file="${2}"
	local id="${1}"
	local result=`grep -e "=id" ${file} | sed -e 's/=.*//'`
	echo "$result"
}

#retourne les id séparé d'un espace
getGenre(){
	local file="${1}"
	local genres=$(./parseJsonMultiple.sh ${file} "id")
	echo "$genres"
}

#$1 l'id du artwork, $2 les genres (une string avec les ids séparé d'un espace
artworkGenreSQL(){
	local artwork="${1}"
	local genres="${2}"
	IFS=" "
	# chaque echo donne l'id d'un genre
	for genre in $genres;do
		echo "INSERT INTO artwork_genre (artwork_id,genre_id) VALUES (\"$artwork\",\"$genre\");" >> $artworkGenreSQL
	done
	unset IFS		
}

#$1 l'id du artwork, $2 l'id du personnage
artworkCharacterSQL(){
	local artwork="${1}"
	local character="${2}"
	echo "INSERT INTO artwork_character (artwork_id,character_id) VALUES (\"$artwork\",\"$character\");" >> $artworkCharacterSQL
}

#$1 l'id du manga, $2 l'id du chapter
mangaChapterSQL(){
	local manga="${1}"
	local chapter="${2}"
	echo "INSERT INTO manga_chapter (manga_id,chapter_id) VALUES (\"$manga\",\"$chapter\");" >> $mangaChapterSQL
}

#$1 l'id du lightnovel, $2 l'id du chapter
lightnovelChapterSQL(){
	local lightnovel="${1}"
	local chapter="${2}"
	echo "INSERT INTO light_novel_chapter (light_novel_id,chapter_id) VALUES (\"$lightnovel\",\"$chapter\");" >> $lightNovelChapterSQL
}

#$1 l'id du anime, $2 l'id du episode
animeEpisodeSQL(){
	local anime="${1}"
	local episode="${2}"
	echo "INSERT INTO anime_episode (anime_id,episode_id) VALUES (\"$anime\",\"$episode\");" >> $animeEpisodeSQL
}

mangaSQL(){
	local file="${1}"
	local mangaID="${2}"
	local artworkID="${3}"
	local synopsis="" #$(./parseJson.sh "${file}" "synopsis")
    local en_jp=$(./parseJson.sh "${file}" "en_jp")
	if [[ "${en_jp}" == *"null"* ]];then
		en_jp=""
    fi
    en_jp="${en_jp// ,}"
    local ja_jp=$(./parseJson.sh "${file}" "ja_jp")
	if [[ "${ja_jp}" == *"null"* ]];then
		ja_jp=""
    fi
    ja_jp="${ja_jp// ,}"
    local ageRating=$(./parseJson.sh "${file}" "ageRating") #G General Audiences;PG Parental Guidance Suggested;R Restricted;R18 Explicit
    if [[ "${ageRating}" == *"null"* ]];then
		ageRating=""
    fi
	ageRating="${ageRating// ,}"
	local startDate=$(./parseJson.sh "${file}" "startDate")
	if [[ "${startDate}" == *"null"* ]];then
		startDate="NULL"
	else
		startDate="\"$startDate\""
    fi
    startDate="${startDate// ,}"
	local endDate=$(./parseJson.sh "${file}" "endDate")	
	if [[ "${endDate}" == *"null"* ]];then
		endDate="NULL"
	else
		endDate="\"$endDate\""
    fi
	endDate="${endDate// ,}"
	local statusID=0
	local status=$(./parseJson.sh "${file}" "status")
	status="${status// ,}"
	if [ "${status,,}" = "current" ];then
		statusID=1
	elif [ "${status,,}" = "finished" ];then
		statusID=2
	elif [ "${status,,}" = "tba" ];then
		statusID=3
	elif [ "${status,,}" = "unreleased" ];then
		statusID=4
	elif [ "${status,,}" = "upcoming" ];then
		statusID=5
	fi
	
	local subtypeID=0
	local subtype=$(./parseJson.sh "${file}" "subtype")
	subtype="${subtype// ,}"
	if [ "${subtype,,}" = "manga" ];then
		subtypeID=1
	elif [ "${subtype,,}" = "manhua" ];then
		subtypeID=2
	elif [ "${subtype,,}" = "manhwa" ];then
		subtypeID=3
	elif [ "${subtype,,}" = "doujin" ];then
		subtypeID=4
	elif [ "${subtype,,}" = "one-shot" ] || [ "${subtype,,}" = "oneshot" ];then
		subtypeID=5
	elif [ "${subtype,,}" = "oel" ];then
		subtypeID=6
	fi
	
	serializationID=0
	local serialization=$(./parseJson.sh ${file} "serialization")	
	serialization="${serialization// ,}"
	serialization=`echo "$serialization" | sed "s/ //g"`
	if [ "${serialization,,}" == "2ddreammagazine" ] ; then
	serializationID=1
	elif [ "${serialization,,}" == "4-komananoace" ] ; then
		serializationID=2
	elif [ "${serialization,,}" == "aceassault" ] ; then
		serializationID=3
	elif [ "${serialization,,}" == "acemomogumi" ] ; then
		serializationID=4
	elif [ "${serialization,,}" == "acenext" ] ; then
		serializationID=5
	elif [ "${serialization,,}" == "acetokunou" ] ; then
		serializationID=6
	elif [ "${serialization,,}" == "ac.qq" ] ; then
		serializationID=7
	elif [ "${serialization,,}" == "actioncomicsboyslove" ] ; then
		serializationID=8
	elif [ "${serialization,,}" == "actionpizazz" ] ; then
		serializationID=9
	elif [ "${serialization,,}" == "actionpizazzdx" ] ; then
		serializationID=10
	elif [ "${serialization,,}" == "actionpizazzhb" ] ; then
		serializationID=11
	elif [ "${serialization,,}" == "actionpizazzspecial" ] ; then
		serializationID=12
	elif [ "${serialization,,}" == "afternoon" ] ; then
		serializationID=13
	elif [ "${serialization,,}" == "agepremium" ] ; then
		serializationID=14
	elif [ "${serialization,,}" == "akalala" ] ; then
		serializationID=15
	elif [ "${serialization,,}" == "akamarujump" ] ; then
		serializationID=16
	elif [ "${serialization,,}" == "alice" ] ; then
		serializationID=17
	elif [ "${serialization,,}" == "alphapolis" ] ; then
		serializationID=18
	elif [ "${serialization,,}" == "alphapoliswebmanga" ] ; then
		serializationID=19
	elif [ "${serialization,,}" == "alternapixiv" ] ; then
		serializationID=20
	elif [ "${serialization,,}" == "altimaace" ] ; then
		serializationID=21
	elif [ "${serialization,,}" == "amiemagazine" ] ; then
		serializationID=22
	elif [ "${serialization,,}" == "anekeipetit-comic" ] ; then
		serializationID=23
	elif [ "${serialization,,}" == "anelala" ] ; then
		serializationID=24
	elif [ "${serialization,,}" == "angelclub" ] ; then
		serializationID=25
	elif [ "${serialization,,}" == "animalhouse" ] ; then
		serializationID=26
	elif [ "${serialization,,}" == "anisemagazine" ] ; then
		serializationID=27
	elif [ "${serialization,,}" == "anisen" ] ; then
		serializationID=28
	elif [ "${serialization,,}" == "aoharu" ] ; then
		serializationID=29
	elif [ "${serialization,,}" == "aoharuonline" ] ; then
		serializationID=30
	elif [ "${serialization,,}" == "aolala" ] ; then
		serializationID=31
	elif [ "${serialization,,}" == "applecollection" ] ; then
		serializationID=32
	elif [ "${serialization,,}" == "applemystery" ] ; then
		serializationID=33
	elif [ "${serialization,,}" == "aquacomics" ] ; then
		serializationID=34
	elif [ "${serialization,,}" == "aquadeep" ] ; then
		serializationID=35
	elif [ "${serialization,,}" == "aquapipi" ] ; then
		serializationID=36
	elif [ "${serialization,,}" == "aria" ] ; then
		serializationID=37
	elif [ "${serialization,,}" == "asahishinbun" ] ; then
		serializationID=38
	elif [ "${serialization,,}" == "asahishougakuseishimbun" ] ; then
		serializationID=39
	elif [ "${serialization,,}" == "asahisonorama" ] ; then
		serializationID=40
	elif [ "${serialization,,}" == "asuka" ] ; then
		serializationID=41
	elif [ "${serialization,,}" == "asukaciel" ] ; then
		serializationID=42
	elif [ "${serialization,,}" == "asukafantasydx" ] ; then
		serializationID=43
	elif [ "${serialization,,}" == "asuka(monthly)" ] ; then
		serializationID=44
	elif [ "${serialization,,}" == "asukamysterydx" ] ; then
		serializationID=45
	elif [ "${serialization,,}" == "awesomefellows!" ] ; then
		serializationID=46
	elif [ "${serialization,,}" == "ax" ] ; then
		serializationID=47
	elif [ "${serialization,,}" == "ayayuri" ] ; then
		serializationID=48
	elif [ "${serialization,,}" == "ayla" ] ; then
		serializationID=49
	elif [ "${serialization,,}" == "baby" ] ; then
		serializationID=50
	elif [ "${serialization,,}" == "bamboocomics" ] ; then
		serializationID=51
	elif [ "${serialization,,}" == "b-boyhoney" ] ; then
		serializationID=52
	elif [ "${serialization,,}" == "b-boyluv" ] ; then
		serializationID=53
	elif [ "${serialization,,}" == "b-boyphoenix" ] ; then
		serializationID=54
	elif [ "${serialization,,}" == "b-boyzips" ] ; then
		serializationID=55
	elif [ "${serialization,,}" == "beansace" ] ; then
		serializationID=56
	elif [ "${serialization,,}" == "be-love" ] ; then
		serializationID=57
	elif [ "${serialization,,}" == "bessatsucorocorocomic" ] ; then
		serializationID=58
	elif [ "${serialization,,}" == "bessatsufriend" ] ; then
		serializationID=59
	elif [ "${serialization,,}" == "bessatsuhanatoyume" ] ; then
		serializationID=60
	elif [ "${serialization,,}" == "bessatsumangagoraku" ] ; then
		serializationID=61
	elif [ "${serialization,,}" == "bessatsumargaret" ] ; then
		serializationID=62
	elif [ "${serialization,,}" == "bessatsushounenchampion" ] ; then
		serializationID=63
	elif [ "${serialization,,}" == "bessatsushounenmagazine" ] ; then
		serializationID=64
	elif [ "${serialization,,}" == "bessatsuyoungchampion" ] ; then
		serializationID=65
	elif [ "${serialization,,}" == "bessatsuyoungmagazine" ] ; then
		serializationID=66
	elif [ "${serialization,,}" == "betsucomi" ] ; then
		serializationID=67
	elif [ "${serialization,,}" == "betsufure" ] ; then
		serializationID=68
	elif [ "${serialization,,}" == "betsufurenext" ] ; then
		serializationID=69
	elif [ "${serialization,,}" == "betsumasister" ] ; then
		serializationID=70
	elif [ "${serialization,,}" == "bexboygold" ] ; then
		serializationID=71
	elif [ "${serialization,,}" == "bexboynovels" ] ; then
		serializationID=72
	elif [ "${serialization,,}" == "bgm" ] ; then
		serializationID=73
	elif [ "${serialization,,}" == "bianca" ] ; then
		serializationID=74
	elif [ "${serialization,,}" == "biblos" ] ; then
		serializationID=75
	elif [ "${serialization,,}" == "bigcomic" ] ; then
		serializationID=76
	elif [ "${serialization,,}" == "bigcomicforladies" ] ; then
		serializationID=77
	elif [ "${serialization,,}" == "bigcomicoriginal" ] ; then
		serializationID=78
	elif [ "${serialization,,}" == "bigcomicoriginalzoukan" ] ; then
		serializationID=79
	elif [ "${serialization,,}" == "bigcomicspirits" ] ; then
		serializationID=80
	elif [ "${serialization,,}" == "bigcomicsuperior" ] ; then
		serializationID=81
	elif [ "${serialization,,}" == "bigcomiczoukan" ] ; then
		serializationID=82
	elif [ "${serialization,,}" == "biggangan" ] ; then
		serializationID=83
	elif [ "${serialization,,}" == "biggold" ] ; then
		serializationID=84
	elif [ "${serialization,,}" == "bishoujokakumeikiwame" ] ; then
		serializationID=85
	elif [ "${serialization,,}" == "bishoujokakumeikiwameroad" ] ; then
		serializationID=86
	elif [ "${serialization,,}" == "bishoujotekikaikatsuryoku" ] ; then
		serializationID=87
	elif [ "${serialization,,}" == "bladeonline" ] ; then
		serializationID=88
	elif [ "${serialization,,}" == "blink" ] ; then
		serializationID=89
	elif [ "${serialization,,}" == "bokkinia" ] ; then
		serializationID=90
	elif [ "${serialization,,}" == "bokura" ] ; then
		serializationID=91
	elif [ "${serialization,,}" == "bonita" ] ; then
		serializationID=92
	elif [ "${serialization,,}" == "booking" ] ; then
		serializationID=93
	elif [ "${serialization,,}" == "boukenou" ] ; then
		serializationID=94
	elif [ "${serialization,,}" == "bouquet" ] ; then
		serializationID=95
	elif [ "${serialization,,}" == "box-air" ] ; then
		serializationID=96
	elif [ "${serialization,,}" == "boyscapi!" ] ; then
		serializationID=97
	elif [ "${serialization,,}" == "boysjam!" ] ; then
		serializationID=98
	elif [ "${serialization,,}" == "boysl" ] ; then
		serializationID=99
	elif [ "${serialization,,}" == "boy'slove" ] ; then
		serializationID=100
	elif [ "${serialization,,}" == "boy'spierce" ] ; then
		serializationID=101
	elif [ "${serialization,,}" == "boy'spiercekindan" ] ; then
		serializationID=102
	elif [ "${serialization,,}" == "b'sanima" ] ; then
		serializationID=103
	elif [ "${serialization,,}" == "b's-loveykatsubou" ] ; then
		serializationID=104
	elif [ "${serialization,,}" == "b's-loveyrecottia" ] ; then
		serializationID=105
	elif [ "${serialization,,}" == "bstreet" ] ; then
		serializationID=106
	elif [ "${serialization,,}" == "bushiroad(monthly)" ] ; then
		serializationID=107
	elif [ "${serialization,,}" == "bushiroadtcgmagazine" ] ; then
		serializationID=108
	elif [ "${serialization,,}" == "businessjump" ] ; then
		serializationID=109
	elif [ "${serialization,,}" == "bustercomic" ] ; then
		serializationID=110
	elif [ "${serialization,,}" == "cab" ] ; then
		serializationID=111
	elif [ "${serialization,,}" == "cabaret-clubcomic" ] ; then
		serializationID=112
	elif [ "${serialization,,}" == "candytime" ] ; then
		serializationID=113
	elif [ "${serialization,,}" == "canna" ] ; then
		serializationID=114
	elif [ "${serialization,,}" == "canopricomic" ] ; then
		serializationID=115
	elif [ "${serialization,,}" == "capbon!" ] ; then
		serializationID=116
	elif [ "${serialization,,}" == "catalogueseries" ] ; then
		serializationID=117
	elif [ "${serialization,,}" == "championcross" ] ; then
		serializationID=118
	elif [ "${serialization,,}" == "championred" ] ; then
		serializationID=119
	elif [ "${serialization,,}" == "championredichigo" ] ; then
		serializationID=120
	elif [ "${serialization,,}" == "championtap!" ] ; then
		serializationID=121
	elif [ "${serialization,,}" == "chance" ] ; then
		serializationID=122
	elif [ "${serialization,,}" == "chance+" ] ; then
		serializationID=123
	elif [ "${serialization,,}" == "chara" ] ; then
		serializationID=124
	elif [ "${serialization,,}" == "charade" ] ; then
		serializationID=125
	elif [ "${serialization,,}" == "charamel" ] ; then
		serializationID=126
	elif [ "${serialization,,}" == "charamelfebri" ] ; then
		serializationID=127
	elif [ "${serialization,,}" == "charaselection" ] ; then
		serializationID=128
	elif [ "${serialization,,}" == "cheese!" ] ; then
		serializationID=129
	elif [ "${serialization,,}" == "cheese!zoukan" ] ; then
		serializationID=130
	elif [ "${serialization,,}" == "cheri+" ] ; then
		serializationID=131
	elif [ "${serialization,,}" == "chobecomi!" ] ; then
		serializationID=132
	elif [ "${serialization,,}" == "chorus" ] ; then
		serializationID=133
	elif [ "${serialization,,}" == "chuchu" ] ; then
		serializationID=134
	elif [ "${serialization,,}" == "ciao" ] ; then
		serializationID=135
	elif [ "${serialization,,}" == "ciaodx" ] ; then
		serializationID=136
	elif [ "${serialization,,}" == "ciaodxhorror" ] ; then
		serializationID=137
	elif [ "${serialization,,}" == "ciel" ] ; then
		serializationID=138
	elif [ "${serialization,,}" == "cieltrestres" ] ; then
		serializationID=139
	elif [ "${serialization,,}" == "citacita" ] ; then
		serializationID=140
	elif [ "${serialization,,}" == "cita-nium" ] ; then
		serializationID=141
	elif [ "${serialization,,}" == "citron" ] ; then
		serializationID=142
	elif [ "${serialization,,}" == "clairtl" ] ; then
		serializationID=143
	elif [ "${serialization,,}" == "clubsunday" ] ; then
		serializationID=144
	elif [ "${serialization,,}" == "cobalt" ] ; then
		serializationID=145
	elif [ "${serialization,,}" == "cocohana" ] ; then
		serializationID=146
	elif [ "${serialization,,}" == "colorfuldrops" ] ; then
		serializationID=147
	elif [ "${serialization,,}" == "comic0ex" ] ; then
		serializationID=148
	elif [ "${serialization,,}" == "comica" ] ; then
		serializationID=149
	elif [ "${serialization,,}" == "comicalive" ] ; then
		serializationID=150
	elif [ "${serialization,,}" == "comicanthurium" ] ; then
		serializationID=151
	elif [ "${serialization,,}" == "comicaqua" ] ; then
		serializationID=152
	elif [ "${serialization,,}" == "comicaun" ] ; then
		serializationID=153
	elif [ "${serialization,,}" == "comicavarus" ] ; then
		serializationID=154
	elif [ "${serialization,,}" == "comicbavel" ] ; then
		serializationID=155
	elif [ "${serialization,,}" == "comicbazooka" ] ; then
		serializationID=156
	elif [ "${serialization,,}" == "comicbe" ] ; then
		serializationID=157
	elif [ "${serialization,,}" == "comicbeam" ] ; then
		serializationID=158
	elif [ "${serialization,,}" == "comicbirz" ] ; then
		serializationID=159
	elif [ "${serialization,,}" == "comicblade" ] ; then
		serializationID=160
	elif [ "${serialization,,}" == "comicblademasamune" ] ; then
		serializationID=161
	elif [ "${serialization,,}" == "comicbladezebel" ] ; then
		serializationID=162
	elif [ "${serialization,,}" == "comicbonbon" ] ; then
		serializationID=163
	elif [ "${serialization,,}" == "comicbreak" ] ; then
		serializationID=164
	elif [ "${serialization,,}" == "comicb's-log" ] ; then
		serializationID=165
	elif [ "${serialization,,}" == "comicb's-logairraid" ] ; then
		serializationID=166
	elif [ "${serialization,,}" == "comicb's-logkyun!" ] ; then
		serializationID=167
	elif [ "${serialization,,}" == "comicbugbug" ] ; then
		serializationID=168
	elif [ "${serialization,,}" == "comicbunbun" ] ; then
		serializationID=169
	elif [ "${serialization,,}" == "comic@bunch" ] ; then
		serializationID=170
	elif [ "${serialization,,}" == "comicbunch" ] ; then
		serializationID=171
	elif [ "${serialization,,}" == "comicburger" ] ; then
		serializationID=172
	elif [ "${serialization,,}" == "comiccandoll" ] ; then
		serializationID=173
	elif [ "${serialization,,}" == "comicchamp" ] ; then
		serializationID=174
	elif [ "${serialization,,}" == "comicchara" ] ; then
		serializationID=175
	elif [ "${serialization,,}" == "comiccharge" ] ; then
		serializationID=176
	elif [ "${serialization,,}" == "comicchois!" ] ; then
		serializationID=177
	elif [ "${serialization,,}" == "comicclear" ] ; then
		serializationID=178
	elif [ "${serialization,,}" == "comiccomomo" ] ; then
		serializationID=179
	elif [ "${serialization,,}" == "comiccomp" ] ; then
		serializationID=180
	elif [ "${serialization,,}" == "comiccue" ] ; then
		serializationID=181
	elif [ "${serialization,,}" == "comiccune" ] ; then
		serializationID=182
	elif [ "${serialization,,}" == "comiccyutt" ] ; then
		serializationID=183
	elif [ "${serialization,,}" == "comicdangan" ] ; then
		serializationID=184
	elif [ "${serialization,,}" == "comicdengekidaioh" ] ; then
		serializationID=185
	elif [ "${serialization,,}" == "comicdengekiteioh" ] ; then
		serializationID=186
	elif [ "${serialization,,}" == "comicdolphin" ] ; then
		serializationID=187
	elif [ "${serialization,,}" == "comicdolphinjr." ] ; then
		serializationID=188
	elif [ "${serialization,,}" == "comicdragon" ] ; then
		serializationID=189
	elif [ "${serialization,,}" == "comicearth☆star" ] ; then
		serializationID=190
	elif [ "${serialization,,}" == "comicero-tama" ] ; then
		serializationID=191
	elif [ "${serialization,,}" == "comicessayroom" ] ; then
		serializationID=192
	elif [ "${serialization,,}" == "comiceuropa" ] ; then
		serializationID=193
	elif [ "${serialization,,}" == "comicexe" ] ; then
		serializationID=194
	elif [ "${serialization,,}" == "comicfans" ] ; then
		serializationID=195
	elif [ "${serialization,,}" == "comicfantasy" ] ; then
		serializationID=196
	elif [ "${serialization,,}" == "comicfire" ] ; then
		serializationID=197
	elif [ "${serialization,,}" == "comicflamingor" ] ; then
		serializationID=198
	elif [ "${serialization,,}" == "comicflapper" ] ; then
		serializationID=199
	elif [ "${serialization,,}" == "comicfleur" ] ; then
		serializationID=200
	elif [ "${serialization,,}" == "comicgaia" ] ; then
		serializationID=201
	elif [ "${serialization,,}" == "comicgamest" ] ; then
		serializationID=202
	elif [ "${serialization,,}" == "comicgamma" ] ; then
		serializationID=203
	elif [ "${serialization,,}" == "comicgang" ] ; then
		serializationID=204
	elif [ "${serialization,,}" == "comicgarden" ] ; then
		serializationID=205
	elif [ "${serialization,,}" == "comicgardo" ] ; then
		serializationID=206
	elif [ "${serialization,,}" == "comicgekiman" ] ; then
		serializationID=207
	elif [ "${serialization,,}" == "comicgeki-yaba" ] ; then
		serializationID=208
	elif [ "${serialization,,}" == "comicgene" ] ; then
		serializationID=209
	elif [ "${serialization,,}" == "comicgenra" ] ; then
		serializationID=210
	elif [ "${serialization,,}" == "comicgrape" ] ; then
		serializationID=211
	elif [ "${serialization,,}" == "comicgt" ] ; then
		serializationID=212
	elif [ "${serialization,,}" == "comicgum" ] ; then
		serializationID=213
	elif [ "${serialization,,}" == "comichanaman" ] ; then
		serializationID=214
	elif [ "${serialization,,}" == "comicheaven" ] ; then
		serializationID=215
	elif [ "${serialization,,}" == "comichigh!" ] ; then
		serializationID=216
	elif [ "${serialization,,}" == "comichimedorobow" ] ; then
		serializationID=217
	elif [ "${serialization,,}" == "comichimekuri" ] ; then
		serializationID=218
	elif [ "${serialization,,}" == "comichime-sakura" ] ; then
		serializationID=219
	elif [ "${serialization,,}" == "comichjbunko" ] ; then
		serializationID=220
	elif [ "${serialization,,}" == "comicholic" ] ; then
		serializationID=221
	elif [ "${serialization,,}" == "comichotmilk" ] ; then
		serializationID=222
	elif [ "${serialization,,}" == "comicino." ] ; then
		serializationID=223
	elif [ "${serialization,,}" == "comicit" ] ; then
		serializationID=224
	elif [ "${serialization,,}" == "comicjumbo" ] ; then
		serializationID=225
	elif [ "${serialization,,}" == "comicjune" ] ; then
		serializationID=226
	elif [ "${serialization,,}" == "comickairaku-ten" ] ; then
		serializationID=227
	elif [ "${serialization,,}" == "comickairaku-tenbeast" ] ; then
		serializationID=228
	elif [ "${serialization,,}" == "comickairaku-tenxtc" ] ; then
		serializationID=229
	elif [ "${serialization,,}" == "comickaryougakuen" ] ; then
		serializationID=230
	elif [ "${serialization,,}" == "comickoh" ] ; then
		serializationID=231
	elif [ "${serialization,,}" == "comickwai" ] ; then
		serializationID=232
	elif [ "${serialization,,}" == "comiclemonclub" ] ; then
		serializationID=233
	elif [ "${serialization,,}" == "comiclily" ] ; then
		serializationID=234
	elif [ "${serialization,,}" == "comiclo" ] ; then
		serializationID=235
	elif [ "${serialization,,}" == "comic@loid" ] ; then
		serializationID=236
	elif [ "${serialization,,}" == "comicloud" ] ; then
		serializationID=237
	elif [ "${serialization,,}" == "comicmagazinelynx" ] ; then
		serializationID=238
	elif [ "${serialization,,}" == "comicmagnum" ] ; then
		serializationID=239
	elif [ "${serialization,,}" == "comicmagnumx" ] ; then
		serializationID=240
	elif [ "${serialization,,}" == "comicmahounoiland" ] ; then
		serializationID=241
	elif [ "${serialization,,}" == "comicmaihimemusou" ] ; then
		serializationID=242
	elif [ "${serialization,,}" == "comicmangaou" ] ; then
		serializationID=243
	elif [ "${serialization,,}" == "comicman-ten" ] ; then
		serializationID=244
	elif [ "${serialization,,}" == "comicmarble" ] ; then
		serializationID=245
	elif [ "${serialization,,}" == "comicmaster" ] ; then
		serializationID=246
	elif [ "${serialization,,}" == "comicmasyo" ] ; then
		serializationID=247
	elif [ "${serialization,,}" == "comicmate" ] ; then
		serializationID=248
	elif [ "${serialization,,}" == "comicmatelegend" ] ; then
		serializationID=249
	elif [ "${serialization,,}" == "comicmegacube" ] ; then
		serializationID=250
	elif [ "${serialization,,}" == "comicmegagold" ] ; then
		serializationID=251
	elif [ "${serialization,,}" == "comicmegamilk" ] ; then
		serializationID=252
	elif [ "${serialization,,}" == "comicmegaplus" ] ; then
		serializationID=253
	elif [ "${serialization,,}" == "comicmegastore" ] ; then
		serializationID=254
	elif [ "${serialization,,}" == "comicmegastorealpha" ] ; then
		serializationID=255
	elif [ "${serialization,,}" == "comicmegastoreh" ] ; then
		serializationID=256
	elif [ "${serialization,,}" == "comicmeteor" ] ; then
		serializationID=257
	elif [ "${serialization,,}" == "comicmilf" ] ; then
		serializationID=258
	elif [ "${serialization,,}" == "comicmilkpurin" ] ; then
		serializationID=259
	elif [ "${serialization,,}" == "comicminimon" ] ; then
		serializationID=260
	elif [ "${serialization,,}" == "comicmoemax" ] ; then
		serializationID=261
	elif [ "${serialization,,}" == "comicmomohime" ] ; then
		serializationID=262
	elif [ "${serialization,,}" == "comicmoog" ] ; then
		serializationID=263
	elif [ "${serialization,,}" == "comicmuga" ] ; then
		serializationID=264
	elif [ "${serialization,,}" == "comicmugentensei" ] ; then
		serializationID=265
	elif [ "${serialization,,}" == "comicmujin" ] ; then
		serializationID=266
	elif [ "${serialization,,}" == "comicnewtype" ] ; then
		serializationID=267
	elif [ "${serialization,,}" == "comicnora" ] ; then
		serializationID=268
	elif [ "${serialization,,}" == "comico" ] ; then
		serializationID=269
	elif [ "${serialization,,}" == "comicojapan" ] ; then
		serializationID=270
	elif [ "${serialization,,}" == "comicojapanchallenge" ] ; then
		serializationID=271
	elif [ "${serialization,,}" == "comicokorea" ] ; then
		serializationID=272
	elif [ "${serialization,,}" == "comicomi" ] ; then
		serializationID=273
	elif [ "${serialization,,}" == "comicorca" ] ; then
		serializationID=274
	elif [ "${serialization,,}" == "comicorecano!" ] ; then
		serializationID=275
	elif [ "${serialization,,}" == "comicotaiwan" ] ; then
		serializationID=276
	elif [ "${serialization,,}" == "comicpapipo" ] ; then
		serializationID=277
	elif [ "${serialization,,}" == "comicpenguinceleb" ] ; then
		serializationID=278
	elif [ "${serialization,,}" == "comicpenguinclub" ] ; then
		serializationID=279
	elif [ "${serialization,,}" == "comicpenguinclubsanzokuban" ] ; then
		serializationID=280
	elif [ "${serialization,,}" == "comicpflirt" ] ; then
		serializationID=281
	elif [ "${serialization,,}" == "comicplum" ] ; then
		serializationID=282
	elif [ "${serialization,,}" == "comicpolaris" ] ; then
		serializationID=283
	elif [ "${serialization,,}" == "comicpool" ] ; then
		serializationID=284
	elif [ "${serialization,,}" == "comicpool(ichijinsha)" ] ; then
		serializationID=285
	elif [ "${serialization,,}" == "comicpot" ] ; then
		serializationID=286
	elif [ "${serialization,,}" == "comicpotpourriclub" ] ; then
		serializationID=287
	elif [ "${serialization,,}" == "comicprism" ] ; then
		serializationID=288
	elif [ "${serialization,,}" == "comicpurumelo" ] ; then
		serializationID=289
	elif [ "${serialization,,}" == "comicpururunmax" ] ; then
		serializationID=290
	elif [ "${serialization,,}" == "comicran" ] ; then
		serializationID=291
	elif [ "${serialization,,}" == "comicrantwins" ] ; then
		serializationID=292
	elif [ "${serialization,,}" == "comicrats" ] ; then
		serializationID=293
	elif [ "${serialization,,}" == "comicrevolution" ] ; then
		serializationID=294
	elif [ "${serialization,,}" == "comicrex" ] ; then
		serializationID=295
	elif [ "${serialization,,}" == "comicride" ] ; then
		serializationID=296
	elif [ "${serialization,,}" == "comicrin" ] ; then
		serializationID=297
	elif [ "${serialization,,}" == "comicruelle" ] ; then
		serializationID=298
	elif [ "${serialization,,}" == "comicrush" ] ; then
		serializationID=299
	elif [ "${serialization,,}" == "comicryu" ] ; then
		serializationID=300
	elif [ "${serialization,,}" == "comicsai" ] ; then
		serializationID=301
	elif [ "${serialization,,}" == "comicsangokushi" ] ; then
		serializationID=302
	elif [ "${serialization,,}" == "comicseed!" ] ; then
		serializationID=303
	elif [ "${serialization,,}" == "comicshingeki" ] ; then
		serializationID=304
	elif [ "${serialization,,}" == "comicshitsuraku-ten" ] ; then
		serializationID=305
	elif [ "${serialization,,}" == "comicshoujoshiki" ] ; then
		serializationID=306
	elif [ "${serialization,,}" == "comicshoujotengoku" ] ; then
		serializationID=307
	elif [ "${serialization,,}" == "comicsigma" ] ; then
		serializationID=308
	elif [ "${serialization,,}" == "comicsituationplay" ] ; then
		serializationID=309
	elif [ "${serialization,,}" == "comicspica" ] ; then
		serializationID=310
	elif [ "${serialization,,}" == "comicsumomo" ] ; then
		serializationID=311
	elif [ "${serialization,,}" == "comictenma" ] ; then
		serializationID=312
	elif [ "${serialization,,}" == "comictokumori" ] ; then
		serializationID=313
	elif [ "${serialization,,}" == "comictom(monthly)" ] ; then
		serializationID=314
	elif [ "${serialization,,}" == "comictomplus" ] ; then
		serializationID=315
	elif [ "${serialization,,}" == "comictoutetsu" ] ; then
		serializationID=316
	elif [ "${serialization,,}" == "comicunreal" ] ; then
		serializationID=317
	elif [ "${serialization,,}" == "comicvalkyrie" ] ; then
		serializationID=318
	elif [ "${serialization,,}" == "comicwalker" ] ; then
		serializationID=319
	elif [ "${serialization,,}" == "comicwalker" ] ; then
		serializationID=320
	elif [ "${serialization,,}" == "comicx-eros" ] ; then
		serializationID=321
	elif [ "${serialization,,}" == "comicxo" ] ; then
		serializationID=322
	elif [ "${serialization,,}" == "comicya!" ] ; then
		serializationID=323
	elif [ "${serialization,,}" == "comicyell!" ] ; then
		serializationID=324
	elif [ "${serialization,,}" == "comicyurihime" ] ; then
		serializationID=325
	elif [ "${serialization,,}" == "comicyurihimes" ] ; then
		serializationID=326
	elif [ "${serialization,,}" == "comiczenon" ] ; then
		serializationID=327
	elif [ "${serialization,,}" == "comiczero-sum" ] ; then
		serializationID=328
	elif [ "${serialization,,}" == "comiczip" ] ; then
		serializationID=329
	elif [ "${serialization,,}" == "comidigi" ] ; then
		serializationID=330
	elif [ "${serialization,,}" == "comiquehug" ] ; then
		serializationID=331
	elif [ "${serialization,,}" == "compace" ] ; then
		serializationID=332
	elif [ "${serialization,,}" == "comptiq" ] ; then
		serializationID=333
	elif [ "${serialization,,}" == "cookie" ] ; then
		serializationID=334
	elif [ "${serialization,,}" == "cookiebox" ] ; then
		serializationID=335
	elif [ "${serialization,,}" == "corocorocomic" ] ; then
		serializationID=336
	elif [ "${serialization,,}" == "craft" ] ; then
		serializationID=337
	elif [ "${serialization,,}" == "crimsoncomics" ] ; then
		serializationID=338
	elif [ "${serialization,,}" == "crunchyroll" ] ; then
		serializationID=339
	elif [ "${serialization,,}" == "cutiecomic" ] ; then
		serializationID=340
	elif [ "${serialization,,}" == "cybercomics" ] ; then
		serializationID=341
	elif [ "${serialization,,}" == "cyberiamaniaex" ] ; then
		serializationID=342
	elif [ "${serialization,,}" == "cycomi" ] ; then
		serializationID=343
	elif [ "${serialization,,}" == "cycomics" ] ; then
		serializationID=344
	elif [ "${serialization,,}" == "daitocomicsboyslove" ] ; then
		serializationID=345
	elif [ "${serialization,,}" == "daiwon" ] ; then
		serializationID=346
	elif [ "${serialization,,}" == "daria" ] ; then
		serializationID=347
	elif [ "${serialization,,}" == "daum" ] ; then
		serializationID=348
	elif [ "${serialization,,}" == "daumleague" ] ; then
		serializationID=349
	elif [ "${serialization,,}" == "daumwebtoon" ] ; then
		serializationID=350
	elif [ "${serialization,,}" == "dear+" ] ; then
		serializationID=351
	elif [ "${serialization,,}" == "deluxebetsucomi" ] ; then
		serializationID=352
	elif [ "${serialization,,}" == "deluxemargaret" ] ; then
		serializationID=353
	elif [ "${serialization,,}" == "dengekibunko" ] ; then
		serializationID=354
	elif [ "${serialization,,}" == "dengekibunkomagazine" ] ; then
		serializationID=355
	elif [ "${serialization,,}" == "dengekicomicgao!" ] ; then
		serializationID=356
	elif [ "${serialization,,}" == "dengekicomicjapan" ] ; then
		serializationID=357
	elif [ "${serialization,,}" == "dengekidaioh" ] ; then
		serializationID=358
	elif [ "${serialization,,}" == "dengekidaiohgenesis" ] ; then
		serializationID=359
	elif [ "${serialization,,}" == "dengekidaiohwebcomic" ] ; then
		serializationID=360
	elif [ "${serialization,,}" == "dengekid-mangaonline" ] ; then
		serializationID=361
	elif [ "${serialization,,}" == "dengekigirl'sstyle" ] ; then
		serializationID=362
	elif [ "${serialization,,}" == "dengekig'scomic" ] ; then
		serializationID=363
	elif [ "${serialization,,}" == "dengekig'sfestival!comic" ] ; then
		serializationID=364
	elif [ "${serialization,,}" == "dengekig'smagazine" ] ; then
		serializationID=365
	elif [ "${serialization,,}" == "dengekig'smagazine" ] ; then
		serializationID=366
	elif [ "${serialization,,}" == "dengekihobby" ] ; then
		serializationID=367
	elif [ "${serialization,,}" == "dengekikuromaoh" ] ; then
		serializationID=368
	elif [ "${serialization,,}" == "dengekimaoh" ] ; then
		serializationID=369
	elif [ "${serialization,,}" == "dengekimoeoh" ] ; then
		serializationID=370
	elif [ "${serialization,,}" == "dengekinintendods" ] ; then
		serializationID=371
	elif [ "${serialization,,}" == "dengekiplaystation" ] ; then
		serializationID=372
	elif [ "${serialization,,}" == "dengekiteioh" ] ; then
		serializationID=373
	elif [ "${serialization,,}" == "dennoumavo" ] ; then
		serializationID=374
	elif [ "${serialization,,}" == "denshibirz" ] ; then
		serializationID=375
	elif [ "${serialization,,}" == "dessert" ] ; then
		serializationID=376
	elif [ "${serialization,,}" == "d-morning" ] ; then
		serializationID=377
	elif [ "${serialization,,}" == "dmzj" ] ; then
		serializationID=378
	elif [ "${serialization,,}" == "dnamediacomics" ] ; then
		serializationID=379
	elif [ "${serialization,,}" == "doki~!" ] ; then
		serializationID=380
	elif [ "${serialization,,}" == "doki~!special" ] ; then
		serializationID=381
	elif [ "${serialization,,}" == "dra-dra-dragonage" ] ; then
		serializationID=382
	elif [ "${serialization,,}" == "dragonage" ] ; then
		serializationID=383
	elif [ "${serialization,,}" == "dragonageextra" ] ; then
		serializationID=384
	elif [ "${serialization,,}" == "dragonagepure" ] ; then
		serializationID=385
	elif [ "${serialization,,}" == "dragonjunior" ] ; then
		serializationID=386
	elif [ "${serialization,,}" == "dragonmagazine" ] ; then
		serializationID=387
	elif [ "${serialization,,}" == "dragonyouth" ] ; then
		serializationID=388
	elif [ "${serialization,,}" == "drap" ] ; then
		serializationID=389
	elif [ "${serialization,,}" == "drapmilk" ] ; then
		serializationID=390
	elif [ "${serialization,,}" == "dvdmajiyaba" ] ; then
		serializationID=391
	elif [ "${serialization,,}" == "e★2" ] ; then
		serializationID=392
	elif [ "${serialization,,}" == "edith" ] ; then
		serializationID=393
	elif [ "${serialization,,}" == "e★everystar" ] ; then
		serializationID=394
	elif [ "${serialization,,}" == "egoist" ] ; then
		serializationID=395
	elif [ "${serialization,,}" == "eleganceeve" ] ; then
		serializationID=396
	elif [ "${serialization,,}" == "emerald" ] ; then
		serializationID=397
	elif [ "${serialization,,}" == "ergo" ] ; then
		serializationID=398
	elif [ "${serialization,,}" == "erotoro(libreshuppan)" ] ; then
		serializationID=399
	elif [ "${serialization,,}" == "esuma" ] ; then
		serializationID=400
	elif [ "${serialization,,}" == "evening" ] ; then
		serializationID=401
	elif [ "${serialization,,}" == "eyes" ] ; then
		serializationID=402
	elif [ "${serialization,,}" == "eyoungmagazine" ] ; then
		serializationID=403
	elif [ "${serialization,,}" == "fakku" ] ; then
		serializationID=404
	elif [ "${serialization,,}" == "famitsu" ] ; then
		serializationID=405
	elif [ "${serialization,,}" == "famitsubros" ] ; then
		serializationID=406
	elif [ "${serialization,,}" == "famitsucomicclear" ] ; then
		serializationID=407
	elif [ "${serialization,,}" == "famitsuplaystation+" ] ; then
		serializationID=408
	elif [ "${serialization,,}" == "fbonline" ] ; then
		serializationID=409
	elif [ "${serialization,,}" == "feelyoung" ] ; then
		serializationID=410
	elif [ "${serialization,,}" == "fellows!" ] ; then
		serializationID=411
	elif [ "${serialization,,}" == "fig" ] ; then
		serializationID=412
	elif [ "${serialization,,}" == "flexcomixblood" ] ; then
		serializationID=413
	elif [ "${serialization,,}" == "flexcomixflare" ] ; then
		serializationID=414
	elif [ "${serialization,,}" == "flexcomixnext" ] ; then
		serializationID=415
	elif [ "${serialization,,}" == "flowercomicsspecial" ] ; then
		serializationID=416
	elif [ "${serialization,,}" == "flowers(monthly)" ] ; then
		serializationID=417
	elif [ "${serialization,,}" == "formrs." ] ; then
		serializationID=418
	elif [ "${serialization,,}" == "foxtooncomic" ] ; then
		serializationID=419
	elif [ "${serialization,,}" == "freshjump" ] ; then
		serializationID=420
	elif [ "${serialization,,}" == "friend" ] ; then
		serializationID=421
	elif [ "${serialization,,}" == "fromgamers" ] ; then
		serializationID=422
	elif [ "${serialization,,}" == "funwarijump" ] ; then
		serializationID=423
	elif [ "${serialization,,}" == "futabashawebmagazine" ] ; then
		serializationID=424
	elif [ "${serialization,,}" == "gabunkomagazine" ] ; then
		serializationID=425
	elif [ "${serialization,,}" == "gagagabunko" ] ; then
		serializationID=426
	elif [ "${serialization,,}" == "galette" ] ; then
		serializationID=427
	elif [ "${serialization,,}" == "gamestmagazine" ] ; then
		serializationID=428
	elif [ "${serialization,,}" == "ganganjoker" ] ; then
		serializationID=429
	elif [ "${serialization,,}" == "ganganonline" ] ; then
		serializationID=430
	elif [ "${serialization,,}" == "ganganpixiv" ] ; then
		serializationID=431
	elif [ "${serialization,,}" == "ganganpowered" ] ; then
		serializationID=432
	elif [ "${serialization,,}" == "ganganwing" ] ; then
		serializationID=433
	elif [ "${serialization,,}" == "ganma!" ] ; then
		serializationID=434
	elif [ "${serialization,,}" == "garakunomori" ] ; then
		serializationID=435
	elif [ "${serialization,,}" == "garo" ] ; then
		serializationID=436
	elif [ "${serialization,,}" == "gateau" ] ; then
		serializationID=437
	elif [ "${serialization,,}" == "gekigayoung" ] ; then
		serializationID=438
	elif [ "${serialization,,}" == "gekkanaction" ] ; then
		serializationID=439
	elif [ "${serialization,,}" == "gekkanshounenjump" ] ; then
		serializationID=440
	elif [ "${serialization,,}" == "gekkan!spirits" ] ; then
		serializationID=441
	elif [ "${serialization,,}" == "gen" ] ; then
		serializationID=442
	elif [ "${serialization,,}" == "genepixiv" ] ; then
		serializationID=443
	elif [ "${serialization,,}" == "generouskiss" ] ; then
		serializationID=444
	elif [ "${serialization,,}" == "gensoufantasy" ] ; then
		serializationID=445
	elif [ "${serialization,,}" == "genzo" ] ; then
		serializationID=446
	elif [ "${serialization,,}" == "gessan" ] ; then
		serializationID=447
	elif [ "${serialization,,}" == "gfantasy" ] ; then
		serializationID=448
	elif [ "${serialization,,}" == "gfantasy(monthly)" ] ; then
		serializationID=449
	elif [ "${serialization,,}" == "girlsform" ] ; then
		serializationID=450
	elif [ "${serialization,,}" == "g-men" ] ; then
		serializationID=451
	elif [ "${serialization,,}" == "gogobunch" ] ; then
		serializationID=452
	elif [ "${serialization,,}" == "good!afternoon" ] ; then
		serializationID=453
	elif [ "${serialization,,}" == "gothicu0026lolitabible" ] ; then
		serializationID=454
	elif [ "${serialization,,}" == "gougaionblue" ] ; then
		serializationID=455
	elif [ "${serialization,,}" == "gramangeki!" ] ; then
		serializationID=456
	elif [ "${serialization,,}" == "grandjump" ] ; then
		serializationID=457
	elif [ "${serialization,,}" == "grandjumppremium" ] ; then
		serializationID=458
	elif [ "${serialization,,}" == "grandjumpweb" ] ; then
		serializationID=459
	elif [ "${serialization,,}" == "g'sister" ] ; then
		serializationID=460
	elif [ "${serialization,,}" == "gundamace" ] ; then
		serializationID=461
	elif [ "${serialization,,}" == "gush" ] ; then
		serializationID=462
	elif [ "${serialization,,}" == "gushpêche" ] ; then
		serializationID=463
	elif [ "${serialization,,}" == "gushpochi." ] ; then
		serializationID=464
	elif [ "${serialization,,}" == "gust" ] ; then
		serializationID=465
	elif [ "${serialization,,}" == ".hack//g.u.theworld" ] ; then
		serializationID=466
	elif [ "${serialization,,}" == "haksan" ] ; then
		serializationID=467
	elif [ "${serialization,,}" == "hanalalaonline" ] ; then
		serializationID=468
	elif [ "${serialization,,}" == "hanamaru" ] ; then
		serializationID=469
	elif [ "${serialization,,}" == "hanamarumanga" ] ; then
		serializationID=470
	elif [ "${serialization,,}" == "hanaoto" ] ; then
		serializationID=471
	elif [ "${serialization,,}" == "hanaotodx" ] ; then
		serializationID=472
	elif [ "${serialization,,}" == "hanatoyume" ] ; then
		serializationID=473
	elif [ "${serialization,,}" == "hanatoyume:bunkeishoujo" ] ; then
		serializationID=474
	elif [ "${serialization,,}" == "hanatoyumeonline" ] ; then
		serializationID=475
	elif [ "${serialization,,}" == "hanatoyumeplus" ] ; then
		serializationID=476
	elif [ "${serialization,,}" == "handycomic" ] ; then
		serializationID=477
	elif [ "${serialization,,}" == "harlequin" ] ; then
		serializationID=478
	elif [ "${serialization,,}" == "harmonyromancezoukangou" ] ; then
		serializationID=479
	elif [ "${serialization,,}" == "harta" ] ; then
		serializationID=480
	elif [ "${serialization,,}" == "haruca" ] ; then
		serializationID=481
	elif [ "${serialization,,}" == "hatsukiss" ] ; then
		serializationID=482
	elif [ "${serialization,,}" == "heros" ] ; then
		serializationID=483
	elif [ "${serialization,,}" == "hertz" ] ; then
		serializationID=484
	elif [ "${serialization,,}" == "hibana" ] ; then
		serializationID=485
	elif [ "${serialization,,}" == "hinakanhi!" ] ; then
		serializationID=486
	elif [ "${serialization,,}" == "hirari" ] ; then
		serializationID=487
	elif [ "${serialization,,}" == "hitomi" ] ; then
		serializationID=488
	elif [ "${serialization,,}" == "hobbyjapan" ] ; then
		serializationID=489
	elif [ "${serialization,,}" == "hontouniattakowaihanashi" ] ; then
		serializationID=490
	elif [ "${serialization,,}" == "hontounikowaidouwa" ] ; then
		serializationID=491
	elif [ "${serialization,,}" == "horrorcomicsspecial" ] ; then
		serializationID=492
	elif [ "${serialization,,}" == "horrorm" ] ; then
		serializationID=493
	elif [ "${serialization,,}" == "hugpixiv" ] ; then
		serializationID=494
	elif [ "${serialization,,}" == "ichibansuki" ] ; then
		serializationID=495
	elif [ "${serialization,,}" == "ichijinshamobile" ] ; then
		serializationID=496
	elif [ "${serialization,,}" == "ichiraci" ] ; then
		serializationID=497
	elif [ "${serialization,,}" == "ichisuki" ] ; then
		serializationID=498
	elif [ "${serialization,,}" == "ihertz" ] ; then
		serializationID=499
	elif [ "${serialization,,}" == "ihrhertz" ] ; then
		serializationID=500
	elif [ "${serialization,,}" == "ikki" ] ; then
		serializationID=501
	elif [ "${serialization,,}" == "ikkicomics" ] ; then
		serializationID=502
	elif [ "${serialization,,}" == "infernalboys" ] ; then
		serializationID=503
	elif [ "${serialization,,}" == "iqjump" ] ; then
		serializationID=504
	elif [ "${serialization,,}" == "issue" ] ; then
		serializationID=505
	elif [ "${serialization,,}" == "itan" ] ; then
		serializationID=506
	elif [ "${serialization,,}" == "jidaigekimangajin" ] ; then
		serializationID=507
	elif [ "${serialization,,}" == "joseiseven" ] ; then
		serializationID=508
	elif [ "${serialization,,}" == "joursutekinashufutachi" ] ; then
		serializationID=509
	elif [ "${serialization,,}" == "judy" ] ; then
		serializationID=510
	elif [ "${serialization,,}" == "juicy" ] ; then
		serializationID=511
	elif [ "${serialization,,}" == "jumpcross" ] ; then
		serializationID=512
	elif [ "${serialization,,}" == "jumpgiga" ] ; then
		serializationID=513
	elif [ "${serialization,,}" == "jumplive" ] ; then
		serializationID=514
	elif [ "${serialization,,}" == "jumpsq" ] ; then
		serializationID=515
	elif [ "${serialization,,}" == "jumpsq.19" ] ; then
		serializationID=516
	elif [ "${serialization,,}" == "jumpsq.crown" ] ; then
		serializationID=517
	elif [ "${serialization,,}" == "jumpsq.crown(shueisha)" ] ; then
		serializationID=518
	elif [ "${serialization,,}" == "jumpsq.lab" ] ; then
		serializationID=519
	elif [ "${serialization,,}" == "jumpvs" ] ; then
		serializationID=520
	elif [ "${serialization,,}" == "jumpx" ] ; then
		serializationID=521
	elif [ "${serialization,,}" == "jun-aikajitsu" ] ; then
		serializationID=522
	elif [ "${serialization,,}" == "june" ] ; then
		serializationID=523
	elif [ "${serialization,,}" == "junecomics" ] ; then
		serializationID=524
	elif [ "${serialization,,}" == "junecomicspiaceseries" ] ; then
		serializationID=525
	elif [ "${serialization,,}" == "juniorchamp" ] ; then
		serializationID=526
	elif [ "${serialization,,}" == "junk!boy" ] ; then
		serializationID=527
	elif [ "${serialization,,}" == "junkudo" ] ; then
		serializationID=528
	elif [ "${serialization,,}" == "justcomic" ] ; then
		serializationID=529
	elif [ "${serialization,,}" == "kadokawanicoace" ] ; then
		serializationID=530
	elif [ "${serialization,,}" == "kadokawaniconicoace" ] ; then
		serializationID=531
	elif [ "${serialization,,}" == "kaesumabunko" ] ; then
		serializationID=532
	elif [ "${serialization,,}" == "kanman" ] ; then
		serializationID=533
	elif [ "${serialization,,}" == "kantanubuntu!" ] ; then
		serializationID=534
	elif [ "${serialization,,}" == "karen" ] ; then
		serializationID=535
	elif [ "${serialization,,}" == "karyougakuenshotoubu" ] ; then
		serializationID=536
	elif [ "${serialization,,}" == "karyousakuragumietsu" ] ; then
		serializationID=537
	elif [ "${serialization,,}" == "kawaadeshoboshinsha" ] ; then
		serializationID=538
	elif [ "${serialization,,}" == "kera" ] ; then
		serializationID=539
	elif [ "${serialization,,}" == "kero-keroace" ] ; then
		serializationID=540
	elif [ "${serialization,,}" == "kerokeroace" ] ; then
		serializationID=541
	elif [ "${serialization,,}" == "kg" ] ; then
		serializationID=542
	elif [ "${serialization,,}" == "kibounotomo" ] ; then
		serializationID=543
	elif [ "${serialization,,}" == "kimitoboku" ] ; then
		serializationID=544
	elif [ "${serialization,,}" == "kindaimahjong" ] ; then
		serializationID=545
	elif [ "${serialization,,}" == "kindaimahjonggold" ] ; then
		serializationID=546
	elif [ "${serialization,,}" == "kindaimahjongoriginal" ] ; then
		serializationID=547
	elif [ "${serialization,,}" == "kinnikuotoko" ] ; then
		serializationID=548
	elif [ "${serialization,,}" == "kirara16" ] ; then
		serializationID=549
	elif [ "${serialization,,}" == "kiss" ] ; then
		serializationID=550
	elif [ "${serialization,,}" == "kiss+" ] ; then
		serializationID=551
	elif [ "${serialization,,}" == "kissca" ] ; then
		serializationID=552
	elif [ "${serialization,,}" == "kissui" ] ; then
		serializationID=553
	elif [ "${serialization,,}" == "kitora" ] ; then
		serializationID=554
	elif [ "${serialization,,}" == "kitsch" ] ; then
		serializationID=555
	elif [ "${serialization,,}" == "koijune" ] ; then
		serializationID=556
	elif [ "${serialization,,}" == "komikult" ] ; then
		serializationID=557
	elif [ "${serialization,,}" == "konomangagasugoi!web" ] ; then
		serializationID=558
	elif [ "${serialization,,}" == "koushokushounen" ] ; then
		serializationID=559
	elif [ "${serialization,,}" == "ktoon" ] ; then
		serializationID=560
	elif [ "${serialization,,}" == "kuaikanmanhua" ] ; then
		serializationID=561
	elif [ "${serialization,,}" == "kuragebunch" ] ; then
		serializationID=562
	elif [ "${serialization,,}" == "kurofunemomo" ] ; then
		serializationID=563
	elif [ "${serialization,,}" == "kurofunepixiv" ] ; then
		serializationID=564
	elif [ "${serialization,,}" == "kurofunezero" ] ; then
		serializationID=565
	elif [ "${serialization,,}" == "kurolala" ] ; then
		serializationID=566
	elif [ "${serialization,,}" == "lala" ] ; then
		serializationID=567
	elif [ "${serialization,,}" == "laladx" ] ; then
		serializationID=568
	elif [ "${serialization,,}" == "lalamelodyonline" ] ; then
		serializationID=569
	elif [ "${serialization,,}" == "lalaspecial" ] ; then
		serializationID=570
	elif [ "${serialization,,}" == "lcmysterycomic" ] ; then
		serializationID=571
	elif [ "${serialization,,}" == "leedcomic" ] ; then
		serializationID=572
	elif [ "${serialization,,}" == "leedcomicbaku" ] ; then
		serializationID=573
	elif [ "${serialization,,}" == "lehzin" ] ; then
		serializationID=574
	elif [ "${serialization,,}" == "lezhin" ] ; then
		serializationID=575
	elif [ "${serialization,,}" == "lezhincomics" ] ; then
		serializationID=576
	elif [ "${serialization,,}" == "lezhincomicswebtoon" ] ; then
		serializationID=577
	elif [ "${serialization,,}" == "line" ] ; then
		serializationID=578
	elif [ "${serialization,,}" == "linemanga" ] ; then
		serializationID=579
	elif [ "${serialization,,}" == "linewebtoon" ] ; then
		serializationID=580
	elif [ "${serialization,,}" == "linewebtoonindonesia" ] ; then
		serializationID=581
	elif [ "${serialization,,}" == "linewebtoonjapan" ] ; then
		serializationID=582
	elif [ "${serialization,,}" == "linewebtoonthailand" ] ; then
		serializationID=583
	elif [ "${serialization,,}" == "l-ladiesandgirlslove-" ] ; then
		serializationID=584
	elif [ "${serialization,,}" == "lovemission" ] ; then
		serializationID=585
	elif [ "${serialization,,}" == "lovexxxboys" ] ; then
		serializationID=586
	elif [ "${serialization,,}" == "lupiniiiofficialmagazine" ] ; then
		serializationID=587
	elif [ "${serialization,,}" == "magalabo" ] ; then
		serializationID=588
	elif [ "${serialization,,}" == "magazinebexboy" ] ; then
		serializationID=589
	elif [ "${serialization,,}" == "magazinecyberia" ] ; then
		serializationID=590
	elif [ "${serialization,,}" == "magazinee-no" ] ; then
		serializationID=591
	elif [ "${serialization,,}" == "magazinefresh!" ] ; then
		serializationID=592
	elif [ "${serialization,,}" == "magazinepocket" ] ; then
		serializationID=593
	elif [ "${serialization,,}" == "magazinespecial" ] ; then
		serializationID=594
	elif [ "${serialization,,}" == "magazinewooooo!" ] ; then
		serializationID=595
	elif [ "${serialization,,}" == "magazinewooooo!b-gumi" ] ; then
		serializationID=596
	elif [ "${serialization,,}" == "magazine-z" ] ; then
		serializationID=597
	elif [ "${serialization,,}" == "magazinezero" ] ; then
		serializationID=598
	elif [ "${serialization,,}" == "magcomi" ] ; then
		serializationID=599
	elif [ "${serialization,,}" == "magi-cu" ] ; then
		serializationID=600
	elif [ "${serialization,,}" == "magilmcomic" ] ; then
		serializationID=601
	elif [ "${serialization,,}" == "manben" ] ; then
		serializationID=602
	elif [ "${serialization,,}" == "mandala" ] ; then
		serializationID=603
	elif [ "${serialization,,}" == "manga4-komapalette" ] ; then
		serializationID=604
	elif [ "${serialization,,}" == "mangaaction" ] ; then
		serializationID=605
	elif [ "${serialization,,}" == "mangaaction!" ] ; then
		serializationID=606
	elif [ "${serialization,,}" == "mangaai!hime" ] ; then
		serializationID=607
	elif [ "${serialization,,}" == "mangaaiki" ] ; then
		serializationID=608
	elif [ "${serialization,,}" == "mangaallman" ] ; then
		serializationID=609
	elif [ "${serialization,,}" == "mangaanimec" ] ; then
		serializationID=610
	elif [ "${serialization,,}" == "mangabangaichi" ] ; then
		serializationID=611
	elif [ "${serialization,,}" == "mangabon" ] ; then
		serializationID=612
	elif [ "${serialization,,}" == "mangabox" ] ; then
		serializationID=613
	elif [ "${serialization,,}" == "mangaboys" ] ; then
		serializationID=614
	elif [ "${serialization,,}" == "mangaclub" ] ; then
		serializationID=615
	elif [ "${serialization,,}" == "mangacluboriginal" ] ; then
		serializationID=616
	elif [ "${serialization,,}" == "mangaeroticsf" ] ; then
		serializationID=617
	elif [ "${serialization,,}" == "mangaerotopia" ] ; then
		serializationID=618
	elif [ "${serialization,,}" == "mangagoccha" ] ; then
		serializationID=619
	elif [ "${serialization,,}" == "mangagoraku" ] ; then
		serializationID=620
	elif [ "${serialization,,}" == "mangagorakudokuhon" ] ; then
		serializationID=621
	elif [ "${serialization,,}" == "mangagorakunexter" ] ; then
		serializationID=622
	elif [ "${serialization,,}" == "mangagorakuspecial" ] ; then
		serializationID=623
	elif [ "${serialization,,}" == "mangagrimmdouwa" ] ; then
		serializationID=624
	elif [ "${serialization,,}" == "mangahome" ] ; then
		serializationID=625
	elif [ "${serialization,,}" == "mangahotmilk" ] ; then
		serializationID=626
	elif [ "${serialization,,}" == "mangakisoutengai" ] ; then
		serializationID=627
	elif [ "${serialization,,}" == "mangakisoutengai" ] ; then
		serializationID=628
	elif [ "${serialization,,}" == "mangalife" ] ; then
		serializationID=629
	elif [ "${serialization,,}" == "mangalifemomo" ] ; then
		serializationID=630
	elif [ "${serialization,,}" == "mangalifeoriginal" ] ; then
		serializationID=631
	elif [ "${serialization,,}" == "mangalifestoria" ] ; then
		serializationID=632
	elif [ "${serialization,,}" == "mangalifewin" ] ; then
		serializationID=633
	elif [ "${serialization,,}" == "mangaone" ] ; then
		serializationID=634
	elif [ "${serialization,,}" == "mangapalettelite" ] ; then
		serializationID=635
	elif [ "${serialization,,}" == "mangapixiv" ] ; then
		serializationID=636
	elif [ "${serialization,,}" == "mangashounen" ] ; then
		serializationID=637
	elif [ "${serialization,,}" == "mangasunday" ] ; then
		serializationID=638
	elif [ "${serialization,,}" == "mangasunday(weekly)" ] ; then
		serializationID=639
	elif [ "${serialization,,}" == "mangatime" ] ; then
		serializationID=640
	elif [ "${serialization,,}" == "mangatimefamily" ] ; then
		serializationID=641
	elif [ "${serialization,,}" == "mangatimejumbo" ] ; then
		serializationID=642
	elif [ "${serialization,,}" == "mangatimekirara" ] ; then
		serializationID=643
	elif [ "${serialization,,}" == "mangatimekiraracarat" ] ; then
		serializationID=644
	elif [ "${serialization,,}" == "mangatimekiraraforward" ] ; then
		serializationID=645
	elif [ "${serialization,,}" == "mangatimekirara☆magica" ] ; then
		serializationID=646
	elif [ "${serialization,,}" == "mangatimekiraramax" ] ; then
		serializationID=647
	elif [ "${serialization,,}" == "mangatimekiraramiracle!" ] ; then
		serializationID=648
	elif [ "${serialization,,}" == "mangatimelovely" ] ; then
		serializationID=649
	elif [ "${serialization,,}" == "mangatimeoriginal" ] ; then
		serializationID=650
	elif [ "${serialization,,}" == "mangatimespecial" ] ; then
		serializationID=651
	elif [ "${serialization,,}" == "mangatown" ] ; then
		serializationID=652
	elif [ "${serialization,,}" == "mangaup!" ] ; then
		serializationID=653
	elif [ "${serialization,,}" == "mangazettaimanzoku" ] ; then
		serializationID=654
	elif [ "${serialization,,}" == "manhuashijie" ] ; then
		serializationID=655
	elif [ "${serialization,,}" == "manhuaweibo" ] ; then
		serializationID=656
	elif [ "${serialization,,}" == "manmanmanhua" ] ; then
		serializationID=657
	elif [ "${serialization,,}" == "marble" ] ; then
		serializationID=658
	elif [ "${serialization,,}" == "margaret" ] ; then
		serializationID=659
	elif [ "${serialization,,}" == "margaretbookstore" ] ; then
		serializationID=660
	elif [ "${serialization,,}" == "margaretbookstore!" ] ; then
		serializationID=661
	elif [ "${serialization,,}" == "marukatsufamicom" ] ; then
		serializationID=662
	elif [ "${serialization,,}" == "me" ] ; then
		serializationID=663
	elif [ "${serialization,,}" == "mebae" ] ; then
		serializationID=664
	elif [ "${serialization,,}" == "megamimagazine" ] ; then
		serializationID=665
	elif [ "${serialization,,}" == "megastore" ] ; then
		serializationID=666
	elif [ "${serialization,,}" == "mei" ] ; then
		serializationID=667
	elif [ "${serialization,,}" == "mellowmellow" ] ; then
		serializationID=668
	elif [ "${serialization,,}" == "melody" ] ; then
		serializationID=669
	elif [ "${serialization,,}" == "meloncomic" ] ; then
		serializationID=670
	elif [ "${serialization,,}" == "mengmengguan" ] ; then
		serializationID=671
	elif [ "${serialization,,}" == "men'sgold" ] ; then
		serializationID=672
	elif [ "${serialization,,}" == "men'syoung" ] ; then
		serializationID=673
	elif [ "${serialization,,}" == "men'syoungspecialikazuchi" ] ; then
		serializationID=674
	elif [ "${serialization,,}" == "mephisto" ] ; then
		serializationID=675
	elif [ "${serialization,,}" == "michao" ] ; then
		serializationID=676
	elif [ "${serialization,,}" == "mike+comics" ] ; then
		serializationID=677
	elif [ "${serialization,,}" == "mikosurihangekijou" ] ; then
		serializationID=678
	elif [ "${serialization,,}" == "millefeui" ] ; then
		serializationID=679
	elif [ "${serialization,,}" == "mimi" ] ; then
		serializationID=680
	elif [ "${serialization,,}" == "minnanocomic" ] ; then
		serializationID=681
	elif [ "${serialization,,}" == "miraclejump" ] ; then
		serializationID=682
	elif [ "${serialization,,}" == "mistmagazine" ] ; then
		serializationID=683
	elif [ "${serialization,,}" == "moae" ] ; then
		serializationID=684
	elif [ "${serialization,,}" == "mobileflower" ] ; then
		serializationID=685
	elif [ "${serialization,,}" == "mobileman" ] ; then
		serializationID=686
	elif [ "${serialization,,}" == "moca" ] ; then
		serializationID=687
	elif [ "${serialization,,}" == "modelgraphix" ] ; then
		serializationID=688
	elif [ "${serialization,,}" == "monmon" ] ; then
		serializationID=689
	elif [ "${serialization,,}" == "monthlyaction" ] ; then
		serializationID=690
	elif [ "${serialization,,}" == "monthlybiggangan" ] ; then
		serializationID=691
	elif [ "${serialization,,}" == "monthlycomiczenon" ] ; then
		serializationID=692
	elif [ "${serialization,,}" == "monthlyflowers" ] ; then
		serializationID=693
	elif [ "${serialization,,}" == "monthlyqoopa!" ] ; then
		serializationID=694
	elif [ "${serialization,,}" == "monthlyshounenmagazine+" ] ; then
		serializationID=695
	elif [ "${serialization,,}" == "morning" ] ; then
		serializationID=696
	elif [ "${serialization,,}" == "morningkc" ] ; then
		serializationID=697
	elif [ "${serialization,,}" == "morningpartyzoukan" ] ; then
		serializationID=698
	elif [ "${serialization,,}" == "morningtwo" ] ; then
		serializationID=699
	elif [ "${serialization,,}" == "motto!" ] ; then
		serializationID=700
	elif [ "${serialization,,}" == "mrblue" ] ; then
		serializationID=701
	elif [ "${serialization,,}" == "mr.magazine" ] ; then
		serializationID=702
	elif [ "${serialization,,}" == "mugenanthologyseries" ] ; then
		serializationID=703
	elif [ "${serialization,,}" == "mugenkan" ] ; then
		serializationID=704
	elif [ "${serialization,,}" == "mutekirenais*girl" ] ; then
		serializationID=705
	elif [ "${serialization,,}" == "mysterybonita" ] ; then
		serializationID=706
	elif [ "${serialization,,}" == "mysterysara" ] ; then
		serializationID=707
	elif [ "${serialization,,}" == "nakayoshi" ] ; then
		serializationID=708
	elif [ "${serialization,,}" == "nakayoshideluxe" ] ; then
		serializationID=709
	elif [ "${serialization,,}" == "nakayoshilovely" ] ; then
		serializationID=710
	elif [ "${serialization,,}" == "namaiki!" ] ; then
		serializationID=711
	elif [ "${serialization,,}" == "nate" ] ; then
		serializationID=712
	elif [ "${serialization,,}" == "natemanhwa" ] ; then
		serializationID=713
	elif [ "${serialization,,}" == "natewebtoons" ] ; then
		serializationID=714
	elif [ "${serialization,,}" == "naver" ] ; then
		serializationID=715
	elif [ "${serialization,,}" == "naverbestchallenge" ] ; then
		serializationID=716
	elif [ "${serialization,,}" == "naverwebtoon" ] ; then
		serializationID=717
	elif [ "${serialization,,}" == "nekopanchi" ] ; then
		serializationID=718
	elif [ "${serialization,,}" == "nekopanchi" ] ; then
		serializationID=719
	elif [ "${serialization,,}" == "nekopara" ] ; then
		serializationID=720
	elif [ "${serialization,,}" == "nemesis" ] ; then
		serializationID=721
	elif [ "${serialization,,}" == "nemuki" ] ; then
		serializationID=722
	elif [ "${serialization,,}" == "newtype" ] ; then
		serializationID=723
	elif [ "${serialization,,}" == "newtypeace" ] ; then
		serializationID=724
	elif [ "${serialization,,}" == "newyouth" ] ; then
		serializationID=725
	elif [ "${serialization,,}" == "nextcomicfirst" ] ; then
		serializationID=726
	elif [ "${serialization,,}" == "niconicoseiga" ] ; then
		serializationID=727
	elif [ "${serialization,,}" == "nikutaiha" ] ; then
		serializationID=728
	elif [ "${serialization,,}" == "nintendodream" ] ; then
		serializationID=729
	elif [ "${serialization,,}" == "noveljapan" ] ; then
		serializationID=730
	elif [ "${serialization,,}" == "nyantype" ] ; then
		serializationID=731
	elif [ "${serialization,,}" == "officeyou" ] ; then
		serializationID=732
	elif [ "${serialization,,}" == "ohsuperjump" ] ; then
		serializationID=733
	elif [ "${serialization,,}" == "ohzorashuppan" ] ; then
		serializationID=734
	elif [ "${serialization,,}" == "omegaverseproject" ] ; then
		serializationID=735
	elif [ "${serialization,,}" == "omoshirobook" ] ; then
		serializationID=736
	elif [ "${serialization,,}" == "onblue" ] ; then
		serializationID=737
	elif [ "${serialization,,}" == "onlinezero-sum" ] ; then
		serializationID=738
	elif [ "${serialization,,}" == "ookbeecomics" ] ; then
		serializationID=739
	elif [ "${serialization,,}" == "opera" ] ; then
		serializationID=740
	elif [ "${serialization,,}" == "otokonokojidai" ] ; then
		serializationID=741
	elif [ "${serialization,,}" == "otomehigh!" ] ; then
		serializationID=742
	elif [ "${serialization,,}" == "otonyan" ] ; then
		serializationID=743
	elif [ "${serialization,,}" == "overlapcomiconline" ] ; then
		serializationID=744
	elif [ "${serialization,,}" == "oyajism" ] ; then
		serializationID=745
	elif [ "${serialization,,}" == "pachinko777" ] ; then
		serializationID=746
	elif [ "${serialization,,}" == "page.kakao" ] ; then
		serializationID=747
	elif [ "${serialization,,}" == "party" ] ; then
		serializationID=748
	elif [ "${serialization,,}" == "pastelcomics" ] ; then
		serializationID=749
	elif [ "${serialization,,}" == "peanutoon" ] ; then
		serializationID=750
	elif [ "${serialization,,}" == "personamagazine" ] ; then
		serializationID=751
	elif [ "${serialization,,}" == "petitcomic" ] ; then
		serializationID=752
	elif [ "${serialization,,}" == "petitcomiczoukan" ] ; then
		serializationID=753
	elif [ "${serialization,,}" == "petitflower" ] ; then
		serializationID=754
	elif [ "${serialization,,}" == "petitprincess" ] ; then
		serializationID=755
	elif [ "${serialization,,}" == "phryné" ] ; then
		serializationID=756
	elif [ "${serialization,,}" == "piace" ] ; then
		serializationID=757
	elif [ "${serialization,,}" == "pixiv" ] ; then
		serializationID=758
	elif [ "${serialization,,}" == "pixivwebtoon" ] ; then
		serializationID=759
	elif [ "${serialization,,}" == "playcomic" ] ; then
		serializationID=760
	elif [ "${serialization,,}" == "pocopoco" ] ; then
		serializationID=761
	elif [ "${serialization,,}" == "pondemix" ] ; then
		serializationID=762
	elif [ "${serialization,,}" == "ponimaga" ] ; then
		serializationID=763
	elif [ "${serialization,,}" == "ponimanga" ] ; then
		serializationID=764
	elif [ "${serialization,,}" == "poplarcomics" ] ; then
		serializationID=765
	elif [ "${serialization,,}" == "pre-comicbunbun" ] ; then
		serializationID=766
	elif [ "${serialization,,}" == "prince(quarterly)" ] ; then
		serializationID=767
	elif [ "${serialization,,}" == "princess" ] ; then
		serializationID=768
	elif [ "${serialization,,}" == "princessgold" ] ; then
		serializationID=769
	elif [ "${serialization,,}" == "pureri" ] ; then
		serializationID=770
	elif [ "${serialization,,}" == "qpa" ] ; then
		serializationID=771
	elif [ "${serialization,,}" == "qpano" ] ; then
		serializationID=772
	elif [ "${serialization,,}" == "quickjapan" ] ; then
		serializationID=773
	elif [ "${serialization,,}" == "racish" ] ; then
		serializationID=774
	elif [ "${serialization,,}" == "rakuenleparadis" ] ; then
		serializationID=775
	elif [ "${serialization,,}" == "rakuenwebzoukan" ] ; then
		serializationID=776
	elif [ "${serialization,,}" == "reijin" ] ; then
		serializationID=777
	elif [ "${serialization,,}" == "reijinbravo!" ] ; then
		serializationID=778
	elif [ "${serialization,,}" == "renaihakushopastel" ] ; then
		serializationID=779
	elif [ "${serialization,,}" == "renailovemax" ] ; then
		serializationID=780
	elif [ "${serialization,,}" == "renaimonogatari" ] ; then
		serializationID=781
	elif [ "${serialization,,}" == "renaiparadise" ] ; then
		serializationID=782
	elif [ "${serialization,,}" == "renairevolution" ] ; then
		serializationID=783
	elif [ "${serialization,,}" == "ribonbikkuri" ] ; then
		serializationID=784
	elif [ "${serialization,,}" == "ribondeluxe" ] ; then
		serializationID=785
	elif [ "${serialization,,}" == "ribonmagazine" ] ; then
		serializationID=786
	elif [ "${serialization,,}" == "ribonmascot" ] ; then
		serializationID=787
	elif [ "${serialization,,}" == "ribonoriginal" ] ; then
		serializationID=788
	elif [ "${serialization,,}" == "ribonspecial" ] ; then
		serializationID=789
	elif [ "${serialization,,}" == "rinka" ] ; then
		serializationID=790
	elif [ "${serialization,,}" == "runrun" ] ; then
		serializationID=791
	elif [ "${serialization,,}" == "rutile" ] ; then
		serializationID=792
	elif [ "${serialization,,}" == "rutilesweet" ] ; then
		serializationID=793
	elif [ "${serialization,,}" == "sacomics" ] ; then
		serializationID=794
	elif [ "${serialization,,}" == "saikyoujump" ] ; then
		serializationID=795
	elif [ "${serialization,,}" == "saizensen" ] ; then
		serializationID=796
	elif [ "${serialization,,}" == "sakurahearts" ] ; then
		serializationID=797
	elif [ "${serialization,,}" == "samanhua" ] ; then
		serializationID=798
	elif [ "${serialization,,}" == "samanyuehua" ] ; then
		serializationID=799
	elif [ "${serialization,,}" == "samuraiace" ] ; then
		serializationID=800
	elif [ "${serialization,,}" == "sengokubushouretsuden" ] ; then
		serializationID=801
	elif [ "${serialization,,}" == "seriemystery" ] ; then
		serializationID=802
	elif [ "${serialization,,}" == "seventeen(monthly)" ] ; then
		serializationID=803
	elif [ "${serialization,,}" == "sfadventure" ] ; then
		serializationID=804
	elif [ "${serialization,,}" == "sfmagazine" ] ; then
		serializationID=805
	elif [ "${serialization,,}" == "shenqi" ] ; then
		serializationID=806
	elif [ "${serialization,,}" == "shikimaya" ] ; then
		serializationID=807
	elif [ "${serialization,,}" == "shincho45" ] ; then
		serializationID=808
	elif [ "${serialization,,}" == "shirolala" ] ; then
		serializationID=809
	elif [ "${serialization,,}" == "sho-comi" ] ; then
		serializationID=810
	elif [ "${serialization,,}" == "sho-comizoukan" ] ; then
		serializationID=811
	elif [ "${serialization,,}" == "shogakukanbooks" ] ; then
		serializationID=812
	elif [ "${serialization,,}" == "shojobeat" ] ; then
		serializationID=813
	elif [ "${serialization,,}" == "shonenshojobokeno" ] ; then
		serializationID=814
	elif [ "${serialization,,}" == "shougakugonensei" ] ; then
		serializationID=815
	elif [ "${serialization,,}" == "shougakuninensei" ] ; then
		serializationID=816
	elif [ "${serialization,,}" == "shougakusannensei" ] ; then
		serializationID=817
	elif [ "${serialization,,}" == "shougakuyonensei" ] ; then
		serializationID=818
	elif [ "${serialization,,}" == "shoujoclub" ] ; then
		serializationID=819
	elif [ "${serialization,,}" == "shoujofriend" ] ; then
		serializationID=820
	elif [ "${serialization,,}" == "shoujoteikoku" ] ; then
		serializationID=821
	elif [ "${serialization,,}" == "shounen" ] ; then
		serializationID=822
	elif [ "${serialization,,}" == "shounenace" ] ; then
		serializationID=823
	elif [ "${serialization,,}" == "shounenbigcomic" ] ; then
		serializationID=824
	elif [ "${serialization,,}" == "shounencaptain" ] ; then
		serializationID=825
	elif [ "${serialization,,}" == "shounenchampion" ] ; then
		serializationID=826
	elif [ "${serialization,,}" == "shounenchampion(monthly)" ] ; then
		serializationID=827
	elif [ "${serialization,,}" == "shounenclub" ] ; then
		serializationID=828
	elif [ "${serialization,,}" == "shounengangan" ] ; then
		serializationID=829
	elif [ "${serialization,,}" == "shounenjets(monthly)" ] ; then
		serializationID=830
	elif [ "${serialization,,}" == "shounenjump" ] ; then
		serializationID=831
	elif [ "${serialization,,}" == "shounenjump+" ] ; then
		serializationID=832
	elif [ "${serialization,,}" == "shounenjumpgiga" ] ; then
		serializationID=833
	elif [ "${serialization,,}" == "shounenjump(monthly)" ] ; then
		serializationID=834
	elif [ "${serialization,,}" == "shounenjumpnext!" ] ; then
		serializationID=835
	elif [ "${serialization,,}" == "shounenjump(weekly)" ] ; then
		serializationID=836
	elif [ "${serialization,,}" == "shounenking" ] ; then
		serializationID=837
	elif [ "${serialization,,}" == "shounenmagazine" ] ; then
		serializationID=838
	elif [ "${serialization,,}" == "shounenmagazineedge" ] ; then
		serializationID=839
	elif [ "${serialization,,}" == "shounenmagazine(monthly)" ] ; then
		serializationID=840
	elif [ "${serialization,,}" == "shounenmagaziner" ] ; then
		serializationID=841
	elif [ "${serialization,,}" == "shounenmagazine(weekly)" ] ; then
		serializationID=842
	elif [ "${serialization,,}" == "shounenrival" ] ; then
		serializationID=843
	elif [ "${serialization,,}" == "shounensirius" ] ; then
		serializationID=844
	elif [ "${serialization,,}" == "shounensunday" ] ; then
		serializationID=845
	elif [ "${serialization,,}" == "shounensundaysuper" ] ; then
		serializationID=846
	elif [ "${serialization,,}" == "shounensunday(weekly)" ] ; then
		serializationID=847
	elif [ "${serialization,,}" == "shounentakarajima(weekly)" ] ; then
		serializationID=848
	elif [ "${serialization,,}" == "shousetsub-boy" ] ; then
		serializationID=849
	elif [ "${serialization,,}" == "shousetsuchocolat" ] ; then
		serializationID=850
	elif [ "${serialization,,}" == "shousetsudear+" ] ; then
		serializationID=851
	elif [ "${serialization,,}" == "shousetsujune" ] ; then
		serializationID=852
	elif [ "${serialization,,}" == "shousetsushinchou" ] ; then
		serializationID=853
	elif [ "${serialization,,}" == "shuukanbunshun" ] ; then
		serializationID=854
	elif [ "${serialization,,}" == "shuukangendai" ] ; then
		serializationID=855
	elif [ "${serialization,,}" == "shuukanshounenchampion" ] ; then
		serializationID=856
	elif [ "${serialization,,}" == "shuukanshounenjump" ] ; then
		serializationID=857
	elif [ "${serialization,,}" == "shuukanshounenmagazine" ] ; then
		serializationID=858
	elif [ "${serialization,,}" == "shuukanshounensunday" ] ; then
		serializationID=859
	elif [ "${serialization,,}" == "shuukanshounensunday(weekly)" ] ; then
		serializationID=860
	elif [ "${serialization,,}" == "shuukanshounenvip" ] ; then
		serializationID=861
	elif [ "${serialization,,}" == "shuuningayuku!special" ] ; then
		serializationID=862
	elif [ "${serialization,,}" == "shy" ] ; then
		serializationID=863
	elif [ "${serialization,,}" == "shynovels" ] ; then
		serializationID=864
	elif [ "${serialization,,}" == "silky" ] ; then
		serializationID=865
	elif [ "${serialization,,}" == "spa!" ] ; then
		serializationID=866
	elif [ "${serialization,,}" == "specialeditiongirls'comic" ] ; then
		serializationID=867
	elif [ "${serialization,,}" == "squarejump" ] ; then
		serializationID=868
	elif [ "${serialization,,}" == "stargirls" ] ; then
		serializationID=869
	elif [ "${serialization,,}" == "stargirlscomic" ] ; then
		serializationID=870
	elif [ "${serialization,,}" == "stencil" ] ; then
		serializationID=871
	elif [ "${serialization,,}" == "studiovoice" ] ; then
		serializationID=872
	elif [ "${serialization,,}" == "sugar" ] ; then
		serializationID=873
	elif [ "${serialization,,}" == "suiyoubinosirius" ] ; then
		serializationID=874
	elif [ "${serialization,,}" == "sukima" ] ; then
		serializationID=875
	elif [ "${serialization,,}" == "sundaygene-x" ] ; then
		serializationID=876
	elif [ "${serialization,,}" == "sundaygx" ] ; then
		serializationID=877
	elif [ "${serialization,,}" == "sundaywebevery" ] ; then
		serializationID=878
	elif [ "${serialization,,}" == "sundaywebry" ] ; then
		serializationID=879
	elif [ "${serialization,,}" == "superbeboycomics" ] ; then
		serializationID=880
	elif [ "${serialization,,}" == "superdashu0026go!" ] ; then
		serializationID=881
	elif [ "${serialization,,}" == "superjump" ] ; then
		serializationID=882
	elif [ "${serialization,,}" == "supermangablast" ] ; then
		serializationID=883
	elif [ "${serialization,,}" == "superrobotmagazine" ] ; then
		serializationID=884
	elif [ "${serialization,,}" == "suspiria" ] ; then
		serializationID=885
	elif [ "${serialization,,}" == "swanmagazine" ] ; then
		serializationID=886
	elif [ "${serialization,,}" == "sweatdrop" ] ; then
		serializationID=887
	elif [ "${serialization,,}" == "swimsuitsfellows!2009" ] ; then
		serializationID=888
	elif [ "${serialization,,}" == "sylph" ] ; then
		serializationID=889
	elif [ "${serialization,,}" == "syosetsu" ] ; then
		serializationID=890
	elif [ "${serialization,,}" == "talesofmagazine" ] ; then
		serializationID=891
	elif [ "${serialization,,}" == "tapas" ] ; then
		serializationID=892
	elif [ "${serialization,,}" == "techgian" ] ; then
		serializationID=893
	elif [ "${serialization,,}" == "televimagazine" ] ; then
		serializationID=894
	elif [ "${serialization,,}" == "televimagazinezoukantelemangaheros" ] ; then
		serializationID=895
	elif [ "${serialization,,}" == "tengxundongman" ] ; then
		serializationID=896
	elif [ "${serialization,,}" == "thedessert" ] ; then
		serializationID=897
	elif [ "${serialization,,}" == "thehanatoyume" ] ; then
		serializationID=898
	elif [ "${serialization,,}" == "themargaret" ] ; then
		serializationID=899
	elif [ "${serialization,,}" == "thesneaker" ] ; then
		serializationID=900
	elif [ "${serialization,,}" == "thesneakerweb" ] ; then
		serializationID=901
	elif [ "${serialization,,}" == "tokusatsuace" ] ; then
		serializationID=902
	elif [ "${serialization,,}" == "tonarinoyoungjump" ] ; then
		serializationID=903
	elif [ "${serialization,,}" == "tophatunderthemoonlight" ] ; then
		serializationID=904
	elif [ "${serialization,,}" == "toptoon" ] ; then
		serializationID=905
	elif [ "${serialization,,}" == "torch" ] ; then
		serializationID=906
	elif [ "${serialization,,}" == "towako" ] ; then
		serializationID=907
	elif [ "${serialization,,}" == "tsubomi" ] ; then
		serializationID=908
	elif [ "${serialization,,}" == "tweetganma!" ] ; then
		serializationID=909
	elif [ "${serialization,,}" == "twi4" ] ; then
		serializationID=910
	elif [ "${serialization,,}" == "twi4" ] ; then
		serializationID=911
	elif [ "${serialization,,}" == "type-moonace" ] ; then
		serializationID=912
	elif [ "${serialization,,}" == "u12kodomofellows" ] ; then
		serializationID=913
	elif [ "${serialization,,}" == "u17" ] ; then
		serializationID=914
	elif [ "${serialization,,}" == "u-2league" ] ; then
		serializationID=915
	elif [ "${serialization,,}" == "ultrajump" ] ; then
		serializationID=916
	elif [ "${serialization,,}" == "ultrajumpegg" ] ; then
		serializationID=917
	elif [ "${serialization,,}" == "unpoco" ] ; then
		serializationID=918
	elif [ "${serialization,,}" == "uppers(kodansha)" ] ; then
		serializationID=919
	elif [ "${serialization,,}" == "urasunday" ] ; then
		serializationID=920
	elif [ "${serialization,,}" == "usca" ] ; then
		serializationID=921
	elif [ "${serialization,,}" == "vanilla" ] ; then
		serializationID=922
	elif [ "${serialization,,}" == "vcomic" ] ; then
		serializationID=923
	elif [ "${serialization,,}" == "vitaman" ] ; then
		serializationID=924
	elif [ "${serialization,,}" == "@vitamin" ] ; then
		serializationID=925
	elif [ "${serialization,,}" == "viva☆talesofmagazine" ] ; then
		serializationID=926
	elif [ "${serialization,,}" == "v-jump" ] ; then
		serializationID=927
	elif [ "${serialization,,}" == "waai!" ] ; then
		serializationID=928
	elif [ "${serialization,,}" == "waai!mahalo" ] ; then
		serializationID=929
	elif [ "${serialization,,}" == "webcomicaction" ] ; then
		serializationID=930
	elif [ "${serialization,,}" == "webcomicbeat's" ] ; then
		serializationID=931
	elif [ "${serialization,,}" == "webcomiceden" ] ; then
		serializationID=932
	elif [ "${serialization,,}" == "webcomicgamma" ] ; then
		serializationID=933
	elif [ "${serialization,,}" == "webcomicgekkin" ] ; then
		serializationID=934
	elif [ "${serialization,,}" == "webcomicgum" ] ; then
		serializationID=935
	elif [ "${serialization,,}" == "webcomichigh!" ] ; then
		serializationID=936
	elif [ "${serialization,,}" == "webcomiczenyon" ] ; then
		serializationID=937
	elif [ "${serialization,,}" == "webikiparacomic" ] ; then
		serializationID=938
	elif [ "${serialization,,}" == "weblink" ] ; then
		serializationID=939
	elif [ "${serialization,,}" == "webmagazinef3" ] ; then
		serializationID=940
	elif [ "${serialization,,}" == "webmagazinewings" ] ; then
		serializationID=941
	elif [ "${serialization,,}" == "webnovel" ] ; then
		serializationID=942
	elif [ "${serialization,,}" == "webspica" ] ; then
		serializationID=943
	elif [ "${serialization,,}" == "weeklyascii" ] ; then
		serializationID=944
	elif [ "${serialization,,}" == "weeklymangatimes" ] ; then
		serializationID=945
	elif [ "${serialization,,}" == "weeklyplayboy" ] ; then
		serializationID=946
	elif [ "${serialization,,}" == "weeklyshonenchampion" ] ; then
		serializationID=947
	elif [ "${serialization,,}" == "weeklyshounenjump" ] ; then
		serializationID=948
	elif [ "${serialization,,}" == "weeklyyoungjump" ] ; then
		serializationID=949
	elif [ "${serialization,,}" == "wings" ] ; then
		serializationID=950
	elif [ "${serialization,,}" == "wink" ] ; then
		serializationID=951
	elif [ "${serialization,,}" == "wonderland" ] ; then
		serializationID=952
	elif [ "${serialization,,}" == "xmagazine" ] ; then
		serializationID=953
	elif [ "${serialization,,}" == "yawarakaspirits" ] ; then
		serializationID=954
	elif [ "${serialization,,}" == "yomban" ] ; then
		serializationID=955
	elif [ "${serialization,,}" == "yomiurishimbun" ] ; then
		serializationID=956
	elif [ "${serialization,,}" == "you" ] ; then
		serializationID=957
	elif [ "${serialization,,}" == "youngace" ] ; then
		serializationID=958
	elif [ "${serialization,,}" == "youngaceup" ] ; then
		serializationID=959
	elif [ "${serialization,,}" == "younganimal" ] ; then
		serializationID=960
	elif [ "${serialization,,}" == "younganimalarashi" ] ; then
		serializationID=961
	elif [ "${serialization,,}" == "younganimaldensi" ] ; then
		serializationID=962
	elif [ "${serialization,,}" == "younganimalisland" ] ; then
		serializationID=963
	elif [ "${serialization,,}" == "youngchamp" ] ; then
		serializationID=964
	elif [ "${serialization,,}" == "youngchampion" ] ; then
		serializationID=965
	elif [ "${serialization,,}" == "youngchampionmagazine" ] ; then
		serializationID=966
	elif [ "${serialization,,}" == "youngchampionretsu" ] ; then
		serializationID=967
	elif [ "${serialization,,}" == "youngcomic" ] ; then
		serializationID=968
	elif [ "${serialization,,}" == "younggangan" ] ; then
		serializationID=969
	elif [ "${serialization,,}" == "younghip" ] ; then
		serializationID=970
	elif [ "${serialization,,}" == "youngjump" ] ; then
		serializationID=971
	elif [ "${serialization,,}" == "youngjump(monthly)" ] ; then
		serializationID=972
	elif [ "${serialization,,}" == "youngking" ] ; then
		serializationID=973
	elif [ "${serialization,,}" == "youngking(monthly)" ] ; then
		serializationID=974
	elif [ "${serialization,,}" == "youngkingours" ] ; then
		serializationID=975
	elif [ "${serialization,,}" == "youngkingours+" ] ; then
		serializationID=976
	elif [ "${serialization,,}" == "youngkingoursgh" ] ; then
		serializationID=977
	elif [ "${serialization,,}" == "youngmagazine" ] ; then
		serializationID=978
	elif [ "${serialization,,}" == "youngmagazinekaizokuban(web)" ] ; then
		serializationID=979
	elif [ "${serialization,,}" == "youngmagazine(monthly)" ] ; then
		serializationID=980
	elif [ "${serialization,,}" == "youngmagazinethe3rd" ] ; then
		serializationID=981
	elif [ "${serialization,,}" == "youngmagazineuppers" ] ; then
		serializationID=982
	elif [ "${serialization,,}" == "youngmagazine(weekly)" ] ; then
		serializationID=983
	elif [ "${serialization,,}" == "youngmanga" ] ; then
		serializationID=984
	elif [ "${serialization,,}" == "youngsunday(weekly)" ] ; then
		serializationID=985
	elif [ "${serialization,,}" == "youngyou" ] ; then
		serializationID=986
	elif [ "${serialization,,}" == "yurihime" ] ; then
		serializationID=987
	elif [ "${serialization,,}" == "yurihimecomics" ] ; then
		serializationID=988
	elif [ "${serialization,,}" == "yuri☆koi" ] ; then
		serializationID=989
	elif [ "${serialization,,}" == "yurishimai" ] ; then
		serializationID=990
	elif [ "${serialization,,}" == "zero" ] ; then
		serializationID=991
	elif [ "${serialization,,}" == "zerocomics" ] ; then
		serializationID=992
	elif [ "${serialization,,}" == "zero-sumonline" ] ; then
		serializationID=993
	elif [ "${serialization,,}" == "zero-sumward" ] ; then
		serializationID=994
	elif [ "${serialization,,}" == "zettairenaisweet" ] ; then
		serializationID=995
	elif [ "${serialization,,}" == "zipper" ] ; then
		serializationID=996
	elif [ "${serialization,,}" == "zoukanflowers" ] ; then
		serializationID=997
	elif [ "${serialization,,}" == "zoukanyounggangan" ] ; then
		serializationID=998
	elif [[ "${serialization,,}" == *"null"* ]] ; then
		serializationID=""
	else
		serializationID=""
		echo "${en_jp} = ${serialization,,}" >> serializationBug
	fi
	
	if [ "${subtype,,}" = "novel" ];then
		echo "INSERT INTO light_novel (id,artwork_id) VALUES (\"$mangaID\",\"$artworkID\");" >> $lightNovelSQL
	else
		echo "INSERT INTO manga (id,manga_type_id,artwork_id,serialization_id) VALUES (\"$mangaID\",\"$subtypeID\",\"$artworkID\",\"$serializationID\");" >> $mangaSQL
	fi
	
	#dossier d'image :
	local name_slug=$en_jp
	name_slug="${name_slug//\./}"
	name_slug="${name_slug//\//}"
	local mangaImage="${image}/Mangas/${name_slug}/${name_slug}-original.jpg"
	if [[ "${name_slug}" == *"null"* ]];then
		name_slug=""
		mangaImage=""
    fi
	echo "INSERT INTO artwork (id,artwork_name,artwork_vo_name,release_date,age_rating,statusId,synopsis,poster_image) VALUES (\"$artworkID\",\"$en_jp\",\"$ja_jp\",$startDate,\"$ageRating\",\"$statusID\",\"$synopsis\",\"$mangaImage\");" >> $artworkSQL
}

chapterSQL(){
	local file="${1}"
	local chapterID="${2}"
	#volumeNumber nombre de volume
	local volumeNumber=$(./parseJson.sh "${file}" "volumeNumber")
	if [[ "${volumeNumber}" == *"null"* ]];then
		volumeNumber=""
	else
		volumeNumber="${volumeNumber//[!0-9]/}"
	fi
	volumeNumber="${volumeNumber// ,}"
	#number est le nombre de chapitre
	local number=$(./parseJson.sh "${file}" "number")
	if [[ "${number}" == *"null"* ]];then
		number=""
	else
		number="${number//[!0-9]/}"
	fi
	number="${number// ,}"
	#en_jp nom du chapitre
	local en_jp=$(./parseJson.sh "${file}" "en_jp")
	if [[ "${en_jp}" == *"null"* ]];then
		en_jp=""
	fi
	en_jp="${en_jp// ,}"
	#synopsis
	local synopsis="" #$(./parseJson.sh "${file}" "synopsis")
	if [[ "${synopsis}" == *"null"* ]];then
		synopsis=""
	fi
	#published date de publication
	local published=$(./parseJson.sh "${file}" "published")
	if [[ "${published}" == *"null"* ]];then
		published="NULL"
	else
		published="\"$published\""
	fi
	published="${published// ,}"
	#length nombre de page du chapitre
	local length=$(./parseJson.sh "${file}" "length")
	if [[ "${length}" == *"null"* ]];then
		length=""
	fi
	length="${length// ,}"
	echo "INSERT INTO chapter (id,chapter_name,chapter_number,chapter_volume_number,chapter_release,chapter_synopsis,chapter_page_nb) VALUES (\"$chapterID\",\"$en_jp\",\"$number\",\"$volumeNumber\",$published,\"$synopsis\",\"$length\");" >> $chapterSQL
}

animeSQL(){
	local file="${1}"
	local animeID="${2}"
	local artworkID="${3}"
	local synopsis="" #$(./parseJson.sh "${file}" "synopsis")
    local en_jp=$(./parseJson.sh "${file}" "en_jp")
	if [[ "${en_jp}" == *"null"* ]];then
		en_jp=""
	fi
	en_jp="${en_jp// ,}"
    local ja_jp=$(./parseJson.sh "${file}" "ja_jp")
	if [[ "${ja_jp}" == *"null"* ]];then
		ja_jp=""
	fi
	ja_jp="${ja_jp// ,}"
    local ageRating=$(./parseJson.sh "${file}" "ageRating") #G General Audiences;PG Parental Guidance Suggested;R Restricted;R18 Explicit
	if [[ "${ageRating}" == *"null"* ]];then
		ageRating=""
	fi
	ageRating="${ageRating// ,}"
	local subtypeID=0
	local subtype=$(./parseJson.sh "${file}" "subtype")
	subtype="${subtype// ,}"
	if [ "${subtype,,}" = "ona" ];then
		subtypeID=1
	elif [ "${subtype,,}" = "ova" ];then
		subtypeID=2
	elif [ "${subtype,,}" = "tv" ];then
		subtypeID=3
	elif [ "${subtype,,}" = "movie" ];then
		subtypeID=4
	elif [ "${subtype,,}" = "music" ];then
		subtypeID=5
	elif [ "${subtype,,}" = "special" ];then
		subtypeID=6
	fi
	
	#episodeLength
	local episodeLength=$(./parseJson.sh "${file}" "episodeLength")
	if [[ "${episodeLength}" == *"null"* ]];then
		episodeLength=""
	else
		episodeLength="${episodeLength//[!0-9]/}"
	fi
	episodeLength="${episodeLength// ,}"
	#youtubeVideoId
	local youtubeVideoId=$(./parseJson.sh "${file}" "youtubeVideoId")
	if [[ "${youtubeVideoId}" == *"null"* ]];then
		youtubeVideoId=""
	fi
	youtubeVideoId="${youtubeVideoId// ,}"
	local statusID=0
	local status=$(./parseJson.sh "${file}" "status")
	status="${status// ,}"
	if [ "${status,,}" = "current" ];then
		statusID=1
	elif [ "${status,,}" = "finished" ];then
		statusID=2
	elif [ "${status,,}" = "tba" ];then
		statusID=3
	elif [ "${status,,}" = "unreleased" ];then
		statusID=4
	elif [ "${status,,}" = "upcoming" ];then
		statusID=5
	fi
	
	#dossier d'image :
	local name_slug=$en_jp
	name_slug="${name_slug//\./}"
	name_slug="${name_slug//\//}" 
	name_slug="${name_slug// ,//}" 
	local animeImage="${image}/Animes/${name_slug}/${name_slug}-original.jpg"
	if [[ "${name_slug}" == *"null"* ]];then
		name_slug=""
		animeImage=""
	fi
	
	#correspond à releasedate
	local startDate=$(./parseJson.sh "${file}" "startDate")
	if [[ "${startDate}" == *"null"* ]];then
		startDate="NULL"
	else
		startDate="\"$startDate\""
	fi
	startDate="${startDate// ,}"
	local endDate=$(./parseJson.sh "${file}" "endDate")
	if [[ "${endDate}" == *"null"* ]];then
			endDate="NULL"
	else
		endDate="\"$startDate\""
	fi
	endDate="${endDate// ,}"
	echo "INSERT INTO artwork (id,artwork_name,artwork_vo_name,release_date,age_rating,statusId,synopsis,poster_image) VALUES (\"$artworkID\",\"$en_jp\",\"$ja_jp\",$startDate,\"$ageRating\",\"$statusID\",\"$synopsis\",\"$animeImage\");" >> $artworkSQL
	echo "INSERT INTO anime (id,anime_type_id,artwork_id,episode_length,youtube_video) VALUES (\"$animeID\",\"$subtypeID\",\"$artworkID\",\"$episodeLength\",\"$youtubeVideoId\");" >> $animeSQL
}

episodeSQL(){
	local file="${1}"
	local episodeID="${2}"
	local en_jp=$(./parseJson.sh "${file}" "en_jp")
	if [[ "${en_jp}" == *"null"* ]];then
		en_jp=""
	fi
	en_jp="${en_jp// ,}"
	local seasonNumber=$(./parseJson.sh "${file}" "seasonNumber")
	if [[ "${seasonNumber}" == *"null"* ]];then
		seasonNumber=""
	else
		seasonNumber="${seasonNumber//[!0-9]/}"
	fi
	seasonNumber="${seasonNumber// ,}"
	local number=$(./parseJson.sh "${file}" "number")
	if [[ "${number}" == *"null"* ]];then
		number=""
	else
		number="${number//[!0-9]/}"
	fi
	number="${number// ,}"
	local synopsis="" #$(./parseJson.sh "${file}" "synopsis")
	local airdate=$(./parseJson.sh "${file}" "airdate")
	if [[ "${airdate}" == *"null"* ]];then
		airdate="NULL"
	else
		airdate="\"$airdate\""
	fi
	airdate="${airdate// ,}"
	local length=$(./parseJson.sh "${file}" "length")
	if [[ "${length}" == *"null"* ]];then
		length=""
	else
		length="${length//[!0-9]/}"
	fi
	length="${length// ,}"
	echo "INSERT INTO episode (id,episode_name,episode_season,episode_number,episode_synopsis,episode_release,episode_duration) VALUES (\"$episodeID\",\"$en_jp\",\"$seasonNumber\",\"$number\",\"$synopsis\",$airdate,\"$length\");" >> $episodeSQL
}

characterSQL(){
	local file="${1}"
	characterID="${2}"
	#name nom du personnage
	local name=$(./parseJson.sh "${file}" "name")
	
	#description description du personnage
	#description=$(./parseJson.sh "${file}" "description")
	
	#dossier d'image :
	local name_slug=$(./parseJson.sh "${file}" "slug")
	name_slug="${name_slug//\./}"
	name_slug="${name_slug//\//}"
	name_slug="${name_slug// ,}"
	
	if [ "$name_slug" = 'slug":null,' ];then
		name_slug=$(./parseJson.sh "${file}" "name")
	fi
	local characterImage="${image}/Characters/${name_slug}/${name_slug}-original.jpg"
	echo "INSERT INTO characters (id,characterName,character_image) VALUES (\"$characterID\",\"$name\",\"$characterImage\");" >> $characterSQL
}

peopleSQL(){
	local file="${1}"
	peopleID="${2}"
	#dossier d'image et nom
	local name=$(./parseJson.sh "${file}" "name")
	name="${name//\./}"
	name="${name//\//}"
	name="${name// ,}" 
	local artistImage="${image}/Peoples/${name}/${name}-original.jpg"	
	echo "INSERT INTO artist (id,artist_name,artist_image) VALUES (\"$peopleID\",\"$name\",\"$artistImage\");" >> $peopleSQL
}

peopleSQLByStartEnd(){
	local cptpeople=$lastPeople
	for ((i="$1";i<="$2";i++ ));do
		#gestion de la pause
		pause
		if [ -f "${peopleDIR}/${i}" ];then
			((cptpeople++))
			peopleSQL "${peopleDIR}/${i}" "$cptpeople"
			idToTXT "$cptpeople" "$i" "$peopleTXT"
			echo "${cptpeople}" >| $lastPeopleTXT
		fi
	done	
}

characterSQLByStartEnd(){
	local cptcharacter=$lastCharacter
	for ((i="$1";i<="$2";i++ ));do
		#gestion de la pause
		pause
		if [ -f "${charactersDIR}/$i" ];then
			((cptcharacter++))
			characterSQL "${charactersDIR}/$i" "$cptcharacter"
			idToTXT "$cptcharacter" "$i" "$characterTXT"
			echo "${cptcharacter}" >| $lastCharacterTXT
		fi
	done	
}

mangaSQLALL(){
	local cptmanga=$lastManga
	local cptlightNovel=$lastLightNovel
	local cptchapter=$lastChapter
	local artwork=$lastArtwork	
	for ((i="$1";i<="$2";i++ ));do
		#gestion de la pause
		pause
		if [ -d "${mangaDIR}/${i}" ]; then
			echo "${mangaDIR}/${i}"
			((artwork++))
			if [ "${subtype,,}" = "novel" ];then
				((cptlightNovel++))
				mangaSQL "${mangaDIR}/${i}/${i}.json" "$cptlightNovel" "$artwork"			
				idToTXT "$cptlightNovel" "$i" "$lightNovelTXT"
				idToTXT "$artwork" "$cptlightNovel" "$artworkLightNovelTXT"
			else			
				((cptmanga++))
				mangaSQL "${mangaDIR}/${i}/${i}.json" "$cptmanga" "$artwork"			
				idToTXT "$cptmanga" "$i" "$mangaTXT"
				idToTXT "$artwork" "$cptmanga" "$artworkMangaTXT"
			fi			
			# Will not run if no directories are available
			local subtype=$(./parseJson.sh "${mangaDIR}/${i}/${i}.json" "subtype")
			subtype="${subtype// ,//}"
			#chapitre du manga, light novel
			for chapter in ${mangaDIR}/${i}/*;do
				if [ -n "${chapter%%*.json}" ] && [ -n "${chapter%%*.genre}" ] ;then
					if [ -f "${chapter}" ]; then
						((cptchapter++))
						chapterNum="${chapter##${mangaDIR}/${i}/}"
						chapterSQL "$chapter" "$cptchapter"
						idToTXT "$cptchapter" "$chapterNum" "$chapterTXT"
						if [ "${subtype,,}" = "novel" ];then
							lightnovelChapterSQL "$cptlightNovel" "$cptchapter"
						else
							mangaChapterSQL "$cptmanga" "$cptchapter"
						fi
					fi
				fi
			done		
			
			#les genres du manga, light novel
			if [ -f "${mangaDIR}/${i}/${i}.genre" ];then
				genres=$(getGenre "${$mangaDIR}/${i}/${i}.genre")
				artworkGenreSQL "$artwork" "$genres"
			fi			
					
		elif [ -f "${mangaDIR}/${i}.json" ];then
			((artwork++))
			local subtype=$(./parseJson.sh "${$mangaDIR}/${i}.json" "subtype")
			if [ "${subtype,,}" = "novel" ];then
				((cptlightNovel++))
				mangaSQL "${mangaDIR}/${i}.json" "$cptlightNovel" "$artwork"
				idToTXT "$cptlightNovel" "$i" "$lightNovelTXT"
				idToTXT "$artwork" "$cptlightNovel" "$artworkLightNovelTXT"
			else
				((cptmanga++))
				mangaSQL "${mangaDIR}/${i}.json" "$cptmanga" "$artwork"
				idToTXT "$cptmanga" "$i" "$mangaTXT"
				idToTXT "$artwork" "$cptmanga" "$artworkMangaTXT"
			fi		
			
			#les genres du manga
			if [ -f "${mangaDIR}/${i}.genre" ];then				
				genres=$(getGenre "${$mangaDIR}/${i}.genre")
				artworkGenreSQL "$artwork" "$genres"
			fi
			
		fi
		echo "${cptmanga}" >| $lastMangaTXT
		echo "${cptlightNovel}" >| $lastLightNovelTXT
		echo "${artwork}" >| $lastArtworkTXT
		echo "${cptchapter}" >| $lastChapterTXT
	done
}

animeSQLALL(){
	local cptanime=$lastAnime
	local cptepisode=$lastEpisode
	local artwork=$lastArtwork
	for ((i="$1";i<="$2";i++ ));do
		#gestion de la pause
		pause
		if [ -d "${animeDIR}/${i}" ]; then
			((cptanime++))
			((artwork++))
			# Will not run if no directories are available
			animeSQL "${animeDIR}/${i}/${i}.json" "$cptanime" "$artwork"
			idToTXT "$cptanime" "$i" "$animeTXT"
			idToTXT "$artwork" "$cptanime" "$artworkAnimeTXT"
			#episode de l'anime
			for episode in ${animeDIR}/${i}/*;do
				if [ -n "${episode%%*.json}" ] && [ -n "${episode%%*.genre}" ] ;then
					if [ -f "${episode}" ]; then
						((cptepisode++))
						episodeNum="${episode##${episodeDIR}/${i}/}"
						episodeSQL "${episode}" "$cptepisode"
						animeEpisodeSQL "$cptanime" "$cptepisode"
						idToTXT "$cptepisode" "$episode" "$episodeTXT"
					fi
				fi
			done
			#les genres de l'anime
			if [ -f "${animeDIR}/${i}/${i}.genre" ];then
				genres=$(getGenre "${animeDIR}/${i}/${i}.genre")
				artworkGenreSQL "$artwork" "$genres"
			fi		
		elif [ -f "${animeDIR}/${i}.json" ];then
			((cptanime++))
			((artwork++))
			animeSQL "${animeDIR}/${i}.json" "$cptanime" "$artwork"
			idToTXT "$cptanime" "$i" "$animeTXT"
			idToTXT "$artwork" "$cptanime" "$artworkAnimeTXT"
			#les genres du manga
			if [ -f "${animeDIR}/${i}.genre" ];then
				genres=$(getGenre "${animeDIR}/${i}.genre")
				artworkGenreSQL "$artwork" "$genres"
			fi
		fi
		echo "${cptanime}" >| $lastAnimeTXT
		echo "${cptepisode}" >| $lastEpisodeTXT
		echo "${artwork}" >| $lastArtworkTXT
	done
}

usage(){
	echo -e "Usage:  $0 <TYPE> [IDStart] [IDEnd] \n\
	$0 -h : For help\n\
	$0 --help : For help\n\
	$0 -usage : For help\n\
	<TYPE> = -m = manga, -a = anime, -c = character, -p = people\n\
	"
	exit 1;
}

#MainStart--------------------------------------------------------------
initLastTXT
if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-usage" ]; then
	usage
elif [ "${1}" = "-c" ];then
	characterSQLByStartEnd "${2}" "${3}"
elif [ "${1}" = "-a" ];then
	animeSQLALL "${2}" "${3}"
elif [ "${1}" = "-m" ];then
	mangaSQLALL "${2}" "${3}"
elif [ "${1}" = "-p" ];then
	peopleSQLByStartEnd "${2}" "${3}"
else
	usage
fi
#MainEND----------------------------------------------------------------
