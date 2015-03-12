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
--	ROM checker for 2d Genesis Sonic games.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Check if any ROM is loaded.
--------------------------------------------------------------------------------
if not gens.emulating() then
	error("Error: No ROM is loaded.", 0)
end

require("sonic/common/enums")
require("headers/lua-oo")

--------------------------------------------------------------------------------
--	Boss data reading metafunctions.
--------------------------------------------------------------------------------
local function make_unsigned_read(off, add)
	return function(self)
			local val = memory.readbyte(self.offset + off) + add
			return val > 0 and val or 0
		end
end

local function make_signed_read(off, add)
	return function(self)
			local val = memory.readbytesigned(self.offset + off) + add
			return val > 0 and val or 0
		end
end

--	S1 Final Zone boss flash timer frames.
local function s1_fz_flash_timer(self)
	local rout = memory.readbyte(self.offset + 0x34)
	local time = memory.readbyte(self.offset + 0x35)
	return ((rout == 2) and time) or 0
end

--	S3&K Death Egg 1 mini-boss hit points.
local function s3k_dez1_hit_count(self)
	--	There are two objects for this boss: one with the flashing timer and
	--	starting with 255 hit points, the other with the actual hit points
	--	and an inverted flashing timer. Since both take hits, I watch the
	--	former and simply deduct 247 hit points from his total.
	return ((memory.readlong(self.offset) == 0x7e768) and (memory.readbyte(self.offset + 0x29) - 247)) or 0
end

--------------------------------------------------------------------------------
--	Supported ROM data.
--------------------------------------------------------------------------------
--	Enum with the checksums of all supported ROMS.
local sums = {
	s1wrev0  = 0x264a,
	s1wrev1  = 0xafc7,
	s1knux   = 0x3f81,
	s1amy    = 0x24c4,
	s1charmy = 0x90ad,
	s1tails  = 0x0000,
	s1ggfe   = 0x0138,
	scd      = 0x4d7a,
	scdjp    = 0x9dd9,
	s2       = 0xd951,
	s2boom   = 0xda18,
	s2amy    = 0xa709,
	s2rob    = 0xda21,
	s2vr     = 0xb617,
	s2hrtw   = 0xe1e9,
	s1and2   = 0x80a5,
	s1and2b  = 0x75c5,
	s3       = 0xa8f2,
	sk       = 0xdfb3,
	s3kmaster= 0xb2d9,
	s3kamy   = 0x3030,
}

--	Enum which allows splitting of game engines.
local eng = {
	s1  = 1,
	s2  = 2,
	s3  = 3,
	sk  = 4,
	scd = 5,
	s3k = 6,	--	Slightly different from S&K (e.g., Hyper forms)
}

--	Array containing the boss ids,  and functions for determining the current
--	hit points and flashing timer frames.
--	For S3, S&K and S3&K, a 'pseudo-ID' is defined instead; it is used to
--	determine the icon to display.
--	Note that this table is nearly useless in its own; a separate, script-
--	generated, file contains all the relevant code addresses used by bosses.
local boss_data = {
	s1  = {
		GHZ3 = {0x3d, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		LZ3  = {0x77, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		MZ3  = {0x73, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		SLZ3 = {0x7a, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		SYZ3 = {0x75, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		FZ   = {0x85, make_unsigned_read(0x21,  0), s1_fz_flash_timer           },
	},
	s2 = {
		CPZ2 = {0x5d, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		EHZ2 = {0x56, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		HTZ2 = {0x52, make_unsigned_read(0x32,  0), make_unsigned_read(0x14,  0)},
		ARZ2 = {0x89, make_unsigned_read(0x32,  0), make_unsigned_read(0x14,  0)},
		MCZ2 = {0x57, make_unsigned_read(0x32,  0), make_unsigned_read(0x14,  0)},
		CNZ2 = {0x51, make_unsigned_read(0x32,  0), make_unsigned_read(0x14,  0)},
		MTZ3 = {0x54, make_unsigned_read(0x32,  0), make_unsigned_read(0x14,  0)},
		OOZ2 = {0x55, make_unsigned_read(0x32,  0), make_unsigned_read(0x14,  0)},
		DEZ1 = {0xaf, make_unsigned_read(0x21,  0), make_unsigned_read(0x30,  0)},
		WFZ  = {0xc5, make_signed_read(0x21, 0)   , make_unsigned_read(0x30,  0)},
		DEZ2 = {0xc7, make_unsigned_read(0x21,  0), make_unsigned_read(0x2a,  0)},
	},
	s2rob = {
		GHZ3 = {0xdd, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		MZ3  = {0xdf, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		SYZ3 = {0xe2, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		LZ3  = {0xe4, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		SLZ3 = {0xe7, make_unsigned_read(0x21,  0), make_unsigned_read(0x3e,  0)},
		FZ   = {0xe9, make_unsigned_read(0x21,  0), s1_fz_flash_timer           },
	},
	s3k = {
		knux   = {    2, make_unsigned_read(0x29,  0), make_unsigned_read(0x20,  0)},	--	HPZ, Knuckles
		mecha1 = {    1, make_unsigned_read(0x29,  0), make_unsigned_read(0x20,  0)},	--	SSZ, Mecha Sonic
		mecha2 = {    1, make_unsigned_read(0x29,  0), make_unsigned_read(0x1c,  0)},	--	SSZ, "Metropolis" Mecha Sonic
		CNZ1   = {    0, make_unsigned_read(0x45,  0), make_unsigned_read(0x20,  0)},	--	CNZ1 mini-boss
		MHZ2   = {    0, make_unsigned_read(0x29, -1), make_unsigned_read(0x20,  0)},	--	MHZ2 boss reports one more hit than he can take
		DEZ1   = {    0, s3k_dez1_hit_count          , make_unsigned_read(0x20,  0)},	--	This boss is a mess, read the comments in s3k_dez1_hit_count
		DDZ    = {    0, make_unsigned_read(0x29,  1), make_unsigned_read(0x20,  0)},	--	Both DDZ bosses report one less hit they can take
		normal = {    0, make_unsigned_read(0x29,  0), make_unsigned_read(0x20,  0)},	--	All other bosses
	}
}

--	This maps the above array entries into the relevant code addresses.
--	The file is generated by an external script.
require("sonic/common/boss-tables")
bosses = make_boss_tables(boss_data)
-- TODO: Find out the boss code addresses for these two.
--	s2boom
--	scd

--	Code addresses of HUDs for S2/S3/SK/S3&K and corresponding supported hacks.
--	The file is generated by an external script.
require("sonic/common/hud-codes")

--------------------------------------------------------------------------------
--	Object that encapsulates loads of data for a supported ROM.
--------------------------------------------------------------------------------
local rom_info = class{
	checksum = 0,
	engine = eng.s1,
	air_cap = false,
	tails_flies = false,
	cream_flies = false,
	is_rom = function (self, val) return false end,
	get_char = function () return charids.sonic end,
	boss_array = {},
	ring_offset = 0,
	hud_code = 0,
}

--	Convenience functions for identifying ROMS.
function rom_info:is_sonic1()
	return self.engine == eng.s1
end

function rom_info:is_sonic_cd()
	return self.engine == eng.scd
end

function rom_info:is_sonic2()
	return self.engine == eng.s2
end

function rom_info:is_sonic3()
	return self.engine == eng.s3 or self.engine == eng.s3k
end

function rom_info:is_sonick()
	return self.engine == eng.sk
end

function rom_info:is_sonic3k()
	return self.engine == eng.s3k
end

function rom_info:has_air_speed_cap()
	return self.air_cap
end

--	Constructor.
function rom_info:construct(checksum, engine, air_cap, tails_flies, cream_flies, get_char, boss_array, ring_offset, scroll_delay, hud_code, is_rom)
	self.checksum    = checksum
	self.engine      = engine
	self.air_cap     = air_cap
	self.tails_flies = tails_flies
	self.cream_flies = cream_flies
	self.is_rom      = is_rom or function(self, val) return self.checksum == val end
	if type(get_char) == "function" then
		self.get_char = get_char
	elseif AND(get_char, 0xff0000) ~= 0 then	-- RAM address
		self.get_char = function() return memory.readword(get_char) end
	else
		self.get_char = function() return get_char end
	end
	self.boss_array  = boss_array or {}
	self.ring_offset = ring_offset or 0xfffe20
	self.scroll_delay = scroll_delay
	self.hud_code    = hud_code
	return self
end

--	Special exception check for Tails in Sonic 1.
local function s1tails_check(self, val)
	if self.checksum ~= val then
		return false
	end
	--	Checksum is no good for this hack.
	local title = memory.readbyterange(0x120,0x30)
	local base  = "MILES \"TAILS\" PROWER IN SONIC THE HEDGEHOG      "
	local istails = true
	for i = 1, 0x30, 1 do
		if base:byte(i) ~= title[i] then
			istails = false
			break
		end
	end
	return istails
end

--	We remap the value read from memory in Amy in S2 to the internal IDs
--	defined in the enums file.
local function s2amy_char()
	local char = memory.readword(0xffff72)
	return (char == 2 and charids.tails) or (char + charids.amy_tails)
end

--	We remap the value read from memory in S3Amy to the internal IDs
--	defined in the enums file.
local function s3kamy_char()
	local char = memory.readword(0xffff08)
	return (char >= 2 and char) or (char + charids.amy_tails)
end

--	Check for plain S&K.
local function sknolockon_check(self, val)
	return self.checksum == val and not memory.isvalid(0x20018e)
end

--	Lock-on check for S&K.
local function sklockon_check(v1)
	return function (self, val)
			if self.checksum == val and memory.isvalid(0x20018e) then
				return memory.readword(0x20018e) == v1
			end
			return false
		end
end

--------------------------------------------------------------------------------
--	Data for all supported ROMS, gathered in an easy-to-use rom_info array.
--------------------------------------------------------------------------------
local supported_games = {
	--  The parameters:                              Air    Tails  Cream  Character ID                       Rings     Scroll     S2/S3/SK
	--                       Checksum       Engine   cap    flies  flies  or function       boss code array  offset    Delay      HUD code      special rom check
	s1wrev0  = rom_info:new(sums.s1wrev0  , eng.s1 , true , false, false, charids.sonic   , bosses.s1wrev0 , 0xfffe20),
	s1wrev1  = rom_info:new(sums.s1wrev1  , eng.s1 , true , false, false, charids.sonic   , bosses.s1wrev1 , 0xfffe20),
	s1knux   = rom_info:new(sums.s1knux   , eng.s1 , false, false, false, charids.knuckles, bosses.s1knux  , 0xfffe20, 0xfff7a6),
	s1tails  = rom_info:new(sums.s1tails  , eng.s1 , false, true , false, charids.tails   , bosses.s1tails , 0xfffe20, 0xfffffc , nil         , s1tails_check),
	s1amy    = rom_info:new(sums.s1amy    , eng.s1 , false, false, false, charids.amy_rose, bosses.s1amy   , 0xfffe20),
	s1charmy = rom_info:new(sums.s1charmy , eng.s1 , false, false, false, charids.charmy  , bosses.s1charmy, 0xfffe20),
	s1ggfe   = rom_info:new(sums.s1ggfe   , eng.s1 , true , false, false, charids.sonic   , bosses.s1ggfe  , 0xfffe20),
	scd      = rom_info:new(sums.scd      , eng.scd, true , false, false, charids.sonic   , bosses.scd     , 0xff1512),
	scdjp    = rom_info:new(sums.scdjp    , eng.scd, true , false, false, charids.sonic   , bosses.scd     , 0xff1512),
	s2       = rom_info:new(sums.s2       , eng.s2 , true , false, false, 0xffff72        , bosses.s2      , 0xfffe20, 0xffeed0 , huds.s2    ),
	s2knux   = rom_info:new(sums.sk       , eng.s2 , false, false, false, charids.knuckles, bosses.s2knux  , 0xfffe20, 0xffeed0 , huds.s2knux , sklockon_check(sums.s2)),
	s2amy    = rom_info:new(sums.s2amy    , eng.s2 , false, false, false, s2amy_char      , bosses.s2amy   , 0xfffe20, 0xffeed0 , huds.s2amy ),
	s2boom   = rom_info:new(sums.s2boom   , eng.s2 , false, false, false, charids.sonic   , bosses.s2boom  , 0xfffe02, 0xffeed0 , huds.s2boom),
	s2rob    = rom_info:new(sums.s2rob    , eng.s2 , true , false, false, 0xffff72        , bosses.s2rob   , 0xfffe20, 0xffeed0 , huds.s2rob ),
	s2vr     = rom_info:new(sums.s2vr     , eng.s2 , true , false, false, charids.sonic   , bosses.s2      , 0xfffe02, 0xffeed0 , huds.s2    ),
	s2hrtw   = rom_info:new(sums.s2hrtw   , eng.s2 , true , false, false, 0xffff72        , bosses.s2      , 0xfffe20, 0xffeed0 , huds.s2    ),
	s1and2   = rom_info:new(sums.s1and2   , eng.s2 , true , false, false, 0xffff72        , bosses.s1and2  , 0xfffe20, 0xffeed0 , huds.s1and2),
	s1and2b  = rom_info:new(sums.s1and2b  , eng.s2 , true , false, false, 0xffff72        , bosses.s1and2  , 0xfffe20, 0xffeed0 , huds.s1and2),
	s3       = rom_info:new(sums.s3       , eng.s3 , false, true , false, 0xffff08        , bosses.s3      , 0xfffe20, 0xffee24 , huds.s3    ),
	sk       = rom_info:new(sums.sk       , eng.sk , false, true , false, 0xffff08        , bosses.sk      , 0xfffe20, 0xffee24 , huds.sk     , sknolockon_check),
	s3k      = rom_info:new(sums.sk       , eng.s3k, false, true , false, 0xffff08        , bosses.sk      , 0xfffe20, 0xffee24 , huds.sk     , sklockon_check(sums.s3)),
	s3kmaster= rom_info:new(sums.s3kmaster, eng.s3k, false, true , false, 0xffff08        , bosses.sk      , 0xfffe20, 0xffee24 , huds.sk    ),
	s3kamy   = rom_info:new(sums.s3kamy   , eng.s3k, false, true , false, s3kamy_char     , bosses.sk      , 0xfffe20, 0xffee24 , huds.s3kamy),
}

--	These two variables will hold info on the currently loaded ROM.
rom = nil
romid = nil

--	Find which ROM we have.
local checksum = memory.readword(0x18e)
for id,game in pairs(supported_games) do
	if game.is_rom(game, checksum) then
		rom = game
		romid = tostring(id)
		break
	end
end

if rom == nil then
	--	No matching ROM in the supported list. Print error.
	local s1 = "Error: Unsupported ROM"
	if checksum == sums.sk then
		s2 = "Error details: 'Sonic & Knuckles' ROM is not supported if it is locked on to anything but 'Sonic 2' or 'Sonic 3'."
	else
		s2 = string.format("Error details: ROM with checksum '0x%04x' is unsupported.", checksum)
	end
	error(s1.."\n\n"..s2, 0)
else
	--	Found ROM. Read and print the reported ROM title.
	local name = ""
	--	Sonic CD is an exception.
	if rom:is_sonic_cd() then
		name = "SONIC THE HEDGEHOG CD"
	else
		name = string.char(unpack(memory.readbyterange(0x120,0x30)))
		name = string.gsub(name, "(%s+)", " ")
		name = string.gsub(name, "(%s+)$", "")
		--	Special exception for S&K with supported lock-ons.
		if memory.isvalid(0x20018e) then
			local name2 = string.char(unpack(memory.readbyterange(0x200120,0x30)))
			name2 = string.gsub(name2, "(%s+)", " ")
			name = name.." + "..string.gsub(name2, "(%s+)$", "")
		end
	end
	print(name)
end

