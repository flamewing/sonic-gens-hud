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
--	Character HUD widget.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

require("headers/lua-oo")
require("headers/widgets")
require("sonic/common/enums")
require("sonic/common/game-info")
require("sonic/common/char-info")

--------------------------------------------------------------------------------
--	Character HUD object.
--------------------------------------------------------------------------------
Character_hud = class{
	character = charids.sonic,
}:extends(Container_widget)

local shield_icons = {[shieldids.no_shield]        = "blank",
                      [shieldids.normal_shield]    = "shield-normal",
                      [shieldids.flame_shield]     = "shield-flame",
                      [shieldids.lightning_shield] = "shield-lightning",
                      [shieldids.bubble_shield]    = "shield-bubble"}

function Character_hud:construct(char, x, y, active)
	self:super(x, y, active)
	self.character = char

	local pad = (char.is_p1 and 15) or 1
	local char_hud = Frame_widget:new(0, 0, (char.is_p1 and 99) or 101, 51)

	if char.is_p1 then
		self:add_toggle(make_toggle(51, false, Container_widget.toggled, self, active), -3, 0)
	else
		self:add_toggle(make_toggle(51, false, Container_widget.toggled, self, active), 102, 0)
	end
	char_hud:add(Icon_widget:new(0, 0, bind(char.get_face, char)), 2, 2)
	if char.is_p1 then
		local lives_delta = (game.get_continues == nil and 4) or 0
		char_hud:add(Text_widget:new(0, 0, bind(game.get_lives, game)), 20, 2 + lives_delta)
		if game.get_continues ~= nil then
			char_hud:add(Text_widget:new(0, 0, bind(game.get_continues, game)), 20, 9)
		end
	else
		char_hud:add(Icon_widget:new(0, 0,
		function()
			return (char:cputime_time_left() == 0 and "cpu-2p") or "tails-player"
		end), 79, 2)
		pad = 0
	end

	char_hud:add(Icon_widget:new(0, 0,
	function()
		return shield_icons[char:shield()]
	end) , 20 + pad, 2)

	-- Drowning timer
	local drown = Conditional_widget:new(0, 0, false, char.is_drowning, char)
	drown:add(Icon_widget:new(0, 0, "bubbles"), 0, 0)
	drown:add(Text_widget:new(0, 0, bind(char.drowning_timer, char), {0, 0, 0, 255}), 1, 10)
	char_hud:add(drown, 40 + pad, 2)

	if not char.is_p1 then
		-- CPU Despawn timer
		local despawn = Conditional_widget:new(0, 0, false, char.despawn_active, char)
		despawn:add(Icon_widget:new(0, 0, bind(char.get_face, char)), 0, 0)
		despawn:add(Icon_widget:new(0, 0, "forbidden"), 0, 0)
		despawn:add(Text_widget:new(0, 0, bind(char.despawn_timer, char), {0, 0, 0, 255}), 3, 10)
		char_hud:add(despawn, 60 + pad, 2)

		-- CPU Respawn timer
		local respawn = Conditional_widget:new(0, 0, false, char.respawn_active, char)
		respawn:add(Icon_widget:new(0, 0, bind(char.get_face, char)), 0, 0)
		respawn:add(Text_widget:new(0, 0, bind(char.respawn_timer, char), {0, 0, 0, 255}), 3, 10)
		char_hud:add(respawn, 60 + pad, 2)

		-- CPU control timer
		local cpuctrl = Conditional_widget:new(0, 0, false, char.cputime_active, char)
		cpuctrl:add(Text_widget:new(0, 0, bind(char.cputime_timer, char), {0, 0, 0, 255}), 3, 10)
		char_hud:add(cpuctrl, 79 + pad, 2)
	end

	--	Position
	char_hud:add(Icon_widget:new(0, 0, "location"                   ),  4, 20)
	char_hud:add(Text_widget:new(0, 0, bind(char.get_position, char)), 20, 20)

	--	Speed
	char_hud:add(Icon_widget:new(0, 0, "speed"                      ),  4, 31)
	char_hud:add(Text_widget:new(0, 0, bind(char.get_speed   , char)), 20, 28)

	--	Jump prediction
	char_hud:add(Text_widget:new(0, 0,
			function()
				if want_prediction() then
					return char.jump_speed
				else
					return ""
				end
			end), 20, 35)

	--	Angle
	char_hud:add(Icon_widget:new(0, 0, "angle"                   ),  4, 42)
	char_hud:add(Text_widget:new(0, 0, bind(char.get_slope, char)), 20, 44)

	--	Move lock
	local cond = Conditional_widget:new(0, 0, true, Character.move_lock_active, char)
	cond:add(Icon_widget:new(0, 0, "move-lock"                    ),  0, 0)
	cond:add(Text_widget:new(0, 0, bind(char.move_lock_text, char)), 20, 2)
	char_hud:add(cond, 59, 42)

	self:add(char_hud, 0, 0)

	return self
end

--------------------------------------------------------------------------------
--	Level bounds class
--------------------------------------------------------------------------------
Level_bounds = class{
	border   = {0, 0, 127, 255},
}:extends(widget)

--	Also draws the contained widgets.
function Level_bounds:draw()
	self.character:update_offset()
	local w, h = self.character:get_dimensions()
	local l, r, t, b = game:get_camera_rect()
	local dl, dr, dw, dh = game:bounds_deltas()
	if game:extend_screen_bounds() then
		r = r + dw
	end
	gui.box(l + dl - w, t - h, r + w + dr, b + h + dh, {0, 0, 0, 0}, self.border)
	return true
end

function Level_bounds:construct(char, border)
	self:super(0, 0)
	self.character = char
	self.border = border or {0, 0, 127, 255}
	return self
end

