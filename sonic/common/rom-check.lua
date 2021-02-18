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

require("sonic/common/game-data/sonic1-data")
require("sonic/common/game-data/sonic2-data")
require("sonic/common/game-data/sonic3k-data")
require("sonic/common/game-data/soniccd-data")
require("sonic/common/game-data/sch-data")
require("sonic/common/game-data/keh-data")
require("sonic/common/enums")
require("headers/lua-oo")

--------------------------------------------------------------------------------
--	Utility function
--------------------------------------------------------------------------------
function bytes_to_string(bytes)
	local bytearr = {}
	for _, v in ipairs(bytes) do
		table.insert(bytearr, string.char(v))
	end
	return table.concat(bytearr)
end

function check_title(base)
	local title = string.char(unpack(memory.readbyterange(0x120, 0x30)))
	return title == base
end

function get_serial(offset)
	return string.char(unpack(memory.readbyterange(0x180 + (offset or 0), 0x0E)))
end

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

--	SCH Final Zone boss flash timer frames.
local function sch_fz_flash_timer(self)
    local rout = memory.readbyte(self.offset + sch_rom_data.Obj_BossFinal_routine )
    local time = memory.readbyte(self.offset + sch_rom_data.boss_invulnerable_time)
    return ((rout == 2) and time) or 0
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
	s1bunnie = 0x9f87,
	s1tnl    = 0x2020,
	scd      = 0x4d7a,
	scdjp    = 0x9dd9,
	s2       = 0xd951,
	s2boom   = 0xda18,
	s2amy    = 0xa709,
	s2rob    = 0xda21,
	s2vr     = 0xb617,
	s2hrtw   = 0xe1e9,
	s2keh    = 0xf400,
	s1and2   = 0x80a5,
	s1and2b  = 0x75c5,
	s3       = 0xa8f2,
	sk       = 0xdfb3,
	s3kmaster= 0xb2d9,
	s3kamy   = 0x3030,
	s4cyb    = 0xbbc3,
	scheroes = sch_rom_data.Revision,	-- Working revision
}

--	Enum which allows splitting of game engines.
local eng = {
	s1  = 1,
	s2  = 2,
	s3  = 3,
	sk  = 4,
	scd = 5,
	s3k = 6,	--	Slightly different from S&K (e.g., Hyper forms)
	keh = 7,	--	Different RAM layout to S2
	sch = 8,	--	Different from EVERYTHING ELSE
}

--	Array containing the boss ids,  and functions for determining the current
--	hit points and flashing timer frames.
--	For S3, S&K and S3&K, a 'pseudo-ID' is defined instead; it is used to
--	determine the icon to display.
--	Note that this table is nearly useless in its own; a separate, script-
--	generated, file contains all the relevant code addresses used by bosses.
local boss_data = {
	s1  = {
		GHZ3 = {0x3d, make_unsigned_read(sonic1_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          ,  0)},
		LZ3  = {0x77, make_unsigned_read(sonic1_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          ,  0)},
		MZ3  = {0x73, make_unsigned_read(sonic1_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          ,  0)},
		SLZ3 = {0x7a, make_unsigned_read(sonic1_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          ,  0)},
		SYZ3 = {0x75, make_unsigned_read(sonic1_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          ,  0)},
		FZ   = {0x85, make_unsigned_read(sonic1_rom_data.collision_property,  0), s1_fz_flash_timer                                                       },
	},
	s2 = {
		CPZ2 = {0x5d, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic2_rom_data.Obj_CPZBoss_invulnerable_time   ,  0)},
		EHZ2 = {0x56, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic2_rom_data.Obj_EHZBoss_invulnerable_time   ,  0)},
		HTZ2 = {0x52, make_unsigned_read(sonic2_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic2_rom_data.boss_invulnerable_time          ,  0)},
		ARZ2 = {0x89, make_unsigned_read(sonic2_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic2_rom_data.boss_invulnerable_time          ,  0)},
		MCZ2 = {0x57, make_unsigned_read(sonic2_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic2_rom_data.boss_invulnerable_time          ,  0)},
		CNZ2 = {0x51, make_unsigned_read(sonic2_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic2_rom_data.boss_invulnerable_time          ,  0)},
		MTZ3 = {0x54, make_unsigned_read(sonic2_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic2_rom_data.boss_invulnerable_time          ,  0)},
		OOZ2 = {0x55, make_unsigned_read(sonic2_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic2_rom_data.boss_invulnerable_time          ,  0)},
		DEZ1 = {0xaf, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic2_rom_data.Obj_MechaSonic_invulnerable_time,  0)},
		WFZ  = {0xc5, make_signed_read  (sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic2_rom_data.Obj_WFZBoss_invulnerable_time   ,  0)},
		DEZ2 = {0xc7, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic2_rom_data.Obj_Eggrobo_invulnerable_time   ,  0)},
	},
	s2rob = {
		GHZ3 = {0xdd, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          , 0)},
		MZ3  = {0xdf, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          , 0)},
		SYZ3 = {0xe2, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          , 0)},
		LZ3  = {0xe4, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          , 0)},
		SLZ3 = {0xe7, make_unsigned_read(sonic2_rom_data.collision_property,  0), make_unsigned_read(sonic1_rom_data.boss_invulnerable_time          , 0)},
		FZ   = {0xe9, make_unsigned_read(sonic2_rom_data.collision_property,  0), s1_fz_flash_timer           },
	},
	s2keh = {},
	s3k = {
		knux   = {    2, make_unsigned_read(sonic3_rom_data.collision_property,  0), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	HPZ, Knuckles
		mecha1 = {    1, make_unsigned_read(sonic3_rom_data.collision_property,  0), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	SSZ, Mecha Sonic
		mecha2 = {    1, make_unsigned_read(sonic3_rom_data.collision_property,  0), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time2      ,  0)},	--	SSZ, "Metropolis" Mecha Sonic
		CNZ1   = {    0, make_unsigned_read(sonic3_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	CNZ1 mini-boss
		MHZ2   = {    0, make_unsigned_read(sonic3_rom_data.collision_property, -1), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	MHZ2 boss reports one more hit than he can take
		DEZ1   = {    0, s3k_dez1_hit_count                                        , make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	This boss is a mess, read the comments in s3k_dez1_hit_count
		DDZ    = {    0, make_unsigned_read(sonic3_rom_data.collision_property,  1), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	Both DDZ bosses report one less hit they can take
		normal = {    0, make_unsigned_read(sonic3_rom_data.collision_property,  0), make_unsigned_read(sonic3_rom_data.boss_invulnerable_time       ,  0)},	--	All other bosses
	},
	s4cyb = {},
	scheroes = {
		GHZ3 = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		LZ3  = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		MZ3  = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		SLZ3 = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		SYZ3 = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		FZ   = {0, make_unsigned_read(sch_rom_data.collision_property,  0), sch_fz_flash_timer                                                   },
		CPZ2 = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.Obj_CPZBoss_invulnerable_time   ,  0)},
		EHZ2 = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.Obj_EHZBoss_invulnerable_time   ,  0)},
		HTZ2 = {0, make_unsigned_read(sch_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		ARZ2 = {0, make_unsigned_read(sch_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		MCZ2 = {0, make_unsigned_read(sch_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		CNZ2 = {0, make_unsigned_read(sch_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		MTZ3 = {0, make_unsigned_read(sch_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		OOZ2 = {0, make_unsigned_read(sch_rom_data.boss_hitcount2    ,  0), make_unsigned_read(sch_rom_data.boss_invulnerable_time          ,  0)},
		DEZ1 = {1, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.Obj_MechaSonic_invulnerable_time,  0)},
		WFZ  = {0, make_signed_read  (sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.Obj_WFZBoss_invulnerable_time   ,  0)},
		DEZ2 = {0, make_unsigned_read(sch_rom_data.collision_property,  0), make_unsigned_read(sch_rom_data.Obj_Eggrobo_invulnerable_time   ,  0)},
	},
}

--	This maps the above array entries into the relevant code addresses.
--	The file is generated by an external script.
require("sonic/common/boss-tables")
bosses = make_boss_tables(boss_data)
bosses.scheroes = {
	[sch_rom_data.Obj_BossGreenHill_ShipMain ] = boss_data.scheroes.GHZ3,	-- 01
	[sch_rom_data.Obj_BossLabyrinth_ShipMain ] = boss_data.scheroes.LZ3,	-- 02
	[sch_rom_data.Obj_BossMarble_ShipMain    ] = boss_data.scheroes.MZ3,	-- 03
	[sch_rom_data.Obj_BossStarLight_ShipMain ] = boss_data.scheroes.SLZ3,	-- 04
	[sch_rom_data.Obj_BossSpringYard_ShipMain] = boss_data.scheroes.SYZ3,	-- 05
	[sch_rom_data.Obj_BossFinal_Eggman       ] = boss_data.scheroes.FZ,	-- 06
	[sch_rom_data.Obj_CPZBoss_Main           ] = boss_data.scheroes.CPZ2,	-- 01
	[sch_rom_data.Obj_EHZBoss_VehicleMain    ] = boss_data.scheroes.EHZ2,	-- 02
	[sch_rom_data.Obj_HTZBoss_Mobile         ] = boss_data.scheroes.HTZ2,	-- 03
	[sch_rom_data.Obj_ARZBoss_Main           ] = boss_data.scheroes.ARZ2,	-- 04
	[sch_rom_data.Obj_MCZBoss_Main           ] = boss_data.scheroes.MCZ2,	-- 05
	[sch_rom_data.Obj_CNZBoss_Main           ] = boss_data.scheroes.CNZ2,	-- 06
	[sch_rom_data.Obj_MTZBoss_Main           ] = boss_data.scheroes.MTZ3,	-- 07
	[sch_rom_data.Obj_OOZBoss_Main           ] = boss_data.scheroes.OOZ2,	-- 08
	[sch_rom_data.Obj_MechaSonic_Main6       ] = boss_data.scheroes.DEZ1,	-- 09
	[sch_rom_data.Obj_MechaSonic_Main8       ] = boss_data.scheroes.DEZ1,	-- 10
	[sch_rom_data.Obj_MechaSonic_MainA       ] = boss_data.scheroes.DEZ1,	-- 11
	[sch_rom_data.Obj_WFZBoss_LaserCase      ] = boss_data.scheroes.WFZ,	-- 12
	[sch_rom_data.Obj_Eggrobo_Body           ] = boss_data.scheroes.DEZ2,	-- 13
}

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
	data = {},
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

function rom_info:is_sonic3alone()
	return self.engine == eng.s3
end

function rom_info:is_sonick()
	return self.engine == eng.sk
end

function rom_info:is_sonic3k()
	return self.engine == eng.s3k
end

function rom_info:is_keh()
	return self.engine == eng.keh
end

function rom_info:is_scheroes()
	return self.engine == eng.sch
end

function rom_info:has_air_speed_cap()
	return self.air_cap
end

--	Constructor.
function rom_info:construct(checksum, engine, air_cap, tails_flies, cream_flies, get_char, boss_array, ring_offset, scroll_delay, hud_code, is_rom, rom_data)
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
		self.get_char = function() return {get_char} end
	end
	self.boss_array   = boss_array or {}
	self.ring_offset  = ring_offset or 0xfffe20
	self.scroll_delay = scroll_delay
	self.hud_code     = hud_code
	self.data         = rom_data
	return self
end

--	Special exception check for Tails in Sonic 1.
local function s1tails_check(self, val)
	if self.checksum ~= val then
		return false
	end
	--	Checksum is no good for this hack.
	return check_title("MILES \"TAILS\" PROWER IN SONIC THE HEDGEHOG      ")
end

--	Special exception check for Tails in Sonic 1.
local function scheroes_check(self, val)
	--	Checksum is no good for this hack.
	local sch_title = check_title("SONIC THE HEDGEHOG CLASSIC HEROES               ")
	if sch_title == true then
		local revision = memory.readlong(0x1C8)
		if self.checksum ~= revision then
			print("Warning: the ROM is at a different revision than the script was written for. Not everything may work correctly.")
		end
	end
	return sch_title
end

--	We remap the value read from memory in S2/S3/S&K/S3&K to the internal IDs
--	defined in the enums file.
local s23k_char_table = {
	[0] = {charids.sonic, charids.tails},
	[1] = {charids.sonic},
	[2] = {charids.tails},
	[3] = {charids.knuckles},
}

local function s2_char()
	return s23k_char_table[memory.readword(sonic2_rom_data.Player_option)]
end

local function s3k_char()
	return s23k_char_table[memory.readword(sonic3_rom_data.Player_option)]
end

--	We remap the value read from memory in S2Amy/S3Amy to the internal IDs
--	defined in the enums file.
local s23kamy_char_table = {
	[0] = {charids.amy_rose, charids.tails},
	[1] = {charids.amy_rose},
	[2] = {charids.tails},
	[3] = {charids.knuckles},
}

--	We remap the value read from memory in Amy in S2 to the internal IDs
--	defined in the enums file.
local function s2amy_char()
	return s23kamy_char_table[memory.readword(sonic2_rom_data.Player_option)]
end

local function s3kamy_char()
	return s23kamy_char_table[memory.readword(sonic3_rom_data.Player_option)]
end

--	We remap the value read from memory in Sonic Classic Heroes to the internal IDs
--	defined in the enums file.
local scheroes_char_table = {
	[0] = {},
	[1] = {charids.sonic},
	[2] = {charids.tails},
	[3] = {charids.sonic, charids.tails},
	[4] = {charids.knuckles},
	[5] = {charids.sonic, charids.knuckles},
	[6] = {charids.tails, charids.knuckles},
	[7] = {charids.sonic, charids.tails, charids.knuckles},
}

--	We remap the value read from memory in Amy in S2 to the internal IDs
--	defined in the enums file.
local function scheroes_char()
	return scheroes_char_table[memory.readbyte(sch_rom_data.Player_set)]
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

--	Generic hack fallbacks
local function generic_s1_hack()
	local serial = get_serial()
	if serial == "GM 00001009-00" then
		print(string.format("Guessing hack based on 'Sonic 1 Rev00'"))
		return true
	elseif serial == "GM 00004049-01" then
		print(string.format("Guessing hack based on 'Sonic 1 Rev01'"))
		return true
	else
		return false
	end
end

local function generic_s2_hack()
	local serial = get_serial()
	if serial == "GM 00001051-00" then
		print(string.format("Guessing hack based on 'Sonic 2 Rev00'"))
		return true
	elseif serial == "GM 00001051-01" then
		print(string.format("Guessing hack based on 'Sonic 2 Rev01'"))
		return true
	elseif serial == "GM 00001051-02" then
		print(string.format("Guessing hack based on 'Sonic 2 Rev02'"))
		return true
	else
		return false
	end
end

local function generic_s3_hack()
	local serial = get_serial()
	if serial == "GM MK-1079 -00" then
		print(string.format("Guessing hack based on 'Sonic 3'"))
		return true
	else
		return false
	end
end

local function generic_sk_hack()
	local serial1 = get_serial()
	local serial2 = memory.isvalid(0x200180) and get_serial(0x200000)
	local sram = string.char(unpack(memory.readbyterange(0x1B0, 0x2)))
	print(serial1, serial1 == "GM MK-1563 -00")
	print(sram, sram == "  ")
	if serial1 == "GM MK-1563 -00" and serial2 ~= "GM MK-1079 -00" and sram == "  " then
		print(string.format("Guessing hack based on 'Sonic & Knuckles'"))
		return true
	else
		return false
	end
end

local function generic_s3k_hack()
	local serial1 = get_serial()
	local serial2 = memory.isvalid(0x200180) and get_serial(0x200000)
	local sram = string.char(unpack(memory.readbyterange(0x1B0, 0x2)))
	if serial1 == "GM MK-1563 -00" and (serial2 == "GM MK-1079 -00" or sram == "RA") then
		print(string.format("Guessing hack based on 'Sonic 3 & Knuckles'"))
		return true
	else
		return false
	end
end
--------------------------------------------------------------------------------
--	Data for all supported ROMS, gathered in an easy-to-use rom_info array.
--------------------------------------------------------------------------------
local supported_games = {
	--  The parameters:                              Air    Tails  Cream  Character ID                       Rings                    Scroll                         S2/S3/SK                              ROM
	--                       Checksum       Engine   cap    flies  flies  or function       boss code array  offset                   Delay                          HUD code      special rom check       Data
	s1wrev0  = rom_info:new(sums.s1wrev0  , eng.s1 , true , false, false, charids.sonic   , bosses.s1wrev0 , 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	s1wrev1  = rom_info:new(sums.s1wrev1  , eng.s1 , true , false, false, charids.sonic   , bosses.s1wrev1 , 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	s1knux   = rom_info:new(sums.s1knux   , eng.s1 , false, false, false, charids.knuckles, bosses.s1knux  , 0xfffe20               , 0xfff7a6                     , nil        , nil                    , sonic1_rom_data ),
	s1tails  = rom_info:new(sums.s1tails  , eng.s1 , false, true , false, charids.tails   , bosses.s1tails , 0xfffe20               , 0xfffffc                     , nil        , s1tails_check          , sonic1_rom_data ),
	s1amy    = rom_info:new(sums.s1amy    , eng.s1 , false, false, false, charids.amy_rose, bosses.s1amy   , 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	s1charmy = rom_info:new(sums.s1charmy , eng.s1 , false, false, false, charids.charmy  , bosses.s1charmy, 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	s1ggfe   = rom_info:new(sums.s1ggfe   , eng.s1 , true , false, false, charids.sonic   , bosses.s1ggfe  , 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	s1bunnie = rom_info:new(sums.s1bunnie , eng.s1 , false, false, false, charids.bunnie  , bosses.s1bunnie, 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	s1tnl    = rom_info:new(sums.s1tnl    , eng.s1 , true , false, false, charids.sonic   , bosses.s1tnl   , 0xfffe20               , nil                          , nil        , nil                    , sonic1_rom_data ),
	scd      = rom_info:new(sums.scd      , eng.scd, true , false, false, charids.sonic   , bosses.scd     , 0xff1512               , nil                          , nil        , nil                    , soniccd_rom_data),
	scdjp    = rom_info:new(sums.scdjp    , eng.scd, true , false, false, charids.sonic   , bosses.scd     , 0xff1512               , nil                          , nil        , nil                    , soniccd_rom_data),
	s2       = rom_info:new(sums.s2       , eng.s2 , true , false, false, s2_char         , bosses.s2      , 0xfffe20               , 0xffeed0                     , huds.s2    , nil                    , sonic2_rom_data ),
	s2knux   = rom_info:new(sums.sk       , eng.s2 , false, false, false, charids.knuckles, bosses.s2knux  , 0xfffe20               , 0xffeed0                     , huds.s2knux, sklockon_check(sums.s2), sonic2_rom_data ),
	s2amy    = rom_info:new(sums.s2amy    , eng.s2 , false, false, false, s2amy_char      , bosses.s2amy   , 0xfffe20               , 0xffeed0                     , huds.s2amy , nil                    , sonic2_rom_data ),
	s2boom   = rom_info:new(sums.s2boom   , eng.s2 , false, false, false, charids.sonic   , bosses.s2boom  , 0xfffe02               , 0xffeed0                     , huds.s2boom, nil                    , sonic2_rom_data ),
	s2rob    = rom_info:new(sums.s2rob    , eng.s2 , true , false, false, s2_char         , bosses.s2rob   , 0xfffe20               , 0xffeed0                     , huds.s2rob , nil                    , sonic2_rom_data ),
	s2vr     = rom_info:new(sums.s2vr     , eng.s2 , true , false, false, charids.sonic   , bosses.s2      , 0xfffe02               , 0xffeed0                     , huds.s2    , nil                    , sonic2_rom_data ),
	s2hrtw   = rom_info:new(sums.s2hrtw   , eng.s2 , true , false, false, s2_char         , bosses.s2      , 0xfffe20               , 0xffeed0                     , huds.s2    , nil                    , sonic2_rom_data ),
	s2keh    = rom_info:new(sums.s2keh    , eng.keh, false, false, false, charids.knuckles, bosses.s2keh   , 0xfffefc               , 0xfff47e                     , huds.s2keh , nil                    , keh_rom_data    ),
	s1and2   = rom_info:new(sums.s1and2   , eng.s2 , true , false, false, s2_char         , bosses.s1and2  , 0xfffe20               , 0xffeed0                     , huds.s1and2, nil                    , sonic2_rom_data ),
	s1and2b  = rom_info:new(sums.s1and2b  , eng.s2 , true , false, false, s2_char         , bosses.s1and2  , 0xfffe20               , 0xffeed0                     , huds.s1and2, nil                    , sonic2_rom_data ),
	s3       = rom_info:new(sums.s3       , eng.s3 , false, true , false, s3k_char        , bosses.s3      , 0xfffe20               , 0xffee24                     , huds.s3    , nil                    , sonic3_rom_data ),
	sk       = rom_info:new(sums.sk       , eng.sk , false, true , false, s3k_char        , bosses.sk      , 0xfffe20               , 0xffee24                     , huds.sk    , sknolockon_check       , sonic3_rom_data ),
	s3k      = rom_info:new(sums.sk       , eng.s3k, false, true , false, s3k_char        , bosses.sk      , 0xfffe20               , 0xffee24                     , huds.sk    , sklockon_check(sums.s3), sonic3_rom_data ),
	s3kmaster= rom_info:new(sums.s3kmaster, eng.s3k, false, true , false, s3k_char        , bosses.sk      , 0xfffe20               , 0xffee24                     , huds.sk    , nil                    , sonic3_rom_data ),
	s3kamy   = rom_info:new(sums.s3kamy   , eng.s3k, false, true , false, s3kamy_char     , bosses.sk      , 0xfffe20               , 0xffee24                     , huds.s3kamy, nil                    , sonic3_rom_data ),
	s4cyb    = rom_info:new(sums.s4cyb    , eng.s3k, false, true , false, charids.sonic   , bosses.s4cyb   , 0xfffe20               , 0xffee24                     , nil        , nil                    , sonic3_rom_data ),
	scheroes = rom_info:new(sums.scheroes , eng.sch, false, true , false, scheroes_char   , bosses.scheroes, sch_rom_data.Ring_count, sch_rom_data.Camera_delay_ptr, nil        , scheroes_check         , sch_rom_data    ),
}

--------------------------------------------------------------------------------
--	Data for fallback base games, gathered in an easy-to-use rom_info array.
--------------------------------------------------------------------------------

local fallbacks = {
	--  The parameters:                              Air    Tails  Cream  Character ID                       Rings                    Scroll                         S2/S3/SK                              ROM
	--                       Checksum       Engine   cap    flies  flies  or function       boss code array  offset                   Delay                          HUD code      special rom check       Data
	s1       = rom_info:new(sums.s1wrev0  , eng.s1 , true , false, false, charids.sonic   , {}             , 0xfffe20               , nil                          , nil        , generic_s1_hack   , sonic1_rom_data ),
	s2       = rom_info:new(sums.s2       , eng.s2 , true , false, false, s2_char         , {}             , 0xfffe20               , 0xffeed0                     , nil        , generic_s2_hack   , sonic2_rom_data ),
	s3       = rom_info:new(sums.s3       , eng.s3 , false, true , false, s3k_char        , {}             , 0xfffe20               , 0xffee24                     , nil        , generic_s3_hack   , sonic3_rom_data ),
	sk       = rom_info:new(sums.sk       , eng.sk , false, true , false, s3k_char        , {}             , 0xfffe20               , 0xffee24                     , nil        , generic_sk_hack   , sonic3_rom_data ),
	s3k      = rom_info:new(sums.sk       , eng.s3k, false, true , false, s3k_char        , {}             , 0xfffe20               , 0xffee24                     , nil        , generic_s3k_hack  , sonic3_rom_data ),
}

--	These two variables will hold info on the currently loaded ROM.
rom = nil
romid = nil

--	Find which ROM we have.
local checksum = memory.readword(0x18e)
for id, game in pairs(supported_games) do
	if game.is_rom(game, checksum) then
		rom = game
		romid = tostring(id)
		break
	end
end

if rom == nil then
	--	No matching ROM in the supported list.
	-- Try fallbacks
	print(string.format("Unsupported ROM with checksum '0x%04x'", checksum))
	--	Find which ROM we have.
	local checksum = memory.readword(0x18e)
	for id, game in pairs(fallbacks) do
		if game.is_rom(game, checksum) then
			rom = game
			romid = tostring(id)
			print(string.format("Note: fallback functionality will be limited, and maybe even wrong.", checksum))
			break
		end
	end
	print("")
end

if rom == nil then
		-- Print error.
	if checksum == sums.sk then
		s2 = "Error: 'Sonic & Knuckles' ROM is not supported if it is locked on to anything but 'Sonic 2' or 'Sonic 3'."
		s2 = string.format("%s\nLock-on checksum '0x%04x' is unsupported.", s2, memory.readword(0x20018e))
	else
		s2 = string.format("Error: ROM with checksum '0x%04x' is unsupported.", checksum)
	end
	error(s2, 0)
else
	--	Found ROM. Read and print the reported ROM title.
	local name = ""
	--	Sonic CD is an exception.
	if rom:is_sonic_cd() then
		name = "SONIC THE HEDGEHOG CD"
	else
		name = string.char(unpack(memory.readbyterange(0x120, 0x30)))
		name = string.gsub(name, "(%s+)", " ")
		name = string.gsub(name, "(%s+)$", "")
		--	Special exception for S&K with supported lock-ons.
		if not rom:is_scheroes() and memory.isvalid(0x20018e) then
			local name2 = string.char(unpack(memory.readbyterange(0x200120, 0x30)))
			name2 = string.gsub(name2, "(%s+)", " ")
			name = name.." + "..string.gsub(name2, "(%s+)$", "")
		end
	end
	print(name)
end

