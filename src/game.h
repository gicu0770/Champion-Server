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

#ifndef FS_GAME_H_3EC96D67DD024E6093B3BAC29B7A6D7F
#define FS_GAME_H_3EC96D67DD024E6093B3BAC29B7A6D7F

#include <mutex>

#include "account.h"
#include "combat.h"
#include "groups.h"
#include "map.h"
#include "position.h"
#include "item.h"
#include "container.h"
#include "player.h"
#include "raids.h"
#include "npc.h"
#include "wildcardtree.h"
#include "quests.h"

class ServiceManager;
class Creature;
class Monster;
class Npc;
class CombatInfo;

enum stackPosType_t {
	STACKPOS_MOVE,
	STACKPOS_LOOK,
	STACKPOS_TOPDOWN_ITEM,
	STACKPOS_USEITEM,
	STACKPOS_USETARGET,
};

enum WorldType_t {
	WORLD_TYPE_NO_PVP = 1,
	WORLD_TYPE_PVP = 2,
	WORLD_TYPE_PVP_ENFORCED = 3,
};

enum GameState_t {
	GAME_STATE_STARTUP,
	GAME_STATE_PREINIT,
	GAME_STATE_INIT,
	GAME_STATE_NORMAL,
	GAME_STATE_CLOSED,
	GAME_STATE_SHUTDOWN,
	GAME_STATE_CLOSING,
	GAME_STATE_MAINTAIN,
};

enum LightState_t {
	LIGHT_STATE_DAY,
	LIGHT_STATE_NIGHT,
	LIGHT_STATE_SUNSET,
	LIGHT_STATE_SUNRISE,
};

static constexpr int32_t EVENT_LIGHTINTERVAL = 10000;
static constexpr int32_t EVENT_CHECK_MARKET_OFFERS = 15 * 60 * 1000;
static constexpr float MARKET_FEE = 0.05f;

#if GAME_FEATURE_RULEVIOLATION > 0
struct RuleViolation
{
	RuleViolation(Player* owner, const std::string& text, int64_t time) :
		message(text), time(time), owner(owner->getID()) {}

	// non-copyable
	RuleViolation(const RuleViolation&) = delete;
	RuleViolation& operator=(const RuleViolation&) = delete;

	// non-moveable
	RuleViolation(RuleViolation&&) = delete;
	RuleViolation& operator=(RuleViolation&&) = delete;

	std::string message;
	int64_t time;
	uint32_t owner;
	uint32_t gamemaster = 0;
};
#endif

/**
  * Main Game class.
  * This class is responsible to control everything that happens
  */

class Game
{
	public:
		Game();
		~Game();

		// non-copyable
		Game(const Game&) = delete;
		Game& operator=(const Game&) = delete;

		void start(ServiceManager* manager);

		void forceAddCondition(uint32_t creatureId, Condition* condition);
		void forceRemoveCondition(uint32_t creatureId, ConditionType_t type);
		void saveGameStateAsync(uint32_t delayBetweenPlayers = 50);

		bool loadMainMap(const std::string& filename);
		void loadMap(const std::string& path, const Position& pos = Position(), bool unload = false, bool lua = false);
		void loadDungeon(const std::string& path, const Position& pos);
		void respawnDungeon(const std::string& path, DungeonInstance* instance, const Position& pos, uint8_t players);

		/**
		  * Returns a dungeon based on its ID
		  * \param id is the dungeon id
		  * \returns A Pointer to the dungeon or nullptr if not found
		  */
		Dungeon* getDungeonById(uint8_t id);

		/**
		  * Get the map size - info purpose only
		  * \param width width of the map
		  * \param height height of the map
		  */
		void getMapDimensions(uint32_t& width, uint32_t& height) const {
			width = map.width;
			height = map.height;
		}

		void setWorldType(WorldType_t type);
		WorldType_t getWorldType() const {
			return worldType;
		}

		Cylinder* internalGetCylinder(Player* player, const Position& pos) const;
		Thing* internalGetThing(Player* player, const Position& pos, int32_t index,
		                        uint32_t spriteId, stackPosType_t type) const;
		static void internalGetPosition(Item* item, Position& pos, uint8_t& stackpos);

		/**
		  * Returns a creature based on the unique creature identifier
		  * \param id is the unique creature id to get a creature pointer to
		  * \returns A Creature pointer to the creature
		  */
		Creature* getCreatureByID(uint32_t id);

		/**
		  * Returns a monster based on the unique creature identifier
		  * \param id is the unique monster id to get a monster pointer to
		  * \returns A Monster pointer to the monster
		  */
		Monster* getMonsterByID(uint32_t id);

		/**
		  * Returns a npc based on the unique creature identifier
		  * \param id is the unique npc id to get a npc pointer to
		  * \returns A NPC pointer to the npc
		  */
		Npc* getNpcByID(uint32_t id);

		/**
		  * Returns a player based on the unique creature identifier
		  * \param id is the unique player id to get a player pointer to
		  * \returns A Pointer to the player
		  */
		Player* getPlayerByID(uint32_t id);

		/**
		  * Returns a creature based on a string name identifier
		  * \param s is the name identifier
		  * \returns A Pointer to the creature
		  */
		Creature* getCreatureByName(const std::string& s);

		/**
		  * Returns a npc based on a string name identifier
		  * \param s is the name identifier
		  * \returns A Pointer to the npc
		  */
		Npc* getNpcByName(const std::string& s);

		/**
		  * Returns a player based on a string name identifier
		  * \param s is the name identifier
		  * \returns A Pointer to the player
		  */
		Player* getPlayerByName(const std::string& s);

		/**
		  * Returns a player based on guid
		  * \returns A Pointer to the player
		  */
		Player* getPlayerByGUID(const uint32_t& guid);

		/**
		  * Returns a player based on a string name identifier, with support for the "~" wildcard.
		  * \param s is the name identifier, with or without wildcard
		  * \param player will point to the found player (if any)
		  * \return "RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE" or "RETURNVALUE_NAMEISTOOAMBIGIOUS"
		  */
		ReturnValue getPlayerByNameWildcard(const std::string& s, Player*& player);

		/**
		  * Returns a player based on an account number identifier
		  * \param acc is the account identifier
		  * \returns A Pointer to the player
		  */
	Player* getPlayerByAccount(uint32_t acc);

	/**
	  * Check if a player GUID has an active session (loading or saving)
	  * \param guid is the player GUID to check
	  * \returns true if the player is currently loading or saving
	  */
	bool hasActivePlayerSession(uint32_t guid) const;

	/**
	  * Mark a player GUID as having an active session (login/save started)
	  * \param guid is the player GUID to mark as active
	  * \returns true if successfully marked (false if already active)
	  */
	bool startPlayerSession(uint32_t guid);

	/**
	  * Remove a player GUID from active sessions (login/save completed)
	  * \param guid is the player GUID to remove from active sessions
	  */
	void stopPlayerSession(uint32_t guid);

	/**
	  * Check if an account has an active session (saving)
	  * \param accountId is the account ID to check
	  * \returns true if the account is currently saving
	  */
	bool hasActiveAccountSession(uint32_t accountId) const;

	/**
	  * Mark an account as having an active session (save started)
	  * \param accountId is the account ID to mark as active
	  * \returns true if successfully marked (false if already active)
	  */
	bool startAccountSession(uint32_t accountId);

	/**
	  * Remove an account from active sessions (save completed)
	  * \param accountId is the account ID to remove from active sessions
	  */
	void stopAccountSession(uint32_t accountId);

	/* Place Creature on the map without sending out events to the surrounding.
	  * \param creature Creature to place on the map
	  * \param pos The position to place the creature
		  * \param extendedPos If true, the creature will in first-hand be placed 2 tiles away
		  * \param forced If true, placing the creature will not fail because of obstacles (creatures/items)
		  */
		bool internalPlaceCreature(Creature* creature, const Position& pos, bool extendedPos = false, bool forced = false);

		/**
		  * Place Creature on the map.
		  * \param creature Creature to place on the map
		  * \param pos The position to place the creature
		  * \param extendedPos If true, the creature will in first-hand be placed 2 tiles away
		  * \param force If true, placing the creature will not fail because of obstacles (creatures/items)
		  */
		bool placeCreature(Creature* creature, const Position& pos, bool extendedPos = false, bool forced = false);

		/**
		  * Remove Creature from the map.
		  * Removes the Creature the map
		  * \param c Creature to remove
		  */
		bool removeCreature(Creature* creature, bool isLogout = true);

		void addCreatureCheck(Creature* creature);
		static void removeCreatureCheck(Creature* creature);

		size_t getPlayersOnline() const {
			return players.size();
		}
		size_t getMonstersOnline() const {
			return monsters.size();
		}
		size_t getNpcsOnline() const {
			return npcs.size();
		}
		uint32_t getPlayersRecord() const {
			return playersRecord;
		}

		LightInfo getWorldLightInfo() const;

		ReturnValue internalMoveCreature(Creature* creature, Direction direction, uint32_t flags = 0);
		ReturnValue internalMoveCreature(Creature& creature, Tile& toTile, uint32_t flags = 0);

		ReturnValue internalMoveItem(Cylinder* fromCylinder, Cylinder* toCylinder, int32_t index,
		                             Item* item, uint32_t count, Item** _moveItem, uint32_t flags = 0, Creature* actor = nullptr, bool checkOtherContainers = false);

		ReturnValue internalAddItem(Cylinder* toCylinder, Item* item, int32_t index = INDEX_WHEREEVER,
		                            uint32_t flags = 0, bool test = false);
		ReturnValue internalAddItem(Cylinder* toCylinder, Item* item, int32_t index,
		                            uint32_t flags, bool test, uint32_t& remainderCount);
		ReturnValue internalRemoveItem(Item* item, int32_t count = -1, bool test = false, uint32_t flags = 0);
		#if GAME_FEATURE_FASTER_CLEAN > 0
		ReturnValue internalCleanItem(Item* item, int32_t count = -1);
		#endif

		ReturnValue internalPlayerAddItem(Player* player, Item* item, bool dropOnMap = true, slots_t slot = CONST_SLOT_WHEREEVER);

		/**
		  * Find an item of a certain type
		  * \param cylinder to search the item
		  * \param itemId is the item to remove
		  * \param subType is the extra type an item can have such as charges/fluidtype, default is -1
			* meaning it's not used
		  * \param depthSearch if true it will check child containers aswell
		  * \returns A pointer to the item to an item and nullptr if not found
		  */
		Item* findItemOfType(Cylinder* cylinder, uint16_t itemId,
		                     bool depthSearch = true, int32_t subType = -1) const;

		/**
		  * Remove/Add item(s) with a monetary value
		  * \param cylinder to remove the money from
		  * \param money is the amount to remove
		  * \param flags optional flags to modifiy the default behaviour
		  * \returns true if the removal was successful
		  */
		bool removeMoney(Cylinder* cylinder, uint64_t money, uint32_t flags = 0);

		/**
		  * Add item(s) with monetary value
		  * \param cylinder which will receive money
		  * \param money the amount to give
		  * \param flags optional flags to modify default behavior
		  */
		void addMoney(Cylinder* cylinder, uint64_t money, uint32_t flags = 0);

		/**
		  * Transform one item to another type/count
		  * \param item is the item to transform
		  * \param newId is the new itemid
		  * \param newCount is the new count value, use default value (-1) to not change it
		  * \returns true if the tranformation was successful
		  */
		Item* transformItem(Item* item, uint16_t newId, int32_t newCount = -1);

		/**
		  * Teleports an object to another position
		  * \param thing is the object to teleport
		  * \param newPos is the new position
		  * \param pushMove force teleport if false
		  * \param flags optional flags to modify default behavior
		  * \returns true if the teleportation was successful
		  */
		ReturnValue internalTeleport(Thing* thing, const Position& newPos, bool pushMove = true, uint32_t flags = 0);

		/**
		  * Turn a creature to a different direction.
		  * \param creature Creature to change the direction
		  * \param dir Direction to turn to
		  */
		bool internalCreatureTurn(Creature* creature, Direction dir);

		/**
		  * Creature wants to say something.
		  * \param creature Creature pointer
		  * \param type Type of message
		  * \param text The text to say
		  */
		bool internalCreatureSay(Creature* creature, SpeakClasses type, const std::string& text,
		                         bool ghostMode, SpectatorVector* spectatorsPtr = nullptr, const Position* pos = nullptr);

		void loadPlayersRecord();
		void resetAllPlayersOnline();
		void checkPlayersRecord();

		void sendGuildMotd(uint32_t playerId);
		void kickPlayer(uint32_t playerId, bool displayEffect);
		void playerReportBug(Player* player, const std::string& message, const Position& position, uint8_t category);
		void playerDebugAssert(Player* player, const std::string& assertLine, const std::string& date, const std::string& description, const std::string& comment);
		void playerAnswerModalWindow(Player* player, uint32_t modalWindowId, uint8_t button, uint8_t choice);
		void playerReportRuleViolation(Player* player, const std::string& targetName, uint8_t reportType, uint8_t reportReason, const std::string& comment, const std::string& translation);

		void updatePlayerEvent(uint32_t playerId);
		void updatePlayerStore(Player* player, bool changeFilter = false, std::string filterName = "", uint8_t filterRarity = 0, uint8_t filterItemType = 0, uint8_t categoryIndex = 0);
		void checkCreatureDeath(uint32_t creatureId);

		void playerMonsterCyclopedia(Player* player);
		void playerCyclopediaMonsters(Player* player, const std::string& race);
		void playerCyclopediaRace(Player* player, uint16_t monsterId);
		#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
		void playerCyclopediaCharacterInfo(Player* player, uint32_t characterID, CyclopediaCharacterInfoType_t characterInfoType, uint16_t entriesPerPage, uint16_t page);
		#endif

		#if GAME_FEATURE_HIGHSCORES > 0
		void playerHighscores(Player* player, uint8_t category, std::vector<uint16_t>& vocation, const std::string& worldName, uint16_t page, uint8_t entriesPerPage, uint8_t type);
		#endif

		void playerTournamentLeaderboard(Player* player, uint8_t leaderboardType);

		bool playerBroadcastMessage(Player* player, const std::string& text) const;
		void broadcastMessage(const std::string& text, MessageClasses type) const;

		void addItemToMarket(Player* player, Item* item, uint16_t count, uint8_t itemType, uint8_t currency, double price, uint32_t marketId);
		void addMarketHistory(uint32_t player_id, uint32_t account_id, uint16_t amount, double price, const std::string name, uint8_t currency, uint32_t clientId, uint8_t rarity, uint8_t type);
		void checkForExpiredOffers();
		void checkPlayersExpiredOffers(Player* player);
		std::unordered_map<uint32_t, Item*> getMarketItems();
		Item* createItemFromBlob(const char* blob, size_t size);
		bool getItemBlobForDatabase(Item* item, const char*& outputBlob, size_t& outputSize);
		void cancelMarketOffer(Player* player, uint32_t marketId);
		void buyMarketOffer(Player* buyer, uint32_t marketId, uint32_t amount);

		//Implementation of player invoked events
		void playerMoveThing(uint32_t playerId, const Position& fromPos, uint16_t spriteId, uint8_t fromStackPos,
		                     const Position& toPos, uint16_t count);
		void playerMoveCreatureByID(uint32_t playerId, uint32_t movingCreatureId, const Position& movingCreatureOrigPos, const Position& toPos);
		void playerMoveCreature(Player* player, Creature* movingCreature, const Position& movingCreatureOrigPos, Tile* toTile);
		void playerMoveItemByPlayerID(uint32_t playerId, const Position& fromPos, uint16_t spriteId, uint8_t fromStackPos, const Position& toPos, uint16_t count, bool allowAutoWalk = true);
		void playerMoveItem(Player* player, const Position& fromPos,
		                    uint16_t spriteId, uint8_t fromStackPos, const Position& toPos, uint16_t count, Item* item, Cylinder* toCylinder, bool allowAutoWalk = true);
		void playerEquipItem(Player* player, uint64_t uid);
		#if CLIENT_VERSION >= 1150
		void playerTeleport(Player* player, const Position& position);
		#endif
		void playerMove(Player* player, Direction direction);
		void playerCreatePrivateChannel(Player* player);
		void playerChannelInvite(Player* player, const std::string& name);
		void playerChannelExclude(Player* player, const std::string& name);
		void playerRequestChannels(Player* player);
		void playerOpenChannel(Player* player, uint16_t channelId);
		void playerCloseChannel(Player* player, uint16_t channelId);
		void playerOpenPrivateChannel(Player* player, std::string& receiver);
		#if GAME_FEATURE_RULEVIOLATION > 0
		void playerRuleViolation(Player* player, const std::string& target, const std::string& comment, uint8_t reason, uint8_t action, uint32_t statementId, bool ipBanishment);
		void playerProcessRuleViolation(Player* player, const std::string& target);
		void playerCloseRuleViolation(Player* player, const std::string& target);
		void playerCancelRuleViolation(Player* player);
		void playerReportRuleViolation(Player* player, const std::string& text);
		void playerContinueReport(Player* player, const std::string& text);
		void playerCheckRuleViolation(Player* player);
		std::unordered_map<std::string, RuleViolation>& getRuleViolations() {return ruleViolations;}
		#endif
		#if GAME_FEATURE_QUEST_TRACKER > 0
		void playerResetTrackedQuests(Player* player, std::vector<uint16_t>& quests);
		#endif
		void playerCloseNpcChannel(Player* player);
		void playerReceivePing(Player* player);
		void playerReceivePingBack(Player* player);
		void playerReceiveNewPing(uint32_t playerId, uint16_t ping, uint16_t fps);
		void playerAutoWalk(uint32_t playerId, std::vector<Direction>& listDir);
		void playerStopAutoWalk(Player* player);
		void playerUseItemEx(uint32_t playerId, const Position& fromPos, uint8_t fromStackPos,
		                     uint16_t fromSpriteId, const Position& toPos, uint8_t toStackPos, uint16_t toSpriteId);
		void playerUseItem(uint32_t playerId, const Position& pos, uint8_t stackPos, uint8_t index, uint16_t spriteId);
		void playerUseWithCreature(uint32_t playerId, const Position& fromPos, uint8_t fromStackPos, uint32_t creatureId, uint16_t spriteId);
		void playerCloseContainer(Player* player, uint8_t cid);
		void playerMoveUpContainer(Player* player, uint8_t cid);
		void playerUpdateContainer(Player* player, uint8_t cid);
		void playerRotateItem(uint32_t playerId, const Position& pos, uint8_t stackPos, const uint16_t spriteId);
		#if CLIENT_VERSION >= 1092
		void playerWrapableItem(uint32_t playerId, const Position& pos, uint8_t stackPos, const uint16_t spriteId);
		#endif
		void playerWriteItem(Player* player, uint32_t windowTextId, const std::string& text);
		#if GAME_FEATURE_BROWSEFIELD > 0
		void playerBrowseField(uint32_t playerId, const Position& pos);
		#endif
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		void playerSeekInContainer(Player* player, uint8_t containerId, uint16_t index);
		#endif
		void playerSortContainer(Player* player, uint8_t containerId, uint8_t sortIndex, const std::string& name = "");
		#if GAME_FEATURE_INSPECTION > 0
		void playerInspectItem(Player* player, const Position& pos);
		void playerInspectItem(Player* player, uint16_t itemId, uint8_t itemCount, bool cyclopedia);
		#endif
		void playerUpdateHouseWindow(Player* player, uint8_t listId, uint32_t windowTextId, const std::string& text);
		void playerPurchaseItem(Player* player, uint16_t spriteId, uint8_t count, uint8_t amount,
		                        bool ignoreCap = false, bool inBackpacks = false);
		void playerSellItem(Player* player, uint16_t spriteId, uint8_t count,
		                    uint8_t amount, uint64_t realUID, bool ignoreEquipped = false);
		void playerSellItems(Player* player, std::vector<uint64_t> items);
		void playerCloseShop(Player* player);
		void playerLookInShop(Player* player, uint16_t spriteId, uint8_t count);
		void playerSetAttackedCreature(uint32_t playerId, uint32_t creatureId);
		void playerFollowCreature(uint32_t playerId, uint32_t creatureId);
		void playerCancelAttackAndFollow(uint32_t playerId);
		void playerSetFightModes(Player* player, fightMode_t fightMode, bool chaseMode, bool secureMode);
		void playerLookAt(Player* player, const Position& pos, uint8_t stackPos);
		void playerLookInBattleList(Player* player, uint32_t creatureId);
		void playerRequestAddVip(Player* player, const std::string& name);
		void playerRequestRemoveVip(Player* player, uint32_t guid);
		void playerRequestEditVip(Player* player, uint32_t guid, const std::string& description, uint32_t icon, bool notify);
		void playerTurn(Player* player, Direction dir);
		void playerRequestOutfit(Player* player);
		void playerShowQuestLog(Player* player);
		void playerShowQuestLine(Player* player, uint16_t questId);
		void playerSay(Player* player, uint16_t channelId, SpeakClasses type,
		               const std::string& receiver, const std::string& text);
		void playerChangeOutfit(Player* player, Outfit_t outfit);
		void playerInviteToParty(Player* player, uint32_t invitedId);
		void playerJoinParty(Player* player, uint32_t leaderId);
		void playerRevokePartyInvitation(Player* player, uint32_t invitedId);
		void playerPassPartyLeadership(Player* player, uint32_t newLeaderId);
		void playerKickPartyMember(Player* player, uint32_t targetId);
		void playerLeaveParty(Player* player);
		void playerEnableSharedPartyExperience(Player* player, bool sharedExpActive);
		#if GAME_FEATURE_MOUNTS > 0
		//void playerToggleMount(Player* player, bool mount);
		void playerToggleOutfitExtension(Player* player, int mount);
		#endif

		void playerExtendedOpcode(Player* player, uint8_t opcode, const std::string& buffer);

		static void updatePremium(Account& account);

		void cleanup();
		void shutdown();
		void ReleaseCreature(Creature* creature);
		void ReleaseItem(Item* item);

		bool canThrowObjectTo(const Position& fromPos, const Position& toPos, SightLines_t lineOfSight = SightLine_CheckSightLine,
		                      int32_t rangex = Map::maxClientViewportX, int32_t rangey = Map::maxClientViewportY) const;
		bool isSightClear(const Position& fromPos, const Position& toPos, bool floorCheck) const;

		void changeSpeed(Creature* creature, int32_t varSpeedDelta);
		void internalCreatureChangeOutfit(Creature* creature, const Outfit_t& outfit);
		void internalCreatureChangeVisible(Creature* creature, bool visible);
		void changeLight(const Creature* creature);
		void updateCreatureSkull(const Creature* creature);
		void updateCreatureJump(const Creature* creature, uint16_t height, uint16_t duration);
		void updateCreatureProgressBar(const Creature* creature, uint32_t duration, bool ltr);
		void updateActiveAuras(const Creature* creature);
		#if CLIENT_VERSION >= 1000 && CLIENT_VERSION < 1185
		void updatePlayerHelpers(const Player& player);
		#endif
		#if CLIENT_VERSION >= 910
		void updateCreatureType(Creature* creature);
		#endif
		#if CLIENT_VERSION >= 854
		void updateCreatureWalkthrough(const Creature* creature);
		#endif

		GameState_t getGameState() const;
		void setGameState(GameState_t newState);
		void saveGameState();

		//Events
		void checkCreatureWalk(uint32_t creatureId);
		void updateCreatureWalk(uint32_t creatureId);
		void checkCreatureAttack(uint32_t creatureId);
		void checkCreatureFeared(uint32_t creatureId);
		void checkCreatures(size_t index);
		void checkLight();

		bool combatBlockHit(CombatDamage& damage, Creature* attacker, Creature* target, bool checkDefense, bool checkArmor, bool field);

		void combatGetTypeInfo(CombatType_t combatType, Creature* target, TextColor_t& color, uint8_t& effect);

		bool combatChangeHealth(Creature* attacker, Creature* target, CombatDamage& damage);
		bool combatChangeMana(Creature* attacker, Creature* target, CombatDamage& damage);
		void setRegenerateShield(uint32_t id, bool regenerate);

		//animation help functions
		void addCreatureHealth(const Creature* target);
		static void addCreatureHealth(const SpectatorVector& spectators, const Creature* target);
		void addAnimatedText(const std::string& message, const Position& pos, TextColor_t color, const std::string& font);
		static void addAnimatedText(const SpectatorVector& spectators, const std::string& message, const Position& pos, TextColor_t color, const std::string& font);
		#if GAME_FEATURE_PARTY_LIST > 0
		void addPlayerMana(const Player* target);
		#endif
		void addMagicEffect(const Position& pos, uint16_t effect, uint8_t bottom = 0, const std::string color = "");
		static void addMagicEffect(const SpectatorVector& spectators, const Position& pos, uint16_t effect, uint8_t bottom = 0, const std::string color = "");
		void addLineEffect(const Position& fromPos, const Position& toPos, uint16_t effect, bool bottom = false);
		static void addLineEffect(const SpectatorVector& spectators, const Position& fromPos, const Position& toPos, uint16_t effect, bool bottom = false);
		void addCreatureEffect(const Creature* creature, uint16_t effect, uint8_t bottom = 0);
		static void addCreatureEffect(const SpectatorVector& spectators, const Creature* creature, uint16_t effect, uint8_t bottom = 0);
		void addDistanceEffect(const Position& fromPos, const Position& toPos, uint16_t effect, bool type, uint16_t duration = 0, double speed = 0.0, const std::string color = "");
		static void addDistanceEffect(const SpectatorVector& spectators, const Position& fromPos, const Position& toPos, uint16_t effect, bool type, uint16_t duration = 0, double speed = 0.0, const std::string color = "");

		void updateCreatureData(const Creature* creature);

		void startDecay(Item* item);
		void stopDecay(Item* item);
		void internalDecayItem(Item* item);

		int32_t getLightHour() const {
			return lightHour;
		}

		bool loadExperienceStages();
		uint64_t getExperienceStage(uint32_t level);

		void loadMotdNum();
		void saveMotdNum() const;
		const std::string& getMotdHash() const { return motdHash; }
		uint32_t getMotdNum() const { return motdNum; }
		void incrementMotdNum() { motdNum++; }

		void sendOfflineTrainingDialog(Player* player);

		const std::unordered_map<uint32_t, Player*>& getPlayers() const { return players; }
		const std::unordered_map<uint32_t, Npc*>& getNpcs() const { return npcs; }

		void addPlayer(Player* player);
		void removePlayer(Player* player);

		void addNpc(Npc* npc);
		void removeNpc(Npc* npc);

		void addMonster(Monster* monster);
		void removeMonster(Monster* monster);

		Guild* getGuild(uint32_t id) const;
		void addGuild(Guild* guild);
		void removeGuild(uint32_t guildId);

		#if GAME_FEATURE_BROWSEFIELD > 0
		void decreaseBrowseFieldRef(const Position& pos);
		std::unordered_map<Tile*, Container*> browseFields;
		#endif

		void internalRemoveItems(std::vector<Item*>& itemList, uint32_t amount, bool stackable);

		BedItem* getBedBySleeper(uint32_t guid) const;
		void setBedSleeper(BedItem* bed, uint32_t guid);
		void removeBedSleeper(uint32_t guid);

		Item* getUniqueItem(uint16_t uniqueId);
		bool addUniqueItem(uint16_t uniqueId, Item* item);
		void removeUniqueItem(uint16_t uniqueId);

		Item* getRealUniqueItem(uint64_t uniqueId);
		uint64_t addRealUniqueItem(uint64_t uniqueId, Item* item);
		void removeRealUniqueItem(uint64_t uniqueId);
		
		bool reloadCreatureScripts(bool fromLua = false, bool reload = true);
		bool reload(ReloadTypes_t reloadType);

	uint64_t nextItemUID() {
		std::lock_guard<std::recursive_mutex> lock(realUniqueItemsMutex);
		return ++lastUID;
	}

	uint32_t nextMarketId() {
			return ++lastMarketOfferId;
		}

		void loadlastUID();
		void savelastUID();

		Container* getMarketBox() {
			return marketBox;
		}

		Container* createMarketBox() {
			marketBox = new Container(14404, 30, true, true);
			return marketBox;
		}

		void marketOffers(Player* player, uint16_t page, uint8_t currency, uint8_t rarity, uint8_t category, const std::string& text, uint8_t sort, uint8_t sortud, uint8_t myOffers, const std::vector<Attribute>& attr = {});
		void creatureRegenerationHealth(uint32_t creatureId);
		void creatureRegenerationEnergyShield(uint32_t creatureId);
		void creatureRegenerationEnergyShieldForce(uint32_t creatureId);
		void playerRegenerationMana(uint32_t playerId);

		Auras auras;
		Shaders shaders;
		Outlines outlines;
		Groups groups;
		Map map;
		Mounts mounts;
		Raids raids;
		Quests quests;
		Wings wings;

		std::vector<Dungeon*> dungeons;

		/**
		  * Scan all players' items for duplicates and high amounts
		  * \param threshold minimum count to flag as suspicious (default 100)
		  * \returns number of suspicious entries found
		  */
		uint32_t scanAllPlayerItems(uint32_t threshold = 100);

	private:
		bool playerSaySpell(Player* player, SpeakClasses type, const std::string& text);
		void playerWhisper(Player* player, const std::string& text);
		bool playerYell(Player* player, const std::string& text);
		bool playerSpeakTo(Player* player, SpeakClasses type, const std::string& receiver, const std::string& text);
		void playerSpeakToNpc(Player* player, const std::string& text);

		#if GAME_FEATURE_RULEVIOLATION > 0
		std::unordered_map<std::string, RuleViolation> ruleViolations;
		#endif
		std::unordered_map<uint32_t, Player*> players;
		std::unordered_map<std::string, Player*> mappedPlayerNames;
		std::unordered_map<uint32_t, Npc*> npcs;
		std::unordered_map<uint32_t, Monster*> monsters;
		std::unordered_map<uint32_t, Guild*> guilds;
		std::unordered_map<uint16_t, Item*> uniqueItems;
	std::unordered_map<uint64_t, Item*> realUniqueItems;
	mutable std::recursive_mutex realUniqueItemsMutex;
	bool shuttingDown = false;
	std::map<uint32_t, uint32_t> stages;

	std::unordered_set<uint32_t> activePlayerSessions;
	mutable std::mutex activePlayerSessionsMutex;

	std::unordered_set<uint32_t> activeAccountSessions;
	mutable std::mutex activeAccountSessionsMutex;

	std::vector<Creature*> checkCreatureLists[EVENT_CREATURECOUNT];
		std::vector<Creature*> ToReleaseCreatures;
		std::vector<Item*> ToReleaseItems;

		size_t lastBucket = 0;

		WildcardTreeNode wildcardTree { false };

		std::map<uint32_t, BedItem*> bedSleepersMap;

		ModalWindow offlineTrainingWindow { std::numeric_limits<uint32_t>::max(), "Choose a Skill", "Please choose a skill:" };

		static constexpr int32_t LIGHT_LEVEL_DAY = 250;
		static constexpr int32_t LIGHT_LEVEL_NIGHT = 40;
		static constexpr int32_t SUNSET = 1305;
		static constexpr int32_t SUNRISE = 430;

		GameState_t gameState = GAME_STATE_NORMAL;
		WorldType_t worldType = WORLD_TYPE_PVP;

		LightState_t lightState = LIGHT_STATE_DAY;
		uint8_t lightLevel = LIGHT_LEVEL_DAY;
		int32_t lightHour = SUNRISE + (SUNSET - SUNRISE) / 2;
		// (1440 minutes/day)/(3600 seconds/day)*10 seconds event interval
		int32_t lightHourDelta = 1400 * 10 / 3600;

		ServiceManager* serviceManager = nullptr;

		void updatePlayersRecord() const;
		uint32_t playersRecord = 0;

		std::string motdHash;
		uint32_t motdNum = 0;

		uint32_t lastStageLevel = 0;
		bool stagesEnabled = false;
		bool useLastStageLevel = false;
		uint64_t lastUID = 0;
		uint32_t lastMarketOfferId = 0;

		Container* marketBox = nullptr;
};

#endif
