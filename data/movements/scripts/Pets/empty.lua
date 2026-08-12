function onEquip(cid, item, slot)
    RemovePets(cid)
	return true
end	
 
function onDeEquip(cid, item, slot)
    RemovePets(cid)
	return true
end

function RemovePets(cid)
    local summons = getCreatureSummons(cid)
    if #summons > 0 then
        for i, v in ipairs(summons) do
            doRemoveCreature(v)
        end
    end
end