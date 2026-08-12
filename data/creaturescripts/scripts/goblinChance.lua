--	function onKill(creature, target, player)
local function remove(pos)
		local item = Tile(pos):getItemById(28302)
		pos.y = pos.y - 1
		if item then
		 Tile(pos):removeWidget()
		 item:remove()
		end
	end
local PORTAL_GOBLIN = {
 {
    pos = corpsePosition,
    id = 3,
    data = {
    "7", -- | RARITY |
    "Goblin Portal", -- | TITLE |
    "Teleports you to the {Goblin Island}.,#8888FF, red,true", -- | TEXT | COLOR | COLOR2 | SEP |
    "You can only stay {10} minutes in this island!,#8888FF, yellow",
   }
  },
 }
function onDeath(creature, corpse, killer, mostDamage, unjustified, mostDamage_unjustified)
	if not creature then
		return true
	end
	local random_chance = math.random(100000)
	local targetPosition = creature:getPosition()
    if creature:isMonster() then
		local HP = creature:getMaxHealth() * (1 + (creature:getMonsterLevel() * 0.04))
		if HP <= 500 then
			return false
		end
		if random_chance <= 250 then -- 25
				if not creature:getMaster() then
				local cryE = Game.createMonster("Treasure Goblin", targetPosition)
					if cryE then
					local hp = creature:getMaxHealth()
					cryE:setMaxHealth(hp * 3)
					cryE:addHealth(hp * 3)
					creature:getPosition():sendMagicEffect(50)
					creature:say("Hahahah ohh RUN!", TALKTYPE_MONSTER_SAY)
						if killer:isPlayer() then
							killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You summon Treasure Goblin catch him! You have 30 seconds after goblin run!")
						end
					end
				end
            end
		
	end
return true
end