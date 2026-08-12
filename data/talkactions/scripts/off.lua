local SHUTDOWN_STATE = false

function shutdownServer()
    if not SHUTDOWN_STATE then
        return
    end
    Game.setGameState(GAME_STATE_SHUTDOWN)
end

local shutdownEvent = nil

function shutdownMessage(timeLeft)
    if timeLeft == 1 then
        broadcastMessage("Server is going down in 1 minute. Sorry for the inconvenience.", MESSAGE_STATUS_WARNING)
		for _, targetPlayer in ipairs(Game.getPlayers()) do
			targetPlayer:sendExtendedOpcode(71, json.encode({text = "Server is going down in 1 minute. Sorry for the inconvenience.", color = "#f7ef8a"}))
		end
        addEvent(shutdownServer, 1 * 60 * 1000)
        return
    end
	for _, targetPlayer in ipairs(Game.getPlayers()) do
		targetPlayer:sendExtendedOpcode(71, json.encode({text = "Server is going down in ".. timeLeft .." minutes. Sorry for the inconvenience.", color = "#f7ef8a"}))
	end
    broadcastMessage("Server is going down in ".. timeLeft .." minutes. Sorry for the inconvenience.", MESSAGE_STATUS_WARNING)
    shutdownEvent = addEvent(shutdownMessage, 1 * 60 * 1000, timeLeft - 1)
end

function onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end

    if SHUTDOWN_STATE then
        if param == "cancel" or param == "stop" then
            broadcastMessage("Restart event has been stopped. Sorry for the inconvenience.", MESSAGE_STATUS_WARNING)
		for _, targetPlayer in ipairs(Game.getPlayers()) do
			targetPlayer:sendExtendedOpcode(71, json.encode({text = "Restart event has been stopped. Sorry for the inconvenience.", color = "#f7ef8a"}))
		end
            SHUTDOWN_STATE = false
            if shutdownEvent then
                stopEvent(shutdownEvent)
                shutdownEvent = nil
            end
        else     
            player:sendCancelMessage("Server is already in a restart state. To cancel restart use the \"/restart stop\" command.")
        end
        return false
    end

    local number = tonumber(param)
    if not number then
        player:sendCancelMessage("Numeric param may not be lower than 0.")
        return false
    end
 
    if number == 0 then
        SHUTDOWN_STATE = true
        shutdownServer()
        return false
    end  

    shutdownMessage(number)
    SHUTDOWN_STATE = true
    return false
end