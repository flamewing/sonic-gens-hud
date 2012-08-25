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
--	Character HUD widget.
--	Written by: Marzo Junior
-------------------------------------------------------------------------------

require("headers/lua-oo")
require("headers/widgets")
require("sonic/common/hud-images")
require("sonic/common/enums")
require("sonic/common/game-info")
require("sonic/common/char-info")

--	Character HUD object.
Character_hud = {
	character = nil,
}

local shield_icons = {[shieldids.no_shield]        = ui_icons.blank,
                      [shieldids.normal_shield]    = ui_icons.shield_normal,
                      [shieldids.flame_shield]     = ui_icons.shield_flame,
                      [shieldids.lightning_shield] = ui_icons.shield_lightning,
                      [shieldids.bubble_shield]    = ui_icons.shield_bubble}

function Character_hud.create(char, x, y, active)
	local self = Container_widget.Create(x, y, active)
	self = ShallowCopy(Character_hud, self)
	self.character = char

	local pad = (char.is_p1 and 15) or 1
	local char_hud = Frame_widget.Create(8, 0, 115 + pad, 35)

	self:add_toggle(make_toggle(35, false, Container_widget.toggled, self, active), (char.is_p1 and 0) or 118 + pad, 0)
	char_hud:add(Icon_widget.Create(0, 0, char.get_face, char), 2, 2)
	if char.is_p1 then
		Text_widget.Create(x, y, text, obj, border, fill)
		char_hud:add(Text_widget.Create(0, 0, game.get_lives, game), 20, 2)
		char_hud:add(Text_widget.Create(0, 0, game.get_continues, game), 20, 9)
		char_hud:add(Icon_widget.Create(0, 0,
				function(char)
					return shield_icons[char:shield()]
				end,
				char ), 2, 20)
	else
		pad = 0
		char_hud:add(Icon_widget.Create   (0, 0,
				function(char)
					return (game:cputime_time_left() == 0 and ui_icons.cpu_2p) or ui_icons.tails_player
				end,
				char ), 2, 20)
	end
	--	Position
	char_hud:add(Icon_widget.Create(0, 0, ui_icons.location      ), 21 + pad, 2)
	char_hud:add(Text_widget.Create(0, 0, char.get_position, char), 36 + pad, 2)

	--	Speed
	char_hud:add(Icon_widget.Create(0, 0, ui_icons.speed         ), 21 + pad, 13)
	char_hud:add(Text_widget.Create(0, 0, char.get_speed   , char), 36 + pad, 10)

	--	Jump prediction
	char_hud:add(Text_widget.Create(0, 0,
			function(char)
				if want_prediction() then
					return char.jump_speed
				else
					return ""
				end
			end,
			char), 36 + pad, 17)

	--	Angle
	char_hud:add(Icon_widget.Create(0, 0, ui_icons.angle      ), 21 + pad, 24)
	char_hud:add(Text_widget.Create(0, 0, char.get_slope, char), 36 + pad, 26)
	
	--	Move lock
	local cond = Conditional_widget.Create(0, 0, true, Character.move_lock_active, char)
	cond:add(Icon_widget.Create(0, 0, ui_icons.move_lock       ),  0, 0)
	cond:add(Text_widget.Create(0, 0, char.move_lock_text, char), 15, 2)
	char_hud:add(cond, 77 + pad, 24)

	self:add(char_hud, 3, 0)

	return self
end

