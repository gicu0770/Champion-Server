-- Core API functions implemented in Lua
dofile('data/lib/core/core.lua')

-- Compatibility library for our old Lua API
dofile('data/lib/compat/compat.lua')
dofile('data/lib/json.lua')
serpent = dofile('data/lib/serpent.lua')
dofile('data/lib/modalwindow.lua')
--dofile('data/lib/core/attributes.lua')
-- Debugging helper function for Lua developers
dofile('data/lib/debugging/dump.lua')
dofile('data/lib/debugging/lua_version.lua')
dofile('data/lib/modalwindow.lua')
-- Quests library
dofile('data/lib/quests/quest.lua')
--Metin lib
--	dofile('data/lib/metin.lua')
--xikiniCustomFunctions
dofile('data/lib/core/xikiniCustomFunctions&Libs.lua')


function Combat.setCallbackFunction(self, event, callback)
  temporaryGlobalCallbackFunction = loadstring(string.dump(callback))
  self:setCallback(event, "temporaryGlobalCallbackFunction")
end