-- Guild System Overhaul for Champion-Server
-- Extended Opcode 239

GuildSystem = {
    OPCODE = ExtendedOPCodes.CODE_GUILD or 239,
    CREATE_LEVEL_REQ = 25,
    CREATE_COST = 10000,
    MAX_TAG_LENGTH = 3,
    MAX_NAME_LENGTH = 16,
    SUBID_BUFF_REGEN = 400990,
    SUBID_BUFF_HEALTH = 400991,
    SUBID_BUFF_EXP = 400992,

    LEVEL_CONFIG = (function()
        local cfg = { [1] = { cost = 0, maxMembers = 10 } }
        for lvl = 2, 50 do
            cfg[lvl] = {
                cost = 10000 + (lvl - 2) * 5000,
                maxMembers = math.min(100, 10 + (lvl - 1) * 2)
            }
        end
        return cfg
    end)(),

    BUFFS = {
        {
            id = 1,
            levelReq = 2,
            enchantId = 4,
            value = 3,
            icon = "/images/buffs/healthregenbuff",
            name = "Health Regeneration",
            desc = "Increases Health Regeneration by +3 per second.",
        },
        {
            id = 2,
            levelReq = 5,
            enchantId = 59,
            value = 5,
            icon = "/images/buffs/exp",
            name = "Experience Surge",
            desc = "Increases Experience gain by +5%.",
        },
        {
            id = 3,
            levelReq = 8,
            enchantId = 1,
            value = 120,
            icon = "/images/buffs/vitality_master",
            name = "Vitality Boost",
            desc = "Increases Maximum Health by +120.",
        },
        {
            id = 4,
            levelReq = 12,
            enchantId = 60,
            value = 10,
            icon = "/images/buffs/gold",
            name = "Prosperity",
            desc = "Increases Gold gain by +10%.",
        },
        {
            id = 5,
            levelReq = 15,
            enchants = { {8, 10}, {9, 10} },
            icon = "/images/buffs/stoneform",
            name = "Iron Bulwark",
            desc = "Increases Physical and Magic Defense by +10.",
        },
        {
            id = 6,
            levelReq = 20,
            enchants = { {6, 10}, {7, 10} },
            icon = "/images/buffs/blade_master",
            name = "Battle Supremacy",
            desc = "Increases Physical and Magic Attack by +10.",
        },
    }
}

-- Database Schema Auto-Migration
local function migrateDatabase()
    local function checkAndAddCol(tableName, colName, colDef)
        local query = string.format("SHOW COLUMNS FROM `%s` LIKE '%s'", tableName, colName)
        local res = db.storeQuery(query)
        if not res then
            db.query(string.format("ALTER TABLE `%s` ADD COLUMN `%s` %s", tableName, colName, colDef))
        else
            result.free(res)
        end
    end

    checkAndAddCol("guilds", "tag", "VARCHAR(3) NOT NULL DEFAULT ''")
    checkAndAddCol("guilds", "level", "INT(11) NOT NULL DEFAULT 1")
    checkAndAddCol("guilds", "gold", "BIGINT(20) NOT NULL DEFAULT 0")
    checkAndAddCol("guilds", "emblem", "INT(11) NOT NULL DEFAULT 1")
    checkAndAddCol("guilds", "join_status", "VARCHAR(16) NOT NULL DEFAULT 'Public'")
    checkAndAddCol("guilds", "required_level", "INT(11) NOT NULL DEFAULT 1")
    checkAndAddCol("guilds", "language", "VARCHAR(32) NOT NULL DEFAULT 'Polish'")
    checkAndAddCol("guilds", "buffs", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guilds", "pacifist_mode", "TINYINT(1) NOT NULL DEFAULT 0")
    checkAndAddCol("guilds", "pacifist_date", "INT(11) NOT NULL DEFAULT 0")
    checkAndAddCol("guilds", "wars_won", "INT(11) NOT NULL DEFAULT 0")
    checkAndAddCol("guilds", "wars_lost", "INT(11) NOT NULL DEFAULT 0")
    checkAndAddCol("guild_membership", "contribution", "BIGINT(20) NOT NULL DEFAULT 0")

    db.query([[
        CREATE TABLE IF NOT EXISTS `guild_applications` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `guild_id` INT NOT NULL,
            `player_id` INT NOT NULL,
            `date` INT NOT NULL,
            `status` VARCHAR(16) NOT NULL DEFAULT 'pending',
            UNIQUE KEY `uniq_guild_player` (`guild_id`, `player_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    db.query([[
        CREATE TABLE IF NOT EXISTS `guild_wars` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `guild1` INT NOT NULL,
            `guild2` INT NOT NULL,
            `name1` VARCHAR(255) NOT NULL DEFAULT '',
            `name2` VARCHAR(255) NOT NULL DEFAULT '',
            `status` INT NOT NULL DEFAULT 0,
            `started` INT NOT NULL DEFAULT 0,
            `ended` INT NOT NULL DEFAULT 0,
            `duration` INT NOT NULL DEFAULT 259200,
            `end_date` INT NOT NULL DEFAULT 0,
            `kills_limit` INT NOT NULL DEFAULT 10,
            `guild1_kills` INT NOT NULL DEFAULT 0,
            `guild2_kills` INT NOT NULL DEFAULT 0,
            `gold_bet` BIGINT NOT NULL DEFAULT 1000,
            `forced` TINYINT(1) NOT NULL DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    checkAndAddCol("guild_wars", "name1", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guild_wars", "name2", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guild_wars", "status", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guild_wars", "started", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guild_wars", "ended", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guild_wars", "duration", "INT NOT NULL DEFAULT 259200")
    checkAndAddCol("guild_wars", "end_date", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guild_wars", "kills_limit", "INT NOT NULL DEFAULT 10")
    checkAndAddCol("guild_wars", "guild1_kills", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guild_wars", "guild2_kills", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guild_wars", "gold_bet", "BIGINT NOT NULL DEFAULT 1000")
    checkAndAddCol("guild_wars", "forced", "TINYINT(1) NOT NULL DEFAULT 0")

    db.query([[
        CREATE TABLE IF NOT EXISTS `guildwar_kills` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `warid` INT NOT NULL,
            `killer` VARCHAR(255) NOT NULL DEFAULT '',
            `target` VARCHAR(255) NOT NULL DEFAULT '',
            `killerguild` INT NOT NULL DEFAULT 0,
            `targetguild` INT NOT NULL DEFAULT 0,
            `killer_guid` INT NOT NULL DEFAULT 0,
            `target_guid` INT NOT NULL DEFAULT 0,
            `killer_name` VARCHAR(255) NOT NULL DEFAULT '',
            `target_name` VARCHAR(255) NOT NULL DEFAULT '',
            `killer_guild` INT NOT NULL DEFAULT 0,
            `target_guild` INT NOT NULL DEFAULT 0,
            `time` BIGINT NOT NULL DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    checkAndAddCol("guildwar_kills", "killer", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guildwar_kills", "target", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guildwar_kills", "killerguild", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "targetguild", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "killer_name", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guildwar_kills", "target_name", "VARCHAR(255) NOT NULL DEFAULT ''")
    checkAndAddCol("guildwar_kills", "killer_guild", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "target_guild", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "killer_guid", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "target_guid", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "warid", "INT NOT NULL DEFAULT 0")
    checkAndAddCol("guildwar_kills", "time", "BIGINT NOT NULL DEFAULT 0")

    db.query([[
        UPDATE `guildwar_kills`
        SET `killer_name` = `killer`
        WHERE (`killer_name` IS NULL OR `killer_name` = '') AND `killer` IS NOT NULL AND `killer` != '';
    ]])
    db.query([[
        UPDATE `guildwar_kills`
        SET `target_name` = `target`
        WHERE (`target_name` IS NULL OR `target_name` = '') AND `target` IS NOT NULL AND `target` != '';
    ]])
    db.query([[
        UPDATE `guildwar_kills`
        SET `killer_guild` = `killerguild`
        WHERE (`killer_guild` IS NULL OR `killer_guild` = 0) AND `killerguild` != 0;
    ]])
    db.query([[
        UPDATE `guildwar_kills`
        SET `target_guild` = `targetguild`
        WHERE (`target_guild` IS NULL OR `target_guild` = 0) AND `targetguild` != 0;
    ]])
end

migrateDatabase()

-- Helper: Get guild row by guild ID
function GuildSystem.getGuildData(guildId)
    if not guildId or guildId <= 0 then return nil end
    local query = string.format("SELECT * FROM `guilds` WHERE `id` = %d LIMIT 1", guildId)
    local res = db.storeQuery(query)
    if not res then return nil end

    local data = {
        id = result.getNumber(res, "id"),
        name = result.getString(res, "name"),
        ownerid = result.getNumber(res, "ownerid"),
        creationdata = result.getNumber(res, "creationdata"),
        motd = result.getString(res, "motd") or "",
        tag = result.getString(res, "tag") or "",
        level = result.getNumber(res, "level") or 1,
        gold = result.getNumber(res, "gold") or 0,
        emblem = result.getNumber(res, "emblem") or 1,
        join_status = result.getString(res, "join_status") or "Public",
        required_level = result.getNumber(res, "required_level") or 1,
        language = result.getString(res, "language") or "Polish",
        pacifist_mode = result.getNumber(res, "pacifist_mode") or 0,
        pacifist_date = result.getNumber(res, "pacifist_date") or 0,
        wars_won = result.getNumber(res, "wars_won") or 0,
        wars_lost = result.getNumber(res, "wars_lost") or 0,
    }
    result.free(res)
    return data
end

-- Helper: Get guild tag by guild ID
function GuildSystem.getGuildTag(guildId)
    if not guildId or guildId <= 0 then return "" end
    local query = string.format("SELECT `tag` FROM `guilds` WHERE `id` = %d LIMIT 1", guildId)
    local res = db.storeQuery(query)
    if not res then return "" end
    local tag = result.getString(res, "tag") or ""
    result.free(res)
    return tag
end

-- Helper: Get member contribution
function GuildSystem.getMemberContribution(playerId, guildId)
    local query = string.format("SELECT `contribution` FROM `guild_membership` WHERE `player_id` = %d AND `guild_id` = %d LIMIT 1", playerId, guildId)
    local res = db.storeQuery(query)
    if not res then return 0 end
    local contrib = result.getNumber(res, "contribution") or 0
    result.free(res)
    return contrib
end

-- Helper: Update player's creature title with Guild Tag
function Player:updateGuildTitle()
    local championName = self:getVocation():getName()
    if self:getGroup():getId() == 3 then
        self:setTitle("Game Master", "Reggae One-10px-bordered", "#0dff00")
        return
    end

    if not championName or championName == "None" then
        return
    end

    local tag = ""
    local res = db.storeQuery(string.format("SELECT g.tag FROM `guild_membership` gm JOIN `guilds` g ON gm.guild_id = g.id WHERE gm.player_id = %d LIMIT 1", self:getGuid()))
    if res then
        tag = result.getString(res, "tag") or ""
        result.free(res)
    else
        pcall(function() self:setGuild(nil) end)
    end

    if tag and tag ~= "" then
        self:setTitle("[" .. tag .. "] " .. championName, "Reggae One-10px-bordered", "#0dff00")
    else
        self:setTitle(championName, "Reggae One-10px-bordered", "#0dff00")
    end
end

-- Guild level caching & retrieval
GuildSystem.guildLevelCache = {}

function GuildSystem.getGuildLevel(guildId)
    if not guildId or guildId <= 0 then return 0 end
    if GuildSystem.guildLevelCache[guildId] then
        return GuildSystem.guildLevelCache[guildId]
    end
    local query = string.format("SELECT `level` FROM `guilds` WHERE `id` = %d LIMIT 1", guildId)
    local res = db.storeQuery(query)
    if res then
        local lvl = result.getNumber(res, "level") or 1
        result.free(res)
        GuildSystem.guildLevelCache[guildId] = lvl
        return lvl
    end
    return 0
end

-- Buff management (Stats recalculated dynamically in Player:setCollectionInfo())
function GuildSystem.applyGuildBuffs(player, guildLevel)
    if not player then return end
    pcall(function()
        player:removeCondition(CONDITION_REGENERATION, CONDITION_SUBID, GuildSystem.SUBID_BUFF_REGEN)
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITION_SUBID, GuildSystem.SUBID_BUFF_HEALTH)
    end)
    player:setCollectionInfo()
end

function GuildSystem.removeGuildBuffs(player)
    if not player then return end
    pcall(function()
        player:removeCondition(CONDITION_REGENERATION, CONDITION_SUBID, GuildSystem.SUBID_BUFF_REGEN)
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITION_SUBID, GuildSystem.SUBID_BUFF_HEALTH)
    end)
    player:setCollectionInfo()
end

-- Broadcast message to all online guild members
function GuildSystem.broadcastToGuild(guildId, message, msgType)
    if not guildId or guildId <= 0 then return end
    msgType = msgType or MESSAGE_INFO_DESCR
    local mQuery = string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId)
    local allM = db.storeQuery(mQuery)
    if allM then
        repeat
            local memName = result.getString(allM, "name")
            local memPlayer = Player(memName)
            if memPlayer then
                memPlayer:sendTextMessage(msgType, message)
            end
        until not result.next(allM)
        result.free(allM)
    end
end

-- Broadcast updated opcode payload to all online guild members
function GuildSystem.broadcastPayloadToGuild(guildId)
    if not guildId or guildId <= 0 then return end
    local mQuery = string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId)
    local allM = db.storeQuery(mQuery)
    if allM then
        repeat
            local memName = result.getString(allM, "name")
            local memPlayer = Player(memName)
            if memPlayer then
                memPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(memPlayer)))
            end
        until not result.next(allM)
        result.free(allM)
    end
end

-- Check and resolve expired wars
function GuildSystem.checkExpiredWars()
    local now = os.time()
    local query = string.format("SELECT * FROM `guild_wars` WHERE `ended` = 0 AND `status` = 1 AND `end_date` > 0 AND `end_date` <= %d", now)
    local res = db.storeQuery(query)
    if not res then return end

    repeat
        local warId = result.getNumber(res, "id")
        local g1 = result.getNumber(res, "guild1")
        local g2 = result.getNumber(res, "guild2")
        local g1Kills = result.getNumber(res, "guild1_kills")
        local g2Kills = result.getNumber(res, "guild2_kills")
        local goldBet = result.getNumber(res, "gold_bet")
        local totalPot = goldBet * 2

        db.query(string.format("UPDATE `guild_wars` SET `ended` = 1, `status` = 4 WHERE `id` = %d", warId))

        if g1Kills > g2Kills then
            db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d, `wars_won` = `wars_won` + 1 WHERE `id` = %d", totalPot, g1))
            db.query(string.format("UPDATE `guilds` SET `wars_lost` = `wars_lost` + 1 WHERE `id` = %d", g2))
            local winData = GuildSystem.getGuildData(g1)
            local msg = string.format("★ WAR EXPIRED! Guild '%s' won by kill advantage (%d vs %d) and took the %s gold pot!", winData and winData.name or "Guild 1", g1Kills, g2Kills, comma_value(totalPot))
            GuildSystem.broadcastToGuild(g1, msg, MESSAGE_EVENT_ADVANCE)
            GuildSystem.broadcastToGuild(g2, msg, MESSAGE_EVENT_ADVANCE)
        elseif g2Kills > g1Kills then
            db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d, `wars_won` = `wars_won` + 1 WHERE `id` = %d", totalPot, g2))
            db.query(string.format("UPDATE `guilds` SET `wars_lost` = `wars_lost` + 1 WHERE `id` = %d", g1))
            local winData = GuildSystem.getGuildData(g2)
            local msg = string.format("★ WAR EXPIRED! Guild '%s' won by kill advantage (%d vs %d) and took the %s gold pot!", winData and winData.name or "Guild 2", g2Kills, g1Kills, comma_value(totalPot))
            GuildSystem.broadcastToGuild(g1, msg, MESSAGE_EVENT_ADVANCE)
            GuildSystem.broadcastToGuild(g2, msg, MESSAGE_EVENT_ADVANCE)
        else
            db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d WHERE `id` = %d", goldBet, g1))
            db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d WHERE `id` = %d", goldBet, g2))
            local msg = "★ WAR EXPIRED! The war ended in a draw! Gold bets have been refunded to both guilds."
            GuildSystem.broadcastToGuild(g1, msg, MESSAGE_EVENT_ADVANCE)
            GuildSystem.broadcastToGuild(g2, msg, MESSAGE_EVENT_ADVANCE)
        end
    until not result.next(res)
    result.free(res)
end

-- Get list of guilds available to declare war against
function GuildSystem.getAvailableWarGuilds(myGuildId)
    local list = {}
    local query = string.format([[
        SELECT g.id, g.name, g.tag, g.level, g.gold, g.emblem, g.pacifist_mode, g.wars_won, g.wars_lost, p.name AS leader_name,
        (SELECT COUNT(*) FROM `guild_membership` WHERE `guild_id` = g.id) AS member_count,
        (SELECT COALESCE(SUM(pl.level), 0) FROM `guild_membership` gm JOIN `players` pl ON gm.player_id = pl.id WHERE gm.guild_id = g.id) AS total_level
        FROM `guilds` g
        LEFT JOIN `players` p ON g.ownerid = p.id
        WHERE g.id != %d
        ORDER BY g.level DESC, g.name ASC
    ]], myGuildId)
    local res = db.storeQuery(query)
    if res then
        repeat
            local mCount = result.getNumber(res, "member_count") or 1
            local tLevel = result.getNumber(res, "total_level") or 1
            table.insert(list, {
                id = result.getNumber(res, "id"),
                name = result.getString(res, "name"),
                tag = result.getString(res, "tag") or "",
                level = result.getNumber(res, "level") or 1,
                emblem = result.getNumber(res, "emblem") or 1,
                leaderName = result.getString(res, "leader_name") or "Unknown",
                memberCount = mCount,
                totalLevels = tLevel,
                avgLevel = math.floor(tLevel / math.max(1, mCount)),
                warsWon = result.getNumber(res, "wars_won") or 0,
                warsLost = result.getNumber(res, "wars_lost") or 0,
                pacifistMode = (result.getNumber(res, "pacifist_mode") == 1),
            })
        until not result.next(res)
        result.free(res)
    end
    return list
end

-- Get wars for a guild
function GuildSystem.getGuildWars(guildId)
    GuildSystem.checkExpiredWars()

    local list = {}
    local query = string.format([[
        SELECT * FROM `guild_wars`
        WHERE (`guild1` = %d OR `guild2` = %d)
        ORDER BY `ended` ASC, `id` DESC
    ]], guildId, guildId)
    local res = db.storeQuery(query)
    if res then
        repeat
            local warId = result.getNumber(res, "id")
            local g1 = result.getNumber(res, "guild1")
            local g2 = result.getNumber(res, "guild2")
            local n1 = result.getString(res, "name1")
            local n2 = result.getString(res, "name2")
            local status = result.getNumber(res, "status")
            local ended = result.getNumber(res, "ended")
            local started = result.getNumber(res, "started")
            local endDate = result.getNumber(res, "end_date")
            local duration = result.getNumber(res, "duration")
            local killsLimit = result.getNumber(res, "kills_limit")
            local g1Kills = result.getNumber(res, "guild1_kills")
            local g2Kills = result.getNumber(res, "guild2_kills")
            local goldBet = result.getNumber(res, "gold_bet")
            local forced = (result.getNumber(res, "forced") == 1)

            local isGuild1 = (guildId == g1)
            local enemyGuildId = isGuild1 and g2 or g1
            local enemyData = GuildSystem.getGuildData(enemyGuildId)
            local ourData = GuildSystem.getGuildData(guildId)

            local statusText = "Inactive"
            if ended == 1 then
                if status == 2 then statusText = "Rejected"
                elseif status == 3 then statusText = "Revoked"
                else statusText = "Ended" end
            elseif status == 0 then
                statusText = isGuild1 and "Declaration Sent" or "Declaration Received"
            elseif status == 1 then
                statusText = "Active War"
            end

            -- Fetch latest kills for this war
            local killsList = {}
            local kRes = db.storeQuery(string.format([[
                SELECT 
                    COALESCE(NULLIF(`killer_name`, ''), `killer`) AS `killer_name`,
                    COALESCE(NULLIF(`target_name`, ''), `target`) AS `target_name`,
                    IF(`killer_guild` != 0, `killer_guild`, `killerguild`) AS `killer_guild`,
                    IF(`target_guild` != 0, `target_guild`, `targetguild`) AS `target_guild`,
                    `time`
                FROM `guildwar_kills`
                WHERE `warid` = %d
                ORDER BY `time` DESC LIMIT 30
            ]], warId))
            if kRes then
                repeat
                    table.insert(killsList, {
                        killerName = result.getString(kRes, "killer_name"),
                        targetName = result.getString(kRes, "target_name"),
                        killerGuild = result.getNumber(kRes, "killer_guild"),
                        targetGuild = result.getNumber(kRes, "target_guild"),
                        timeStr = os.date("%H:%M:%S", result.getNumber(kRes, "time")),
                        dateStr = os.date("%d/%m/%Y %H:%M", result.getNumber(kRes, "time")),
                    })
                until not result.next(kRes)
                result.free(kRes)
            end

            local resultText = nil
            if ended == 1 then
                if status == 2 then resultText = "Rejected"
                elseif status == 3 then resultText = "Revoked"
                elseif status == 4 then
                    local myK = isGuild1 and g1Kills or g2Kills
                    local enK = isGuild1 and g2Kills or g1Kills
                    if myK > enK then resultText = "Victory"
                    elseif myK < enK then resultText = "Defeat"
                    else resultText = "Draw" end
                else
                    resultText = "Ended"
                end
            end

            table.insert(list, {
                id = warId,
                isGuild1 = isGuild1,
                myGuildId = guildId,
                myGuildName = ourData and ourData.name or (isGuild1 and n1 or n2),
                myGuildEmblem = ourData and ourData.emblem or 1,
                myKills = isGuild1 and g1Kills or g2Kills,
                enemyGuildId = enemyGuildId,
                enemyGuildName = enemyData and enemyData.name or (isGuild1 and n2 or n1),
                enemyGuildEmblem = enemyData and enemyData.emblem or 1,
                enemyKills = isGuild1 and g2Kills or g1Kills,
                status = status,
                statusText = statusText,
                resultText = resultText,
                ended = ended,
                killsLimit = killsLimit,
                goldBet = goldBet,
                goldPot = goldBet * 2,
                started = started,
                endDate = endDate,
                endDateStr = endDate > 0 and os.date("%d/%m/%Y %H:%M", endDate) or "Pending Start",
                forced = forced,
                latestKills = killsList
            })
        until not result.next(res)
        result.free(res)
    end
    return list
end

-- Build guild payload for client
function GuildSystem.buildGuildPayload(player)
    local playerGuid = player:getGuid()
    local guildId = nil

    -- Check database as the single source of truth for guild membership
    local res = db.storeQuery(string.format("SELECT `guild_id` FROM `guild_membership` WHERE `player_id` = %d LIMIT 1", playerGuid))
    if res then
        guildId = result.getNumber(res, "guild_id")
        result.free(res)
    else
        pcall(function() player:setGuild(nil) end)
    end

    -- Fetch Top Guilds list for the browser tab
    local topGuilds = {}
    local topRes = db.storeQuery([[
        SELECT g.id, g.name, g.tag, g.level, g.gold, g.emblem, g.join_status, g.required_level,
               g.wars_won, g.wars_lost,
               p.name AS leader_name,
               (SELECT COUNT(*) FROM `guild_membership` WHERE `guild_id` = g.id) AS member_count
        FROM `guilds` g
        LEFT JOIN `players` p ON g.ownerid = p.id
        ORDER BY g.level DESC, g.wars_won DESC, g.gold DESC
        LIMIT 20
    ]])
    if topRes then
        repeat
            table.insert(topGuilds, {
                id = result.getNumber(topRes, "id"),
                name = result.getString(topRes, "name"),
                tag = result.getString(topRes, "tag") or "",
                level = result.getNumber(topRes, "level") or 1,
                gold = result.getNumber(topRes, "gold") or 0,
                emblem = result.getNumber(topRes, "emblem") or 1,
                joinStatus = result.getString(topRes, "join_status") or "Public",
                requiredLevel = result.getNumber(topRes, "required_level") or 1,
                leaderName = result.getString(topRes, "leader_name") or "Unknown",
                memberCount = result.getNumber(topRes, "member_count") or 1,
                warsWon = result.getNumber(topRes, "wars_won") or 0,
                warsLost = result.getNumber(topRes, "wars_lost") or 0,
            })
        until not result.next(topRes)
        result.free(topRes)
    end

    if not guildId then
        return {
            hasGuild = false,
            createReq = {
                level = GuildSystem.CREATE_LEVEL_REQ,
                cost = GuildSystem.CREATE_COST,
                maxTagLength = GuildSystem.MAX_TAG_LENGTH,
                maxNameLength = GuildSystem.MAX_NAME_LENGTH
            },
            topGuilds = topGuilds,
            buffsConfig = GuildSystem.BUFFS
        }
    end

    local gData = GuildSystem.getGuildData(guildId)
    if not gData then
        return {
            hasGuild = false,
            createReq = {
                level = GuildSystem.CREATE_LEVEL_REQ,
                cost = GuildSystem.CREATE_COST,
                maxTagLength = GuildSystem.MAX_TAG_LENGTH,
                maxNameLength = GuildSystem.MAX_NAME_LENGTH
            },
            topGuilds = topGuilds,
            buffsConfig = GuildSystem.BUFFS
        }
    end

    -- Members list
    local members = {}
    local totalLevels = 0
    local leaderName = "Unknown"
    local playerRankLevel = 1
    local playerRankName = "Member"

    local mRes = db.storeQuery(string.format("SELECT gm.player_id, gm.contribution, gm.nick, gr.name AS rank_name, gr.level AS rank_level, p.name, p.level, p.vocation FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d ORDER BY gr.level DESC, p.level DESC", guildId))
    if mRes then
        repeat
            local mGuid = result.getNumber(mRes, "player_id")
            local mName = result.getString(mRes, "name")
            local mLevel = result.getNumber(mRes, "level")
            local mVocId = result.getNumber(mRes, "vocation")
            local mRankName = result.getString(mRes, "rank_name")
            local mRankLevel = result.getNumber(mRes, "rank_level")
            local mContrib = result.getNumber(mRes, "contribution") or 0
            local mOnline = Player(mName) ~= nil

            totalLevels = totalLevels + mLevel

            if mGuid == gData.ownerid or mRankLevel == 3 then
                leaderName = mName
            end

            if mGuid == playerGuid then
                playerRankLevel = mRankLevel
                playerRankName = mRankName
            end

            table.insert(members, {
                guid = mGuid,
                name = mName,
                level = mLevel,
                vocation = mVocId,
                rankName = mRankName,
                rankLevel = mRankLevel,
                contribution = mContrib,
                online = mOnline
            })
        until not result.next(mRes)
        result.free(mRes)
    end

    local curLevel = gData.level
    local nextLevel = curLevel + 1
    local nextConfig = GuildSystem.LEVEL_CONFIG[nextLevel]
    local nextCost = nextConfig and nextConfig.cost or 0
    local curConfig = GuildSystem.LEVEL_CONFIG[curLevel] or { maxMembers = 10 }
    local maxMembers = curConfig.maxMembers

    -- Applications list (for leadership)
    local applications = {}
    if playerRankLevel >= 2 then
        local aRes = db.storeQuery(string.format("SELECT ga.player_id, ga.date, p.name, p.level, p.vocation FROM `guild_applications` ga JOIN `players` p ON ga.player_id = p.id WHERE ga.guild_id = %d AND ga.status = 'pending' ORDER BY ga.date DESC", guildId))
        if aRes then
            repeat
                table.insert(applications, {
                    guid = result.getNumber(aRes, "player_id"),
                    name = result.getString(aRes, "name"),
                    level = result.getNumber(aRes, "level"),
                    vocation = result.getNumber(aRes, "vocation"),
                    date = result.getNumber(aRes, "date")
                })
            until not result.next(aRes)
            result.free(aRes)
        end
    end

    return {
        hasGuild = true,
        guild = {
            id = gData.id,
            name = gData.name,
            tag = gData.tag,
            level = curLevel,
            gold = gData.gold,
            emblem = gData.emblem,
            joinStatus = gData.join_status,
            requiredLevel = gData.required_level,
            language = gData.language,
            motd = gData.motd,
            nextCost = nextCost,
            canLevelUp = (nextConfig ~= nil) and (gData.gold >= nextCost),
            maxMembers = maxMembers,
            memberCount = #members,
            leaderName = leaderName,
            totalLevels = totalLevels,
            yourContribution = GuildSystem.getMemberContribution(playerGuid, guildId),
            playerRankLevel = playerRankLevel,
            playerRankName = playerRankName,
            isLeader = (playerRankLevel >= 3 or gData.ownerid == playerGuid),
            isVice = (playerRankLevel >= 2),
            pacifistMode = (gData.pacifist_mode == 1),
            pacifistDate = gData.pacifist_date > 0 and os.date("%H:%M:%S %m/%d/%y", gData.pacifist_date) or "Inactive",
            warsWon = gData.wars_won or 0,
            warsLost = gData.wars_lost or 0,
            wars = GuildSystem.getGuildWars(guildId),
            availableGuilds = GuildSystem.getAvailableWarGuilds(guildId),
        },
        members = members,
        applications = applications,
        buffsConfig = GuildSystem.BUFFS,
        topGuilds = topGuilds
    }
end

-- Extended Opcode Handler
local ExtendedEvent = CreatureEvent("GuildSystemExtendedOpcode")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= GuildSystem.OPCODE then return false end

    local status, data = pcall(function() return json.decode(buffer) end)
    if not status or type(data) ~= "table" then return false end

    local action = data.action

    if action == "fetch" then
        player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
        return true

    elseif action == "create" then
        -- Guild creation requirements
        local name = (data.name or ""):gsub("^%s*(.-)%s*$", "%1")
        local tag = (data.tag or ""):gsub("^%s*(.-)%s*$", "%1"):upper()
        local emblem = tonumber(data.emblem) or 1
        local joinStatus = data.joinStatus or "Public"
        local reqLevel = tonumber(data.requiredLevel) or 1
        local language = data.language or "Polish"

        if player:getLevel() < GuildSystem.CREATE_LEVEL_REQ then
            player:sendCancelMessage(string.format("You need level %d or higher to create a guild.", GuildSystem.CREATE_LEVEL_REQ))
            return true
        end

        local totalMoney = player:getMoney() + player:getBankBalance()
        if totalMoney < GuildSystem.CREATE_COST then
            player:sendCancelMessage(string.format("You need %s gold to create a guild.", comma_value(GuildSystem.CREATE_COST)))
            return true
        end

        if #name < 3 or #name > GuildSystem.MAX_NAME_LENGTH then
            player:sendCancelMessage(string.format("Guild name must be between 3 and %d characters.", GuildSystem.MAX_NAME_LENGTH))
            return true
        end

        if #tag < 1 or #tag > GuildSystem.MAX_TAG_LENGTH then
            player:sendCancelMessage(string.format("Guild tag must be between 1 and %d characters.", GuildSystem.MAX_TAG_LENGTH))
            return true
        end

        if not name:match("^[A-Za-z0-9 %-_]+$") then
            player:sendCancelMessage("Guild name contains invalid characters.")
            return true
        end

        if not tag:match("^[A-Za-z0-9]+$") then
            player:sendCancelMessage("Guild tag can only contain letters and numbers.")
            return true
        end

        -- Check existing player guild membership
        local playerGuid = player:getGuid()
        local existingCheck = db.storeQuery(string.format("SELECT `guild_id` FROM `guild_membership` WHERE `player_id` = %d LIMIT 1", playerGuid))
        if existingCheck then
            result.free(existingCheck)
            player:sendCancelMessage("You are already in a guild!")
            return true
        end

        -- Check name uniqueness
        local nameEsc = db.escapeString(name)
        local tagEsc = db.escapeString(tag)
        local nameCheck = db.storeQuery(string.format("SELECT `id` FROM `guilds` WHERE `name` = %s LIMIT 1", nameEsc))
        if nameCheck then
            result.free(nameCheck)
            player:sendCancelMessage("A guild with this name already exists!")
            return true
        end

        local tagCheck = db.storeQuery(string.format("SELECT `id` FROM `guilds` WHERE `tag` = %s LIMIT 1", tagEsc))
        if tagCheck then
            result.free(tagCheck)
            player:sendCancelMessage("A guild with this tag already exists!")
            return true
        end

        -- Remove creation cost
        if not player:removeTotalMoney(GuildSystem.CREATE_COST) then
            player:sendCancelMessage("Failed to deduct gold for guild creation.")
            return true
        end

        -- Insert Guild
        local now = os.time()
        local insertGuildQuery = string.format("INSERT INTO `guilds` (`name`, `ownerid`, `creationdata`, `motd`, `tag`, `level`, `gold`, `emblem`, `join_status`, `required_level`, `language`) VALUES (%s, %d, %d, 'Welcome to our guild!', %s, 1, 0, %d, %s, %d, %s)",
            nameEsc, playerGuid, now, tagEsc, emblem, db.escapeString(joinStatus), reqLevel, db.escapeString(language))
        db.query(insertGuildQuery)

        local newGuildRes = db.storeQuery(string.format("SELECT `id` FROM `guilds` WHERE `name` = %s LIMIT 1", nameEsc))
        if not newGuildRes then
            player:sendCancelMessage("Failed to retrieve created guild.")
            return true
        end
        local newGuildId = result.getNumber(newGuildRes, "id")
        result.free(newGuildRes)

        -- Insert Ranks (Leader lvl 3, Vice-Leader lvl 2, Member lvl 1)
        db.query(string.format("INSERT INTO `guild_ranks` (`guild_id`, `name`, `level`) VALUES (%d, 'Leader', 3)", newGuildId))
        db.query(string.format("INSERT INTO `guild_ranks` (`guild_id`, `name`, `level`) VALUES (%d, 'Vice-Leader', 2)", newGuildId))
        db.query(string.format("INSERT INTO `guild_ranks` (`guild_id`, `name`, `level`) VALUES (%d, 'Member', 1)", newGuildId))

        local rankRes = db.storeQuery(string.format("SELECT `id` FROM `guild_ranks` WHERE `guild_id` = %d AND `level` = 3 LIMIT 1", newGuildId))
        local leaderRankId = 1
        if rankRes then
            leaderRankId = result.getNumber(rankRes, "id")
            result.free(rankRes)
        end

        -- Insert Leader Membership
        db.query(string.format("INSERT INTO `guild_membership` (`player_id`, `guild_id`, `rank_id`, `nick`, `contribution`) VALUES (%d, %d, %d, '', 0)",
            playerGuid, newGuildId, leaderRankId))

        -- Update player in game
        player:updateGuildTitle()
        GuildSystem.applyGuildBuffs(player, 1)

        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Congratulations! Guild '%s' [%s] has been created!", name, tag))
        player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
        return true

    elseif action == "donate" then
        local amount = tonumber(data.amount)
        if not amount or amount < 1 or amount > 10000 then
            player:sendCancelMessage("Donation amount must be between 1 and 10,000 gold.")
            return true
        end

        amount = math.floor(amount)
        local bankBalance = player:getBankBalance()
        if bankBalance < amount then
            player:sendCancelMessage("You do not have enough gold in your bank balance to donate that amount.")
            return true
        end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT `guild_id` FROM `guild_membership` WHERE `player_id` = %d LIMIT 1", playerGuid))
        if not gRes then
            player:sendCancelMessage("You are not in a guild.")
            return true
        end
        local guildId = result.getNumber(gRes, "guild_id")
        result.free(gRes)

        -- Deduct strictly from bank balance (not backpack gold)
        player:setBankBalance(bankBalance - amount)

        -- Update DB
        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d WHERE `id` = %d", amount, guildId))
        db.query(string.format("UPDATE `guild_membership` SET `contribution` = `contribution` + %d WHERE `player_id` = %d AND `guild_id` = %d", amount, playerGuid, guildId))

        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You deposited %s gold from your bank balance into the guild fund.", comma_value(amount)))

        -- Broadcast to online guild members
        local mQuery = string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId)
        local allM = db.storeQuery(mQuery)
        if allM then
            repeat
                local memName = result.getString(allM, "name")
                local memPlayer = Player(memName)
                if memPlayer then
                    memPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(memPlayer)))
                end
            until not result.next(allM)
            result.free(allM)
        end
        return true

    elseif action == "levelUp" then
        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then
            player:sendCancelMessage("You are not in a guild.")
            return true
        end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only the Guild Leader or Vice-Leader can level up the guild.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)
        if not gData then return true end

        local curLevel = gData.level
        local nextLevel = curLevel + 1
        local nextConfig = GuildSystem.LEVEL_CONFIG[nextLevel]
        if not nextConfig then
            player:sendCancelMessage("Your guild has reached the maximum level!")
            return true
        end

        if gData.gold < nextConfig.cost then
            player:sendCancelMessage(string.format("The guild needs %s gold to level up. Current gold: %s.", comma_value(nextConfig.cost), comma_value(gData.gold)))
            return true
        end

        -- Deduct guild gold & level up
        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` - %d, `level` = %d WHERE `id` = %d", nextConfig.cost, nextLevel, guildId))
        GuildSystem.guildLevelCache[guildId] = nextLevel

        -- Notify and update all online members
        local allM = db.storeQuery(string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId))
        if allM then
            repeat
                local memName = result.getString(allM, "name")
                local memPlayer = Player(memName)
                if memPlayer then
                    GuildSystem.applyGuildBuffs(memPlayer, nextLevel)
                    memPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("★ Guild '%s' has advanced to Level %d! New bonuses are now active!", gData.name, nextLevel))
                    memPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(memPlayer)))
                end
            until not result.next(allM)
            result.free(allM)
        end
        return true

    elseif action == "settings" then
        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can alter settings.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)
        if not gData then return true end

        local motd = data.motd ~= nil and data.motd or gData.motd
        local emblem = tonumber(data.emblem) or gData.emblem
        local joinStatus = data.joinStatus or gData.join_status
        local reqLevel = tonumber(data.requiredLevel) or gData.required_level
        local language = data.language or gData.language

        db.query(string.format("UPDATE `guilds` SET `motd` = %s, `emblem` = %d, `join_status` = %s, `required_level` = %d, `language` = %s WHERE `id` = %d",
            db.escapeString(motd), emblem, db.escapeString(joinStatus), reqLevel, db.escapeString(language), guildId))

        player:sendTextMessage(MESSAGE_INFO_DESCR, "Guild settings updated successfully.")

        -- Broadcast to online guild members
        local allM = db.storeQuery(string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId))
        if allM then
            repeat
                local memName = result.getString(allM, "name")
                local memPlayer = Player(memName)
                if memPlayer then
                    memPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(memPlayer)))
                end
            until not result.next(allM)
            result.free(allM)
        end
        return true

    elseif action == "join" then
        local targetGuildId = tonumber(data.guildId)
        if not targetGuildId then return true end

        local playerGuid = player:getGuid()
        local existCheck = db.storeQuery(string.format("SELECT `guild_id` FROM `guild_membership` WHERE `player_id` = %d LIMIT 1", playerGuid))
        if existCheck then
            result.free(existCheck)
            player:sendCancelMessage("You are already in a guild!")
            return true
        end

        local gData = GuildSystem.getGuildData(targetGuildId)
        if not gData then
            player:sendCancelMessage("Guild does not exist.")
            return true
        end

        if gData.join_status == "Closed" then
            player:sendCancelMessage("This guild is currently closed for new members.")
            return true
        end

        if player:getLevel() < gData.required_level then
            player:sendCancelMessage(string.format("You must be level %d or higher to join this guild.", gData.required_level))
            return true
        end

        local countRes = db.storeQuery(string.format("SELECT COUNT(*) AS count FROM `guild_membership` WHERE `guild_id` = %d", targetGuildId))
        local mCount = 0
        if countRes then
            mCount = result.getNumber(countRes, "count")
            result.free(countRes)
        end

        local curConfig = GuildSystem.LEVEL_CONFIG[gData.level] or { maxMembers = 10 }
        if mCount >= curConfig.maxMembers then
            player:sendCancelMessage("This guild has reached the maximum member capacity!")
            return true
        end

        -- Check join policy: Approval / By Request
        if gData.join_status == "Approval" or gData.join_status == "Invite Only" then
            local pendCheck = db.storeQuery(string.format("SELECT `id` FROM `guild_applications` WHERE `guild_id` = %d AND `player_id` = %d AND `status` = 'pending' LIMIT 1", targetGuildId, playerGuid))
            if pendCheck then
                result.free(pendCheck)
                player:sendCancelMessage("You have already sent a join request to this guild.")
                return true
            end

            db.query(string.format("INSERT INTO `guild_applications` (`guild_id`, `player_id`, `date`, `status`) VALUES (%d, %d, %d, 'pending')", targetGuildId, playerGuid, os.time()))
            player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Your request to join '%s' has been sent! Waiting for leadership approval.", gData.name))

            -- Notify online leaders/vices of the guild
            local lQuery = string.format("SELECT p.name FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d AND gr.level >= 2", targetGuildId)
            local lRes = db.storeQuery(lQuery)
            if lRes then
                repeat
                    local lName = result.getString(lRes, "name")
                    local lPlayer = Player(lName)
                    if lPlayer then
                        lPlayer:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Guild]: %s has requested to join your guild! Check the Inbox tab.", player:getName()))
                        lPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(lPlayer)))
                    end
                until not result.next(lRes)
                result.free(lRes)
            end
            return true
        end

        -- Direct join (Public / Anyone)
        local rRes = db.storeQuery(string.format("SELECT `id` FROM `guild_ranks` WHERE `guild_id` = %d AND `level` = 1 LIMIT 1", targetGuildId))
        local memberRankId = 1
        if rRes then
            memberRankId = result.getNumber(rRes, "id")
            result.free(rRes)
        end

        db.query(string.format("INSERT INTO `guild_membership` (`player_id`, `guild_id`, `rank_id`, `nick`, `contribution`) VALUES (%d, %d, %d, '', 0)",
            playerGuid, targetGuildId, memberRankId))

        player:updateGuildTitle()
        GuildSystem.applyGuildBuffs(player, gData.level)

        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You have joined '%s' [%s]!", gData.name, gData.tag))
        player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
        return true

    elseif action == "accept_application" then
        local targetGuid = tonumber(data.targetGuid)
        if not targetGuid then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only the Guild Leader or Vice-Leader can approve applications.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)
        if not gData then return true end

        -- Check guild capacity
        local countRes = db.storeQuery(string.format("SELECT COUNT(*) AS count FROM `guild_membership` WHERE `guild_id` = %d", guildId))
        local mCount = 0
        if countRes then
            mCount = result.getNumber(countRes, "count")
            result.free(countRes)
        end
        local curConfig = GuildSystem.LEVEL_CONFIG[gData.level] or { maxMembers = 10 }
        if mCount >= curConfig.maxMembers then
            player:sendCancelMessage("The guild has reached the maximum member capacity!")
            return true
        end

        -- Check if target is already in a guild
        local checkTarget = db.storeQuery(string.format("SELECT `guild_id` FROM `guild_membership` WHERE `player_id` = %d LIMIT 1", targetGuid))
        if checkTarget then
            result.free(checkTarget)
            db.query(string.format("DELETE FROM `guild_applications` WHERE `guild_id` = %d AND `player_id` = %d", guildId, targetGuid))
            player:sendCancelMessage("That player is already in a guild.")
            player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
            return true
        end

        -- Default Member rank
        local rRes = db.storeQuery(string.format("SELECT `id` FROM `guild_ranks` WHERE `guild_id` = %d AND `level` = 1 LIMIT 1", guildId))
        local memberRankId = 1
        if rRes then
            memberRankId = result.getNumber(rRes, "id")
            result.free(rRes)
        end

        db.query(string.format("INSERT INTO `guild_membership` (`player_id`, `guild_id`, `rank_id`, `nick`, `contribution`) VALUES (%d, %d, %d, '', 0)",
            targetGuid, guildId, memberRankId))
        db.query(string.format("DELETE FROM `guild_applications` WHERE `guild_id` = %d AND `player_id` = %d", guildId, targetGuid))

        -- If target player is online, notify and update them
        local targetRes = db.storeQuery(string.format("SELECT `name` FROM `players` WHERE `id` = %d LIMIT 1", targetGuid))
        if targetRes then
            local targetName = result.getString(targetRes, "name")
            result.free(targetRes)
            local targetPlayer = Player(targetName)
            if targetPlayer then
                targetPlayer:updateGuildTitle()
                GuildSystem.applyGuildBuffs(targetPlayer, gData.level)
                targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Congratulations! You were accepted into '%s' [%s]!", gData.name, gData.tag))
                targetPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(targetPlayer)))
            end
        end

        player:sendTextMessage(MESSAGE_INFO_DESCR, "Application accepted.")

        -- Broadcast to online members
        local allM = db.storeQuery(string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId))
        if allM then
            repeat
                local memName = result.getString(allM, "name")
                local memPlayer = Player(memName)
                if memPlayer then
                    memPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(memPlayer)))
                end
            until not result.next(allM)
            result.free(allM)
        end
        return true

    elseif action == "reject_application" then
        local targetGuid = tonumber(data.targetGuid)
        if not targetGuid then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only the Guild Leader or Vice-Leader can reject applications.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)

        db.query(string.format("DELETE FROM `guild_applications` WHERE `guild_id` = %d AND `player_id` = %d", guildId, targetGuid))

        local targetRes = db.storeQuery(string.format("SELECT `name` FROM `players` WHERE `id` = %d LIMIT 1", targetGuid))
        if targetRes then
            local targetName = result.getString(targetRes, "name")
            result.free(targetRes)
            local targetPlayer = Player(targetName)
            if targetPlayer and gData then
                targetPlayer:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Your request to join '%s' was declined.", gData.name))
            end
        end

        player:sendTextMessage(MESSAGE_INFO_DESCR, "Application rejected.")
        player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
        return true

    elseif action == "leave" then
        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level, g.ownerid FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id JOIN `guilds` g ON gm.guild_id = g.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then
            player:sendCancelMessage("You are not in a guild.")
            return true
        end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        local ownerId = result.getNumber(gRes, "ownerid")
        result.free(gRes)

        if playerGuid == ownerId then
            player:sendCancelMessage("The Guild Leader cannot leave the guild! You must disband it or transfer leadership.")
            return true
        end

        db.query(string.format("DELETE FROM `guild_membership` WHERE `player_id` = %d AND `guild_id` = %d", playerGuid, guildId))

        pcall(function() player:setGuild(nil) end)
        GuildSystem.removeGuildBuffs(player)
        player:updateGuildTitle()
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have left the guild.")
        player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
        return true

    elseif action == "disband" then
        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT g.id, g.name, g.ownerid FROM `guilds` g JOIN `guild_membership` gm ON g.id = gm.guild_id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then
            player:sendCancelMessage("You are not in a guild.")
            return true
        end
        local guildId = result.getNumber(gRes, "id")
        local guildName = result.getString(gRes, "name")
        local ownerId = result.getNumber(gRes, "ownerid")
        result.free(gRes)

        if playerGuid ~= ownerId then
            player:sendCancelMessage("Only the Guild Leader can disband the guild.")
            return true
        end

        -- Update all online members
        local allM = db.storeQuery(string.format("SELECT p.name FROM `guild_membership` gm JOIN `players` p ON gm.player_id = p.id WHERE gm.guild_id = %d", guildId))
        if allM then
            repeat
                local memName = result.getString(allM, "name")
                local memPlayer = Player(memName)
                if memPlayer then
                    pcall(function() memPlayer:setGuild(nil) end)
                    GuildSystem.removeGuildBuffs(memPlayer)
                    addEvent(function()
                        local p = Player(memName)
                        if p then
                            pcall(function() p:setGuild(nil) end)
                            p:updateGuildTitle()
                            p:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Guild '%s' has been disbanded.", guildName))
                            p:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(p)))
                        end
                    end, 100)
                end
            until not result.next(allM)
            result.free(allM)
        end

        db.query(string.format("DELETE FROM `guild_membership` WHERE `guild_id` = %d", guildId))
        db.query(string.format("DELETE FROM `guild_ranks` WHERE `guild_id` = %d", guildId))
        db.query(string.format("DELETE FROM `guilds` WHERE `id` = %d", guildId))
        GuildSystem.guildLevelCache[guildId] = nil

        return true

    elseif action == "kick" then
        local targetGuid = tonumber(data.targetGuid)
        if not targetGuid then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local callerRank = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if callerRank < 2 then
            player:sendCancelMessage("You do not have permission to kick members.")
            return true
        end

        local tRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level, p.name FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id JOIN `players` p ON gm.player_id = p.id WHERE gm.player_id = %d AND gm.guild_id = %d LIMIT 1", targetGuid, guildId))
        if not tRes then
            player:sendCancelMessage("Member not found in guild.")
            return true
        end
        local targetRank = result.getNumber(tRes, "rank_level")
        local targetName = result.getString(tRes, "name")
        result.free(tRes)

        if targetRank >= callerRank then
            player:sendCancelMessage("You cannot kick a member of equal or higher rank.")
            return true
        end

        db.query(string.format("DELETE FROM `guild_membership` WHERE `player_id` = %d AND `guild_id` = %d", targetGuid, guildId))

        local targetPlayer = Player(targetName) or Player(targetGuid)
        if targetPlayer then
            pcall(function() targetPlayer:setGuild(nil) end)
            GuildSystem.removeGuildBuffs(targetPlayer)
            targetPlayer:updateGuildTitle()
            targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been kicked from the guild.")
            targetPlayer:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(targetPlayer)))
        end

        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Player %s has been kicked from the guild.", targetName))
        player:sendExtendedOpcode(GuildSystem.OPCODE, json.encode(GuildSystem.buildGuildPayload(player)))
        return true

    elseif action == "toggle_pacifist" then
        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can toggle Pacifist Mode.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)
        if not gData then return true end

        local newMode = (gData.pacifist_mode == 1) and 0 or 1
        local newDate = (newMode == 1) and os.time() or 0
        db.query(string.format("UPDATE `guilds` SET `pacifist_mode` = %d, `pacifist_date` = %d WHERE `id` = %d", newMode, newDate, guildId))

        local statusText = (newMode == 1) and "ACTIVE" or "INACTIVE"
        GuildSystem.broadcastToGuild(guildId, string.format("Pacifist Mode is now %s.", statusText))
        GuildSystem.broadcastPayloadToGuild(guildId)
        return true

    elseif action == "declare_war" then
        local targetGuildId = tonumber(data.targetGuildId)
        if not targetGuildId then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can declare war.")
            return true
        end

        if guildId == targetGuildId then
            player:sendCancelMessage("You cannot declare war on your own guild.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)
        local tData = GuildSystem.getGuildData(targetGuildId)
        if not gData or not tData then
            player:sendCancelMessage("Guild not found.")
            return true
        end

        -- Check existing war
        local exRes = db.storeQuery(string.format([[
            SELECT `id` FROM `guild_wars`
            WHERE ((`guild1` = %d AND `guild2` = %d) OR (`guild1` = %d AND `guild2` = %d))
            AND `ended` = 0 LIMIT 1
        ]], guildId, targetGuildId, targetGuildId, guildId))
        if exRes then
            result.free(exRes)
            player:sendCancelMessage("There is already an active or pending war with this guild.")
            return true
        end

        local forced = (data.forced == true or data.forced == 1 or data.forced == "true")
        local durationDays = math.max(1, math.min(7, tonumber(data.durationDays) or 3))
        local durationSec = durationDays * 86400
        local killsLimit = math.max(5, math.min(200, tonumber(data.killsLimit) or 10))
        local goldBet = math.max(0, math.min(10000000, tonumber(data.goldBet) or 1000))

        if gData.gold < goldBet then
            player:sendCancelMessage(string.format("Your guild needs at least %s gold in the treasury to bet.", comma_value(goldBet)))
            return true
        end

        if tData.pacifist_mode == 1 and not forced then
            player:sendCancelMessage("This guild is currently in Pacifist Mode! You must use Forced War to declare war on them.")
            return true
        end

        if forced then
            db.query(string.format("UPDATE `guilds` SET `gold` = `gold` - %d WHERE `id` = %d", goldBet, guildId))
            local targetDeduct = math.min(tData.gold, goldBet)
            if targetDeduct > 0 then
                db.query(string.format("UPDATE `guilds` SET `gold` = `gold` - %d WHERE `id` = %d", targetDeduct, targetGuildId))
            end

            local now = os.time()
            local endDate = now + durationSec
            db.query(string.format([[
                INSERT INTO `guild_wars` (`guild1`, `guild2`, `name1`, `name2`, `status`, `started`, `ended`, `duration`, `end_date`, `kills_limit`, `guild1_kills`, `guild2_kills`, `gold_bet`, `forced`)
                VALUES (%d, %d, %s, %s, 1, %d, 0, %d, %d, %d, 0, 0, %d, 1)
            ]], guildId, targetGuildId, db.escapeString(gData.name), db.escapeString(tData.name), now, durationSec, endDate, killsLimit, goldBet))

            local warMsg = string.format("[WAR]: '%s' has declared a FORCED WAR on '%s'! Duration: %d days, Kills Limit: %d, Pot: %s gold.",
                gData.name, tData.name, durationDays, killsLimit, comma_value(goldBet + targetDeduct))
            GuildSystem.broadcastToGuild(guildId, warMsg, MESSAGE_EVENT_ADVANCE)
            GuildSystem.broadcastToGuild(targetGuildId, warMsg, MESSAGE_EVENT_ADVANCE)
        else
            db.query(string.format("UPDATE `guilds` SET `gold` = `gold` - %d WHERE `id` = %d", goldBet, guildId))
            db.query(string.format([[
                INSERT INTO `guild_wars` (`guild1`, `guild2`, `name1`, `name2`, `status`, `started`, `ended`, `duration`, `end_date`, `kills_limit`, `guild1_kills`, `guild2_kills`, `gold_bet`, `forced`)
                VALUES (%d, %d, %s, %s, 0, 0, 0, %d, 0, %d, 0, 0, %d, 0)
            ]], guildId, targetGuildId, db.escapeString(gData.name), db.escapeString(tData.name), durationSec, killsLimit, goldBet))

            player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("War declaration sent to '%s'. Awaiting their response.", tData.name))
            GuildSystem.broadcastToGuild(targetGuildId, string.format("[WAR]: Guild '%s' has declared war on your guild! Check the Wars tab to accept or reject.", gData.name))
        end

        GuildSystem.broadcastPayloadToGuild(guildId)
        GuildSystem.broadcastPayloadToGuild(targetGuildId)
        return true

    elseif action == "accept_war" then
        local warId = tonumber(data.warId)
        if not warId then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can accept war declarations.")
            return true
        end

        local wRes = db.storeQuery(string.format("SELECT * FROM `guild_wars` WHERE `id` = %d AND `status` = 0 AND `ended` = 0 LIMIT 1", warId))
        if not wRes then
            player:sendCancelMessage("War declaration no longer available.")
            return true
        end

        local g1 = result.getNumber(wRes, "guild1")
        local g2 = result.getNumber(wRes, "guild2")
        local duration = result.getNumber(wRes, "duration")
        local goldBet = result.getNumber(wRes, "gold_bet")
        local killsLimit = result.getNumber(wRes, "kills_limit")
        local n1 = result.getString(wRes, "name1")
        local n2 = result.getString(wRes, "name2")
        result.free(wRes)

        if guildId ~= g2 then
            player:sendCancelMessage("You cannot accept your own war declaration.")
            return true
        end

        local gData = GuildSystem.getGuildData(guildId)
        if not gData or gData.gold < goldBet then
            player:sendCancelMessage(string.format("Your guild treasury needs at least %s gold to match the war bet.", comma_value(goldBet)))
            return true
        end

        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` - %d WHERE `id` = %d", goldBet, guildId))

        local now = os.time()
        local endDate = now + duration
        db.query(string.format("UPDATE `guild_wars` SET `status` = 1, `started` = %d, `end_date` = %d WHERE `id` = %d", now, endDate, warId))

        local warMsg = string.format("[WAR]: Guild '%s' accepted war declaration from '%s'! Kills Limit: %d, Pot: %s gold.",
            n2, n1, killsLimit, comma_value(goldBet * 2))
        GuildSystem.broadcastToGuild(g1, warMsg, MESSAGE_EVENT_ADVANCE)
        GuildSystem.broadcastToGuild(g2, warMsg, MESSAGE_EVENT_ADVANCE)

        GuildSystem.broadcastPayloadToGuild(g1)
        GuildSystem.broadcastPayloadToGuild(g2)
        return true

    elseif action == "reject_war" then
        local warId = tonumber(data.warId)
        if not warId then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can reject war declarations.")
            return true
        end

        local wRes = db.storeQuery(string.format("SELECT * FROM `guild_wars` WHERE `id` = %d AND `status` = 0 AND `ended` = 0 LIMIT 1", warId))
        if not wRes then return true end
        local g1 = result.getNumber(wRes, "guild1")
        local g2 = result.getNumber(wRes, "guild2")
        local goldBet = result.getNumber(wRes, "gold_bet")
        local n2 = result.getString(wRes, "name2")
        result.free(wRes)

        if guildId ~= g2 then return true end

        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d WHERE `id` = %d", goldBet, g1))
        db.query(string.format("UPDATE `guild_wars` SET `status` = 2, `ended` = 1 WHERE `id` = %d", warId))

        GuildSystem.broadcastToGuild(g1, string.format("Guild '%s' has rejected your war declaration. %s gold bet refunded.", n2, comma_value(goldBet)))
        GuildSystem.broadcastToGuild(g2, "War declaration rejected.")

        GuildSystem.broadcastPayloadToGuild(g1)
        GuildSystem.broadcastPayloadToGuild(g2)
        return true

    elseif action == "revoke_war" then
        local warId = tonumber(data.warId)
        if not warId then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can revoke war declarations.")
            return true
        end

        local wRes = db.storeQuery(string.format("SELECT * FROM `guild_wars` WHERE `id` = %d AND `status` = 0 AND `ended` = 0 LIMIT 1", warId))
        if not wRes then return true end
        local g1 = result.getNumber(wRes, "guild1")
        local g2 = result.getNumber(wRes, "guild2")
        local goldBet = result.getNumber(wRes, "gold_bet")
        local n1 = result.getString(wRes, "name1")
        result.free(wRes)

        if guildId ~= g1 then return true end

        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d WHERE `id` = %d", goldBet, g1))
        db.query(string.format("UPDATE `guild_wars` SET `status` = 3, `ended` = 1 WHERE `id` = %d", warId))

        GuildSystem.broadcastToGuild(g1, string.format("War declaration revoked. %s gold bet refunded.", comma_value(goldBet)))
        GuildSystem.broadcastToGuild(g2, string.format("Guild '%s' has revoked their war declaration.", n1))

        GuildSystem.broadcastPayloadToGuild(g1)
        GuildSystem.broadcastPayloadToGuild(g2)
        return true

    elseif action == "surrender_war" then
        local warId = tonumber(data.warId)
        if not warId then return true end

        local playerGuid = player:getGuid()
        local gRes = db.storeQuery(string.format("SELECT gm.guild_id, gr.level AS rank_level FROM `guild_membership` gm JOIN `guild_ranks` gr ON gm.rank_id = gr.id WHERE gm.player_id = %d LIMIT 1", playerGuid))
        if not gRes then return true end
        local guildId = result.getNumber(gRes, "guild_id")
        local rankLevel = result.getNumber(gRes, "rank_level")
        result.free(gRes)

        if rankLevel < 2 then
            player:sendCancelMessage("Only guild leadership can surrender.")
            return true
        end

        local wRes = db.storeQuery(string.format("SELECT * FROM `guild_wars` WHERE `id` = %d AND `status` = 1 AND `ended` = 0 LIMIT 1", warId))
        if not wRes then return true end
        local g1 = result.getNumber(wRes, "guild1")
        local g2 = result.getNumber(wRes, "guild2")
        local goldBet = result.getNumber(wRes, "gold_bet")
        local totalPot = goldBet * 2
        result.free(wRes)

        local winnerId = (guildId == g1) and g2 or g1
        local loserId = guildId

        db.query(string.format("UPDATE `guild_wars` SET `status` = 4, `ended` = 1 WHERE `id` = %d", warId))
        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d, `wars_won` = `wars_won` + 1 WHERE `id` = %d", totalPot, winnerId))
        db.query(string.format("UPDATE `guilds` SET `wars_lost` = `wars_lost` + 1 WHERE `id` = %d", loserId))

        local winData = GuildSystem.getGuildData(winnerId)
        local surrData = GuildSystem.getGuildData(loserId)
        local surrMsg = string.format("🏳 SURRENDER! Guild '%s' has surrendered! Guild '%s' wins the war and receives %s gold pot!",
            surrData and surrData.name or "Guild", winData and winData.name or "Guild", comma_value(totalPot))
        GuildSystem.broadcastToGuild(g1, surrMsg, MESSAGE_EVENT_ADVANCE)
        GuildSystem.broadcastToGuild(g2, surrMsg, MESSAGE_EVENT_ADVANCE)

        GuildSystem.broadcastPayloadToGuild(g1)
        GuildSystem.broadcastPayloadToGuild(g2)
        return true
    end

    return true
end

ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()

-- PvP Death Event for War Frags
local WarDeathEvent = CreatureEvent("GuildWarDeath")
function WarDeathEvent.onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    local actualKiller = killer or mostDamageKiller
    if not actualKiller or not actualKiller:isPlayer() or not player:isPlayer() then
        return true
    end

    local killerGuild = actualKiller:getGuild()
    local victimGuild = player:getGuild()
    if not killerGuild or not victimGuild then return true end

    local kGuildId = killerGuild:getId()
    local vGuildId = victimGuild:getId()
    if kGuildId == vGuildId then return true end

    -- Check active war
    local wRes = db.storeQuery(string.format([[
        SELECT * FROM `guild_wars`
        WHERE ((`guild1` = %d AND `guild2` = %d) OR (`guild1` = %d AND `guild2` = %d))
        AND `status` = 1 AND `ended` = 0 LIMIT 1
    ]], kGuildId, vGuildId, vGuildId, kGuildId))

    if not wRes then return true end

    local warId = result.getNumber(wRes, "id")
    local guild1 = result.getNumber(wRes, "guild1")
    local guild2 = result.getNumber(wRes, "guild2")
    local killsLimit = result.getNumber(wRes, "kills_limit")
    local g1Kills = result.getNumber(wRes, "guild1_kills")
    local g2Kills = result.getNumber(wRes, "guild2_kills")
    local goldBet = result.getNumber(wRes, "gold_bet")
    local warName1 = result.getString(wRes, "name1")
    local warName2 = result.getString(wRes, "name2")
    result.free(wRes)

    local isKillerGuild1 = (kGuildId == guild1)
    if isKillerGuild1 then
        g1Kills = g1Kills + 1
        db.query(string.format("UPDATE `guild_wars` SET `guild1_kills` = `guild1_kills` + 1 WHERE `id` = %d", warId))
    else
        g2Kills = g2Kills + 1
        db.query(string.format("UPDATE `guild_wars` SET `guild2_kills` = `guild2_kills` + 1 WHERE `id` = %d", warId))
    end

    -- Insert kill log
    db.query(string.format([[
        INSERT INTO `guildwar_kills` (`warid`, `killer_guid`, `target_guid`, `killer_name`, `target_name`, `killer_guild`, `target_guild`, `killer`, `target`, `killerguild`, `targetguild`, `time`)
        VALUES (%d, %d, %d, %s, %s, %d, %d, %s, %s, %d, %d, %d)
    ]], warId, actualKiller:getGuid(), player:getGuid(),
        db.escapeString(actualKiller:getName()), db.escapeString(player:getName()), kGuildId, vGuildId,
        db.escapeString(actualKiller:getName()), db.escapeString(player:getName()), kGuildId, vGuildId,
        os.time()))

    local scoreStr = string.format("%s %d : %d %s", warName1, g1Kills, g2Kills, warName2)
    local killMsg = string.format("[WAR]: %s (%s) killed %s (%s)! Score: %s",
        actualKiller:getName(), killerGuild:getName(), player:getName(), victimGuild:getName(), scoreStr)

    GuildSystem.broadcastToGuild(guild1, killMsg)
    GuildSystem.broadcastToGuild(guild2, killMsg)

    -- Check win condition
    local winnerGuildId = nil
    local loserGuildId = nil
    if g1Kills >= killsLimit then
        winnerGuildId = guild1
        loserGuildId = guild2
    elseif g2Kills >= killsLimit then
        winnerGuildId = guild2
        loserGuildId = guild1
    end

    if winnerGuildId then
        local totalPot = goldBet * 2
        db.query(string.format("UPDATE `guild_wars` SET `status` = 4, `ended` = 1 WHERE `id` = %d", warId))
        db.query(string.format("UPDATE `guilds` SET `gold` = `gold` + %d, `wars_won` = `wars_won` + 1 WHERE `id` = %d", totalPot, winnerGuildId))
        db.query(string.format("UPDATE `guilds` SET `wars_lost` = `wars_lost` + 1 WHERE `id` = %d", loserGuildId))

        local winData = GuildSystem.getGuildData(winnerGuildId)
        local winMsg = string.format("★ WAR VICTORY! Guild '%s' reached the kill limit (%d kills) and won the war! Awarded %s gold pot!", winData and winData.name or "Guild", killsLimit, comma_value(totalPot))
        GuildSystem.broadcastToGuild(guild1, winMsg, MESSAGE_EVENT_ADVANCE)
        GuildSystem.broadcastToGuild(guild2, winMsg, MESSAGE_EVENT_ADVANCE)
    end

    GuildSystem.broadcastPayloadToGuild(guild1)
    GuildSystem.broadcastPayloadToGuild(guild2)

    return true
end
WarDeathEvent:type("death")
WarDeathEvent:register()

-- Player Login Event: Register opcode, apply buffs, and set title
local LoginEvent = CreatureEvent("GuildSystemLogin")
function LoginEvent.onLogin(player)
    player:registerEvent("GuildSystemExtendedOpcode")
    player:registerEvent("GuildWarDeath")

    local guild = player:getGuild()
    local guildId = guild and guild:getId() or nil
    if not guildId then
        local res = db.storeQuery(string.format("SELECT `guild_id` FROM `guild_membership` WHERE `player_id` = %d LIMIT 1", player:getGuid()))
        if res then
            guildId = result.getNumber(res, "guild_id")
            result.free(res)
        end
    end

    if guildId then
        local gData = GuildSystem.getGuildData(guildId)
        if gData then
            GuildSystem.applyGuildBuffs(player, gData.level)
        end
    end

    player:updateGuildTitle()
    return true
end

LoginEvent:type("login")
LoginEvent:register()

-- Register for all online players immediately on load/reload
if Game and Game.getPlayers then
    for _, player in ipairs(Game.getPlayers()) do
        player:registerEvent("GuildSystemExtendedOpcode")
        player:registerEvent("GuildWarDeath")
        player:updateGuildTitle()
    end
end
