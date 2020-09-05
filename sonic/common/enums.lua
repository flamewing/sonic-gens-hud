--------------------------------------------------------------------------------
--	This file is part of the Lua HUD for TASing Sega Genesis Sonic games.
--
--	This program is free software: you can redistribute it and/or modify
--	it under the terms of the GNU Lesser General Public License as
--	published by the Free Software Foundation, either version 3 of the
--	License, or (at your option) any later version.
--
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--	GNU General Public License for more details.
--
--	You should have received a copy of the GNU Lesser General Public License
--	along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Handy constants.
--	Written by: Marzo Junior
--	Based on game disassemblies and Gens' RAM search.
--------------------------------------------------------------------------------

charids = {
	sonic_tails = 0,
	sonic       = 1,
	tails       = 2,
	knuckles    = 3,
	amy_tails   = 4,
	amy_rose    = 5,
	charmy      = 6,
	bunnie      = 7,
}

shieldids = {
	no_shield        = -1,
	normal_shield    =  0,
	flame_shield     =  4,
	lightning_shield =  5,
	bubble_shield    =  6
}

