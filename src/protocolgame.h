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

#ifndef FS_PROTOCOLGAME_H_FACA2A2D1A9348B78E8FD7E8003EBB87
#define FS_PROTOCOLGAME_H_FACA2A2D1A9348B78E8FD7E8003EBB87

#include "protocol.h"
#include "chat.h"
#include "creature.h"
#include "tasks.h"

class NetworkMessage;
class Player;
class Game;
class House;
class Container;
class Tile;
class Connection;
class Quest;
class ProtocolGame;
using ProtocolGame_ptr = std::shared_ptr<ProtocolGame>;

extern Game g_game;

struct TextMessage
{
	MessageClasses type = MESSAGE_STATUS_DEFAULT;
	std::string text;
	Position position;
	uint16_t channelId;
	struct {
		int64_t value = 0;
		TextColor_t color;
	} primary, secondary;

	TextMessage() = default;
	TextMessage(MessageClasses type, std::string text) : type(type), text(std::move(text)) {}
};

#if GAME_FEATURE_QUEST_TRACKER > 0
class Mission;
#endif

class ProtocolGame final : public Protocol
{
	public:
		// static protocol information
		#if GAME_FEATURE_SERVER_SENDFIRST > 0
		enum {server_sends_first = true};
		#else
		enum {server_sends_first = false};
		#endif
		enum {protocol_identifier = 0x0A};
		#if GAME_FEATURE_PROTOCOLSEQUENCE > 0 || GAME_FEATURE_ADLER32_CHECKSUM > 0
		enum {use_checksum = true};
		#else
		enum {use_checksum = false};
		#endif
		static const char* protocol_name() {
			return "gameworld protocol";
		}

		explicit ProtocolGame(Connection_ptr connection) : Protocol(connection) {}

		#if GAME_FEATURE_SESSIONKEY > 0
		void login(const std::string& accountName, const std::string& password, std::string& characterName, std::string& token, uint32_t tokenTime, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem);
		#else
		void login(const std::string& accountName, const std::string& password, std::string& characterName, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem);
		#endif
		void logout(bool displayEffect, bool forced);

		uint16_t getVersion() const {
			return version;
		}

		static NetworkMessage playermsg;

	private:
		ProtocolGame_ptr getThis() {
			return std::static_pointer_cast<ProtocolGame>(shared_from_this());
		}
		void connect(uint32_t playerId, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem);
		void finishPlayerLogin(Player* player, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem);
		void disconnectClient(const std::string& message) const;
		void writeToOutputBuffer(const NetworkMessage& msg, bool addToCam = true);

		void release() override;

		void checkCreatureAsKnown(uint32_t id, bool& known, uint32_t& removedKnown);

		bool canSee(int32_t x, int32_t y, int32_t z) const;
		bool canSee(const Creature*) const;
		bool canSee(const Position& pos) const;

		// we have all the parse methods
		void parsePacket(NetworkMessage& msg) override;
		void onRecvFirstMessage(NetworkMessage& msg) override;
		void onConnect() override;

		void parseServerMessage(NetworkMessage& msg);

		//Parse methods
		#if GAME_FEATURE_QUEST_TRACKER > 0
		void parseTrackedQuestFlags(NetworkMessage& msg);
		#endif
		void parseAutoWalk(NetworkMessage& msg);
		void parseSetOutfit(NetworkMessage& msg);
		void parseSay(NetworkMessage& msg);
		#if CLIENT_VERSION >= 1092
		void parseWrapableItem(NetworkMessage& msg);
		#endif
		void parseLookAt(NetworkMessage& msg);
		void parseLookInBattleList(NetworkMessage& msg);
		void parseFightModes(NetworkMessage& msg);
		void parseAttack(NetworkMessage& msg);
		void parseFollow(NetworkMessage& msg);
		void parseEquipObject(NetworkMessage& msg);
		#if CLIENT_VERSION >= 1150
		void parseTeleport(NetworkMessage& msg);
		#endif

		void parseCyclopediaMonsters(NetworkMessage& msg);
		void parseCyclopediaRace(NetworkMessage& msg);
		void parseCyclopediaHouseAction(NetworkMessage& msg);
		#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
		void parseCyclopediaCharacterInfo(NetworkMessage& msg);
		#endif
		#if GAME_FEATURE_HIGHSCORES > 0
		void parseHighscores(NetworkMessage& msg);
		#endif

		#if GAME_FEATURE_HIGHSCORES > 0
		void sendHighscoresNoData();
		void sendHighscores(const std::vector<HighscoreCharacter>& characters, uint8_t categoryId, uint16_t page, uint16_t pages);
		#endif

		void parseTournamentLeaderboard(NetworkMessage& msg);

		void parseBugReport(NetworkMessage& msg);
		#if GAME_FEATURE_RULEVIOLATION > 0
		void parseRuleViolation(NetworkMessage& msg);
		#endif
		void parseDebugAssert(NetworkMessage& msg);
		void parseRuleViolationReport(NetworkMessage& msg);

		void parseThrow(NetworkMessage& msg);
		void parseUseItemEx(NetworkMessage& msg);
		void parseUseWithCreature(NetworkMessage& msg);
		void parseUseItem(NetworkMessage& msg);
		void parseCloseContainer(NetworkMessage& msg);
		void parseUpArrowContainer(NetworkMessage& msg);
		void parseUpdateContainer(NetworkMessage& msg);
		void parseTextWindow(NetworkMessage& msg);
		void parseHouseWindow(NetworkMessage& msg);
	

		void parseLookInShop(NetworkMessage& msg);
		void parsePlayerPurchase(NetworkMessage& msg);
		void parsePlayerSale(NetworkMessage& msg);
		void parseGetItems(NetworkMessage& msg);

		void parseQuestLine(NetworkMessage& msg);

		void parseInviteToParty(NetworkMessage& msg);
		void parseJoinParty(NetworkMessage& msg);
		void parseRevokePartyInvite(NetworkMessage& msg);
		void parseKickPartyMember(NetworkMessage& msg);
		void parsePassPartyLeadership(NetworkMessage& msg);
		void parseEnableSharedPartyExperience(NetworkMessage& msg);

		#if GAME_FEATURE_MOUNTS > 0
		void parseToggleMount(NetworkMessage& msg);
		#endif
		#if CLIENT_VERSION >= 960
		void parseModalWindowAnswer(NetworkMessage& msg);
		#endif

		#if GAME_FEATURE_BROWSEFIELD > 0
		void parseBrowseField(NetworkMessage& msg);
		#endif
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		void parseSeekInContainer(NetworkMessage& msg);
		#endif
		void parseSortContainer(NetworkMessage& msg);

		//VIP methods
		void parseAddVip(NetworkMessage& msg);
		void parseRemoveVip(NetworkMessage& msg);
		void parseEditVip(NetworkMessage& msg);

		void parseRotateItem(NetworkMessage& msg);

		//Channel tabs
		void parseChannelInvite(NetworkMessage& msg);
		void parseChannelExclude(NetworkMessage& msg);
		void parseOpenChannel(NetworkMessage& msg);
		void parseOpenPrivateChannel(NetworkMessage& msg);
		void parseCloseChannel(NetworkMessage& msg);
		#if GAME_FEATURE_RULEVIOLATION > 0
		void parseProcessRuleViolation(NetworkMessage& msg);
		void parseCloseRuleViolation(NetworkMessage& msg);
		#endif

		//Market
		void sendMarketOffersNoData();
		void sendMarketResponse(uint8_t code, const std::string response);
		void sendMarketOffers(const std::vector<MarketOffer>& offer, uint16_t page, uint16_t pages, uint8_t category);
		void parseMarket(NetworkMessage& msg);

		//Send functions
		void sendActiveAuras(const Creature* creature);
		void sendCreatureJump(const Creature* creature, uint16_t height, uint16_t duration);
		void sendPlayerGold(uint64_t gold);
		void sendPartyInvite(const std::string& name, const uint32_t cid);
		void sendProgressBar(const Creature* creature, const uint32_t duration, const bool ltr);
		void sendServerTime();
		#if GAME_FEATURE_INSPECTION > 0
		void sendItemInspection(uint16_t itemId, uint8_t itemCount, const Item* item, bool cyclopedia);
		#endif
		void sendChannelMessage(const std::string& author, const std::string& text, SpeakClasses type, uint16_t channel);
		#if GAME_FEATURE_CHAT_PLAYERLIST > 0
		void sendChannelEvent(uint16_t channelId, const std::string& playerName, ChannelEvent_t channelEvent);
		#endif
		void sendClosePrivate(uint16_t channelId);
		void sendCreatePrivateChannel(uint16_t channelId, const std::string& channelName);
		void sendChannelsDialog();
		void sendChannel(uint16_t channelId, const std::string& channelName, const UsersMap* channelUsers, const InvitedMap* invitedUsers);
		#if GAME_FEATURE_RULEVIOLATION > 0
		void sendRuleViolationChannel(uint16_t channelId);
		void sendRuleViolationRemove(const std::string& target);
		void sendRuleViolationCancel(const std::string& target);
		void sendRuleViolationLock();
		void sendChannelMessage(const Player* target, const std::string& text, SpeakClasses type, uint32_t time);
		#endif
		void sendOpenPrivateChannel(const std::string& receiver);
		void sendToChannel(const Creature* creature, SpeakClasses type, const std::string& text, uint16_t channelId);
		void sendPrivateMessage(const Player* speaker, SpeakClasses type, const std::string& text);
		void sendIcons(uint32_t icons);
		void sendFYIBox(const std::string& message);

		void sendDistanceShoot(const Position& from, const Position& to, uint16_t type, bool typeOb, uint16_t duration, double speed, const std::string color);
		void sendLineEffect(const Position& from, const Position& to, uint16_t type, bool bottom = true);
		void sendMagicEffect(const Position& pos, uint16_t type, uint8_t bottom = 0, const std::string color = "");
		void sendCreatureEffect(const Creature* creature, uint16_t type, uint8_t bottom = 0);
		void sendCreatureHealth(const Creature* creature, uint8_t healthPercent, uint8_t energyPercent);
		void sendCreatureEnergyShield(const Creature* creature, uint8_t shieldPercent);
		#if GAME_FEATURE_PARTY_LIST > 0
		void sendPartyCreatureUpdate(const Creature* target); 
		void sendPartyCreatureHealth(const Creature* target, uint8_t healthPercent);
		void sendPartyPlayerMana(const Player* target, uint8_t manaPercent);
		void sendPartyCreatureShowStatus(const Creature* target, bool showStatus);
		void sendPartyJoin(const Creature* target);
		void sendPartyUpdateShield(const Creature* target);
		void sendPartyLeave(const Creature* target);
		void sendPartyPlayerPos(const Creature* target, const Position pos);
		void sendPartyDisband();
		#endif
		void sendSkills();
		void sendPing();
		void sendPingBack();
		void sendCreatureTurn(const Creature* creature, uint32_t stackPos);
		void sendCreatureSay(const Creature* creature, SpeakClasses type, const std::string& text, const Position* pos = nullptr);

		void sendQuestLog();
		void sendQuestLine(const Quest* quest);
		#if GAME_FEATURE_QUEST_TRACKER > 0
		void sendTrackedQuests(uint8_t remainingQuests, std::vector<uint16_t>& quests);
		void sendUpdateTrackedQuest(const Mission* mission);
		#endif

		void sendCancelWalk();
		void sendChangeSpeed(const Creature* creature, uint32_t speed);
		void sendCancelTarget();
		void sendCreatureOutfit(const Creature* creature, const Outfit_t& outfit);
		void sendStats(uint8_t type);
		#if CLIENT_VERSION >= 950
		void sendBasicData();
		#endif
		//void sendBlessStatus();
		void sendTextMessage(const TextMessage& message);
		void sendReLoginWindow(uint8_t unfairFightReduction);

		void sendTutorial(uint8_t tutorialId);
		void sendAddMarker(const Position& pos, uint8_t markType, const std::string& desc);

		void sendMonsterCyclopedia();
		void sendCyclopediaMonsters(const std::string& race);
		void sendCyclopediaRace(uint16_t monsterId);
		void sendCyclopediaBonusEffects();

		void sendTournamentLeaderboard();

		void updateCreatureData(const Creature* creature);
		#if CLIENT_VERSION >= 854
		void sendCreatureWalkthrough(const Creature* creature, bool walkthrough);
		#endif
		void sendCreatureAttackable(const Creature* creature, bool attackable);
		void sendCreatureShield(const Creature* creature);
		void sendCreatureSkull(const Creature* creature);
		#if CLIENT_VERSION >= 910
		void sendCreatureType(const Creature* creature, uint8_t creatureType);
		#endif
		#if CLIENT_VERSION >= 1000 && CLIENT_VERSION < 1185
		void sendCreatureHelpers(uint32_t creatureId, uint16_t helpers);
		#endif

		void sendShop(Npc* npc, const ShopInfoList& itemList);
		void sendCloseShop();
		void sendSaleItemList(const std::map<uint64_t, PlayerInventorySellItem>& inventoryMap, const std::map<uint32_t, uint16_t>& stackMap, uint8_t categoryIndex = 0);
		#if GAME_FEATURE_ANALYTICS > 0
		void sendMarketStatistics();
		void sendImpactTracking(bool healing, int32_t impact);
		#if GAME_FEATURE_ANALYTICS_IMPACT_TRACKING_EXTENDED > 0
		void sendImpactTracking(CombatType_t combatType, int32_t impact, const std::string& cause);
		#endif
		void sendKillTracking(const std::string& name, const Outfit_t& outfit, const Container* container);
		#endif

		void sendTextWindow(uint32_t windowTextId, Item* item, uint16_t maxlen, bool canWrite);
		void sendTextWindow(uint32_t windowTextId, uint32_t itemId, const std::string& text);
		void sendHouseWindow(uint32_t windowTextId, const std::string& text);
		void sendOutfitWindow();

		void sendUpdatedVIPStatus(uint32_t guid, VipStatus_t newStatus);
		#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
		void sendVIP(uint32_t guid, const std::string& name, const std::string& description, uint32_t icon, bool notify, VipStatus_t status);
		#else
		void sendVIP(uint32_t guid, const std::string& name, VipStatus_t status);
		#endif
		void sendVIPEntries();
		void sendAnimatedText(const std::string& message, const Position& pos, TextColor_t color, const std::string& font);
		#if CLIENT_VERSION >= 1000
		void sendFightModes();
		#endif

		void sendCreatureLight(const Creature* creature);
		void sendWorldLight(LightInfo lightInfo);
		#if CLIENT_VERSION >= 1121
		void sendTibiaTime(int32_t time);
		#endif

		void sendCreatureSquare(const Creature* creature, SquareColor_t color);

		#if CLIENT_VERSION >= 870
		void sendSpellCooldown(uint8_t spellId, uint32_t time);
		void sendSpellGroupCooldown(SpellGroup_t groupId, uint32_t time);
		#endif

		//tiles
		void sendMapDescription(const Position& pos);

		#if GAME_FEATURE_TILE_ADDTHING_STACKPOS > 0
		void sendAddTileItem(const Position& pos, uint32_t stackpos, const Item* item);
		#else
		void sendAddTileItem(const Position& pos, const Item* item);
		#endif
		void sendUpdateTileItem(const Position& pos, uint32_t stackpos, const Item* item);
		void sendRemoveTileThing(const Position& pos, uint32_t stackpos);
		void sendUpdateTile(const Tile* tile, const Position& pos);
		void sendUpdateTileCreature(const Position& pos, uint32_t stackpos, const Creature* creature);

		void sendAddCreature(const Creature* creature, const Position& pos, int32_t stackpos, bool isLogin);
		void sendMoveCreature(const Creature* creature, const Position& newPos, int32_t newStackPos,
		                      const Position& oldPos, int32_t oldStackPos, bool teleport);

		//containers
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		void sendAddContainerItem(uint8_t cid, uint16_t slot, const Item* item);
		void sendUpdateContainerItem(uint8_t cid, uint16_t slot, const Item* item);
		void sendRemoveContainerItem(uint8_t cid, uint16_t slot, const Item* lastItem);
		void sendContainer(uint8_t cid, const Container* container, bool hasParent, uint16_t firstIndex);
		#else
		void sendAddContainerItem(uint8_t cid, const Item* item);
		void sendUpdateContainerItem(uint8_t cid, uint8_t slot, const Item* item);
		void sendRemoveContainerItem(uint8_t cid, uint8_t slot);
		void sendContainer(uint8_t cid, const Container* container, bool hasParent);
		#endif
		void sendCloseContainer(uint8_t cid);

		//inventory
		void sendInventoryItem(slots_t slot, const Item* item);
		#if GAME_FEATURE_INVENTORY_LIST > 0
		void sendItems(const std::map<uint32_t, PlayerInventorySellItem>& inventoryMap);
		#endif

		//messages
		#if CLIENT_VERSION >= 960
		void sendModalWindow(const ModalWindow& modalWindow);
		#endif

		//Help functions

		// translate a tile to clientreadable format
		void GetTileDescription(const Tile* tile);
		void sendTilesWidget(int32_t x, int32_t y, int32_t z, int32_t width, int32_t height);
		void sendTileWidget(const Tile* tile, const Position& pos);
		void sendTileRemoveWidget(const Tile* tile, const Position& pos);

		// translate a floor to clientreadable format
		void GetFloorDescription(int32_t x, int32_t y, int32_t z, int32_t width, int32_t height, int32_t offset, int32_t& skip);

		// translate a map area to clientreadable format
		void GetMapDescription(int32_t x, int32_t y, int32_t z, int32_t width, int32_t height);

		void AddCreature(const Creature* creature, bool known, uint32_t remove);
		void AddPlayerStats(uint8_t type);
		void AddOutfit(const Outfit_t& outfit);
		void AddPlayerSkills();
		void AddWorldLight(LightInfo lightInfo);
		void AddCreatureLight(const Creature* creature);

		//tiles
		void RemoveTileThing(const Position& pos, uint32_t stackpos);

		//shop
		void AddShopItem(const ShopInfo& item);

		//items
		void AddItem(uint16_t id, uint16_t count);
		void AddItem(const Item* item);

		//otclient
		void parseExtendedOpcode(NetworkMessage& msg);

		//translations
		SpeakClasses translateSpeakClassFromClient(uint8_t talkType);
		uint8_t translateSpeakClassToClient(SpeakClasses talkType);
		uint8_t translateMessageClassToClient(MessageClasses messageType);

		// CAM
		void startCamRecording();
		void stopCamRecording();
		bool isRecording();
		void sendCamRefreshPacket();
		void syncOpenContainers();
		void parseInputEvent(NetworkMessage& msg);

		void sendFloorDescription(const Position& pos, int floor);
		void parseChangeAwareRange(NetworkMessage& msg);
		void updateAwareRange(int width, int height);
		void sendAwareRange();

		void parseNewWalking(NetworkMessage& msg);
		void checkPredictiveWalking(const Position& pos);
		void sendPredictiveCancel(const Position& pos);
		void sendNewCancelWalk();

		void parseNewPing(NetworkMessage& msg);
		void sendNewPing(uint32_t pingId);


		friend class Player;

		std::unordered_set<uint32_t> knownCreatureSet;
		Player* player = nullptr;

		uint64_t eventConnect = 0;
		uint32_t challengeTimestamp = 0;
		uint16_t version = CLIENT_VERSION;

		uint8_t challengeRandom = 0;

		bool addExivaRestrictions = false;
		bool debugAssertSent = false;
		bool acceptPackets = false;

		struct AwareRange {
			int width = 17;
			int height = 13;

			int left() const { return width / 2; }
			int right() const { return 1 + width / 2; }
			int top() const { return height / 2; }
			int bottom() const { return 1 + height / 2; }
			int horizontal() const { return width + 1; }
			int vertical() const { return height + 1; }
		} awareRange;

		uint32_t camId = 0;
		bool camOnlyPackets = false;
		time_t camLastRefreshPacket = 0, camStart = 0;
};

#endif
