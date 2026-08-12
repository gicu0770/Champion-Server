-- Equipment spy by Azi [ersiu] --
function getItemsInContainer(cont, sep)
    local text = ""
    local tsep = ""
    local count = ""
    for i=1, sep do
        tsep = tsep.."-"
    end
    tsep = tsep..">"
    for i=0, cont:getSize()-1 do
        local item = cont:getItem(i)
        if not item:isContainer() then
            if item:getType():getType() > 0 then
			count = "("..item:getType():getType().."x)"
            end
            text = text.."\n"..tsep..item:getName().." "..count
        else
            if item:getSize() > 0 then
                text = text.."\n"..tsep..item:getName()
                text = text..getItemsInContainer(item, sep+2)
            else
                text = text.."\n"..tsep..item:getName()
            end
        end
    end
    return text
end

function onSay(player, words, param, channel)
    if not player:getGroup():getAccess() then
        return true
    end
    if(param == "") then
        player:sendCancelMessage("Command requires param.")
        return TRUE
    end
    local slotName = {"Head Slot", "Amulet Slot", "Backpack Slot", "Armor Slot", "Right Hand", "Left Hand", "Legs Slot", "Feet Slot", "Ring Slot", "Ammo Slot"}
    local target = Player(param)
    if target:isPlayer() then
        local text = target:getName().."'s Equipment: "   
        for i=1, 10 do
            text = text.."\n\n"
            local item = target:getSlotItem(i)
            if item then
			local atricle = item:getArticle()
			local rarity = item:getRarity().name
			local nameIT = item:getName()
			local upgrade = item:getUpgradeLevel()
                if item:isContainer() then
                    text = text..slotName[i]..": "..item:getName()..getItemsInContainer(item, 1)
                else
                    text = text..slotName[i]..": "..atricle.." "..rarity.." "..nameIT.." + "..upgrade
                end
            else
                text = text..slotName[i]..": Empty"
            end
        end
        player:showTextDialog(6579, text)
    else
        player:sendCancelMessage("This player is not online.")
    end
    return false
end