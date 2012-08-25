#!/bin/bash

###############################################################################
##	This file is part of the Lua HUD for TASing Sega Genesis Sonic games.
##	
##	This program is free software: you can redistribute it and/or modify
##	it under the terms of the GNU Lesser General Public License as 
##	published by the Free Software Foundation, either version 3 of the 
##	License, or (at your option) any later version.
##	
##	This program is distributed in the hope that it will be useful,
##	but WITHOUT ANY WARRANTY; without even the implied warranty of
##	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##	GNU General Public License for more details.
##	
##	You should have received a copy of the GNU Lesser General Public License
##	along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################

output=./sonic/common/hud-images.lua
rm -f $output
if [[ -d "img" ]]; then
	rm -f img/*.luaimg
else
	mkdir img
fi
touch $output

echo "-------------------------------------------------------------------------------
--	DO NOT EDIT THIS FILE, IT IS AUTOGENERATED!
--	All images are PNGs predumped to GD format.
-------------------------------------------------------------------------------

local function open_image(fname)
	local prefix = \"./lua/img\"
	local file = io.open(string.format(\"%s/%s\", prefix, fname), \"rb\") or
		error(string.format(\"Error: Image '%s' could not be found.\", string.format(\"%s/%s\", prefix, fname)), 0)
	local retvar = file:read(\"*a\")
	file:close()
	return retvar
end

ui_icons = {" >> $output

ls ./pngs/*.png | sort | while read f; do
	base="$(basename $f .png)"
	name=${base#ui-icon-}
	dest="./img/$base.luaimg"
	pngtogd $f $dest
	printf "\t%-40s = open_image(\"%s\"),\n" ${name//-/_} "$base.luaimg" >> $output
done
echo "}
" >> $output

