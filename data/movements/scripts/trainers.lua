local LCORNER = {x = 793, y = 144} -- 793, 144, 7  {x = 793, y = 39}
local RCORNER = {x = 999, y = 221} -- 999, 221, 7 {x = 1000, y = 118}
local T_ITEMID = 11062

function findfreespot()
    for x = LCORNER.x, RCORNER.x do
        for y = LCORNER.y, RCORNER.y do
            local tmpPos = {x=x, y=y, z = 7};
            local t = Tile(tmpPos)
            if t ~= nil then
                if(t:getThing():getId() == T_ITEMID and not t:getTopCreature()) then
                    return tmpPos
                end
            end
        end
    end
    return false
end

function onStepIn(player, item, position, fromPosition)
    local slot = findfreespot()
    if(slot) then
        player:teleportTo(slot)
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "No available free trainers slots.")
    end
    return true
end