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
require("sonic/common/enums")
require("sonic/common/rom-check")
require("sonic/common/game-info")
require("sonic/common/portraits")

Character = class{
	is_p1          = false,
	base_offset    = 0,
	offset         = 0,
	charid         = charids.sonic,
	portraits      = {},       --	Character portait sets
	curr_set       = {},       --	Current portrait set
	curr_face      = false,    --	Currently selected face
	swap_delay     = 0,        --	Delay for portrait swap
	super_pal      = 0,        --	Current portrait palette
	super_swap     = 0,        --	Counter for portrait swap
	super_frame    = 0,        --	Frame in which portrait will be swapped
	jump_speed     = "",       --	String value for jump prediction
	drowning_timer = function (self) return "" end,
	status_huds    = {},
}

local curr_data = rom.data

if curr_data.Leader_ptr ~= nil then
	local charidmap = {
		[curr_data.ObjID_Sonic]    = charids.sonic,
		[curr_data.ObjID_Tails]    = charids.tails,
		[curr_data.ObjID_Knuckles] = charids.knuckles,
		[curr_data.ObjID_Espio]    = charids.espio,
		[curr_data.ObjID_Charmy]   = charids.charmy,
		[curr_data.ObjID_Vector]   = charids.vector,
	}
	local portraitmap = {
		[curr_data.ObjID_Sonic]    = portraits.sonic,
		[curr_data.ObjID_Tails]    = portraits.tails,
		[curr_data.ObjID_Knuckles] = portraits.knuckles,
		[curr_data.ObjID_Espio]    = portraits.espio,
		[curr_data.ObjID_Charmy]   = portraits.charmy,
		[curr_data.ObjID_Vector]   = portraits.vector,
	}
	function Character:update_offset()
		self.offset = 0xff0000 + memory.readword(self.base_offset)
		local id = memory.readbyte(self.offset + curr_data.player_id)
		self.charid = charidmap[id]
		self.portraits = portraitmap[id]
	end
else
	function Character:update_offset()
		self.offset = self.base_offset
	end
end

function Character:get_slope()
	return string.format("%+5d", memory.readbytesigned(self.offset + curr_data.angle))
end

function Character:get_position()
	local xpospix   = memory.readword      (self.offset + curr_data.x_pos)
	local xpossub   = memory.readbyte      (self.offset + curr_data.x_sub)
	local ypospix   = memory.readwordsigned(self.offset + curr_data.y_pos)
	local ypossub   = memory.readbyte      (self.offset + curr_data.y_sub)
	return string.format("%5d:%-3d,%5d:%-3d", xpospix, xpossub, ypospix, ypossub)
end

function Character:get_speed()
	local xvel      = memory.readwordsigned(self.offset + curr_data.x_vel)
	local yvel      = memory.readwordsigned(self.offset + curr_data.y_vel)
	local speed     = memory.readwordsigned(self.offset + curr_data.inertia)
	return string.format("%+5d, %+5d, %+5d", xvel, yvel, speed)
end

function Character:get_ypos()
	return memory.readwordsigned(self.offset + curr_data.y_pos)
end

function Character:get_ysub()
	return memory.readbyte(self.offset + curr_data.y_sub)
end

function Character:get_yvel()
	return memory.readwordsigned(self.offset + curr_data.y_vel)
end

function Character:get_inertia()
	return memory.readwordsigned(self.offset + curr_data.inertia)
end

function Character:get_flags()
	return memory.readbyte(self.offset + curr_data.status)
end

function Character:get_dimensions()
	return memory.readbyte(self.offset + curr_data.y_radius), memory.readbyte(self.offset + curr_data.x_radius)
end

if rom:is_sonic3() or rom:is_sonick() or rom:is_scheroes() then
	function Character:hit_time_left()
		return memory.readbyte(self.offset + curr_data.invulnerable_time)
	end
else
	function Character:hit_time_left()
		return memory.readword(self.offset + curr_data.invulnerable_time)
	end
end

function Character:hit_timer()
	return string.format("%5d", self:hit_time_left())
end

if curr_data.Invincibility_time >= 0xff0000 then
	-- Raw RAM address
	function Character:stars_timer()
		return string.format("%5d", 8 * memory.readword(curr_data.Invincibility_time))
	end
elseif rom:is_sonic3() or rom:is_sonick() then
	function Character:stars_timer()
		return string.format("%5d", 8 * memory.readbyte(self.offset + curr_data.Invincibility_time) - game:get_level_frames() % 8)
	end
else
	function Character:stars_timer()
		return string.format("%5d", memory.readword(self.offset + curr_data.Invincibility_time))
	end
end

if curr_data.Speedshoes_time >= 0xff0000 then
	-- Raw RAM address
	function Character:shoes_timer()
		return string.format("%5d", 8 * memory.readword(curr_data.Speedshoes_time))
	end
elseif rom:is_sonic3() or rom:is_sonick() then
	function Character:shoes_timer()
		return string.format("%5d", 8 * memory.readbyte(self.offset + curr_data.Speedshoes_time) - game:get_level_frames() % 8)
	end
else
	function Character:shoes_timer()
		return string.format("%5d", memory.readword(self.offset + curr_data.Speedshoes_time))
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

if curr_data.status_secondary ~= nil then
	function Character:get_status()
		return memory.readbyte(self.offset + curr_data.status_secondary)
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
else
	if curr_data.Invincibility_active == nil then
		function Character:stars_active()
			return false
		end
	else
		function Character:stars_active()
			return memory.readbyte(curr_data.Invincibility_active) ~= 0
		end
	end

	if curr_data.Speedshoes_active == nil then
		function Character:shoes_active()
			return false
		end
	else
		function Character:shoes_active()
			return memory.readbyte(curr_data.Speedshoes_active) ~= 0
		end
	end

	if curr_data.Shield_active == nil then
		function Character:get_shield()
			return 0
		end
	else
		function Character:get_shield()
			return memory.readbyte(curr_data.Shield_active)
		end
	end
end

if curr_data.double_jump_data == nil then
	function Character:flight_time_left()
		return 0
	end
elseif rom:is_sonic1() then
	function Character:flight_time_left()
		return memory.readword(self.offset + curr_data.double_jump_data)
	end
else
	function Character:flight_time_left()
		local dec = 1 - AND(game:get_level_frames(), 1)
		return 2 * memory.readbyte(self.offset + curr_data.double_jump_data) - dec
	end
end

if curr_data.double_jump_data == nil then
	function Character:flight_value()
		return 0
	end
else
	function Character:flight_value()
		return memory.readbyte(self.offset + curr_data.double_jump_flag)
	end
end

function Character:can_fly()
	if self.charid == charids.tails then
		return rom.tails_flies
	elseif self.charid == charids.cream then
		return rom.cream_flies
	else
		return false
	end
end

function Character:flight_active()
	return self:can_fly() and self:flight_value() ~= 0 and self:flight_time_left() > 0
end

if curr_data.carry_delay == nil then
	function Character:flight_no_pickup_time_left()
		return 0
	end
elseif curr_data.carry_delay >= 0xff0000 then
	function Character:flight_no_pickup_time_left()
		return memory.readbyte(curr_data.carry_delay)
	end
else
	function Character:flight_no_pickup_time_left()
		return memory.readbyte(self.offset + curr_data.carry_delay)
	end
end

function Character:flight_boost_timer()
	-- Frames left in the boost counter
	local fval = 32 - self:flight_value()
	-- Vertical position
	local ypos = self:get_ypos()
	-- Vertical limit for flight
	local ylim = game:min_camera_y() + 0x10
	-- Above this position, Tails can't have negative vertical speed
	if ypos > ylim then
		-- Velocity
		local yvel = self:get_yvel()
		-- Predividing initial velocity by acceleration
		local vy_0 = -yvel / 32
		-- Distance, in subpixels, before Tails reaches the flight limit,
		-- predivided by absolute value of acceleration (we will only need
		-- the square of this term).
		local dy_0 = 2 * ((ylim - ypos) * 256 - self:get_ysub()) / 32
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

function Character:flight_timer()
	return string.format("%5d", self:flight_time_left())
end

function Character:flight_boosting()
	return self:can_fly() and self:flight_value() > 1 and self:get_yvel() >= -256
end

function Character:flight_no_pickup_timer()
	return string.format("%5d", self:flight_no_pickup_time_left())
end

function Character:flight_no_pickup_active()
	return self:can_fly() and self:flight_no_pickup_time_left() > 0
end

function Character:flight_icon()
	if self.charid == charids.tails then
		return "tails-flight"
	elseif self.charid == charids.cream then
		return "cream-flight"
	else
		return "blank"
	end
end

function Character:shield()
	local status = self:get_shield()
	for _, m in ipairs(game.shields) do
		if AND(status, BIT(m)) ~= 0 then
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

if curr_data.shield >= 0xff0000 then
	function Character:get_shield_object()
		return curr_data.shield
	end
else
	function Character:get_shield_object()
		return 0xff0000 + memory.readword(self.offset + curr_data.shield)
	end
end

if rom:is_sonic3() or rom:is_sonick() or rom:is_scheroes() then
	function Character:doing_instashield()
		return self.charid == charids.sonic and self:shield() == shieldids.no_shield and
			   game:super_status() ~= 1 and game:super_status() ~= -1 and
			   not self:stars_active() and
		       memory.readbyte(self.offset + curr_data.double_jump_flag) == 1
	end

	function Character:instashield_time()
		local shield = self:get_shield_object()
		return string.format("%5d", 15 - memory.readbyte(shield + curr_data.prev_anim) - memory.readbyte(shield + curr_data.anim_frame))
	end
else
	function Character:doing_instashield()
		return false
	end

	function Character:instashield_time()
		return 0
	end
end

if curr_data.top_speed >= 0xff0000 then
	function Character:get_top_speed()
		return memory.readword(curr_data.top_speed)
	end
else
	function Character:get_top_speed()
		return memory.readword(self.offset + curr_data.top_speed)
	end
end

if rom:is_sonic_cd() then
	--	Spindash and super peelout use essentially the same mechanism in SCD.
	function Character:spindash_time()
		return memory.readbyte(self.offset + curr_data.spindash_counter)
	end

	function Character:spindash_active()
		return self:spindash_time() ~= 0
	end

	function Character:spindash_charge()
		-- You can release it a frame earlier than this, but it will be slower.
		local max = (self:is_rolling() and (45-1)) or (30-1)
		local val = self:spindash_time()
		local sonicspd = self:get_top_speed()
		local absinertia = math.abs(self:get_inertia())
		local maxcharge = (Character:shoes_active() and (sonicspd * 3 / 2)) or (sonicspd * 2)
		return string.format("%s%3d%%", (val >= max and "Y") or "N", math.floor((100 * absinertia) / maxcharge))
	end

	function Character:is_peelout()
		return not self:is_rolling()
	end

	function Character:no_peelout_time()
		return AND(memory.readbyte(curr_data.Charge_Delay), 0xf)
	end

	function Character:no_peelout_active()
		return self.charid == charids.sonic and self:no_peelout_time() ~= 0
	end

	function Character:no_peelout_value()
		return string.format("%5d", 0x10 - self:no_peelout_time())
	end
else
	-- Standard spindash.
	function Character:spindash_active()
		return memory.readbytesigned(self.offset + curr_data.spindash_flag) ~= 0
	end

	function Character:is_peelout()
		return memory.readbytesigned(self.offset + curr_data.spindash_flag) < 0
	end

	function Character:spindash_charge()
		return string.format("%4d%%", SHIFT(100 * memory.readword(self.offset + curr_data.spindash_counter), 11))
	end

	function Character:no_peelout_active()
		return false
	end

	function Character:no_peelout_value()
		return ""
	end
end

if curr_data.dropdash_flag ~= nil then
	function Character:dropdash_active()
		return self.charid == charids.sonic and memory.readbyte(self.offset + curr_data.dropdash_flag) > 0
	end

	function Character:dropdash_timer()
		local timer = memory.readbytesigned(self.offset + curr_data.dropdash_delay)
		if timer < 0 then
			return "Ready"
		else
			return string.format("%5d", memory.readbytesigned(self.offset + curr_data.dropdash_delay) + 1)
		end
	end
else
	function Character:dropdash_active()
		return false
	end

	function Character:dropdash_timer()
		return string.format("%5d", 0)
	end
end

function Character:spindash_icon()
	return (self:is_peelout() and "sonic-peelout") or self.curr_set.spindash
end

function Character:wounded_icon()
	return self.curr_set.wounded
end

function Character:move_lock_timer()
	return memory.readword(self.offset + curr_data.move_lock)
end

function Character:move_lock_active()
	return self:move_lock_timer() > 0
end

function Character:move_lock_text()
	return string.format("%4d", self:move_lock_timer())
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

if curr_data.code ~= nil then
	function Character:in_game()
		return memory.readlong(self.offset + curr_data.code) ~= 0
	end
elseif curr_data.id ~= nil then
	function Character:in_game()
		return memory.readbyte(self.offset + curr_data.id) ~= 0
	end
else
	function Character:in_game()
		return false
	end
end

if curr_data.air_left >= 0xff0000 then
	function Character:get_drowning_seconds()
		return memory.readbyte(curr_data.air_left)
	end
else
	function Character:get_drowning_seconds()
		return memory.readbyte(self.offset + curr_data.air_left)
	end
end

if curr_data.bubbles ~= nil then
	function Character:get_drowning_frames()
		return memory.readword(0xff0000 + memory.readword(self.offset + curr_data.bubbles) + curr_data.air_frames)
	end
elseif curr_data.bubbles_P2 ~= nil then
	function Character:get_drowning_frames()
		--	Tails and Cream drown differently in S2, S3 and S3K, even if solo.
		if self.charid == charids.tails or self.charid == charids.cream then
			return memory.readword(curr_data.bubbles_P2 + curr_data.air_frames)
		else
			return memory.readword(curr_data.bubbles_P1 + curr_data.air_frames)
		end
	end
else
	function Character:get_drowning_frames()
		return memory.readword(curr_data.bubbles_P1 + curr_data.air_frames)
	end
end

function Character:drowning_timer()
	return string.format("%4d", 60 * self:get_drowning_seconds() + self:get_drowning_frames())
end

if curr_data.control_counter == nil then
	function Character:cputime_time_left()
		return 0
	end
elseif curr_data.control_counter >= 0xff0000 then
	function Character:cputime_time_left()
		return memory.readword(curr_data.control_counter)
	end
else
	function Character:cputime_time_left()
		return memory.readword(self.offset + curr_data.control_counter)
	end
end

function Character:cputime_active()
	local cputime = self:cputime_time_left()
	return cputime ~= 0 and cputime < 599
end

function Character:cputime_timer()
	return string.format("%3d", self:cputime_time_left())
end

if curr_data.respawn_counter == nil then
	function Character:despawn_time_left()
		return 0
	end
elseif curr_data.respawn_counter >= 0xff0000 then
	function Character:despawn_time_left()
		return memory.readword(curr_data.respawn_counter)
	end
else
	function Character:despawn_time_left()
		return memory.readword(self.offset + curr_data.respawn_counter)
	end
end

function Character:despawn_active()
	return self:despawn_time_left() ~= 0
end

function Character:despawn_timer()
	return string.format("%3d", 300 - self:despawn_time_left())
end

function Character:respawn_time_left()
	return (64 - AND(game:get_level_frames(), 0x3f)) % 64
end

if curr_data.CPU_routine ~= nil and curr_data.obj_control ~= nil then
	local status_mask;
	local obj_control_mask;
	if rom:is_sonic2() then
		status_mask = 0xd2
		obj_control_mask = 0xff
	else
		status_mask = 0x80
		obj_control_mask = 0x80
	end

	if curr_data.CPU_routine >= 0xff0000 then
		function Character:get_CPU_routine()
			return memory.readword(curr_data.CPU_routine)
		end
	else
		function Character:get_CPU_routine()
			return memory.readword(self.offset + curr_data.CPU_routine)
		end
	end

	if rom:is_scheroes() then
		function Character:respawn_active()
			if self:get_CPU_routine() == 2 then
				local leader_ptr = 0xff0000 + memory.readword(curr_data.Leader_ptr)
				return self:respawn_time_left() ~= 0
					   and AND(memory.readbytesigned(leader_ptr + curr_data.obj_control), obj_control_mask) == 0
					   and AND(memory.readbyte(leader_ptr + curr_data.status), status_mask) == 0
			end
			return false
		end
	else
		function Character:respawn_active()
			if self:get_CPU_routine() == 2 then
				return self:respawn_time_left() ~= 0
					   and AND(memory.readbytesigned(curr_data.Player1 + curr_data.obj_control), obj_control_mask) == 0
					   and AND(memory.readbyte(curr_data.Player1 + curr_data.status), status_mask) == 0
			end
			return false
		end
	end
else
	function Character:respawn_active()
		return false
	end
end

function Character:respawn_timer()
	return string.format("%3d", self:respawn_time_left())
end

function Character:init(id, index, port)
	self.charid      = id
	self.is_p1       = index == 0

	--	Character offsets
	local player_offsets = {
		[0] = curr_data.Player1 or curr_data.Leader_ptr,
		[1] = curr_data.Player2 or curr_data.Sidekick1_ptr,
		[2] = curr_data.Player3 or curr_data.Sidekick2_ptr,
	}

	self.base_offset  = player_offsets[index]
	self:update_offset()

	self.portraits   = port
	self.curr_set    = port.normal
	self.curr_face   = false
	self.super_frame = 0
	self.jump_speed  = ""

	if self.charid == charids.tails or self.charid == charids.cream then
		--	You can hack Tails in Sonic & Knuckles, so lets leave him here.
		-- For Cream, just copying Tails stuff.
		self.swap_delay  = 4
		self.super_pal   = 0xfff668
		self.super_swap  = 0xfff669
	else
		self.swap_delay  = (rom:is_sonic2() and 2) or 3
		self.super_pal   = 0xfff65d
		self.super_swap  = 0xfff65e
	end

	--	This manufactures a HUD icon monitor given the adequate functions.
	--	'Icon' can be either a function or a gdimage.
	local function Create_HUD(this, active_fun, timer_fun, icon)
		local cond = Conditional_widget:new(0, 0, false, active_fun, this)
		local hud  = Frame_widget:new(0, 0, 42, 17)
		if type(icon) == "function" then
			icon = bind(icon, this)
		end
		hud:add_status_icon(2, 2, icon, bind(timer_fun, this))
		cond:add(hud, 0, 0)

		return cond
	end

	--	Here we generate the list of status monitor icons for each character, starting with
	--	the common icons. To add new ones, just copy and modify accordingly.
	self.status_huds = {
		Create_HUD(self, self.spindash_active  , self.spindash_charge , self.spindash_icon),
		Create_HUD(self, self.dropdash_active  , self.dropdash_timer  , self.spindash_icon),
		Create_HUD(self, self.hit_active       , self.hit_timer       , self.wounded_icon ),
	}

	table.insert(self.status_huds, 1,
		Create_HUD(self, self.doing_instashield      , self.instashield_time      , "sonic-instashield"))
	table.insert(self.status_huds, 1,
		Create_HUD(self, self.no_peelout_active      , self.no_peelout_value      , "sonic-no-peelout" ))
	table.insert(self.status_huds, 1,
		Create_HUD(self, self.flight_no_pickup_active, self.flight_no_pickup_timer, "tails-flight-no-pickup"))
	table.insert(self.status_huds, 1,
		Create_HUD(self, self.flight_active          , self.flight_timer          , self.flight_icon))
	table.insert(self.status_huds, 1,
		Create_HUD(self, self.flight_boosting        , self.flight_boost_timer    , "flight-boost"  ))

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
	end
end

function Character:construct(id, index, port)
	self:init(id, index, port)
	return self
end


--------------------------------------------------------------------------------
--	Initializer for the character objects.
--------------------------------------------------------------------------------
characters = nil

--	Set character data
local portrait_data = {
	[charids.sonic   ] = portraits.sonic,
	[charids.tails   ] = portraits.tails,
	[charids.knuckles] = portraits.knuckles,
	[charids.amy_rose] = portraits.amy_rose,
	[charids.charmy  ] = portraits.charmy,
	[charids.bunnie  ] = portraits.bunnie,
	[charids.espio   ] = portraits.sonic,		-- TODO: Fix this
	[charids.vector  ] = portraits.knuckles,	-- TODO: Fix this
}

function set_chardata(selchar)
	game.curr_char   = selchar
	characters = {}
	for i, char in ipairs(selchar) do
		table.insert(characters, Character:new(char, i - 1, portrait_data[char]))
	end
end
