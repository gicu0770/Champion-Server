/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2019  Mark Samman <mark.samman@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef FS_PLAYER_H_4083D3D3A05B4EDE891B31BB720CD06F
#define FS_PLAYER_H_4083D3D3A05B4EDE891B31BB720CD06F

#include "creature.h"
#include "container.h"
#include "cylinder.h"
#include "outfit.h"
#include "enums.h"
#include "vocation.h"
#include "protocolgame.h"
#include "ioguild.h"
#include "party.h"
#include "inbox.h"
#include "depotchest.h"
#include "depotlocker.h"
#include "guild.h"
#include "groups.h"
#include "town.h"
#include "mounts.h"
#include "auras.h"
#include "wings.h"
#include "shader.h"
#include "outline.h"
#include "tempstorage.h"
#include "tradestorage.h"

#include <memory>
#include <atomic>
#include <spdlog/logger.h>
#include <spdlog/spdlog.h>
#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/common.h>


class House;
class NetworkMessage;
class Weapon;
class ProtocolGame;
class Npc;
class Party;
class Bed;
class Guild;
class Dungeon;

enum skillsid_t {
	SKILLVALUE_LEVEL = 0,
	SKILLVALUE_TRIES = 1,
	SKILLVALUE_PERCENT = 2,
};

enum fightMode_t : uint8_t {
	FIGHTMODE_ATTACK = 1,
	FIGHTMODE_BALANCED = 2,
	FIGHTMODE_DEFENSE = 3,
};

enum pvpMode_t : uint8_t {
	PVP_MODE_DOVE = 0,
	PVP_MODE_WHITE_HAND = 1,
	PVP_MODE_YELLOW_HAND = 2,
	PVP_MODE_RED_FIST = 3,
};

static const uint16_t translate_vocations[] = {
    0,   // Placeholder for index 0 (assuming 0-indexed array)
    1, 2, 3, 4,  // Sorcerer
    1, 2, 3, 4,  // Druid
    1, 2, 3, 4,  // Paladin
    1, 2, 3, 4,  // Knight
    17, 17, 17, 17,  // Additional Paladin vocations
    21, 21, 21, 21   // Shadow
};

#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
struct VIPEntry {
	VIPEntry(uint32_t guid, std::string name, std::string description, uint32_t icon, bool notify) :
		guid(guid), name(std::move(name)), description(std::move(description)), icon(icon), notify(notify) {}

	uint32_t guid;
	std::string name;
	std::string description;
	uint32_t icon;
	bool notify;
};
#else
struct VIPEntry {
	VIPEntry(uint32_t guid, std::string name) :
		guid(guid), name(std::move(name)) {}

	uint32_t guid;
	std::string name;
};
#endif

struct OpenContainer {
	Container* container;
	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	uint16_t index;
	#endif
};

struct OutfitEntry {
	constexpr OutfitEntry(uint16_t lookType, uint8_t addons) : lookType(lookType), addons(addons) {}

	uint16_t lookType;
	uint8_t addons;
};

struct Skill {
	uint64_t tries = 0;
	uint16_t level = 0;
	#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
	uint16_t percent = 0;
	#else
	uint8_t percent = 0;
	#endif
};

enum PlayerUpdateFlags : uint32_t {

	PlayerUpdate_Light = 1 << 0,
	PlayerUpdate_Inventory = 1 << 1,
	PlayerUpdate_Sale = 1 << 2,

	// PlayerUpdate_Health = 1 << 0,
	// PlayerUpdate_EnergyShield = 1 << 1,
	// PlayerUpdate_Level = 1 << 3,
	// PlayerUpdate_Mana = 1 << 4,
};

enum PlayerAsyncOngoingTaskFlags : uint64_t {
	PlayerAsyncTask_Highscore = 1 << 0,
	PlayerAsyncTask_RecentDeaths = 1 << 1,
	PlayerAsyncTask_RecentPvPKills = 1 << 2,
	PlayerAsyncTask_MarketOffers = 1 << 3
};

using MuteCountMap = std::map<uint32_t, uint32_t>;

static constexpr int32_t PLAYER_MAX_SPEED = 4000;
static constexpr int32_t PLAYER_MIN_SPEED = 50;

#if GAME_FEATURE_QUEST_TRACKER > 0
class Mission;
#endif

class Player final : public Creature, public Cylinder
{
	public:
		explicit Player(ProtocolGame_ptr p);
		~Player();

		// non-copyable
		Player(const Player&) = delete;
		Player& operator=(const Player&) = delete;

		Player* getPlayer() override {
			return this;
		}
		const Player* getPlayer() const override {
			return this;
		}

		void addInfoLog(std::string message) {
			if (playerLogger) {
				playerLogger->info(message);
			}
		}

		void setID() override {
			if (id == 0) {
				// keep id the same as guid because client save data using this id
				id = 0x10000000 + guid;
				playerAutoID = std::max<uint32_t>(playerAutoID, id);
			}
		}

		static MuteCountMap muteCountMap;

		const std::string& getName() const override {
			return name;
		}
		void setName(std::string name) override {
			this->name = std::move(name);
		}
		const std::string& getNameDescription() const override {
			return name;
		}
		std::string getDescription(int32_t lookDistance) const override;

		CreatureType_t getType() const override {
			return CREATURETYPE_PLAYER;
		}

		#if GAME_FEATURE_MOUNTS > 0
		uint8_t getCurrentMount() const;
		void setCurrentMount(uint8_t mountId);
		//bool isMounted() const {
		bool isMounted() const
		{
			return defaultOutfit.lookMount != 0;
		}
		bool hasMount() const
		{
			return defaultOutfit.lookMount != 0;
		}
		bool hasAura() const
		{
			return defaultOutfit.lookAura != 0;
		}
		bool hasWing() const
		{
			return defaultOutfit.lookWings != 0;
		}
		bool hasShader() const
		{
			return defaultOutfit.lookShader != "";
		}
		bool hasOutline() const
		{
			return defaultOutfit.lookOutline != "";
		}

		

		bool hasShader(const Shader* shader) const;
		bool addShader(uint8_t shaderId);

		bool hasOutline(const Outline* outline) const;
		bool addOutline(uint8_t outlineId);

		bool tameMount(uint8_t mountId);
		bool toggleMount(bool mount);
		bool untameMount(uint8_t mountId);
		bool hasMount(const Mount* mount) const;
		void dismount();
		#endif
		
		bool addWings(uint16_t wingId);
		bool hasWing(const Wing* wing) const;

		bool addAura(uint16_t auraId);
		bool hasAura(const Aura* aura) const;

		void sendFYIBox(const std::string& message) {
			if (client) {
				client->sendFYIBox(message);
			}
		}

		void setGUID(uint32_t guid) {
			this->guid = guid;
		}
		uint32_t getGUID() const {
			return guid;
		}
		bool canSeeInvisibility() const override {
			return hasFlag(PlayerFlag_CanSenseInvisibility) || group->access;
		}

		bool hasOutfit(uint16_t looktype, uint8_t addon) const;
		void removeList() override;
		void addList() override;
		void kickPlayer(bool displayEffect);
		static uint64_t getExpForLevel(uint64_t level)
		{
			if (level >= 349) {
				return 0;
			}
			level += 1;

			double baseExp = 50.0;
			if (level >= 50) {
				baseExp += static_cast<double>(level - 50);
			}

			double exp =
				((baseExp * std::pow(static_cast<double>(level), 3.0)) / 3.0)
				- (100.0 * std::pow(static_cast<double>(level), 2.0))
				+ ((850.0 * static_cast<double>(level)) / 3.0)
				- 200.0;

			exp *= 2.0;

			// scaling 85+
			if (level >= 85) {
				double extraFactor = 1.0 + (static_cast<double>(level) - 85.0) * 0.1;
				exp *= extraFactor;
			}

			if (level >= 120)
			{
				double x = static_cast<double>(level) - 120;          // ile leveli po soft capie
				double factor = 1.0 + x * 0.174;
				exp *= factor;
			}

			return static_cast<uint64_t>(std::floor(exp));
		}

		uint16_t getStaminaMinutes() const {
			return staminaMinutes;
		}

		bool addOfflineTrainingTries(skills_t skill, uint64_t tries);

		void addOfflineTrainingTime(int32_t addTime) {
			offlineTrainingTime = std::min<int32_t>(12 * 3600 * 1000, offlineTrainingTime + addTime);
		}
		void removeOfflineTrainingTime(int32_t removeTime) {
			offlineTrainingTime = std::max<int32_t>(0, offlineTrainingTime - removeTime);
		}
		int32_t getOfflineTrainingTime() const {
			return offlineTrainingTime;
		}

		int32_t getOfflineTrainingSkill() const {
			return offlineTrainingSkill;
		}
		void setOfflineTrainingSkill(int32_t skill) {
			offlineTrainingSkill = skill;
		}

		uint64_t getBankBalance() const {
			return bankBalance;
		}
		void setBankBalance(uint64_t balance) {
			bankBalance = balance;
			sendPlayerGold(bankBalance);
		}

		Guild* getGuild() const {
			return guild;
		}
		void setGuild(Guild* guild);

		const GuildRank* getGuildRank() const {
			return guildRank;
		}
		void setGuildRank(const GuildRank* newGuildRank) {
			guildRank = newGuildRank;
		}

		bool isGuildMate(const Player* player) const;

		const std::string& getGuildNick() const {
			return guildNick;
		}
		void setGuildNick(std::string nick) {
			guildNick = std::move(nick);
		}

		bool isInWar(const Player* player) const;
		bool isInWarList(uint32_t guildId) const;

		void setLastWalkthroughAttempt(int64_t walkthroughAttempt) {
			lastWalkthroughAttempt = walkthroughAttempt;
		}
		void setLastWalkthroughPosition(Position walkthroughPosition) {
			lastWalkthroughPosition = walkthroughPosition;
		}

		Inbox* getInbox() const {
			return inbox;
		}
		
		TempStorage* getTempStorage() const {
			return tempStorage;
		}

		TradeStorage* getTradeStorage() const {
			return tradeStorage;
		}

		uint32_t getClientIcons() const;

		const GuildWarVector& getGuildWarVector() const {
			return guildWarVector;
		}

		Vocation* getVocation() const {
			return vocation;
		}
		
		OperatingSystem_t getOperatingSystem() const {
			return operatingSystem;
		}
		void setOperatingSystem(OperatingSystem_t clientos) {
			operatingSystem = clientos;
		}
		OperatingSystem_t getTfcOperatingSystem() const {
			return tfcOperatingSystem;
		}
		void setTfcOperatingSystem(OperatingSystem_t clientos) {
			tfcOperatingSystem = clientos;
		}

		uint16_t getProtocolVersion() const {
			if (!client) {
				return 0;
			}

			return client->getVersion();
		}

		bool hasSecureMode() const {
			return secureMode;
		}

		void setParty(Party* party) {
			this->party = party;
		}
		Party* getParty() const {
			return party;
		}
		PartyShields_t getPartyShield(const Player* player) const;
		bool isInviting(const Player* player) const;
		bool isPartner(const Player* player) const;
		void sendPlayerPartyIcons(Player* player);
		bool addPartyInvitation(Party* party);
		void removePartyInvitation(Party* party);
		void clearPartyInvitations();

		GuildEmblems_t getGuildEmblem(const Player* player) const;

		uint64_t getSpentMana() const {
			return manaSpent;
		}

		bool hasFlag(PlayerFlags value) const {
			return (group->flags & value) != 0;
		}

		BedItem* getBedItem() {
			return bedItem;
		}
		void setBedItem(BedItem* b) {
			bedItem = b;
		}

		void addBlessing(uint8_t blessing) {
			blessings |= blessing;
		}
		void removeBlessing(uint8_t blessing) {
			blessings &= ~blessing;
		}
		bool hasBlessing(uint8_t value) const {
			return (blessings & (static_cast<uint8_t>(1) << value)) != 0;
		}

		bool isOffline() const {
			return (getID() == 0);
		}
		void disconnect() {
			if (client) {
				client->disconnect();
			}
		}

		void setIP(uint32_t ip) {
			this->ip = ip;
		}
		uint32_t getIP() const {
			return this->ip;
		}

		void setInstanceId(uint32_t id) {
			this->instanceId = id;
		}
		uint32_t getInstanceId() const {
			return this->instanceId;
		}

		void addContainer(uint8_t cid, Container* container);
		void closeContainer(uint8_t cid);
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		void setContainerIndex(uint8_t cid, uint16_t index);
		#endif

		Container* getContainerByID(uint8_t cid);
		int8_t getContainerID(const Container* container) const;
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		uint16_t getContainerIndex(uint8_t cid) const;
		#endif

		bool canOpenCorpse(uint32_t ownerId) const;

		void addStorageValue(const uint32_t key, const int32_t value, const bool isLogin = false);
		bool getStorageValue(const uint32_t key, int32_t& value) const;

		void setAccountStorageValue(const uint32_t key, const int32_t value);
		bool getAccountStorageValue(const uint32_t key, int32_t& value) const;


		#if GAME_FEATURE_QUEST_TRACKER > 0
		size_t getAllowedTrackedQuestCount() const;
		bool hasTrackingQuest(uint16_t missionId) const;
		void resetTrackedQuests(std::vector<uint16_t>& quests);
		#endif

		void setGroup(Group* newGroup) {
			group = newGroup;
		}
		Group* getGroup() const {
			return group;
		}

		void setLastDepotId(int16_t newId) {
			lastDepotId = newId;
		}
		int16_t getLastDepotId() const {
			return lastDepotId;
		}

		void resetIdleTime() {
			idleTime = 0;
		}

		int32_t getIdleTime() const {
			return idleTime;
		}

		bool isInGhostMode() const override {
			return ghostMode;
		}
		void switchGhostMode() {
			ghostMode = !ghostMode;
		}

		uint32_t getAccount() const {
			return accountNumber;
		}
		AccountType_t getAccountType() const {
			return accountType;
		}
		uint32_t getLevel() const {
			return level;
		}
		void setLevel(uint32_t newLevel) {
			level = newLevel;
			experience = getExpForLevel(level); 
		}
		uint8_t getLevelPercent() const {
			return levelPercent;
		}
		uint32_t getMagicLevel() const {
			return std::max<int32_t>(0, magLevel + varStats[STAT_MAGICPOINTS]);
		}
		uint32_t getBaseMagicLevel() const {
			return magLevel;
		}
		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		uint16_t getMagicLevelPercent() const {
		#else
		uint8_t getMagicLevelPercent() const {
		#endif
			return magLevelPercent;
		}
		uint8_t getSoul() const {
			return soul;
		}
		bool isAccessPlayer() const {
			return group->access;
		}
		bool isPremium() const;
		void setPremiumDays(int32_t v);

		uint16_t getHelpers() const;

		bool setVocation(uint16_t vocId, bool internal = false);
		uint16_t getVocationId() const {
			return vocation->getId();
		}

		PlayerSex_t getSex() const {
			return sex;
		}
		void setSex(PlayerSex_t);
		uint64_t getExperience() const {
			return experience;
		}

		time_t getLastLoginSaved() const {
			return lastLoginSaved;
		}

		time_t getLastLogout() const {
			return lastLogout;
		}
		
		time_t getFirstLogin() const {
			return firstLogin;
		}

		time_t getOnlineTime() const {
			return onlineTime;
		}

		uint16_t getDungeonTier() const {
			return dungeonTier;
		}

		uint64_t getDPS() const {
			return dps;
		}

		void setDPS(uint64_t dps) {
			this->dps = dps;
		}

		void setDungeonTier(uint16_t dungeonTier) {
			this->dungeonTier = dungeonTier;
		}

		uint32_t getKills() const {
			return kills;
		}

		void setKills(uint32_t kills) {
			this->kills = kills;
		}

		void addKill() {
			++kills;
		}

		uint32_t getDeaths() const {
			return deaths;
		}

		void setDeaths(uint32_t deaths) {
			this->deaths = deaths;
		}

		void addDeath() {
			++deaths;
		}

		const Position& getLoginPosition() const {
			return loginPosition;
		}
		const Position& getTemplePosition() const {
			return town->getTemplePosition();
		}
		Town* getTown() const {
			return town;
		}
		void setTown(Town* town) {
			this->town = town;
		}

		void clearModalWindows();
		bool hasModalWindowOpen(uint32_t modalWindowId) const;
		void onModalWindowHandled(uint32_t modalWindowId);

		bool isPushable() const override;
		uint32_t isMuted() const;
		void addMessageBuffer();
		void removeMessageBuffer();

		bool removeItemOfType(uint16_t itemId, uint32_t amount, int32_t subType, bool ignoreEquipped = false) const;

		uint32_t getCapacity() const {
			return std::numeric_limits<uint32_t>::max();
		}

		uint32_t getFreeCapacity() const {
			return std::numeric_limits<uint32_t>::max();
		}

		int64_t getMaxHealth() const override;
		int64_t getMaxEnergyShield() const override;
		double getPrecentEnergyShieldMultiplier() const;
		
		int64_t getMana() const {
			return mana;
		}

		int64_t getHealth() const {
			return health;
		}

		int64_t getRealMaxMana() const;
		double getPrecentManaMultiplier() const;
		int64_t getRealMaxHealth() const override;
		double getPrecentHealthMultiplier() const;

		int64_t getMaxMana() const;

		void addReservation(uint32_t id, float value, bool health) {
			if (health) {
				healthReservation[id] = value;
			} else {
				manaReservation[id] = value;
			}

			setupReservations();
		}

		void setupReservations() {
			float value = 1.0f;
			for (auto& it : (manaReservation)) {
				value -= it.second;
			}
			manaReservationTotal = value;

			value = 1.0f;
			for (auto& it : (healthReservation)) {
				value -= it.second;
			}
			healthReservationTotal = value;

			if (getHealth() > getMaxHealth()) {
				health = getMaxHealth();
			}

			if (getMana() > getMaxMana()) {
				mana = getMaxMana();
			}
		}

		void correctStats();

		float getReservationTotal(bool health) const {
			return health ? healthReservationTotal : manaReservationTotal;
		}

		float getReservation(bool health) const {
			float value = 1.0f;

			for (auto& it : (health ? healthReservation : manaReservation)) {
				value -= it.second;
			}
	
			return value;
		}

		void removeReservation(uint32_t id) {
			healthReservation.erase(id);
			manaReservation.erase(id);
			setupReservations();
		}

		void addManaGain(uint32_t id, int32_t manaGain, bool setup) {
			manaGainMap[id] = manaGain;
			if (setup) {
				setupRegenrations(3);
			}
		}
		void removeManaGain(uint32_t id, bool setup) {
			manaGainMap.erase(id);
			if (setup) {
				setupRegenrations(3);
			}
		}
		int32_t getManaGain(uint32_t id) {
			return manaGainMap[id];
		}
		std::map<uint32_t, int32_t> getManaGainMap() {
			return manaGainMap;
		}

		bool isFullMana() const {
			return getMana() >= getMaxMana();
		}
		double getManaRest() const {
			return manaRest;
		}
		void setManaRest(double newManaRest) {
			manaRest = newManaRest;
		}
		double getManaRestGain() const {
			return manaRestGain;
		}
		void setManaRestGain(double newManaRestGain) {
			manaRestGain = newManaRestGain;
		}


		int32_t getManaTotalGain() const {
			return manaGain;
		}
		void setManaGain(int32_t newManaGain) {
			manaGain = newManaGain;
		}
		void setManaGainTicks(uint32_t newManaGainTicks) {
			manaGainTicks = newManaGainTicks;
		}
		uint32_t getManaGainTicks() const {
			return manaGainTicks;
		}

		int32_t getTotalManaGain() {
			int32_t positiveManaGain = 0;
			int32_t negativeManaGain = 0;
			
			for (auto& it : manaGainMap) {
				if (it.second > 0) {
					positiveManaGain += it.second;
				} else {
					negativeManaGain += it.second;
				}
			}

			int32_t manaGainPrecent = 100;
			for (auto& it : manaGainPrecentMap) {
				manaGainPrecent += it.second;
			}

			double positiveResult = positiveManaGain * ((double)manaGainPrecent / 100);
			double totalResult = positiveResult + negativeManaGain;

			return std::ceil(totalResult);
		}

		int32_t getTotalPrecentManaGain() {
			int32_t totalManaGain = 0;
			for (auto& it : manaGainPrecentMap) {
				totalManaGain += it.second;
			}
			return totalManaGain;
		}

		void addManaPrecentGain(uint32_t id, int32_t manaGain, bool setup) {
			manaGainPrecentMap[id] = manaGain;
			if (setup) {
				setupRegenrations(3);
			}
		}
		int32_t getManaPrecentGain(uint32_t id) {
			return manaGainPrecentMap[id];
		}
		void removeManaPrecentGain(uint32_t id, bool setup) {
			manaGainPrecentMap.erase(id);
			if (setup) {
				setupRegenrations(3);
			}
		}
		std::map<uint32_t, int32_t> getManaPrecentGainMap() {
			return manaGainPrecentMap;
		}

		Item* getInventoryItem(slots_t slot) const;

		bool isItemAbilityEnabled(slots_t slot) const {
			return inventoryAbilities[slot];
		}
		void setItemAbility(slots_t slot, bool enabled) {
			inventoryAbilities[slot] = enabled;
		}

		void setVarSkill(skills_t skill, int32_t modifier) {
			varSkills[skill] += modifier;
		}

		void setVarSpecialSkill(SpecialSkills_t skill, int32_t modifier) {
			varSpecialSkills[skill] += modifier;
		}

		void setVarStats(stats_t stat, int32_t modifier);
		int32_t getVarStats(stats_t stat) const {
			return varStats[stat];
		}
		int32_t getDefaultStats(stats_t stat) const;

		void addConditionSuppressions(uint32_t conditions);
		void removeConditionSuppressions(uint32_t conditions);

		DepotChest* getDepotChest(uint32_t depotId, bool autoCreate);
		DepotLocker* getDepotLocker(uint32_t depotId);
		void onReceiveMail() const;
		bool isNearDepotBox() const;

		bool canSee(const Position& pos) const override;
		bool canSeeCreature(const Creature* creature) const override;

		bool canWalkthrough(const Creature* creature) const;
		bool canWalkthroughEx(const Creature* creature) const;

		RaceType_t getRace() const override {
			return RACE_BLOOD;
		}

		uint64_t getMoney() const;
		bool removeTotalMoney(uint64_t amount);
		uint64_t getTotalMoney() const {
			return getMoney() + getBankBalance();
		}

		//shop functions
		void setShopOwner(Npc* owner, int32_t onBuy, int32_t onSell) {
			shopOwner = owner;
			purchaseCallback = onBuy;
			saleCallback = onSell;
		}

		Npc* getShopOwner(int32_t& onBuy, int32_t& onSell) {
			onBuy = purchaseCallback;
			onSell = saleCallback;
			return shopOwner;
		}

		const Npc* getShopOwner(int32_t& onBuy, int32_t& onSell) const {
			onBuy = purchaseCallback;
			onSell = saleCallback;
			return shopOwner;
		}

		//V.I.P. functions
		void notifyStatusChange(Player* loginPlayer, VipStatus_t status);
		bool removeVIP(uint32_t vipGuid);
		bool addVIP(uint32_t vipGuid, const std::string& vipName, VipStatus_t status);
		bool addVIPInternal(uint32_t vipGuid);
		bool editVIP(uint32_t vipGuid, const std::string& description, uint32_t icon, bool notify);

		//follow functions
		bool setFollowCreature(Creature* creature) override;
		void goToFollowCreature() override;

		//follow events
		void onFollowCreature(const Creature* creature) override;

		//walk events
		void onWalk(Direction& dir) override;
		void onWalkAborted() override;
		void onWalkComplete() override;

		void stopWalk();
		void openShopWindow(Npc* npc, std::vector<ShopInfo>& shop);
		bool closeShopWindow(bool sendCloseShopWindow = true);
		bool updateSaleShopList(const Item* item);
		bool hasShopItemForSale(uint32_t itemId, uint8_t subType) const;
		bool hasShopItemForBuy(uint32_t itemId) const;

		void setChaseMode(bool mode);
		void setFightMode(fightMode_t mode) {
			fightMode = mode;
		}
		void setSecureMode(bool mode) {
			secureMode = mode;
		}

		bool canUpadteStore() const {
			return canPlayerUpdateShop;
		}

		void setCanUpdateShop(bool value) {
			canPlayerUpdateShop = value;
		} 

		//combat functions
		bool setAttackedCreature(Creature* creature) override;
		bool isImmune(CombatType_t type) const override;
		bool isImmune(ConditionType_t type) const override;
		bool hasShield() const;
		bool isAttackable() const override;
		static bool lastHitIsPlayer(Creature* lastHitCreature);

		void changeHealth(int64_t healthChange, bool sendHealthChange = true) override;
		void changeEnergyShield(int64_t energyShieldChange, bool sendHealthChange = true) override;
		void changeMana(int64_t manaChange);
		void changeSoul(int32_t soulChange);

		bool canDrainMana(int64_t manaChange) const {
			return mana >= static_cast<uint64_t>(std::abs(manaChange));
		}

		bool isPzLocked() const {
			return pzLocked;
		}
		BlockType_t blockHit(Creature* attacker, CombatType_t combatType, int64_t& damage,
		                             bool checkDefense = false, bool checkArmor = false, bool field = false) override;
		void doAttacking(uint32_t interval) override;
		bool hasExtraSwing() override {
			return lastAttack > 0 && ((OTSYS_TIME() - lastAttack) >= getAttackSpeed());
		}

		uint16_t getSpecialSkill(uint8_t skill) const {
			return std::max<int32_t>(0, varSpecialSkills[skill]);
		}
		uint16_t getSkillLevel(uint8_t skill) const {
			return std::max<int32_t>(0, skills[skill].level + varSkills[skill]);
		}
		uint16_t getBaseSkill(uint8_t skill) const {
			return skills[skill].level;
		}
		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		uint16_t getSkillPercent(uint8_t skill) const {
		#else
		uint8_t getSkillPercent(uint8_t skill) const {
		#endif
			return skills[skill].percent;
		}

		bool getAddAttackSkill() const {
			return addAttackSkillPoint;
		}
		BlockType_t getLastAttackBlockType() const {
			return lastAttackBlockType;
		}

		Item* getWeapon(slots_t slot, bool ignoreAmmo) const;
		Item* getWeapon(bool ignoreAmmo = false) const;
		WeaponType_t getWeaponType() const;
		int32_t getWeaponSkill(const Item* item) const;
		void getShieldAndWeapon(const Item*& shield, const Item*& weapon) const;

		void drainHealth(Creature* attacker, int64_t damage) override;
		void drainMana(Creature* attacker, int64_t manaLoss);
		void addManaSpent(uint64_t amount);
		void addSkillAdvance(skills_t skill, uint64_t count);

		int32_t getArmor() const override;
		float getDefense() const override;
		float getAttackFactor() const override;
		float getDefenseFactor() const override;

		void addInFightTicks(bool pzlock = false);

		uint64_t getGainedExperience(Creature* attacker) const override;

		//combat event functions
		void onAddCondition(ConditionType_t type) override;
		void onAddCombatCondition(ConditionType_t type) override;
		void onEndCondition(ConditionType_t type) override;
		void onCombatRemoveCondition(Condition* condition) override;
		void onAttackedCreature(Creature* target) override;
		void onAttacked() override;
		void onAttackedCreatureDrainHealth(Creature* target, int64_t points) override;
		void onTargetCreatureGainHealth(Creature* target, int64_t points) override;
		bool onKilledCreature(Creature* target, bool lastHit = true) override;
		void onGainExperience(uint64_t gainExp, Creature* target) override;
		void onGainSharedExperience(uint64_t gainExp, Creature* source);
		void onAttackedCreatureBlockHit(BlockType_t blockType) override;
		void onBlockHit() override;
		void onChangeZone(ZoneType_t zone) override;
		void onAttackedCreatureChangeZone(ZoneType_t zone) override;
		void onIdleStatus() override;
		void onPlacedCreature() override;

		LightInfo getCreatureLight() const override;

		Skulls_t getSkull() const override;
		Skulls_t getSkullClient(const Creature* creature) const override;
		int64_t getSkullTicks() const { return skullTicks; }
		void setSkullTicks(int64_t ticks) { skullTicks = ticks; }

		bool hasAttacked(const Player* attacked) const;
		void addAttacked(const Player* attacked);
		void removeAttacked(const Player* attacked);
		void clearAttacked();
		void addUnjustifiedDead(const Player* attacked);
		void sendCreatureSkull(const Creature* creature) const {
			if (client) {
				client->sendCreatureSkull(creature);
			}
		}
		void checkSkullTicks(int64_t ticks);

		void sendActiveAuras(const Creature* creature) const {
			if (client) {
				client->sendActiveAuras(creature);
			}
		}

		void sendPartyInvite(const std::string& name, const uint32_t cid) const {
			if (client) {
				client->sendPartyInvite(name, cid);
			}
		}

		void sendJump(const Creature* creature, uint16_t height, uint16_t duration) const {
			if (client) {
				client->sendCreatureJump(creature, height, duration);
			}
		}

		void sendProgressBar(const Creature* creature, const uint32_t duration, const bool ltr) const {
			if (client) {
				client->sendProgressBar(creature, duration, ltr);
			}
		}

		void sendServerTime() const {
			if (client) {
				client->sendServerTime();
			}
		}

		void sendPlayerGold(uint64_t gold) const {
			if (client) {
				client->sendPlayerGold(gold);
			}
		}

		bool canWear(uint32_t lookType, uint8_t addons) const;
		bool addOutfit(uint16_t lookType, uint8_t addons);
		bool getOutfitAddons(const Outfit& outfit, uint8_t& addons) const;

		bool canLogout();

		size_t getMaxVIPEntries() const;
		size_t getMaxDepotItems() const;

		void setCharacterStat(CharacterStats_t stat, int16_t value);
		void addCharacterStat(CharacterStats_t stat, int16_t value);
		int16_t getCharacterStat(CharacterStats_t stat) const {
			return charStats[stat];
		}

		//tile
		//send methods
		void sendAddTileItem(const Tile* tile, const Position& pos, const Item* item) {
			if (client) {
				int32_t stackpos = tile->getStackposOfItem(this, item);
				if (stackpos != -1) {
					#if GAME_FEATURE_TILE_ADDTHING_STACKPOS > 0
					client->sendAddTileItem(pos, stackpos, item);
					#else
					client->sendAddTileItem(pos, item);
					#endif
				}
			}
		}
		void sendUpdateTileItem(const Tile* tile, const Position& pos, const Item* item) {
			if (client) {
				int32_t stackpos = tile->getStackposOfItem(this, item);
				if (stackpos != -1) {
					client->sendUpdateTileItem(pos, stackpos, item);
				}
			}
		}
		void sendRemoveTileThing(const Position& pos, int32_t stackpos) {
			if (stackpos != -1 && client) {
				client->sendRemoveTileThing(pos, stackpos);
			}
		}
		void sendUpdateTile(const Tile* tile, const Position& pos) {
			if (client) {
				client->sendUpdateTile(tile, pos);
			}
		}
		void sendMapDescription() {
			if (client) {
				client->sendMapDescription(getPosition());
			}
		}

		void sendChannelMessage(const std::string& author, const std::string& text, SpeakClasses type, uint16_t channel) {
			if (client) {
				client->sendChannelMessage(author, text, type, channel);
			}
		}
		#if GAME_FEATURE_CHAT_PLAYERLIST > 0
		void sendChannelEvent(uint16_t channelId, const std::string& playerName, ChannelEvent_t channelEvent) {
			if (client) {
				client->sendChannelEvent(channelId, playerName, channelEvent);
			}
		}
		#endif
		void sendCreatureAppear(const Creature* creature, const Position& pos, bool isLogin) {
			if (client) {
				client->sendAddCreature(creature, pos, creature->getTile()->getStackposOfCreature(this, creature), isLogin);
			}
		}
		void sendCreatureMove(const Creature* creature, const Position& newPos, int32_t newStackPos, const Position& oldPos, int32_t oldStackPos, bool teleport) {
			if (client) {
				client->sendMoveCreature(creature, newPos, newStackPos, oldPos, oldStackPos, teleport);
			}
		}
		void sendCreatureTurn(const Creature* creature) {
			if (client && canSeeCreature(creature)) {
				int32_t stackpos = creature->getTile()->getStackposOfCreature(this, creature);
				if (stackpos != -1) {
					client->sendCreatureTurn(creature, stackpos);
				}
			}
		}
		void sendCreatureSay(const Creature* creature, SpeakClasses type, const std::string& text, const Position* pos = nullptr) {
			if (client) {
				client->sendCreatureSay(creature, type, text, pos);
			}
		}
		void sendPrivateMessage(const Player* speaker, SpeakClasses type, const std::string& text) {
			if (client) {
				client->sendPrivateMessage(speaker, type, text);
			}
		}
		void sendCreatureSquare(const Creature* creature, SquareColor_t color) {
			if (client) {
				client->sendCreatureSquare(creature, color);
			}
		}
		void sendCreatureChangeOutfit(const Creature* creature, const Outfit_t& outfit) {
			if (client) {
				client->sendCreatureOutfit(creature, outfit);
			}
		}
		void sendCreatureChangeVisible(const Creature* creature, bool visible) {
			if (!client) {
				return;
			}

			if (creature->getPlayer()) {
				if (visible) {
					client->sendCreatureOutfit(creature, creature->getCurrentOutfit());
				} else {
					static Outfit_t outfit;
					client->sendCreatureOutfit(creature, outfit);
				}
			} else if (canSeeInvisibility()) {
				client->sendCreatureOutfit(creature, creature->getCurrentOutfit());
			} else {
				int32_t stackpos = creature->getTile()->getStackposOfCreature(this, creature);
				if (stackpos == -1) {
					return;
				}

				if (visible) {
					client->sendAddCreature(creature, creature->getPosition(), stackpos, false);
				} else {
					client->sendRemoveTileThing(creature->getPosition(), stackpos);
				}
			}
		}
		void sendCreatureLight(const Creature* creature) {
			if (client) {
				client->sendCreatureLight(creature);
			}
		}
		#if CLIENT_VERSION >= 854
		void sendCreatureWalkthrough(const Creature* creature, bool walkthrough) {
			if (client) {
				client->sendCreatureWalkthrough(creature, walkthrough);
			}
		}
		#endif

		void sendCreatureAttackable(const Creature* creature, bool attackable) {
			if (client) {
				client->sendCreatureAttackable(creature, attackable);
			}
		}
		void sendCreatureShield(const Creature* creature) {
			if (client) {
				client->sendCreatureShield(creature);
			}
		}
		void sendAnimatedText(const std::string& message, const Position& pos, TextColor_t color, const std::string& font) {
            if (client) {
                client->sendAnimatedText(message, pos, color, font);
            }
        }
		#if CLIENT_VERSION >= 910
		void sendCreatureType(const Creature* creature, uint8_t creatureType) {
			if (client) {
				client->sendCreatureType(creature, creatureType);
			}
		}
		#endif
		#if CLIENT_VERSION >= 1000 && CLIENT_VERSION < 1185
		void sendCreatureHelpers(uint32_t creatureId, uint16_t helpers) {
			if (client) {
				client->sendCreatureHelpers(creatureId, helpers);
			}
		}
		#endif
		#if CLIENT_VERSION >= 870
		void sendSpellCooldown(uint8_t spellId, uint32_t time) {
			if (client) {
				client->sendSpellCooldown(spellId, time);
			}
		}
		void sendSpellGroupCooldown(SpellGroup_t groupId, uint32_t time) {
			if (client) {
				client->sendSpellGroupCooldown(groupId, time);
			}
		}
		#endif
		void sendModalWindow(const ModalWindow& modalWindow);

		//container
		void sendAddContainerItem(const Container* container, const Item* item);
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		void sendUpdateContainerItem(const Container* container, uint16_t slot, const Item* newItem);
		void sendRemoveContainerItem(const Container* container, uint16_t slot);
		void sendContainer(uint8_t cid, const Container* container, bool hasParent, uint16_t firstIndex) {
			if (client) {
				client->sendContainer(cid, container, hasParent, firstIndex);
			}
		}
		#else
		void sendUpdateContainerItem(const Container* container, uint8_t slot, const Item* newItem);
		void sendRemoveContainerItem(const Container* container, uint8_t slot);
		void sendContainer(uint8_t cid, const Container* container, bool hasParent) {
			if (client) {
				client->sendContainer(cid, container, hasParent);
			}
		}
		#endif

		//inventory
		void sendInventoryItem(slots_t slot, const Item* item) {
			if (client) {
				client->sendInventoryItem(slot, item);
			}
		}
		#if GAME_FEATURE_INVENTORY_LIST > 0
		void sendItems(const std::map<uint32_t, PlayerInventorySellItem>& inventoryMap) {
			if (client) {
				client->sendItems(inventoryMap);
			}
		}
		#endif

		//event methods
		void onUpdateTileItem(const Tile* tile, const Position& pos, const Item* oldItem,
		                              const ItemType& oldType, const Item* newItem, const ItemType& newType) override;
		void onRemoveTileItem(const Tile* tile, const Position& pos, const ItemType& iType,
		                              const Item* item) override;

		void onCreatureAppear(Creature* creature, bool isLogin) override;
		void onRemoveCreature(Creature* creature, bool isLogout) override;
		void onCreatureMove(Creature* creature, const Tile* newTile, const Position& newPos,
		                            const Tile* oldTile, const Position& oldPos, bool teleport) override;

		void onAttackedCreatureDisappear(bool isLogout) override;
		void onFollowCreatureDisappear(bool isLogout) override;

		void onCloseContainer(const Container* container);
		void onSendContainer(const Container* container);
		void autoCloseContainers(const Container* container);


		void updateCreatureData(const Creature* creature) const {
			if (client) {
				client->updateCreatureData(creature);
			}
		}
		void sendCancelMessage(const std::string& msg) const {
			if (client) {
				client->sendTextMessage(TextMessage(MESSAGE_STATUS_SMALL, msg));
			}
		}

		void sendTileWidget(const Tile* tile, const Position& pos) {
			if (client) {
				client->sendTileWidget(tile, pos);
			}
		}
		void sendTileRemoveWidget(const Tile* tile, const Position& pos) {
			if (client) {
				client->sendTileRemoveWidget(tile, pos);
			}
		}

		void sendCancelMessage(ReturnValue message) const;
		void sendCancelTarget() const {
			if (client) {
				client->sendCancelTarget();
			}
		}
		void sendCancelWalk() const {
			if (client) {
				client->sendCancelWalk();
			}
		}

		void sendNewCancelWalk() const {
			if (client) {
				client->sendNewCancelWalk();
			}
		}
		void sendChangeSpeed(const Creature* creature, uint32_t newSpeed) const {
			if (client) {
				client->sendChangeSpeed(creature, newSpeed);
			}
		}
		void sendCreatureHealth(const Creature* creature, uint8_t healthPercent, uint8_t energyPercent) const {
			if (client) {
				client->sendCreatureHealth(creature, healthPercent, energyPercent);
			}
		}
		#if GAME_FEATURE_PARTY_LIST > 0
		void sendPartyCreatureUpdate(const Creature* creature) const {
			if (client) {
				client->sendPartyCreatureUpdate(creature);
			}
		}
		void sendPartyCreatureHealth(const Creature* creature, uint8_t healthPercent) const {
			if (client) {
				client->sendPartyCreatureHealth(creature, healthPercent);
			}
		}
		void sendPartyPlayerMana(const Player* player, uint8_t manaPercent) const {
			if (client) {
				client->sendPartyPlayerMana(player, manaPercent);
			}
		}
		void sendPartyCreatureShowStatus(const Creature* creature, bool showStatus) const {
			if (client) {
				client->sendPartyCreatureShowStatus(creature, showStatus);
			}
		}
		void sendPartyJoin(const Creature* creature) const {
			if (client) {
				client->sendPartyJoin(creature);
			}
		}
		void sendPartyPlayerPos(const Creature* creature, const Position pos) const {
			if (client) {
				client->sendPartyPlayerPos(creature, pos);
			}
		}
		void sendPartyUpdateShield(const Creature* creature) const {
			if (client) {
				client->sendPartyUpdateShield(creature);
			}
		}
		void sendPartyLeave(const Creature* creature) const {
			if (client) {
				client->sendPartyLeave(creature);
			}
		}
		void sendPartyDisband() const {
			if (client) {
				client->sendPartyDisband();
			}
		}
		#endif
		void sendDistanceShoot(const Position& from, const Position& to, uint16_t type, bool typeOb, uint16_t duration, double speed, const std::string color) const {
			if (client) {
				client->sendDistanceShoot(from, to, type, typeOb, duration, speed, color);
			}
		}
		void sendLineEffect(const Position& from, const Position& to, uint16_t type, bool bottom = false) const {
			if (client) {
				client->sendLineEffect(from, to, type, bottom);
			}
		}
		void sendHouseWindow(House* house, uint32_t listId) const;
		void sendCreatePrivateChannel(uint16_t channelId, const std::string& channelName) {
			if (client) {
				client->sendCreatePrivateChannel(channelId, channelName);
			}
		}
		void sendClosePrivate(uint16_t channelId);
		void sendIcons() const {
			if (client) {
				client->sendIcons(getClientIcons());
			}
		}
		void sendMagicEffect(const Position& pos, uint16_t type, uint8_t bottom = 0, const std::string color = "") const {
			if (client) {
				client->sendMagicEffect(pos, type, bottom, color);
			}
		}
		void sendCreatureEffect(const Creature* creature, uint16_t type, uint8_t bottom = 0) const {
			if (client) {
				client->sendCreatureEffect(creature, type, bottom);
			}
		}
		void sendPing();
		void sendPingBack() const {
			if (client) {
				client->sendPingBack();
			}
		}
		void sendStats(uint8_t type);
		#if CLIENT_VERSION >= 950
		void sendBasicData() const {
			if (client) {
				client->sendBasicData();
			}
		}
		#endif
		void sendSkills() const {
			if (client) {
				client->sendSkills();
			}
		}
		void sendTextMessage(MessageClasses mclass, const std::string& message) const {
			if (client) {
				client->sendTextMessage(TextMessage(mclass, message));
			}
		}
		void sendTextMessage(const TextMessage& message) const {
			if (client) {
				client->sendTextMessage(message);
			}
		}
		void sendReLoginWindow(uint8_t unfairFightReduction) const {
			if (client) {
				client->sendReLoginWindow(unfairFightReduction);
			}
		}
		void sendTextWindow(Item* item, uint16_t maxlen, bool canWrite) const {
			if (client) {
				client->sendTextWindow(windowTextId, item, maxlen, canWrite);
			}
		}
		void sendTextWindow(uint32_t itemId, const std::string& text) const {
			if (client) {
				client->sendTextWindow(windowTextId, itemId, text);
			}
		}
		void sendToChannel(const Creature* creature, SpeakClasses type, const std::string& text, uint16_t channelId) const {
			if (client) {
				client->sendToChannel(creature, type, text, channelId);
			}
		}
		void sendShop(Npc* npc) const {
			if (client) {
				client->sendShop(npc, shopItemList);
			}
		}
		void sendSaleItemList(const std::map<uint64_t, PlayerInventorySellItem>& uniqueMap, const std::map<uint32_t, uint16_t>& stackMap, uint8_t categoryIndex) const {
			if (client) {
				client->sendSaleItemList(uniqueMap, stackMap, categoryIndex);
			}
		}
		void sendCloseShop() const {
			if (client) {
				client->sendCloseShop();
			}
		}
		void sendWorldLight(LightInfo lightInfo) {
			if (client) {
				client->sendWorldLight(lightInfo);
			}
		}
		#if CLIENT_VERSION >= 1121
		void sendTibiaTime(int32_t time) {
			if (client) {
				client->sendTibiaTime(time);
			}
		}
		#endif
		#if GAME_FEATURE_INSPECTION > 0
		void sendItemInspection(uint16_t itemId, uint8_t itemCount, const Item* item, bool cyclopedia) {
			if (client) {
				client->sendItemInspection(itemId, itemCount, item, cyclopedia);
			}
		}
		#endif
		void sendChannelsDialog() {
			if (client) {
				client->sendChannelsDialog();
			}
		}
		void sendOpenPrivateChannel(const std::string& receiver) {
			if (client) {
				client->sendOpenPrivateChannel(receiver);
			}
		}
		void sendOutfitWindow() {
			if (client) {
				client->sendOutfitWindow();
			}
		}
		void sendCloseContainer(uint8_t cid) {
			if (client) {
				client->sendCloseContainer(cid);
			}
		}

		void sendChannel(uint16_t channelId, const std::string& channelName, const UsersMap* channelUsers, const InvitedMap* invitedUsers) {
			if (client) {
				client->sendChannel(channelId, channelName, channelUsers, invitedUsers);
			}
		}
		#if GAME_FEATURE_RULEVIOLATION > 0
		void sendRuleViolationChannel(uint16_t channelId) {
			if (client) {
				client->sendRuleViolationChannel(channelId);
			}
		}
		void sendRuleViolationRemove(const std::string& target) {
			if (client) {
				client->sendRuleViolationRemove(target);
			}
		}
		void sendRuleViolationCancel(const std::string& target) {
			if (client) {
				client->sendRuleViolationCancel(target);
			}
		}
		void sendRuleViolationLock() {
			if (client) {
				client->sendRuleViolationLock();
			}
		}
		void sendChannelMessage(const Player* target, const std::string& text, SpeakClasses type, uint32_t time) {
			if (client) {
				client->sendChannelMessage(target, text, type, time);
			}
		}
		#endif
		void sendTutorial(uint8_t tutorialId) {
			if (client) {
				client->sendTutorial(tutorialId);
			}
		}
		void sendAddMarker(const Position& pos, uint8_t markType, const std::string& desc) {
			if (client) {
				client->sendAddMarker(pos, markType, desc);
			}
		}
		void sendMonsterCyclopedia() {
			if (client) {
				client->sendMonsterCyclopedia();
			}
		}
		void sendCyclopediaMonsters(const std::string& race) {
			if (client) {
				client->sendCyclopediaMonsters(race);
			}
		}
		void sendCyclopediaRace(uint16_t monsterId) {
			if (client) {
				client->sendCyclopediaRace(monsterId);
			}
		}
		void sendCyclopediaBonusEffects() {
			if (client) {
				client->sendCyclopediaBonusEffects();
			}
		}
		#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
		void sendCyclopediaCharacterNoData(CyclopediaCharacterInfoType_t characterInfoType, uint8_t errorCode) {
			if (client) {
				client->sendCyclopediaCharacterNoData(characterInfoType, errorCode);
			}
		}
		void sendCyclopediaCharacterBaseInformation() {
			if (client) {
				client->sendCyclopediaCharacterBaseInformation();
			}
		}
		void sendCyclopediaCharacterGeneralStats() {
			if (client) {
				client->sendCyclopediaCharacterGeneralStats();
			}
		}
		void sendCyclopediaCharacterCombatStats() {
			if (client) {
				client->sendCyclopediaCharacterCombatStats();
			}
		}
		void sendCyclopediaCharacterRecentDeaths(uint16_t page, uint16_t pages, const std::vector<RecentDeathEntry>& entries) {
			if (client) {
				client->sendCyclopediaCharacterRecentDeaths(page, pages, entries);
			}
		}
		void sendCyclopediaCharacterRecentPvPKills(uint16_t page, uint16_t pages, const std::vector<RecentPvPKillEntry>& entries) {
			if (client) {
				client->sendCyclopediaCharacterRecentPvPKills(page, pages, entries);
			}
		}
		void sendCyclopediaCharacterAchievements() {
			if (client) {
				client->sendCyclopediaCharacterAchievements();
			}
		}
		void sendCyclopediaCharacterItemSummary() {
			if (client) {
				client->sendCyclopediaCharacterItemSummary();
			}
		}
		void sendCyclopediaCharacterOutfitsMounts() {
			if (client) {
				client->sendCyclopediaCharacterOutfitsMounts();
			}
		}
		void sendCyclopediaCharacterStoreSummary() {
			if (client) {
				client->sendCyclopediaCharacterStoreSummary();
			}
		}
		void sendCyclopediaCharacterInspection() {
			if (client) {
				client->sendCyclopediaCharacterInspection();
			}
		}
		void sendCyclopediaCharacterBadges() {
			if (client) {
				client->sendCyclopediaCharacterBadges();
			}
		}
		void sendCyclopediaCharacterTitles() {
			if (client) {
				client->sendCyclopediaCharacterTitles();
			}
		}
		#endif
		#if GAME_FEATURE_HIGHSCORES > 0
		void sendHighscoresNoData() {
			if (client) {
				client->sendHighscoresNoData();
			}
		}
		void sendHighscores(const std::vector<HighscoreCharacter>& characters, uint8_t categoryId, uint16_t page, uint16_t pages) {
			if (client) {
				client->sendHighscores(characters, categoryId, page, pages);
			}
		}
		#endif

		void sendMarketOffersNoData() {
			if (client) {
				client->sendMarketOffersNoData();
			}
		}
		void sendMarketResponse(uint8_t code, const std::string response) {
			if (client) {
				client->sendMarketResponse(code, response);
			}
		}
		void sendMarketOffers(const std::vector<MarketOffer>& offer, uint16_t page, uint16_t pages, uint8_t category) {
			if (client) {
				client->sendMarketOffers(offer, page, pages, category);
			}
		}
		void sendTournamentLeaderboard() {
			if (client) {
				client->sendTournamentLeaderboard();
			}
		}
		#if GAME_FEATURE_ANALYTICS > 0
		void sendImpactTracking(bool healing, int32_t impact) {
			if (client) {
				client->sendImpactTracking(healing, impact);
			}
		}
		#if GAME_FEATURE_ANALYTICS_IMPACT_TRACKING_EXTENDED > 0
		void sendImpactTracking(CombatType_t combatType, int32_t impact, const std::string& cause) {
			if (client) {
				client->sendImpactTracking(combatType, impact, cause);
			}
		}
		#endif
		void sendKillTracking(const std::string& name, const Outfit_t& outfit, const Container* container) {
			if (client) {
				client->sendKillTracking(name, outfit, container);
			}
		}
		#endif
		void sendQuestLog() {
			if (client) {
				client->sendQuestLog();
			}
		}
		void sendQuestLine(const Quest* quest) {
			if (client) {
				client->sendQuestLine(quest);
			}
		}
		#if GAME_FEATURE_QUEST_TRACKER > 0
		void sendTrackedQuests(uint8_t remainingQuests, std::vector<uint16_t>& quests) {
			if (client) {
				client->sendTrackedQuests(remainingQuests, quests);
			}
		}
		void sendUpdateTrackedQuest(const Mission* mission) {
			if (client) {
				client->sendUpdateTrackedQuest(mission);
			}
		}
		#endif
		#if CLIENT_VERSION >= 1000
		void sendFightModes() {
			if (client) {
				client->sendFightModes();
			}
		}
		#endif
		void sendNetworkMessage(const NetworkMessage& message) {
			if (client) {
				client->writeToOutputBuffer(message);
			}
		}

		void sendUpdateTileCreature(const Creature* creature) {
			if (client) {
				client->sendUpdateTileCreature(creature->getPosition(), creature->getTile()->getClientIndexOfCreature(this, creature), creature);
			}
		}

		void receivePing() {
			lastPong = OTSYS_TIME();
		}

		void setFPS(uint16_t value)
		{
			fps = value;
		}
		void setLocalPing(uint16_t value)
		{
			localPing = value;
		}
		uint16_t getFPS() const
		{
			return fps;
		}
		uint16_t getLocalPing() const
		{
			return localPing;
		}

		void startCamRecording()
		{
			if (client)
				client->startCamRecording();
		}
		void stopCamRecording()
		{
			if (client)
				client->stopCamRecording();
		}
		bool isRecording()
		{
			if (client)
				return client->isRecording();
			return false;
		}
		void sendCamRefreshPacket()
		{
			if (client)
				client->sendCamRefreshPacket();
		}

		bool isShop() const {
			return Shop;
		}

		void onThink(uint32_t interval) override;

		void postAddNotification(Thing* thing, const Cylinder* oldParent, int32_t index, cylinderlink_t link = LINK_OWNER) override;
		void postRemoveNotification(Thing* thing, const Cylinder* newParent, int32_t index, cylinderlink_t link = LINK_OWNER) override;

		void setNextAction(int64_t time) {
			if (time > nextAction) {
				nextAction = time;
			}
		}
		bool canDoAction() const {
			return nextAction <= OTSYS_TIME();
		}
		uint32_t getNextActionTime() const;

		Item* getWriteItem(uint32_t& windowTextId, uint16_t& maxWriteLen);
		void setWriteItem(Item* item, uint16_t maxWriteLen = 0);

		House* getEditHouse(uint32_t& windowTextId, uint32_t& listId);
		void setEditHouse(House* house, uint32_t listId = 0);

		void learnInstantSpell(const std::string& spellName);
		void forgetInstantSpell(const std::string& spellName);
		bool hasLearnedInstantSpell(const std::string& spellName) const;

		void addScheduledUpdates(uint32_t flags);
		bool hasScheduledUpdates(uint32_t flags) const {
			return (scheduledUpdates & flags);
		}
		void resetScheduledUpdates() {
			scheduledUpdates = 0;
			scheduledUpdate = false;
		}

		void addAsyncOngoingTask(uint64_t flags) {
			asyncOngoingTasks |= flags;
		}
		bool hasAsyncOngoingTask(uint64_t flags) const {
			return (asyncOngoingTasks & flags);
		}
		void resetAsyncOngoingTask(uint64_t flags) {
			asyncOngoingTasks &= ~(flags);
		}

		Item *getItemByUID(uint32_t uid) const;
		
		void setDungeon(Dungeon* dungeon) {
			this->dungeon = dungeon;
		}

		Dungeon* getDungeon() {
			return dungeon;
		}

		uint16_t getItemLevel() const;
		uint16_t getFreeBackpackSlots() const;
		
		uint32_t getItemTypeCount(uint16_t itemId, int32_t subType = -1, bool ignoreEquipped = false) const override;

		void autoOpenContainers();

		const std::map<uint8_t, OpenContainer>& getOpenContainers() const
		{
			return openContainers;
		}

		bool isShopping() const 
		{
			return shopOwner != nullptr;
		}

	private:
		std::shared_ptr<spdlog::logger> playerLogger;
		std::vector<Condition*> getMuteConditions() const;

		void gainExperience(uint64_t gainExp, Creature* source);
		void addExperience(Creature* source, uint64_t exp, bool sendText = false);
		void removeExperience(uint64_t exp, bool sendText = false, bool canRemoveLevel = true);

		void updateInventoryWeight();

		void stopNextWalkActionTask();
		void stopNextWalkTask();
		void stopNextActionTask();
		void setNextWalkActionTask(uint32_t delay, std::function<void (void)> f);
		void setNextWalkTask(uint32_t delay, std::function<void (void)> f);
		void setNextActionTask(uint32_t delay, std::function<void (void)> f);

		void death(Creature* lastHitCreature) override;
		bool dropCorpse(Creature* lastHitCreature, Creature* mostDamageCreature, bool lastHitUnjustified, bool mostDamageUnjustified) override;
		Item* getCorpse(Creature* lastHitCreature, Creature* mostDamageCreature) override;

		//cylinder implementations
		ReturnValue queryAdd(int32_t index, const Thing& thing, uint32_t count,
				uint32_t flags, Creature* actor = nullptr) const override;
		ReturnValue queryMaxCount(int32_t index, const Thing& thing, uint32_t count, uint32_t& maxQueryCount,
				uint32_t flags) const override;
		ReturnValue queryRemove(const Thing& thing, uint32_t count, uint32_t flags, Creature* actor = nullptr) const override;
		Cylinder* queryDestination(int32_t& index, const Thing& thing, Item** destItem,
				uint32_t& flags) override;

		void addThing(Thing*) override {}
		void addThing(int32_t index, Thing* thing) override;

		void updateThing(Thing* thing, uint16_t itemId, uint32_t count) override;
		void replaceThing(uint32_t index, Thing* thing) override;

		void removeThing(Thing* thing, uint32_t count) override;

		int32_t getThingIndex(const Thing* thing) const override;
		size_t getFirstIndex() const override;
		size_t getLastIndex() const override;

		void setLimitMaxHealth(uint32_t value) {
			limitMaxHealth = value;
			if (limitMaxHealth > 0) {
				if (getHealth() > getMaxHealth()) {
					health = getMaxHealth();
				}
			}
			sendStats(1);
		}

		uint32_t getLimitMaxHealth() const {
			return limitMaxHealth;
		}

		std::map<uint32_t, uint32_t>& getAllItemTypeCount(std::map<uint32_t, uint32_t>& countMap) const override;
		void getAllItemTypeCountAndSubtype(std::map<uint64_t, PlayerInventorySellItem>& uniqueMap, std::map<uint32_t, uint16_t>& stackMap) const;
		void setShopFilters(const std::string name, uint8_t rarity, uint8_t itemType, uint8_t categoryIndex) {
			filterRarity = rarity;
			filterName = name;
			filterItemType = itemType;
			filterCategoryIndex = categoryIndex;
		};
		Thing* getThing(size_t index) const override;

		void internalAddThing(Thing* thing) override;
		void internalAddThing(uint32_t index, Thing* thing) override;
		
		std::unordered_set<uint32_t> attackedSet;
		std::unordered_set<uint32_t> VIPList;

		std::map<uint8_t, OpenContainer> openContainers;
		std::map<uint32_t, DepotLocker*> depotLockerMap;
		std::map<uint32_t, DepotChest*> depotChests;
		std::unordered_map<uint32_t, int32_t> storageMap;
		std::unordered_map<uint32_t, int32_t> accountStorageMap;

		std::vector<uint32_t> modalWindows;
		GuildWarVector guildWarVector;

		std::vector<ShopInfo> shopItemList;

		std::unordered_set<std::string> learnedInstantSpellList;
		std::vector<Party*> invitePartyList;
		std::vector<Condition*> storedConditionList;

		#if GAME_FEATURE_QUEST_TRACKER > 0
		std::vector<uint16_t> trackedQuests;
		#endif

		std::string name;
		std::string guildNick;

		Skill skills[SKILL_LAST + 1];
		LightInfo itemsLight;
		Position loginPosition;
		Position lastWalkthroughPosition;

		time_t lastLoginSaved = 0;
		time_t lastLogout = 0;
		time_t firstLogin = 0;
		time_t onlineTime = 0;

		uint64_t dps = 0;
		uint16_t dungeonTier = 0;
		uint32_t kills = 0;
		uint32_t deaths = 0;

		bool canPlayerUpdateShop = true;
		bool Shop = false;
		bool setShop(bool shop);
		uint32_t limitMaxHealth = 0;
		uint64_t experience = 0;
		uint64_t manaSpent = 0;
		uint64_t lastAttack = 0;
		uint64_t bankBalance = 0;
		uint64_t lastQuestlogUpdate = 0;
		uint64_t actionTaskEvent = 0;
		uint64_t nextStepEvent = 0;
		uint64_t walkTaskEvent = 0;
		uint64_t asyncOngoingTasks = 0;
		int64_t lastFailedFollow = 0;
		int64_t skullTicks = 0;
		int64_t lastWalkthroughAttempt = 0;
		#if GAME_FEATURE_MOUNTS > 0
		int64_t lastToggleMount = 0;
		#endif
		int64_t lastPing;
		int64_t lastPong;
		int64_t nextAction = 0;

		BedItem* bedItem = nullptr;
		Guild* guild = nullptr;
		const GuildRank* guildRank = nullptr;
		Group* group = nullptr;
		Inbox* inbox;
 		Item* inventory[CONST_SLOT_LAST + 1] = {};
		Item* writeItem = nullptr;
		House* editHouse = nullptr;
		Npc* shopOwner = nullptr;
		Party* party = nullptr;
		ProtocolGame_ptr client;
		std::pair<uint32_t, std::function<void (void)>>* walkTask = nullptr;
		Town* town = nullptr;
		Vocation* vocation = nullptr;
		Dungeon* dungeon = nullptr;
		TempStorage* tempStorage = nullptr;
		TradeStorage* tradeStorage = nullptr;

		std::string filterName;
		uint8_t filterRarity;
		uint8_t filterItemType;
		uint8_t filterCategoryIndex;

		uint32_t scheduledUpdates = 0;
		uint32_t inventoryWeight = 0;
		uint32_t capacity = 40000;
		uint32_t damageImmunities = 0;
		uint32_t conditionImmunities = 0;
		uint32_t conditionSuppressions = 0;
		uint32_t level = 1;
		uint32_t magLevel = 0;
		uint32_t MessageBufferTicks = 0;
		uint32_t lastIP = 0;
		uint32_t accountNumber = 0;
		uint32_t guid = 0;
		uint32_t windowTextId = 0;
		uint32_t editListId = 0;
		uint64_t mana = 0;
		uint64_t manaMax = 0;


		std::map<uint32_t, float> manaReservation;
		std::map<uint32_t, float> healthReservation;

		float healthReservationTotal = 1.0f;
		float manaReservationTotal = 1.0f;
	
		uint32_t ip = 0;
		int32_t varSkills[SKILL_LAST + 1] = {};
		int32_t varSpecialSkills[SPECIALSKILL_LAST + 1] = {};
		int32_t varStats[STAT_LAST + 1] = {};
		int32_t purchaseCallback = -1;
		int32_t saleCallback = -1;
		int32_t MessageBufferCount = 0;
		int32_t premiumDays = 0;
		int32_t bloodHitCount = 0;
		int32_t shieldBlockCount = 0;
		int32_t offlineTrainingSkill = -1;
		int32_t offlineTrainingTime = 0;
		int32_t idleTime = 0;

		uint32_t instanceId = 0;

		double manaRest = 0;
		double manaRestGain = 0;
		int32_t manaGain = 0;
		uint32_t manaGainTicks = 1000;
		std::map<uint32_t, int32_t> manaGainMap;
		std::map<uint32_t, int32_t> manaGainPrecentMap;

		uint16_t lastStatsTrainingTime = 0;
		uint16_t staminaMinutes = 2520;
		uint16_t maxWriteLen = 0;
		uint16_t localPing = 0;
		uint16_t fps = 0;
		int16_t lastDepotId = -1;

		uint8_t soul = 0;
		uint8_t blessings = 0;
		uint8_t levelPercent = 0;
		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		uint16_t magLevelPercent = 0;
		#else
		uint8_t magLevelPercent = 0;
		#endif

		int16_t charStats[CHARSTAT_LAST + 1] = {};

		PlayerSex_t sex = PLAYERSEX_FEMALE;
		OperatingSystem_t operatingSystem = CLIENTOS_NONE;
		OperatingSystem_t tfcOperatingSystem = CLIENTOS_NONE;
		BlockType_t lastAttackBlockType = BLOCK_NONE;
		fightMode_t fightMode = FIGHTMODE_ATTACK;
		AccountType_t accountType = ACCOUNT_TYPE_NORMAL;

	bool chaseMode = false;
	bool secureMode = false;
	bool inMarket = false;
	#if GAME_FEATURE_MOUNTS > 0
	bool wasMounted = false;
	#endif
	bool ghostMode = false;
	bool pzLocked = false;
	bool isConnecting = false;
	bool addAttackSkillPoint = false;
	bool inventoryAbilities[CONST_SLOT_LAST + 1] = {};
	bool scheduledUpdate = false;
	std::atomic<bool> isSaving{false}; // Flag to prevent concurrent saves (death during async save)
	int8_t serverChannel = 0;		static uint32_t playerAutoID;

		void updateItemsLight(bool internal = false);
		int32_t getStepSpeed() const override {
			return std::max<int32_t>(PLAYER_MIN_SPEED, std::min<int32_t>(PLAYER_MAX_SPEED, getSpeed()));
		}
		int8_t getServerChannel() const {
			return serverChannel;
		}
		void setServerChannel(int8_t channel) {
			serverChannel = channel;
		}
		void updateBaseSpeed() {
			if (!hasFlag(PlayerFlag_SetMaxSpeed)) {
				baseSpeed = vocation->getBaseSpeed(); // + (1 * ((level / 4) - 1));
			} else {
				baseSpeed = PLAYER_MAX_SPEED;
			}
		}

		bool isPromoted() const;

		uint32_t getAttackSpeed() const;

		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		static uint16_t getPercentSkillLevel(uint64_t count, uint64_t nextLevelCount);
		#else
		static uint8_t getPercentSkillLevel(uint64_t count, uint64_t nextLevelCount);
		#endif
		static uint8_t getPercentLevel(uint64_t count, uint64_t nextLevelCount);
		double getLostPercent() const;
		uint64_t getLostExperience() const override {
			return skillLoss ? static_cast<uint64_t>(experience * getLostPercent()) : 0;
		}
		uint32_t getDamageImmunities() const override {
			return damageImmunities;
		}
		uint32_t getConditionImmunities() const override {
			return conditionImmunities;
		}
		uint32_t getConditionSuppressions() const override {
			return conditionSuppressions;
		}
		uint16_t getLookCorpse() const override;
		void getPathSearchParams(const Creature* creature, FindPathParams& fpp) const override;

		friend class Game;
		friend class Npc;
		friend class LuaScriptInterface;
		friend class Map;
		friend class Actions;
		friend class IOLoginData;
		friend class ProtocolGame;
};

#endif
