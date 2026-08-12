local config = {
	{from = Position(711, 1034, 7), to = Position(712, 1034, 7)},
}

function onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		for i = 1, #config do
			local tp = config[i]
			if tp.from == position then
				player:teleportTo(tp.to)
				tp.to:sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
	end
	return true
end
