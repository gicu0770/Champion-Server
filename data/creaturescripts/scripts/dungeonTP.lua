local cfg = {
    ['vampire queen'] = {
        tpDestination = Position(837, 922, 7),
        xCreate = 247,
        yCreate = 267,
        zCreate = 6
    }, -- ukonczenie tp na Fungusy 26mlvl
    ['pheonix'] = {
        tpDestination = Position(1007, 900, 7),
        xCreate = 1092,
        yCreate = 1073,
        zCreate = 8
    }, -- 1007 900 7 Flame Cave {x = 1092, y = 1073, z = 8} Pozycja Boss & Teleport po zabiciu
    ['toxic hydra'] = {
        tpDestination = Position(826, 1204, 7),
        xCreate = 1063,
        yCreate = 1182,
        zCreate = 8
    }, -- Swamp Pit{x = 1063, y = 1182, z = 8}  Pozycja Boss & Teleportu po zabiciu
    ['undead king'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1043,
        yCreate = 1123,
        zCreate = 7
    },
    ['ethereal seraph'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1021,
        yCreate = 986,
        zCreate = 6
    },
    ['glacier warlord'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 447,
        yCreate = 232,
        zCreate = 7
    },
    ['copper golem'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1035,
        yCreate = 1035,
        zCreate = 7
    },
    ['holy protector'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1037,
        yCreate = 1025,
        zCreate = 6
    },
    ['frost beast'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1028,
        yCreate = 1027,
        zCreate = 6
    },
    ['thunderlord'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1032,
        yCreate = 1035,
        zCreate = 6
    },
    ['blackfang archer'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1043,
        yCreate = 1035,
        zCreate = 6
    },
    ['venomgrizzle'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1046,
        yCreate = 1041,
        zCreate = 7
    },
    ['bonebound stalker'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1050,
        yCreate = 1040,
        zCreate = 6
    },
    ['voidflare wisp'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1056,
        yCreate = 1051,
        zCreate = 5
    },
    ['reaper shade'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1027,
        yCreate = 1030,
        zCreate = 6
    },
    ['fleshrend'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 453,
        yCreate = 285,
        zCreate = 5
    },
    ['arbaziloth'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 271,
        yCreate = 261,
        zCreate = 6
    },
    ['tidal overlord'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1090,
        yCreate = 1086,
        zCreate = 7
    },
    ['emberlord'] = {
        tpDestination = Position(837, 922, 7),
        xCreate = 1000,
        yCreate = 993,
        zCreate = 7
    },
    ['voidlord'] = {
        tpDestination = Position(1007, 900, 7),
        xCreate = 1000,
        yCreate = 993,
        zCreate = 7
    },
    ['naturlord'] = {
        tpDestination = Position(826, 1204, 7),
        xCreate = 1000,
        yCreate = 993,
        zCreate = 7
    },
    ['icelord'] = {
        tpDestination = Position(274, 1271, 7),
        xCreate = 1000,
        yCreate = 993,
        zCreate = 7
    },
    ['voort'] = {
        tpDestination = Position(399, 835, 7),
        xCreate = 1011,
        yCreate = 1000,
        zCreate = 7
    },
    ['forest keeper'] = {
        tpDestination = Position(1053, 509, 7),
        xCreate = 1000,
        yCreate = 1000,
        zCreate = 3
    },
    ['blood fury'] = {
        tpDestination = Position(1737, 1213, 7),
        xCreate = 1002,
        yCreate = 991,
        zCreate = 7
    },
    ['sand colossus'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1205,
        yCreate = 986,
        zCreate = 7
    },
    ['molten abyss'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1267,
        yCreate = 1060,
        zCreate = 5
    },
    ['toxic witch'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1179,
        yCreate = 1090,
        zCreate = 8
    },
    ['soulbound lich'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1227,
        yCreate = 1056,
        zCreate = 6
    },
    ['grave spearlord'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1237,
        yCreate = 1029,
        zCreate = 6
    },
    ['minotaur liberator'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1309,
        yCreate = 1046,
        zCreate = 6
    },
    ['eldritch reaver'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1246,
        yCreate = 1067,
        zCreate = 6
    },
    ['golden hoarder'] = {
        tpDestination = Position(673, 1024, 7),
        xCreate = 1205,
        yCreate = 1177,
        zCreate = 7
    },
}
local cfgminiboss = {
    --	['vampire queen'] = {xDest = 837, yDest = 922, zDest = 7, xCreate = 1047, yCreate = 1123, zCreate = 7},
}

function onDeath(target, corpse, creature)
    local tmp = cfg[target:getName():lower()]
    local minibossteleport = cfgminiboss[target:getName():lower()]
    if tmp and target:isMonster() then
        local dungeon = creature:getDungeon()
        if dungeon then
            local instance = dungeon:getPlayerInstance(creature)
            if instance then
                local instancePosition = instance:getPosition()
                local TPstonePos = {
                    x = instancePosition.x + tmp.xCreate,
                    y = instancePosition.y + tmp.yCreate,
                    z = tmp.zCreate
                }
                addEvent(function()
                    local teleport = Game.createItem(28300, -1, TPstonePos)
                    Teleport(teleport.uid):setDestination(tmp.tpDestination)
                    teleport:setActionId(6435)
                end, 3000)
            end
        end

    end

    if minibossteleport and target:isMonster() then
        local pos = target:getPosition()
        local dungeon = creature:getDungeon()
        if dungeon then
            local instance = dungeon:getPlayerInstance(creature)
            if instance then
                local instancePosition = instance:getPosition()
                local TPstonePos2 = {
                    x = instancePosition.x + minibossteleport.xCreate,
                    y = instancePosition.y + minibossteleport.yCreate,
                    z = minibossteleport.zCreate
                }
                local tpDest = {
                    x = instancePosition.x + minibossteleport.xDest,
                    y = instancePosition.y + minibossteleport.yDest,
                    z = minibossteleport.zDest
                }
                local teleport2 = Game.createItem(28300, -1, TPstonePos2)
                Teleport(teleport2.uid):setDestination(tpDest)
                instance:finishBonusObjective(minibossteleport.objective)
            end
        end
    end
    return true
end
