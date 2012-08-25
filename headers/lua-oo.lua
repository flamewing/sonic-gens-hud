-------------------------------------------------------------------------------
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

--	From http://code.google.com/p/mangos-luascript/source/browse/trunk/src/bindings/luascript/lua-scripts/LuaScript/Mango/Mango.Utils.lua?spec=svn61&r=61
function ShallowCopy(fromTable, toTable)
	toTable = toTable or {} -- new table if not given
	local inx = nil
	local val = nil
	repeat
		inx, val = next(fromTable, inx)
		if val then toTable[inx] = val end
	until (inx == nil)
	return toTable
end

