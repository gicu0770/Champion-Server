function onThink(creature, interval)
if creature then
 if creature:getStorageValue(PlayerStorage.intervalBonus) >= os.time() then
 
 else
	local hp = creature:getMaxHealth() * 0.05
	creature:addHealth(hp)
	creature:getPosition():sendMagicEffect(168)
	creature:setStorageValue(PlayerStorage.intervalBonus, os.time() + 1)
 end
end
    return true
end