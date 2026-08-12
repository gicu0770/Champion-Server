function onUse(player, item, fromPosition, target, toPosition, isHotkey)
--	local lootTrash = {26555, 18413, 18415, 18422, 18421, 18420}
	local soulshards = {36971, 36972, 36973, 36974, 36975, 36976, 36977, 36978, 36980, 37286, 37284, 37295, 37301, 37283, 37290, 37282, 37287, 37298}
	local upgradeshards = {26555, 36979, 36981}
  if item:getId() == US_CONFIG.CRYSTAL_FOSSIL then
	if Tile(player:getPosition()):getHouse() then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "Cannot use inside house.")
		return false
	end
    local amount = item:getCount()
	math.randomseed(os.time())
    for i = 1, amount do
      if math.random(10) <= 5 then
		local rend = math.random(1,20)
		if rend == 1 then
		 player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Upgrade Crystal")
		 player:addItem(26555, 1)
		end
		if rend == 2 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Soul Shard Upgrade Tools")
			player:addItem(36979, 1)
		end
		if rend == 3 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Soul Shard Removal Tools")
			player:addItem(36981, 1)
		end
		if math.random(100000) <= 200 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Empty Cube")
			player:addItem(33950, 1)
		end


		if math.random(100000) <= 333 then
		 player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Soul Shard Bag")
		 player:addItem(29560, 1)
		 player:getPosition():sendMagicEffect(35)
		end

		randomFragments(player, player, 1)
		currencyDrop(player, player, 1)
      else
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "Crystal inside broke!")
		player:say("Crystal was broke!", TALKTYPE_MONSTER_SAY)
      end
    end
    item:remove(amount)
  end
  return true
end
