#!/bin/bash

ROMDIR="$HOME/.wine/drive_c/games/gens/ROMS/GenRen/"
HACKDIR="$HOME/.wine/drive_c/games/gens/ROMS/"
CDDIR="$HOME/.wine/drive_c/games/gens/ROMS/"
export ROMDIR HACKDIR CDDIR

function check_run()
{
	if [[ (! -f "sonic/common/$2") || ("sonic/common/$2" -nt "$1") ]]; then
		echo "$3"
		./$1
	fi 
}

check_run find_huds.lua hud-codes.lua "Finding HUD code points..."
check_run find_bosses.lua boss-tables.lua "Finding boss code points..."
echo "Generating luaimg files and header file..."
./imagedump.sh

echo "Creating archive sonic-hud.7z..."
rm -f sonic-hud.7z
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on sonic-hud.7z *.txt sonic-hud.lua headers/*.lua img/*.luaimg sonic/*.lua sonic/common/*.lua &> /dev/null
echo "All done."

