
local bossConfig = {
	[27575] = {
		portalTP = false,
		name = "Blood Fury",
		dungeonName = "Bloodfall Arena",
		promotionStorage = PlayerStorage.promotionBoss7,
		taskStorage = 801121,
		taskName = "Prism Beast",
		teleportPos = Position(674, 1024, 7)
	},
	[27561] = {
		portalTP = true,
		name = "Voort",
		dungeonName = "Firecastle Ruins",
		minLevel = 90,
		promotionStorage = PlayerStorage.promotionBoss5,
		taskStorage = 801119,
		taskName = "Thornroot",
		teleportPos = Position(398, 835, 7)
	},
	[27570] = {
		portalTP = true,
		name = "Yeti",
		dungeonName = "Frostbound",
		promotionStorage = PlayerStorage.promotionBoss4,
		taskStorage = 801118,
		taskName = "Yeti",
		teleportPos = Position(274, 1271, 7)
	},
	[27571] = {
		portalTP = true,
		name = "Grimdelver",
		dungeonName = "Wildwood",
		promotionStorage = PlayerStorage.promotionBoss3,
		taskStorage = 801117,
		taskName = "Grimdelver",
		teleportPos = Position(826, 1204, 7)
	},
	[27572] = {
		portalTP = true,
		name = "Rotburrow",
		dungeonName = "Otherworld",
		promotionStorage = PlayerStorage.promotionBoss2,
		taskStorage = 801116,
		taskName = "Rotburrow",
		teleportPos = Position(1007, 900, 7)
	},
	[27573] = {
		portalTP = true,
		name = "Lava Golem",
		dungeonName = "Molten Core",
		promotionStorage = PlayerStorage.promotionBoss1,
		taskStorage = 801115,
		taskName = "Lava Golem",
		teleportPos = Position(837, 922, 7)
	},
	[27574] = {
		portalTP = false,
		name = "Forest Keeper",
		dungeonName = "Toxic Arena",
		promotionStorage = PlayerStorage.promotionBoss6,
		taskStorage = PlayerStorage.specialization,
		taskName = "Sandfang",
		teleportPos = Position(1053, 509, 7)
	}
}

function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return true
	end
	local config = bossConfig[item.actionid]
	if not config then
		return true
	end
	if config.minLevel and creature:getLevel() < config.minLevel then
		creature:teleportTo(fromPosition)
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "Your level is too low, required " .. config.minLevel .. " or higher.")
		return false
	end
	if creature:getStorageValue(config.promotionStorage) < 0 then -- Wymaganie ukoczenia Taska
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "You need to finish " .. config.taskName .. " task.")
		creature:teleportTo(fromPosition)
		return false
	elseif creature:getStorageValue(config.promotionStorage) > 0 and creature:getStorageValue(config.taskStorage) < 0 then -- Majac taska mozna wejsc na Dunga
		creature:onForceJoinQueue(config.dungeonName)
		return true
	elseif config.portalTP and creature:getStorageValue(config.taskStorage) < 0 then -- Maja ten storage ozancza ze zabiles bosa i mozesz uzywac portalu
		creature:teleportTo(fromPosition)
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "You need to defeat the " .. config.name .. " boss to use the portal.")	
		return true
	else
		creature:teleportTo(config.teleportPos)
	end
	return true
end
--[[
function onStepIn(creature, item, position, fromPosition)
if creature:isPlayer() then
	if item then
		if item.actionid == 27561 then
			if creature:getLevel() < 95 then creature:teleportTo(fromPosition) creature:sendTextMessage(MESSAGE_INFO_DESCR, "Your level is too low, required 95 or higher.") return false end
			-- Sprawdź, czy na arenie znajduje się już gracz
			local occupied = false
			local creatures = Game.getSpectators(arenaPosition, false, false, 15, 15, 15, 15)
			for _, inRoom in pairs(creatures) do
				if inRoom:isPlayer() then
				--	inRoom:sendTextMessage(MESSAGE_INFO_DESCR, "The arena is already occupied by another player!")
					occupied = true
				end
			end
			if creature:getStorageValue(PlayerStorage.endGame) > 0 then
				creature:teleportTo(Position(399, 835, 7))
				return false
			end
			if occupied then creature:teleportTo(fromPosition) creature:sendTextMessage(MESSAGE_INFO_DESCR, "The arena is already occupied by another player!") return false end
			-- Sprawdź, czy na arenie znajduje się już boss
			for _, boss in pairs(creatures) do
				if boss:getName() == bossName then
					boss:remove() -- Usuń poprzedniego bossa
				end
			end

			-- Stwórz nowego bossa
			local boss = Game.createMonster(bossName, bossPosition)
			if boss then
				boss:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					boss:setMaxHealth(15000000)
					boss:setHealth(15000000)
					boss:getPosition():sendMagicEffect(50)
					boss:registerEvent("voort_death_hp")
					boss:registerEvent("voort_death")
					boss:registerEvent("SpellHealthChangeEvent")
					boss:registerEvent("UpgradeSystemHealth")
					boss:registerEvent("UpgradeSystemMana")
					boss:registerEvent("UpgradeSystemKill")
					boss:registerEvent("EliteAffixHP")
					boss:registerEvent("EliteAffixMANA")
					boss:registerEvent("UpgradeSystemDeath")
					boss:registerEvent("TaskDeath")
					boss:setMonsterLevel(120)
					boss:setAura(2169, 120)
					local outfit = boss:getOutfit()
					outfit.lookHealthBar = 3
					boss:setOutfit(outfit)
				creature:sendTextMessage(MESSAGE_INFO_DESCR, "Voort, has been summoned!")
				creature:teleportTo(playerPosition)
				creature:setStorageValue(PlayerStorage.portalVoort, 1)
			else
				creature:sendTextMessage(MESSAGE_INFO_DESCR, "Failed to summon the boss.")
			end
		end
	end
end
	return true
end
--]]