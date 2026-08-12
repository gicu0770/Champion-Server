function onExtendedOpcode(player, opcode, buffer)
    local banana = player:getItemCount(2676)
        local cake = player:getItemCount(6278)
            local melon = player:getItemCount(2680)
                  local buf = tonumber(buffer)
local condition = player:getCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT)
if condition and math.floor(condition:getTicks() / 1000) >= 1200 then
player:sendTextMessage(MESSAGE_STATUS_SMALL, "You are full.")
return false
end
if opcode == 14 and buf == 1 and banana >= 1 then
player:feed(180)
player:say("Omn, omn~! Banani!", TALKTYPE_MONSTER_SAY)
player:removeItem(2676, 1)
elseif opcode == 14 and buf == 3 and cake >= 1 then
player:feed(180)
player:say("Omn, omn~! Fat Boosting!", TALKTYPE_MONSTER_SAY)
player:removeItem(6278, 1)
elseif opcode == 14 and buf == 2 and melon >= 1 then
player:removeItem(2680, 1)
player:feed(180)
player:say("Omn, omn~! He?!", TALKTYPE_MONSTER_SAY)
end
end