local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onThink()                          npcHandler:onThink()                        end

function onAddFocus(cid)
    npcHandler:addFocus(cid)
    local player = Player(cid)
    if player then
        sendPotionUpgradeData(player)
    end
    return true
end

function onCreatureSay(cid, type, msg)
    if getDistanceBetween(getThingPos(cid), Creature(getNpcCid()):getPosition()) >= 4 then
        return false
    end

    npcHandler:onCreatureSay(cid, type, msg)
end

local function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end

    local player = Player(cid)
    if not player then
        return false
    end

    if msgcontains(msg, "upgrade") or msgcontains(msg, "potion") or msgcontains(msg, "hi") or msgcontains(msg, "hello") then
        sendPotionUpgradeData(player)
        local canUpgrade, reason, cfg, nextCfg, reqLevel, reqGold = getPotionUpgradeInfo(player)
        if reason == "NO_POTION" then
            npcHandler:say("You don't have any potion equipped or in your backpack!", cid)
            npcHandler.topic[cid] = 0
        elseif reason == "MAX_TIER" then
            npcHandler:say("Your " .. (cfg and cfg.name or "potion") .. " is already at the maximum tier!", cid)
            npcHandler.topic[cid] = 0
        elseif reason == "LOW_LEVEL" then
            npcHandler:say("You need level " .. reqLevel .. " to upgrade to " .. (nextCfg and nextCfg.name or "next tier") .. ". You are level " .. player:getLevel() .. ".", cid)
            npcHandler.topic[cid] = 0
        elseif reason == "NO_GOLD" then
            npcHandler:say("You need " .. reqGold .. " gold coins to upgrade to " .. (nextCfg and nextCfg.name or "next tier") .. ". You have " .. player:getTotalMoney() .. " gold in your account.", cid)
            npcHandler.topic[cid] = 0
        else
            npcHandler.topic[cid] = 1
            npcHandler:say("I can upgrade your " .. cfg.name .. " (+" .. cfg.health[1] .. " HP) to " .. nextCfg.name .. " (+" .. nextCfg.health[1] .. " HP) for " .. reqGold .. " gold coins (level " .. reqLevel .. " required). Do you want to upgrade? {yes}", cid)
        end
        return true

    elseif npcHandler.topic[cid] == 1 and msgcontains(msg, "yes") then
        if upgradePotionForPlayer(player) then
            npcHandler:say("Here you go! Your potion has been upgraded!", cid)
            sendPotionUpgradeData(player)
        else
            npcHandler:say("Could not complete the upgrade.", cid)
        end
        npcHandler.topic[cid] = 0
        return true

    elseif npcHandler.topic[cid] == 1 and msgcontains(msg, "no") then
        npcHandler:say("Maybe next time then.", cid)
        npcHandler.topic[cid] = 0
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:addModule(FocusModule:new())
