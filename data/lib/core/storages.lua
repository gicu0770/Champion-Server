-- Reserved storage QUEST CHEST from 2000 - 2300
--[[
TalentsStorage = {

	KNIGHT_talent_line_2 = 435002,
	KNIGHT_talent_line_3 = 435003,
	KNIGHT_talent_line_4 = 435004,
	KNIGHT_talent_line_5 = 435030,
	
	ARCHER_talent_line_1 = 435005,
	ARCHER_talent_line_2 = 435006,
	ARCHER_talent_line_3 = 435007,
	ARCHER_talent_line_4 = 435008,
	ARCHER_talent_line_5 = 435031,

	PALADIN_talent_line_1 = 435009, 
	PALADIN_talent_line_2 = 435010,
	PALADIN_talent_line_3 = 435011,
	PALADIN_talent_line_4 = 435012,
	PALADIN_talent_line_5 = 435032,
	
	DRUID_talent_line_1 = 435013,
	DRUID_talent_line_2 = 435014,
	DRUID_talent_line_3 = 435015,
	DRUID_talent_line_4 = 435016,
	DRUID_talent_line_5 = 435033,
	
	SORCERER_talent_line_1 = 435017,
	SORCERER_talent_line_2 = 435018,
	SORCERER_talent_line_3 = 435019,
	SORCERER_talent_line_4 = 435020,
	SORCERER_talent_line_5 = 435060,
	
	SHADOW_talent_line_1 = 435021,
	SHADOW_talent_line_2 = 435022,
	SHADOW_talent_line_3 = 435023,
	SHADOW_talent_line_4 = 435024,
	SHADOW_talent_line_5 = 435034,
	
	ALL_talent_line_200 = 435025,
	ALL_talent_line_200_1 = 435035,
	ALL_talent_line_200_2 = 435036,
	ALL_talent_line_200_3 = 435037,
	ALL_talent_line_200_4 = 435038,
	ALL_talent_line_200_5 = 435039,
	
	ALL_talent_line_400 = 435026,
	ALL_talent_line_400_1 = 435040,
	ALL_talent_line_400_2 = 435041,
	ALL_talent_line_400_3 = 435042,
	ALL_talent_line_400_4 = 435043,
	ALL_talent_line_400_5 = 435044,
	
	ALL_talent_line_600 = 435027,
	ALL_talent_line_600_1 = 435045,
	ALL_talent_line_600_2 = 435046,
	ALL_talent_line_600_3 = 435047,
	ALL_talent_line_600_4 = 435048,
	ALL_talent_line_600_5 = 435049,
	
	ALL_talent_line_800 = 435028,
	ALL_talent_line_800_1 = 435050,
	ALL_talent_line_800_2 = 435051,
	ALL_talent_line_800_3 = 435052,
	ALL_talent_line_800_4 = 435053,
	ALL_talent_line_800_5 = 435054,
	
	ALL_talent_line_1000 = 435029,
	ALL_talent_line_1000_1 = 435055,
	ALL_talent_line_1000_2 = 435056,
	ALL_talent_line_1000_3 = 435057,
	ALL_talent_line_1000_4 = 435058,
	ALL_talent_line_1000_5 = 435059,
	
}
--]]

PlayerStorageKeys = {
	annihilatorReward = 30015,
	promotion = 30018,
	delayLargeSeaShell = 30019,
	firstRod = 30020,
	delayWallMirror = 30021,
	inspectStatus = 30022,
	characterStatsPoints = 84590, -- 84590 - 84596 reserved
	characterStatsLevel = 85590,
	craftingMastery = 85592, -- 85592 - 86596 reserved
}

MonsterStorages = {
	stoneMaxLifes = 500000,
	stoneLifes = 500001,
	stoneZoneId = 500002,
	isStoneMonster = 500003,
	voidRelict = 666666,
}

GlobalStorageKeys = {
	globalHighQualityBook = 545400,	-- globalHighQualityBook
	globalAbilityBook = 545401,	-- globalAbilityBook
	globalAbilityRemover = 545402,	-- globalAbilityRemover
	globalEXPtime = 67861,
	globalGOLDtime = 67862,
	globalLOOTtime = 67863,
	globalSKILLtime = 67864,
	
	globalDAMAGEtime = 67865,
	globalDAMAGE_REDUCTIONtime = 67866,
	globalHEALINGtime = 67867,
	globalFOSSILtime = 67868,
	globalUPGRADE_MATERIALStime = 67869,
}



PlayerStorage = {
	portals = 727500, -- 727500 - 727599 reserved
	portalSelected = 727600,

	BPrestart = 812345,
	subTalents = 999999,
	specialization = 999032, -- specialization Talent
	trait = 999031, -- Trait Talent
	fusionTalent = 999030, -- Fusion Talent
	promotionBoss7 = 804156, -- specialization portal
	promotionBoss6 = 804155, -- specialization portal
	promotionBoss5 = 804154, -- Voort
	promotionBoss4 = 804153, -- Yeti
	promotionBoss3 = 804152, -- grim
	promotionBoss2 = 804151, -- Rot
	promotionBoss1 = 804150, -- Lava golem
	endGameBossTierUnlocked = 803000, -- reserverd 130
	forgeCurrency = 802000, -- reserverd 130
	rebornNeed1 = 801100,
	rebornNeed2 = 801101,
	rebornNeed3 = 801102,
	portalMonsters = 801103,
	portalBoss = 801104,
	monsterSetTier = 801105,
	dungeon_death = 801106,
	totalPhysial = 801107,
	totalElemental = 801108,

	forgePowder1 = 801109,
	forgePowder2 = 801110,
	forgePowder3 = 801111,
	voortResetTalent = 801112,
	dailyBoosty = 801113,

	filter = 801114,
	vengeanceFlameDmg = 801120,
	maxSpellLevelReached = 801121,
	gornShieldAmount = 801122,
	concussiveBlastCooldown = 801130,
	braveSmiteCooldown = 801131,
	focusingMarkCooldown = 801132,
	weaknessFinderCooldown = 801133,
	spellbladeCooldown = 801134,
	spellbladeProc = 801135,
	ichorShieldTime = 801136,
	ichorShieldAmount = 801137,

	dungeonTp = 801115, -- reserver 50
	bossCloneEX = 435007,
	bossClone = 435006,
	bossRelictBoss = 435005,
	championRelictBoss = 435004,
	goblinRelictBoss = 435003,
	strongboxRelictBoss = 435002,
	secondTalnet = 435001,
	exhaustSpecial = 801000, -- reserver 100
	spell_support = 800300, -- reserverd 100
	cd_items = 800201,
	attack_speed = 800200,
	worldBossDamage = 800104,
	worldBossDamagePercent = 800103,
	t10access2 = 800102,
	t10access = 800101,
	t9access2 = 800100,
	spellLevelTarget = 800085, -- reserver 15
	--[[
	testRate = 800084,
	waveEvolve5 = 800083,
	waveEvolve4 = 800082,
	waveEvolve3 = 800081,
	waveEvolve2 = 800080,
	waveEvolve1 = 800079,
	reductionTotal = 800078,
	scrapall = 800077,
	raid7TimeCooldown = 800076,
	raid6TimeCooldown = 800075,
	raid5TimeCooldown = 800074,
	raid4TimeCooldown = 800073,
	raid3TimeCooldown = 800072,
	raid2TimeCooldown = 800071,
	raid1TimeCooldown = 800070,
	--]]
	basicSpecials = 80700, -- 150 reserverd
	counterPen = 80555, -- 150 reserverd
	basicPen = 800404, -- 150 reserverd
	monsterModifier_partyBonus = 800091,
	portalVoort = 800403,
	secondTrait = 800402,
	keyTier = 800401,
	endGame = 800400,
	damageDotInfo = 800090,
	damageLog = 800095,
	monsterModifier_extracurrency = 800089,
	monsterModifier_extraexp = 800088,
	monsterModifier_extragold = 800087,
	monsterModifier_armored = 800086,
	monsterModifier_bloody = 800085,
	monsterModifier_phantom = 800084,
	monsterModifier_rift = 800083,
	monsterModifier_bonus = 800082,
	monsterModifier_movements = 800081,
	monsterModifier_ailments = 800080,
	monsterModifier_dodge = 800079,
	monsterModifier_damage_physical = 800078,
	monsterModifier_damage_elemental = 800077,
	monsterModifier_elementalProtection = 800076,
	monsterModifier_dualityProtection = 800075,
	monsterModifier_spell_avoid = 800074,
	monsterModifier_exp = 800073,
	monsterModifier_gold = 800072,
	monsterModifier_physicalProtection = 800071,
	monsterModifier_damage = 800070,
	playerTier = 800069,
	--[[
	dungTier10acc = 800068,
	dungTier10set = 800067,
	dungTier9acc = 800066,
	dungTier9set = 800065,
	dungTier8acc = 800064,
	dungTier8set = 800063,
	dungTier7acc = 800062,
	dungTier7set = 800061,
	dungTier6acc = 800060,
	dungTier6set = 800059,
	dungTier5acc = 800058,
	dungTier5set = 800057,
	dungTier4acc = 800056,
	dungTier4set = 800055,
	dungTier3acc = 800054,
	dungTier3set = 800053,
	dungTier2acc = 800052,
	dungTier2set = 800051,
	dungTier1 = 800050,
	--]]
	dungeonUnlocked9 = 800058,
	dungeonUnlocked8 = 800057,
	dungeonUnlocked7 = 800056,
	dungeonUnlocked6 = 800055,
	dungeonUnlocked5 = 800054,
	dungeonUnlocked4 = 800053,
	dungeonUnlocked3 = 800052,
	dungeonUnlocked2 = 800051,
	dungeonUnlocked1 = 800050,
	AFKrooms = 800049,
	endlessArenaCorruptedPoints = 800048,
	onlinePointsStorageLimit = 800047,
	endlessArenaCorruptedLimit = 800046,
	endlessBossxx = 800045,
	endlesscoruptMobs = 800044,
	endlesscorupt = 800043,
	endlessc = 800042,
	endlessMobsLeft = 800041,
	endlessStarted = 800040,
	endlessPos = 800039,
	endlessMobs = 800038,
	t9access = 800037,
	endlessBoss = 800036,
	endless = 800035,
	potion4 = 800034,
	potion3 = 800033,
	potion2 = 800032,
	potion1 = 800031,
	t7access = 800030,
	-- 800027-8-9 zajete
	paragonLevelNewChaarcter = 800026,
	paragonLevel = 800025,
	paragonEXP = 800024,
	promotionStorage = 800023,
	-- spell level
	fusionClassBonus = 999001,
	subTrait = 999000,
	damageGoldInfo = 800022,
	damageExpInfo = 800021,
	damageHealingInfo = 800020,
	damageTakenInfo = 800019,
	vocationQuest = 800018,
	intervalBonus2 = 800017,
	intervalBonus = 800016,
	HPAttackMPBlockade = 800005, -- 800005 - 800015
	talentAttackSpeed1 = 800004,	
	talentMP1 = 800003,		
	talentHP1 = 800002,	

	spellMessage = 800001,
	spellEffects = 800000,
	
	
	
	-- daily_questReserver [730020 - 730040
	autolootSlots = 730101,
	autolootActive = 730100,
	riftMonster_plus = 730023,
	riftMonster_minus = 730022,
	riftBoss = 730021,
	riftMonster = 730020,
	autolootindifityActivated = 730019,
	autolootindifity = 730018,
	autolootrarityActivated = 730017,
	autolootrarity = 730016,
	strongBoxMonsterBoss = 730015,
	strongBoxMonster = 730014,
	skillBoostShop = 730012,	
	lootBoostShop = 730011,
	goldBoostShop = 730010,
	blessOUT = 730001,
	moreInfoChances = 730000,

	sideBoss22 = 726587, -- Bridge Boss
	sideBoss21 = 726586, -- Bridge Boss
	sideBoss20 = 726585, -- Bridge Boss
	sideBoss19 = 726584, -- Bridge Boss

	sideBoss18 = 726583, -- relmboss
	sideBoss17 = 726582, -- relmboss
	sideBoss16 = 726581, -- relmboss
	sideBoss15 = 726580, -- relmboss
	sideBoss14 = 726579,
	sideBoss13 = 726578,
	sideBoss12 = 726577,
	sideBoss11 = 726576,
	footPrints = 726543, -- 726543 - 726575
	footChoosen = 726542,
	
	sideBoss10 = 726541,
	sideBoss9 = 726540,
	sideBoss8 = 726539,
	sideBoss7 = 726538,
	sideBoss6 = 726537,
	sideBoss5 = 726536,
	sideBoss4 = 726535,
	sideBoss3 = 726534,
	sideBoss2 = 726533,
	sideBoss1 = 726532,

	bossesPassive = 726531,
	questPassive = 726530,
	progressBonuses = 726529,
	exhaustMoveItems = 726528,
	castInfo = 726519,	-- t8 access SET
	basicInfo = 726518,	-- t8 access SET
	t8accHell = 726517,	-- t8 access SET
	t8accAskara = 726516,	-- t8 access akcesoria
	darkForeiQuest = 726515,	-- acc/set t7
	feralQuest = 726514,	-- feralQuest acc T6
	upgradeChanceIncreased = 726513,	-- upgradeChanceIncreased
	mythicQuestAcc3 = 726512,	-- mythic quest acc 3
	mythicQuestAcc2 = 726511,	-- mythic quest acc 2
	mythicQuestAcc1 = 726510,	-- mythic quest acc 1
	mythicQuest = 726509,	-- mythic quest
	riftBlokade = 726508,	-- rift blockade
	riftReward = 225000,	-- rift reward
	riftPortal = 726507,	-- rift storage
	damageInfo = 726506,	-- player damageInfo
	playerPosition = 800027,	-- player save position
	moreInfoMonster = 726504,	-- moreInfoMonster
	animatedTalentSkills = 726503,	-- show skills
	moreInfo = 726502,	-- moreInfo
	increaseDamageSpellPvP = 726501,	-- increase damage spell pvp
	increaseDamageMeleePvP = 726500,	-- increase damage melee pvp
	increaseDamageSpell = 726401,	-- increase damage spell
	increaseDamageMelee = 726400,	-- increase damage melee
	ultimateSpells = 230123,	-- reserver 10	230123-230133
	shopOnTimeBuy = 226326,	-- reserver 10	226326-226336
	questBoots = 226325,
	auraStorage = 226324,
	wingsStorage = 226323,
	mining_points_character = 226223,
	mining_points_character2 = 226224,
	mining_points_character3 = 226225,
	mining_points_character4 = 226226,
	mining_points_character5 = 226227,
	eliteAffixes = 226123,
	swamp_pit = 40100,
	wayPoints = 41875,
	autoLoot = 954000, -- reserver 25 954000-954100
	reborn = 707070,
	rebornMessageAfterLogin = 707071,
	darkTower = 275400,
	demonOak = 145000,
	dpsStorage = 50392,
	elfFortressQuest = 170001,
	frozenQuest = 170002,
	miningQuest = 170003,
	onlinePoints = 125230,
	expScroll = 777000,
	expDaily = 777001,
	expBoostShop = 777002,
	globalEXP = 17589,
	globalEXP2 = 17585,
	globalMlvl = 17591,
	globalMlvl2 = 17587,
	globalSkill = 17590,
	globalSkill2 = 17586,
	dungeonsDifficulty = 86597, -- 86597 - 86640 reserved (43 dungeons limit)
	challengeComplete = 86641, -- 86641 - 87000 reserved (359 challenges limit)
	challengeProgress = 87001, -- 87001 - 87360 reserved (359)
	challengePoints = 87361,

	manaBarOption = 87362,

	traadeStorage = 87363, -- +3
	antiSpam = 52390,
	antiSpamCount = 52391,

	orbsbagBought = 523952,

	recomb = 540000, -- +3

	QuestTrackerActive = 115000,
	QuestTracked = 115000, -- 5 -- max 5 quest can be tracked at once
	QuestStatus = 115005, -- 115105


	EnchantmentsAltar = 125105, -- 125205
	inspectable = 900000,
}


Storage = {
	SvargrondArena = {
		-- Reserved storage from 51710 - 51729
		Arena = 51710,
		PitDoor = 51711,
		QuestLogGreenhorn = 51712,
		QuestLogScrapper = 51713,
		QuestLogWarlord = 51714,
		RewardGreenhorn = 51715,
		RewardScrapper = 51716,
		RewardWarlord = 51717,
		TrophyGreenhorn = 51718,
		TrophyScrapper = 51719,
		TrophyWarlord = 51720,
		GreenhornDoor = 51721,
		ScrapperDoor = 51722,
		WarlordDoor= 51723
	}
}