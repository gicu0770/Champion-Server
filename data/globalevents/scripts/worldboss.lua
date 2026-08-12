function onTime(interval, lastExecution)
local bossName = "Gorn"
local bossLifeTime =  10 * 60 * 1000 -- 10min
local bossPosition = Position(579, 1071, 7)
local portalPosition = Position(674, 1038, 7)
local portalDestination = Position(579, 1071, 7)
local countdownTime = 5 * 60 -- 1min
    local function sendToAllPlayers(msg)
        for _, player in ipairs(Game.getPlayers()) do
            player:sendExtendedOpcode(71, json.encode({text = msg, color = "#f7ef8a"}))
        end
    end
    local function remove(pos)
        local item = Tile(pos):getItemById(28293)
        if item then
            item:remove()
        end
    end
	local function removeBossAfterDelay(id)
		addEvent(function()
			local boss = Creature(id)
			if boss and boss:isMonster() and not boss:isRemoved() then
				boss:remove()
				for _, player in ipairs(Game.getPlayers()) do
					player:sendExtendedOpcode(71, json.encode({text = "The {"..bossName.."} has been defeated by the gods!", color = "#f7ef8a"}))
				end
			end
		end, bossLifeTime)
	end
	local function createBoss(pos)
		local boss = Game.createMonster(bossName, pos, false, true)
		if boss then
			local totalLevel = 0
			for _, targetPlayer in ipairs(Game.getPlayers()) do
				totalLevel = totalLevel + targetPlayer:getLevel()
			end
			local HP = boss:getMaxHealth() + (10000 * totalLevel)
			boss:setMaxHealth(HP)
			boss:setHealth(boss:getMaxHealth())
			for _, targetPlayer in ipairs(Game.getPlayers()) do
				targetPlayer:sendExtendedOpcode(71, json.encode({text = "The {"..bossName.."} has come to our world! You have {10min} to destroy him!", color = "#f7ef8a"}))
			end
			removeBossAfterDelay(boss:getId()) -- Dodajemy automatyczne usuwanie bossa po 5 sekundach
		end
	end
    local teleport = Game.createItem(28293, -1, portalPosition)
    Teleport(teleport.uid):setDestination(portalDestination)
	--[[
    addEvent(remove, countdownTime * 1000, portalPosition)
	for i = 1, countdownTime do
		local timeEE = countdownTime - i
		addEvent(function (portalPosition) Game.sendAnimatedText(""..timeEE.."", portalPosition, 205) end, i * 1000, portalPosition)
	end
	--]]
WORLDBOSS_PORTAL_WIDGET = {
	{
		pos = createTP,
		id = 3,
		data = {
			"2",                                         -- | RARITY |
			"World Boss Portal",                     -- | NAME |
		}
	},
}
	tile = Tile(portalPosition.x, portalPosition.y - 1, portalPosition.z)
	if tile then
		WORLDBOSS_PORTAL_WIDGET[1].data[3] = os.time() + math.ceil(countdownTime)
		tile:setWidget(WORLDBOSS_PORTAL_WIDGET[1].id, WORLDBOSS_PORTAL_WIDGET[1].data)
	end
	addEvent(function()
		local item = Tile(portalPosition):getItemById(28293)
		portalPosition.y = portalPosition.y - 1
		if item then
			item:remove()
			if Tile(portalPosition) then
				Tile(portalPosition):removeWidget()
			end
		end
	end, countdownTime * 1000)
    -- Countdown messages
	sendToAllPlayers("The {"..bossName.."} Boss coming to Desert Arena! Teleport will be available for {5} minutes.")
	for i = 1, countdownTime / 60 - 1 do
		addEvent(function()
			sendToAllPlayers("The {"..bossName.."} Boss coming to Desert Arena! Teleport will be available for {"..(countdownTime/60 - i).."} minutes.")
		end, i * 60 * 1000)
	end

	addEvent(createBoss, countdownTime * 1000, bossPosition)
	return true
end