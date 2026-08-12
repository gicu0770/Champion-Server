local function characterNameAlreadyExists(characterName)
    local resultId = db.storeQuery('SELECT * FROM `players` WHERE `name` = ' .. db.escapeString(characterName))
    if not resultId then
        return false
    end
    result.free(resultId)
    return true
end

local function isCharacterNameCorrect(characterName)
    local reason
    local words = { "owner", "gamemaster", "hoster", "admin", "staff",
    "tibia", "account", "god", "anal", "ass", "fuck",
    "sex", "hitler", "pussy", "dick", "rape", "cm", "gm",
    "tutor", "counsellor", "maldito" }
    for index, word in pairs(words) do
        if string.find(characterName:lower(), word) then
            reason = string.format("The name contains the word %s and is prohibited.", word)
            break
        end
    end
    for index, word in pairs(characterName:split(" ")) do
        if #word < 4 then
            reason = "The name is very long, you must use a shorter one."
            break
        end
    end
    if not reason then
        if MonsterType(characterName) then
            reason = string.format("The name %s can't be a monster's name.", characterName)
        elseif Npc(characterName) then
            reason = string.format("The name %s can't be a npc's name.", characterName)
        elseif string.match(characterName, "%a+%s%a+%s%a+") or string.match(characterName, "%s+%a-%s+") then
            reason = "The name contains many spaces separations."
        elseif string.match(characterName, "%d+") or string.match(characterName, "%p+") then
            reason = "The name cannot contain numbers or symbols."
        elseif #characterName > 18 then
            reason = "The name is very long, you must use a shorter one."
        elseif #characterName < 4 then
            reason = "The name is very short, you must use a longer one."
        end
    end
    return reason
end

local function changeName(player, name)
    return db.query(('UPDATE `players` SET `name` = "%s" WHERE `id` = %u'):format(name, player:getGuid()))
end

function onSay(player, words, param)
    if param == '' then
        return not player:sendCancelMessage("Insufficient parameters.")
    end
    if player:getItemCount(35533) < 1 then
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return not player:sendCancelMessage("You dont have change name item.")
    end
    local newname = param:lower():gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end):trim()
    local reason = isCharacterNameCorrect(newname)
    if reason then
        player:sendCancelMessage(reason)
    elseif characterNameAlreadyExists(newname) then
        player:sendCancelMessage("A player with that name already exists, please choose another name.")
    elseif player:removeItem(35533, 1) and changeName(player, newname) then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "The name has been changed successfully.")
        addEvent(function(cid)
            local player = Player(cid)
            if player then
                player:remove()
            end
        end, 1400, player.uid)
    else
        player:sendCancelMessage("An error occurred while changing the name.")
    end
    return false
end