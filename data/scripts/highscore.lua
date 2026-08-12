local highscore_clones = {
  [1] = {
    pos = Position(683, 1026, 7),
    creature = nil
  },
  [2] = {
    pos = Position(681, 1027, 7),
    creature = nil
  },
  [3] = {
    pos = Position(685, 1027, 7),
    creature = nil
  }
}

function applyHighScorePlayers(resultId)
  local collectedData = {}
	repeat
		local data = {
      name = result.getString(resultId, "name"),
      level = result.getDataInt(resultId, "level"),
      exp = result.getDataInt(resultId, "experience"),
      tier = result.getDataInt(resultId, "dungeontier"),
      outfit = {
        lookBody = result.getDataInt(resultId, "lookbody"),
        lookFeet = result.getDataInt(resultId, "lookfeet"),
        lookHead = result.getDataInt(resultId, "lookhead"),
        lookLegs = result.getDataInt(resultId, "looklegs"),
        lookType = result.getDataInt(resultId, "looktype"),
        lookAddons = result.getDataInt(resultId, "lookaddons"),
        lookWings = result.getDataInt(resultId, "lookwings"),
        lookAura = result.getDataInt(resultId, "lookaura"),
        lookShader = result.getString(resultId, "lookshader"),
        lookOutline = result.getString(resultId, "lookoutline"),
      }
		}
		table.insert(collectedData, data)
	until not result.next(resultId)
	result.free(resultId)

  for i = 1, #collectedData do
    local creature = Creature(highscore_clones[i].creature)
    if creature and not creature:isRemoved() then
      if collectedData[i].tier > 0 then
        creature:setTitle("Dungeon Tier: "..collectedData[i].tier, "Reggae One-10px-bordered", "#33ff00")
      else
        creature:setTitle("Level: "..collectedData[i].level, "Reggae One-12px-bordered", "#33ff00")
      end
      creature:setName(collectedData[i].name)
      creature:setOutfit(collectedData[i].outfit)

      if creature:getPosition() ~= highscore_clones[i].pos then
        creature:teleportTo(highscore_clones[i].pos)
      end
    end
  end
end

function placeHighScoreClones()
  for i = 1, #highscore_clones do
    local npc = Game.createNpc("Clone", highscore_clones[i].pos, true, true)
    if npc then
      npc:setMasterPos(highscore_clones[i].pos)
      highscore_clones[i].creature = npc:getId()
    end
  end
  updateHighScoreClones()
end

function updateHighScoreClones()
  db.asyncStoreQuery("SELECT p.`name`,p.`level`,p.`experience`,p.`lookbody`,p.`lookfeet`,p.`lookhead`,p.`looklegs`,p.`looktype`,p.`lookaddons`,p.`lookwings`,p.`lookaura`,p.`lookshader`,p.`dungeontier`,p.`lookoutline` FROM `players` p LEFT JOIN `account_bans` ab ON ab.`account_id`=p.`account_id` WHERE p.`group_id`=1 AND ab.`account_id` IS NULL ORDER BY CASE WHEN p.`dungeontier`>0 THEN 1 ELSE 0 END DESC,p.`dungeontier` DESC,p.`experience` DESC LIMIT 3;", applyHighScorePlayers) 
end