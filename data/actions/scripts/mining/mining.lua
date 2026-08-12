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
  if player:getLevel() < 100 then
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need Level 100+ to use this pickaxe!")
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