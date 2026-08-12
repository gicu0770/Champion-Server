
function onStepIn(creature, item, position, fromPosition)
if creature:isPlayer() then
	if item.actionid == 27562 then
		local rand = math.random(1,4)
		local boosts = {MONSTER_SOUL_EXP, MONSTER_SOUL_GOLD, MONSTER_SOUL_LOOT, MONSTER_SOUL_DAMAGE}
		local boosts_effects = {1, 2, 3, 4}
		local boostsName = {"Exp +25%", "Gold +100%", "Loot +20%", "Damage +20%"}
		creature:addBuff(boosts[rand])
		creature:getPosition():sendMagicEffect(350)
		item:remove()
		Game.sendAnimatedText(boostsName[rand], creature:getPosition(), 215, "Reggae One-20px-bordered")
	end

	if item.itemid == 37275 then
		creature:getPosition():sendMagicEffect(344)
		creature:addHealth(creature:getMaxHealth() * 0.25)
		applyResourceRegen(creature, "health", 100, 60, 100, HEALTH_REGENERATION_GLOBE)
		item:remove()
		Game.sendAnimatedText("Health Regeneration +100%", creature:getPosition(), 180, "Reggae One-20px-bordered")
	end
	if item.itemid == 37276 then
		creature:getPosition():sendMagicEffect(346)
		creature:addMana(creature:getMaxMana() * 0.25)
		applyResourceRegen(creature, "mana", 100, 60, 101, MANA_REGENERATION_GLOBE)
		item:remove()
		Game.sendAnimatedText("Mana Regeneration +100%", creature:getPosition(), 155, "Reggae One-20px-bordered")
	end
	if item.itemid == 37277 then
		creature:getPosition():sendMagicEffect(348)
		creature:addEnergyShield(creature:getMaxEnergyShield() * 0.25)
		applyResourceRegen(creature, "energyshield", 100, 60, 102, ENERGYSHIELD_REGENERATION_GLOBE)
		item:remove()
		Game.sendAnimatedText("Energy Shield Regeneration +100%", creature:getPosition(), 198, "Reggae One-20px-bordered")
	end
	if item.itemid == 37278 then
			-- Apply experience stage multiplier + exp %
		creature:getPosition():sendMagicEffect(350)
		local text = "EXP"
		local exp_bonus = item:getBonusGlobe()
		creature:addExperience(exp_bonus)
		item:remove()
		Game.sendAnimatedText(""..text.." +"..exp_bonus.."", creature:getPosition(), 198, "Reggae One-20px-bordered")
	end
	if item.itemid == 37279 then
			creature:getPosition():sendMagicEffect(344)
			creature:addHealth(creature:getMaxHealth() * 0.10)
			item:remove()
			Game.sendAnimatedText("Health +10%", creature:getPosition(), 180, "Reggae One-20px-bordered")
	end
	if item.itemid == 37280 then
			creature:getPosition():sendMagicEffect(346)
			creature:addMana(creature:getMaxMana() * 0.10)
			item:remove()
			Game.sendAnimatedText("Mana +10%", creature:getPosition(), 155, "Reggae One-20px-bordered")
	end
	if item.itemid == 37281 then
			creature:getPosition():sendMagicEffect(348)
			creature:addHealth(creature:getMaxHealth() * 0.15)
			creature:addMana(creature:getMaxMana() * 0.15)
			item:remove()
			Game.sendAnimatedText("Health&Mana +15%", creature:getPosition(), 198, "Reggae One-20px-bordered")
	end


end
	return true
end