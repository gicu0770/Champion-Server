local time = 2 * 60 * 60

function removeBoss2(cid)
    local monster = Monster(cid)
		if monster then
			monster:getPosition():sendMagicEffect(11)
			monster:remove()
		end
	end

function onCreatureAppear(self, creature)
    if self == creature then
        addEvent(removeBoss2, time * 1000, self:getId())
    end
end