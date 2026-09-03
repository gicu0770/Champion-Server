function onModalWindow(player, modalWindowId, buttonId, choiceId)
    player:unregisterEvent("ModalWindow_Tutorial")
	player:unregisterEvent("ModalWindow_Third_Promotion")
	local class = {
		[1] = "Assassin",
		[2] = "Colossus",
		[3] = "Cryomancer", 
		[4] = "Saint",
		[5] = "Shaman",
		[6] = "Slayer",
		[7] = "Soulblade",
		[8] = "Stormcaller",
		[9] = "Venomstorm",
		[10] = "Inquisitor",
		[11] = "Marksman",
		[12] = "Pyromancer",
	  }
	  local name = {
		[1] = "Sorcerer",
		[2] = "Druid",
		[3] = "Archer",
		[4] = "Knight",
		[17] = "Paladin",
		[21] = "Shadow",
	  }
    if modalWindowId == 1005 then
     if buttonId == 100 and player:getStorageValue(999997) <= 0 then
	  player:setStorageValue(999997, choiceId)
	  player:popupFYI("You chose [ "..class[choiceId].." ] Sub-Class!.\nYou can now use Sub-Class Skill Tree.")
	  player:sendCurrentTreeData()
	  else
	  player:popupFYI("You already have a Sub-Class.")
     end
    end
	if modalWindowId == 1006 then
		if buttonId == 101 then
			return false
		end
		if buttonId == 100 and player:getStorageValue(PlayerStorage.secondTrait) < 0 then
			player:setStorageValue(PlayerStorage.secondTrait, choiceId)
			player:popupFYI("You chose talents [ " ..name[choiceId] .. " ] tree.\nYou can now use Vocation Trait of this class.")
			if choiceId == 3 then
				player:addBuff(ARCHER_TRAIT)
				player:setBuffStacks(ARCHER_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			elseif choiceId == 1 then
				player:addBuff(SORCERER_TRAIT)
				player:setBuffStacks(SORCERER_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			elseif choiceId == 2 then
				player:addBuff(DRUID_TRAIT)
				player:setBuffStacks(DRUID_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			elseif choiceId == 17 then
				player:addBuff(PALADIN_TRAIT)
				player:setBuffStacks(PALADIN_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			elseif choiceId == 4 then
				player:addBuff(KNIGHT_TRAIT)
				player:setBuffStacks(KNIGHT_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			elseif choiceId == 21 then
				player:addBuff(SHADOW_TRAIT)
				player:setBuffStacks(SHADOW_TRAIT, player:getStorageValue(PlayerStorage.reborn) + 1)
			end

			local traits = {
			{ check = function(p) return p:isArcher() end, id = 3, buff = ARCHER_TRAIT },
			{ check = function(p) return p:isSorcerer() end, id = 1, buff = SORCERER_TRAIT },
			{ check = function(p) return p:isDruid() end, id = 2, buff = DRUID_TRAIT },
			{ check = function(p) return p:isPaladin() end, id = 17, buff = PALADIN_TRAIT },
			{ check = function(p) return p:isKnight() end, id = 4, buff = KNIGHT_TRAIT },
			{ check = function(p) return p:isShadow() end, id = 21, buff = SHADOW_TRAIT }
		}

		for _, trait in ipairs(traits) do
			if trait.check(player) or player:getStorageValue(PlayerStorage.secondTrait) == trait.id then
				player:addBuff(trait.buff)
				player:setBuffStacks(trait.buff, player:getStorageValue(PlayerStorage.reborn) + 1)
			end
		end

		else
			player:popupFYI("You already have a second Vocation Trait.")
		end
	end

	if modalWindowId == 1050 then
		player:unregisterEvent("ModalWindow_PotionUpgrade")
		if buttonId == 100 then
			upgradePotionForPlayer(player)
		end
		return true
	end
end