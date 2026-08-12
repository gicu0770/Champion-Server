local config = {	
  ['undead dragon lord'] = {name = 'Death', amount = 10000, storage = 81107, startstorage = 81007, startvalue = 1, nameQ = 'Royal Village'},
  ['undead reaper'] = {name = 'Death', amount = 10000, storage = 81107, startstorage = 81007, startvalue = 1, nameQ = 'Royal Village'},
  ['death lich'] = {name = 'Death', amount = 10000, storage = 81107, startstorage = 81007, startvalue = 1, nameQ = 'Royal Village'}

}
function onKill(player, target)
  if not target then
      return true
  end
  local monster = config[target:getName():lower()]
  if target:isPlayer() or not monster or target:getMaster() then
      return true
  end

player:openChannel(16)
local party = player:getParty()
if party then
  local members = party:getMembers()
  for i = 1, #members do
--member
      local member = members[i]
      if member:getPosition():getDistance(target:getPosition()) <= 20 then
  local stor = member:getStorageValue(monster.storage)+1
  if stor < monster.amount and member:getStorageValue(monster.startstorage) >= monster.startvalue then
      member:setStorageValue(monster.storage, stor)
   member:sendChannelMessage('','[Access '..monster.nameQ..'] '..(stor +1)..' of '..monster.amount..' '..(monster.name or target:getName())..'s killed.', TALKTYPE_CHANNEL_O, 12)
  end
  if (stor +1) == monster.amount then
  member:sendChannelMessage('','[Access '..monster.nameQ..'] Congratulations, you have killed '..(stor +1)..' '..monster.name..'s and completed the '..monster.name..'s mission.', TALKTYPE_CHANNEL_R1, 12)
      member:setStorageValue(monster.storage, stor +1)
  end
      end
  end
--leader
  local leader = party:getLeader()
  if leader:getPosition():getDistance(target:getPosition()) <= 20 then
  local stor = leader:getStorageValue(monster.storage)+1
  if stor < monster.amount and leader:getStorageValue(monster.startstorage) >= monster.startvalue then
      leader:setStorageValue(monster.storage, stor)
   leader:sendChannelMessage('','[Access '..monster.nameQ..'] '..(stor +1)..' of '..monster.amount..' '..(monster.name or target:getName())..'s killed.', TALKTYPE_CHANNEL_O, 12)
  end
  if (stor +1) == monster.amount then
  leader:sendChannelMessage('','[Access '..monster.nameQ..'] Congratulations, you have killed '..(stor +1)..' '..monster.name..'s and completed the '..monster.name..'s mission.', TALKTYPE_CHANNEL_R1, 12)
      leader:setStorageValue(monster.storage, stor +1)
  end
  end
else
---player only
 local stor = player:getStorageValue(monster.storage)+1
  if stor < monster.amount and player:getStorageValue(monster.startstorage) >= monster.startvalue then
      player:setStorageValue(monster.storage, stor)
   player:sendChannelMessage('','[Access '..monster.nameQ..'] '..(stor +1)..' of '..monster.amount..' '..(monster.name or target:getName())..'s killed.', TALKTYPE_CHANNEL_O, 12)
  end
  if (stor +1) == monster.amount then
  player:sendChannelMessage('','[Access '..monster.nameQ..'] Congratulations, you have killed '..(stor +1)..' '..monster.name..'s and completed the '..monster.name..'s mission.', TALKTYPE_CHANNEL_R1, 12)
      player:setStorageValue(monster.storage, stor +1)
  end
end
  return true
end