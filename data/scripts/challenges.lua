ChallengesIndex = {
  SPECTRE_DONE = 1,
  FLAME_CAVE = 2,
  SWAMP_PIT_FUSION = 3,
  UNDEAD_CAVE_TRAIT = 4,
  VOORT = 5,
  TIER_BOSS1 = 6,
  TIER_BOSS2 = 7,
  TIER_BOSS3 = 8,
  TIER_BOSS4 = 9,
  SPECIALIZATION = 10,
  TIER_BOSS5 = 11,
  BRIDGE_1 = 12,
  BRIDGE_2 = 13,
  BRIDGE_3 = 14,
  BRIDGE_4 = 15,
}

ChallengesList = {
  [ChallengesIndex.SPECTRE_DONE] = {
    title = "First Promotion",
    description = "Done dungeon to get new promotion. Increase Health and Mana regeneration.",
    points = 1
  },
  [ChallengesIndex.FLAME_CAVE] = {
    title = "Second Promotion",
    description = "Done dungeon to get new promotion and Fusion Vocation. Talk to Orrn in town. Increase Health and Mana regeneration.",
    points = 1
  },
  [ChallengesIndex.SWAMP_PIT_FUSION] = {
    title = "Fusion Ability",
    description = "Done dungeon to get Fusion Ability unlocked. Need relogin.",
    points = 1
  },
  [ChallengesIndex.UNDEAD_CAVE_TRAIT] = {
    title = "Trait",
    description = "Done dungeon to get Trait from other vocation unlocked.",
    points = 1
  },
  [ChallengesIndex.VOORT] = {
    title = "Voort",
    description = "Done dungeon to get Endgame unlocked.",
    points = 1
  },
  [ChallengesIndex.TIER_BOSS1] = {
    title = "Venomgrizzle",
    description = "Done dungeon to get First unlocked.",
    points = 1
  },
  [ChallengesIndex.TIER_BOSS2] = {
    title = "Bonebound Stalker",
    description = "Done dungeon to get Second unlocked.",
    points = 1
  },
  [ChallengesIndex.TIER_BOSS3] = {
    title = "Blood Fury",
    description = "Done dungeon to get Third unlocked.",
    points = 1
  },
  [ChallengesIndex.TIER_BOSS4] = {
    title = "Voidflare Wisp",
    description = "Done dungeon to get Fourth unlocked.",
    points = 1
  },
  [ChallengesIndex.SPECIALIZATION] = {
    title = "Forest Keeper",
    description = "Done dungeon to get Specialization unlocked.",
    points = 1
  },
  [ChallengesIndex.TIER_BOSS5] = {
    title = "Reaper Shade",
    description = "Done dungeon to get Fifty unlocked.",
    points = 1
  },
  [ChallengesIndex.BRIDGE_1] = {
    title = "Bridge 1",
    description = "XXX.",
    points = 1
  },
  [ChallengesIndex.BRIDGE_2] = {
    title = "Bridge 2",
    description = "XXX.",
    points = 1
  },
  [ChallengesIndex.BRIDGE_3] = {
    title = "Bridge 3",
    description = "XXX.",
    points = 1
  },
  [ChallengesIndex.BRIDGE_4] = {
    title = "Bridge 4",
    description = "XXX.",
    points = 1
  },
}

function Player:addChallengeProgress(id, value)
  self:setStorageValue(PlayerStorage.challengeComplete + id, self:getChallengeProgress(id) + value)
end

function Player:getChallengeProgress(id)
  local progress = self:getStorageValue(PlayerStorage.challengeProgress + id)
  if progress == -1 then
    progress = 0
  end
  return progress
end

function Player:completeChallenge(id)
  self:setStorageValue(PlayerStorage.challengeComplete + id, 1)
  self:setStorageValue(PlayerStorage.challengePoints, self:getChallengePoints() + ChallengesList[id].points)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "challenge", data = ChallengesList[id].title}))
end

function Player:hasCompletedChallenge(id)
  return self:getStorageValue(PlayerStorage.challengeComplete + id) > 0
end

function Player:getChallengePoints()
  local points = self:getStorageValue(PlayerStorage.challengePoints)
  if points == -1 then
    points = 0
  end

  return points
end
