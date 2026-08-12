task = {
    storage = {
        onTask         = 7522000,
        monstersLeft = 7522001,
        completed    = 7522002,
        getFinished  = 7522003,
    },
    tasks = { -- You can add as many tasks as you want
        [1] = {
            name = "Slimy Worms", -- Name of Task
            --description = "The slimy rotworms in the sewers are destroying the city. Please kill some of them for me.", -- What the NPC tells the player to do
			description = "Kill 4 Rotworms",
            monsters = { -- You can add as many monsters as you want
                "Rotworm",
                "Carrion Worm",
            },
            toKill = 4, -- How many monsters the player needs to kill
            rewards = {    -- You can add as many rewards as you want
                [1] = {
                    name = "crystal coin",
                    itemid = 2160,
                    count = 10,
                    experience = 100, -- base exp task
                },
                [2] = {
                    name = "magic sword",
                    itemid = 2400,
                    count = 1,
                },
            },
        },
        [2] = {
            name = "Firebreathers",
            --description = "Dragons.. dragons.. dragons...", 
				description = "Kill 3 Dragons",
            monsters = {
                "Dragon",
                "Dragon Lord",
            },
            toKill = 3,
            rewards = {
                [1] = {
                    name = "crystal coin",
                    itemid = 2160,
                    count = 10,
                    experience = 200, -- base exp task
                },
            },
        },
        [3] = {
            name = "Demonz",
            --description = "Big, red and magical.", 
				description = "Kill 1 Demon",
            monsters = {
                "Demon",
            },
            toKill = 1,
            rewards = {
                [1] = {
                    name = "crystal coin",
                    itemid = 2160,
                    count = 50,
                },
            },
        },
    },
}

task.__index = task

function task:onTask(player)
    for i = 1, #task.tasks do
        if player:getStorageValue(task.storage.onTask) == i then
            return i
        end
    end
    return 0
end
function onSay(player, words, param)
    if task:onTask(player) > 0 then
        player:say("You already have a mission. " .. task.tasks[task:onTask(player)].description  .. "", player:getId())
        task:debug(player:getName() .. " is already on a mission " .. task.tasks[task:onTask(player)].name  .. ".")
        return false
    end
return false
end