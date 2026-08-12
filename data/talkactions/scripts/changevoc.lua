function onSay(player, words, param)
	if player:getItemCount(36596) < 1 then
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return not player:sendTextMessage(MESSAGE_EVENT_ADVANCE,"You dont have change vocation item.")
    end
	local split = param:split(",")
	if split[1] == nil then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,"Choose vocation.\nIf you are after reborn dont worry system set proper vocation!\n.[Knight, Archer, Druid, Sorcerer, Shadow or Paladin]")
		return false
	end
	--	local vocation = tostring(param)
		if param == "knight" or param == "Knight" then
			local reborn = (player:getStorageValue(707070) + 1)
			player:setVocation(4 + (reborn * 4))
			player:getPosition():sendMagicEffect(50)
			local vocName = player:getVocation():getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
			player:remove()
		end
		if param == "archer" or param == "Archer" then
			local reborn = (player:getStorageValue(707070) + 1)
			player:setVocation(3 + (reborn * 4))
			player:getPosition():sendMagicEffect(50)
			local vocName = player:getVocation():getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
			player:remove()
		end
		if param == "sorcerer" or param == "Sorcerer" then
			local reborn = (player:getStorageValue(707070) + 1)
			player:setVocation(1 + (reborn * 4))
			player:getPosition():sendMagicEffect(50)
			local vocName = player:getVocation():getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
			player:remove()
		end
		if param == "druid" or param == "Druid" then
			local reborn = (player:getStorageValue(707070) + 1)
			player:setVocation(2 + (reborn * 4))
			player:getPosition():sendMagicEffect(50)
			local vocName = player:getVocation():getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
			player:remove()
		end
		if param == "paladin" or param == "Paladin" then
			local reborn = (player:getStorageValue(707070) + 1)
			player:setVocation(17 + reborn)
			player:getPosition():sendMagicEffect(50)
			local vocName = player:getVocation():getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
			player:remove()
		end
		if param == "shadow" or param == "Shadow" then
			local reborn = (player:getStorageValue(707070) + 1)
			player:setVocation(21 + reborn)
			player:getPosition():sendMagicEffect(50)
			local vocName = player:getVocation():getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!")
			player:remove()
		end
	return true
end

--addEvent(function() target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You vocation changed to "..vocName.."!") end, 1000)
--addEvent(function() player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You changed "..target:getName().." vocation to "..vocName.."!") end, 1000)