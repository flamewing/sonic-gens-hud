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
--	Character data, wrapped up in an object.
--	Written by: Marzo Junior
--	Based on game disassemblies and Gens' RAM search.
--------------------------------------------------------------------------------

require("headers/lua-oo")
require("sonic/common/rom-check")
require("sonic/common/game-info")

Character = class{
	is_p1          = false,
	offset         = 0,
	charid         = charids.sonic,
	flies          = false,
	portraits      = {},       --	Character portait sets
	curr_set       = {},       --	Current portrait set
	curr_face      = false,    --	Currently selected face
	swap_delay     = 0,        --	Delay for portrait swap
	super_pal      = 0,        --	Current portrait palette
	super_swap     = 0,        --	Counter for portrait swap
	super_frame    = 0,        --	Frame in which portrait will be swapped
	jump_speed     = "",       --	String value for jump prediction
	drowning_timer = function (self) return "" end,
	drown_icon     = "blank",
	status_huds    = {},
}

function Character:get_slope()
	return string.format("%+5d", memory.readbytesigned(self.offset + 0x26))
end

if rom:is_sonic3() or rom:is_sonick() then
	function Character:get_position()
		local xpospix   = memory.readword      (self.offset + 0x10)
		local xpossub   = memory.readbyte      (self.offset + 0x12)
		local ypospix   = memory.readwordsigned(self.offset + 0x14)
		local ypossub   = memory.readbyte      (self.offset + 0x16)
		return string.format("%5d:%-3d,%5d:%-3d", xpospix, xpossub, ypospix, ypossub)
	end

	function Character:get_speed()
		local xvel      = memory.readwordsigned(self.offset + 0x18)
		local yvel      = memory.readwordsigned(self.offset + 0x1a)
		local speed     = memory.readwordsigned(self.offset + 0x1c)
		return string.format("%+5d, %+5d, %+5d", xvel, yvel, speed)
	end

	function Character:get_yvel()
		return memory.readwordsigned(self.offset + 0x1a)
	end

	function Character:get_flags()
		return memory.readbyte(self.offset + 0x2a)
	end

	function Character:hit_time_left()
		return memory.readbyte(self.offset + 0x34)
	end

	function Character:hit_timer()
		return string.format("%5d", self:hit_time_left())
	end

	function Character:stars_timer()
		return string.format("%5d", 8 * memory.readbyte(self.offset + 0x35) - game:get_level_frames() % 8)
	end

	function Character:shoes_timer()
		return string.format("%5d", 8 * memory.readbyte(self.offset + 0x36) - game:get_level_frames() % 8)
	end
	
	function Character:get_dimensions()
		return memory.readbyte(self.offset + 0x1F), memory.readbyte(self.offset + 0x1E)
	end
else
	function Character:get_position()
		local xpospix   = memory.readword      (self.offset + 0x08)
		local xpossub   = memory.readbyte      (self.offset + 0x0a)
		local ypospix   = memory.readwordsigned(self.offset + 0x0c)
		local ypossub   = memory.readbyte      (self.offset + 0x0e)
		return string.format("%5d:%-3d,%5d:%-3d", xpospix, xpossub, ypospix, ypossub)
	end

	function Character:get_speed()
		local xvel      = memory.readwordsigned(self.offset + 0x10)
		local yvel      = memory.readwordsigned(self.offset + 0x12)
		local speed     = memory.readwordsigned(self.offset + 0x14)
		return string.format("%+5d, %+5d, %+5d", xvel, yvel, speed)
	end

	function Character:get_yvel()
		return memory.readwordsigned(self.offset + 0x12)
	end

	function Character:get_flags()
		return memory.readbyte(self.offset + 0x22)
	end

	function Character:hit_time_left()
		return memory.readword(self.offset + 0x30)
	end

	function Character:hit_timer()
		return string.format("%5d", self:hit_time_left())
	end

	function Character:stars_timer()
		return string.format("%5d", memory.readword(self.offset + 0x32))
	end

	function Character:shoes_timer()
		return string.format("%5d", memory.readword(self.offset + 0x34))
	end
	
	function Character:get_dimensions()
		return memory.readbyte(self.offset + 0x17), memory.readbyte(self.offset + 0x16)
	end
end

function Character:is_rolling()
	return AND(self:get_flags(), BIT(2)) ~= 0
end

function Character:is_underwater()
	return AND(self:get_flags(), BIT(6)) ~= 0
end

function Character:hit_active()
	return self:hit_time_left() ~= 0
end

if rom:is_sonic1() then
	function Character:stars_active()
		return memory.readbyte(0xfffe2d) ~= 0
	end

	function Character:shoes_active()
		return memory.readbyte(0xfffe2e) ~= 0
	end

	function Character:get_shield()
		return memory.readbyte(0xfffe2c)
	end
elseif rom:is_sonic_cd() then
	function Character:stars_active()
		return memory.readbyte(0xff151f) ~= 0
	end

	function Character:shoes_active()
		return memory.readbyte(0xff1520) ~= 0
	end

	function Character:get_shield()
		return memory.readbyte(0xff151e)
	end
else
	function Character:get_status()
		return memory.readbyte(self.offset + 0x2b)
	end

	function Character:stars_active()
		return AND(self:get_status(), BIT(1)) ~= 0
				and game:super_status() == 0
	end
	
	function Character:shoes_active()
		return AND(self:get_status(), BIT(2)) ~= 0
	end

	function Character:get_shield()
		return self:get_status()
	end
end

if rom:is_sonic1() then
	function Character:flight_time_left()
		return memory.readword(self.offset + 0x20)
	end

	function Character:flight_active()
		return memory.readbyte(self.offset + 0x2f) ~= 0 and self:flight_time_left() > 0
	end

	function Character:flight_value()
		return memory.readbyte(self.offset + 0x2f)
	end

	function Character:flight_no_pickup_time_left()
		return 0
	end

	function Character:flight_boost_timer()
		-- Frames left in the boost counter
		local fval = 32 - self:flight_value()
		-- Vertical position
		local ypos = memory.readwordsigned(self.offset + 0xc)
		-- Vertical limit for flight
		local ylim = memory.readwordsigned(0xfff724) + 0x10 -- need to check this!
		-- Above this position, Tails can't have negative vertical speed
		if ypos > ylim then
			-- Velocity
			local yvel = self:get_yvel()
			-- Predividing initial velocity by acceleration
			local vy_0 = -yvel / 32
			-- Distance, in subpixels, before Tails reaches the flight limit,
			-- predivided by absolute value of acceleration (we will only need
			-- the square of this term).
			local dy_0 = 2 * ((ylim - ypos) * 256 - memory.readbyte(self.offset + 0xe)) / 32
			-- How many frames (including fractions) until Tails reaches
			-- the flight limit
			local nfra = (dy_0 * dy_0 + vy_0 * vy_0) ^ (0.5) - vy_0
			-- How many frames until Tails reaches flight speed limit
			local vlim = (yvel + 288)/32
			-- Pick lowest of the 3.
			if nfra < fval and nfra < vlim then
				return string.format("%5d", nfra)
			elseif nfra < fval or vlim < fval then
				return string.format("%5d", vlim)
			end
		end
		return string.format("%5d", fval)
	end
elseif rom:is_sonic3() or rom:is_sonick() then
	function Character:flight_time_left()
		local dec = 1 - AND(game:get_level_frames(),1)
		return 2 * memory.readbyte(self.offset + 0x25) - dec
	end

	function Character:flight_active()
		return memory.readbyte(self.offset + 0x2f) ~= 0 and self:flight_time_left() > 0
	end

	function Character:flight_value()
		return memory.readbyte(self.offset + 0x2f)
	end

	function Character:flight_no_pickup_time_left()
		return memory.readbyte(0xfffff73f)
	end

	function Character:flight_boost_timer()
		-- Frames left in the boost counter
		local fval = 32 - self:flight_value()
		-- Vertical position
		local ypos = memory.readwordsigned(self.offset + 0xc)
		-- Vertical limit for flight
		local ylim = memory.readwordsigned(0xffee18) + 0x10
		-- Above this position, Tails can't have negative vertical speed
		if ypos > ylim then
			-- Velocity
			local yvel = self:get_yvel()
			-- Predividing initial velocity by acceleration
			local vy_0 = -yvel / 32
			-- Distance, in subpixels, before Tails reaches the flight limit,
			-- predivided by absolute value of acceleration (we will only need
			-- the square of this term).
			local dy_0 = 2 * ((ylim - ypos) * 256 - memory.readbyte(self.offset + 0xe)) / 32
			-- How many frames (including fractions) until Tails reaches
			-- the flight limit
			local nfra = (dy_0 * dy_0 + vy_0 * vy_0) ^ (0.5) - vy_0
			-- How many frames until Tails reaches flight speed limit
			local vlim = (yvel + 288)/32
			-- Pick lowest of the 3.
			if nfra < fval and nfra < vlim then
				return string.format("%5d", nfra)
			elseif nfra < fval or vlim < fval then
				return string.format("%5d", vlim)
			end
		end
		return string.format("%5d", fval)
	end
else
	function Character:flight_time_left()
		return 0
	end

	function Character:flight_active()
		return false
	end

	function Character:flight_value()
		return 0
	end

	function Character:flight_no_pickup_time_left()
		return 0
	end

	function Character:flight_boost_timer()
		return "0"
	end
end

function Character:flight_timer()
	return string.format("%5d", self:flight_time_left())
end

function Character:flight_boosting()
	return self:flight_value() > 1 and self:get_yvel() >= -256
end

function Character:flight_no_pickup_timer()
	return string.format("%5d", self:flight_no_pickup_time_left())
end

function Character:flight_no_pickup_active()
	return self:flight_no_pickup_time_left() > 0
end

function Character:shield()
	local status = self:get_shield()
	for _,m in ipairs(game.shields) do
		if AND(status,BIT(m)) ~= 0 then
			return m
		end
	end
	return shieldids.no_shield
end

function Character:is_drowning()
	return self:shield() ~= shieldids.bubble_shield and     --	Bubble shield
	       --	That is right: Tails doesn't drown if *Sonic* is in Hyper form!
	       not game:hyper_form() and self:is_underwater()
end

if rom:is_sonic3() or rom:is_sonick() then
	--	Filtered by Sonic elsewhere.
	function Character:doing_instashield()
		return self:shield() == shieldids.no_shield and
		       game:super_status() ~= 1 and game:super_status() ~= -1 and
		       memory.readbyte(self.offset + 0x2f) == 1 and
		       memory.readbyte(0xffcce8 + 0x23) >= 0
	end
	function Character:instashield_time()
		return string.format("%5d", 15 - memory.readbyte(0xffcce8 + 0x21) - memory.readbyte(0xffcce8 + 0x23))
	end
else
	function Character:doing_instashield()
		return false
	end
	function Character:instashield_time()
		return 0
	end
end

if rom:is_sonic_cd() then
	--	Spindash and super peelout use essentially the same mechanism in SCD.
	function Character:spindash_time()
		return memory.readbyte(self.offset + 0x2a)
	end
	function Character:spindash_active()
		return self:spindash_time() ~= 0
	end

	function Character:spindash_charge()
		-- You can release it a frame earlier than this, but it will be slower.
		local max = (self:is_rolling() and 45-1) or 30-1
		local val = self:spindash_time()
		local sonicspd = memory.readword(0xfff760)
		local absinertia = math.abs(memory.readwordsigned(self.offset + 0x14))
		local maxcharge = (Character:shoes_active() and (sonicspd * 3 / 2)) or (sonicspd * 2)
		return string.format("%s%3d%%", (val >= max and "Y") or "N", math.floor((100 * absinertia) / maxcharge))
	end

	function Character:spindash_icon()
		return (self:is_rolling() and self.curr_set.spindash) or "sonic-peelout"
	end

	function Character:no_peelout_time()
		return AND(memory.readbyte(0xfff788), 0xf)
	end

	function Character:no_peelout_active()
		return self:no_peelout_time() ~= 0
	end

	function Character:no_peelout_value()
		return string.format("%5d", 0x10 - self:no_peelout_time())
	end
else
	-- Standard spindash.
	local flag   = nil --	byte; set for spindash
	local charge = nil --	word; spindash charge
	if rom:is_sonic3() or rom:is_sonick() then
		flag     = 0x3d
		charge   = 0x3e
	else
		flag     = 0x39
		charge   = 0x3a
	end

	function Character:spindash_active()
		return memory.readbytesigned(self.offset + flag) ~= 0
	end

	function Character:spindash_charge()
		return string.format("%4d%%", SHIFT(100 * memory.readword(self.offset + charge), 11))
	end

	function Character:spindash_icon()
		return self.curr_set.spindash
	end

	function Character:no_peelout_active()
		return false
	end

	function Character:no_peelout_value()
		return ""
	end
end

function Character:wounded_icon()
	return self.curr_set.wounded
end

if rom:is_sonic3() or rom:is_sonick() then
	function Character:move_lock_timer()
		return memory.readword(self.offset + 0x32)
	end
elseif rom:is_sonic2() then
	function Character:move_lock_timer()
		return memory.readword(self.offset + 0x2e)
	end
else
	function Character:move_lock_timer()
		return memory.readword(self.offset + 0x3e)
	end
end

function Character:move_lock_active()
	return self:move_lock_timer() > 0
end

function Character:move_lock_text()
	return string.format("%5d", self:move_lock_timer())
end


function Character:get_face()
	--	Only for player 1
	if self.is_p1 then
		local super = game:super_status()
		if super == 2 or super == 0 then --	Transformation ending or no transformation
			self.curr_set  = self.portraits.normal
			self.curr_face = self.curr_set.face
		elseif super == 1 then           --	Transforming
			self.curr_face = "superchange"
		elseif super == -1 then          --	Super form
			local currframe = gens.framecount()
			if gens.lagged() then    --	TESTING!!!
				self.super_frame = self.super_frame + 1
			end
			if currframe == self.super_frame or not self.curr_face then      --	Time to get a new portrait
				local newpal = memory.readbyte(self.super_pal)
				if self.charid == charids.tails then	         --	Tails is different
					self.curr_set = self.portraits.hyper
				else
					if game:hyper_form() then
						self.curr_set = self.portraits.hyper
					else
						--	Note that suptype = 0 means no super and suptype = 1 means super.
						--	But this is irrelevant given that we check for super form more reliably.
						self.curr_set = self.portraits.super
					end
				end
				self.curr_face = self.curr_set.face[newpal]
			end
			local swaptimer = memory.readbyte(self.super_swap)
			if swaptimer == 0 then    --	Queue next palette swap
				self.super_frame = currframe + self.swap_delay
			end
		end
	else
		--	Just in case.
		self.curr_set  = self.portraits.normal
		self.curr_face = self.curr_set.face
	end
	return self.curr_face
end

if rom:is_sonic3() or rom:is_sonick() then
	function Character:in_game()
		return memory.readlong(self.offset) ~= 0
	end
else
	function Character:in_game()
		return memory.readbyte(self.offset) ~= 0
	end
end

function Character:init(id, p1, port)
	self.charid      = id
	self.is_p1       = p1

	--	Character offsets
	local p1_off        = nil
	local p2_off        = nil
	if rom:is_sonic1() or rom:is_sonic_cd() then
		p1_off        = 0xffd000
		p2_off        = 0xffd040
	elseif rom:is_sonic2() then
		p1_off        = 0xffb000
		p2_off        = 0xffb040
	else
		p1_off        = 0xffb000
		p2_off        = 0xffb04a
	end
	if p1 then
		self.offset       = p1_off
		self.drown_icon   = "bubbles"
	else
		self.offset       = p2_off
		if self.charid == charids.tails then
			self.drown_icon   = "bubbles-tails"
		elseif self.charid == charids.cream then
			self.drown_icon   = "bubbles-cream"
		end
	end

	self.portraits   = port
	self.curr_set    = port.normal
	self.curr_face   = false
	self.super_frame = 0
	self.jump_speed  = ""
	local dso = nil
	local dfo = nil
	if rom:is_sonic_cd() then
		dso = 0xff150b
		dfo = 0xffd1f8
	elseif rom:is_sonic1() then
		dso = 0xfffe15
		dfo = 0xffd378
	elseif rom:is_sonic2() then
		dso = self.offset + 0x28
		dfo = 0xffd0b8
	elseif rom:is_sonic3() or rom:is_sonick() then
		dso = self.offset + 0x2c
		dfo = 0xffcb68
	end

	if self.charid == charids.tails then
		--	Tails is different.
		if not rom:is_sonic1() then
			--	Tails drowns differently in S2, S3 and S3K, even if solo.
			dfo = dfo + p2_off - p1_off
		end
		--	You can hack Tails in Sonic & Knuckles, so lets leave him here.
		self.flies       = rom.tails_flies
		self.swap_delay  = 4
		self.super_pal   = 0xfff668
		self.super_swap  = 0xfff669
	elseif self.charid == charids.cream then
		--	As is Cream in S2.
		if not rom:is_sonic1() then
			--	Cream drowns differently in S2, even if solo.
			dfo = dfo + p2_off - p1_off
		end
		self.flies       = rom.cream_flies
		--	Copying Tails' super stuff from S3&K.
		self.swap_delay  = 4
		self.super_pal   = 0xfff668
		self.super_swap  = 0xfff669
	else
		self.flies       = false
		self.swap_delay  = (rom:is_sonic2() and 2) or 3
		self.super_pal   = 0xfff65d
		self.super_swap  = 0xfff65e
	end

	self.drowning_timer = function(self)
				return string.format("%5d", 60 * memory.readbyte(dso) + memory.readword(dfo))
			end

	--	This manufactures a HUD icon monitor given the adequate functions.
	--	'Icon' can be either a function or a gdimage.
	local function Create_HUD(this, active_fun, timer_fun, icon)
		local cond = Conditional_widget:new(0, 0, false, active_fun, this)
		local hud  = Frame_widget:new(0, 0, 42, 17)
		hud:add_status_icon(2, 2, icon, bind(timer_fun, this))
		cond:add(hud, 0, 0)

		return cond
	end

	--	Here we generate the list of status monitor icons for each character, starting with
	--	the common icons. To add new ones, just copy and modify accordingly.
	self.status_huds = {
		Create_HUD(self, self.spindash_active  , self.spindash_charge , bind(self.spindash_icon, self)),
		Create_HUD(self, self.hit_active       , self.hit_timer       , bind(self.wounded_icon , self)),
		Create_HUD(self, self.is_drowning      , self.drowning_timer  , self.drown_icon               ),
	}

	if self.charid == charids.sonic then
	 	table.insert(self.status_huds, 1,
			Create_HUD(self, self.doing_instashield , self.instashield_time , "sonic-instashield"))
	 	table.insert(self.status_huds, 1,
			Create_HUD(self, self.no_peelout_active , self.no_peelout_value , "sonic-no-peelout" ))
	end

	if self.flies then
		local ficon = "blank"
		if self.charid == charids.tails then
			ficon = "tails-flight"
			if rom:is_sonic3() or rom:is_sonick() then
			 	table.insert(self.status_huds, 1,
					Create_HUD(self, self.flight_no_pickup_active, self.flight_no_pickup_timer, "tails-flight-no-pickup"))
			end
		elseif self.charid == charids.cream then
		 	ficon = "cream-flight"
		end
	 	table.insert(self.status_huds, 1,
			Create_HUD(self, self.flight_active  , self.flight_timer      , ficon         ))
	 	table.insert(self.status_huds, 1,
			Create_HUD(self, self.flight_boosting, self.flight_boost_timer, "flight-boost"))
	end

	if self.is_p1 then
	 	--	Status icons specific to player 1 (whoever he is).
		--	While the first two icons (invincibility and speed shoes) could theoretically
		--	apply for either character in a Sonic + Tails game (in S2, S3, S3&K), it never
		--	happens in-game except in 2p mode, for which this script is inadequate anyway.
		table.insert(self.status_huds, 1,
			Create_HUD(self, self.stars_active       , self.stars_timer        , "invincibility"))
		table.insert(self.status_huds, 2,
			Create_HUD(self, self.shoes_active       , self.shoes_timer        , "superspeed"   ))
	 	--	Player-independent status icons. They are included in player 1 for
	 	--	convenience purposes only.
		table.insert(self.status_huds, 3,
			Create_HUD(game, game.super_active       , game.super_timer        , "superchange"  ))
		table.insert(self.status_huds,
			Create_HUD(game, game.warp_active        , game.warp_timer         , "clock"        ))
		table.insert(self.status_huds,
			Create_HUD(game, game.scroll_delay_active, game.scroll_delay_timer , "camera-lock"  ))
	elseif self.charid == charids.tails then
		--	Status icons specific to player 2 Tails.
		table.insert(self.status_huds,
			Create_HUD(game, game.cputime_active     , game.cputime_timer      , "cpu-2p"       ))
		table.insert(self.status_huds,
			Create_HUD(game, game.despawn_active     , game.despawn_timer      , "tails-despawn"))
		table.insert(self.status_huds,
			Create_HUD(game, game.respawn_active     , game.respawn_timer      , "tails-normal" ))
	elseif self.charid == charids.cream then
		--	Status icons specific to player 2 Cream.
		table.insert(self.status_huds,
			Create_HUD(game, game.cputime_active     , game.cputime_timer      , "cpu-2p"       ))
		table.insert(self.status_huds,
			Create_HUD(game, game.despawn_active     , game.despawn_timer      , "cream-despawn"))
		table.insert(self.status_huds,
			Create_HUD(game, game.respawn_active     , game.respawn_timer      , "cream-normal" ))
	end
end

function Character:construct(id, p1, port)
	self:init(id, p1, port)
	return self
end


--------------------------------------------------------------------------------
--	Initializer for the character objects.
--------------------------------------------------------------------------------
characters = nil

--	Set character data
function set_chardata(selchar)
	game.curr_char   = selchar
	if selchar == charids.sonic_tails then          --	Sonic + Tails
		characters = {
			Character:new(charids.sonic, true , portraits.sonic),
			Character:new(charids.tails, false, portraits.tails)
		}
	elseif selchar == charids.sonic then            --	Sonic solo
		characters = {
			Character:new(charids.sonic, true , portraits.sonic)
		}
	elseif selchar == charids.tails then            --	Tails
		characters = {
			Character:new(charids.tails, true , portraits.tails)
		}
	elseif selchar == charids.knuckles then         --	Knuckles
		characters = {
			Character:new(charids.knuckles, true , portraits.knuckles)
		}
	elseif selchar == charids.amy_tails then        --	Amy + Tails
		characters = {
			Character:new(charids.amy_rose, true , portraits.amy_rose),
			Character:new(charids.tails, false, portraits.tails)
		}
	elseif selchar == charids.amy_rose then			--	Amy
		characters = {
			Character:new(charids.amy_rose, true , portraits.amy_rose)
		}
	--[[
	elseif selchar == charids.cream then			--	Cream
		characters = {
			Character:new(charids.cream   , true , portraits.cream   )
		}
	--]]
	elseif selchar == charids.charmy then			--	charmy
		characters = {
			Character:new(charids.charmy  , true , portraits.charmy  )
		}
	elseif selchar == charids.bunnie then			--	Bunnie
		characters = {
			Character:new(charids.bunnie  , true , portraits.bunnie  )
		}
	end
end

