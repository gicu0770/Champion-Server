local bossName = "Voort"
local arenaPosition = Position(422, 1260, 7) -- Przykładowa pozycja areny, dostosuj do swojej mapy
local playerPosition = Position(411, 1260, 7)
local bossPosition = Position(430,1260, 7)

function onStepIn(creature, item, position, fromPosition)
if creature:isPlayer() then
	if item then
		if item.actionid == 37282 then
		    -- Sprawdź, czy na arenie znajduje się już gracz
			local creatures = Game.getSpectators(arenaPosition, false, false, 15, 15, 15, 15)
			for _, creature in pairs(creatures) do
				if creature:isPlayer() then
					player:sendTextMessage(MESSAGE_INFO_DESCR, "The arena is already occupied by another player!")
					player:teleportTo(fromPosition)
					return false
				end
			end
		
			-- Sprawdź, czy na arenie znajduje się już boss
			for _, creature in pairs(creatures) do
				if creature:getName() == bossName then
					creature:remove() -- Usuń poprzedniego bossa
				end
			end
		
			-- Stwórz nowego bossa
			local boss = Game.createMonster(bossName, bossPosition)
			if boss then
				boss:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Voort, has been summoned!")
				player:teleportTo(playerPosition)
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Failed to summon the boss.")
			end
		end
	end
end
	return true
end