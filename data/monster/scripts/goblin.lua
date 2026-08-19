local time = 60

function removeBoss(cid)
    local monster = Monster(cid)
    if monster then
		local pos = monster:getPosition()
		Game.sendAnimatedText('Losers!', pos, 210)
		monster:getPosition():sendMagicEffect(11)
        monster:remove()
    end
end

function onCreatureAppear(self, creature)
    if self == creature then
        addEvent(removeBoss, time * 1000, self:getId())
    end
end