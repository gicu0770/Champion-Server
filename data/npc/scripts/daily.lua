local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()    end
function selfBoost(player, buffId, buffName)
	local extraTextInfo = "activated"
	local showText = true
	if player:hasBuff(buffId) then
		extraTextInfo = "extended"
		showText = false
	end
	local textChat = "You have " .. extraTextInfo .. " a Self " .. buffName .. " Boost"
	local textBr = " You have " ..
	extraTextInfo ..
	" a {Self " .. buffName .. " Boost}!\nYou gain +20% " .. buffName .. " for the next 60 minutes!\nTime to grind!"
	player:sendExtendedOpcode(71, json.encode({ text = textBr, color = "#f7ef8a" }))
	player:sendTextMessage(MESSAGE_EVENT_ORANGE, textChat)
	if showText then
		player:sendTextMessage(MESSAGE_EVENT_ORANGE, "You gain +20% " .. buffName .. " for the next 60 minutes!")
	end
	player:addBuff(buffId, 60 * 60 * 1000)
	return true
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
	local player = Player(cid)
	local DAILY_REWARD_STORAGE = PlayerStorage.dailyNPC -- unikalne ID storage
	local COOLDOWN_SECONDS = 10 -- czas testowy: 10 sekund

	local currentTime = os.time()
	local lastReward = player:getStorageValue(DAILY_REWARD_STORAGE)

	if msgcontains(msg, "daily") then
		if lastReward == -1 then
			lastReward = 0
		end

		if currentTime - lastReward < COOLDOWN_SECONDS then
			local remaining = COOLDOWN_SECONDS - (currentTime - lastReward)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("You already claimed your reward! Please wait %d seconds.", remaining))
			return false
		else
			-- Gracz może odebrać nagrodę
			player:setStorageValue(DAILY_REWARD_STORAGE, currentTime)
			selfSay("You received your daily reward!", player) -- masz juz trait
			selfBoost(player, BUFF_EXP_BOOST, "EXP")
		end
	end 

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())


