CURSED_CHESTS_AID = 9000


CURSED_CHESTS_SPAWNS = {
	[1] = {
		pos = Position(598, 1046, 9),
		size = 1,
		chests = {1},
	},
	[2] = {
		pos = Position(869, 954, 7),
		size = 1,
		chests = {1},
	},
	[3] = {
		pos = Position(786, 895, 6),
		size = 1,
		chests = {1},
	},
	[4] = {
		pos = Position(589, 1143, 7),
		size = 1,
		chests = {1},
	},
	[5] = {
		pos = Position(468, 933, 7),
		size = 1,
		chests = {1},
	},
	[6] = {
		pos = Position(601, 868, 7),
		size = 1,
		chests = {1},
	},
	[7] = {
		pos = Position(571, 953, 7),
		size = 1,
		chests = {1},
	},
	[8] = {
		pos = Position(641, 652, 7),
		size = 1,
		chests = {1},
	},
	[9] = {
		pos = Position(680, 688, 7),
		size = 1,
		chests = {1},
	},
	[10] = {
		pos = Position(772, 717, 7),
		size = 1,
		chests = {1},
	},
	[11] = {
		pos = Position(823, 731, 7),
		size = 1,
		chests = {1},
	},
	[12] = {
		pos = Position(752, 815, 7),
		size = 1,
		chests = {1},
	},
	[13] = {
		pos = Position(637, 973, 7),
		size = 1,
		chests = {1}
	}
}

function onThink(cid, interval, lastExecution)
	for spawnId, data in ipairs(CURSED_CHESTS_SPAWNS) do
		if not data.spawned then
			local from = Position(data.pos.x - data.size, data.pos.y - data.size, data.pos.z)
			local to = Position(data.pos.x + data.size, data.pos.y + data.size, data.pos.z)
			local chestId = math.random(1, #data.chests)
			local spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), data.pos.z)
			local tile = Tile(spawnPos)
			local spawnTest = 0

			while spawnTest < 100 do
				if isBadTile(tile) then
					spawnPos = Position(math.random(from.x, to.x), math.random(from.y, to.y), data.pos.z)
					tile = Tile(spawnPos)
					spawnTest = spawnTest + 1
				else
					break
				end
			end

			if spawnTest < 100 then
				local rarity = nil
				for i = #CURSED_CHESTS_TIERS, 1, -1 do
					rarity = CURSED_CHESTS_TIERS[i]
					if math.random(1, 100) <= rarity.chance then
						break
					end
				end
				if rarity ~= nil then
					local chest = Game.createItem(rarity.item, 1, spawnPos)				
					chest:setActionId(CURSED_CHESTS_AID)
					spawnPos:sendMagicEffect(CONST_ME_GROUNDSHAKER)
					local chestData = {}
					chestData.pos = spawnPos
					chestData.spawnId = spawnId
					chestData.wave = 0
					chestData.monsters = {}
					chestData.active = 0
					chestData.finished = false
					chestData.container = chest
					chestData.chest = CURSED_CHESTS_CONFIG[chestId]
					chestData.rarity = rarity
					CURSED_CHESTS_DATA[#CURSED_CHESTS_DATA + 1] = chestData
					data.spawned = true
				end
			end

		end
	end
	return true
end
