function onUse(player, item, fromPosition, itemEx, toPosition)
	if item.itemid == 12383 and item.actionid >= 10578 and item.actionid <= 10582 then
		--	Item(item.uid):transform(item.itemid == 9825 and 9826 or 9825)

		local useItemPosition = item:getPosition()
		local tileCreateNew = Tile(useItemPosition.x, useItemPosition.y, useItemPosition.z)
		local tileLeft = Tile(useItemPosition.x - 1, useItemPosition.y, useItemPosition.z)
		local tileRight = Tile(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z)
		local thingLeft = tileLeft:getTopVisibleThing(player)
		local thingRight = tileRight:getTopVisibleThing(player)
		if thingLeft:getId() == 0 then return end
		local bar = { 36223, 36221, 36216, 36215, 36219, 36220, 36217, 36218 }
		local shards1 = { 37244, 37242, 37238, 37127, 37151 }
		local shards2 = { 37139, 37147, 37131, 37133, 37135, 37125, 37143 }
		local fragmentsTier1 = { 37152, 37236, 37239, 37243, 37245 }
		local fragmentsTier2 = { 37140, 37148, 37132, 37136, 37129, 37134 }
		local fragmentsTier3 = { 37154, 37235, 37237, 37241 }
		local allFragments = { 37152, 37236, 37239, 37243, 37245, 37140, 37148, 37132, 37136, 37129, 37134 }
		local allsahrds = { 37244, 37242, 37238, 37127, 37151, 37139, 37147, 37131, 37133, 37135, 37125, 37143 }
		local shoulshards = { 36971, 36972, 36973, 36974, 36975, 36976, 36977, 36978, 36980, 37286, 37284, 37295, 37301, 37283, 37290, 37282, 37287, 37298 }
		local itemId = thingLeft:getId()
		local itemType = ItemType(thingLeft:getId())
		local op = false
		if isInArray(allFragments, itemId) then -- and thingL:isItem()
			op = true
			if math.random(100) <= 80 then
				--	Game.sendAnimatedText('Success!', useItemPosition, 192, "Reggae One-20px-bordered")
				useItemPosition:sendMagicEffect(325)
				if isInArray(fragmentsTier1, itemId) then
					thingLeft:remove(thingLeft:getCount())
					Game.createItem(fragmentsTier1[math.random(#fragmentsTier1)], thingLeft:getCount(),
						Position(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z))
				elseif isInArray(fragmentsTier2, itemId) then
					thingLeft:remove(thingLeft:getCount())
					Game.createItem(fragmentsTier2[math.random(#fragmentsTier2)], thingLeft:getCount(),
						Position(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z))
				end
			else
				useItemPosition:sendMagicEffect(326)
				thingLeft:remove(thingLeft:getCount())
			end
		else
			--	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Wrong item! Fragments required!")
		end

		if isInArray(bar, itemId) then -- and thingL:isItem()
			op = true
			if math.random(100) <= 80 then
				--	Game.sendAnimatedText('Success!', useItemPosition, 192, "Reggae One-20px-bordered")
				useItemPosition:sendMagicEffect(325)
				if isInArray(bar, itemId) then
					thingLeft:remove(thingLeft:getCount())
					Game.createItem(bar[math.random(#bar)], thingLeft:getCount(),Position(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z))
				end
			else
				useItemPosition:sendMagicEffect(326)
				thingLeft:remove(thingLeft:getCount())
			end
		else
			--	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Wrong item! Fragments required!")
		end

		if isInArray(allsahrds, itemId) then -- and thingL:isItem()
			op = true
			if math.random(100) <= 80 then
				--	Game.sendAnimatedText('Success!', useItemPosition, 192, "Reggae One-20px-bordered")
				useItemPosition:sendMagicEffect(325)
				if isInArray(shards1, itemId) then
					thingLeft:remove(thingLeft:getCount())
					Game.createItem(shards1[math.random(#shards1)], thingLeft:getCount(),
						Position(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z))
				elseif isInArray(shards2, itemId) then
					thingLeft:remove(thingLeft:getCount())
					Game.createItem(shards2[math.random(#shards2)], thingLeft:getCount(),
						Position(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z))
				end
			else
				useItemPosition:sendMagicEffect(326)
				thingLeft:remove(thingLeft:getCount())
			end
		else
			--	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Wrong item! Fragments required!")
		end

		if isInArray(shoulshards, itemId) and not op then
			if math.random(100) <= 80 then
				useItemPosition:sendMagicEffect(325)
				local newRandomShard = shoulshards[math.random(#shoulshards)]
				local newSahrd = Game.createItem(newRandomShard, thingLeft:getCount(),
					Position(useItemPosition.x + 1, useItemPosition.y, useItemPosition.z))

				local config = {
					[36971] = 1,
					[36972] = 2,
					[36973] = 3,
					[36974] = 4,
					[36975] = 5,
					[36976] = 6,
					[36977] = 7,
					[36978] = 8,
					[36980] = 9,
					[37286] = 10,
					[37284] = 11,
					[37295] = 12,
					[37301] = 13,
					[37283] = 14,
					[37290] = 15,
					[37282] = 16,
					[37287] = 17,
				}
				if thingLeft:isLegendarySoulShard() then newSahrd:setLegendarySoulShard(true) end
				newSahrd:setSoulShard(config[newRandomShard])
				newSahrd:setSoulShardLevel(thingLeft:getSoulShardLevel())

				thingLeft:remove(thingLeft:getCount())
			else
				useItemPosition:sendMagicEffect(326)
				thingLeft:remove(thingLeft:getCount())
			end
		end
	end
	return true
end
