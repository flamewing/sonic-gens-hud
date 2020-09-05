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
--	Replacement xxx.register functions.
--	Currently supports the following:
--		gens.registerbefore
--		gens.registerafter
--		gens.registerexit
--		gens.registerstart
--		savestate.registerload
--		savestate.registersave
--		gui.register
--------------------------------------------------------------------------------

require("headers/lua-oo")

callback = class{
	callbacks = {},
	nonrecursive = false,
	in_call = false,
	redraw = false,
}

function callback:call()
	if self.nonrecursive and self.in_call then
		return
	end
	self.in_call = true
	for _,callfun in pairs(self.callbacks) do
		callfun()
	end
	if self.redraw then
		gens.redraw()
	end
	self.in_call = false
end

function callback:remove(fun)
	for id,callfun in pairs(self.callbacks) do
		if callfun == fun then
			table.remove(self.callbacks, id)
			return
		end
	end
end

function callback:add(fun)
	assert_function(fun)
	self:remove(fun);
	table.insert(self.callbacks, fun)
end

--	Create widget and set position.
function callback:construct(registerfunc, nonrec, redraw)
	assert_function(registerfunc)
	self.callbacks = {}
	self.nonrecursive = nonrec or false
	self.in_call = false
	self.redraw = redraw
	registerfunc(function() self:call() end)
	return self
end

callbacks = {
	gens = {
		registerbefore = callback:new(gens.registerbefore   , true, false),
		registerafter  = callback:new(gens.registerafter    , true, false),
		registerexit   = callback:new(gens.registerexit     , true, false),
		registerstart  = callback:new(gens.registerstart    , true, false),
	},
	savestate = {
		registerload   = callback:new(savestate.registerload, true, false),
		registersave   = callback:new(savestate.registersave, true, false),
	},
	gui = {
		register       = callback:new(gui.register          , true, true ),
	},
}

