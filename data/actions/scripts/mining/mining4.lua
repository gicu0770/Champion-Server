-- Mining Skill by Ramirow
-- Skill System created by Codex NG -THANKS! (https://otland.net/members/codex-ng.213653/)
-- For TFS version 1.1

local name = "Mining"  -- Name of the Custom Skill
local storage = 15002  -- Storage used to store Custom Skill Levels
local minutes = 3  -- Minutes to recreate the stone

function doCreateStone(pos, itemid)  -- Recreates the stone after given time
  local tile = Tile(pos)
  if tile:getTopCreature() then
  pos:sendMagicEffect(CONST_ME_POFF)
  return addEvent(doCreateStone, math.random(1, minutes) * 60 * 1000, pos, itemid)
  else
  Game.createItem(itemid, 1, pos)
  pos:sendMagicEffect(CONST_ME_MAGIC_RED)
  end
end

local stones = {  -- Contains all stones and their data
  [36170] = {
   itemid = 36170,
   stonetype = 'small enchanted sapphire',
   stonetype2 = 'sapphire', 
   item = 7759,
   item2 = 36208,
   xp = 3,
   xp2 = 5
  },
  [36171] = {
   itemid = 36171,
   stonetype = 'small enchanted sapphire',
   stonetype2 = 'sapphire',
   item = 7759,
   item2 = 36208,
   xp = 3,
   xp2 = 5
  },
  [36172] = {
   itemid = 36172,
   stonetype = 'small enchanted sapphire',
   stonetype2 = 'sapphire',
   item = 7759,
   item2 = 36208,
   xp = 3,
   xp2 = 5
  },
  [36163] = {
   itemid = 36163,
   stonetype = 'small enchanted emerald',
   stonetype2 = 'emerald', -- small ruby 2147  small enchanted ruby 7760 amethyst
   item = 7761,
   item2 = 36207,
   xp = 3,
   xp2 = 5
  },
  [36164] = {
   itemid = 36164,
   stonetype = 'small enchanted emerald',
   stonetype2 = 'emerald',
   item = 7761,
   item2 = 36207,
   xp = 3,
   xp2 = 5
  },
  [36165] = {
   itemid = 36165,
   stonetype = 'small enchanted emerald',
   stonetype2 = 'emerald',
   item = 7761,
   item2 = 36207,
   xp = 3,
   xp2 = 5
  },
  [36180] = {
   itemid = 36180,
   stonetype = 'small enchanted ruby',
   stonetype2 = 'ruby', 
   item = 7760,
   item2 = 36210,
   xp = 3,
   xp2 = 5
  },
  [36181] = {
   itemid = 36181,
   stonetype = 'small enchanted ruby',
   stonetype2 = 'ruby',
   item = 7760,
   item2 = 36210,
   xp = 3,
   xp2 = 5
  },
  [36182] = {
   itemid = 36182,
   stonetype = 'small enchanted ruby',
   stonetype2 = 'ruby',
   item = 7760,
   item2 = 36210,
   xp = 3,
   xp2 = 5
  },
  [36175] = {
   itemid = 36175,
   stonetype = 'small emerald',
   stonetype2 = 'topaz', -- small ruby 2147  small enchanted ruby 7760 amethyst
   item = 2149,
   item2 = 36209,
   xp = 3,
   xp2 = 5
  },
  [36176] = {
   itemid = 36176,
   stonetype = 'small emerald',
   stonetype2 = 'topaz',
   item = 2149,
   item2 = 36209,
   xp = 3,
   xp2 = 5
  },
  [36177] = {
   itemid = 36177,
   stonetype = 'small emerald',
   stonetype2 = 'topaz',
   item = 2149,
   item2 = 36209,
   xp = 3,
   xp2 = 5
  },
  [36158] = {
   itemid = 36158,
   stonetype = 'small sapphire',
   stonetype2 = 'turquoise', 
   item = 2146,
   item2 = 36206,
   xp = 3,
   xp2 = 5
  },
  [36159] = {
   itemid = 36159,
   stonetype = 'small sapphire',
   stonetype2 = 'turquoise',
   item = 2146,
   item2 = 36206,
   xp = 3,
   xp2 = 5
  },
  [36160] = {
   itemid = 36160,
   stonetype = 'small sapphire',
   stonetype2 = 'turquoise',
   item = 2146,
   item2 = 36206,
   xp = 3,
   xp2 = 5
  },
  [36151] = {
   itemid = 36151,
   stonetype = 'small topaz',
   stonetype2 = 'aber', -- small ruby 2147  small enchanted ruby 7760 amethyst
   item = 9970,
   item2 = 36205,
   xp = 3,
   xp2 = 5
  },
  [36152] = {
   itemid = 36152,
   stonetype = 'small topaz',
   stonetype2 = 'aber',
   item = 9970,
   item2 = 36205,
   xp = 3,
   xp2 = 5
  },
  [36153] = {
   itemid = 36153,
   stonetype = 'small topaz',
   stonetype2 = 'aber',
   item = 9970,
   item2 = 36205,
   xp = 3,
   xp2 = 5
  },
  [36185] = {
   itemid = 36185,
   stonetype = 'small amethyst',
   stonetype2 = 'amethyst', 
   item = 2150,
   item2 = 36211,
   xp = 3,
   xp2 = 5
  },
  [36186] = {
   itemid = 36186,
   stonetype = 'small amethyst',
   stonetype2 = 'amethyst',
   item = 2150,
   item2 = 36211,
   xp = 3,
   xp2 = 5
  },
  [36187] = {
   itemid = 36187,
   stonetype = 'small amethyst',
   stonetype2 = 'amethyst',
   item = 2150,
   item2 = 36211,
   xp = 3,
   xp2 = 5
  },
  [36192] = {
   itemid = 36192,
   stonetype = 'small ruby',
   stonetype2 = 'opal', -- small ruby 2147  small enchanted ruby 7760 amethyst
   item = 2147,
   item2 = 36212,
   xp = 3,
   xp2 = 5
  },
  [36193] = {
   itemid = 36193,
   stonetype = 'small ruby',
   stonetype2 = 'opal',
   item = 2147,
   item2 = 36212,
   xp = 3,
   xp2 = 5
  },
  [36194] = {
   itemid = 36194,
   stonetype = 'small ruby',
   stonetype2 = 'opal',
   item = 2147,
   item2 = 36212,
   xp = 3,
   xp2 = 5
  }
}

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
  local player = type(cid) == 'number' and Player(cid) or cid
  if player:getLevel() < 400 then
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need Level 400+ to use this pickaxe!")
  return false
  end
  local miningSkill = player:getEffectiveSkillLevel(SKILL_FIST)
  if stones[target.itemid] then
	if math.random(1,100) <= 10 then
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Nothing happend")
	toPosition:sendMagicEffect(3)
	return false
	end
  local chance = 20 + miningSkill
  if math.random(1,100) <= chance then
	  player:addItem(stones[target.itemid].item2, math.random(1,3))
	  toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
	  target:remove()
	  addEvent(doCreateStone, math.random(1, minutes) * 60 * 1000, toPosition, target.itemid)
	  player:addSkillTries(SKILL_FIST, stones[target.itemid].xp2)
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You mined " .. stones[target.itemid].stonetype2 .. ". Mining Skill increased!")
	--	if math.random(1, 100) <= 30 then
	--		local clone = Game.createMonster("Lava Golem", player:getPosition(), true, true)
	--		if clone then
	--		clone:setMaxHealth(clone:getMaxHealth() * 1.3)
	--		clone:setHealth(clone:getMaxHealth())
	--		end
	--	end
	if math.random(1, 100) <= 5 then
		player:addItem(24850, math.random(1,3))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You mined Crystal Fossil.")
	end	
     elseif math.random(1,100) <= chance then
	player:addItem(stones[target.itemid].item, math.random(1,5))
	toPosition:sendMagicEffect(CONST_ME_MAGIC_RED)
	target:remove()
	addEvent(doCreateStone, math.random(1, minutes) * 60 * 1000, toPosition, target.itemid)
	 player:addSkillTries(SKILL_FIST, stones[target.itemid].xp)
	 player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You mined " .. stones[target.itemid].stonetype .. ".")
	if math.random(1, 100) <= 5 then
		player:addItem(24850, math.random(1,3))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You mined Crystal Fossil.")
	end
   else
	  toPosition:sendMagicEffect(CONST_ME_POFF)
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You failed and the rock was destroyed.")
	  target:remove()
	  addEvent(doCreateStone, math.random(1, minutes) * 60 * 1000, toPosition, target.itemid)
	  player:addSkillTries(SKILL_FIST, 1)
     end
	 else
	  player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You couldn't mine anything.")
	  toPosition:sendMagicEffect(CONST_ME_HITAREA)
end
  return true
end