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

#include "otpch.h"

#include <cmath>
#include <sstream>
#include <iomanip>
#include <fstream>

#include "pugicast.h"
#include "decay.h"
#include "ban.h"

#include "modules.h"
#include "stats.h"
#include "actions.h"
#include "bed.h"
#include "configmanager.h"
#include "creature.h"
#include "creatureevent.h"
#include "databasetasks.h"
#include "events.h"
#include "game.h"
#include "globalevent.h"
#include "iologindata.h"
#include "databasemanager.h"
#include "items.h"
#include "monster.h"
#include "movement.h"
#include "server.h"
#include "spells.h"
#include "talkaction.h"
#include "weapons.h"
#include "script.h"
#include "cams.h"
#include "instancemanager.h"

#include <malloc.h>

extern ConfigManager g_config;
extern Modules g_modules;
extern Actions* g_actions;
extern Chat* g_chat;
extern TalkActions* g_talkActions;
extern Spells* g_spells;
extern Vocations g_vocations;
extern GlobalEvents* g_globalEvents;
extern CreatureEvents* g_creatureEvents;
extern Events* g_events;
extern Monsters g_monsters;
extern MoveEvents* g_moveEvents;
extern Weapons* g_weapons;
extern Scripts* g_scripts;
extern InstanceManager* g_instanceManager;

Game::Game()
{
	offlineTrainingWindow.defaultEnterButton = 1;
	offlineTrainingWindow.defaultEscapeButton = 0;
	offlineTrainingWindow.choices.emplace_back("Melee Fighting and Shielding", SKILL_MELEE);
	offlineTrainingWindow.choices.emplace_back("Distance Fighting and Shielding", SKILL_DISTANCE);
	offlineTrainingWindow.choices.emplace_back("Magic Power and Shielding", SKILL_FISHING);
	offlineTrainingWindow.choices.emplace_back("Mastery and Shielding", SKILL_MAGLEVEL);
	offlineTrainingWindow.choices.shrink_to_fit();
	offlineTrainingWindow.buttons.emplace_back("Okay", offlineTrainingWindow.defaultEnterButton);
	offlineTrainingWindow.buttons.emplace_back("Cancel", offlineTrainingWindow.defaultEscapeButton);
	offlineTrainingWindow.buttons.shrink_to_fit();
	offlineTrainingWindow.priority = true;
}

Game::~Game()
{
	shuttingDown = true;
	
	for (const auto& it : guilds) {
		delete it.second;
	}

	realUniqueItems.clear();
}

void Game::start(ServiceManager* manager)
{
	serviceManager = manager;

	g_dispatcher.addEvent(EVENT_LIGHTINTERVAL, std::bind(&Game::checkLight, this));
	g_dispatcher.addEvent(EVENT_CREATURE_THINK_INTERVAL, std::bind(&Game::checkCreatures, this, 0));
	g_dispatcher.addEvent(EVENT_CHECK_MARKET_OFFERS, std::bind(&Game::checkForExpiredOffers, this));
}

GameState_t Game::getGameState() const
{
	return gameState;
}

void Game::setWorldType(WorldType_t type)
{
	worldType = type;
}

void Game::setGameState(GameState_t newState)
{
	if (gameState == GAME_STATE_SHUTDOWN) {
		return;    //this cannot be stopped
	}

	if (gameState == newState) {
		return;
	}

	gameState = newState;
	switch (newState) {
		case GAME_STATE_PREINIT: {
			//loadlastUID();
			break;
		}

		case GAME_STATE_INIT: {
			loadExperienceStages();

			groups.load();
			g_chat->load();

			map.spawns.startup();

			raids.loadFromXml();
			raids.startup();

			quests.loadFromXml();
			#if GAME_FEATURE_MOUNTS > 0
			mounts.loadFromXml();
			#endif
			auras.loadFromXml();
			wings.loadFromXml();
			shaders.loadFromXml();
			outlines.loadFromXml();

			size_t maxPlayers = static_cast<size_t>(g_config.getNumber(ConfigManager::MAX_PLAYERS));
			if (maxPlayers > 0) {
				players.reserve(maxPlayers);
				mappedPlayerNames.reserve(maxPlayers);
			}

			loadMotdNum();
			loadPlayersRecord();
			resetAllPlayersOnline();
			DBResult_ptr result = g_database.storeQuery("SELECT MAX(id) FROM market_offers");
			if (result) {
				lastMarketOfferId = result->getNumber<uint32_t>("MAX(id)");
			}

			g_globalEvents->startup();
			break;
		}

		case GAME_STATE_SHUTDOWN: {
			g_globalEvents->execute(GLOBALEVENT_SHUTDOWN);

			//kick all players that are still online
			auto it = players.begin();
			while (it != players.end()) {
				it->second->kickPlayer(true);
				it = players.begin();
			}


			saveMotdNum();
			saveGameState();

			g_dispatcher.addTask(std::bind(&Game::shutdown, this));
			g_cams.stop();
			g_databaseTasks.stop();
			g_dispatcher.stop();
			#ifdef STATS_ENABLED
				g_stats.stop();
			#endif
			break;
		}

		case GAME_STATE_CLOSED: {
			/* kick all players without the CanAlwaysLogin flag */
			auto it = players.begin();
			while (it != players.end()) {
				if (!it->second->hasFlag(PlayerFlag_CanAlwaysLogin)) {
					it->second->kickPlayer(true);
					it = players.begin();
				} else {
					++it;
				}
			}

			saveGameState();
			break;
		}

		default:
			break;
	}
}

void Game::saveGameState()
{
	if (gameState == GAME_STATE_NORMAL) {
		setGameState(GAME_STATE_MAINTAIN);
	}

	std::cout << "Saving server..." << std::endl;

	for (const auto& it : players) {
		it.second->loginPosition = it.second->getPosition();
		IOLoginData::savePlayer(it.second, false);
	}

	Map::save();

	g_databaseTasks.flush();

	if (gameState == GAME_STATE_MAINTAIN) {
		setGameState(GAME_STATE_NORMAL);
	}

	malloc_trim(0);
}

void Game::saveGameStateAsync(uint32_t delayBetweenPlayers)
{
	std::cout << "Saving server (async batched)..." << std::endl;
	
	// Collect player GUIDs first (don't hold player pointers across async calls)
	std::vector<uint32_t> playerGuids;
	for (const auto& it : players) {
		it.second->loginPosition = it.second->getPosition();
		playerGuids.push_back(it.second->getGUID());
	}
	
	// Save map immediately (this is typically fast)
	Map::save();
	
	// Schedule player saves with delays between each
	uint32_t delay = 0;
	for (uint32_t guid : playerGuids) {
		g_dispatcher.addEvent(delay, [guid]() {
			Player* player = g_game.getPlayerByGUID(guid);
			if (player && !player->isRemoved()) {
				IOLoginData::savePlayer(player, false);
			}
		});
		delay += delayBetweenPlayers;
	}
	
	// Schedule database flush after all saves complete
	g_dispatcher.addEvent(delay + 100, []() {
		g_databaseTasks.flush();
		std::cout << "Server save complete." << std::endl;
	});
}

bool Game::loadMainMap(const std::string& filename)
{
	Monster::despawnRange = g_config.getNumber(ConfigManager::DEFAULT_DESPAWNRANGE);
	Monster::despawnRadius = g_config.getNumber(ConfigManager::DEFAULT_DESPAWNRADIUS);
	for (int8_t i = 0; i < MAP_CHANNELS; ++i) {
		map.loadMap("data/world/" + filename + ".otbm", true, Position(0, 0, 16*i), false, false, i);
	}

	map.setLoaded();
	return true;
}

void Game::loadMap(const std::string& path, const Position& pos, bool unload, bool lua)
{
	map.loadMap(path, false, pos, unload, lua);
}

void Game::loadDungeon(const std::string& path, const Position& pos)
{
	map.loadDungeon(path, pos);
}

void Game::respawnDungeon(const std::string& path, DungeonInstance* instance, const Position& pos, uint8_t players)
{
	map.respawnDungeon(path, instance, pos, players);
}

Cylinder* Game::internalGetCylinder(Player* player, const Position& pos) const
{
	if (pos.x != 0xFFFF) {
		return map.getTile(pos);
	}

	//container
	if (pos.y & 0x40) {
		uint8_t from_cid = pos.y & 0x0F;
		return player->getContainerByID(from_cid);
	}

	//inventory
	return player;
}

Thing* Game::internalGetThing(Player* player, const Position& pos, int32_t index, uint32_t spriteId, stackPosType_t type) const
{
	if (pos.x != 0xFFFF) {
		Tile* tile = map.getTile(pos);
		if (!tile) {
			return nullptr;
		}

		Thing* thing;
		switch (type) {
			case STACKPOS_LOOK: {
				return tile->getTopVisibleThing(player);
			}

			case STACKPOS_MOVE: {
				Item* item = tile->getTopDownItem();
				if (item && item->isMoveable()) {
					thing = item;
				} else {
					thing = tile->getTopVisibleCreature(player);
				}
				break;
			}

			case STACKPOS_USEITEM: {
				thing = tile->getUseItem(index);
				break;
			}

			case STACKPOS_TOPDOWN_ITEM: {
				thing = tile->getTopDownItem();
				break;
			}

			case STACKPOS_USETARGET: {
				thing = tile->getTopVisibleCreature(player);
				if (!thing) {
					thing = tile->getUseItem(index);
				}
				break;
			}

			default: {
				thing = nullptr;
				break;
			}
		}

		if (player && tile->hasFlag(TILESTATE_SUPPORTS_HANGABLE)) {
			//do extra checks here if the thing is accessable
			if (thing && thing->getItem()) {
				if (tile->hasProperty(CONST_PROP_ISVERTICAL)) {
					if (player->getPosition().x + 1 == tile->getPosition().x) {
						thing = nullptr;
					}
				} else { // horizontal
					if (player->getPosition().y + 1 == tile->getPosition().y) {
						thing = nullptr;
					}
				}
			}
		}
		return thing;
	}

	//container
	if (pos.y & 0x40) {
		uint8_t fromCid = pos.y & 0x0F;

		Container* parentContainer = player->getContainerByID(fromCid);
		if (!parentContainer) {
			return nullptr;
		}

		#if GAME_FEATURE_BROWSEFIELD > 0
		if (parentContainer->getID() == ITEM_BROWSEFIELD) {
			Tile* tile = parentContainer->getTile();
			if (tile && tile->hasFlag(TILESTATE_SUPPORTS_HANGABLE)) {
				if (tile->hasProperty(CONST_PROP_ISVERTICAL)) {
					if (player->getPosition().x + 1 == tile->getPosition().x) {
						return nullptr;
					}
				} else { // horizontal
					if (player->getPosition().y + 1 == tile->getPosition().y) {
						return nullptr;
					}
				}
			}
		}
		#endif

		uint8_t slot = pos.z;
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		return parentContainer->getItemByIndex(player->getContainerIndex(fromCid) + slot);
		#else
		return parentContainer->getItemByIndex(slot);
		#endif
	} else if (pos.y == 0 && pos.z == 0) {
		const ItemType& it = Item::items.getItemIdByClientId(spriteId);
		if (it.id == 0) {
			return nullptr;
		}

		int32_t subType;
		if (it.isFluidContainer()) {
			subType = clientFluidToServer(index);
		} else {
			subType = -1;
		}

		return findItemOfType(player, it.id, true, subType);
	}

	//inventory
	slots_t slot = static_cast<slots_t>(pos.y);
	return player->getInventoryItem(slot);
}

void Game::internalGetPosition(Item* item, Position& pos, uint8_t& stackpos)
{
	pos.x = 0;
	pos.y = 0;
	pos.z = 0;
	stackpos = 0;

	Cylinder* topParent = item->getTopParent();
	if (topParent) {
		if (Player* player = dynamic_cast<Player*>(topParent)) {
			pos.x = 0xFFFF;

			Container* container = dynamic_cast<Container*>(item->getParent());
			if (container) {
				pos.y = static_cast<uint16_t>(0x40) | static_cast<uint16_t>(player->getContainerID(container));
				pos.z = container->getThingIndex(item);
				stackpos = pos.z;
			} else {
				pos.y = player->getThingIndex(item);
				stackpos = pos.y;
			}
		} else if (Tile* tile = topParent->getTile()) {
			pos = tile->getPosition();
			stackpos = tile->getThingIndex(item);
		}
	}
}

Creature* Game::getCreatureByID(uint32_t id)
{
	if (id <= Player::playerAutoID) {
		return getPlayerByID(id);
	} else if (id <= Monster::monsterAutoID) {
		return getMonsterByID(id);
	} else if (id <= Npc::npcAutoID) {
		return getNpcByID(id);
	}
	return nullptr;
}

Monster* Game::getMonsterByID(uint32_t id)
{
	if (id == 0) {
		return nullptr;
	}

	auto it = monsters.find(id);
	if (it == monsters.end()) {
		return nullptr;
	}
	return it->second;
}

Npc* Game::getNpcByID(uint32_t id)
{
	if (id == 0) {
		return nullptr;
	}

	auto it = npcs.find(id);
	if (it == npcs.end()) {
		return nullptr;
	}
	return it->second;
}

Player* Game::getPlayerByID(uint32_t id)
{
	if (id == 0) {
		return nullptr;
	}

	auto it = players.find(id);
	if (it == players.end()) {
		return nullptr;
	}
	return it->second;
}

Creature* Game::getCreatureByName(const std::string& s)
{
	if (s.empty()) {
		return nullptr;
	}

	const std::string& lowerCaseName = asLowerCaseString(s);

	auto m_it = mappedPlayerNames.find(lowerCaseName);
	if (m_it != mappedPlayerNames.end()) {
		return m_it->second;
	}

	const size_t lowerCaseName_len = lowerCaseName.length();
	const char* lowerCaseName_cstr = lowerCaseName.c_str();

	for (const auto& it : npcs) {
		const std::string& npcName = it.second->getName();
		if (lowerCaseName_len == npcName.length() && !tfs_strncmp(lowerCaseName_cstr, asLowerCaseString(npcName).c_str(), lowerCaseName_len)) {
			return it.second;
		}
	}

	for (const auto& it : monsters) {
		const std::string& monsterName = it.second->getName();
		if (lowerCaseName_len == monsterName.length() && !tfs_strncmp(lowerCaseName_cstr, asLowerCaseString(monsterName).c_str(), lowerCaseName_len)) {
			return it.second;
		}
	}
	return nullptr;
}

Npc* Game::getNpcByName(const std::string& s)
{
	if (s.empty()) {
		return nullptr;
	}

	const std::string& lowerCaseName = asLowerCaseString(s);
	const size_t lowerCaseName_len = lowerCaseName.length();
	const char* lowerCaseName_cstr = lowerCaseName.c_str();
	for (const auto& it : npcs) {
		const std::string& npcName = it.second->getName();
		if (lowerCaseName_len == npcName.length() && !tfs_strncmp(lowerCaseName_cstr, asLowerCaseString(npcName).c_str(), lowerCaseName_len)) {
			return it.second;
		}
	}
	return nullptr;
}

Player* Game::getPlayerByName(const std::string& s)
{
	if (s.empty()) {
		return nullptr;
	}

	auto it = mappedPlayerNames.find(asLowerCaseString(s));
	if (it == mappedPlayerNames.end()) {
		return nullptr;
	}
	return it->second;
}

Player* Game::getPlayerByGUID(const uint32_t& guid)
{
	if (guid == 0) {
		return nullptr;
	}

	for (const auto& it : players) {
		if (guid == it.second->getGUID()) {
			return it.second;
		}
	}
	return nullptr;
}

Dungeon* Game::getDungeonById(uint8_t id)
{
	if (id == 0) {
		return nullptr;
	}

	for (Dungeon* dungeon : dungeons) {
		if (dungeon && dungeon->getId() == id) {
			return dungeon;
		}
	}
	return nullptr;
}

ReturnValue Game::getPlayerByNameWildcard(const std::string& s, Player*& player)
{
	size_t strlen = s.length();
	if (strlen == 0 || strlen > NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		return RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE;
	}

	if (s.back() == '~') {
		const std::string& query = asLowerCaseString(s.substr(0, strlen - 1));
		std::string result;
		ReturnValue ret = wildcardTree.findOne(query, result);
		if (ret != RETURNVALUE_NOERROR) {
			return ret;
		}

		player = getPlayerByName(result);
	} else {
		player = getPlayerByName(s);
	}

	if (!player) {
		return RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE;
	}

	return RETURNVALUE_NOERROR;
}

Player* Game::getPlayerByAccount(uint32_t acc)
{
	for (const auto& it : players) {
		if (it.second->getAccount() == acc) {
			return it.second;
		}
	}
	return nullptr;
}

bool Game::hasActivePlayerSession(uint32_t guid) const
{
	std::lock_guard<std::mutex> lock(activePlayerSessionsMutex);
	return activePlayerSessions.find(guid) != activePlayerSessions.end();
}

bool Game::startPlayerSession(uint32_t guid)
{
	std::lock_guard<std::mutex> lock(activePlayerSessionsMutex);
	return activePlayerSessions.insert(guid).second;
}

void Game::stopPlayerSession(uint32_t guid)
{
	std::lock_guard<std::mutex> lock(activePlayerSessionsMutex);
	activePlayerSessions.erase(guid);
}

bool Game::hasActiveAccountSession(uint32_t accountId) const
{
	std::lock_guard<std::mutex> lock(activeAccountSessionsMutex);
	return activeAccountSessions.find(accountId) != activeAccountSessions.end();
}

bool Game::startAccountSession(uint32_t accountId)
{
	std::lock_guard<std::mutex> lock(activeAccountSessionsMutex);
	return activeAccountSessions.insert(accountId).second;
}

void Game::stopAccountSession(uint32_t accountId)
{
	std::lock_guard<std::mutex> lock(activeAccountSessionsMutex);
	activeAccountSessions.erase(accountId);
}

bool Game::internalPlaceCreature(Creature* creature, const Position& pos, bool extendedPos /*=false*/, bool forced /*= false*/)
{
	if (creature->getParent() != nullptr) {
		return false;
	}

	if (!map.placeCreature(pos, creature, extendedPos, forced)) {
		return false;
	}
	creature->incrementReferenceCounter();
	creature->setID();
	creature->addList();
	#if GAME_FEATURE_NEWSPEED_LAW > 0
	creature->cacheSpeed();
	#endif
	return true;
}

bool Game::placeCreature(Creature* creature, const Position& pos, bool extendedPos /*=false*/, bool forced /*= false*/)
{
	if (!internalPlaceCreature(creature, pos, extendedPos, forced)) {
		return false;
	}

	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true);
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendCreatureAppear(creature, creature->getPosition(), true);
		}
	}

	for (Creature* spectator : spectators) {
		spectator->onCreatureAppear(creature, true);
	}

	creature->getParent()->postAddNotification(creature, nullptr, 0);

	addCreatureCheck(creature);
	if (Player* player = creature->getPlayer()) {
		creatureRegenerationHealth(creature->getID());
		creatureRegenerationEnergyShield(creature->getID());
		creatureRegenerationEnergyShieldForce(creature->getID());
		playerRegenerationMana(player->getID());
	}

	creature->onPlacedCreature();
	return true;
}

bool Game::removeCreature(Creature* creature, bool isLogout/* = true*/)
{
	if (!creature || creature->isRemoved()) {
		return false;
	}

	Tile* tile = creature->getTile();
	if (!tile) {
		if (creature->getMaster() && !creature->getMaster()->isRemoved()) {
			creature->setMaster(nullptr);
		}

		creature->removeList();
		creature->setRemoved();
		ReleaseCreature(creature);

		removeCreatureCheck(creature);

		for (Creature* summon : creature->summons) {
			summon->setSkillLoss(false);
			removeCreature(summon);
		}
		return true;
	}

	const Position& tilePosition = tile->getPosition();

	SpectatorVector spectators;
	map.getSpectators(spectators, tile->getPosition(), true);

	std::vector<int32_t> oldStackPosVector(spectators.size());
	size_t i = static_cast<size_t>(-1); //Start index at -1 to avoid copying it
	for (Creature* spectator : spectators) {
		if (Player* player = spectator->getPlayer()) {
			if (player->canSeeCreature(creature)) {
				oldStackPosVector[++i] = (player->canSeeCreature(creature) ? tile->getStackposOfCreature(player, creature) : -1);
			}
		}
	}

	tile->removeCreature(creature);

	//send to client + event method
	i = static_cast<size_t>(-1); //Start index at -1 to avoid copying it
	for (Creature* spectator : spectators) {
		if (Player* player = spectator->getPlayer()) {
			player->sendRemoveTileThing(tilePosition, oldStackPosVector[++i]);
		}

		spectator->onRemoveCreature(creature, isLogout);
	}

	if (creature->getMaster() && !creature->getMaster()->isRemoved()) {
		creature->setMaster(nullptr);
	}

	creature->getParent()->postRemoveNotification(creature, nullptr, 0);

	creature->removeList();
	creature->setRemoved();
	ReleaseCreature(creature);

	removeCreatureCheck(creature);

	for (Creature* summon : creature->summons) {
		summon->setSkillLoss(false);
		removeCreature(summon);
	}
	return true;
}

void Game::playerMoveThing(uint32_t playerId, const Position& fromPos,
                           uint16_t spriteId, uint8_t fromStackPos, const Position& toPos, uint16_t count)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	uint8_t fromIndex = 0;
	if (fromPos.x == 0xFFFF) {
		if (fromPos.y & 0x40) {
			fromIndex = fromPos.z;
		} else {
			fromIndex = static_cast<uint8_t>(fromPos.y);
		}
	} else {
		fromIndex = fromStackPos;
	}

	Thing* thing = internalGetThing(player, fromPos, fromIndex, 0, STACKPOS_MOVE);
	if (!thing) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	if (Creature* movingCreature = thing->getCreature()) {
		Tile* tile = map.getTile(toPos);
		if (!tile) {
			player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
			return;
		}

		if (Position::areInRange<1, 1, 0>(movingCreature->getPosition(), player->getPosition())) {
			player->setNextActionTask(1000, std::bind(&Game::playerMoveCreatureByID, this, player->getID(), movingCreature->getID(), movingCreature->getPosition(), tile->getPosition()));
		} else {
			playerMoveCreature(player, movingCreature, movingCreature->getPosition(), tile);
		}
	} else if (thing->getItem()) {
		Cylinder* toCylinder = internalGetCylinder(player, toPos);
		if (!toCylinder) {
			player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
			return;
		}

		playerMoveItem(player, fromPos, spriteId, fromStackPos, toPos, count, thing->getItem(), toCylinder);
	}
}

void Game::playerMoveCreatureByID(uint32_t playerId, uint32_t movingCreatureId, const Position& movingCreatureOrigPos, const Position& toPos)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	Creature* movingCreature = getCreatureByID(movingCreatureId);
	if (!movingCreature) {
		return;
	}

	Tile* toTile = map.getTile(toPos);
	if (!toTile) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	playerMoveCreature(player, movingCreature, movingCreatureOrigPos, toTile);
}

void Game::playerMoveCreature(Player* player, Creature* movingCreature, const Position& movingCreatureOrigPos, Tile* toTile)
{
	if (!player->canDoAction()) {
		uint32_t delay = player->getNextActionTime();
		player->setNextActionTask(delay, std::bind(&Game::playerMoveCreatureByID, this, player->getID(), movingCreature->getID(), movingCreatureOrigPos, toTile->getPosition()));
		return;
	}

	player->stopNextActionTask();

	if (!Position::areInRange<1, 1, 0>(movingCreatureOrigPos, player->getPosition())) {
		//need to walk to the creature first before moving it
		std::vector<Direction> listDir;
		if (player->getPathTo(movingCreatureOrigPos, listDir, 0, 1, true, false)) {
			g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
			player->setNextWalkActionTask(1500, std::bind(&Game::playerMoveCreatureByID, this, player->getID(), movingCreature->getID(), movingCreatureOrigPos, toTile->getPosition()));
		} else {
			player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
		}
		return;
	}

	if ((!movingCreature->isPushable() && !player->hasFlag(PlayerFlag_CanPushAllCreatures)) ||
	        (movingCreature->isInGhostMode() && !player->isAccessPlayer())) {
		player->sendCancelMessage(RETURNVALUE_NOTMOVEABLE);
		return;
	}

	//check throw distance
	const Position& movingCreaturePos = movingCreature->getPosition();
	const Position& toPos = toTile->getPosition();
	
	int32_t throwRange = movingCreature->getThrowRange();
	if (Position::getDistanceX(movingCreaturePos, toPos) > throwRange || Position::getDistanceY(movingCreaturePos, toPos) > throwRange ||
			Position::getDistanceZ(movingCreaturePos, toPos) > 0) {
		player->sendCancelMessage(RETURNVALUE_DESTINATIONOUTOFREACH);
		return;
	}

	if (player != movingCreature) {
		if (toTile->hasFlag(TILESTATE_BLOCKPATH)) {
			player->sendCancelMessage(RETURNVALUE_NOTENOUGHROOM);
			return;
		} else if ((movingCreature->getZone() == ZONE_PROTECTION && !toTile->hasFlag(TILESTATE_PROTECTIONZONE)) || (movingCreature->getZone() == ZONE_NOPVP && !toTile->hasFlag(TILESTATE_NOPVPZONE))) {
			player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
			return;
		} else {
			if (CreatureVector* tileCreatures = toTile->getCreatures()) {
				for (Creature* tileCreature : *tileCreatures) {
					if (!tileCreature->isInGhostMode()) {
						player->sendCancelMessage(RETURNVALUE_NOTENOUGHROOM);
						return;
					}
				}
			}

			Npc* movingNpc = movingCreature->getNpc();
			if (movingNpc && !Spawns::isInZone(movingNpc->getMasterPos(), movingNpc->getMasterRadius(), toPos)) {
				player->sendCancelMessage(RETURNVALUE_NOTENOUGHROOM);
				return;
			}
		}
	}

	if (!g_events->eventPlayerOnMoveCreature(player, movingCreature, movingCreaturePos, toPos)) {
		return;
	}

	ReturnValue ret = internalMoveCreature(*movingCreature, *toTile);
	if (ret != RETURNVALUE_NOERROR) {
		player->sendCancelMessage(ret);
	}
}

ReturnValue Game::internalMoveCreature(Creature* creature, Direction direction, uint32_t flags /*= 0*/)
{
	creature->setLastPosition(creature->getPosition());
	const Position& currentPos = creature->getPosition();
	Position destPos = getNextPosition(direction, currentPos);
	Player* player = creature->getPlayer();

	if (player) {
		g_events->eventPlayerOnWalk(player, currentPos, destPos);
	}

	if (creature->isInPlace()) {
		return RETURNVALUE_NOTPOSSIBLE;
	}
	
	if (creature->hasCondition(CONDITION_STUN) || creature->hasCondition(CONDITION_ROOT)) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (creature->hasFear() && flags != FLAG_FEARED) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	bool diagonalMovement = (direction & DIRECTION_DIAGONAL_MASK) != 0;
	if (player && !diagonalMovement) {
		//try go up
		if (currentPos.z != 8 && creature->getTile()->hasHeight(3)) {
			Tile* tmpTile = map.getTile(currentPos.x, currentPos.y, currentPos.getZ() - 1);
			if (tmpTile == nullptr || (tmpTile->getGround() == nullptr && !tmpTile->hasFlag(TILESTATE_BLOCKSOLID))) {
				tmpTile = map.getTile(destPos.x, destPos.y, destPos.getZ() - 1);
				if (tmpTile && tmpTile->getGround() && !tmpTile->hasFlag(TILESTATE_BLOCKSOLID)) {
					flags |= FLAG_IGNOREBLOCKITEM | FLAG_IGNOREBLOCKCREATURE;

					if (!tmpTile->hasFlag(TILESTATE_FLOORCHANGE)) {
						player->setDirection(direction);
						destPos.z--;
					}
				}
			}
		}

		//try go down
		if (currentPos.z != 7 && currentPos.z == destPos.z) {
			Tile* tmpTile = map.getTile(destPos.x, destPos.y, destPos.z);
			if (tmpTile == nullptr || (tmpTile->getGround() == nullptr && !tmpTile->hasFlag(TILESTATE_BLOCKSOLID))) {
				tmpTile = map.getTile(destPos.x, destPos.y, destPos.z + 1);
				if (tmpTile && tmpTile->hasHeight(3)) {
					flags |= FLAG_IGNOREBLOCKITEM | FLAG_IGNOREBLOCKCREATURE;
					player->setDirection(direction);
					destPos.z++;
				}
			}
		}
	}

	Tile* toTile = map.getTile(destPos);
	if (!toTile) {
		return RETURNVALUE_NOTPOSSIBLE;
	}
	return internalMoveCreature(*creature, *toTile, flags);
}

ReturnValue Game::internalMoveCreature(Creature& creature, Tile& toTile, uint32_t flags /*= 0*/)
{
	//check if we can move the creature to the destination
	ReturnValue ret = toTile.queryAdd(0, creature, 1, flags);
	if (ret != RETURNVALUE_NOERROR) {
		return ret;
	}

	map.moveCreature(creature, toTile);
	if (creature.getParent() != &toTile) {
		return RETURNVALUE_NOERROR;
	}

	int32_t index = 0;
	Item* toItem = nullptr;
	Tile* subCylinder = nullptr;
	Tile* toCylinder = &toTile;
	Tile* fromCylinder = nullptr;
	uint32_t n = 0;

	while ((subCylinder = toCylinder->queryDestination(index, creature, &toItem, flags)) != toCylinder) {
		map.moveCreature(creature, *subCylinder);

		if (creature.getParent() != subCylinder) {
			//could happen if a script move the creature
			fromCylinder = nullptr;
			break;
		}

		fromCylinder = toCylinder;
		toCylinder = subCylinder;
		flags = 0;

		//to prevent infinite loop
		if (++n >= MAP_MAX_LAYERS) {
			break;
		}
	}

	if (fromCylinder) {
		const Position& fromPosition = fromCylinder->getPosition();
		const Position& toPosition = toCylinder->getPosition();
		if (fromPosition.z != toPosition.z && (fromPosition.x != toPosition.x || fromPosition.y != toPosition.y)) {
			Direction dir = getDirectionTo(fromPosition, toPosition);
			if ((dir & DIRECTION_DIAGONAL_MASK) == 0) {
				internalCreatureTurn(&creature, dir);
			}
		}
	}

	return RETURNVALUE_NOERROR;
}

void Game::playerMoveItemByPlayerID(uint32_t playerId, const Position& fromPos, uint16_t spriteId, uint8_t fromStackPos, const Position& toPos, uint16_t count, bool allowAutoWalk)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}
	playerMoveItem(player, fromPos, spriteId, fromStackPos, toPos, count, nullptr, nullptr, allowAutoWalk);
}

void Game::playerMoveItem(Player* player, const Position& fromPos,
                          uint16_t spriteId, uint8_t fromStackPos, const Position& toPos, uint16_t count, Item* item, Cylinder* toCylinder, bool allowAutoWalk)
{
	player->stopNextActionTask();
	player->stopNextWalkActionTask();
	
	if (!player->canDoAction()) {
		uint32_t delay = player->getNextActionTime();
		player->setNextActionTask(delay, std::bind(&Game::playerMoveItemByPlayerID, this, player->getID(), fromPos, spriteId, fromStackPos, toPos, count, false));
		return;
	}

	if (item == nullptr) {
		uint8_t fromIndex = 0;
		if (fromPos.x == 0xFFFF) {
			if (fromPos.y & 0x40) {
				fromIndex = fromPos.z;
			} else {
				fromIndex = static_cast<uint8_t>(fromPos.y);
			}
		} else {
			fromIndex = fromStackPos;
		}

		Thing* thing = internalGetThing(player, fromPos, fromIndex, 0, STACKPOS_MOVE);
		if (!thing || !thing->getItem()) {
			player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
			return;
		}

		item = thing->getItem();
	}

	if (item->getClientID() != spriteId) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Cylinder* fromCylinder = internalGetCylinder(player, fromPos);
	if (fromCylinder == nullptr) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	if (toCylinder == nullptr) {
		toCylinder = internalGetCylinder(player, toPos);
		if (toCylinder == nullptr) {
			player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
			return;
		}
	}

	if (!item->isPushable() || item->hasAttribute(ITEM_ATTRIBUTE_UNIQUEID)) {
		player->sendCancelMessage(RETURNVALUE_NOTMOVEABLE);
		return;
	}

	const Position& playerPos = player->getPosition();
	const Tile* fromCylinderTile = fromCylinder->getTile();
	const Tile* toCylinderTile = toCylinder->getTile();
	Position mapFromPos = playerPos;
	if (fromCylinderTile) {
		mapFromPos = fromCylinderTile->getPosition();

		if (playerPos.z != mapFromPos.z) {
			player->sendCancelMessage(playerPos.z > mapFromPos.z ? RETURNVALUE_FIRSTGOUPSTAIRS : RETURNVALUE_FIRSTGODOWNSTAIRS);
			return;
		}

		if (!Position::areInRange<1, 1>(playerPos, mapFromPos)) {
			//need to walk to the item first before using it
			if (!allowAutoWalk) {
				player->sendCancelMessage(RETURNVALUE_TOOFARAWAY);
				return;
			}
			std::vector<Direction> listDir;
			if (player->getPathTo(item->getPosition(), listDir, 0, 1, true, false)) {
				player->startAutoWalk(std::move(listDir));
				player->setNextWalkActionTask(100, std::bind(&Game::playerMoveItemByPlayerID, this, player->getID(), fromPos, spriteId, fromStackPos, toPos, count, true));
			} else {
				player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
			}
			return;
		}
	}

	if (toCylinderTile) {
		const Position mapToPos = toCylinderTile->getPosition();

		//hangable item specific code
		if (item->isHangable() && toCylinderTile->hasFlag(TILESTATE_SUPPORTS_HANGABLE)) {
			//destination supports hangable objects so need to move there first
			bool vertical = toCylinderTile->hasProperty(CONST_PROP_ISVERTICAL);
			if (vertical) {
				if (playerPos.x + 1 == mapToPos.x) {
					player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
					return;
				}
			} else { // horizontal
				if (playerPos.y + 1 == mapToPos.y) {
					player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
					return;
				}
			}

			if (!Position::areInRange<1, 1, 0>(playerPos, mapToPos)) {
				Position walkPos = mapToPos;
				if (vertical) {
					walkPos.x++;
				} else {
					walkPos.y++;
				}

				Position itemPos = fromPos;
				uint8_t itemStackPos = fromStackPos;

				if (fromPos.x != 0xFFFF && Position::areInRange<1, 1>(mapFromPos, playerPos)
				        && !Position::areInRange<1, 1, 0>(mapFromPos, walkPos)) {
					//need to pickup the item first
					Item* moveItem = nullptr;

					ReturnValue ret = internalMoveItem(fromCylinder, player, INDEX_WHEREEVER, item, count, &moveItem);
					if (ret != RETURNVALUE_NOERROR) {
						player->sendCancelMessage(ret);
						return;
					}

					//changing the position since its now in the inventory of the player
					internalGetPosition(moveItem, itemPos, itemStackPos);
				}

				std::vector<Direction> listDir;
				if (player->getPathTo(walkPos, listDir, 0, 0, true, false)) {
					g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
					player->setNextWalkActionTask(400, std::bind(&Game::playerMoveItemByPlayerID, this, player->getID(), itemPos, spriteId, itemStackPos, toPos, count, true));
				} else {
					player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
				}
				return;
			}
		}

		int32_t throwRange = item->getThrowRange();
		if (Position::getDistanceX(playerPos, mapToPos) > throwRange || Position::getDistanceY(playerPos, mapToPos) > throwRange ||
				(!item->isPickupable() && Position::getDistanceZ(mapFromPos, mapToPos) > 0)) {
			player->sendCancelMessage(RETURNVALUE_DESTINATIONOUTOFREACH);
			return;
		}

		if (!canThrowObjectTo(mapFromPos, mapToPos)) {
			player->sendCancelMessage(RETURNVALUE_CANNOTTHROW);
			return;
		}
	}

	if (!g_events->eventPlayerOnMoveItem(player, item, count, fromPos, toPos, fromCylinder, toCylinder)) {
		return;
	}

	uint8_t toIndex = 0;
	if (toPos.x == 0xFFFF) {
		if (toPos.y & 0x40) {
			toIndex = toPos.z;
		} else {
			toIndex = static_cast<uint8_t>(toPos.y);
		}
	}

	ReturnValue ret = internalMoveItem(fromCylinder, toCylinder, toIndex, item, count, nullptr, 0, player);
	if (ret != RETURNVALUE_NOERROR) {
		player->sendCancelMessage(ret);
	} else {
		g_events->eventPlayerOnItemMoved(player, item, count, fromPos, toPos, fromCylinder, toCylinder);
	}
}

ReturnValue Game::internalMoveItem(Cylinder* fromCylinder, Cylinder* toCylinder, int32_t index,
                                   Item* item, uint32_t count, Item** _moveItem, uint32_t flags /*= 0*/, Creature* actor/* = nullptr*/, bool checkOtherContainers/* = false*/)
{
	#if GAME_FEATURE_BROWSEFIELD > 0
	Tile* fromTile = fromCylinder->getTile();
	if (fromTile) {
		auto it = browseFields.find(fromTile);
		if (it != browseFields.end() && it->second == fromCylinder) {
			fromCylinder = fromTile;
		}
	}
	#endif

	Item* toItem = nullptr;

	Cylinder* subCylinder;
	int floorN = 0;

	while ((subCylinder = toCylinder->queryDestination(index, *item, &toItem, flags)) != toCylinder) {
		toCylinder = subCylinder;
		flags = 0;

		//to prevent infinite loop
		if (++floorN >= MAP_MAX_LAYERS) {
			break;
		}
	}

	//destination is the same as the source?
	if (item == toItem) {
		return RETURNVALUE_NOERROR;    //silently ignore move
	}

	//check if we can add this item
	ReturnValue ret = toCylinder->queryAdd(index, *item, count, flags, actor);
	if (ret == RETURNVALUE_NEEDEXCHANGE) {
		//check if we can add it to source cylinder
		ret = fromCylinder->queryAdd(fromCylinder->getThingIndex(item), *toItem, toItem->getItemCount(), 0);
		if (ret == RETURNVALUE_NOERROR) {
			//check how much we can move
			uint32_t maxExchangeQueryCount = 0;
			ReturnValue retExchangeMaxCount = fromCylinder->queryMaxCount(INDEX_WHEREEVER, *toItem, toItem->getItemCount(), maxExchangeQueryCount, 0);

			if (retExchangeMaxCount != RETURNVALUE_NOERROR && maxExchangeQueryCount == 0) {
				return retExchangeMaxCount;
			}

			if (toCylinder->queryRemove(*toItem, toItem->getItemCount(), flags, actor) == RETURNVALUE_NOERROR) {
				int32_t oldToItemIndex = toCylinder->getThingIndex(toItem);
				toCylinder->removeThing(toItem, toItem->getItemCount());
				fromCylinder->addThing(toItem);

				if (oldToItemIndex != -1) {
					toCylinder->postRemoveNotification(toItem, fromCylinder, oldToItemIndex);
				}

				int32_t newToItemIndex = fromCylinder->getThingIndex(toItem);
				if (newToItemIndex != -1) {
					fromCylinder->postAddNotification(toItem, toCylinder, newToItemIndex);
				}

				ret = toCylinder->queryAdd(index, *item, count, flags);
				toItem = nullptr;
			}
		}
	}

	if (ret != RETURNVALUE_NOERROR) {
		if (checkOtherContainers) {
			//try to find a container that fits the move
			for (ContainerIterator it = toCylinder->getContainer()->iterator(); it.hasNext(); it.advance()) {
				Item* containerItem = *it;
				Container* containerX = containerItem->getContainer();
				if (containerX) {
					ret = internalMoveItem(fromCylinder, containerX, INDEX_WHEREEVER, item, count, _moveItem, flags, actor, false);
					if (ret == RETURNVALUE_NOERROR) {
						return RETURNVALUE_NOERROR;
					}
				}
			}
		}
		return ret;
	}

	//check how much we can move
	uint32_t maxQueryCount = 0;
	ReturnValue retMaxCount = toCylinder->queryMaxCount(index, *item, count, maxQueryCount, flags);
	if (retMaxCount != RETURNVALUE_NOERROR && maxQueryCount == 0) {
		return retMaxCount;
	}

	uint32_t m;
	if (item->isStackable()) {
		m = std::min<uint32_t>(count, maxQueryCount);
	} else {
		m = maxQueryCount;
	}

	Item* moveItem = item;

	//check if we can remove this item
	ret = fromCylinder->queryRemove(*item, m, flags, actor);
	if (ret != RETURNVALUE_NOERROR) {
		return ret;
	}

	//remove the item
	int32_t itemIndex = fromCylinder->getThingIndex(item);
	Item* updateItem = nullptr;
	fromCylinder->removeThing(item, m);

	//update item(s)
	if (item->isStackable()) {
		uint32_t n;

		if (item->equals(toItem)) {
			n = std::min<uint32_t>(9999 - toItem->getItemCount(), m);
			toCylinder->updateThing(toItem, toItem->getID(), toItem->getItemCount() + n);
			updateItem = toItem;
		} else {
			n = 0;
		}

		int32_t newCount = m - n;
		if (newCount > 0) {
			moveItem = item->clone();
			moveItem->setItemCount(newCount);
		} else {
			moveItem = nullptr;
		}

		if (item->isRemoved()) {
			if (item->getIsRealItem() && item->getRealUID() > 0) {
				removeRealUniqueItem(item->getRealUID());
			}
			item->stopDecaying();
			ReleaseItem(item);
		}
	}

	//add item
	if (moveItem /*m - n > 0*/) {
		toCylinder->addThing(index, moveItem);
	}

	if (itemIndex != -1) {
		fromCylinder->postRemoveNotification(item, toCylinder, itemIndex);
	}

	if (moveItem) {
		int32_t moveItemIndex = toCylinder->getThingIndex(moveItem);
		if (moveItemIndex != -1) {
			toCylinder->postAddNotification(moveItem, fromCylinder, moveItemIndex);
		}
		moveItem->startDecaying();
	}

	if (updateItem) {
		int32_t updateItemIndex = toCylinder->getThingIndex(updateItem);
		if (updateItemIndex != -1) {
			toCylinder->postAddNotification(updateItem, fromCylinder, updateItemIndex);
		}
		updateItem->startDecaying();
	}

	if (_moveItem) {
		if (moveItem) {
			*_moveItem = moveItem;
		} else {
			*_moveItem = item;
		}
	}

	//we could not move all, inform the player
	if (item->isStackable() && maxQueryCount < count) {
		return retMaxCount;
	}

	return ret;
}

ReturnValue Game::internalAddItem(Cylinder* toCylinder, Item* item, int32_t index /*= INDEX_WHEREEVER*/,
                                  uint32_t flags/* = 0*/, bool test/* = false*/)
{
	uint32_t remainderCount = 0;
	return internalAddItem(toCylinder, item, index, flags, test, remainderCount);
}

ReturnValue Game::internalAddItem(Cylinder* toCylinder, Item* item, int32_t index,
                                  uint32_t flags, bool test, uint32_t& remainderCount)
{
	if (toCylinder == nullptr || item == nullptr) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	Cylinder* destCylinder = toCylinder;
	Item* toItem = nullptr;
	toCylinder = toCylinder->queryDestination(index, *item, &toItem, flags);

	//check if we can add this item
	ReturnValue ret = toCylinder->queryAdd(index, *item, item->getItemCount(), flags);
	if (ret != RETURNVALUE_NOERROR) {
		return ret;
	}

	/*
	Check if we can move add the whole amount, we do this by checking against the original cylinder,
	since the queryDestination can return a cylinder that might only hold a part of the full amount.
	*/
	uint32_t maxQueryCount = 0;
	ret = destCylinder->queryMaxCount(INDEX_WHEREEVER, *item, item->getItemCount(), maxQueryCount, flags);

	if (ret != RETURNVALUE_NOERROR) {
		return ret;
	}

	if (test) {
		return RETURNVALUE_NOERROR;
	}

	if (item->isStackable() && item->equals(toItem)) {
		uint32_t m = std::min<uint32_t>(item->getItemCount(), maxQueryCount);
		uint32_t n = std::min<uint32_t>(9999 - toItem->getItemCount(), m);

		toCylinder->updateThing(toItem, toItem->getID(), toItem->getItemCount() + n);

		int32_t count = m - n;
		if (count > 0) {
			if (item->getItemCount() != count) {
				Item* remainderItem = item->clone();
				remainderItem->setItemCount(count);
				if (internalAddItem(destCylinder, remainderItem, INDEX_WHEREEVER, flags, false) != RETURNVALUE_NOERROR) {
					ReleaseItem(remainderItem);
					remainderCount = count;
				}
			} else {
				toCylinder->addThing(index, item);

				int32_t itemIndex = toCylinder->getThingIndex(item);
				if (itemIndex != -1) {
					toCylinder->postAddNotification(item, nullptr, itemIndex);
				}
			}
		} else {
			//fully merged with toItem, item will be destroyed
			item->onRemoved();
			ReleaseItem(item);

			int32_t itemIndex = toCylinder->getThingIndex(toItem);
			if (itemIndex != -1) {
				toCylinder->postAddNotification(toItem, nullptr, itemIndex);
			}
		}
	} else {
		toCylinder->addThing(index, item);

		int32_t itemIndex = toCylinder->getThingIndex(item);
		if (itemIndex != -1) {
			toCylinder->postAddNotification(item, nullptr, itemIndex);
		}
	}

	return RETURNVALUE_NOERROR;
}

ReturnValue Game::internalRemoveItem(Item* item, int32_t count /*= -1*/, bool test /*= false*/, uint32_t flags /*= 0*/)
{
	Cylinder* cylinder = item->getParent();
	if (cylinder == nullptr) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	#if GAME_FEATURE_BROWSEFIELD > 0
	Tile* fromTile = cylinder->getTile();
	if (fromTile) {
		auto it = browseFields.find(fromTile);
		if (it != browseFields.end() && it->second == cylinder) {
			cylinder = fromTile;
		}
	}
	#endif

	if (count == -1) {
		count = item->getItemCount();
	}

	//check if we can remove this item
	ReturnValue ret = cylinder->queryRemove(*item, count, flags | FLAG_IGNORENOTMOVEABLE);
	if (ret != RETURNVALUE_NOERROR) {
		return ret;
	}

	if (!item->canRemove()) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (!test) {
		int32_t index = cylinder->getThingIndex(item);

		//remove the item
		cylinder->removeThing(item, count);

		if (item->isRemoved()) {
			item->onRemoved();
			item->stopDecaying();
			ReleaseItem(item);
		}

		cylinder->postRemoveNotification(item, nullptr, index);
	}

	return RETURNVALUE_NOERROR;
}

#if GAME_FEATURE_FASTER_CLEAN > 0
ReturnValue Game::internalCleanItem(Item* item, int32_t count /*= -1*/)
{
	Cylinder* cylinder = item->getParent();
	if (cylinder == nullptr) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	#if GAME_FEATURE_BROWSEFIELD > 0
	Tile* fromTile = cylinder->getTile();
	if (fromTile) {
		auto it = browseFields.find(fromTile);
		if (it != browseFields.end() && it->second == cylinder) {
			cylinder = fromTile;
		}
	}
	#endif

	if (count == -1) {
		count = item->getItemCount();
	}

	//check if we can remove this item
	ReturnValue ret = cylinder->queryRemove(*item, count, FLAG_IGNORENOTMOVEABLE);
	if (ret != RETURNVALUE_NOERROR) {
		return ret;
	}

	if (!item->canRemove()) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	int32_t index = cylinder->getThingIndex(item);

	//remove the item
	Tile* tile = cylinder->getTile();
	if (tile) {
		tile->cleanItem(item, index, count);
	} else {
		cylinder->removeThing(item, count);
	}

	if (item->isRemoved()) {
		item->onRemoved();
		item->stopDecaying();
		ReleaseItem(item);
	}

	cylinder->postRemoveNotification(item, nullptr, index, LINK_CLEAN);
	return RETURNVALUE_NOERROR;
}
#endif

ReturnValue Game::internalPlayerAddItem(Player* player, Item* item, bool dropOnMap /*= true*/, slots_t slot /*= CONST_SLOT_WHEREEVER*/)
{
	ReturnValue ret = RETURNVALUE_NOTPOSSIBLE;
	if (item->isPickupable()) {
		uint32_t remainderCount = 0;
		ret = internalAddItem(player, item, static_cast<int32_t>(slot), 0, false, remainderCount);
		if (remainderCount != 0) {
			Item* remainderItem = Item::CreateItem(item->getID(), remainderCount);
			ReturnValue remaindRet = internalAddItem(player->getTile(), remainderItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
			if (remaindRet != RETURNVALUE_NOERROR) {
				ReleaseItem(remainderItem);
			}
		}
	}

	if (ret != RETURNVALUE_NOERROR && dropOnMap) {
		ret = internalAddItem(player->getTile(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
	}

	return ret;
}

Item* Game::findItemOfType(Cylinder* cylinder, uint16_t itemId,
                           bool depthSearch /*= true*/, int32_t subType /*= -1*/) const
{
	if (cylinder == nullptr) {
		return nullptr;
	}

	std::vector<Container*> containers;
	containers.reserve(32);

	for (size_t i = cylinder->getFirstIndex(), j = cylinder->getLastIndex(); i < j; ++i) {
		Thing* thing = cylinder->getThing(i);
		if (!thing) {
			continue;
		}

		Item* item = thing->getItem();
		if (!item) {
			continue;
		}

		if (item->getID() == itemId && (subType == -1 || subType == item->getSubType())) {
			return item;
		}

		if (depthSearch) {
			Container* container = item->getContainer();
			if (container) {
				containers.push_back(container);
			}
		}
	}

	size_t i = static_cast<size_t>(-1);
	while (++i < containers.size()) {
		Container* container = containers[i];
		for (Item* item : container->getItemList()) {
			if (item->getID() == itemId && (subType == -1 || subType == item->getSubType())) {
				return item;
			}

			Container* subContainer = item->getContainer();
			if (subContainer) {
				containers.push_back(subContainer);
			}
		}
	}
	return nullptr;
}

bool Game::removeMoney(Cylinder* cylinder, uint64_t money, uint32_t flags /*= 0*/)
{
	if (cylinder == nullptr) {
		return false;
	}

	if (money == 0) {
		return true;
	}

	std::multimap<uint32_t, Item*> moneyMap;
	std::vector<Container*> containers;
	containers.reserve(32);

	uint64_t moneyCount = 0;
	for (size_t i = cylinder->getFirstIndex(), j = cylinder->getLastIndex(); i < j; ++i) {
		Thing* thing = cylinder->getThing(i);
		if (!thing) {
			continue;
		}

		Item* item = thing->getItem();
		if (!item) {
			continue;
		}

		Container* container = item->getContainer();
		if (container) {
			containers.push_back(container);
		} else {
			const uint32_t worth = item->getWorth();
			if (worth != 0) {
				moneyCount += worth;
				moneyMap.emplace(worth, item);
			}
		}
	}

	size_t i = static_cast<size_t>(-1);
	while (++i < containers.size()) {
		Container* container = containers[i];
		for (Item* item : container->getItemList()) {
			Container* tmpContainer = item->getContainer();
			if (tmpContainer) {
				containers.push_back(tmpContainer);
			} else {
				const uint32_t worth = item->getWorth();
				if (worth != 0) {
					moneyCount += worth;
					moneyMap.emplace(worth, item);
				}
			}
		}
	}

	if (moneyCount < money) {
		return false;
	}

	for (const auto& moneyEntry : moneyMap) {
		Item* item = moneyEntry.second;
		if (moneyEntry.first < money) {
			internalRemoveItem(item);
			money -= moneyEntry.first;
		} else if (moneyEntry.first > money) {
			const uint32_t worth = moneyEntry.first / item->getItemCount();
			const uint32_t removeCount = std::ceil(money / static_cast<double>(worth));

			addMoney(cylinder, (worth * removeCount) - money, flags);
			internalRemoveItem(item, removeCount);
			break;
		} else {
			internalRemoveItem(item);
			break;
		}
	}
	return true;
}

void Game::addMoney(Cylinder* cylinder, uint64_t money, uint32_t flags /*= 0*/)
{
	if (money == 0) {
		return;
	}

	uint32_t crystalCoins = money / 10000;
	money -= crystalCoins * 10000;
	while (crystalCoins > 0) {
		const uint16_t count = std::min<uint32_t>(100, crystalCoins);

		Item* remaindItem = Item::CreateItem(ITEM_CRYSTAL_COIN, count);

		ReturnValue ret = internalAddItem(cylinder, remaindItem, INDEX_WHEREEVER, flags);
		if (ret != RETURNVALUE_NOERROR) {
			internalAddItem(cylinder->getTile(), remaindItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
		}

		crystalCoins -= count;
	}

	uint16_t platinumCoins = money / 100;
	if (platinumCoins != 0) {
		Item* remaindItem = Item::CreateItem(ITEM_PLATINUM_COIN, platinumCoins);

		ReturnValue ret = internalAddItem(cylinder, remaindItem, INDEX_WHEREEVER, flags);
		if (ret != RETURNVALUE_NOERROR) {
			internalAddItem(cylinder->getTile(), remaindItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
		}

		money -= platinumCoins * 100;
	}

	if (money != 0) {
		Item* remaindItem = Item::CreateItem(ITEM_GOLD_COIN, money);

		ReturnValue ret = internalAddItem(cylinder, remaindItem, INDEX_WHEREEVER, flags);
		if (ret != RETURNVALUE_NOERROR) {
			internalAddItem(cylinder->getTile(), remaindItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
		}
	}
}

Item* Game::transformItem(Item* item, uint16_t newId, int32_t newCount /*= -1*/)
{
	if (item->getID() == newId && (newCount == -1 || (newCount == item->getSubType() && newCount != 0))) { //chargeless item placed on map = infinite
		return item;
	}

	Cylinder* cylinder = item->getParent();
	if (cylinder == nullptr) {
		return nullptr;
	}

	#if GAME_FEATURE_BROWSEFIELD > 0
	Tile* fromTile = cylinder->getTile();
	if (fromTile) {
		auto it = browseFields.find(fromTile);
		if (it != browseFields.end() && it->second == cylinder) {
			cylinder = fromTile;
		}
	}
	#endif

	int32_t itemIndex = cylinder->getThingIndex(item);
	if (itemIndex == -1) {
		return item;
	}

	if (!item->canTransform()) {
		return item;
	}

	const ItemType& newType = Item::items[newId];
	if (newType.id == 0) {
		return item;
	}

	const ItemType& curType = Item::items[item->getID()];
	if (curType.alwaysOnTop != newType.alwaysOnTop) {
		//This only occurs when you transform items on tiles from a downItem to a topItem (or vice versa)
		//Remove the old, and add the new
		cylinder->removeThing(item, item->getItemCount());
		cylinder->postRemoveNotification(item, cylinder, itemIndex);

		item->setID(newId);
		if (newCount != -1) {
			item->setSubType(newCount);
		}
		cylinder->addThing(item);

		Cylinder* newParent = item->getParent();
		if (newParent == nullptr) {
			item->stopDecaying();
			ReleaseItem(item);
			return nullptr;
		}

		newParent->postAddNotification(item, cylinder, newParent->getThingIndex(item));
		item->startDecaying();

		return item;
	}

	if (curType.type == newType.type) {
		//Both items has the same type so we can safely change id/subtype
		if (newCount == 0 && (item->isStackable() || item->hasAttribute(ITEM_ATTRIBUTE_CHARGES))) {
			if (item->isStackable()) {
				internalRemoveItem(item);
				return nullptr;
			} else {
				int32_t newItemId = newId;
				if (curType.id == newType.id) {
					newItemId = curType.decayTo;
				}

				if (newItemId < 0) {
					internalRemoveItem(item);
					return nullptr;
				} else if (newItemId != newId) {
					//Replacing the the old item with the new while maintaining the old position
					Item* newItem = Item::CreateItem(newItemId, 1);
					if (newItem == nullptr) {
						return nullptr;
					}

					cylinder->replaceThing(itemIndex, newItem);
					cylinder->postAddNotification(newItem, cylinder, itemIndex);

					item->setParent(nullptr);
					cylinder->postRemoveNotification(item, cylinder, itemIndex);
					item->stopDecaying();
					ReleaseItem(item);
					newItem->startDecaying();

					return newItem;
				} else {
					return transformItem(item, newItemId);
				}
			}
		} else {
			cylinder->postRemoveNotification(item, cylinder, itemIndex);
			uint16_t itemId = item->getID();
			int32_t count = item->getSubType();

			if (curType.id != newType.id) {
				if (newType.group != curType.group) {
					item->setDefaultSubtype();
				}

				itemId = newId;
			}

			if (newCount != -1 && newType.hasSubType()) {
				count = newCount;
			}

			cylinder->updateThing(item, itemId, count);
			cylinder->postAddNotification(item, cylinder, itemIndex);
			item->startDecaying();

			return item;
		}
	}

	//Replacing the the old item with the new while maintaining the old position
	Item* newItem;
	if (newCount == -1) {
		newItem = Item::CreateItem(newId);
	} else {
		newItem = Item::CreateItem(newId, newCount);
	}

	if (newItem == nullptr) {
		return nullptr;
	}

	cylinder->replaceThing(itemIndex, newItem);
	cylinder->postAddNotification(newItem, cylinder, itemIndex);

	item->setParent(nullptr);
	cylinder->postRemoveNotification(item, cylinder, itemIndex);
	item->stopDecaying();
	ReleaseItem(item);
	newItem->startDecaying();

	return newItem;
}

ReturnValue Game::internalTeleport(Thing* thing, const Position& newPos, bool pushMove/* = true*/, uint32_t flags /*= 0*/)
{
	if (newPos == thing->getPosition()) {
		return RETURNVALUE_NOERROR;
	} else if (thing->isRemoved()) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	Tile* toTile = map.getTile(newPos);
	if (!toTile) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (Creature* creature = thing->getCreature()) {
		ReturnValue ret = toTile->queryAdd(0, *creature, 1, FLAG_NOLIMIT);
		if (ret != RETURNVALUE_NOERROR) {
			return ret;
		}

		map.moveCreature(*creature, *toTile, !pushMove);
		return RETURNVALUE_NOERROR;
	} else if (Item* item = thing->getItem()) {
		return internalMoveItem(item->getParent(), toTile, INDEX_WHEREEVER, item, item->getItemCount(), nullptr, flags);
	}
	return RETURNVALUE_NOTPOSSIBLE;
}

Item* searchForItem(Container* container, uint16_t itemId)
{
	for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
		if ((*it)->getID() == itemId) {
			return *it;
		}
	}

	return nullptr;
}

slots_t getSlotType(const ItemType& it)
{
	slots_t slot = CONST_SLOT_RIGHT;
	if (it.weaponType != WeaponType_t::WEAPON_SHIELD) {
		int32_t slotPosition = it.slotPosition;

		if (slotPosition & SLOTP_HEAD) {
			slot = CONST_SLOT_HEAD;
		} else if (slotPosition & SLOTP_NECKLACE) {
			slot = CONST_SLOT_NECKLACE;
		} else if (slotPosition & SLOTP_ARMOR) {
			slot = CONST_SLOT_ARMOR;
		} else if (slotPosition & SLOTP_LEGS) {
			slot = CONST_SLOT_LEGS;
		} else if (slotPosition & SLOTP_FEET) {
			slot = CONST_SLOT_FEET ;
		} else if (slotPosition & SLOTP_RING) {
			slot = CONST_SLOT_RING;
		} else if (slotPosition & SLOTP_GLOVES) {
			slot = CONST_SLOT_GLOVES;
		} else if (slotPosition & SLOTP_RING2) {
			slot = CONST_SLOT_RING2;
		} else if (slotPosition & SLOTP_SPELL1) {
			slot = CONST_SLOT_SPELL1;
		} else if (slotPosition & SLOTP_SPELL2) {
			slot = CONST_SLOT_SPELL2;
		} else if (slotPosition & SLOTP_SPELL3) {
			slot = CONST_SLOT_SPELL3;
		} else if (slotPosition & SLOTP_SPELL4) {
			slot = CONST_SLOT_SPELL4;
		} else if (slotPosition & SLOTP_POTION1) {
			slot = CONST_SLOT_POTION1;
		} else if (slotPosition & SLOTP_POTION2) {
			slot = CONST_SLOT_POTION2;
		} else if (slotPosition & SLOTP_TWO_HAND || slotPosition & SLOTP_LEFT) {
			slot = CONST_SLOT_LEFT;
		}
	}

	return slot;
}

void Game::playerEquipItem(Player* player, uint64_t uid)
{
	Item* item = player->getItemByUID(uid);
	if (!item) {
		return;
	}

	const ItemType& it = Item::items[item->getID()];
	slots_t slot = getSlotType(it);
	Position fromPos, toPos;
	uint8_t fromStackPos, toStackPos;

	if (item) {
		internalGetPosition(item, fromPos, fromStackPos);
	}

	Item* oldItem = player->getInventoryItem(slot);
	ReturnValue ret = RETURNVALUE_NOERROR;
	if (oldItem) {
		internalGetPosition(oldItem, toPos, toStackPos);
	}
	
	playerMoveItem(player, fromPos, item->getClientID(), fromStackPos, toPos, 1, item, player);
}

#if CLIENT_VERSION >= 1150
void Game::playerTeleport(Player* player, const Position& position)
{
	if (!player->isAccessPlayer()) {
		return;
	}

	ReturnValue ret = g_game.internalTeleport(player, position, false, FLAG_NOLIMIT);
	if (ret != RETURNVALUE_NOERROR) {
		player->sendCancelMessage(ret);
	}
}
#endif

void Game::playerMove(Player* player, Direction direction)
{
	player->resetIdleTime();
	player->stopNextWalkActionTask();

	player->startAutoWalk(direction);
}

bool Game::playerBroadcastMessage(Player* player, const std::string& text) const
{
	if (!player->hasFlag(PlayerFlag_CanBroadcast)) {
		return false;
	}

	std::cout << "> " << player->getName() << " broadcasted: \"" << text << "\"." << std::endl;

	for (const auto& it : players) {
		it.second->sendPrivateMessage(player, TALKTYPE_BROADCAST, text);
	}

	return true;
}

void Game::playerCreatePrivateChannel(Player* player)
{
	ChatChannel* channel = g_chat->createChannel(*player, CHANNEL_PRIVATE);
	if (!channel || !channel->addUser(*player)) {
		return;
	}

	player->sendCreatePrivateChannel(channel->getId(), channel->getName());
}

void Game::playerChannelInvite(Player* player, const std::string& name)
{
	PrivateChatChannel* channel = g_chat->getPrivateChannel(*player);
	if (!channel) {
		return;
	}

	Player* invitePlayer = getPlayerByName(name);
	if (!invitePlayer) {
		return;
	}

	if (player == invitePlayer) {
		return;
	}

	channel->invitePlayer(*player, *invitePlayer);
}

void Game::playerChannelExclude(Player* player, const std::string& name)
{
	PrivateChatChannel* channel = g_chat->getPrivateChannel(*player);
	if (!channel) {
		return;
	}

	Player* excludePlayer = getPlayerByName(name);
	if (!excludePlayer) {
		return;
	}

	if (player == excludePlayer) {
		return;
	}

	channel->excludePlayer(*player, *excludePlayer);
}

void Game::playerRequestChannels(Player* player)
{
	player->sendChannelsDialog();
}

void Game::playerOpenChannel(Player* player, uint16_t channelId)
{
	ChatChannel* channel = g_chat->addUserToChannel(*player, channelId);
	if (!channel) {
		return;
	}

	const InvitedMap* invitedUsers = channel->getInvitedUsers();
	const UsersMap* users;
	if (!channel->isPublicChannel()) {
		users = &channel->getUsers();
	} else {
		users = nullptr;
	}

	#if GAME_FEATURE_RULEVIOLATION > 0
	if (channel->getId() == 3) {
		player->sendRuleViolationChannel(channel->getId());
		return;
	}
	#endif
	player->sendChannel(channel->getId(), channel->getName(), users, invitedUsers);
}

void Game::playerCloseChannel(Player* player, uint16_t channelId)
{
	g_chat->removeUserFromChannel(*player, channelId);
}

void Game::playerOpenPrivateChannel(Player* player, std::string& receiver)
{
	if (!IOLoginData::formatPlayerName(receiver)) {
		player->sendCancelMessage("A player with this name does not exist.");
		return;
	}

	if (player->getName() == receiver) {
		player->sendCancelMessage("You cannot set up a private message channel with yourself.");
		return;
	}

	player->sendOpenPrivateChannel(receiver);
}

#if GAME_FEATURE_RULEVIOLATION > 0
void Game::playerRuleViolation(Player* player, const std::string& target, const std::string& comment, uint8_t reason, uint8_t, uint32_t, bool ipBanishment)
{
	if (!player->isAccessPlayer()) {
		return;
	}

	std::string reasonStr;
	#if CLIENT_VERSION >= 726 && CLIENT_VERSION <= 730
	switch (reason) {
		case 0: reasonStr = "Insulting name"; break;
		case 1: reasonStr = "Name containing parts of sentences"; break;
		case 2: reasonStr = "Name with nonsensical letter combination"; break;
		case 3: reasonStr = "Badly formatted name"; break;
		case 4: reasonStr = "Name not describing person"; break;
		case 5: reasonStr = "Name of celebrity"; break;
		case 6: reasonStr = "Name referring to country"; break;
		case 7: reasonStr = "Name to fake identity"; break;
		case 8: reasonStr = "Name to fake official position"; break;
		case 9: reasonStr = "Insulting statements"; break;
		case 10: reasonStr = "Spamming"; break;
		case 11: reasonStr = "Off-topic advertisment"; break;
		case 12: reasonStr = "Real money advertisment"; break;
		case 13: reasonStr = "Off-topic channel use"; break;
		case 14: reasonStr = "Inciting rule violation"; break;
		case 15: reasonStr = "Bug abuse"; break;
		case 16: reasonStr = "Game weakness abuse"; break;
		case 17: reasonStr = "Macro use"; break;
		case 18: reasonStr = "Using modified client"; break;
		case 19: reasonStr = "Hacking attempt"; break;
		case 20: reasonStr = "Multi-clienting"; break;
		case 21: reasonStr = "Account trading"; break;
		case 22: reasonStr = "Account sharing"; break;
		case 23: reasonStr = "Threatening gamemaster"; break;
		case 24: reasonStr = "Pretending official position"; break;
		case 25: reasonStr = "Pretending to have influence on staff"; break;
		case 26: reasonStr = "False reports"; break;
		case 27: reasonStr = "Excessive unjustified player killing"; break;
		case 28: reasonStr = "Destructive behaviour"; break;
		case 29: reasonStr = "Invalid payment"; break;
		default: reasonStr = "Unknown reason"; break;
	}
	#elif CLIENT_VERSION >= 820
	switch (reason) {
		case 0: reasonStr = "Offensive Name"; break;
		case 1: reasonStr = "Invalid Name Format"; break;
		case 2: reasonStr = "Unsuitable Name"; break;
		case 3: reasonStr = "Name Inciting Rule Violation"; break;
		case 4: reasonStr = "Offensive Statement"; break;
		case 5: reasonStr = "Spamming"; break;
		case 6: reasonStr = "Illegal Advertising"; break;
		case 7: reasonStr = "Off-Topic Public Statement"; break;
		case 8: reasonStr = "Non-English Public Statement"; break;
		case 9: reasonStr = "Inciting Rule Violation"; break;
		case 10: reasonStr = "Bug Abuse"; break;
		case 11: reasonStr = "Game Weakness Abuse"; break;
		case 12: reasonStr = "Using Unofficial Software to Play"; break;
		case 13: reasonStr = "Hacking"; break;
		case 14: reasonStr = "Multi-Clienting"; break;
		case 15: reasonStr = "Account Trading or Sharing"; break;
		case 16: reasonStr = "Threatening Gamemaster"; break;
		case 17: reasonStr = "Pretending to Have Influence on Rule Enforcement"; break;
		case 18: reasonStr = "False Report to Gamemaster"; break;
		case 19: reasonStr = "Destructive Behaviour"; break;
		case 20: reasonStr = "Excessive Unjustified Player Killing"; break;
		case 21: reasonStr = "Invalid Payment"; break;
		case 22: reasonStr = "Spoiling Auction"; break;
		default: reasonStr = "Unknown reason"; break;
	}
	#else
	switch (reason) {
		case 0: reasonStr = "Offensive name"; break;
		case 1: reasonStr = "Name containing part of sentence"; break;
		case 2: reasonStr = "Name with nonsensical letter combination"; break;
		case 3: reasonStr = "Invalid name format"; break;
		case 4: reasonStr = "Name not describing person"; break;
		case 5: reasonStr = "Name of celebrity"; break;
		case 6: reasonStr = "Name referring to country"; break;
		case 7: reasonStr = "Name to fake player identity"; break;
		case 8: reasonStr = "Name to fake official position"; break;
		case 9: reasonStr = "Offensive statement"; break;
		case 10: reasonStr = "Spamming"; break;
		case 11: reasonStr = "Advertisement not related to game"; break;
		case 12: reasonStr = "Real money advertisement"; break;
		case 13: reasonStr = "Non-English public statement"; break;
		case 14: reasonStr = "Off-topic public statement"; break;
		case 15: reasonStr = "Inciting rule violation"; break;
		case 16: reasonStr = "Bug abuse"; break;
		case 17: reasonStr = "Game weakness abuse"; break;
		case 18: reasonStr = "Macro use"; break;
		case 19: reasonStr = "Using unofficial software to play"; break;
		case 20: reasonStr = "Hacking"; break;
		case 21: reasonStr = "Multi-clienting"; break;
		case 22: reasonStr = "Account trading"; break;
		case 23: reasonStr = "Account sharing"; break;
		case 24: reasonStr = "Threatening gamemaster"; break;
		case 25: reasonStr = "Pretending to have official position"; break;
		case 26: reasonStr = "Pretending to have influence on gamemaster"; break;
		case 27: reasonStr = "False report to gamemaster"; break;
		case 28: reasonStr = "Excessive unjustified player killing"; break;
		case 29: reasonStr = "Destructive behaviour"; break;
		case 30: reasonStr = "Spoiling auction"; break;
		case 31: reasonStr = "Invalid payment"; break;
		default: reasonStr = "Unknown reason"; break;
	}
	#endif

	time_t timeBan = 7 * 86400;
	time_t timeNow = time(nullptr);
	if (!comment.empty()) {
		std::string::size_type end = 0;
		if (comment.front() == '{' && (end = comment.find('}')) != std::string::npos) {
			timeBan = 0;

			StringVector timeVec = explodeString(comment.substr(1, end - 1), ";");
			for (const std::string& timeStr : timeVec) {
				StringVector timer = explodeString(timeStr, ",");
				uint32_t time = 1;
				if (timer.size() > 1) {
					try {
						time = std::stoul(timer[1]);
					} catch (const std::invalid_argument&) {
						time = 0;
					} catch (const std::out_of_range&) {
						time = 0;
					}
				}

				if (!timer.empty() && !timer[0].empty()) {
					if (timer[0].front() == 's') {
						timeBan += (time);
					} else if (timer[0].front() == 'm') {
						timeBan += (time * 60);
					} else if (timer[0].front() == 'h') {
						timeBan += (time * 3600);
					} else if (timer[0].front() == 'd') {
						timeBan += (time * 86400);
					} else if (timer[0].front() == 'w') {
						timeBan += (time * 604800);
					} else if (timer[0].front() == 'm') {
						timeBan += (time * 2592000);
					} else if (timer[0].front() == 'y') {
						timeBan += (time * 31536000);
					}
				}
			}

			++end;
		}

		std::string commentStr = comment.substr(end);
		if (!commentStr.empty()) {
			reasonStr.push_back('(');
			reasonStr.append(commentStr);
			reasonStr.push_back(')');
		}
	}
	BanInfo banInfo;

	Player* targetPlayer = getPlayerByName(target);
	if (ipBanishment) {
		uint32_t targetIp;
		if (targetPlayer) {
			targetIp = targetPlayer->getIP();
		} else {
			targetIp = IOBan::getAccountLastIP(target);
		}

		if (targetIp == 0) {
			player->sendCancelMessage("A player with this name does not exist.");
			return;
		}

		if (IOBan::isIpBanned(targetIp, banInfo)) {
			player->sendCancelMessage((targetPlayer ? targetPlayer->getName() : target) + " is already IP banned.");
			if (targetPlayer) {
				targetPlayer->kickPlayer(true);
			}
			return;
		}

		std::stringExtended query(256);
		query << "INSERT INTO `ip_bans` (`ip`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" << targetIp << ", " << g_database.escapeString(reasonStr) << ", " << timeNow << ", " << (timeNow + timeBan) << ", " << player->getGUID() << ")";
		g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));

		player->sendTextMessage(MESSAGE_EVENT_ADVANCE, (targetPlayer ? targetPlayer->getName() : target) + " has been IP banned.");
		if (targetPlayer) {
			targetPlayer->kickPlayer(true);
		}
	} else {
		uint32_t targetAccId;
		if (targetPlayer) {
			targetAccId = targetPlayer->getAccount();
		} else {
			targetAccId = IOBan::getAccountID(target);
		}

		if (targetAccId == 0) {
			player->sendCancelMessage("A player with this name does not exist.");
			return;
		}

		if (IOBan::isAccountBanned(targetAccId, banInfo)) {
			player->sendCancelMessage((targetPlayer ? targetPlayer->getName() : target) + " is already banned.");
			if (targetPlayer) {
				targetPlayer->kickPlayer(true);
			}
			return;
		}

		std::stringExtended query(256);
		query << "INSERT INTO `account_bans` (`account_id`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" << targetAccId << ", " << g_database.escapeString(reasonStr) << ", " << timeNow << ", " << (timeNow + timeBan) << ", " << player->getGUID() << ")";
		g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));

		player->sendTextMessage(MESSAGE_EVENT_ADVANCE, (targetPlayer ? targetPlayer->getName() : target) + " has been banned.");
		if (targetPlayer) {
			targetPlayer->kickPlayer(true);
		}
	}
}

void Game::playerProcessRuleViolation(Player* player, const std::string& target)
{
	if (!player->hasFlag(PlayerFlag_CanAnswerRuleViolations)) {
		return;
	}

	if (Player* reporter = getPlayerByName(target)) {
		auto it = ruleViolations.find(reporter->getName());
		if (it != ruleViolations.end() && it->second.gamemaster == 0) {
			it->second.gamemaster = player->getID();
			if (ChatChannel* channel = g_chat->getChannelById(3)) {
				const UsersMap& users = channel->getUsers();
				for (const auto& uit : users) {
					uit.second->sendRuleViolationRemove(reporter->getName());
				}
			}
		}
	}
}

void Game::playerCloseRuleViolation(Player* player, const std::string& target)
{
	if (!player->hasFlag(PlayerFlag_CanAnswerRuleViolations)) {
		return;
	}

	if (Player* reporter = getPlayerByName(target)) {
		auto it = ruleViolations.find(reporter->getName());
		if (it != ruleViolations.end()) {
			reporter->sendRuleViolationLock();
			if (ChatChannel* channel = g_chat->getChannelById(3)) {
				const UsersMap& users = channel->getUsers();
				for (const auto& uit : users) {
					uit.second->sendRuleViolationRemove(reporter->getName());
				}
			}
			ruleViolations.erase(it);
		}
	}
}

void Game::playerCancelRuleViolation(Player* player)
{
	auto it = ruleViolations.find(player->getName());
	if (it != ruleViolations.end()) {
		if (Player* gamemaster = getPlayerByID(it->second.gamemaster)) {
			gamemaster->sendRuleViolationCancel(player->getName());
		} else if (ChatChannel* channel = g_chat->getChannelById(3)) {
			const UsersMap& users = channel->getUsers();
			for (const auto& uit : users) {
				uit.second->sendRuleViolationRemove(player->getName());
			}
		}
		ruleViolations.erase(it);
	}
}

void Game::playerReportRuleViolation(Player* player, const std::string& text)
{
	playerCancelRuleViolation(player);
	ruleViolations.emplace(std::piecewise_construct, std::forward_as_tuple(player->getName()), std::forward_as_tuple(player, text, OTSYS_TIME()));

	if (ChatChannel* channel = g_chat->getChannelById(3)) {
		const UsersMap& users = channel->getUsers();
		for (const auto& uit : users) {
			uit.second->sendChannelMessage(player, text, TALKTYPE_RVR_CHANNEL, 0);
		}
	}
}

void Game::playerContinueReport(Player* player, const std::string& text)
{
	auto it = ruleViolations.find(player->getName());
	if (it != ruleViolations.end()) {
		if (Player* gamemaster = getPlayerByID(it->second.gamemaster)) {
			gamemaster->sendPrivateMessage(player, TALKTYPE_RVR_CONTINUE, text);
		}
	}
}

void Game::playerCheckRuleViolation(Player* player)
{
	playerCancelRuleViolation(player);
	if (player->hasFlag(PlayerFlag_CanAnswerRuleViolations)) {
		for (auto it = ruleViolations.begin(); it != ruleViolations.end(); ++it) {
			RuleViolation& rvr = it->second;
			if (rvr.gamemaster == player->getID()) {
				if (Player* owner = g_game.getPlayerByID(rvr.owner)) {
					owner->sendRuleViolationLock();
				}
				ruleViolations.erase(it);
				break;
			}
		}
	}
}
#endif

#if GAME_FEATURE_QUEST_TRACKER > 0
void Game::playerResetTrackedQuests(Player* player, std::vector<uint16_t>& quests)
{
	player->resetTrackedQuests(quests);
}
#endif

void Game::playerCloseNpcChannel(Player* player)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, player->getPosition());
	for (Creature* spectator : spectators) {
		if (Npc* npc = spectator->getNpc()) {
			npc->onPlayerCloseChannel(player);
		}
	}
}

void Game::playerReceivePing(Player* player)
{
	player->receivePing();
}

void Game::playerReceivePingBack(Player* player)
{
	player->sendPingBack();
}

void Game::playerAutoWalk(uint32_t playerId, std::vector<Direction>& listDir)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	player->resetIdleTime();
	player->stopNextWalkTask();
	player->stopNextWalkActionTask();
	player->startAutoWalk(std::move(listDir));
}

void Game::playerReceiveNewPing(uint32_t playerId, uint16_t ping, uint16_t fps)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	player->receivePing();
	player->setLocalPing(ping);
	player->setFPS(fps);
}

void Game::playerStopAutoWalk(Player* player)
{
	player->stopWalk();
}

void Game::playerUseItemEx(uint32_t playerId, const Position& fromPos, uint8_t fromStackPos, uint16_t fromSpriteId,
                           const Position& toPos, uint8_t toStackPos, uint16_t toSpriteId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	bool isHotkey = (fromPos.x == 0xFFFF && fromPos.y == 0 && fromPos.z == 0);
	if (isHotkey && !g_config.getBoolean(ConfigManager::AIMBOT_HOTKEY_ENABLED)) {
		return;
	}

	Thing* thing = internalGetThing(player, fromPos, fromStackPos, fromSpriteId, STACKPOS_USEITEM);
	if (!thing) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Item* item = thing->getItem();
	if (!item || !item->isUseable() || item->getClientID() != fromSpriteId) {
		player->sendCancelMessage(RETURNVALUE_CANNOTUSETHISOBJECT);
		return;
	}

	Position walkToPos = fromPos;
	ReturnValue ret = g_actions->canUse(player, fromPos);
	if (ret == RETURNVALUE_NOERROR) {
		ret = g_actions->canUse(player, toPos, item);
		if (ret == RETURNVALUE_TOOFARAWAY) {
			walkToPos = toPos;
		}
	}

	if (ret != RETURNVALUE_NOERROR) {
		if (ret == RETURNVALUE_TOOFARAWAY) {
			Position itemPos = fromPos;
			uint8_t itemStackPos = fromStackPos;

			if (fromPos.x != 0xFFFF && toPos.x != 0xFFFF && Position::areInRange<1, 1, 0>(fromPos, player->getPosition()) &&
			        !Position::areInRange<1, 1, 0>(fromPos, toPos)) {
				Item* moveItem = nullptr;

				ret = internalMoveItem(item->getParent(), player, INDEX_WHEREEVER, item, item->getItemCount(), &moveItem);
				if (ret != RETURNVALUE_NOERROR) {
					player->sendCancelMessage(ret);
					return;
				}

				//changing the position since its now in the inventory of the player
				internalGetPosition(moveItem, itemPos, itemStackPos);
			}

			std::vector<Direction> listDir;
			if (player->getPathTo(walkToPos, listDir, 0, 1, true, false)) {
				g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
				player->setNextWalkActionTask(400, std::bind(&Game::playerUseItemEx, this, playerId, itemPos, itemStackPos, fromSpriteId, toPos, toStackPos, toSpriteId));
			} else {
				player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
			}
			return;
		}

		player->sendCancelMessage(ret);
		return;
	}

	if (!player->canDoAction()) {
		uint32_t delay = player->getNextActionTime();
		player->setNextActionTask(delay, std::bind(&Game::playerUseItemEx, this, playerId, fromPos, fromStackPos, fromSpriteId, toPos, toStackPos, toSpriteId));
		return;
	}

	player->resetIdleTime();
	player->stopNextActionTask();

	g_actions->useItemEx(player, fromPos, toPos, toStackPos, item, isHotkey);
}

void Game::playerUseItem(uint32_t playerId, const Position& pos, uint8_t stackPos,
                         uint8_t index, uint16_t spriteId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	bool isHotkey = (pos.x == 0xFFFF && pos.y == 0 && pos.z == 0);
	if (isHotkey && !g_config.getBoolean(ConfigManager::AIMBOT_HOTKEY_ENABLED)) {
		return;
	}

	Thing* thing = internalGetThing(player, pos, stackPos, spriteId, STACKPOS_USEITEM);
	if (!thing) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Item* item = thing->getItem();
	if (!item || item->isUseable() || item->getClientID() != spriteId) {
		player->sendCancelMessage(RETURNVALUE_CANNOTUSETHISOBJECT);
		return;
	}

	ReturnValue ret = g_actions->canUse(player, pos);
	if (ret != RETURNVALUE_NOERROR) {
		if (ret == RETURNVALUE_TOOFARAWAY) {
			std::vector<Direction> listDir;
			if (player->getPathTo(pos, listDir, 0, 1, true, false)) {
				g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
				player->setNextWalkActionTask(400, std::bind(&Game::playerUseItem, this, playerId, pos, stackPos, index, spriteId));
				return;
			}

			ret = RETURNVALUE_THEREISNOWAY;
		}

		player->sendCancelMessage(ret);
		return;
	}

	if (!player->canDoAction()) {
		uint32_t delay = player->getNextActionTime();
		player->setNextActionTask(delay, std::bind(&Game::playerUseItem, this, playerId, pos, stackPos, index, spriteId));
		return;
	}

	player->resetIdleTime();
	player->stopNextActionTask();

	g_actions->useItem(player, pos, index, item, isHotkey);
}

void Game::playerUseWithCreature(uint32_t playerId, const Position& fromPos, uint8_t fromStackPos, uint32_t creatureId, uint16_t spriteId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	if (!Position::areInRange<7, 5, 0>(creature->getPosition(), player->getPosition())) {
		return;
	}

	bool isHotkey = (fromPos.x == 0xFFFF && fromPos.y == 0 && fromPos.z == 0);
	if (!g_config.getBoolean(ConfigManager::AIMBOT_HOTKEY_ENABLED)) {
		if (creature->getPlayer() || isHotkey) {
			player->sendCancelMessage(RETURNVALUE_DIRECTPLAYERSHOOT);
			return;
		}
	}

	Thing* thing = internalGetThing(player, fromPos, fromStackPos, spriteId, STACKPOS_USEITEM);
	if (!thing) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Item* item = thing->getItem();
	if (!item || !item->isUseable() || item->getClientID() != spriteId) {
		player->sendCancelMessage(RETURNVALUE_CANNOTUSETHISOBJECT);
		return;
	}

	Position toPos = creature->getPosition();
	Position walkToPos = fromPos;
	ReturnValue ret = g_actions->canUse(player, fromPos);
	if (ret == RETURNVALUE_NOERROR) {
		ret = g_actions->canUse(player, toPos, item);
		if (ret == RETURNVALUE_TOOFARAWAY) {
			walkToPos = toPos;
		}
	}

	if (ret != RETURNVALUE_NOERROR) {
		if (ret == RETURNVALUE_TOOFARAWAY) {
			Position itemPos = fromPos;
			uint8_t itemStackPos = fromStackPos;

			if (fromPos.x != 0xFFFF && Position::areInRange<1, 1, 0>(fromPos, player->getPosition()) && !Position::areInRange<1, 1, 0>(fromPos, toPos)) {
				Item* moveItem = nullptr;
				ret = internalMoveItem(item->getParent(), player, INDEX_WHEREEVER, item, item->getItemCount(), &moveItem);
				if (ret != RETURNVALUE_NOERROR) {
					player->sendCancelMessage(ret);
					return;
				}

				//changing the position since its now in the inventory of the player
				internalGetPosition(moveItem, itemPos, itemStackPos);
			}

			std::vector<Direction> listDir;
			if (player->getPathTo(walkToPos, listDir, 0, 1, true, false)) {
				g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
				player->setNextWalkActionTask(400, std::bind(&Game::playerUseWithCreature, this, playerId, itemPos, itemStackPos, creatureId, spriteId));
			} else {
				player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
			}
			return;
		}

		player->sendCancelMessage(ret);
		return;
	}

	if (!player->canDoAction()) {
		uint32_t delay = player->getNextActionTime();
		player->setNextActionTask(delay, std::bind(&Game::playerUseWithCreature, this, playerId, fromPos, fromStackPos, creatureId, spriteId));
		return;
	}

	player->resetIdleTime();
	player->stopNextActionTask();

	g_actions->useItemEx(player, fromPos, creature->getPosition(), creature->getParent()->getThingIndex(creature), item, isHotkey, creature);
}

void Game::playerCloseContainer(Player* player, uint8_t cid)
{
	player->closeContainer(cid);
	player->sendCloseContainer(cid);
}

void Game::playerMoveUpContainer(Player* player, uint8_t cid)
{
	Container* container = player->getContainerByID(cid);
	if (!container) {
		return;
	}

	Container* parentContainer = dynamic_cast<Container*>(container->getRealParent());
	if (!parentContainer) {
		#if GAME_FEATURE_BROWSEFIELD > 0
		Tile* tile = container->getTile();
		if (!tile) {
			return;
		}

		auto it = browseFields.find(tile);
		if (it == browseFields.end()) {
			parentContainer = new Container(tile);
			parentContainer->incrementReferenceCounter();
			browseFields[tile] = parentContainer;
			g_dispatcher.addEvent(30000, std::bind(&Game::decreaseBrowseFieldRef, this, tile->getPosition()));
		} else {
			parentContainer = it->second;
		}
		#else
		return;
		#endif
	}

	int8_t test_cid = player->getContainerID(parentContainer);
	if (test_cid != -1) {
		player->closeContainer(test_cid);
		player->sendCloseContainer(test_cid);
		return;
	}
	
	player->addContainer(cid, parentContainer);
	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	player->sendContainer(cid, parentContainer, parentContainer->hasParent(), player->getContainerIndex(cid));
	#else
	player->sendContainer(cid, parentContainer, parentContainer->hasParent());
	#endif
}

void Game::playerUpdateContainer(Player* player, uint8_t cid)
{
	Container* container = player->getContainerByID(cid);
	if (!container) {
		return;
	}

	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	player->sendContainer(cid, container, container->hasParent(), player->getContainerIndex(cid));
	#else
	player->sendContainer(cid, container, container->hasParent());
	#endif
}

void Game::playerRotateItem(uint32_t playerId, const Position& pos, uint8_t stackPos, const uint16_t spriteId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	Thing* thing = internalGetThing(player, pos, stackPos, 0, STACKPOS_TOPDOWN_ITEM);
	if (!thing) {
		return;
	}

	Item* item = thing->getItem();
	if (!item || item->getClientID() != spriteId || !item->isRotatable() || item->hasAttribute(ITEM_ATTRIBUTE_UNIQUEID)) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	if (pos.x != 0xFFFF && !Position::areInRange<1, 1, 0>(pos, player->getPosition())) {
		std::vector<Direction> listDir;
		if (player->getPathTo(pos, listDir, 0, 1, true, false)) {
			g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
			player->setNextWalkActionTask(400, std::bind(&Game::playerRotateItem, this, playerId, pos, stackPos, spriteId));
		} else {
			player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
		}
		return;
	}

	uint16_t newId = Item::items[item->getID()].rotateTo;
	if (newId != 0) {
		transformItem(item, newId);
	}
}

#if CLIENT_VERSION >= 1092
void Game::playerWrapableItem(uint32_t playerId, const Position& pos, uint8_t stackPos, const uint16_t spriteId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	Thing* thing = internalGetThing(player, pos, stackPos, 0, STACKPOS_TOPDOWN_ITEM);
	if (!thing) {
		return;
	}

	Item* item = thing->getItem();
	if (!item || item->getClientID() != spriteId || (!item->isWrapable() && item->getID() != ITEM_DECORATION_KIT) || item->hasAttribute(ITEM_ATTRIBUTE_UNIQUEID)) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Tile* tile = map.getTile(pos);
	if (!tile) {
		player->sendCancelMessage("Put the construction kit on the floor first.");
		return;
	}

	HouseTile* houseTile = dynamic_cast<HouseTile*>(tile);
	if (!houseTile || !houseTile->getHouse() || !houseTile->getHouse()->isInvited(player)) {
		player->sendCancelMessage("You may construct this only inside a house.");
		return;
	}

	if (pos.x != 0xFFFF && !Position::areInRange<1, 1, 0>(pos, player->getPosition())) {
		std::vector<Direction> listDir;
		if (player->getPathTo(pos, listDir, 0, 1, true, false)) {
			g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
			player->setNextWalkActionTask(400, std::bind(&Game::playerWrapableItem, this, playerId, pos, stackPos, spriteId));
		} else {
			player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
		}
		return;
	}

	const Container* container = item->getContainer();
	if (container && !container->empty()) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	uint16_t itemId = item->getID();
	uint16_t newId = Item::items[itemId].wrapableTo;
	std::string itemName = item->getName();
	if (newId != 0 && itemId != ITEM_DECORATION_KIT) {
		uint16_t charges = item->getSubType();
		Item* newItem = transformItem(item, newId);
		if (newItem) {
			if (internalMoveItem(newItem->getParent(), player, INDEX_WHEREEVER, newItem, newItem->getItemCount(), nullptr) == RETURNVALUE_NOERROR) {
				newItem->setActionId(itemId);
				newItem->setDate(charges);
				newItem->setSpecialDescription("Unwrap it in your own house to create a " + itemName + ".");
				addMagicEffect(pos, CONST_ME_POFF);
				newItem->startDecaying();
			} else {
				player->sendCancelMessage("Make sure you have enough space in your backpack.");
				transformItem(newItem, itemId);
			}
		}
	} else if (newId == 0 && item->getActionId() != 0) {
		uint16_t charges = static_cast<uint16_t>(item->getDate());
		newId = item->getActionId();
		Item* newItem = transformItem(item, newId);
		if (newItem) {
			if (charges > 0) {
				newItem->setSubType(charges);
			}
			newItem->removeAttribute(ITEM_ATTRIBUTE_ACTIONID);
			newItem->removeAttribute(ITEM_ATTRIBUTE_DATE);
			newItem->removeAttribute(ITEM_ATTRIBUTE_DESCRIPTION);
			addMagicEffect(pos, CONST_ME_POFF);
			newItem->startDecaying();
		}
	}
}
#endif

void Game::playerWriteItem(Player* player, uint32_t windowTextId, const std::string& text)
{
	uint16_t maxTextLength = 0;
	uint32_t internalWindowTextId = 0;

	Item* writeItem = player->getWriteItem(internalWindowTextId, maxTextLength);
	if (text.length() > maxTextLength || windowTextId != internalWindowTextId) {
		return;
	}

	if (!writeItem || writeItem->isRemoved()) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Cylinder* topParent = writeItem->getTopParent();

	Player* owner = dynamic_cast<Player*>(topParent);
	if (owner && owner != player) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	if (!Position::areInRange<1, 1, 0>(writeItem->getPosition(), player->getPosition())) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	for (auto creatureEvent : player->getCreatureEvents(CREATURE_EVENT_TEXTEDIT)) {
		if (!creatureEvent->executeTextEdit(player, writeItem, text)) {
			player->setWriteItem(nullptr);
			return;
		}
	}

	if (!text.empty()) {
		if (writeItem->getText() != text) {
			writeItem->setText(text);
			writeItem->setWriter(player->getName());
			writeItem->setDate(time(nullptr));
		}
	} else {
		writeItem->resetText();
		writeItem->resetWriter();
		writeItem->resetDate();
	}

	uint16_t newId = Item::items[writeItem->getID()].writeOnceItemId;
	if (newId != 0) {
		transformItem(writeItem, newId);
	}

	player->setWriteItem(nullptr);
}

#if GAME_FEATURE_BROWSEFIELD > 0
void Game::playerBrowseField(uint32_t playerId, const Position& pos)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	const Position& playerPos = player->getPosition();
	if (playerPos.z != pos.z) {
		player->sendCancelMessage(playerPos.z > pos.z ? RETURNVALUE_FIRSTGOUPSTAIRS : RETURNVALUE_FIRSTGODOWNSTAIRS);
		return;
	}

	if (!Position::areInRange<1, 1>(playerPos, pos)) {
		std::vector<Direction> listDir;
		if (player->getPathTo(pos, listDir, 0, 1, true, false)) {
			g_dispatcher.addTask(std::bind(&Game::playerAutoWalk, this, player->getID(), std::move(listDir)));
			player->setNextWalkActionTask(400, std::bind(&Game::playerBrowseField, this, playerId, pos));
		} else {
			player->sendCancelMessage(RETURNVALUE_THEREISNOWAY);
		}
		return;
	}

	Tile* tile = map.getTile(pos);
	if (!tile) {
		return;
	}

	if (!g_events->eventPlayerOnBrowseField(player, pos)) {
		return;
	}

	Container* container;

	auto it = browseFields.find(tile);
	if (it == browseFields.end()) {
		container = new Container(tile);
		container->incrementReferenceCounter();
		browseFields[tile] = container;
		g_dispatcher.addEvent(30000, std::bind(&Game::decreaseBrowseFieldRef, this, tile->getPosition()));
	} else {
		container = it->second;
	}

	uint8_t dummyContainerId = 0xF - ((pos.x % 3) * 3 + (pos.y % 3));
	Container* openContainer = player->getContainerByID(dummyContainerId);
	if (openContainer) {
		player->onCloseContainer(openContainer);
		player->closeContainer(dummyContainerId);
	} else {
		player->addContainer(dummyContainerId, container);
		player->sendContainer(dummyContainerId, container, false, 0);
	}
}
#endif

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void Game::playerSeekInContainer(Player* player, uint8_t containerId, uint16_t index)
{
	Container* container = player->getContainerByID(containerId);
	if (!container || !container->hasPagination()) {
		return;
	}

	if ((index % container->capacity()) != 0 || index >= container->size()) {
		return;
	}

	player->setContainerIndex(containerId, index);
	player->sendContainer(containerId, container, container->hasParent(), index);
}
#endif


void Game::playerSortContainer(Player* player, uint8_t containerId, uint8_t sortIndex, const std::string& name)
{
	Container* container = player->getContainerByID(containerId);
	if (!container) {
		return;
	}


	switch (sortIndex) {
		case 1:
			container->sortByCount(true, name);
			break;
		case 2:
			container->sortByCount(false, name);
			break;
		case 3:
			container->sortByRarity(true, name);
			break;	
		case 4:
			container->sortByRarity(false, name);
			break;
	}

	player->sendContainer(containerId, container, container->hasParent(), player->getContainerIndex(containerId));
}


#if GAME_FEATURE_INSPECTION > 0
void Game::playerInspectItem(Player* player, const Position& pos)
{
	Thing* thing = internalGetThing(player, pos, 0, 0, STACKPOS_TOPDOWN_ITEM);
	if (!thing) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Item* item = thing->getItem();
	if (!item) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	player->sendItemInspection(item->getClientID(), item->getItemCount(), item, false);
}

void Game::playerInspectItem(Player* player, uint16_t itemId, uint8_t itemCount, bool cyclopedia)
{
	player->sendItemInspection(itemId, itemCount, nullptr, cyclopedia);
}
#endif

void Game::playerUpdateHouseWindow(Player* player, uint8_t listId, uint32_t windowTextId, const std::string& text)
{
	uint32_t internalWindowTextId;
	uint32_t internalListId;

	House* house = player->getEditHouse(internalWindowTextId, internalListId);
	if (house && house->canEditAccessList(internalListId, player) && internalWindowTextId == windowTextId && listId == 0) {
		house->setAccessList(internalListId, text);
	}

	player->setEditHouse(nullptr);
}

void Game::playerPurchaseItem(Player* player, uint16_t spriteId, uint8_t count, uint8_t amount,
                              bool ignoreCap/* = false*/, bool inBackpacks/* = false*/)
{
	int32_t onBuy, onSell;

	Npc* merchant = player->getShopOwner(onBuy, onSell);
	if (!merchant) {
		return;
	}

	const ItemType& it = Item::items.getItemIdByClientId(spriteId);
	if (it.id == 0) {
		return;
	}

	uint8_t subType;
	if (it.isSplash() || it.isFluidContainer()) {
		subType = clientFluidToServer(count);
	} else {
		subType = count;
	}

	if (!player->hasShopItemForSale(it.id, subType)) {
		return;
	}

	merchant->onPlayerTrade(player, onBuy, it.id, subType, amount, ignoreCap, inBackpacks);
}

void Game::playerSellItem(Player* player, uint16_t spriteId, uint8_t count, uint8_t amount, uint64_t realUID, bool ignoreEquipped)
{
	int32_t onBuy, onSell;

	Npc* merchant = player->getShopOwner(onBuy, onSell);
	if (!merchant) {
		return;
	}

	const ItemType& it = Item::items.getItemIdByClientId(spriteId);
	if (it.id == 0) {
		return;
	}

	uint8_t subType;
	if (it.isSplash() || it.isFluidContainer()) {
		subType = clientFluidToServer(count);
	} else {
		subType = count;
	}

	merchant->onPlayerTrade(player, onSell, it.id, subType, amount, realUID, ignoreEquipped);
}

void Game::playerSellItems(Player* player, std::vector<uint64_t> items)
{
	int32_t onBuy, onSell;

	Npc* merchant = player->getShopOwner(onBuy, onSell);
	if (!merchant) {
		return;
	}

	merchant->onPlayerSellMultiple(player, onSell, items);
}

void Game::playerCloseShop(Player* player)
{
	player->closeShopWindow();
}

void Game::playerLookInShop(Player* player, uint16_t spriteId, uint8_t count)
{
	int32_t onBuy, onSell;

	Npc* merchant = player->getShopOwner(onBuy, onSell);
	if (!merchant) {
		return;
	}

	const ItemType& it = Item::items.getItemIdByClientId(spriteId);
	if (it.id == 0) {
		return;
	}

	int32_t subType;
	if (it.isFluidContainer() || it.isSplash()) {
		subType = clientFluidToServer(count);
	} else {
		subType = count;
	}

	if (!player->hasShopItemForSale(it.id, subType)) {
		return;
	}

	if (!g_events->eventPlayerOnLookInShop(player, &it, subType)) {
		return;
	}

	std::string str, description = Item::getDescription(it, 1, nullptr, subType);
	str.reserve(description.length() + static_cast<size_t>(10));
	str.append("You see ").append(description);
	
	player->sendTextMessage(MESSAGE_INFO_DESCR, str);
}

void Game::playerLookAt(Player* player, const Position& pos, uint8_t stackPos)
{
	Thing* thing = internalGetThing(player, pos, stackPos, 0, STACKPOS_LOOK);
	if (!thing) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Position thingPos = thing->getPosition();
	if (!player->canSee(thingPos)) {
		player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
		return;
	}

	Position playerPos = player->getPosition();

	int32_t lookDistance;
	if (thing != player) {
		lookDistance = std::max<int32_t>(Position::getDistanceX(playerPos, thingPos), Position::getDistanceY(playerPos, thingPos));
		if (playerPos.z != thingPos.z) {
			lookDistance += 15;
		}
	} else {
		lookDistance = -1;
	}

	g_events->eventPlayerOnLook(player, pos, thing, stackPos, lookDistance);
}

void Game::playerLookInBattleList(Player* player, uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	if (!player->canSeeCreature(creature)) {
		return;
	}

	const Position& creaturePos = creature->getPosition();
	if (!player->canSee(creaturePos)) {
		return;
	}

	int32_t lookDistance;
	if (creature != player) {
		const Position& playerPos = player->getPosition();
		lookDistance = std::max<int32_t>(Position::getDistanceX(playerPos, creaturePos), Position::getDistanceY(playerPos, creaturePos));
		if (playerPos.z != creaturePos.z) {
			lookDistance += 15;
		}
	} else {
		lookDistance = -1;
	}

	g_events->eventPlayerOnLookInBattleList(player, creature, lookDistance);
}

void Game::playerCancelAttackAndFollow(uint32_t playerId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	playerSetAttackedCreature(playerId, 0);
	playerFollowCreature(playerId, 0);
	player->stopWalk();
}

void Game::playerSetAttackedCreature(uint32_t playerId, uint32_t creatureId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	if (player->getAttackedCreature() && creatureId == 0) {
		player->setAttackedCreature(nullptr);
		player->sendCancelTarget();
		return;
	}

	Creature* attackCreature = getCreatureByID(creatureId);
	if (!attackCreature) {
		player->setAttackedCreature(nullptr);
		player->sendCancelTarget();
		return;
	}

	ReturnValue ret = Combat::canTargetCreature(player, attackCreature);
	if (ret != RETURNVALUE_NOERROR) {
		player->sendCancelMessage(ret);
		player->sendCancelTarget();
		player->setAttackedCreature(nullptr);
		return;
	}

	attackCreature->addTargetingPlayer(player);
	Creature* lastAttackedCreature = player->getAttackedCreature();
	if (lastAttackedCreature && !lastAttackedCreature->isRemoved()) {
		lastAttackedCreature->removeTargetingPlayer(player);
	}
	player->setAttackedCreature(attackCreature);
}

void Game::playerFollowCreature(uint32_t playerId, uint32_t creatureId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	player->setAttackedCreature(nullptr);
	player->setFollowCreature(getCreatureByID(creatureId));
}

void Game::playerSetFightModes(Player* player, fightMode_t fightMode, bool chaseMode, bool secureMode)
{
	player->setFightMode(fightMode);
	player->setChaseMode(chaseMode);
	player->setSecureMode(secureMode);
}

void Game::playerRequestAddVip(Player* player, const std::string& name)
{
	Player* vipPlayer = getPlayerByName(name);
	if (!vipPlayer) {
		uint32_t guid;
		bool specialVip;
		std::string formattedName = name;
		if (!IOLoginData::getGuidByNameEx(guid, specialVip, formattedName)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "A player with this name does not exist.");
			return;
		}

		if (specialVip && !player->hasFlag(PlayerFlag_SpecialVIP)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You can not add this player.");
			return;
		}

		player->addVIP(guid, formattedName, VIPSTATUS_OFFLINE);
	} else {
		if (vipPlayer->hasFlag(PlayerFlag_SpecialVIP) && !player->hasFlag(PlayerFlag_SpecialVIP)) {
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You can not add this player.");
			return;
		}

		if (!vipPlayer->isInGhostMode() || player->isAccessPlayer()) {
			player->addVIP(vipPlayer->getGUID(), vipPlayer->getName(), VIPSTATUS_ONLINE);
		} else {
			player->addVIP(vipPlayer->getGUID(), vipPlayer->getName(), VIPSTATUS_OFFLINE);
		}
	}
}

void Game::playerRequestRemoveVip(Player* player, uint32_t guid)
{
	player->removeVIP(guid);
}

void Game::playerRequestEditVip(Player* player, uint32_t guid, const std::string& description, uint32_t icon, bool notify)
{
	player->editVIP(guid, description, icon, notify);
}

void Game::playerTurn(Player* player, Direction dir)
{
	if (!g_events->eventPlayerOnTurn(player, dir)) {
		return;
	}

	player->resetIdleTime();
	internalCreatureTurn(player, dir);
}

void Game::playerRequestOutfit(Player* player)
{
	if (!g_config.getBoolean(ConfigManager::ALLOW_CHANGEOUTFIT)) {
		return;
	}
	
	player->sendOutfitWindow();
}

#if GAME_FEATURE_MOUNTS > 0
//void Game::playerToggleMount(Player* player, bool mount)
//void Game::playerToggleMount(uint32_t playerId, bool mount)		wingJEDEN
void Game::playerToggleOutfitExtension(Player* player, int mount)
{
	//player->toggleMount(mount);
	if(mount != -1)
		player->toggleMount(mount == 1);
}
#endif

void Game::playerChangeOutfit(Player* player, Outfit_t outfit)
{
	if (!g_config.getBoolean(ConfigManager::ALLOW_CHANGEOUTFIT)) {
		return;
	}
	
	#if GAME_FEATURE_MOUNTS > 0
	const Outfit* playerOutfit = Outfits::getInstance().getOutfitByLookType(player->getSex(), outfit.lookType);
	if (!playerOutfit) {
		outfit.lookType = player->getSex() == PLAYERSEX_FEMALE ? 136 : 128;
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have this outfit.");
	}

	if (outfit.lookWings != 0) {
		Wing* wing = wings.getWingByID(outfit.lookWings);
		if (!wing || !player->hasWing(wing)) {
			outfit.lookWings = 0;
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have these wings.");
		}
	}

	if (outfit.lookAura != 0) {
		Aura* aura =
		 auras.getAuraByID(outfit.lookAura);
		if (!aura || !player->hasAura(aura)) {
			outfit.lookAura = 0;
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have this aura.");
		}
	}

	if (outfit.lookShader != "") {
		Shader* shader = shaders.getShaderByName(outfit.lookShader);
		if (!shader || !player->hasShader(shader)) {
			outfit.lookShader = "";
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have this shader.");
		}
	}

	if (outfit.lookOutline != "") {
		Outline* outline = outlines.getOutlineByName(outfit.lookOutline);
		if (!outline || !player->hasOutline(outline)) {
			outfit.lookOutline = "";
			player->sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have this outline.");
		}
	}

	if (outfit.lookMount != 0) {
		Mount* mount = mounts.getMountByClientID(outfit.lookMount);
		if (!mount) {
			return;
		}

		if (!player->hasMount(mount)) {
			return;
		}

		if (player->isMounted()) {
			Mount* prevMount = mounts.getMountByID(player->getCurrentMount());
			if (prevMount) {
				changeSpeed(player, mount->speed - prevMount->speed);
			}

			player->setCurrentMount(mount->id);
		} else {
			player->setCurrentMount(mount->id);
			outfit.lookMount = 0;
		}
	} else if (player->isMounted()) {
		player->dismount();
	}
	#endif

	if (player->canWear(outfit.lookType, outfit.lookAddons)) {
		player->defaultOutfit = outfit;

		if (player->hasCondition(CONDITION_OUTFIT)) {
			return;
		}

		internalCreatureChangeOutfit(player, outfit);
	}
}

void Game::playerShowQuestLog(Player* player)
{
	player->sendQuestLog();
}

void Game::playerShowQuestLine(Player* player, uint16_t questId)
{
	Quest* quest = quests.getQuestByID(questId);
	if (!quest) {
		return;
	}

	player->sendQuestLine(quest);
}

void Game::playerSay(Player* player, uint16_t channelId, SpeakClasses type,
                     const std::string& receiver, const std::string& text)
{
    player->addInfoLog("[SAY][CID: " + std::to_string(channelId) +
	"][TYPE: " + std::to_string(static_cast<int>(type)) +
	"][REC: " + receiver + "] " + text);
	player->resetIdleTime();
	if (playerSaySpell(player, type, text)) {
		return;
	}

	uint32_t muteTime = player->isMuted();
	if (muteTime > 0) {
		std::stringExtended ss(64);
		ss << "You are still ";
	if (player->hasCondition(CONDITION_STUN)) {
		ss << "stunned";
	} else {
		ss << "muted";
	}
		ss << " for " << muteTime << " seconds.";
		player->sendTextMessage(MESSAGE_STATUS_SMALL, ss);
		return;
	}

	if (text.front() == '/' && player->isAccessPlayer()) {
		return;
	}

	if (type != TALKTYPE_PRIVATE_PN) {
		player->removeMessageBuffer();
	}

	if (text.find("otclientbot") != std::string::npos) {
		return;
	}

	if (text.find("bot.com") != std::string::npos) {
		return;
	}

	if (text.find("bot . com") != std::string::npos) {
		return;
	}

	if (text.find("https://otclient") != std::string::npos) {
		return;
	}

	switch (type) {
		case TALKTYPE_SAY:
			internalCreatureSay(player, TALKTYPE_SAY, text, false);
			break;

		case TALKTYPE_WHISPER:
			playerWhisper(player, text);
			break;

		case TALKTYPE_YELL:
			playerYell(player, text);
			break;

		case TALKTYPE_PRIVATE_TO:
		case TALKTYPE_PRIVATE_RED_TO:
		#if GAME_FEATURE_RULEVIOLATION > 0
		case TALKTYPE_RVR_ANSWER:
		#endif
			playerSpeakTo(player, type, receiver, text);
			break;

		case TALKTYPE_CHANNEL_O:
		case TALKTYPE_CHANNEL_Y:
		case TALKTYPE_CHANNEL_R1:
			g_chat->talkToChannel(*player, type, text, channelId);
			break;

		case TALKTYPE_PRIVATE_PN:
			playerSpeakToNpc(player, text);
			break;

		case TALKTYPE_BROADCAST:
			playerBroadcastMessage(player, text);
			break;

		#if GAME_FEATURE_RULEVIOLATION > 0
		case TALKTYPE_RVR_CHANNEL:
			playerReportRuleViolation(player, text);
			break;

		case TALKTYPE_RVR_CONTINUE:
			playerContinueReport(player, text);
			break;
		#endif

		default:
			break;
	}
}

bool Game::playerSaySpell(Player* player, SpeakClasses type, const std::string& text)
{
	std::string words = text;
	const std::string& lowerWords = asLowerCaseString(words);

	TalkActionResult_t result;
	if (text.front() == '/' || text.front() == '!') {
		result = g_talkActions->playerSaySpell(player, type, words);
		if (result == TALKACTION_BREAK) {
			return true;
		}
	}

	if (player->hasCondition(CONDITION_MUTED)) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "You are silenced.");
		return false;
	}
	result = g_spells->playerSaySpell(player, words, lowerWords);
	if (result == TALKACTION_BREAK) {
		if (!g_config.getBoolean(ConfigManager::EMOTE_SPELLS)) {
			return internalCreatureSay(player, TALKTYPE_SPELL, words, false);
		} else {
			return internalCreatureSay(player, TALKTYPE_MONSTER_SAY, words, false);
		}
	} else if (result == TALKACTION_FAILED) {
		return true;
	}
	return false;
}

void Game::playerWhisper(Player* player, const std::string& text)
{
	SpectatorVector spectators;
	const Position& pos = player->getPosition();
	map.getSpectatorsInternal(spectators, pos, Map::maxClientViewportX, Map::maxClientViewportX,
			Map::maxClientViewportY, Map::maxClientViewportY, pos.z, pos.z, false);

	//send to client + event method
	for (Creature* spectator : spectators) {
		if (Player* spectatorPlayer = spectator->getPlayer()) {
			if (!Position::areInRange<1, 1>(player->getPosition(), spectatorPlayer->getPosition())) {
				spectatorPlayer->sendCreatureSay(player, TALKTYPE_WHISPER, "pspsps");
			} else {
				spectatorPlayer->sendCreatureSay(player, TALKTYPE_WHISPER, text);
			}
		}
	
		spectator->onCreatureSay(player, TALKTYPE_WHISPER, text);
	}
}

bool Game::playerYell(Player* player, const std::string& text)
{
	if (player->getLevel() == 1) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "You may not yell as long as you are on level 1.");
		return false;
	}

	if (player->hasCondition(CONDITION_YELLTICKS)) {
		player->sendCancelMessage(RETURNVALUE_YOUAREEXHAUSTED);
		return false;
	}

	if (player->getAccountType() < ACCOUNT_TYPE_GAMEMASTER) {
		Condition* condition = Condition::createCondition(CONDITIONID_DEFAULT, CONDITION_YELLTICKS, 30000, 0);
		player->addCondition(condition);
	}

	internalCreatureSay(player, TALKTYPE_YELL, asUpperCaseString(text), false);
	return true;
}

bool Game::playerSpeakTo(Player* player, SpeakClasses type, const std::string& receiver,
                         const std::string& text)
{
	Player* toPlayer = getPlayerByName(receiver);
	if (!toPlayer) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "A player with this name is not online.");
		return false;
	}

	if (type == TALKTYPE_PRIVATE_RED_TO && (player->hasFlag(PlayerFlag_CanTalkRedPrivate) || player->getAccountType() >= ACCOUNT_TYPE_GAMEMASTER)) {
		type = TALKTYPE_PRIVATE_RED_FROM;
	} else {
		#if GAME_FEATURE_RULEVIOLATION > 0
		if (type != TALKTYPE_RVR_ANSWER) {
			type = TALKTYPE_PRIVATE_FROM;
		}
		#else
		type = TALKTYPE_PRIVATE_FROM;
		#endif
	}

	toPlayer->sendPrivateMessage(player, type, text);
	toPlayer->onCreatureSay(player, type, text);

	if (toPlayer->isInGhostMode() && !player->isAccessPlayer()) {
		player->sendTextMessage(MESSAGE_STATUS_SMALL, "A player with this name is not online.");
	}
	return true;
}

void Game::playerSpeakToNpc(Player* player, const std::string& text)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, player->getPosition());
	for (Creature* spectator : spectators) {
		if (spectator->getNpc()) {
			spectator->onCreatureSay(player, TALKTYPE_PRIVATE_PN, text);
		}
	}
}

//--
bool Game::canThrowObjectTo(const Position& fromPos, const Position& toPos, SightLines_t lineOfSight /*= SightLine_CheckSightLine*/,
                            int32_t rangex /*= Map::maxClientViewportX*/, int32_t rangey /*= Map::maxClientViewportY*/) const
{
	return map.canThrowObjectTo(fromPos, toPos, lineOfSight, rangex, rangey);
}

bool Game::isSightClear(const Position& fromPos, const Position& toPos, bool floorCheck) const
{
	return map.isSightClear(fromPos, toPos, floorCheck);
}

bool Game::internalCreatureTurn(Creature* creature, Direction dir)
{
	if (creature->getDirection() == dir) {
		return false;
	}
	
	if (creature->hasCondition(CONDITION_STUN)) {
		return false;
	}

	if (creature->isInPlace()) {
		return false;
	}

	creature->setDirection(dir);

	//send to client
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendCreatureTurn(creature);
	}
	return true;
}

bool Game::internalCreatureSay(Creature* creature, SpeakClasses type, const std::string& text,
                               bool ghostMode, SpectatorVector* spectatorsPtr/* = nullptr*/, const Position* pos/* = nullptr*/)
{
	if (text.empty()) {
		return false;
	}

	if (!pos) {
		pos = &creature->getPosition();
	}

	SpectatorVector spectators;
	if (!spectatorsPtr || spectatorsPtr->empty()) {
		// This somewhat complex construct ensures that the cached SpectatorVector
		// is used if available and if it can be used, else a local vector is
		// used (hopefully the compiler will optimize away the construction of
		// the temporary when it's not used).
		if (type != TALKTYPE_YELL && type != TALKTYPE_MONSTER_YELL) {
			map.getSpectatorsInternal(spectators, *pos, Map::maxClientViewportX, Map::maxClientViewportX,
					Map::maxClientViewportY, Map::maxClientViewportY, pos->z, pos->z, false);
		} else {
			if (pos->z < 8) {
				map.getSpectatorsInternal(spectators, *pos, 18, 18, 14, 14, 0, 7, false);
			} else {
				map.getSpectatorsInternal(spectators, *pos, 18, 18, 14, 14, pos->z, pos->z, false);
			}
		}
	} else {
		spectators = std::move(*spectatorsPtr);
	}

	//send to client + event method
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			if (!ghostMode || tmpPlayer->canSeeCreature(creature)) {
				int32_t storage;
				tmpPlayer->getStorageValue(800001, storage);
				if (storage > 0 && type == 19) {
					continue;
				} else {
					tmpPlayer->sendCreatureSay(creature, type, text, pos);
				}
			}
		}
		spectator->onCreatureSay(creature, type, text);
	}
	return true;
}

void Game::checkCreatureWalk(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (creature && creature->getHealth() > 0) {
		creature->onWalk();
		cleanup();
	}
}

void Game::updateCreatureWalk(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (creature && creature->getHealth() > 0) {
		creature->goToFollowCreature();
	}
}

void Game::checkCreatureAttack(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (creature && creature->getHealth() > 0) {
		creature->onAttacking(0);
	}
}

void Game::checkCreatureFeared(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (creature && creature->getHealth() > 0 && creature->hasFear()) {
		creature->moveFeared();
	}
}

void Game::addCreatureCheck(Creature* creature)
{
	creature->creatureCheck = true;
	if (creature->inCheckCreaturesVector) {
		// already in a vector
		return;
	}

	creature->inCheckCreaturesVector = true;
	checkCreatureLists[uniform_random(0, EVENT_CREATURECOUNT - 1)].push_back(creature);
	creature->incrementReferenceCounter();
}

void Game::removeCreatureCheck(Creature* creature)
{
	if (creature->inCheckCreaturesVector) {
		creature->creatureCheck = false;
	}
}

void Game::checkCreatures(size_t index)
{
	g_dispatcher.addEvent(EVENT_CHECK_CREATURE_INTERVAL, std::bind(&Game::checkCreatures, this, (index + 1) % EVENT_CREATURECOUNT));

	auto& checkCreatureList = checkCreatureLists[index];
	size_t it = 0, end = checkCreatureList.size();
	while (it < end) {
		Creature* creature = checkCreatureList[it];
		if (creature->creatureCheck) {
			if (creature->getHealth() > 0) {
				creature->onThink(EVENT_CREATURE_THINK_INTERVAL);
				creature->onAttacking(EVENT_CREATURE_THINK_INTERVAL);
				creature->executeConditions(EVENT_CREATURE_THINK_INTERVAL);
			} else {
				creature->onDeath();
			}
			++it;
		} else {
			creature->inCheckCreaturesVector = false;
			ReleaseCreature(creature);

			checkCreatureList[it] = checkCreatureList.back();
			checkCreatureList.pop_back();
			--end;
		}
	}
	cleanup();
	#ifdef STATS_ENABLED
		g_stats.playersOnline = getPlayersOnline();
	#endif
}

void Game::changeSpeed(Creature* creature, int32_t varSpeedDelta)
{
	int32_t varSpeed = creature->getSpeed() - creature->getBaseSpeed();
	varSpeed += varSpeedDelta;

	creature->setSpeed(varSpeed);

	//send to clients
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), false, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendChangeSpeed(creature, creature->getStepSpeed());
	}
}

void Game::internalCreatureChangeOutfit(Creature* creature, const Outfit_t& outfit)
{
	if (!g_events->eventCreatureOnChangeOutfit(creature, outfit)) {
		return;
	}

	creature->setCurrentOutfit(outfit);

	if (creature->isInvisible()) {
		return;
	}

	//send to clients
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendCreatureChangeOutfit(creature, outfit);
	}
}

void Game::internalCreatureChangeVisible(Creature* creature, bool visible)
{
	//send to clients
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendCreatureChangeVisible(creature, visible);
	}
}

void Game::changeLight(const Creature* creature)
{
	//send to clients
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendCreatureLight(creature);
	}
}

bool Game::combatBlockHit(CombatDamage& damage, Creature* attacker, Creature* target, bool checkDefense, bool checkArmor, bool field)
{
	if (damage.primary.type == COMBAT_NONE && damage.secondary.type == COMBAT_NONE) {
		return true;
	}

	if (target->getPlayer() && target->isInGhostMode()) {
		return true;
	}

	if (damage.primary.value > 0) {
		return false;
	}

	static const auto sendBlockEffect = [this](BlockType_t blockType, CombatType_t combatType, const Position& targetPos) {
		if (blockType == BLOCK_DEFENSE) {
			addMagicEffect(targetPos, CONST_ME_POFF);
		} else if (blockType == BLOCK_ARMOR) {
			addMagicEffect(targetPos, CONST_ME_BLOCKHIT);
		} else if (blockType == BLOCK_IMMUNITY) {
			uint8_t hitEffect = 0;
			switch (combatType) {
				case COMBAT_UNDEFINEDDAMAGE: {
					return;
				}
				case COMBAT_ENERGYDAMAGE:
				case COMBAT_FIREDAMAGE:
				case COMBAT_PHYSICALDAMAGE:
				case COMBAT_ICEDAMAGE:
				case COMBAT_DEATHDAMAGE: {
					hitEffect = CONST_ME_BLOCKHIT;
					break;
				}
				case COMBAT_EARTHDAMAGE: {
					hitEffect = CONST_ME_GREEN_RINGS;
					break;
				}
				case COMBAT_HOLYDAMAGE: {
					hitEffect = CONST_ME_HOLYDAMAGE;
					break;
				}
				default: {
					hitEffect = CONST_ME_POFF;
					break;
				}
			}
			addMagicEffect(targetPos, hitEffect);
		}
	};

	BlockType_t primaryBlockType, secondaryBlockType;
	if (damage.primary.type != COMBAT_NONE) {
		damage.primary.value = -damage.primary.value;
		primaryBlockType = target->blockHit(attacker, damage.primary.type, damage.primary.value, checkDefense, checkArmor, field);

		damage.primary.value = -damage.primary.value;
		sendBlockEffect(primaryBlockType, damage.primary.type, target->getPosition());
	} else {
		primaryBlockType = BLOCK_NONE;
	}

	if (damage.secondary.type != COMBAT_NONE) {
		damage.secondary.value = -damage.secondary.value;
		secondaryBlockType = target->blockHit(attacker, damage.secondary.type, damage.secondary.value, false, false, field);

		damage.secondary.value = -damage.secondary.value;
		sendBlockEffect(secondaryBlockType, damage.secondary.type, target->getPosition());
	} else {
		secondaryBlockType = BLOCK_NONE;
	}
	
	damage.blockType = primaryBlockType;
	
	return (primaryBlockType != BLOCK_NONE) && (secondaryBlockType != BLOCK_NONE);
}

void Game::combatGetTypeInfo(CombatType_t combatType, Creature* target, TextColor_t& color, uint8_t& effect)
{
	switch (combatType) {
		case COMBAT_PHYSICALDAMAGE: {
			Item* splash = nullptr;
			switch (target->getRace()) {
				case RACE_VENOM:
					color = TEXTCOLOR_RED;
					effect = CONST_ME_NONE;
					splash = Item::CreateItem(ITEM_SMALLSPLASH, FLUID_SLIME);
					break;
				case RACE_BLOOD:
					color = TEXTCOLOR_RED;
					effect = CONST_ME_NONE;
					if (const Tile* tile = target->getTile()) {
						if (!tile->hasFlag(TILESTATE_PROTECTIONZONE)) {
							splash = Item::CreateItem(ITEM_SMALLSPLASH, FLUID_BLOOD);
						}
					}
					break;
				case RACE_UNDEAD:
					color = TEXTCOLOR_RED;
					effect = CONST_ME_NONE;
					break;
				case RACE_FIRE:
					color = TEXTCOLOR_RED;
					effect = CONST_ME_NONE;
					break;
				case RACE_ENERGY:
					color = TEXTCOLOR_RED;
					effect = CONST_ME_NONE;
					break;
				case RACE_BOSS:
					color = TEXTCOLOR_RED;
					effect = CONST_ME_NONE;
					break;
				default:
					color = TEXTCOLOR_NONE;
					effect = CONST_ME_NONE;
					break;
			}

			if (splash) {
				internalAddItem(target->getTile(), splash, INDEX_WHEREEVER, FLAG_NOLIMIT);
				splash->startDecaying();
			}

			break;
		}

		
//		case COMBAT_ENERGYDAMAGE: {
//			switch (origin) {
//				case ORIGIN_WAND:
//					color = TEXTCOLOR_RED;
//					effect = CONST_ME_DRAWBLOOD;
//					break;
//				default:
//					color = TEXTCOLOR_ELECTRICPURPLE;
//					effect = CONST_ME_ENERGYHIT;
//					break;
//			}
//			break;
//		}

		case COMBAT_PHYSICAL_PROC_DAMAGE: {
			color = TEXTCOLOR_RED;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_ELEMENTAL_PROC_DAMAGE: {
			color = TEXTCOLOR_MAYABLUE;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_PHYSICAL_DOT: {
			color = TEXTCOLOR_RED;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_ELEMENTAL_DOT: {
			color = TEXTCOLOR_MAYABLUE;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_ENERGYDAMAGE: {
			color = TEXTCOLOR_ELECTRICPURPLE;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_EARTHDAMAGE: {
			color = TEXTCOLOR_DARKGREEN; // TEXTCOLOR_LIGHTGREEN
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_DROWNDAMAGE: {
			color = TEXTCOLOR_LIGHTBLUE;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_FIREDAMAGE: {
			color = TEXTCOLOR_ORANGE;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_ICEDAMAGE: {
			color = TEXTCOLOR_SKYBLUE;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_HOLYDAMAGE: {
			color = TEXTCOLOR_YELLOW;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_DEATHDAMAGE: {
			color = TEXTCOLOR_LIGHTGREY;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_LIFEDRAIN: {
			color = TEXTCOLOR_DARKRED;
			effect = CONST_ME_NONE;
			break;
		}
		case COMBAT_UNDEFINEDDAMAGE: {
			color = TEXTCOLOR_WHITE_EXP;
			effect = CONST_ME_NONE;
			break;
		}
		default: {
			color = TEXTCOLOR_NONE;
			effect = CONST_ME_NONE;
			break;
		}
	}
}

bool Game::combatChangeHealth(Creature* attacker, Creature* target, CombatDamage& damage)
{
	// Recursion guard to prevent infinite loop: combatChangeHealth -> onHealthChange -> autoCastSpell -> combat -> combatChangeHealth
	static thread_local int combatRecursionDepth = 0;
	static constexpr int MAX_COMBAT_RECURSION_DEPTH = 10;
	
	if (++combatRecursionDepth > MAX_COMBAT_RECURSION_DEPTH) {
		std::cout << "[Warning] combatChangeHealth: Recursion depth exceeded (" << combatRecursionDepth 
		          << "), breaking potential infinite loop" << std::endl;
		--combatRecursionDepth;
		return false;
	}
	
	// RAII guard to decrement counter on function exit
	struct RecursionGuard {
		~RecursionGuard() { --combatRecursionDepth; }
	} guard;
	
	if (!attacker || !target || target->isRemoved() || attacker->isRemoved()) {
		return false;
	}

	const Position& targetPos = target->getPosition();
	if (damage.primary.value > 0) {
		if (target->getHealth() <= 0) {
			return false;
		}

		Player* attackerPlayer;
		if (attacker) {
			attackerPlayer = attacker->getPlayer();
		} else {
			attackerPlayer = nullptr;
		}

		Player* targetPlayer = target->getPlayer();
		if (attackerPlayer && targetPlayer && attackerPlayer->getSkull() == SKULL_BLACK && attackerPlayer->getSkullClient(targetPlayer) == SKULL_NONE) {
			return false;
		}
		
		if (damage.origin != ORIGIN_NONE && damage.origin != ORIGIN_CAST && damage.origin != ORIGIN_DOT) {
			const auto& events = target->getCreatureEvents(CREATURE_EVENT_HEALTHCHANGE);
			if (!events.empty()) {
				for (CreatureEvent* creatureEvent : events) {
					creatureEvent->executeHealthChange(target, attacker, damage);
				}
				damage.origin = ORIGIN_NONE;
				return combatChangeHealth(attacker, target, damage);
			}
		}
		

		int64_t realHealthChange = target->getHealth();
		target->gainHealth(attacker, damage.primary.value);
		realHealthChange = target->getHealth() - realHealthChange;

		if (realHealthChange > 0 && !target->isInGhostMode()) {
			#if GAME_FEATURE_ANALYTICS > 0
			if (targetPlayer) {
				targetPlayer->sendImpactTracking(true, realHealthChange);
			}
			#endif

			#if GAME_FEATURE_SERVER_LOG_DETAILS > 0
			std::stringExtended damageString(32);
			damageString << realHealthChange << (realHealthChange != 1 ? " hitpoints." : " hitpoint.");
			#endif

			TextMessage message;
			message.type = MESSAGE_HEALED;
			message.position = targetPos;
			message.primary.value = realHealthChange;
			message.primary.color = TEXTCOLOR_LIGHTGREEN;
			
//			std::stringExtended healANim(32);
//			healANim << "Heal +" << realHealthChange;
//			g_game.addAnimatedText(healANim, targetPos, TEXTCOLOR_LIGHTGREEN);

			SpectatorVector spectators;
			map.getSpectators(spectators, targetPos, false, true);
			for (Creature* spectator : spectators) {
				Player* tmpPlayer = spectator->getPlayer();
				#if GAME_FEATURE_SERVER_LOG_DETAILS > 0
				if (tmpPlayer == attackerPlayer && attackerPlayer != targetPlayer) {
					std::stringExtended sink(target->getNameDescription().length() + damageString.length() + 16);
					sink << "You heal " << target->getNameDescription() << " for " << damageString;
					message.type = MESSAGE_HEALED;
					message.text = std::move(static_cast<std::string&>(sink));
				} else if (tmpPlayer == targetPlayer) {
					std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + damageString.length() + 32);
					if (!attacker) {
						sink << "You were healed";
					} else if (targetPlayer == attackerPlayer) {
						sink << "You healed yourself";
					} else {
						sink << "You were healed by " << attacker->getNameDescription();
					}
					sink << " for " << damageString;
					message.type = MESSAGE_HEALED;
					message.text = std::move(static_cast<std::string&>(sink));
				} else {
					if (message.type != MESSAGE_HEALED_OTHERS) {
						std::stringExtended sink;
						if (!attacker) {
							sink.reserve(target->getNameDescription().length() + damageString.length() + 32);
							sink << target->getNameDescription() << " was healed";
						} else {
							sink.reserve(attacker->getNameDescription().length() + target->getNameDescription().length() + damageString.length() + 32);
							sink << attacker->getNameDescription() << " healed ";
							if (attacker == target) {
								sink << (targetPlayer ? (targetPlayer->getSex() == PLAYERSEX_FEMALE ? "herself" : "himself") : "itself");
							} else {
								sink << target->getNameDescription();
							}
						}
						sink << " for " << damageString;
						message.type = MESSAGE_HEALED_OTHERS;
						message.text = std::move(static_cast<std::string&>(sink));
					}
				}
				#endif
				message.type = MESSAGE_STATUS_DEFAULT;
				//tmpPlayer->sendTextMessage(message);
				std::string font = "Reggae One-14px-bordered";
				if (message.secondary.value > 0) {
					tmpPlayer->sendAnimatedText(std::to_string(message.secondary.value), message.position, message.secondary.color, font);
				}
				if (damage.critical)
					font = "Reggae One-20px-bordered";
				tmpPlayer->sendAnimatedText(std::to_string(message.primary.value), message.position, message.primary.color, font);
			}
		}
	} else {
		if (!target->isAttackable()) {
			if (!target->isInGhostMode()) {
				addMagicEffect(targetPos, CONST_ME_POFF);
			}
			return true;
		}

		Player* attackerPlayer;
		if (attacker) {
			attackerPlayer = attacker->getPlayer();
		} else {
			attackerPlayer = nullptr;
		}

		Player* targetPlayer = target->getPlayer();
		if (attackerPlayer && targetPlayer && attackerPlayer->getSkull() == SKULL_BLACK && attackerPlayer->getSkullClient(targetPlayer) == SKULL_NONE) {
			return false;
		}
	
		if (attackerPlayer) {
			if (target->isSpawnBlocking(attackerPlayer)) {
				return true;
			}
		}

		Monster* monster = attacker ? attacker->getMonster() : nullptr;
		if (monster && monster->getLevel() > 0) {
			float bonusDmg = g_config.getFloat(ConfigManager::MLVL_BONUSDMG) * monster->getLevel();
			if (bonusDmg != 0.0) {
				damage.primary.value += std::round(damage.primary.value * bonusDmg);
				damage.secondary.value += std::round(damage.secondary.value * bonusDmg);
			}
		}

		damage.primary.value = std::abs(damage.primary.value);
		damage.secondary.value = std::abs(damage.secondary.value);

		int64_t healthChange = damage.primary.value + damage.secondary.value;
		if (healthChange == 0) {
			return true;
		}


		TextMessage message;
		message.position = targetPos;

		SpectatorVector spectators;
		if (targetPlayer && target->hasCondition(CONDITION_MANASHIELD)) { // && damage.primary.type != COMBAT_UNDEFINEDDAMAGE
			int64_t manaDamage = std::min<int64_t>(targetPlayer->getMana(), healthChange);
			if (manaDamage != 0) {
				if (damage.origin != ORIGIN_NONE && damage.origin != ORIGIN_CAST && damage.origin != ORIGIN_DOT) {
					const auto& events = target->getCreatureEvents(CREATURE_EVENT_MANACHANGE);
					if (!events.empty()) {
						for (CreatureEvent* creatureEvent : events) {
							creatureEvent->executeManaChange(target, attacker, damage);
						}
						healthChange = damage.primary.value + damage.secondary.value;
						if (healthChange == 0) {
							return true;
						}
						manaDamage = std::min<int64_t>(targetPlayer->getMana(), healthChange);
					}
				}

				targetPlayer->drainMana(attacker, manaDamage);
				map.getSpectators(spectators, targetPos, true, true);
				addMagicEffect(spectators, targetPos, CONST_ME_LOSEENERGY);

				message.type = MESSAGE_DAMAGE_DEALT;
				message.primary.value = manaDamage;
				message.primary.color = TEXTCOLOR_BLUE;

				for (Creature* spectator : spectators) {
					Player* tmpPlayer = spectator->getPlayer();
					if (tmpPlayer->getPosition().z != targetPos.z) {
						continue;
					}

					#if GAME_FEATURE_SERVER_LOG_DETAILS > 0
					std::string elementDamage = "None";
					if (damage.primary.type == COMBAT_LIFEDRAIN || damage.secondary.type == COMBAT_LIFEDRAIN) { 
						if (damage.critical) {
								elementDamage = "[Critical Percent HP]";	
							} else {
								elementDamage = "[Percent HP]";
							}
						} else {
						if (damage.primary.type == COMBAT_PHYSICALDAMAGE || damage.secondary.type == COMBAT_PHYSICALDAMAGE) {
							if (damage.critical) {
								elementDamage = "[Critical Physical]";	
							} else {
								elementDamage = "[Physical]";
							}
						} else if (damage.primary.type == COMBAT_UNDEFINEDDAMAGE || damage.secondary.type == COMBAT_UNDEFINEDDAMAGE) {
							if (damage.critical) {
								elementDamage = "[Critical Penetration]";
							} else {
								elementDamage = "[Penetration]";
							}
						} else {
							if (damage.critical) {
								elementDamage = "[Critical Elemental]";
							} else {
								elementDamage = "[Elemental]";
							}
						}
						if (damage.primary.type == COMBAT_PHYSICAL_PROC_DAMAGE || damage.secondary.type == COMBAT_PHYSICAL_PROC_DAMAGE) {
							if (damage.critical) {
								elementDamage = "[PROC Critical Physical]";	
							} else {
								elementDamage = "[PROC Physical]";
							}
						} else if (damage.primary.type == COMBAT_ELEMENTAL_PROC_DAMAGE || damage.secondary.type == COMBAT_ELEMENTAL_PROC_DAMAGE) {
							if (damage.critical) {
								elementDamage = "[PROC Critical Elemental]";
							} else {
								elementDamage = "[PROC Elemental]";
							}
						}
					}
					if (tmpPlayer == attackerPlayer && attackerPlayer != targetPlayer) {
						std::stringExtended sink(target->getNameDescription().length() + 64);
						sink << ucfirst(target->getNameDescription()) << " loses " << manaDamage << " mana due to your " << elementDamage <<" attack.";
						message.type = MESSAGE_DAMAGE_DEALT;
						message.text = std::move(static_cast<std::string&>(sink));
					} else if (tmpPlayer == targetPlayer) {
						std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + 64);
						sink << "You lose " << manaDamage << " mana";
						if (!attacker) {
							sink << '.';
						} else if (targetPlayer == attackerPlayer) {
							sink << " due to your own " << elementDamage << " attack.";
						} else {
							sink << " due to an " << elementDamage << " attack by " << attacker->getNameDescription() << '.';
						}
						message.type = MESSAGE_DAMAGE_RECEIVED;
						message.text = std::move(static_cast<std::string&>(sink));
					} else {
						if (message.type != MESSAGE_DAMAGE_OTHERS) {
							std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + target->getNameDescription().length() + 64);
							sink << ucfirst(target->getNameDescription()) << " loses " << manaDamage << " mana";
							if (attacker) {
								sink << " due to ";
								if (attacker == target) {
									sink << (targetPlayer->getSex() == PLAYERSEX_FEMALE ? "her own attack" : "his own attack");
								} else {
									sink << "an attack by " << attacker->getNameDescription();
								}
							}
							sink << '.';
							message.type = MESSAGE_DAMAGE_OTHERS;
							message.text = std::move(static_cast<std::string&>(sink));
						}
					}
					#endif
					message.type = MESSAGE_STATUS_DEFAULT;
					//tmpPlayer->sendTextMessage(message);
					std::string font = "Reggae One-14px-bordered";
					if (message.secondary.value > 0) {
						tmpPlayer->sendAnimatedText(std::to_string(message.secondary.value), message.position, message.secondary.color, font);
					}
					if (damage.critical)
						font = "Reggae One-20px-bordered";
					tmpPlayer->sendAnimatedText(std::to_string(message.primary.value), message.position, message.primary.color, font);
				}

				damage.primary.value -= manaDamage;
				if (damage.primary.value < 0) {
					damage.secondary.value = std::max<int64_t>(0, damage.secondary.value + damage.primary.value);
					damage.primary.value = 0;
				}
			}
		}

		int64_t realDamage = damage.primary.value + damage.secondary.value;
		if (realDamage == 0) {
			return true;
		}

		if (damage.origin != ORIGIN_NONE && damage.origin != ORIGIN_CAST && damage.origin != ORIGIN_DOT) {
			const auto& events = target->getCreatureEvents(CREATURE_EVENT_HEALTHCHANGE);
			if (!events.empty()) {
				for (CreatureEvent* creatureEvent : events) {
					creatureEvent->executeHealthChange(target, attacker, damage);
				}
				damage.origin = ORIGIN_NONE;
				return combatChangeHealth(attacker, target, damage);
			}
		}

		int64_t targetHealth = target->getHealth();
		realDamage = damage.primary.value + damage.secondary.value;
		if (realDamage == 0) {
			return true;
		}

		if (spectators.empty()) {
			map.getSpectators(spectators, targetPos, true, true);
		}

		message.primary.value = damage.primary.value;
		message.secondary.value = damage.secondary.value;

		uint8_t hitEffect;
		if (message.primary.value) {
			combatGetTypeInfo(damage.primary.type, target, message.primary.color, hitEffect);
			if (hitEffect != CONST_ME_NONE) {
				addMagicEffect(spectators, targetPos, hitEffect);
			}
		}

		if (message.secondary.value) {
			combatGetTypeInfo(damage.secondary.type, target, message.secondary.color, hitEffect);
			if (hitEffect != CONST_ME_NONE) {
				addMagicEffect(spectators, targetPos, hitEffect);
			}
		}

		
		message.type = MESSAGE_DAMAGE_DEALT;
		if (message.primary.color != TEXTCOLOR_NONE || message.secondary.color != TEXTCOLOR_NONE) {
			#if GAME_FEATURE_ANALYTICS > 0
			if (attackerPlayer) {
				#if GAME_FEATURE_ANALYTICS_IMPACT_TRACKING_EXTENDED > 0
				attackerPlayer->sendImpactTracking(damage.primary.type, damage.primary.value, "");
				if (damage.secondary.type != COMBAT_NONE) {
					attackerPlayer->sendImpactTracking(damage.secondary.type, damage.secondary.value, "");
				}
				#else
				attackerPlayer->sendImpactTracking(false, realDamage);
				#endif
			}
			#endif
			#if GAME_FEATURE_ANALYTICS_IMPACT_TRACKING_EXTENDED > 0
			if (targetPlayer) {
				std::string cause = "field item"; //I don't have access to test server so it might be called something else
				if (attacker) {
					cause = attacker->getName();
				}
				targetPlayer->sendImpactTracking(damage.primary.type, damage.primary.value, cause);
				if (damage.secondary.type != COMBAT_NONE) {
					attackerPlayer->sendImpactTracking(damage.secondary.type, damage.secondary.value, cause);
				}
			}
			#endif

			#if GAME_FEATURE_SERVER_LOG_DETAILS > 0
			std::stringExtended damageString(32);
			damageString << realDamage << (realDamage != 1 ? " hitpoints" : " hitpoint");
			#endif

			for (Creature* spectator : spectators) {
				Player* tmpPlayer = spectator->getPlayer();
				if (tmpPlayer->getPosition().z != targetPos.z) {
					continue;
				}

				#if GAME_FEATURE_SERVER_LOG_DETAILS > 0
				std::string elementDamage = "None";
					if (damage.primary.type == COMBAT_LIFEDRAIN) { 
						if (damage.critical) {
								elementDamage = "[Critical Percent HP]";	
							} else {
								elementDamage = "[Percent HP]";
							}
						} else {
						if (damage.primary.type == COMBAT_PHYSICALDAMAGE) {
							if (damage.critical) {
								elementDamage = "[Critical Physical]";	
							} else {
								elementDamage = "[Physical]";
							}
						} else if (damage.primary.type == COMBAT_UNDEFINEDDAMAGE) {
							if (damage.critical) {
								elementDamage = "[Critical Penetration]";
							} else {
								elementDamage = "[Penetration]";
							}
						} else {
							if (damage.critical) {
								elementDamage = "[Critical Elemental]";
							} else {
								elementDamage = "[Elemental]";
							}
						}
						if (damage.primary.type == COMBAT_PHYSICAL_PROC_DAMAGE) {
							if (damage.critical) {
								elementDamage = "[PROC Critical Physical]";	
							} else {
								elementDamage = "[PROC Physical]";
							}
						} else if (damage.primary.type == COMBAT_ELEMENTAL_PROC_DAMAGE) {
							if (damage.critical) {
								elementDamage = "[PROC Critical Elemental]";
							} else {
								elementDamage = "[PROC Elemental]";
							}
						}
					}
				
				if (tmpPlayer == attackerPlayer && attackerPlayer != targetPlayer) {
					std::stringExtended sink(target->getNameDescription().length() + damageString.length() + 32);
					sink << ucfirst(target->getNameDescription()) << " loses " << damageString << " due to your " << elementDamage << " attack.";
					message.type = MESSAGE_DAMAGE_DEALT;
					message.text = std::move(static_cast<std::string&>(sink));
				} else if (tmpPlayer == targetPlayer) {
					std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + damageString.length() + 32);
					sink << "You lose " << damageString;
					if (!attacker) {
						sink << '.' << elementDamage;
					} else if (targetPlayer == attackerPlayer) {
						sink << " due to your own " << elementDamage << " attack.";
					} else {
						sink << " due to an " << elementDamage << " attack by " << attacker->getNameDescription() << '.';
					}
					message.type = MESSAGE_DAMAGE_RECEIVED;
					message.text = std::move(static_cast<std::string&>(sink));
				} else {
					if (message.type != MESSAGE_DAMAGE_OTHERS) {
						std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + target->getNameDescription().length() + damageString.length() + 32);
						sink << ucfirst(target->getNameDescription()) << " loses " << damageString;
						if (attacker) {
							sink << " due to ";
							if (attacker == target) {
								if (targetPlayer) {
									sink << (targetPlayer->getSex() == PLAYERSEX_FEMALE ? "her own attack" : "his own attack");
								} else {
									sink << "its own attack";
								}
							} else {
								sink << "an attack by " << attacker->getNameDescription();
							}
						}
						sink << '.';
						message.type = MESSAGE_DAMAGE_OTHERS;
						message.text = std::move(static_cast<std::string&>(sink));
					}
				}
				#endif
				message.type = MESSAGE_STATUS_DEFAULT;
				//tmpPlayer->sendTextMessage(message);
				std::string font = "Reggae One-14px-bordered";
				if (message.secondary.value > 0) {
					tmpPlayer->sendAnimatedText(std::to_string(message.secondary.value), message.position, message.secondary.color, font);
				}
				if (damage.critical)
					font = "Reggae One-20px-bordered";
				tmpPlayer->sendAnimatedText(std::to_string(message.primary.value), message.position, message.primary.color, font);
			}
		}

		int64_t targetEnergyShield = target->getEnergyShield();
		if (targetEnergyShield > 0) {
			target->changeEnergyShield(-realDamage);
			if (realDamage > targetEnergyShield) {
				realDamage -= targetEnergyShield;
			} else {
				realDamage = 0;
			}
		}

		if (realDamage >= targetHealth) {
			for (CreatureEvent* creatureEvent : target->getCreatureEvents(CREATURE_EVENT_PREPAREDEATH)) {
				if (!creatureEvent->executeOnPrepareDeath(target, attacker)) {
					return false;
				}
			}

			//Dispatch creature death event to the first safe cpu cycle
			g_dispatcher.addTask(std::bind(&Game::checkCreatureDeath, this, target->getID()));
		}

		target->setCanRegenerateShield(false);

		uint64_t esRegenEvent = target->getRegenEvent();
		if (esRegenEvent != 0) {
			g_dispatcher.stopEvent(esRegenEvent);
		}

		target->setRegenEvent(g_dispatcher.addEvent(1500, std::bind(&Game::setRegenerateShield, this, target->getID(), true)));
		target->drainHealth(attacker, realDamage);

		for (CreatureEvent* creatureEvent : target->getCreatureEvents(CREATURE_EVENT_HEALTHDRAIN)) {
			creatureEvent->executeOnHealthDrain(target, attacker, realDamage);
		}
		addCreatureHealth(spectators, target);
	}

	return true;
}

void Game::setRegenerateShield(uint32_t id, bool regenerate)
{
	Creature* creature = getCreatureByID(id);
	if (!creature) {
		return;
	}

	creature->setCanRegenerateShield(regenerate);
}

bool Game::combatChangeMana(Creature* attacker, Creature* target, CombatDamage& damage)
{
	Player* targetPlayer = target->getPlayer();
	if (!targetPlayer) {
		return true;
	}

	Monster* monster = attacker ? attacker->getMonster() : nullptr;
	if (monster && monster->getLevel() > 0) {
		float bonusDmg = g_config.getFloat(ConfigManager::MLVL_BONUSDMG) * monster->getLevel();
		if (bonusDmg != 0.0) {
			if (damage.primary.value < 0) {
				damage.primary.value += std::round(damage.primary.value * bonusDmg);
			}
			if (damage.secondary.value < 0) {
				damage.secondary.value += std::round(damage.secondary.value * bonusDmg);
			}
		}
	}

	int64_t manaChange = damage.primary.value + damage.secondary.value;
	if (manaChange > 0) {
		if (attacker) {
			const Player* attackerPlayer = attacker->getPlayer();
			if (attackerPlayer && attackerPlayer->getSkull() == SKULL_BLACK && attackerPlayer->getSkullClient(target) == SKULL_NONE) {
				return false;
			}
		}

		if (damage.origin != ORIGIN_NONE && damage.origin != ORIGIN_CAST && damage.origin != ORIGIN_DOT) {
			const auto& events = target->getCreatureEvents(CREATURE_EVENT_MANACHANGE);
			if (!events.empty()) {
				for (CreatureEvent* creatureEvent : events) {
					creatureEvent->executeManaChange(target, attacker, damage);
				}
				damage.origin = ORIGIN_NONE;
				return combatChangeMana(attacker, target, damage);
			}
		}

		int64_t realManaChange = targetPlayer->getMana();
		targetPlayer->changeMana(manaChange);
		realManaChange = targetPlayer->getMana() - realManaChange;

		if (realManaChange > 0 && !targetPlayer->isInGhostMode()) {
			TextMessage message(MESSAGE_HEALED, "You gained " + std::to_string(realManaChange) + " mana.");
			message.position = target->getPosition();
			message.primary.value = realManaChange;
			message.primary.color = TEXTCOLOR_ELECTRICPURPLE;
			message.type = MESSAGE_STATUS_DEFAULT;
			//targetPlayer->sendTextMessage(message);
			std::string font = "Reggae One-14px-bordered";
			if (message.secondary.value > 0) {
				targetPlayer->sendAnimatedText(std::to_string(message.secondary.value), message.position, message.secondary.color, font);
			}
			if (damage.critical)
				font = "Reggae One-20px-bordered";
			targetPlayer->sendAnimatedText(std::to_string(message.primary.value), message.position, message.primary.color, font);
			
//			std::stringExtended manaAnim(32);
//			manaAnim << "Mana +" << realManaChange;
//			g_game.addAnimatedText(manaAnim, targetPlayer->getPosition(), TEXTCOLOR_MAYABLUE);
			
			
		}
	} else {
		const Position& targetPos = target->getPosition();
		if (!target->isAttackable()) {
			if (!target->isInGhostMode()) {
				addMagicEffect(targetPos, CONST_ME_POFF);
			}
			return false;
		}

		Player* attackerPlayer;
		if (attacker) {
			attackerPlayer = attacker->getPlayer();
		} else {
			attackerPlayer = nullptr;
		}

		if (attackerPlayer && attackerPlayer->getSkull() == SKULL_BLACK && attackerPlayer->getSkullClient(targetPlayer) == SKULL_NONE) {
			return false;
		}

		int64_t manaLoss = std::min<int64_t>(targetPlayer->getMana(), -manaChange);
		BlockType_t blockType = target->blockHit(attacker, COMBAT_MANADRAIN, manaLoss);
		if (blockType != BLOCK_NONE) {
			addMagicEffect(targetPos, CONST_ME_POFF);
			return false;
		}

		if (manaLoss <= 0) {
			return true;
		}

		if (damage.origin != ORIGIN_NONE && damage.origin != ORIGIN_CAST && damage.origin != ORIGIN_DOT) {
			const auto& events = target->getCreatureEvents(CREATURE_EVENT_MANACHANGE);
			if (!events.empty()) {
				for (CreatureEvent* creatureEvent : events) {
					creatureEvent->executeManaChange(target, attacker, damage);
				}
				damage.origin = ORIGIN_NONE;
				return combatChangeMana(attacker, target, damage);
			}
		}

		targetPlayer->drainMana(attacker, manaLoss);

		TextMessage message;
		message.type = MESSAGE_DAMAGE_DEALT;
		message.position = targetPos;
		message.primary.value = manaLoss;
		message.primary.color = TEXTCOLOR_BLUE;

		SpectatorVector spectators;
		map.getSpectators(spectators, targetPos, false, true);
		for (Creature* spectator : spectators) {
			Player* tmpPlayer = spectator->getPlayer();
			#if GAME_FEATURE_SERVER_LOG_DETAILS > 0
			if (tmpPlayer == attackerPlayer && attackerPlayer != targetPlayer) {
				std::stringExtended sink(target->getNameDescription().length() + 64);
				sink << ucfirst(target->getNameDescription()) << " loses " << manaLoss << " mana due to your attack.";
				message.type = MESSAGE_DAMAGE_DEALT;
				message.text = std::move(static_cast<std::string&>(sink));
			} else if (tmpPlayer == targetPlayer) {
				std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + 64);
				sink << "You lose " << manaLoss << " mana";
				if (!attacker) {
					sink << '.';
				} else if (targetPlayer == attackerPlayer) {
					sink << " due to your own attack.";
				} else {
					sink << " mana due to an attack by " << attacker->getNameDescription() << '.';
				}
				message.type = MESSAGE_DAMAGE_RECEIVED;
				message.text = std::move(static_cast<std::string&>(sink));
			} else {
				if (message.type != MESSAGE_DAMAGE_OTHERS) {
					std::stringExtended sink(NETWORKMESSAGE_PLAYERNAME_MAXLENGTH + target->getNameDescription().length() + 64);
					sink << ucfirst(target->getNameDescription()) << " loses " << manaLoss << " mana";
					if (attacker) {
						sink << " due to ";
						if (attacker == target) {
							sink << (targetPlayer->getSex() == PLAYERSEX_FEMALE ? "her own attack" : "his own attack");
						} else {
							sink << "an attack by " << attacker->getNameDescription();
						}
					}
					sink << '.';
					message.type = MESSAGE_DAMAGE_OTHERS;
					message.text = std::move(static_cast<std::string&>(sink));
				}
			}
			#endif
			message.type = MESSAGE_STATUS_DEFAULT;
			//tmpPlayer->sendTextMessage(message);
			std::string font = "Reggae One-14px-bordered";
			if (message.secondary.value > 0) {
				tmpPlayer->sendAnimatedText(std::to_string(message.secondary.value), message.position, message.secondary.color, font);
			}
			if (damage.critical)
				font = "Reggae One-20px-bordered";
			tmpPlayer->sendAnimatedText(std::to_string(message.primary.value), message.position, message.primary.color, font);
		}
	}

	return true;
}

void Game::addCreatureHealth(const Creature* target)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, target->getPosition(), true, true);
	addCreatureHealth(spectators, target);
}

void Game::addCreatureHealth(const SpectatorVector& spectators, const Creature* target)
{
	uint8_t healthPercent = std::ceil((static_cast<double>(target->getHealth()) / std::max<int64_t>(target->getMaxHealth(), 1)) * 100);
	uint8_t energyPercent = std::ceil((static_cast<double>(target->getEnergyShield()) / std::max<int64_t>(target->getMaxEnergyShield(), 1)) * 100);
	#if GAME_FEATURE_PARTY_LIST > 0
	if (const Player* targetPlayer = target->getPlayer()) {
		if (Party* party = targetPlayer->getParty()) {
			party->updatePlayerHealth(targetPlayer, target, healthPercent);
		}
	} else if (const Creature* master = target->getMaster()) {
		if (const Player* masterPlayer = master->getPlayer()) {
			if (Party* party = masterPlayer->getParty()) {
				party->updatePlayerHealth(masterPlayer, target, healthPercent);
			}
		}
	}
	#endif

	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendCreatureHealth(target, healthPercent, energyPercent);
		}
	}
}

void Game::addAnimatedText(const std::string& message, const Position& pos, TextColor_t color, const std::string& font)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, pos, true, true);
	addAnimatedText(spectators, message, pos, color, font);
}


void Game::addAnimatedText(const SpectatorVector& spectators, const std::string& message, const Position& pos, TextColor_t color, const std::string& font)
{
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendAnimatedText(message, pos, color, font);
		}
	}
}

#if GAME_FEATURE_PARTY_LIST > 0
void Game::addPlayerMana(const Player* target)
{
	if (Party* party = target->getParty()) {
		uint8_t manaPercent = std::ceil((static_cast<double>(target->getMana()) / std::max<int64_t>(target->getMaxMana(), 1)) * 100);
		party->updatePlayerMana(target, manaPercent);
	}
}
#endif

void Game::addMagicEffect(const Position& pos, uint16_t effect, uint8_t bottom /* 0 */, const std::string color /* 0 */)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, pos, true, true);
	addMagicEffect(spectators, pos, effect, bottom, color);
}

void Game::addMagicEffect(const SpectatorVector& spectators, const Position& pos, uint16_t effect, uint8_t bottom /* 0 */, const std::string color /* 0 */)
{
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendMagicEffect(pos, effect, bottom, color);
		}
	}
}

void Game::addLineEffect(const Position& fromPos, const Position& toPos, uint16_t effect, bool bottom)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, fromPos, true, true);
	addLineEffect(spectators, fromPos, toPos, effect, bottom);
}

void Game::addLineEffect(const SpectatorVector& spectators, const Position& fromPos, const Position& toPos, uint16_t effect, bool bottom)
{
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendLineEffect(fromPos, toPos, effect, bottom);
		}
	}
}

void Game::addCreatureEffect(const Creature* creature, uint16_t effect, uint8_t bottom /* 0 */)
{
	SpectatorVector spectators;
	Position pos = creature->getPosition();
	map.getSpectators(spectators, pos, true, true);
	addCreatureEffect(spectators, creature, effect, bottom);
}

void Game::addCreatureEffect(const SpectatorVector& spectators, const Creature* creature, uint16_t effect, uint8_t bottom /* 0 */)
{
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendCreatureEffect(creature, effect, bottom);
		}
	}
}

void Game::addDistanceEffect(const Position& fromPos, const Position& toPos, uint16_t effect, bool type, uint16_t duration, double speed, const std::string color)
{
	SpectatorVector spectators;
	if (std::abs(fromPos.x - toPos.x) == 1 || std::abs(fromPos.y - toPos.y) == 1) {
		int32_t minRangeX = Map::maxViewportX;
		int32_t maxRangeX = Map::maxViewportX;
		int32_t minRangeY = Map::maxViewportY;
		int32_t maxRangeY = Map::maxViewportY;
		if (fromPos.y > toPos.y) {
			++minRangeY;
		} else if (fromPos.y < toPos.y) {
			++maxRangeY;
		}

		if (fromPos.x < toPos.x) {
			++maxRangeX;
		} else if (fromPos.x > toPos.x) {
			++minRangeX;
		}
		map.getSpectators(spectators, fromPos, false, true, minRangeX, maxRangeX, minRangeY, maxRangeY);
	} else {
		SpectatorVector tospectators;
		map.getSpectators(spectators, fromPos, false, true);
		map.getSpectators(tospectators, toPos, false, true);
		spectators.mergeSpectators(tospectators);
	}
	addDistanceEffect(spectators, fromPos, toPos, effect, type, duration, speed, color);
}

void Game::addDistanceEffect(const SpectatorVector& spectators, const Position& fromPos, const Position& toPos, uint16_t effect, bool type, uint16_t duration, double speed, const std::string color)
{
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendDistanceShoot(fromPos, toPos, effect, type, duration, speed, color);
		}
	}
}

void Game::updateCreatureData(const Creature* creature)
{
	for (const auto& it : players) {
		it.second->updateCreatureData(creature);
	}
}

void Game::startDecay(Item* item)
{
	if (!item) {
		return;
	}

	ItemDecayState_t decayState = item->getDecaying();
	if (decayState == DECAYING_STOPPING || (!item->canDecay() && decayState == DECAYING_TRUE)) {
		stopDecay(item);
		return;
	}

	if (!item->canDecay() || decayState == DECAYING_TRUE) {
		return;
	}

	int32_t duration = item->getIntAttr(ITEM_ATTRIBUTE_DURATION);
	if (duration > 0) {
		g_decay.startDecay(item, duration);
	} else {
		internalDecayItem(item);
	}
}

void Game::stopDecay(Item* item)
{
	if (item->hasAttribute(ITEM_ATTRIBUTE_DECAYSTATE)) {
		if (item->hasAttribute(ITEM_ATTRIBUTE_DURATION_TIMESTAMP)) {
			g_decay.stopDecay(item, item->getIntAttr(ITEM_ATTRIBUTE_DURATION_TIMESTAMP));
			item->removeAttribute(ITEM_ATTRIBUTE_DURATION_TIMESTAMP);
		} else {
			item->removeAttribute(ITEM_ATTRIBUTE_DECAYSTATE);
		}
	}
}

void Game::internalDecayItem(Item* item)
{
	const ItemType& it = Item::items[item->getID()];
	if (it.decayTo != 0) {
		uint32_t owner = item->getCorpseOwner();
		Item *newItem = transformItem(item, it.decayTo);
		if (owner != 0 && newItem && !newItem->isRemoved()) {
			newItem->setCorpseOwner(owner);
		}
	} else {
		uint32_t playerId = item->getCorpseOwner();
		if (playerId > 0) {		
			for (auto& it : g_globalEvents->getEventMap(GLOBALEVENT_PREREMOVEITEM)) {
				it.second.executePreRemove(item, playerId);
			}
		}
		ReturnValue ret = internalRemoveItem(item);
		if (ret != RETURNVALUE_NOERROR) {
			std::cout << "[Debug - Game::internalDecayItem] internalDecayItem failed, error code: " << static_cast<uint32_t>(ret) << ", item id: " << item->getID() << std::endl;
		}
	}
}

void Game::checkLight()
{
	g_dispatcher.addEvent(EVENT_LIGHTINTERVAL, std::bind(&Game::checkLight, this));

	lightHour += lightHourDelta;

	if (lightHour > 1440) {
		lightHour -= 1440;
	}

	if (std::abs(lightHour - SUNRISE) < 2 * lightHourDelta) {
		lightState = LIGHT_STATE_SUNRISE;
	} else if (std::abs(lightHour - SUNSET) < 2 * lightHourDelta) {
		lightState = LIGHT_STATE_SUNSET;
	}

	int32_t newLightLevel = lightLevel;
	bool lightChange = false;

	switch (lightState) {
		case LIGHT_STATE_SUNRISE: {
			newLightLevel += (LIGHT_LEVEL_DAY - LIGHT_LEVEL_NIGHT) / 30;
			lightChange = true;
			break;
		}
		case LIGHT_STATE_SUNSET: {
			newLightLevel -= (LIGHT_LEVEL_DAY - LIGHT_LEVEL_NIGHT) / 30;
			lightChange = true;
			break;
		}
		default:
			break;
	}

	if (newLightLevel <= LIGHT_LEVEL_NIGHT) {
		lightLevel = LIGHT_LEVEL_NIGHT;
		lightState = LIGHT_STATE_NIGHT;
	} else if (newLightLevel >= LIGHT_LEVEL_DAY) {
		lightLevel = LIGHT_LEVEL_DAY;
		lightState = LIGHT_STATE_DAY;
	} else {
		lightLevel = newLightLevel;
	}

	if (lightChange) {
		LightInfo lightInfo = getWorldLightInfo();

		for (const auto& it : players) {
			it.second->sendWorldLight(lightInfo);
			#if CLIENT_VERSION >= 1121
			it.second->sendTibiaTime(lightHour);
			#endif
		}
	}
	#if CLIENT_VERSION >= 1121
	else {
		for (const auto& it : players) {
			it.second->sendTibiaTime(lightHour);
		}
	}
	#endif
}

LightInfo Game::getWorldLightInfo() const
{
	return {lightLevel, 0xD7};
}

void Game::shutdown()
{
	std::cout << "Shutting down..." << std::flush;

	g_cams.shutdown();
	g_databaseTasks.shutdown();
	g_dispatcher.shutdown();
	#ifdef STATS_ENABLED
		g_stats.shutdown();
	#endif
	map.spawns.clear();
	raids.clear();

	cleanup();

	if (serviceManager) {
		serviceManager->stop();
	}

	ConnectionManager::getInstance().closeAll();

	std::cout << " done!" << std::endl;
}

void Game::cleanup()
{
	//free memory
	for (auto creature : ToReleaseCreatures) {
		creature->decrementReferenceCounter();
	}
	ToReleaseCreatures.clear();

	int iteration = 0;
	while (!ToReleaseItems.empty()) {
		std::vector<Item*> itemsToProcess;
		itemsToProcess.reserve(ToReleaseItems.size());
		
		for (auto item : ToReleaseItems) {
			itemsToProcess.push_back(item);
		}
		ToReleaseItems.clear();
		
		for (auto item : itemsToProcess) {
			if (item) {
				item->decrementReferenceCounter();
			}
		}
		++iteration;
	}
}

void Game::ReleaseCreature(Creature* creature)
{
	ToReleaseCreatures.push_back(creature);
}

void Game::ReleaseItem(Item* item)
{
	if (!item) {
		return;
	}
	
	uint32_t refCount = item->getReferenceCounter();
	if (refCount == 0) {
		// Item already at refCount=0, likely released by async save thread
		// Safe to delete directly
		delete item;
		return;
	}
	
	ToReleaseItems.push_back(item);
}

void Game::broadcastMessage(const std::string& text, MessageClasses type) const
{
	std::cout << "> Broadcasted message: \"" << text << "\"." << std::endl;
	for (const auto& it : players) {
		it.second->sendTextMessage(type, text);
	}
}

#if CLIENT_VERSION >= 854
void Game::updateCreatureWalkthrough(const Creature* creature)
{
	//send to clients
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		Player* tmpPlayer = spectator->getPlayer();
		tmpPlayer->sendCreatureWalkthrough(creature, tmpPlayer->canWalkthroughEx(creature));
	}
}
#endif

void Game::updateCreatureSkull(const Creature* creature)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendCreatureSkull(creature);
	}
}

void Game::updateActiveAuras(const Creature* creature)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendActiveAuras(creature);
	}
}

void Game::updateCreatureJump(const Creature* creature, uint16_t height, uint16_t duration)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendJump(creature, height, duration);
	}
}

void Game::updateCreatureProgressBar(const Creature* creature, uint32_t duration, bool ltr)
{
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendProgressBar(creature, duration, ltr);
	}
}

#if CLIENT_VERSION >= 1000 && CLIENT_VERSION < 1185
void Game::updatePlayerHelpers(const Player& player)
{
	uint32_t creatureId = player.getID();
	uint16_t helpers = player.getHelpers();

	SpectatorVector spectators;
	map.getSpectators(spectators, player.getPosition(), true, true);
	for (Creature* spectator : spectators) {
		spectator->getPlayer()->sendCreatureHelpers(creatureId, helpers);
	}
}
#endif

#if CLIENT_VERSION >= 910
void Game::updateCreatureType(Creature* creature)
{
	const Player* masterPlayer = nullptr;

	CreatureType_t creatureType = creature->getType();
	if (creatureType == CREATURETYPE_MONSTER) {
		const Creature* master = creature->getMaster();
		if (master) {
			masterPlayer = master->getPlayer();
			if (masterPlayer) {
				creatureType = CREATURETYPE_SUMMON_OTHERS;
			}
		}
	}
	if (creature->isHealthHidden()) {
		creatureType = CREATURETYPE_HIDDEN;
	}

	//send to clients
	SpectatorVector spectators;
	map.getSpectators(spectators, creature->getPosition(), true, true);
	if (creatureType == CREATURETYPE_SUMMON_OTHERS) {
		for (Creature* spectator : spectators) {
			Player* player = spectator->getPlayer();
			if (masterPlayer == player) {
				player->sendCreatureType(creature, CREATURETYPE_SUMMON_OWN);
			} else {
				player->sendCreatureType(creature, creatureType);
			}
		}
	} else {
		for (Creature* spectator : spectators) {
			spectator->getPlayer()->sendCreatureType(creature, creatureType);
		}
	}
}
#endif

void Game::updatePremium(Account& account)
{
	bool save = false;
	time_t timeNow = time(nullptr);

	if (account.premiumDays != 0 && account.premiumDays != std::numeric_limits<uint16_t>::max()) {
		if (account.lastDay == 0) {
			account.lastDay = timeNow;
			save = true;
		} else {
			uint32_t days = (timeNow - account.lastDay) / 86400;
			if (days > 0) {
				if (days >= account.premiumDays) {
					account.premiumDays = 0;
					account.lastDay = 0;
				} else {
					account.premiumDays -= days;
					time_t remainder = (timeNow - account.lastDay) % 86400;
					account.lastDay = timeNow - remainder;
				}

				save = true;
			}
		}
	} else if (account.lastDay != 0) {
		account.lastDay = 0;
		save = true;
	}

	if (save && !IOLoginData::saveAccount(account)) {
		std::cout << "> ERROR: Failed to save account: " << account.email << "!" << std::endl;
	}
}

void Game::loadMotdNum()
{
	DBResult_ptr result = g_database.storeQuery("SELECT `value` FROM `server_config` WHERE `config` = 'motd_num' LIMIT 1");
	if (result) {
		motdNum = result->getNumber<uint32_t>("value");
	} else {
		g_database.executeQuery("INSERT INTO `server_config` (`config`, `value`) VALUES ('motd_num', '0')");
	}

	result = g_database.storeQuery("SELECT `value` FROM `server_config` WHERE `config` = 'motd_hash' LIMIT 1");
	if (result) {
		motdHash = std::move(result->getString("value"));
		if (motdHash != transformToSHA1(g_config.getString(ConfigManager::MOTD))) {
			++motdNum;
		}
	} else {
		g_database.executeQuery("INSERT INTO `server_config` (`config`, `value`) VALUES ('motd_hash', '')");
	}
}

void Game::saveMotdNum() const
{
	std::stringExtended query(128);
	query << "UPDATE `server_config` SET `value` = '" << motdNum << "' WHERE `config` = 'motd_num'";
	g_database.executeQuery(query);

	query.clear();
	query << "UPDATE `server_config` SET `value` = '" << transformToSHA1(g_config.getString(ConfigManager::MOTD)) << "' WHERE `config` = 'motd_hash'";
	g_database.executeQuery(query);
}

void Game::checkPlayersRecord()
{
	const size_t playersOnline = getPlayersOnline();
	if (playersOnline > playersRecord) {
		uint32_t previousRecord = playersRecord;
		playersRecord = playersOnline;

		for (auto& it : g_globalEvents->getEventMap(GLOBALEVENT_RECORD)) {
			it.second.executeRecord(playersRecord, previousRecord);
		}
		updatePlayersRecord();
	}
}

void Game::updatePlayersRecord() const
{
	std::stringExtended query(128);
	query << "UPDATE `server_config` SET `value` = '" << playersRecord << "' WHERE `config` = 'players_record'";
	g_database.executeQuery(query);
}

void Game::savelastUID()
{
	std::stringExtended query(128);
	query << "UPDATE `server_config` SET `value` = '" << lastUID << "' WHERE `config` = 'lastUID'";
	g_database.executeQuery(query);
}

void Game::loadlastUID()
{
	DBResult_ptr result = g_database.storeQuery("SELECT `value` FROM `server_config` WHERE `config` = 'lastUID' LIMIT 1");
	if (result) {
		lastUID = result->getNumber<uint32_t>("value");
	} else {
		g_database.executeQuery("INSERT INTO `server_config` (`config`, `value`) VALUES ('lastUID', '0')");
	}
}

void Game::loadPlayersRecord()
{
	DBResult_ptr result = g_database.storeQuery("SELECT `value` FROM `server_config` WHERE `config` = 'players_record'");
	if (result) {
		playersRecord = result->getNumber<uint32_t>("value");
	} else {
		g_database.executeQuery("INSERT INTO `server_config` (`config`, `value`) VALUES ('players_record', '0')");
	}
}

// void Game::checkIfIstanceIsReady()
// {
// 	boost::asio::io_service io_service;
// 	boost::asio::ip::tcp::resolver resolver(io_service);
// 	boost::asio::ip::tcp::resolver::query query("51.222.245.108", "6666");
// 	auto endpoint_iterator = resolver.resolve(query);

// 	auto socket = std::make_shared<boost::asio::ip::tcp::socket>(io_service);
// 	auto netMsg = std::make_shared<NetworkMessage>();

// 	boost::asio::async_connect(*socket, endpoint_iterator, [socket, netMsg](const boost::system::error_code& ec, auto) {
// 		if (ec) {
// 			std::cout << "Failed to connect: " << ec.message() << std::endl;
// 			return;
// 		}
// 		std::cout << "Connected to main server" << std::endl;

// 		auto msg = OutputMessagePool::getOutputMessage();
// 		// msg size
// 		msg->addByte(8);

// 		// server things i think for xtea enecryption
// 		msg->addByte(0); 
// 		msg->addByte(0); 
// 		msg->addByte(0);
// 		msg->addByte(0); 
// 		msg->addByte(0); 
// 		msg->addByte(0);

// 		// for now 66 = other server = will be changed to password or something
// 		msg->addByte(66);
// 		// test data 
// 		msg->addByte(2); 
// 		msg->addByte(3);

// 		boost::asio::async_write(*socket, boost::asio::buffer(msg->getOutputBuffer(), msg->getLength()), [socket, netMsg](const boost::system::error_code& ec, std::size_t) {
// 			if (ec) {
// 				std::cout << "Write failed: " << ec.message() << std::endl;
// 				return;
// 			}
// 			netMsg->setLength(NetworkMessage::HEADER_LENGTH);
// 			boost::asio::async_read(*socket, boost::asio::buffer(netMsg->getBuffer(), NetworkMessage::HEADER_LENGTH), [socket, netMsg](const boost::system::error_code& ec, std::size_t) {
// 				if (!ec) {
// 					std::cout << "Read header failed: " << ec.message() << std::endl;
// 					return
// 				}

// 				uint16_t bodySize = netMsg->getLengthHeader();
// 				netMsg->setLength(NetworkMessage::HEADER_LENGTH + bodySize);
// 				boost::asio::async_read(*socket, boost::asio::buffer(netMsg->getBodyBuffer(), bodySize), [netMsg](const boost::system::error_code& ec, std::size_t) {
// 					if (ec) {
// 						std::cout << "Read body failed: " << ec.message() << std::endl;
// 						return;
// 					}
					
// 					std::cout << (uint)netMsg->getByte() << std::endl;
// 					std::cout << netMsg->getString() << std::endl;
// 				});
// 			});	
// 		});
// 	});

// 	io_service.run();
// }

void Game::resetAllPlayersOnline()
{
	g_database.executeQuery("UPDATE `players` SET `online` = 0;");
	if (g_config.getNumber(ConfigManager::INSTANCE_TYPE) == 0) {
		return;
	}
}

uint64_t Game::getExperienceStage(uint32_t level)
{
	if (!stagesEnabled) {
		return g_config.getNumber(ConfigManager::RATE_EXPERIENCE);
	}

	if (useLastStageLevel && level >= lastStageLevel) {
		return stages[lastStageLevel];
	}

	return stages[level];
}

bool Game::loadExperienceStages()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/XML/stages.xml");
	if (!result) {
		printXMLError("Error - Game::loadExperienceStages", "data/XML/stages.xml", result);
		return false;
	}

	for (auto stageNode : doc.child("stages").children()) {
		if (strcasecmp(stageNode.name(), "config") == 0) {
			stagesEnabled = stageNode.attribute("enabled").as_bool();
		} else {
			uint32_t minLevel, maxLevel, multiplier;

			pugi::xml_attribute minLevelAttribute = stageNode.attribute("minlevel");
			if (minLevelAttribute) {
				minLevel = pugi::cast<uint32_t>(minLevelAttribute.value());
			} else {
				minLevel = 1;
			}

			pugi::xml_attribute maxLevelAttribute = stageNode.attribute("maxlevel");
			if (maxLevelAttribute) {
				maxLevel = pugi::cast<uint32_t>(maxLevelAttribute.value());
			} else {
				maxLevel = 0;
				lastStageLevel = minLevel;
				useLastStageLevel = true;
			}

			pugi::xml_attribute multiplierAttribute = stageNode.attribute("multiplier");
			if (multiplierAttribute) {
				multiplier = pugi::cast<uint32_t>(multiplierAttribute.value());
			} else {
				multiplier = 1;
			}

			if (useLastStageLevel) {
				stages[lastStageLevel] = multiplier;
			} else {
				for (uint32_t i = minLevel; i <= maxLevel; ++i) {
					stages[i] = multiplier;
				}
			}
		}
	}
	return true;
}

void Game::playerInviteToParty(Player* player, uint32_t invitedId)
{
	if (player->getID() == invitedId) {
		return;
	}

	Player* invitedPlayer = getPlayerByID(invitedId);
	if (!invitedPlayer || invitedPlayer->isInviting(player)) {
		return;
	}

	if (invitedPlayer->getParty()) {
		std::stringExtended ss(invitedPlayer->getName().length() + static_cast<size_t>(32));
		ss << invitedPlayer->getName() << " is already in a party.";
		player->sendTextMessage(MESSAGE_INFO_DESCR, ss);
		return;
	}

	Party* party = player->getParty();
	if (!party) {
		party = new Party(player);
	} else if (party->getLeader() != player) {
		return;
	}

	size_t partySize = party->getMemberCount() + 1;
	if (partySize >= 4) {
		player->sendTextMessage(MESSAGE_INFO_DESCR, "The party is full. (max. 4 members)");
		return;
	}

	party->invitePlayer(*invitedPlayer);
}

void Game::playerJoinParty(Player* player, uint32_t leaderId)
{
	Player* leader = getPlayerByID(leaderId);
	if (!leader || !leader->isInviting(player)) {
		return;
	}

	Party* party = leader->getParty();
	if (!party || party->getLeader() != leader) {
		return;
	}

	if (player->getParty()) {
		player->sendTextMessage(MESSAGE_INFO_DESCR, "You are already in a party.");
		return;
	}

	size_t partySize = party->getMemberCount() + 1;
	if (partySize >= 4) {
		player->sendTextMessage(MESSAGE_INFO_DESCR, "The party is full. (max. 4 members)");
		return;
	}

	party->joinParty(*player);
}

void Game::playerRevokePartyInvitation(Player* player, uint32_t invitedId)
{
	Party* party = player->getParty();
	if (!party || party->getLeader() != player) {
		return;
	}

	Player* invitedPlayer = getPlayerByID(invitedId);
	if (!invitedPlayer || !player->isInviting(invitedPlayer)) {
		return;
	}

	party->revokeInvitation(*invitedPlayer);
}

void Game::playerPassPartyLeadership(Player* player, uint32_t newLeaderId)
{
	Party* party = player->getParty();
	if (!party || party->getLeader() != player) {
		return;
	}

	Player* newLeader = getPlayerByID(newLeaderId);
	if (!newLeader || !player->isPartner(newLeader)) {
		return;
	}

	party->passPartyLeadership(newLeader);
}

void Game::playerKickPartyMember(Player* player, uint32_t targetId)
{
	Party* party = player->getParty();
	if (!party || party->getLeader() != player) {
		return;
	}

	Player* target = getPlayerByID(targetId);
	if (!target || !player->isPartner(target)) {
		return;
	}

	party->kickPartyMember(target);
}

void Game::playerLeaveParty(Player* player)
{
	Party* party = player->getParty();
	if (!party) {
		return;
	}

	party->leaveParty(player);
}

void Game::playerEnableSharedPartyExperience(Player* player, bool sharedExpActive)
{
	Party* party = player->getParty();
	if (!party) {  // || (player->hasCondition(CONDITION_INFIGHT) && player->getZone() != ZONE_PROTECTION)
		return;
	}

	party->setSharedExperience(player, sharedExpActive);
}

void Game::sendGuildMotd(uint32_t playerId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	Guild* guild = player->getGuild();
	if (guild) {
		player->sendChannelMessage("Message of the Day", guild->getMotd(), TALKTYPE_CHANNEL_R1, CHANNEL_GUILD);
	}
}

void Game::kickPlayer(uint32_t playerId, bool displayEffect)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	player->kickPlayer(displayEffect);
}

void Game::playerReportRuleViolation(Player* player, const std::string& targetName, uint8_t reportType, uint8_t reportReason, const std::string& comment, const std::string& translation)
{
	g_events->eventPlayerOnReportRuleViolation(player, targetName, reportType, reportReason, comment, translation);
}

void Game::playerMonsterCyclopedia(Player* player)
{
	player->sendMonsterCyclopedia();
	player->sendCyclopediaBonusEffects();
}

void Game::playerCyclopediaMonsters(Player* player, const std::string& race)
{
	player->sendCyclopediaMonsters(race);
}

void Game::playerCyclopediaRace(Player* player, uint16_t monsterId)
{
	player->sendCyclopediaRace(monsterId);
}

#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
void Game::playerCyclopediaCharacterInfo(Player* player, uint32_t characterID, CyclopediaCharacterInfoType_t characterInfoType, uint16_t entriesPerPage, uint16_t page)
{
	uint32_t playerGUID = player->getGUID();
	if (characterID != playerGUID) {
		//For now allow viewing only our character since we don't have tournaments supported
		player->sendCyclopediaCharacterNoData(characterInfoType, 2);
		return;
	}

	switch (characterInfoType) {
		case CYCLOPEDIA_CHARACTERINFO_BASEINFORMATION: player->sendCyclopediaCharacterBaseInformation(); break;
		case CYCLOPEDIA_CHARACTERINFO_GENERALSTATS: player->sendCyclopediaCharacterGeneralStats(); break;
		case CYCLOPEDIA_CHARACTERINFO_COMBATSTATS: player->sendCyclopediaCharacterCombatStats(); break;
		case CYCLOPEDIA_CHARACTERINFO_RECENTDEATHS: {
			std::stringExtended query(1024);
			uint32_t offset = static_cast<uint32_t>(page - 1) * entriesPerPage;
			query << "SELECT `time`, `level`, `killed_by`, `mostdamage_by`, (select count(*) FROM `player_deaths` WHERE `player_id` = " << playerGUID << ") as `entries` FROM `player_deaths` WHERE `player_id` = " << playerGUID << " ORDER BY `time` DESC LIMIT " << offset << ", " << entriesPerPage;

			uint32_t playerID = player->getID();
			std::function<void(DBResult_ptr, bool, uint64_t)> callback = [playerID, page, entriesPerPage](DBResult_ptr result, bool, uint64_t) {
				Player* player = g_game.getPlayerByID(playerID);
				if (!player) {
					return;
				}

				player->resetAsyncOngoingTask(PlayerAsyncTask_RecentDeaths);
				if (!result) {
					player->sendCyclopediaCharacterRecentDeaths(0, 0, {});
					return;
				}

				uint32_t pages = result->getNumber<uint32_t>("entries");
				pages += entriesPerPage - 1;
				pages /= entriesPerPage;

				std::vector<RecentDeathEntry> entries;
				entries.reserve(result->countResults());
				do {
					std::string cause1 = result->getString("killed_by");
					std::string cause2 = result->getString("mostdamage_by");

					std::stringExtended cause(1024);
					cause << "Died at Level " << result->getNumber<uint32_t>("level") << " by";
					if (!cause1.empty()) {
						const char& character = cause1.front();
						if (character == 'a' || character == 'e' || character == 'i' || character == 'o' || character == 'u') {
							cause << " an ";
						} else {
							cause << " a ";
						}
						cause << cause1;
					}

					if (!cause2.empty()) {
						if (!cause1.empty()) {
							cause << " and ";
						}

						const char& character = cause2.front();
						if (character == 'a' || character == 'e' || character == 'i' || character == 'o' || character == 'u') {
							cause << " an ";
						} else {
							cause << " a ";
						}
						cause << cause2;
					}
					cause << '.';
					entries.emplace_back(std::move(static_cast<std::string&>(cause)), result->getNumber<uint32_t>("time"));
				} while (result->next());
				player->sendCyclopediaCharacterRecentDeaths(page, static_cast<uint16_t>(pages), entries);
			};
			g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)), callback, true);
			player->addAsyncOngoingTask(PlayerAsyncTask_RecentDeaths);
			break;
		}
		case CYCLOPEDIA_CHARACTERINFO_RECENTPVPKILLS: {
			//TODO: add guildwar, assists and arena kills
			const std::string& escapedName = g_database.escapeString(player->getName());
			std::stringExtended query(1024);
			uint32_t offset = static_cast<uint32_t>(page - 1) * entriesPerPage;
			query << "SELECT `d`.`time`, `d`.`killed_by`, `d`.`mostdamage_by`, `d`.`unjustified`, `d`.`mostdamage_unjustified`, `p`.`name`, (select count(*) FROM `player_deaths` WHERE ((`killed_by` = " << escapedName << " AND `is_player` = 1) OR (`mostdamage_by` = " << escapedName << " AND `mostdamage_is_player` = 1))) as `entries` FROM `player_deaths` AS `d` INNER JOIN `players` AS `p` ON `d`.`player_id` = `p`.`id` WHERE ((`d`.`killed_by` = " << escapedName << " AND `d`.`is_player` = 1) OR (`d`.`mostdamage_by` = " << escapedName << " AND `d`.`mostdamage_is_player` = 1)) ORDER BY `time` DESC LIMIT " << offset << ", " << entriesPerPage;

			uint32_t playerID = player->getID();
			std::function<void(DBResult_ptr, bool, uint64_t)> callback = [playerID, page, entriesPerPage](DBResult_ptr result, bool, uint64_t) {
				Player* player = g_game.getPlayerByID(playerID);
				if (!player) {
					return;
				}

				player->resetAsyncOngoingTask(PlayerAsyncTask_RecentPvPKills);
				if (!result) {
					player->sendCyclopediaCharacterRecentPvPKills(0, 0, {});
					return;
				}

				uint32_t pages = result->getNumber<uint32_t>("entries");
				pages += entriesPerPage - 1;
				pages /= entriesPerPage;

				std::vector<RecentPvPKillEntry> entries;
				entries.reserve(result->countResults());
				do {
					std::string cause1 = result->getString("killed_by");
					std::string cause2 = result->getString("mostdamage_by");
					std::string name = result->getString("name");

					uint8_t status = CYCLOPEDIA_CHARACTERINFO_RECENTKILLSTATUS_JUSTIFIED;
					if (player->getName() == cause1) {
						if (result->getNumber<uint32_t>("unjustified") == 1) {
							status = CYCLOPEDIA_CHARACTERINFO_RECENTKILLSTATUS_UNJUSTIFIED;
						}
					} else if (player->getName() == cause2) {
						if (result->getNumber<uint32_t>("mostdamage_unjustified") == 1) {
							status = CYCLOPEDIA_CHARACTERINFO_RECENTKILLSTATUS_UNJUSTIFIED;
						}
					}

					std::stringExtended description(1024);
					description << "Killed " << name << '.';
					entries.emplace_back(std::move(static_cast<std::string&>(description)), result->getNumber<uint32_t>("time"), status);
				} while (result->next());
				player->sendCyclopediaCharacterRecentPvPKills(page, static_cast<uint16_t>(pages), entries);
			};
			g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)), callback, true);
			player->addAsyncOngoingTask(PlayerAsyncTask_RecentPvPKills);
			break;
		}
		case CYCLOPEDIA_CHARACTERINFO_ACHIEVEMENTS: player->sendCyclopediaCharacterAchievements(); break;
		case CYCLOPEDIA_CHARACTERINFO_ITEMSUMMARY: player->sendCyclopediaCharacterItemSummary(); break;
		case CYCLOPEDIA_CHARACTERINFO_OUTFITSMOUNTS: player->sendCyclopediaCharacterOutfitsMounts(); break;
		case CYCLOPEDIA_CHARACTERINFO_STORESUMMARY: player->sendCyclopediaCharacterStoreSummary(); break;
		case CYCLOPEDIA_CHARACTERINFO_INSPECTION: player->sendCyclopediaCharacterInspection(); break;
		case CYCLOPEDIA_CHARACTERINFO_BADGES: player->sendCyclopediaCharacterBadges(); break;
		case CYCLOPEDIA_CHARACTERINFO_TITLES: player->sendCyclopediaCharacterTitles(); break;
		default: player->sendCyclopediaCharacterNoData(characterInfoType, 1); break;
	}
}
#endif

#if GAME_FEATURE_HIGHSCORES > 0
void Game::playerHighscores(Player* player, uint8_t category, std::vector<uint16_t>& vocation, const std::string&, uint16_t page, uint8_t entriesPerPage, uint8_t type)
{
	if (player->hasAsyncOngoingTask(PlayerAsyncTask_Highscore)) {
		return;
	}

	std::string categoryName;
	std::string categoryTable;
	switch (category) {
		case 0: categoryTable = "p"; categoryName = "experience"; break;
		case 1: categoryTable = "p"; categoryName = "onlinetime"; break;
		case 2: categoryTable = "p"; categoryName = "dungeontier"; break;
		case 3: categoryTable = "p"; categoryName = "dps"; break;
	
		default: {
			category = 0;
			categoryName = "experience";
			break;
		}
	}
	std::stringExtended query(1024);
	if (type == 0) {
		uint32_t startPage = (static_cast<uint32_t>(page - 1) * static_cast<uint32_t>(entriesPerPage));
		uint32_t endPage = startPage + static_cast<uint32_t>(entriesPerPage);
		query << "SELECT *, @row AS `entries`, "<< page <<" AS `page` FROM (SELECT *, ( @row := @row + 1 ) AS `rn` FROM (SELECT `p`.`id`, `p`.`name`, `p`.`level`, `p`.`vocation`, `p`.`lookbody`, `p`.`lookfeet`, `p`.`lookhead`, `p`.`looklegs`, `p`.`looktype`, `p`.`lookaddons`, `p`.`lookwings`, `p`.`lookshader`, `p`.`lookaura`, `p`.`online`, `p`.`lookoutline`, `"<< categoryTable <<"`.`" << categoryName << "` AS `points` FROM `players` AS `p` INNER JOIN `accounts` AS `a` ON `p`.`account_id` = `a`.`id` LEFT JOIN `account_bans` AS `b` ON `p`.`account_id` = `b`.`account_id`, (SELECT @currank := 0, @prevrank := NULL, @row := 0) `r` WHERE  `group_id` < 2 AND `b`.`account_id` IS NULL ORDER  BY `" << categoryName << "` DESC) `t`";

		if (vocation[0] != 0 ){
			bool firstVocation = true;
			for (uint8_t i = 0; i < vocation.size(); ++i) {
				if (firstVocation) {
					query << " WHERE `vocation` = " << vocation[i];
					firstVocation = false;
				} else {
					query << " OR `vocation` = " << vocation[i];
				}
			}
		}

		query << ") `T` WHERE `rn` > " << startPage << " AND `rn` <= " << endPage;

	} else {
		query << "SELECT *,@row AS `entries`,( @ourrow DIV 10 ) + 1 AS `page` FROM (SELECT *,( @row := @row + 1 ) AS `rn`, @ourrow := IF(`id` = " << player->getGUID() << ", @row - 1, @ourrow) AS `rw` FROM   (SELECT `p`.`id`, `p`.`name`, `p`.`level`, `p`.`vocation`, `p`.`lookbody`, `p`.`lookfeet`, `p`.`lookhead`, `p`.`looklegs`, `p`.`looktype`, `p`.`lookaddons`, `p`.`lookwings`, `p`.`lookaura`, `p`.`online`, `p`.`lookoutline`, `p`.`lookshader`, `"<< categoryTable <<"`.`" << categoryName << "` AS `points` FROM `players` AS `p` INNER JOIN `accounts` AS `a` ON `p`.`account_id` = `a`.`id` LEFT JOIN `account_bans` AS `b` ON `p`.`account_id` = `b`.`account_id`, (SELECT @row := 0, @ourrow := 0) `r` WHERE  `group_id` < 2 AND `b`.`account_id` IS NULL ORDER  BY `" << categoryName << "` DESC) `t`";

		if (vocation[0] != 0 ){
			bool firstVocation = true;
			for (uint8_t i = 0; i < vocation.size(); ++i) {
				if (firstVocation) {
					query << " WHERE `vocation` = " << vocation[i];
					firstVocation = false;
				} else {
					query << " OR `vocation` = " << vocation[i];
				}
			}
		}

		query << ") `T` WHERE  `rn` > ( ( @ourrow DIV 10 ) * 10 ) AND `rn` <= ( ( ( @ourrow DIV 10 ) * 10 ) + 10 )";
	}


	uint32_t playerID = player->getID();
	std::function<void(DBResult_ptr, bool, uint64_t)> callback = [playerID, category, vocation, entriesPerPage](DBResult_ptr result, bool, uint64_t) {
		Player* player = g_game.getPlayerByID(playerID);
		if (!player) {
			return;
		}

		player->resetAsyncOngoingTask(PlayerAsyncTask_Highscore);
		if (!result) {
			player->sendHighscoresNoData();
			return;
		}

		uint16_t page = result->getNumber<uint16_t>("page");
		uint32_t pages = result->getNumber<uint32_t>("entries");
		pages += entriesPerPage - 1;
		pages /= entriesPerPage;

		std::vector<HighscoreCharacter> characters;
		characters.reserve(result->countResults());
		do {
			Outfit_t outfit;
			outfit.lookBody = result->getNumber<uint16_t>("lookbody");
			outfit.lookFeet = result->getNumber<uint16_t>("lookfeet");
			outfit.lookHead = result->getNumber<uint16_t>("lookhead");
			outfit.lookLegs = result->getNumber<uint16_t>("looklegs");
			outfit.lookType = result->getNumber<uint16_t>("looktype");
			outfit.lookAddons = result->getNumber<uint16_t>("lookaddons");
			outfit.lookWings = result->getNumber<uint16_t>("lookwings");
			outfit.lookAura = result->getNumber<uint16_t>("lookaura");
			outfit.lookShader = std::move(result->getString("lookshader"));
			outfit.lookOutline = std::move(result->getString("lookoutline"));
			characters.emplace_back(std::move(result->getString("name")), result->getNumber<uint64_t>("points"), result->getNumber<uint32_t>("id"), result->getNumber<uint32_t>("rn"), result->getNumber<uint16_t>("level"), result->getNumber<uint16_t>("vocation"), result->getNumber<uint16_t>("online"), outfit);
		} while (result->next());
		player->sendHighscores(characters, category, page, static_cast<uint16_t>(pages));
	};
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)), callback, true);
	player->addAsyncOngoingTask(PlayerAsyncTask_Highscore);
}
#endif

void Game::playerTournamentLeaderboard(Player* player, uint8_t leaderboardType)
{
	if (leaderboardType > 1) {
		return;
	}

	player->sendTournamentLeaderboard();
}

void Game::playerReportBug(Player* player, const std::string& message, const Position& position, uint8_t category)
{
	g_events->eventPlayerOnReportBug(player, message, position, category);
}

void Game::playerDebugAssert(Player* player, const std::string& assertLine, const std::string& date, const std::string& description, const std::string& comment)
{
	// TODO: move debug assertions to database
	FILE* file = fopen("client_assertions.txt", "a");
	if (file) {
		fprintf(file, "----- %s - %s (%s) -----\n", formatDate(time(nullptr)).c_str(), player->getName().c_str(), convertIPToString(player->getIP()).c_str());
		fprintf(file, "%s\n%s\n%s\n%s\n", assertLine.c_str(), date.c_str(), description.c_str(), comment.c_str());
		fclose(file);
	}
}

void Game::playerExtendedOpcode(Player* player, uint8_t opcode, const std::string& buffer)
{
	for (CreatureEvent* creatureEvent : player->getCreatureEvents(CREATURE_EVENT_EXTENDED_OPCODE)) {
		creatureEvent->executeExtendedOpcode(player, opcode, buffer);
	}
}

void Game::forceAddCondition(uint32_t creatureId, Condition* condition)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		delete condition;
		return;
	}

	creature->addCondition(condition, true);
}

void Game::forceRemoveCondition(uint32_t creatureId, ConditionType_t type)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	creature->removeCondition(type, true);
}

void Game::sendOfflineTrainingDialog(Player* player)
{
	if (!player) {
		return;
	}

	if (!player->hasModalWindowOpen(offlineTrainingWindow.id)) {
		player->sendModalWindow(offlineTrainingWindow);
	}
}

void Game::playerAnswerModalWindow(Player* player, uint32_t modalWindowId, uint8_t button, uint8_t choice)
{
	if (!player->hasModalWindowOpen(modalWindowId)) {
		return;
	}

	player->onModalWindowHandled(modalWindowId);

	// offline training, hardcoded
	if (modalWindowId == std::numeric_limits<uint32_t>::max()) {
		if (button == offlineTrainingWindow.defaultEnterButton) {
			if (choice == SKILL_MELEE || choice == SKILL_DISTANCE || choice == SKILL_FISHING || choice == SKILL_MAGLEVEL) {
				BedItem* bedItem = player->getBedItem();
				if (bedItem && bedItem->sleep(player)) {
					player->setOfflineTrainingSkill(choice);
					return;
				}
			}
		} else {
			player->sendTextMessage(MESSAGE_EVENT_ADVANCE, "Offline training aborted.");
		}

		player->setBedItem(nullptr);
	} else {
		for (auto creatureEvent : player->getCreatureEvents(CREATURE_EVENT_MODALWINDOW)) {
			creatureEvent->executeModalWindow(player, modalWindowId, button, choice);
		}
	}
}

void Game::updatePlayerEvent(uint32_t playerId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	if (player->hasScheduledUpdates(PlayerUpdate_Light)) {
		player->updateItemsLight();
	}
	player->resetScheduledUpdates();
}

void Game::updatePlayerStore(Player* player, bool changeFilters, std::string filterName, uint8_t filterRarity, uint8_t filterItemType, uint8_t categoryIndex)
{
	if (!player->canUpadteStore())
		return;
	std::map<uint64_t, PlayerInventorySellItem> tempUniqueItem;
	std::map<uint32_t, uint16_t> tempStackableItem;
	if (changeFilters)
		player->setShopFilters(filterName, filterRarity, filterItemType, categoryIndex);
	player->getAllItemTypeCountAndSubtype(tempUniqueItem, tempStackableItem);
	player->sendSaleItemList(tempUniqueItem, tempStackableItem, categoryIndex);
}

void Game::checkCreatureDeath(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	if (creature->getHealth() <= 0) {
		creature->onDeath();
	}
}

void Game::addPlayer(Player* player)
{
	const std::string& lowercase_name = asLowerCaseString(player->getName());
	mappedPlayerNames[lowercase_name] = player;
	wildcardTree.insert(lowercase_name);
	players[player->getID()] = player;
}

void Game::removePlayer(Player* player)
{
	const std::string& lowercase_name = asLowerCaseString(player->getName());
	mappedPlayerNames.erase(lowercase_name);
	wildcardTree.remove(lowercase_name);
	players.erase(player->getID());
}

void Game::addNpc(Npc* npc)
{
	npcs[npc->getID()] = npc;
}

void Game::removeNpc(Npc* npc)
{
	npcs.erase(npc->getID());
}

void Game::addMonster(Monster* monster)
{
	monsters[monster->getID()] = monster;
}

void Game::removeMonster(Monster* monster)
{
	monsters.erase(monster->getID());
}

Guild* Game::getGuild(uint32_t id) const
{
	auto it = guilds.find(id);
	if (it == guilds.end()) {
		return nullptr;
	}
	return it->second;
}

void Game::addGuild(Guild* guild)
{
	guilds[guild->getId()] = guild;
}

void Game::removeGuild(uint32_t guildId)
{
	guilds.erase(guildId);
}

#if GAME_FEATURE_BROWSEFIELD > 0
void Game::decreaseBrowseFieldRef(const Position& pos)
{
	Tile* tile = map.getTile(pos.x, pos.y, pos.z);
	if (!tile) {
		return;
	}

	auto it = browseFields.find(tile);
	if (it != browseFields.end()) {
		it->second->decrementReferenceCounter();
	}
}
#endif

void Game::internalRemoveItems(std::vector<Item*>& itemList, uint32_t amount, bool stackable)
{
	if (stackable) {
		for (Item* item : itemList) {
			if (item->getItemCount() > amount) {
				internalRemoveItem(item, amount);
				break;
			} else {
				amount -= item->getItemCount();
				internalRemoveItem(item);
			}
		}
	} else {
		for (Item* item : itemList) {
			internalRemoveItem(item);
		}
	}
}

BedItem* Game::getBedBySleeper(uint32_t guid) const
{
	auto it = bedSleepersMap.find(guid);
	if (it == bedSleepersMap.end()) {
		return nullptr;
	}
	return it->second;
}

void Game::setBedSleeper(BedItem* bed, uint32_t guid)
{
	bedSleepersMap[guid] = bed;
}

void Game::removeBedSleeper(uint32_t guid)
{
	auto it = bedSleepersMap.find(guid);
	if (it != bedSleepersMap.end()) {
		bedSleepersMap.erase(it);
	}
}

Item* Game::getUniqueItem(uint16_t uniqueId)
{
	auto it = uniqueItems.find(uniqueId);
	if (it == uniqueItems.end()) {
		return nullptr;
	}
	return it->second;
}

bool Game::addUniqueItem(uint16_t uniqueId, Item* item)
{
	auto result = uniqueItems.emplace(uniqueId, item);
	if (!result.second) {
		std::cout << "Duplicate unique id: " << uniqueId << std::endl;
	}
	return result.second;
}

void Game::removeUniqueItem(uint16_t uniqueId)
{
	auto it = uniqueItems.find(uniqueId);
	if (it != uniqueItems.end()) {
		uniqueItems.erase(it);
	}
}

bool Game::reloadCreatureScripts(bool fromLua, bool reload)
{
	std::map<uint32_t, std::vector<std::string>> cacheCreaturesEvents;
	#define cacheCreatures(container)																	\
		do {																							\
			for (const auto& it : container) {															\
				CreatureEventList& creatureEvents = it.second->getCreatureEvents();						\
				for (auto creatureEvent : creatureEvents) {												\
					cacheCreaturesEvents[it.second->getID()].emplace_back(creatureEvent->getName());	\
				}																						\
				it.second->resetEventsRegistered();														\
				creatureEvents.clear();																	\
			}																							\
		} while(0)

	cacheCreatures(players);
	cacheCreatures(npcs);
	cacheCreatures(monsters);
	#undef cacheCreatures

	bool result = true;
	if (fromLua) {
		if (reload) {
			result = g_creatureEvents->reload();
		}
		g_creatureEvents->clear(true);
		g_scripts->loadScripts("scripts", false, true);
	} else {
		result = g_creatureEvents->reload();
	}

	for (const auto& it : cacheCreaturesEvents) {
		Creature* creature = getCreatureByID(it.first);
		if (creature) {
			for (const std::string& creatureEvent : it.second) {
				creature->registerCreatureEvent(creatureEvent);
			}
		}
	}
	return result;
}

bool Game::reload(ReloadTypes_t reloadType)
{
	switch (reloadType) {
		case RELOAD_TYPE_ACTIONS: return g_actions->reload();
		case RELOAD_TYPE_AURAS: return auras.reload();
		case RELOAD_TYPE_SHADERS: return shaders.reload();
		case RELOAD_TYPE_OUTLINES: return outlines.reload();
		case RELOAD_TYPE_CHAT: return g_chat->load();
		case RELOAD_TYPE_CONFIG: return g_config.reload();
		case RELOAD_TYPE_CREATURESCRIPTS: return reloadCreatureScripts();
		case RELOAD_TYPE_EVENTS: return g_events->load();
		case RELOAD_TYPE_GLOBALEVENTS: return g_globalEvents->reload();
		case RELOAD_TYPE_ITEMS: return Item::items.reload();
		case RELOAD_TYPE_MONSTERS: return g_monsters.reload();
		case RELOAD_TYPE_MODULES: return g_modules.load();
		case RELOAD_TYPE_MOUNTS:
		#if GAME_FEATURE_MOUNTS > 0
			return mounts.reload();
		#else
			return false;
		#endif
		case RELOAD_TYPE_MOVEMENTS: return g_moveEvents->reload();
		case RELOAD_TYPE_NPCS: {
			Npcs::reload();
			return true;
		}

		case RELOAD_TYPE_QUESTS: return quests.reload();
		case RELOAD_TYPE_RAIDS: return raids.reload() && raids.startup();

		case RELOAD_TYPE_SPELLS: {
			if (!g_spells->reload()) {
				std::cout << "[Error - Game::reload] Failed to reload spells." << std::endl;
				std::terminate();
			} else if (!g_monsters.reload()) {
				std::cout << "[Error - Game::reload] Failed to reload monsters." << std::endl;
				std::terminate();
			}
			return true;
		}

		case RELOAD_TYPE_TALKACTIONS: return g_talkActions->reload();

		case RELOAD_TYPE_WEAPONS: {
			bool results = g_weapons->reload();
			g_weapons->loadDefaults();
			return results;
		}

		case RELOAD_TYPE_WINGS: return wings.reload();

		case RELOAD_TYPE_SCRIPTS: {
			// commented out stuff is TODO, once we approach further in revscriptsys
			g_actions->clear(true);
			g_moveEvents->clear(true);
			g_talkActions->clear(true);
			g_globalEvents->clear(true);
			g_weapons->clear(true);
			g_weapons->loadDefaults();
			g_spells->clear(true);
			reloadCreatureScripts(true, false); //Keep it as the last because it'll call loadScripts
			/*
			Npcs::reload();
			raids.reload() && raids.startup();
			Item::items.reload();
			quests.reload();
			mounts.reload();
			auras.reload();
			shaders.reload();
			wings.reload();
			g_config.reload();
			g_events->load();
			g_chat->load();
			*/
			return true;
		}

		default: {
			if (!g_spells->reload()) {
				std::cout << "[Error - Game::reload] Failed to reload spells." << std::endl;
				std::terminate();
			} else if (!g_monsters.reload()) {
				std::cout << "[Error - Game::reload] Failed to reload monsters." << std::endl;
				std::terminate();
			}

			g_actions->reload();
			g_config.reload();
			g_monsters.reload();
			g_moveEvents->reload();
			Npcs::reload();
			raids.reload() && raids.startup();
			g_talkActions->reload();
			Item::items.reload();
			g_weapons->reload();
			g_weapons->clear(true);
			g_weapons->loadDefaults();
			quests.reload();
			auras.reload();
			shaders.reload();
			outlines.reload();
			mounts.reload();
			wings.reload();
			g_globalEvents->reload();
			g_events->load();
			g_chat->load();
			g_actions->clear(true);
			g_moveEvents->clear(true);
			g_talkActions->clear(true);
			g_globalEvents->clear(true);
			g_spells->clear(true);
			reloadCreatureScripts(true); //Keep it as the last because it'll call loadScripts
			return true;
		}
	}
	return true;
}

Item* Game::getRealUniqueItem(uint64_t uniqueId)
{
	std::lock_guard<std::recursive_mutex> lock(realUniqueItemsMutex);
	auto it = realUniqueItems.find(uniqueId);
	if (it == realUniqueItems.end()) {
		return nullptr;
	}
	return it->second;
}

uint64_t Game::addRealUniqueItem(uint64_t uniqueId, Item* item)
{
	if (uniqueId == 0) {
		return false;
	}

	std::lock_guard<std::recursive_mutex> lock(realUniqueItemsMutex);
	auto result = realUniqueItems.emplace(uniqueId, item);
	if (!result.second) {
		// UID already exists - remove item's old UID before assigning new one
		uint32_t oldUID = item->getRealUID();
		if (oldUID > 0) {
			auto it = realUniqueItems.find(oldUID);
			if (it != realUniqueItems.end() && it->second == item) {
				realUniqueItems.erase(it);
			}
		}
		return addRealUniqueItem(nextItemUID(), item);
	}

	item->setRealUID(uniqueId);
	return uniqueId;
}

void Game::removeRealUniqueItem(uint64_t uniqueId)
{
	if (uniqueId == 0 || shuttingDown) {
		return;
	}
	std::lock_guard<std::recursive_mutex> lock(realUniqueItemsMutex);
	auto it = realUniqueItems.find(uniqueId);
	if (it != realUniqueItems.end()) {
		realUniqueItems.erase(it);
	}
}

void Game::marketOffers(Player* player, uint16_t page, uint8_t currency, uint8_t rarity, uint8_t category, const std::string& text, uint8_t sort, uint8_t sortud, uint8_t myOffers, const std::vector<Attribute>& attr)
{
	if (player->hasAsyncOngoingTask(PlayerAsyncTask_MarketOffers)) {
		return;
	}

	uint8_t entriesPerPage = 10;
	std::string sortByItemType;
	std::string sortByUD;
	
	switch (sort) {
		case 1: sortByItemType = "created"; break;
		case 2: sortByItemType = "rarity"; break;
		case 3: sortByItemType = "name"; break;
		case 4: sortByItemType = "seller"; break;
		case 5: sortByItemType = "amount"; break;
		case 6: sortByItemType = "price"; break;
		case 7: sortByItemType = "currency"; break;
		default: {
			sortByItemType = "created";
			break;
		}
	}

	if (myOffers != 0) {
		entriesPerPage = 50;
		if (sortByItemType == "seller") {
			sortByItemType = "created";
		}
	}

	switch (sortud) {
		case 1: sortByUD = "DESC"; break;
		case 2: sortByUD = "ASC"; break;
		default: {
			sortByUD = "DESC";
			break;
		}
	}

	std::stringExtended query(1024);
	uint32_t startPage = (static_cast<uint32_t>(page - 1) * static_cast<uint32_t>(entriesPerPage));
	uint32_t endPage = startPage + static_cast<uint32_t>(entriesPerPage);
	query << "SELECT *, @row AS `entries`, "<< page <<" AS `page` FROM (SELECT *, ( @row := @row + 1 ) AS `rn` FROM (SELECT `id`, `clientId`, `seller`, `amount`, `created`, `price`, `currency`, `name`, `rarity`, `itemtype`, `player_id`, `account_id` FROM `market_offers`, (SELECT @currank := 0, @prevrank := NULL, @row := 0) `r` ORDER  BY `" << sortByItemType << "` " << sortByUD << ") `t` WHERE ";

	if (category != 0) {
		query << "`itemtype` = '" << category << "' AND ";
	}

	if (currency != 0) {
		query << "`currency` = '" << currency << "' AND ";
	}

	if (rarity != 0) {
		rarity -= 1;
		query << "`rarity` = '" << rarity << "' AND ";
	}

	if (myOffers != 0) {
		query << "`account_id` = " << player->getAccount() << " AND ";
	}

	std::string escapedText = g_database.escapeString(text);
	if (escapedText.length() >= 2 && escapedText.front() == '\'' && escapedText.back() == '\'') {
		escapedText = escapedText.substr(1, escapedText.length() - 2);
	}
	query << "`name` LIKE '%" << escapedText << "%' COLLATE utf8mb4_general_ci";

	if (!attr.empty()) {
		for (const auto& a : attr) {
			query << " AND EXISTS (SELECT 1 FROM `market_attributes` ma"
				  << " WHERE ma.marketId = `t`.`id`"
				  << " AND ma.attrId = " << a.id;
	
			if (a.min != ATTRIBUTE_EMPTY) {
				query << " AND ma.value >= " << a.min;
			}
			if (a.max != ATTRIBUTE_EMPTY) {
				query << " AND ma.value <= " << a.max;
			}
	
			query << ")";
		}
	}
	query << ") `T` WHERE `rn` > " << startPage << " AND `rn` <= " << endPage;

	uint32_t playerID = player->getID();
	std::function<void(DBResult_ptr, bool, uint64_t)> callback = [playerID, entriesPerPage, myOffers](DBResult_ptr result, bool, uint64_t) {
		Player* player = g_game.getPlayerByID(playerID);
		if (!player) {
			return;
		}

		player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
		if (!result) {
			player->sendMarketOffersNoData();
			return;
		}

		uint16_t page = result->getNumber<uint16_t>("page");
		uint32_t pages = result->getNumber<uint32_t>("entries");
		pages += entriesPerPage - 1;
		pages /= entriesPerPage;

		std::vector<MarketOffer> offer;
		offer.reserve(result->countResults());
		do {
			offer.emplace_back(result->getNumber<uint64_t>("id"), result->getNumber<uint32_t>("clientId"), std::move(result->getString("seller")), result->getNumber<uint16_t>("amount"), result->getNumber<uint64_t>("created"), result->getNumber<double>("price"), result->getNumber<uint16_t>("currency"), std::move(result->getString("name")), result->getNumber<uint16_t>("rarity"));
		} while (result->next());
		player->sendMarketOffers(offer, page, static_cast<uint16_t>(pages), myOffers);
	};
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)), callback, true);
	player->addAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
}

void Game::creatureRegenerationHealth(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	int32_t healthGain = creature->getHealthTotalGain();
	bool minusValue = healthGain < 0;

	if (!creature->isFullHealth() || minusValue) {
		double healthRestGain = creature->getHealthRestGain();
		if (healthRestGain != 0) {
			double healthRest = creature->getHealthRest();
			healthRest += healthRestGain;
			if (healthRest > 1) {
				if (minusValue)
					healthGain -= 1;
				else 
					healthGain += 1;
				healthRest -= 1.0;
			}
			creature->setHealthRest(healthRest);
		}
		
		creature->changeHealth(healthGain);
	}


	if (minusValue) {
		if (Player* player = creature->getPlayer()) {
			const auto& minusRegenEvents = player->getCreatureEvents(CREATURE_EVENT_MINUSREGENHP);
			if (!minusRegenEvents.empty()) {
				for (CreatureEvent* creatureEvent : minusRegenEvents) {
					creatureEvent->executeMinusRegenHP(player, healthGain);
				}
			}

			healthGain = -healthGain * 2;

			if (creature->getHealth() <= healthGain) {
				const auto& endScriptsRegenEvents = player->getCreatureEvents(CREATURE_EVENT_ENDSCRIPTS_REGEN);
				if (!endScriptsRegenEvents.empty()) {
					for (CreatureEvent* creatureEvent : endScriptsRegenEvents) {
						creatureEvent->executeEndScriptsRegen(player, true);
					}
				}
			}
		}
	}
	g_dispatcher.addEvent(creature->getHealthGainTicks(), std::bind(&Game::creatureRegenerationHealth, this, creatureId));
}

void Game::creatureRegenerationEnergyShield(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	if (creature->canRegenerateShield() && !creature->isFullEnergyShield()) {
		int32_t valueGain = creature->getEnergyShieldTotalGain();
		double valueRestGain = creature->getEnergyShieldRestGain();
		if (valueRestGain != 0) {
			double valueRest = creature->getEnergyShieldRest();
			valueRest += valueRestGain;
			if (valueRest > 1) {
				valueGain += 1;
				valueRest -= 1.0;
			}
			creature->setEnergyShieldRest(valueRest);
		}
	
		creature->changeEnergyShield(valueGain);
	}

	g_dispatcher.addEvent(creature->getEnergyShieldGainTicks(), std::bind(&Game::creatureRegenerationEnergyShield, this, creatureId));
}

void Game::creatureRegenerationEnergyShieldForce(uint32_t creatureId)
{
	Creature* creature = getCreatureByID(creatureId);
	if (!creature) {
		return;
	}

	if (!creature->isFullEnergyShield()) {
		int32_t valueGain = creature->getEnergyShieldTotalGainForce();
		double valueRestGain = creature->getEnergyShieldRestGainForce();
		if (valueRestGain != 0) {
			double valueRest = creature->getEnergyShieldRestForce();
			valueRest += valueRestGain;
			if (valueRest > 1) {
				valueGain += 1;
				valueRest -= 1.0;
			}
			creature->setEnergyShieldRestForce(valueRest);
		}
	
		creature->changeEnergyShield(valueGain);
	}

	g_dispatcher.addEvent(creature->getEnergyShieldGainTicksForce(), std::bind(&Game::creatureRegenerationEnergyShieldForce, this, creatureId));
}

void Game::playerRegenerationMana(uint32_t playerId)
{
	Player* player = getPlayerByID(playerId);
	if (!player) {
		return;
	}

	int32_t valueGain = player->getManaTotalGain();
	bool minusValue = valueGain < 0;

	if (!player->isFullMana() || minusValue) {
		double valueRestGain = player->getManaRestGain();
		if (valueRestGain != 0) {
			double valueRest = player->getManaRest();
			valueRest += valueRestGain;
			if (valueRest > 1) {
				if (minusValue)
					valueGain -= 1;
				else 
					valueGain += 1;
				valueRest -= 1.0;
			}
			player->setManaRest(valueRest);
		}
	
		player->changeMana(valueGain);
	}

	if (minusValue && player->getMana() <= 0) {
		const auto& events = player->getCreatureEvents(CREATURE_EVENT_ENDSCRIPTS_REGEN);
		if (!events.empty()) {
			for (CreatureEvent* creatureEvent : events) {
				creatureEvent->executeEndScriptsRegen(player, false);
			}
		}
	}

	g_dispatcher.addEvent(player->getManaGainTicks(), std::bind(&Game::playerRegenerationMana, this, playerId));
}

bool Game::getItemBlobForDatabase(Item* item, const char*& outputBlob, size_t& outputSize) {
    if (!item) return false;

    PropWriteStream propWriteStream;
    propWriteStream.write<uint16_t>(item->getID());
    item->serializeAttr(propWriteStream);
    propWriteStream.write<uint8_t>(0x00);

    const char* data = propWriteStream.getStream(outputSize);
    if (outputSize < 3) return false;

    char* blobCopy = new char[outputSize];
    memcpy(blobCopy, data, outputSize);
    outputBlob = blobCopy;
    return true;
}

Item* Game::createItemFromBlob(const char* blob, size_t size) {
    if (!blob || size == 0) {
        return nullptr;
    }

    PropStream propStream;
    propStream.init(blob, size);

    // Read item ID
    uint16_t id;
    if (!propStream.read<uint16_t>(id)) {
        std::cout << "[Warning - Game::createItemFromBlob] Failed to read item ID" << std::endl;
        return nullptr;
    }

    // Create the item
    Item* item = Item::CreateItem(id, 0);
    if (!item) {
        std::cout << "[Warning - Game::createItemFromBlob] Failed to create item with ID " << id << std::endl;
        return nullptr;
    }

    // Unserialize attributes
    if (!item->unserializeAttr(propStream)) {
        std::cout << "[Warning - Game::createItemFromBlob] Failed to unserialize attributes for item " << id << std::endl;
        delete item;
        return nullptr;
    }

    return item;
}

void Game::addItemToMarket(Player* player, Item* item, uint16_t count, uint8_t itemType, uint8_t currency, double price, uint32_t marketId)
{
	if (player->hasAsyncOngoingTask(PlayerAsyncTask_MarketOffers)) {
		return;
	}

	player->addAsyncOngoingTask(PlayerAsyncTask_MarketOffers);

	const char* blobData;
	size_t blobSize;
	if (!getItemBlobForDatabase(item, blobData, blobSize)) {
		std::cout << "[Warning - Game::addItemToMarket] Something went wrong creating blob from item " << std::endl;
		player->addInfoLog("[MARKET] Failed to create blob for item.");
		player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
		return;
	}

	uint32_t rarityId = item->getColor();
	if (rarityId == 0) {
		auto rarity = item->getCustomAttribute("rarity");
		if (rarity) {
			rarityId = rarity->getInt();
		}
	}

	uint32_t realUID = item->getRealUID();
	uint32_t itemId = item->getID();
	// player->addInfoLog("[MARKET] Attempting to list item: " + item->getName() +
	// 	" | Count: " + std::to_string(count) +
	// 	" | Price: " + std::to_string(price) + " " + currency +
	// 	" | Rarity: " + std::to_string(rarityId) +
	// 	" | ItemID: " + std::to_string(itemId) + 
	// 	" | Market ID: " + std::to_string(marketId));

	std::stringExtended query(512);
	query << "INSERT INTO `market_offers` (`id`, `player_id`, `account_id`, `clientId`, `itemtype`, `seller`, `amount`, `created`, `price`, `currency`, `name`, `rarity`, `item` ) VALUES ("
		<< marketId << ", "
		<< player->getGUID() << ", "
		<< player->getAccount() << ", "
		<< item->getClientID() << ", "
		<< itemType << ", "
		<< g_database.escapeString(player->getName()) << ", "
		<< count << ", "
		<< time(nullptr) + 48 * 60 * 60 << ", "
		<< std::to_string(price) << ", "
		<< currency << ", "
		<< g_database.escapeString(item->getName()) << ", "
		<< rarityId << ", "
		<< g_database.escapeBlob(blobData, blobSize) << ");";
		
	uint32_t playerID = player->getID();
	std::function<void(DBResult_ptr, bool, uint64_t)> callback = [playerID, marketId, realUID, itemId, count](DBResult_ptr result, bool, uint64_t) {
		Player* player = g_game.getPlayerByID(playerID);
		if (!player) {
			return;
		}

		uint32_t idToSend = 0;
		Container* storage = player->getTempStorage();
		if (storage) {
			Item* itemToDelete;
			if (realUID > 0) {
				idToSend = realUID;
				itemToDelete = storage->getItemByUID(realUID);
			} else {
				idToSend = itemId;
				itemToDelete = storage->getItemById(itemId);
			}

			if (itemToDelete)
				storage->removeThing(itemToDelete, count);
		}

		player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);

		// player->addInfoLog("[MARKET] Successfully listed item: " + itemId +
		// 	" | Count: " + std::to_string(count) +
		// 	" | Market ID: " + std::to_string(marketId));

		g_events->eventPlayerOnMarketOfferAdd(player, marketId, idToSend);
	};


	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)), callback);

	delete[] blobData;
}

void Game::checkForExpiredOffers()
{
    g_dispatcher.addEvent(EVENT_CHECK_MARKET_OFFERS, std::bind(&Game::checkForExpiredOffers, this));

    std::stringExtended markQuery(512);
    markQuery << "UPDATE `market_offers` SET `status` = 1 WHERE `created` <= " << time(nullptr) << " AND `status` = 0;";

    std::function<void(DBResult_ptr, bool, uint64_t)> markCallback = [](DBResult_ptr, bool, uint64_t) {
        std::stringExtended selectQuery(512);
        selectQuery << "SELECT `id`, `player_id`, `account_id`, `name`, `item`, `amount` FROM `market_offers` WHERE `status` = 1;";

        std::function<void(DBResult_ptr, bool, uint64_t)> processCallback = [](DBResult_ptr result, bool, uint64_t) {
            if (!result) {
                return;
            }

            do {
                uint32_t playerId = result->getNumber<uint32_t>("player_id");
                uint32_t accountId = result->getNumber<uint32_t>("account_id");
                uint32_t marketId = result->getNumber<uint32_t>("id");
                uint32_t amount = result->getNumber<uint32_t>("amount");
                std::string name = std::move(result->getString("name"));
                unsigned long itemSize;
                const char* blobItem = result->getStream("item", itemSize);

                std::stringExtended deleteQuery(512);
                deleteQuery << "DELETE FROM `market_offers` WHERE `id` = " << marketId << ";";
                g_databaseTasks.addTask(std::move(static_cast<std::string&>(deleteQuery)));

                Player* player = g_game.getPlayerByGUID(playerId);
                if (player) {
					// CRITICAL: If player is saving async (logging out), treat as offline
					// Don't modify their items during save - store in market_expired instead
					if (player->isSaving.load()) {
						std::cout << "[Market] Player " << player->getName() << " is logging out (async save in progress). Storing expired offer for offline delivery." << std::endl;
						std::stringExtended insertExpiredQuery(512);
						insertExpiredQuery << "INSERT INTO `market_expired` (`player_id`, `account_id`, `amount`, `item`) VALUES ("
										   << playerId << ", "
										   << accountId << ", "
										   << amount << ", "
										   << g_database.escapeBlob(blobItem, itemSize) << ");";
						g_databaseTasks.addTask(std::move(static_cast<std::string&>(insertExpiredQuery)));
						continue;
					}
					
                    Item* item = g_game.createItemFromBlob(blobItem, itemSize);
                    if (item) {
                        item->setItemCount(amount);
                        g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
                        std::stringExtended msg(128);
                        msg << "Offer x" << amount << " " << name << " has expired, check your inbox.";
                        player->sendTextMessage(MESSAGE_INFO_DESCR, msg);
						// player->addInfoLog("[MARKET] " + msg);
                    } else {
						// player->addInfoLog("[MARKET] Something went wrong with retiving item" + name);
                        std::cout << "checkForExpiredOffers | Something went wrong retrieving item " << name << std::endl;
                    }
                } else {
                    std::stringExtended insertExpiredQuery(512);
                    insertExpiredQuery << "INSERT INTO `market_expired` (`player_id`, `account_id`, `amount`, `item`) VALUES ("
                                       << playerId << ", "
                                       << accountId << ", "
                                       << amount << ", "
                                       << g_database.escapeBlob(blobItem, itemSize) << ");";
                    g_databaseTasks.addTask(std::move(static_cast<std::string&>(insertExpiredQuery)));
                }
            } while (result->next());
        };

        g_databaseTasks.addTask(std::move(static_cast<std::string&>(selectQuery)), processCallback, true);
    };

    g_databaseTasks.addTask(std::move(static_cast<std::string&>(markQuery)), markCallback, false);
}

void Game::checkPlayersExpiredOffers(Player* player)
{
    uint32_t playerId = player->getID();
	uint32_t accountId = player->getAccount();
    std::stringExtended updateQuery(256);
    updateQuery << "UPDATE `market_expired` SET `status` = 1 WHERE `account_id` = " << accountId << " AND `status` = 0;";

    std::function<void(DBResult_ptr, bool, uint64_t)> updateCallback = [playerId, accountId](DBResult_ptr, bool, uint64_t) {
        std::stringExtended selectQuery(512);
        selectQuery << "SELECT `id`, `item`, `amount` FROM `market_expired` WHERE `account_id` = " << accountId << " AND `status` = 1;";

        std::function<void(DBResult_ptr, bool, uint64_t)> selectCallback = [playerId](DBResult_ptr result, bool, uint64_t) {
            if (!result) {
                return;
            }

            Player* player = g_game.getPlayerByID(playerId);
            if (!player) {
                return;
            }

            do {
                unsigned long itemSize;
                const char* blobItem = result->getStream("item", itemSize);
                uint32_t amount = result->getNumber<uint32_t>("amount");
                uint32_t marketId = result->getNumber<uint32_t>("id");

                Item* item = g_game.createItemFromBlob(blobItem, itemSize);
                if (item) {
                    item->setItemCount(amount);
                    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

                    std::stringExtended deleteQuery(256);
                    deleteQuery << "DELETE FROM `market_expired` WHERE `id` = " << marketId << ";";
                    g_databaseTasks.addTask(std::move(static_cast<std::string&>(deleteQuery)));
					
					// Note: No need to check isSaving here - this runs on login, before async save starts
                } else {
                    std::cout << "checkPlayersExpiredOffers | Something went wrong retrieving item " << std::endl;
                }
            } while (result->next());
        };

        g_databaseTasks.addTask(std::move(static_cast<std::string&>(selectQuery)), selectCallback, true);
    };

    g_databaseTasks.addTask(std::move(static_cast<std::string&>(updateQuery)), updateCallback, false);
}


std::unordered_map<uint32_t, Item*> Game::getMarketItems()
{
	std::unordered_map<uint32_t, Item*> marketItems;

	DBResult_ptr result = g_database.storeQuery("SELECT `id`, `item` FROM `market_offers`");
	if (!result) {
		return marketItems;
	}

	do {
		uint32_t marketId = result->getNumber<uint32_t>("id");
		unsigned long itemSize;
		const char* blobItem = result->getStream("item", itemSize);
		Item* item = g_game.createItemFromBlob(blobItem, itemSize);
		if (item) {
			marketItems[marketId] = item;
		} else {
			std::cout << "getMarketItems | something wrong with item with marketId" << marketId << std::endl;
		}
	} while (result->next());

	return marketItems;
}

void Game::cancelMarketOffer(Player* player, uint32_t marketId)
{
	if (player->hasAsyncOngoingTask(PlayerAsyncTask_MarketOffers)) {
		return;
	}

    uint32_t playerId = player->getID();
	uint32_t accountId = player->getAccount();

    std::stringExtended updateQuery(512);
    updateQuery << "UPDATE `market_offers` SET `status` = 1 WHERE `account_id` = " << accountId
                << " AND `id` = " << marketId << " AND `status` = 0;";

    std::function<void(DBResult_ptr, bool, uint64_t)> updateCallback = [playerId, marketId, accountId](DBResult_ptr, bool, uint64_t) {
        std::stringExtended selectQuery(512);
        selectQuery << "SELECT `id`, `item`, `amount`, `created` FROM `market_offers` WHERE `account_id` = "
                    << accountId << " AND `id` = " << marketId << " AND `status` = 1;";

        std::function<void(DBResult_ptr, bool, uint64_t)> selectCallback = [playerId](DBResult_ptr result, bool, uint64_t) {
            Player* player = g_game.getPlayerByID(playerId);
            if (!player) {
                return;
            }

            if (!result) {
                player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
                return;
            }
			
			// CRITICAL: If player is saving (logging out), deny cancel operation
			if (player->isSaving.load()) {
				player->sendMarketResponse(3, "Cannot cancel offers while logging out. Please try again after logging in.");
				player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
				return;
			}

            do {
                unsigned long itemSize;
                const char* blobItem = result->getStream("item", itemSize);
                uint32_t amount = result->getNumber<uint32_t>("amount");
                uint32_t marketId = result->getNumber<uint32_t>("id");
                uint32_t created = result->getNumber<uint32_t>("created");
                created -= time(nullptr);

                if (created <= (5 * 60)) {
                    player->sendMarketResponse(3, "Market offers that expire soon cannot be canceled.");

                    std::stringExtended revertQuery(256);
                    revertQuery << "UPDATE `market_offers` SET `status` = 0 WHERE `id` = " << marketId << ";";
                    g_databaseTasks.addTask(std::move(static_cast<std::string&>(revertQuery)));

                    player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
                    return;
                }

                Item* item = g_game.createItemFromBlob(blobItem, itemSize);
                if (item) {
                    item->setItemCount(amount);
                    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

					player->sendMarketResponse(4, "Item was successfully removed from the market, check your inbox.");
                    std::stringExtended deleteQuery(256);
                    deleteQuery << "DELETE FROM `market_offers` WHERE `id` = " << marketId << ";";
                    g_databaseTasks.addTask(std::move(static_cast<std::string&>(deleteQuery)));

                } else {
                    std::cout << "cancelMarketOffer | Something went wrong with retrieving item " << std::endl;
                }
            } while (result->next());

            player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
        };

        g_databaseTasks.addTask(std::move(static_cast<std::string&>(selectQuery)), selectCallback, true);
    };

    player->addAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
    g_databaseTasks.addTask(std::move(static_cast<std::string&>(updateQuery)), updateCallback, false);
}

void Game::buyMarketOffer(Player* buyer, uint32_t marketId, uint32_t amount)
{
	if (buyer->hasAsyncOngoingTask(PlayerAsyncTask_MarketOffers)) {
		return;
	}

	uint32_t buyerId = buyer->getID();
	std::stringExtended updateQuery(512);
	updateQuery << "UPDATE `market_offers` SET `status` = 2 WHERE `id` = " << marketId << " AND `status` = 0;";

	std::function<void(DBResult_ptr, bool, uint64_t)> updateCallback = [buyerId, marketId, amount](DBResult_ptr, bool, uint64_t affectedRows) {
		if (affectedRows != 1) {
			Player* player = g_game.getPlayerByID(buyerId);
			if (player) {
				player->sendMarketResponse(2, "This market offer is no longer available.");
				player->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
			}

			std::stringExtended unlockQuery(128);
			unlockQuery << "UPDATE `market_offers` SET `status` = 0 WHERE `id` = " << marketId << ";";
			g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
			return;
		}

		std::stringExtended selectQuery(512);
		selectQuery << "SELECT `player_id`, `account_id`, `item`, `amount`, `price`, `currency`, `name`, `rarity`, `clientId` FROM `market_offers` WHERE `id` = " << marketId << " AND `status` = 2;";

		std::function<void(DBResult_ptr, bool, uint64_t)> selectCallback = [buyerId, marketId, amount](DBResult_ptr selectResult, bool, uint64_t) {
			Player* buyer = g_game.getPlayerByID(buyerId);
			if (!buyer || !selectResult) {
				std::stringExtended unlockQuery(128);
				unlockQuery << "UPDATE `market_offers` SET `status` = 0 WHERE `id` = " << marketId << ";";
				g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
				if (buyer) {
					buyer->sendMarketResponse(2, "Market offer no longer exists.");
					buyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
				}
				return;
			}
			
			// CRITICAL: If buyer is saving (logging out), deny buy operation
			if (buyer->isSaving.load()) {
				buyer->sendMarketResponse(2, "Cannot buy offers while logging out. Please try again after logging in.");
				buyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
				std::stringExtended unlockQuery(128);
				unlockQuery << "UPDATE `market_offers` SET `status` = 0 WHERE `id` = " << marketId << ";";
				g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
				return;
			}

			uint32_t sellerID = selectResult->getNumber<uint32_t>("player_id");
			uint32_t sellerAID = selectResult->getNumber<uint32_t>("account_id");
			uint32_t offerAmount = selectResult->getNumber<uint32_t>("amount");
			double pricePerItem = selectResult->getNumber<double>("price");
			uint16_t currency = selectResult->getNumber<uint16_t>("currency");
			uint16_t rarity = selectResult->getNumber<uint16_t>("rarity");
			uint32_t clientId = selectResult->getNumber<uint16_t>("clientId");
			unsigned long itemSize;
			const char* blobItem = selectResult->getStream("item", itemSize);
			std::string name = selectResult->getString("name");

			uint64_t buyerGuid = buyer->getGUID();
			uint64_t buyerAccountId = buyer->getAccount();
			double totalPrice = pricePerItem * static_cast<double>(amount);

			if (buyerAccountId == sellerAID) {
				buyer->sendMarketResponse(2, "You cannot buy your own offers.");

				std::stringExtended unlockQuery(128);
				unlockQuery << "UPDATE `market_offers` SET `status` = 0 WHERE `id` = " << marketId << ";";
				g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));

				buyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
				return;
			}

			if (amount > offerAmount) {
				buyer->sendMarketResponse(2, "Not enough items available in this offer, item count: " + offerAmount);

				std::stringExtended unlockQuery(128);
				unlockQuery << "UPDATE `market_offers` SET `status` = 0 WHERE `id` = " << marketId << ";";
				g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));

				buyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
				return;
			}

			auto completeTransaction = [=](double totalPrice, uint8_t currency) {
				Player* currentBuyer = g_game.getPlayerByID(buyerId);
				if (!currentBuyer) {
					std::stringExtended unlockQuery(128);
					unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
					g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
					return;
				}

				// CRITICAL FIX: Check payment BEFORE creating/adding item
				Player* seller = g_game.getPlayerByGUID(sellerID);
					if (currency == 1) {
						// currency 1 = gold (integers) - round to nearest integer for money operations
						uint64_t intTotal = static_cast<uint64_t>(std::llround(totalPrice));
						if (!currentBuyer->removeTotalMoney(intTotal)) {
						currentBuyer->sendMarketResponse(2, "You do not have enough money to buy this offer.");
						std::stringExtended unlockQuery(128);
						unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
						g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
						currentBuyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
						return;
					}
				} else if (currency == 2) {
					std::stringExtended deductQuery(128);
					deductQuery << "UPDATE `accounts` SET `coins` = `coins` - " << std::to_string(totalPrice) << " WHERE `id` = " << buyerAccountId << ";";
					g_databaseTasks.addTask(std::move(static_cast<std::string&>(deductQuery)));
				}

				// NOW create and add item after payment is confirmed
				Item* item = g_game.createItemFromBlob(blobItem, itemSize);
				if (!item) {
					currentBuyer->sendMarketResponse(2, "Failed to retrieve item data. Your payment will be refunded.");
					
					// Refund payment to bank balance
					if (currency == 1) {
						currentBuyer->setBankBalance(currentBuyer->getBankBalance() + static_cast<uint64_t>(std::llround(totalPrice)));
					} else if (currency == 2) {
						std::stringExtended refundQuery(128);
						refundQuery << "UPDATE `accounts` SET `coins` = `coins` + " << std::to_string(totalPrice) << " WHERE `id` = " << buyerAccountId << ";";
						g_databaseTasks.addTask(std::move(static_cast<std::string&>(refundQuery)));
					}
					
					std::stringExtended unlockQuery(128);
					unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
					g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
					currentBuyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
					return;
				}
				item->setItemCount(amount);

				bool added = g_game.internalAddItem(currentBuyer->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
				if (!added) {
					delete item;
					currentBuyer->sendMarketResponse(2, "Failed to add item to inbox. Your payment will be refunded.");
					
					// Refund payment to bank balance
						if (currency == 1) {
							currentBuyer->setBankBalance(currentBuyer->getBankBalance() + static_cast<uint64_t>(std::llround(totalPrice)));
						} else if (currency == 2) {
						std::stringExtended refundQuery(128);
						refundQuery << "UPDATE `accounts` SET `coins` = `coins` + " << std::to_string(totalPrice) << " WHERE `id` = " << buyerAccountId << ";";
						g_databaseTasks.addTask(std::move(static_cast<std::string&>(refundQuery)));
					}
					
					std::stringExtended unlockQuery(128);
					unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
					g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
					currentBuyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
					return;
				}

				// Payment successful and item added, now credit seller
						// Seller pays the market fee. Calculate seller amount after fee.
						double sellerAmountD = totalPrice * (1.0 - MARKET_FEE);
						if (currency == 1) {
							uint64_t sellerInt = static_cast<uint64_t>(std::llround(sellerAmountD));

							if (seller) {
								seller->setBankBalance(seller->getBankBalance() + sellerInt);
								std::stringExtended msg(128);
								msg << "Your item \"" << name << "\" (x" << amount << ") was bought for " << sellerInt << " gold coins.";
								seller->sendTextMessage(MESSAGE_INFO_DESCR, msg);
							} else {
								IOLoginData::increaseAccountBankBalance(sellerAID, sellerInt);
							}
						} else if (currency == 2) {
							double sellerD = sellerAmountD;
							std::stringExtended addQuery(128);
							addQuery << "UPDATE `accounts` SET `coins` = `coins` + " << std::to_string(sellerD) << " WHERE `id` = " << sellerAID << ";";
							g_databaseTasks.addTask(std::move(static_cast<std::string&>(addQuery)));

							if (seller) {
								std::stringExtended msg(128);
								msg << "Your item \"" << name << "\" (x" << amount << ") was bought for " << std::to_string(sellerD) << " Gems.";
								seller->sendTextMessage(MESSAGE_INFO_DESCR, msg);
							}
						}

				std::stringExtended queryUpdateOrDelete(256);
				if (amount == offerAmount) {
					queryUpdateOrDelete << "DELETE FROM `market_offers` WHERE `id` = " << marketId << ";";
				} else {
					uint32_t newAmount = offerAmount - amount;
					queryUpdateOrDelete << "UPDATE `market_offers` SET `amount` = " << newAmount << ", `status` = 0 WHERE `id` = " << marketId << ";";
				}

				g_databaseTasks.addTask(std::move(static_cast<std::string&>(queryUpdateOrDelete)));

				currentBuyer->sendMarketResponse(2, "You have successfully purchased the item.");
				currentBuyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
				g_game.addMarketHistory(currentBuyer->getGUID(), buyerAccountId, amount, totalPrice, name, currency, clientId, rarity, 1);
				g_game.addMarketHistory(sellerID, sellerAID, amount, totalPrice, name, currency, clientId, rarity, 0);
			};
				if (currency == 1) {
					// For gold, compare integer representation
					uint64_t intTotal = static_cast<uint64_t>(std::llround(totalPrice));
					if (buyer->getTotalMoney() < intTotal) {
					buyer->sendMarketResponse(2, "You do not have enough money to buy this offer.");
					std::stringExtended unlockQuery(128);
					unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
					g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
					buyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
					return;
				}
					completeTransaction(totalPrice, currency);
			} else if (currency == 2) {
				std::stringExtended coinsQuery(128);
				coinsQuery << "SELECT `coins` FROM `accounts` WHERE `id` = " << buyerAccountId << ";";

				std::function<void(DBResult_ptr, bool, uint64_t)> coinsCallback = [=](DBResult_ptr coinsResult, bool, uint64_t) {
					Player* currentBuyer = g_game.getPlayerByID(buyerId);
					if (!currentBuyer || !coinsResult) {
						std::stringExtended unlockQuery(128);
						unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
						g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
						return;
					}

					double coins = coinsResult->getNumber<double>("coins");
					if (coins < totalPrice) {
						currentBuyer->sendMarketResponse(2, "You do not have enough coins.");
						std::stringExtended unlockQuery(128);
						unlockQuery << "UPDATE market_offers SET status = 0 WHERE id = " << marketId << ";";
						g_databaseTasks.addTask(std::move(static_cast<std::string&>(unlockQuery)));
						currentBuyer->resetAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
						return;
					}

					completeTransaction(totalPrice, currency);
				};

				g_databaseTasks.addTask(std::move(static_cast<std::string&>(coinsQuery)), coinsCallback, true);
			}
		};

		g_databaseTasks.addTask(std::move(static_cast<std::string&>(selectQuery)), selectCallback, true);
	};

	g_databaseTasks.addTask(std::move(static_cast<std::string&>(updateQuery)), updateCallback, false);
	buyer->addAsyncOngoingTask(PlayerAsyncTask_MarketOffers);
}

void Game::addMarketHistory(uint32_t player_id, uint32_t account_id, uint16_t amount, double price, const std::string name, uint8_t currency, uint32_t clientId, uint8_t rarity, uint8_t type)
{
	std::stringExtended query(512);
	query << "INSERT INTO `market_history` (`player_id`, `account_id`, `amount`, `price`, `date`, `name`, `currency`, `clientId`, `type`, `rarity`) VALUES ("
		<< player_id << ", "
		<< account_id << ", "
		<< amount << ", "
		<< std::to_string(price) << ", "
		<< time(nullptr) << ", "
		<< g_database.escapeString(name) << ", "
		<< currency << ", "
		<< clientId << ", "
		<< type << ", "
		<< rarity << ");";

	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
}

// Helper function to load items from a blob and count them
// This properly parses container contents from the serialized stream
static void loadAndCountItems(const char* blob, unsigned long blobSize, std::map<uint16_t, uint64_t>& itemCounts) {
	if (blobSize == 0 || blob == nullptr) {
		return;
	}
	
	PropStream propStream;
	propStream.init(blob, blobSize);
	
	int32_t pid;
	uint16_t id;
	
	while (propStream.read<int32_t>(pid) && propStream.read<uint16_t>(id)) {
		Item* item = Item::CreateItem(id, 0);
		if (!item) {
			// Skip unknown item attributes
			uint8_t attr_type;
			while (propStream.read<uint8_t>(attr_type)) {
				if (attr_type == 0x00) {
					break;
				}
			}
			continue;
		}
		
		if (!item->unserializeAttr(propStream)) {
			delete item;
			continue;
		}
		
		// Count this item
		uint16_t itemId = item->getID();
		uint32_t count = item->isStackable() ? item->getItemCount() : 1;
		itemCounts[itemId] += count;
		
		// If it's a container, we need to read and count its contents from the stream
		Container* container = item->getContainer();
		if (container && container->getSerializationCount() > 0) {
			// Process containers iteratively using a stack
			std::vector<Container*> containerStack;
			containerStack.push_back(container);
			
			while (!containerStack.empty()) {
				Container* currentContainer = containerStack.back();
				
				if (currentContainer->getSerializationCount() > 0) {
					uint16_t containedId;
					if (!propStream.read<uint16_t>(containedId)) {
						break;
					}
					
					Item* containedItem = Item::CreateItem(containedId, 0);
					if (!containedItem) {
						// Skip unknown item
						uint8_t attr_type;
						while (propStream.read<uint8_t>(attr_type)) {
							if (attr_type == 0x00) {
								break;
							}
						}
						currentContainer->decrementSerializationCount();
						continue;
					}
					
					if (!containedItem->unserializeAttr(propStream)) {
						delete containedItem;
						currentContainer->decrementSerializationCount();
						continue;
					}
					
					// Count this contained item
					uint16_t containedItemId = containedItem->getID();
					uint32_t containedCount = containedItem->isStackable() ? containedItem->getItemCount() : 1;
					itemCounts[containedItemId] += containedCount;
					
					currentContainer->decrementSerializationCount();
					
					// If the contained item is also a container, push it onto the stack
					Container* nestedContainer = containedItem->getContainer();
					if (nestedContainer && nestedContainer->getSerializationCount() > 0) {
						containerStack.push_back(nestedContainer);
					} else {
						delete containedItem;
					}
				} else {
					// This container is fully processed, read end marker and pop
					uint8_t endAttr;
					propStream.read<uint8_t>(endAttr); // Should be 0x00
					delete currentContainer;
					containerStack.pop_back();
				}
			}
		} else {
			delete item;
		}
	}
}

uint32_t Game::scanAllPlayerItems(uint32_t threshold)
{
	std::cout << "[Item Scanner] Starting item scan with threshold: " << threshold << std::endl;
	
	// Open log file
	std::time_t now = std::time(nullptr);
	std::tm* tm_now = std::localtime(&now);
	char timeBuffer[64];
	std::strftime(timeBuffer, sizeof(timeBuffer), "%Y%m%d_%H%M%S", tm_now);
	
	std::string logFilename = "data/logs/item_scan_" + std::string(timeBuffer) + ".log";
	std::ofstream logFile(logFilename);
	if (!logFile.is_open()) {
		std::cout << "[Item Scanner] Failed to open log file: " << logFilename << std::endl;
		return 0;
	}
	
	logFile << "=== Item Duplication Scan Report ===" << std::endl;
	logFile << "Scan Time: " << std::ctime(&now);
	logFile << "Threshold: " << threshold << std::endl;
	logFile << "======================================" << std::endl << std::endl;
	
	uint32_t suspiciousCount = 0;
	
	// Get all accounts with depot items
	std::stringExtended accountQuery(256);
	accountQuery << "SELECT a.id as account_id, a.depotitems, a.depotlockeritems, a.inboxitems, "
	             << "(SELECT GROUP_CONCAT(p.name SEPARATOR ', ') FROM players p WHERE p.account_id = a.id) as player_names "
	             << "FROM accounts a";
	
	DBResult_ptr accountResult = g_database.storeQuery(accountQuery);
	if (accountResult) {
		do {
			uint32_t accountId = accountResult->getNumber<uint32_t>("account_id");
			std::string playerNames = accountResult->getString("player_names");
			
			// Track counts separately for each location
			std::map<uint16_t, uint64_t> depotCounts;
			std::map<uint16_t, uint64_t> depotLockerCounts;
			std::map<uint16_t, uint64_t> inboxCounts;
			
			// Load depot items
			unsigned long depotSize;
			const char* depotBlob = accountResult->getStream("depotitems", depotSize);
			loadAndCountItems(depotBlob, depotSize, depotCounts);
			
			// Load depot locker items
			unsigned long depotLockerSize;
			const char* depotLockerBlob = accountResult->getStream("depotlockeritems", depotLockerSize);
			loadAndCountItems(depotLockerBlob, depotLockerSize, depotLockerCounts);
			
			// Load inbox items (store inbox)
			unsigned long inboxSize;
			const char* inboxBlob = accountResult->getStream("inboxitems", inboxSize);
			loadAndCountItems(inboxBlob, inboxSize, inboxCounts);
			
			// Merge all counts to find totals
			std::map<uint16_t, uint64_t> totalCounts;
			for (const auto& pair : depotCounts) {
				totalCounts[pair.first] += pair.second;
			}
			for (const auto& pair : depotLockerCounts) {
				totalCounts[pair.first] += pair.second;
			}
			for (const auto& pair : inboxCounts) {
				totalCounts[pair.first] += pair.second;
			}
			
			// Check for suspicious items
			for (const auto& pair : totalCounts) {
				if (pair.second >= threshold) {
					const ItemType& itemType = Item::items[pair.first];
					uint64_t depotAmt = depotCounts[pair.first];
					uint64_t depotLockerAmt = depotLockerCounts[pair.first];
					uint64_t inboxAmt = inboxCounts[pair.first];
					
					logFile << "[SUSPICIOUS] Account ID: " << accountId 
					        << " | Players: " << playerNames
					        << " | Item: " << itemType.name << " (ID: " << pair.first << ")"
					        << " | TOTAL: " << pair.second << std::endl;
					logFile << "             -> Depot: " << depotAmt 
					        << " | DepotLocker: " << depotLockerAmt 
					        << " | StoreInbox: " << inboxAmt << std::endl;
					suspiciousCount++;
				}
			}
		} while (accountResult->next());
	}
	
	logFile << std::endl << "--- Player Inventory Items ---" << std::endl << std::endl;
	
	// Now scan individual player inventory items
	std::stringExtended playerQuery(256);
	playerQuery << "SELECT id, account_id, name, items FROM players";
	
	DBResult_ptr playerResult = g_database.storeQuery(playerQuery);
	if (playerResult) {
		do {
			uint32_t playerId = playerResult->getNumber<uint32_t>("id");
			uint32_t accountId = playerResult->getNumber<uint32_t>("account_id");
			std::string playerName = playerResult->getString("name");
			
			std::map<uint16_t, uint64_t> inventoryCounts;
			
			// Load inventory items
			unsigned long itemsSize;
			const char* itemsBlob = playerResult->getStream("items", itemsSize);
			loadAndCountItems(itemsBlob, itemsSize, inventoryCounts);
			
			// Check for suspicious items
			for (const auto& pair : inventoryCounts) {
				if (pair.second >= threshold) {
					const ItemType& itemType = Item::items[pair.first];
					logFile << "[SUSPICIOUS] Account ID: " << accountId 
					        << " | Player: " << playerName << " (ID: " << playerId << ")"
					        << " | Item: " << itemType.name << " (ID: " << pair.first << ")"
					        << " | Inventory Count: " << pair.second << std::endl;
					suspiciousCount++;
				}
			}
		} while (playerResult->next());
	}
	
	logFile << std::endl << "--- House Items ---" << std::endl << std::endl;
	
	// Scan house items from tile_store
	std::stringExtended houseQuery(256);
	houseQuery << "SELECT house_id, data FROM tile_store";
	
	DBResult_ptr houseResult = g_database.storeQuery(houseQuery);
	if (houseResult) {
		// Group house data by house_id
		std::map<uint32_t, std::map<uint16_t, uint64_t>> houseItemCounts;
		
		do {
			uint32_t houseId = houseResult->getNumber<uint32_t>("house_id");
			
			// Load house tile items
			unsigned long dataSize;
			const char* dataBlob = houseResult->getStream("data", dataSize);
			
			if (dataSize > 0 && dataBlob != nullptr) {
				PropStream propStream;
				propStream.init(dataBlob, dataSize);
				
				// Skip position data (x, y, z)
				uint16_t x, y;
				uint8_t z;
				if (!propStream.read<uint16_t>(x) || !propStream.read<uint16_t>(y) || !propStream.read<uint8_t>(z)) {
					continue;
				}
				
				// Read item count
				uint32_t item_count;
				if (!propStream.read<uint32_t>(item_count)) {
					continue;
				}
				
				// Count items on this tile
				std::map<uint16_t, uint64_t> tileCounts;
				
				for (uint32_t i = 0; i < item_count; ++i) {
					uint16_t id;
					if (!propStream.read<uint16_t>(id)) {
						break;
					}
					
					Item* item = Item::CreateItem(id, 0);
					if (!item) {
						// Skip unknown item attributes
						uint8_t attr_type;
						while (propStream.read<uint8_t>(attr_type)) {
							if (attr_type == 0x00) {
								break;
							}
						}
						continue;
					}
					
					if (!item->unserializeAttr(propStream)) {
						delete item;
						continue;
					}
					
					// Count this item
					uint16_t itemId = item->getID();
					uint32_t count = item->isStackable() ? item->getItemCount() : 1;
					tileCounts[itemId] += count;
					
					// If it's a container, count its contents
					Container* container = item->getContainer();
					if (container && container->getSerializationCount() > 0) {
						std::vector<Container*> containerStack;
						containerStack.push_back(container);
						
						while (!containerStack.empty()) {
							Container* currentContainer = containerStack.back();
							
							if (currentContainer->getSerializationCount() > 0) {
								uint16_t containedId;
								if (!propStream.read<uint16_t>(containedId)) {
									break;
								}
								
								Item* containedItem = Item::CreateItem(containedId, 0);
								if (!containedItem) {
									uint8_t attr_type;
									while (propStream.read<uint8_t>(attr_type)) {
										if (attr_type == 0x00) {
											break;
										}
									}
									currentContainer->decrementSerializationCount();
									continue;
								}
								
								if (!containedItem->unserializeAttr(propStream)) {
									delete containedItem;
									currentContainer->decrementSerializationCount();
									continue;
								}
								
								// Count this contained item
								uint16_t containedItemId = containedItem->getID();
								uint32_t containedCount = containedItem->isStackable() ? containedItem->getItemCount() : 1;
								tileCounts[containedItemId] += containedCount;
								
								currentContainer->decrementSerializationCount();
								
								Container* nestedContainer = containedItem->getContainer();
								if (nestedContainer && nestedContainer->getSerializationCount() > 0) {
									containerStack.push_back(nestedContainer);
								} else {
									delete containedItem;
								}
							} else {
								uint8_t endAttr;
								propStream.read<uint8_t>(endAttr);
								delete currentContainer;
								containerStack.pop_back();
							}
						}
					} else {
						delete item;
					}
				}
				
				// Merge tile counts into house counts
				for (const auto& pair : tileCounts) {
					houseItemCounts[houseId][pair.first] += pair.second;
				}
			}
		} while (houseResult->next());
		
		// Check for suspicious items in houses
		for (const auto& housePair : houseItemCounts) {
			uint32_t houseId = housePair.first;
			const auto& itemCounts = housePair.second;
			
			for (const auto& itemPair : itemCounts) {
				if (itemPair.second >= threshold) {
					const ItemType& itemType = Item::items[itemPair.first];
					logFile << "[SUSPICIOUS] House ID: " << houseId
					        << " | Item: " << itemType.name << " (ID: " << itemPair.first << ")"
					        << " | Count: " << itemPair.second << std::endl;
					suspiciousCount++;
				}
			}
		}
	}
	
	logFile << std::endl << "======================================" << std::endl;
	logFile << "Total suspicious entries found: " << suspiciousCount << std::endl;
	logFile.close();
	
	std::cout << "[Item Scanner] Scan complete. Found " << suspiciousCount << " suspicious entries." << std::endl;
	std::cout << "[Item Scanner] Log saved to: " << logFilename << std::endl;
	
	return suspiciousCount;
}