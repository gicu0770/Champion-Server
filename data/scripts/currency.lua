local currencyIds = {
    2400, -- Orb of Transmutation
}

local currency = Action()

function currency.onUse(player, item, fromPosition, target, toPosition, isHotkey)

    if item:getId() == 2400 then

    end
	return true
end


currency:id(2400)
currency:register()
