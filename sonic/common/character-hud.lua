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
	local char_hud = Frame_widget:new(0, 0, 99, 51)

	self:add_toggle(make_toggle(99, true, Container_widget.toggled, self, active), 0, 52)
	char_hud:add(Icon_widget:new(0, 0, bind(char.get_face, char)), 2, 2)
	if char.is_p1 then
		char_hud:add(Text_widget:new(0, 0, bind(game.get_lives, game)), 20, 2)
		if game.get_continues ~= nil then
			char_hud:add(Text_widget:new(0, 0, bind(game.get_continues, game)), 20, 9)
		end
	else
		char_hud:add(Icon_widget:new(0, 0,
		function()
			return (game:cputime_time_left() == 0 and "cpu-2p") or "tails-player"
		end), 79, 2)
		pad = 0
	end
	char_hud:add(Icon_widget:new(0, 0,
			function()
				return shield_icons[char:shield()]
			end) , 20 + pad, 2)
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

