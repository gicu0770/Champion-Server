-- pushTarget(creatureId, creatureId, 1+, true/false)
function pushTarget(creatureId, targetId, amount, dynamic) -- dynamic means it'll look for extra squares
    local creature = Creature(creatureId)
    local target = Creature(targetId)
    if not creature or not target or creature == target then
        return false
    end
    local creaturePosition = creature:getPosition()
    local targetInitialPosition = target:getPosition()
    if creaturePosition.z ~= targetInitialPosition.z then
        return false
    end
    local nextPosition
    local targetCurrentPosition
    local x, y, x_temp, y_temp
    local tile
    for i = 1, amount do
        targetCurrentPosition = target:getPosition()
        x_temp = targetCurrentPosition.x - creaturePosition.x
        y_temp = targetCurrentPosition.y - creaturePosition.y
        x = x_temp < 0 and 1 or x_temp == 0 and 0 or -1
        y = y_temp < 0 and 1 or y_temp == 0 and 0 or -1
        x_temp = x_temp > 0 and x_temp * -1 or x_temp
        y_temp = y_temp > 0 and y_temp * -1 or y_temp
        x = x_temp > y_temp and 0 or x
        y = y_temp > x_temp and 0 or y 
        nextPosition = Position(targetCurrentPosition.x - x, targetCurrentPosition.y - y, creaturePosition.z)
        tile = Tile(nextPosition)
	if not tile then return end
	local thing = tile:getTopVisibleThing(player)
	local thingID = 0
	if thing ~= nil then
	 thingID = thing:getId()
	end
        if tile and tile:isWalkable() and thingID ~= 459 and not Creature(tile:getTopCreature()) and not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
            target:teleportTo(nextPosition)
        elseif dynamic then
            x_temp = targetInitialPosition.x - creaturePosition.x
            y_temp = targetInitialPosition.y - creaturePosition.y
            x = x_temp < 0 and 1 or x_temp == 0 and 0 or -1
            y = y_temp < 0 and 1 or y_temp == 0 and 0 or -1
            for n = 1, 4 do
                if n == 1 then
                    nextPosition = Position(targetCurrentPosition.x - x, targetCurrentPosition.y - y, creaturePosition.z)
                elseif n == 2 then
                    nextPosition = Position(targetCurrentPosition.x - (x ~= 0 and 0 or x), targetCurrentPosition.y - y, creaturePosition.z)
                elseif n == 3 then
                    nextPosition = Position(targetCurrentPosition.x - x, targetCurrentPosition.y - (y ~= 0 and 0 or y), creaturePosition.z)
                else
                    return
                end
                tile = Tile(nextPosition)
                if tile and tile:isWalkable() and thingID ~= 459 and not Creature(tile:getTopCreature()) and not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
                    target:teleportTo(nextPosition)
                    break
                end
            end
        else
            return
        end
    end
end

-- pullTarget(creatureId, creatureId, 1+, true/false)
function pullTarget(creatureId, targetId, amount, dynamic) -- dynamic means it'll look for extra squares
    local creature = Creature(creatureId)
    local target = Creature(targetId)
    if not creature or not target or creature == target then
        return false
    end
    local creaturePosition = creature:getPosition()
    local targetInitialPosition = target:getPosition()
    if creaturePosition.z ~= targetInitialPosition.z then
        return false
    end
    local nextPosition
    local targetCurrentPosition
    local x, y, x_temp, y_temp
    local tile
    for i = 1, amount do
        targetCurrentPosition = target:getPosition()
        if creaturePosition:getDistance(targetCurrentPosition) == 1 then
            return
        end
        x_temp = targetCurrentPosition.x - creaturePosition.x
        y_temp = targetCurrentPosition.y - creaturePosition.y
        x = x_temp < 0 and 1 or x_temp == 0 and 0 or -1
        y = y_temp < 0 and 1 or y_temp == 0 and 0 or -1
        x_temp = x_temp > 0 and x_temp * -1 or x_temp
        y_temp = y_temp > 0 and y_temp * -1 or y_temp
        x = x_temp > y_temp and 0 or x
        y = y_temp > x_temp and 0 or y   
        nextPosition = Position(targetCurrentPosition.x + x, targetCurrentPosition.y + y, creaturePosition.z)
        tile = Tile(nextPosition)
        if tile and tile:isWalkable() and not Creature(tile:getTopCreature()) and not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
            target:teleportTo(nextPosition)
        elseif dynamic then
            x_temp = targetInitialPosition.x - creaturePosition.x
            y_temp = targetInitialPosition.y - creaturePosition.y
            x = x_temp < 0 and 1 or x_temp == 0 and 0 or -1
            y = y_temp < 0 and 1 or y_temp == 0 and 0 or -1
            for n = 1, 4 do
                if n == 1 then
                    nextPosition = Position(targetCurrentPosition.x + x, targetCurrentPosition.y + y, creaturePosition.z)
                elseif n == 2 then
                    nextPosition = Position(targetCurrentPosition.x + (x ~= 0 and 0 or x), targetCurrentPosition.y + y, creaturePosition.z)
                elseif n == 3 then
                    nextPosition = Position(targetCurrentPosition.x + x, targetCurrentPosition.y + (y ~= 0 and 0 or y), creaturePosition.z)
                else
                    return
                end
                tile = Tile(nextPosition)
                if tile and tile:isWalkable() and not Creature(tile:getTopCreature()) and not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
                    target:teleportTo(nextPosition)
                    break
                end
            end
        else
            return
        end
    end
end