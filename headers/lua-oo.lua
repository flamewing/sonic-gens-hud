--------------------------------------------------------------------------------
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

--	Based on code from http://lua-users.org/wiki/InheritanceTutorial
function class(prototype)
	local new_class = prototype or {}
	local class_mt = {__index = new_class}

	function new_class.new(self, ...)
		local newinst = {}
		setmetatable(newinst, class_mt)
		if newinst.construct then
			newinst:construct(unpack(arg))
			assert(self["@super_chain@"] == nil or self["@super_chain@"].construct == nil,
			       debug.traceback("Error: A constructor in the class hierarchy does not call self:super([args])."))
		end
		return newinst
	end

	function new_class:extends(baseClass)
		setmetatable(self, {__index = baseClass})

		-- Return the super class object of the instance
		function new_class:superClass()
			return baseClass
		end

		function new_class.super(self_, ...)
			local super = self_["@super_chain@"] or baseClass
			self_["@super_chain@"] = super:superClass()
			assert(super.construct ~= nil, debug.traceback("Error: self:super([args]) called on class whose base class does not define a constructor."))
			return super.construct(self_, unpack(arg))
		end

		return self
	end

	-- Return the class object of the instance
	function new_class:class()
		return new_class
	end

	-- Return the super class object of the instance
	function new_class:superClass()
		return nil
	end

	-- Return true if the caller is an instance of theClass
	function new_class:isa(theClass)
		local b_isa = false
		local cur_class = new_class

		while (cur_class ~= nil) and (b_isa == false) do
			if cur_class == theClass then
				b_isa = true
			else
				cur_class = cur_class:superClass()
			end
		end
		return b_isa
	end
	return new_class
end

--	Static assertion function for debugging purposes.
function assert_function(fun)
	local ty = type(fun)
	assert(ty == "function", debug.traceback(string.format("Error: Function expected for variable 'fun', got '" .. ty .. "'.")))
end

-- Binds an argument to a function
function bind(f, arg)
	-- Debugging, disabled for now.
	--assert(f ~= nil, debug.traceback("Error: Binding nil function."))
	--assert(f ~= nil and type(f) == "function", debug.traceback("Error: Binding non-function."))
	return function () return f(arg) end
end

