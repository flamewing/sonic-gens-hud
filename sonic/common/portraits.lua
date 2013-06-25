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

require("sonic/common/rom-check")
require("headers/lua-oo")

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
	sonic    = Char_portraits.Create("sonic-normal",
	                                 "sonic-spindash",
	                                 "sonic-wounded",
	                                 "sonic-normal",
	                                 "sonic-super-spindash",
	                                 "sonic-super-wounded"),
	tails    = Char_portraits.Create("tails-normal",
	                                 "tails-spindash",
	                                 "tails-wounded"),
	knuckles = Char_portraits.Create("knuckles-normal",
	                                 "knuckles-spindash",
	                                 "knuckles-wounded"),
	amy_rose = Char_portraits.Create("amy-normal",
	                                 "amy-spindash",
	                                 "amy-wounded"),
	cream    = Char_portraits.Create("cream-normal",
	                                 "cream-spindash",
	                                 "cream-wounded"),
	charmy   = Char_portraits.Create("charmy-normal",
	                                 "charmy-spindash",
	                                 "charmy-wounded"),

	sel_char  = nil,
	curr_set  = nil
}

if rom:is_sonic3() or rom:is_sonick() then
	portraits.sonic.super.face    = {[ 36]="sonic-super-36",    [ 42]="sonic-super-42",    [ 48]="sonic-super-48"}
	portraits.sonic.hyper.face    = {[ 00]="sonic-hyper-00",    [ 06]="sonic-hyper-06",    [ 12]="sonic-hyper-12",
	                                 [ 18]="sonic-hyper-18",    [ 24]="sonic-hyper-24",    [ 30]="sonic-hyper-30",
	                                 [ 36]="sonic-hyper-36",    [ 42]="sonic-hyper-42",    [ 48]="sonic-hyper-48",
	                                 [ 54]="sonic-hyper-54",    [ 60]="sonic-hyper-60",    [ 66]="sonic-hyper-66"}
	portraits.tails.hyper.face    = {[ 00]="tails-super-00",    [ 06]="tails-super-06",    [ 12]="tails-super-12",
	                                 [ 18]="tails-super-18",    [ 24]="tails-super-24",    [ 30]="tails-super-30"}
	portraits.tails.super.face = portraits.tails.hyper.face	--	There is no 'Turbo Tails', but lets be safe here
	portraits.knuckles.hyper.face = {[ 00]="knuckles-hyper-00", [ 06]="knuckles-hyper-06", [ 12]="knuckles-hyper-12",
	                                 [ 18]="knuckles-hyper-18", [ 24]="knuckles-hyper-24", [ 30]="knuckles-hyper-30",
	                                 [ 36]="knuckles-hyper-36", [ 42]="knuckles-hyper-42", [ 48]="knuckles-hyper-48",
	                                 [ 54]="knuckles-hyper-54"}
	portraits.knuckles.super.face = portraits.knuckles.hyper.face	--	Same portrait set
	--	Just in case:
	portraits.amy_rose.super.face = {[ 00]="amy-super-30",      [ 06]="amy-super-70",      [ 12]="amy-super-30",
	                                 [ 18]="amy-super-38",      [ 24]="amy-super-40",      [ 30]="amy-super-48",
	                                 [ 36]="amy-super-48",      [ 42]="amy-super-48",      [ 48]="amy-super-48",
	                                 [ 54]="amy-super-48",      [ 60]="amy-super-40",      [ 66]="amy-super-38"}
	portraits.amy_rose.hyper.face = portraits.amy_rose.super.face
else
	--	Defining for all others just in case, using the same set as for S2.
	portraits.sonic.super.face    = {[ 48]="sonic-super-36",    [ 56]="sonic-super-42",    [ 64]="sonic-super-48",
	                                 [ 72]="sonic-super-48",    [ 80]="sonic-super-42",    [ 88]="sonic-super-42",
	                                 [ 96]="sonic-super-48",    [104]="sonic-super-42",    [112]="sonic-super-36"}
	portraits.sonic.hyper.face    = portraits.sonic.super.face
	portraits.tails.hyper.face    = {[ 48]="tails-super-00",    [ 56]="tails-super-06",    [ 64]="tails-super-12",
	                                 [ 72]="tails-super-18",    [ 80]="tails-super-24",    [ 88]="tails-super-00",
	                                 [ 96]="tails-super-00",    [104]="tails-super-00",    [112]="tails-super-00"}
	portraits.tails.super.face    = portraits.tails.hyper.face	--	There is no 'Turbo Tails', but lets be safe here
	portraits.knuckles.hyper.face = {[ 00]="knuckles-hyper-00", [ 06]="knuckles-hyper-06", [ 12]="knuckles-hyper-12",
	                                 [ 18]="knuckles-hyper-18", [ 24]="knuckles-hyper-24", [ 30]="knuckles-hyper-30",
	                                 [ 36]="knuckles-hyper-36", [ 42]="knuckles-hyper-42", [ 48]="knuckles-hyper-48",
	                                 [ 54]="knuckles-hyper-54"}
	portraits.knuckles.super.face = portraits.knuckles.hyper.face	--	Same portrait set
	portraits.amy_rose.super.face = {[ 48]="amy-super-30",      [ 56]="amy-super-38",      [ 64]="amy-super-40",
	                                 [ 72]="amy-super-48",      [ 80]="amy-super-50",      [ 88]="amy-super-58",
	                                 [ 96]="amy-super-60",      [104]="amy-super-68",      [112]="amy-super-70"}
	portraits.amy_rose.hyper.face = portraits.amy_rose.super.face	--	Same portrait set
end

