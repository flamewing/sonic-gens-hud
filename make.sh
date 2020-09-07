#!/bin/bash

if [[ -v MSYSTEM ]]; then
	BASE="c:/Users/marzo/Documents/gens/ROMS"
else
	BASE="$HOME/.wine/drive_c/games/gens/ROMS"
fi
ROMDIR="$BASE/GenRen/"
HACKDIR="$BASE/"
CDDIR="$BASE/"
export ROMDIR HACKDIR CDDIR

function check_run()
{
	if [[ (! -f "sonic/common/$2") || ("sonic/common/$2" -ot "$1") ]]; then
		echo "$3"
		./$1
	fi
}

find . -iname '*~' -delete
check_run find_huds.lua hud-codes.lua "Finding HUD code points..."
check_run find_bosses.lua boss-tables.lua "Finding boss code points..."
echo "Generating luaimg files..."
./imagedump.sh

BUILD="builds/sonic-hud-$(date +"%F").7z"
mkdir -p builds
rm -f "$BUILD"
echo "Creating archive '$BUILD'..."
unix2dos *.txt *.md
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$BUILD" *.txt *.md sonic-hud.lua headers/*.lua img/*.luaimg sonic/*.lua sonic/common/*.lua sonic/common/game-data/*.lua &> /dev/null
dos2unix *.txt *.md
echo "All done."

