-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--	Portrait tables.
--	Written by: Marzo Junior
--	Based on game disassemblies and Gens' RAM search.
-------------------------------------------------------------------------------

require("headers/lua-oo")
require("sonic/common/rom-check")
require("sonic/common/hud-images")

-------------------------------------------------------------------------------
--	Set of portraits for a character.
-------------------------------------------------------------------------------
Portrait_set =  {
	face     = nil,
	spindash = nil,
	wounded  = nil
}

function Portrait_set.Create(face, spin, wound)
	local self = ShallowCopy(Portrait_set)
	self.face     = face
	self.spindash = spin
	self.wounded  = wound
	return self
end

-------------------------------------------------------------------------------
--	Set of all portraits for a character, accounting for transformations.
-------------------------------------------------------------------------------
Char_portraits = {
	normal = nil,
	super  = nil,
	hyper  = nil
}

function Char_portraits.Create(face1, spin1, wound1, face2, spin2, wound2, face3, spin3, wound3)
	local self = ShallowCopy(Char_portraits)
	if face2 == nil then
		face2 = face1
	end
	if face3 == nil then
		face3 = face2
	end
	if spin2 == nil then
		spin2 = spin1
	end
	if spin3 == nil then
		spin3 = spin2
	end
	if wound2 == nil then
		wound2 = wound1
	end
	if wound3 == nil then
		wound3 = wound2
	end
	self.normal = Portrait_set.Create(face1, spin1, wound1)
	self.super  = Portrait_set.Create(face2, spin2, wound2)
	self.hyper  = Portrait_set.Create(face3, spin3, wound3)
	return self
end

-------------------------------------------------------------------------------
--	All set of portraits for all characters.
-------------------------------------------------------------------------------
portraits = {
	sonic    = Char_portraits.Create(ui_icons.sonic_normal,
	                                 ui_icons.sonic_spindash,
	                                 ui_icons.sonic_wounded,
	                                 ui_icons.sonic_normal,
	                                 ui_icons.sonic_super_spindash,
	                                 ui_icons.sonic_super_wounded),
	tails    = Char_portraits.Create(ui_icons.tails_normal,
	                                 ui_icons.tails_spindash,
	                                 ui_icons.tails_wounded),
	knuckles = Char_portraits.Create(ui_icons.knuckles_normal,
	                                 ui_icons.knuckles_spindash,
	                                 ui_icons.knuckles_wounded),
	amy_rose = Char_portraits.Create(ui_icons.amy_normal,
	                                 ui_icons.amy_spindash,
	                                 ui_icons.amy_wounded),
	cream    = Char_portraits.Create(ui_icons.cream_normal,
	                                 ui_icons.cream_spindash,
	                                 ui_icons.cream_wounded),
	charmy   = Char_portraits.Create(ui_icons.charmy_normal,
	                                 ui_icons.charmy_spindash,
	                                 ui_icons.charmy_wounded),

	sel_char  = nil,
	curr_set  = nil
}

if rom:is_sonic3() or rom:is_sonick() then
	portraits.sonic.super.face    = {[ 36]=ui_icons.sonic_super_36,    [ 42]=ui_icons.sonic_super_42,    [ 48]=ui_icons.sonic_super_48}
	portraits.sonic.hyper.face    = {[ 00]=ui_icons.sonic_hyper_00,    [ 06]=ui_icons.sonic_hyper_06,    [ 12]=ui_icons.sonic_hyper_12,
	                                 [ 18]=ui_icons.sonic_hyper_18,    [ 24]=ui_icons.sonic_hyper_24,    [ 30]=ui_icons.sonic_hyper_30,
	                                 [ 36]=ui_icons.sonic_hyper_36,    [ 42]=ui_icons.sonic_hyper_42,    [ 48]=ui_icons.sonic_hyper_48,
	                                 [ 54]=ui_icons.sonic_hyper_54,    [ 60]=ui_icons.sonic_hyper_60,    [ 66]=ui_icons.sonic_hyper_66}
	portraits.tails.hyper.face    = {[ 00]=ui_icons.tails_super_00,    [ 06]=ui_icons.tails_super_06,    [ 12]=ui_icons.tails_super_12,
	                                 [ 18]=ui_icons.tails_super_18,    [ 24]=ui_icons.tails_super_24,    [ 30]=ui_icons.tails_super_30}
	portraits.tails.super.face = portraits.tails.hyper.face	--	There is no 'Turbo Tails', but lets be safe here
	portraits.knuckles.hyper.face = {[ 00]=ui_icons.knuckles_hyper_00, [ 06]=ui_icons.knuckles_hyper_06, [ 12]=ui_icons.knuckles_hyper_12,
	                                 [ 18]=ui_icons.knuckles_hyper_18, [ 24]=ui_icons.knuckles_hyper_24, [ 30]=ui_icons.knuckles_hyper_30,
	                                 [ 36]=ui_icons.knuckles_hyper_36, [ 42]=ui_icons.knuckles_hyper_42, [ 48]=ui_icons.knuckles_hyper_48,
	                                 [ 54]=ui_icons.knuckles_hyper_54}
	portraits.knuckles.super.face = portraits.knuckles.hyper.face	--	Same portrait set
	--	Just in case:
	portraits.amy_rose.super.face = {[ 48]=ui_icons.sonic_super_30,    [ 56]=ui_icons.sonic_super_38,    [ 64]=ui_icons.sonic_super_40,
	                                 [ 72]=ui_icons.sonic_super_48,    [ 80]=ui_icons.sonic_super_50,    [ 88]=ui_icons.sonic_super_58,
	                                 [ 96]=ui_icons.sonic_super_60,    [104]=ui_icons.sonic_super_68,    [112]=ui_icons.sonic_super_70}
	portraits.amy_rose.hyper.face = portraits.amy_rose.super.face
else
	--	Defining for all others just in case, using the same set as for S2.
	portraits.sonic.super.face    = {[ 48]=ui_icons.sonic_super_36,    [ 56]=ui_icons.sonic_super_42,    [ 64]=ui_icons.sonic_super_48,
	                                 [ 72]=ui_icons.sonic_super_48,    [ 80]=ui_icons.sonic_super_42,    [ 88]=ui_icons.sonic_super_42,
	                                 [ 96]=ui_icons.sonic_super_48,    [104]=ui_icons.sonic_super_42,    [112]=ui_icons.sonic_super_36}
	portraits.sonic.hyper.face    = portraits.sonic.super.face
	portraits.tails.hyper.face    = {[ 48]=ui_icons.tails_super_00,    [ 56]=ui_icons.tails_super_06,    [ 64]=ui_icons.tails_super_12,
	                                 [ 72]=ui_icons.tails_super_18,    [ 80]=ui_icons.tails_super_24,    [ 88]=ui_icons.tails_super_00,
	                                 [ 96]=ui_icons.tails_super_00,    [104]=ui_icons.tails_super_00,    [112]=ui_icons.tails_super_00}
	portraits.tails.super.face    = portraits.tails.hyper.face	--	There is no 'Turbo Tails', but lets be safe here
	portraits.knuckles.hyper.face = {[ 00]=ui_icons.knuckles_hyper_00, [ 06]=ui_icons.knuckles_hyper_06, [ 12]=ui_icons.knuckles_hyper_12,
	                                 [ 18]=ui_icons.knuckles_hyper_18, [ 24]=ui_icons.knuckles_hyper_24, [ 30]=ui_icons.knuckles_hyper_30,
	                                 [ 36]=ui_icons.knuckles_hyper_36, [ 42]=ui_icons.knuckles_hyper_42, [ 48]=ui_icons.knuckles_hyper_48,
	                                 [ 54]=ui_icons.knuckles_hyper_54}
	portraits.knuckles.super.face = portraits.knuckles.hyper.face	--	Same portrait set
	portraits.amy_rose.super.face = {[ 48]=ui_icons.amy_super_30,      [ 56]=ui_icons.amy_super_38,      [ 64]=ui_icons.amy_super_40,
	                                 [ 72]=ui_icons.amy_super_48,      [ 80]=ui_icons.amy_super_50,      [ 88]=ui_icons.amy_super_58,
	                                 [ 96]=ui_icons.amy_super_60,      [104]=ui_icons.amy_super_68,      [112]=ui_icons.amy_super_70}
	portraits.amy_rose.hyper.face = portraits.amy_rose.super.face	--	Same portrait set
end

