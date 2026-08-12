--	function onKill(creature, target, player)
function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature then
		return true
	end
	local crystal = {"Common Crystal", "Rare Crystal", "Epic Crystal", "Legendary Crystal",}
	local random_chance = math.random(100000)
	local targetPosition = creature:getPosition()
	if creature:isMonster() then
		local HP = creature:getMaxHealth() * (1 + (creature:getMonsterLevel() * 0.04))
		if HP <= 500 then
			return false
		end
		if random_chance <= 250 then -- 25
		if killer and killer:isPlayer() then
		local dungeon = killer:getDungeon()
			if dungeon then
			local instance = dungeon:getPlayerInstance(killer)
				if instance then
					return false
				end
			end
		end
		if creature:getName() == "Common Crystal" or creature:getName() == "Rare Crystal" or creature:getName() == "Epic Crystal" or creature:getName() == "Legendary Crystal" then
			return false
		end
			if not creature:getMaster() then
			local cry = Game.createMonster(crystal[math.random(#crystal)], targetPosition, true, true)
			local hp = creature:getMaxHealth()
				if cry:getName() == "Common Crystal" then
				hpR = hp * 1.20
				elseif cry:getName() == "Rare Crystal" then
				hpR = hp * 1.30
				elseif cry:getName() == "Epic Crystal" then
				hpR = hp * 1.50
				elseif cry:getName() == "Legendary Crystal" then
				hpR = hp * 2
				end
			cry:setMaxHealth(hpR)
			cry:addHealth(hpR)
			creature:getPosition():sendMagicEffect(50)
			creature:say("You summon Crystal!", TALKTYPE_MONSTER_SAY)
				if killer:isPlayer() then
					killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You summon Crystal ! Destroy it and you will receive a reward.")
				end
			end
		end
	end
return true
end