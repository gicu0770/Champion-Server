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

#include "events.h"
#include "tools.h"
#include "item.h"
#include "player.h"

#include <set>

Events::Events() :
	scriptInterface("Event Interface")
{
	scriptInterface.initState();
}

bool Events::load()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/events/events.xml");
	if (!result) {
		printXMLError("Error - Events::load", "data/events/events.xml", result);
		return false;
	}

	info = {};

	std::set<std::string> classes;
	for (auto eventNode : doc.child("events").children()) {
		if (!eventNode.attribute("enabled").as_bool()) {
			continue;
		}

		const std::string& className = eventNode.attribute("class").as_string();
		auto res = classes.insert(className);
		if (res.second) {
			const std::string& lowercase = asLowerCaseString(className);
			if (scriptInterface.loadFile("data/events/scripts/" + lowercase + ".lua") != 0) {
				std::cout << "[Warning - Events::load] Can not load script: " << lowercase << ".lua" << std::endl;
				std::cout << scriptInterface.getLastLuaError() << std::endl;
			}
		}

		const std::string& methodName = eventNode.attribute("method").as_string();
		const int32_t event = scriptInterface.getMetaEvent(className, methodName);
		if (!tfs_strcmp(className.c_str(), "Creature")) {
			if (!tfs_strcmp(methodName.c_str(), "onChangeOutfit")) {
				info.creatureOnChangeOutfit = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onAreaCombat")) {
				info.creatureOnAreaCombat = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onTargetCombat")) {
				info.creatureOnTargetCombat = event;
			} else {
				std::cout << "[Warning - Events::load] Unknown creature method: " << methodName << std::endl;
			}
		} else if (!tfs_strcmp(className.c_str(), "Party")) {
			if (!tfs_strcmp(methodName.c_str(), "onJoin")) {
				info.partyOnJoin = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLeave")) {
				info.partyOnLeave = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onDisband")) {
				info.partyOnDisband = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onShareExperience")) {
				info.partyOnShareExperience = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLeaderPass")) {
				info.partyOnLeaderPass = event;
			} else {
				std::cout << "[Warning - Events::load] Unknown party method: " << methodName << std::endl;
			}
		} else if (!tfs_strcmp(className.c_str(), "Player")) {
			if (!tfs_strcmp(methodName.c_str(), "onBrowseField")) {
				info.playerOnBrowseField = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLook")) {
				info.playerOnLook = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onWalk")) {
				info.playerOnWalk = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onHouseWalk")) {
				info.playerOnHouseWalk = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLoadItem")) {
				info.playerOnItemLoad = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLookInBattleList")) {
				info.playerOnLookInBattleList = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLookInShop")) {
				info.playerOnLookInShop = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onMoveItem")) {
				info.playerOnMoveItem = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onItemMoved")) {
				info.playerOnItemMoved = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onMoveCreature")) {
				info.playerOnMoveCreature = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onReportRuleViolation")) {
				info.playerOnReportRuleViolation = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onReportBug")) {
				info.playerOnReportBug = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onTurn")) {
				info.playerOnTurn = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onGainExperience")) {
				info.playerOnGainExperience = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onLoseExperience")) {
				info.playerOnLoseExperience = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onGainSkillTries")) {
				info.playerOnGainSkillTries = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onInventoryUpdate")) {
				info.playerOnInventoryUpdate = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onBossAppear")) {
				info.playerOnBossAppear = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onBossDisappear")) {
				info.playerOnBossDisappear = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onQueueLeave")) {
				info.playerOnQueueLeave = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onTileWidgetAppear")) {
				info.playerOnTileWidgetAppear = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onMarketOfferAdd")) {
				info.playerOnMarketOfferAdd = event;
			} else {
				std::cout << "[Warning - Events::load] Unknown player method: " << methodName << std::endl;
			}
		} else if (!tfs_strcmp(className.c_str(), "Monster")) {
			if (!tfs_strcmp(methodName.c_str(), "onDropLoot")) {
				info.monsterOnDropLoot = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onSpawn")) {
				info.monsterOnSpawn = event;
			} else {
				std::cout << "[Warning - Events::load] Unknown monster method: " << methodName << std::endl;
			}
		} else if (!tfs_strcmp(className.c_str(), "Dungeon")) {
			if (!tfs_strcmp(methodName.c_str(), "onQueue")) {
				info.dungeonOnQueue = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onPrepare")) {
				info.dungeonOnPrepare = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onStart")) {
				info.dungeonOnStart = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onSuccess")) {
				info.dungeonOnSuccess = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onFail")) {
				info.dungeonOnFail = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onPlayerLeft")) {
				info.dungeonOnPlayerLeave = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onMonstersCount")) {
				info.dungeonOnMonstersCount = event;
			} else if (!tfs_strcmp(methodName.c_str(), "onMonsterSpawn")) {
				info.dungeonOnMonsterSpawn = event;
			} else {
				std::cout << "[Warning - Events::load] Unknown dungeon method: " << methodName << std::endl;
			}
		} else {
			std::cout << "[Warning - Events::load] Unknown class: " << className << std::endl;
		}
	}
	return true;
}

// Monster
bool Events::eventMonsterOnSpawn(Monster* monster, const Position& position, bool startup, bool artificial, bool dungeon /*false*/)
{
	// Monster:onSpawn(position, startup, artificial)
	if (info.monsterOnSpawn == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::monsterOnSpawn] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.monsterOnSpawn, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.monsterOnSpawn);

	LuaScriptInterface::pushUserdata<Monster>(L, monster);
	LuaScriptInterface::setMetatable(L, -1, "Monster");
	LuaScriptInterface::pushPosition(L, position);
	LuaScriptInterface::pushBoolean(L, startup);
	LuaScriptInterface::pushBoolean(L, artificial);
	LuaScriptInterface::pushBoolean(L, dungeon);

	return scriptInterface.callFunction(5);
}

// Creature
bool Events::eventCreatureOnChangeOutfit(Creature* creature, const Outfit_t& outfit)
{
	// Creature:onChangeOutfit(outfit) or Creature.onChangeOutfit(self, outfit)
	if (info.creatureOnChangeOutfit == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventCreatureOnChangeOutfit] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.creatureOnChangeOutfit, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.creatureOnChangeOutfit);

	LuaScriptInterface::pushUserdata<Creature>(L, creature);
	LuaScriptInterface::setCreatureMetatable(L, -1, creature);

	LuaScriptInterface::pushOutfit(L, outfit);

	return scriptInterface.callFunction(2);
}

ReturnValue Events::eventCreatureOnAreaCombat(Creature* creature, Tile* tile, bool aggressive)
{
	// Creature:onAreaCombat(tile, aggressive) or Creature.onAreaCombat(self, tile, aggressive)
	if (info.creatureOnAreaCombat == -1) {
		return RETURNVALUE_NOERROR;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventCreatureOnAreaCombat] Call stack overflow" << std::endl;
		return RETURNVALUE_NOTPOSSIBLE;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.creatureOnAreaCombat, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.creatureOnAreaCombat);

	if (creature) {
		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);
	} else {
		lua_pushnil(L);
	}

	LuaScriptInterface::pushUserdata<Tile>(L, tile);
	LuaScriptInterface::setMetatable(L, -1, "Tile");

	LuaScriptInterface::pushBoolean(L, aggressive);

	ReturnValue returnValue;
	if (scriptInterface.protectedCall(L, 3, 1) != 0) {
		returnValue = RETURNVALUE_NOTPOSSIBLE;
		LuaScriptInterface::reportError(nullptr, LuaScriptInterface::popString(L));
	} else {
		returnValue = LuaScriptInterface::getNumber<ReturnValue>(L, -1);
		lua_pop(L, 1);
	}

	scriptInterface.resetScriptEnv();
	return returnValue;
}

ReturnValue Events::eventCreatureOnTargetCombat(Creature* creature, Creature* target)
{
	// Creature:onTargetCombat(target) or Creature.onTargetCombat(self, target)
	if (info.creatureOnTargetCombat == -1) {
		return RETURNVALUE_NOERROR;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventCreatureOnTargetCombat] Call stack overflow" << std::endl;
		return RETURNVALUE_NOTPOSSIBLE;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.creatureOnTargetCombat, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.creatureOnTargetCombat);

	if (creature) {
		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);
	} else {
		lua_pushnil(L);
	}

	LuaScriptInterface::pushUserdata<Creature>(L, target);
	LuaScriptInterface::setCreatureMetatable(L, -1, target);

	ReturnValue returnValue;
	if (scriptInterface.protectedCall(L, 2, 1) != 0) {
		returnValue = RETURNVALUE_NOTPOSSIBLE;
		LuaScriptInterface::reportError(nullptr, LuaScriptInterface::popString(L));
	} else {
		returnValue = LuaScriptInterface::getNumber<ReturnValue>(L, -1);
		lua_pop(L, 1);
	}

	scriptInterface.resetScriptEnv();
	return returnValue;
}

// Party
bool Events::eventPartyOnJoin(Party* party, Player* player)
{
	// Party:onJoin(player) or Party.onJoin(self, player)
	if (info.partyOnJoin == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPartyOnJoin] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.partyOnJoin, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.partyOnJoin);

	LuaScriptInterface::pushUserdata<Party>(L, party);
	LuaScriptInterface::setMetatable(L, -1, "Party");

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	return scriptInterface.callFunction(2);
}

bool Events::eventPartyOnLeave(Party* party, Player* player)
{
	// Party:onLeave(player) or Party.onLeave(self, player)
	if (info.partyOnLeave == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPartyOnLeave] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.partyOnLeave, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.partyOnLeave);

	LuaScriptInterface::pushUserdata<Party>(L, party);
	LuaScriptInterface::setMetatable(L, -1, "Party");

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	return scriptInterface.callFunction(2);
}

bool Events::eventPartyOnDisband(Party* party)
{
	// Party:onDisband() or Party.onDisband(self)
	if (info.partyOnDisband == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPartyOnDisband] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.partyOnDisband, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.partyOnDisband);

	LuaScriptInterface::pushUserdata<Party>(L, party);
	LuaScriptInterface::setMetatable(L, -1, "Party");

	return scriptInterface.callFunction(1);
}

void Events::eventPartyOnShareExperience(Party* party, uint64_t& exp)
{
	// Party:onShareExperience(exp) or Party.onShareExperience(self, exp)
	if (info.partyOnShareExperience == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPartyOnShareExperience] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.partyOnShareExperience, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.partyOnShareExperience);

	LuaScriptInterface::pushUserdata<Party>(L, party);
	LuaScriptInterface::setMetatable(L, -1, "Party");

	lua_pushnumber(L, exp);

	if (scriptInterface.protectedCall(L, 2, 1) != 0) {
		LuaScriptInterface::reportError(nullptr, LuaScriptInterface::popString(L));
	} else {
		exp = LuaScriptInterface::getNumber<uint64_t>(L, -1);
		lua_pop(L, 1);
	}

	scriptInterface.resetScriptEnv();
}

bool Events::eventPartyOnLeaderPass(Party* party, Player* oldLeader, Player* newLeader)
{
	// Party:onLeaderPass(oldLeader, newLeader) or Party.onLeaderPass(self, oldLeader, newLeader)
	if (info.partyOnLeaderPass == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPartyOnLeaderPass] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.partyOnLeaderPass, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.partyOnLeaderPass);

	LuaScriptInterface::pushUserdata<Party>(L, party);
	LuaScriptInterface::setMetatable(L, -1, "Party");

	LuaScriptInterface::pushUserdata<Player>(L, oldLeader);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Player>(L, newLeader);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	return scriptInterface.callFunction(3);
}

// Player
bool Events::eventPlayerOnBrowseField(Player* player, const Position& position)
{
	// Player:onBrowseField(position) or Player.onBrowseField(self, position)
	if (info.playerOnBrowseField == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnBrowseField] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnBrowseField, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnBrowseField);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushPosition(L, position);

	return scriptInterface.callFunction(2);
}

void Events::eventPlayerOnLook(Player* player, const Position& position, Thing* thing, uint8_t stackpos, int32_t lookDistance)
{
	// Player:onLook(thing, position, distance) or Player.onLook(self, thing, position, distance)
	if (info.playerOnLook == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnLook] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnLook, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnLook);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	if (Creature* creature = thing->getCreature()) {
		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);
	} else if (Item* item = thing->getItem()) {
		LuaScriptInterface::pushUserdata<Item>(L, item);
		LuaScriptInterface::setItemMetatable(L, -1, item);
	} else {
		lua_pushnil(L);
	}

	LuaScriptInterface::pushPosition(L, position, stackpos);
	lua_pushnumber(L, lookDistance);

	scriptInterface.callVoidFunction(4);
}

void Events::eventPlayerOnLookInBattleList(Player* player, Creature* creature, int32_t lookDistance)
{
	// Player:onLookInBattleList(creature, position, distance) or Player.onLookInBattleList(self, creature, position, distance)
	if (info.playerOnLookInBattleList == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnLookInBattleList] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnLookInBattleList, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnLookInBattleList);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Creature>(L, creature);
	LuaScriptInterface::setCreatureMetatable(L, -1, creature);

	lua_pushnumber(L, lookDistance);

	scriptInterface.callVoidFunction(3);
}

bool Events::eventPlayerOnLookInShop(Player* player, const ItemType* itemType, uint8_t count)
{
	// Player:onLookInShop(itemType, count) or Player.onLookInShop(self, itemType, count)
	if (info.playerOnLookInShop == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnLookInShop] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnLookInShop, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnLookInShop);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<const ItemType>(L, itemType);
	LuaScriptInterface::setMetatable(L, -1, "ItemType");

	lua_pushnumber(L, count);

	return scriptInterface.callFunction(3);
}

bool Events::eventPlayerOnMoveItem(Player* player, Item* item, uint16_t count, const Position& fromPosition, const Position& toPosition, Cylinder* fromCylinder, Cylinder* toCylinder)
{
	// Player:onMoveItem(item, count, fromPosition, toPosition) or Player.onMoveItem(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if (info.playerOnMoveItem == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnMoveItem] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnMoveItem, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnMoveItem);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Item>(L, item);
	LuaScriptInterface::setItemMetatable(L, -1, item);

	lua_pushnumber(L, count);
	LuaScriptInterface::pushPosition(L, fromPosition);
	LuaScriptInterface::pushPosition(L, toPosition);

	LuaScriptInterface::pushCylinder(L, fromCylinder);
	LuaScriptInterface::pushCylinder(L, toCylinder);

	return scriptInterface.callFunction(7);
}

void Events::eventPlayerOnHouseWalk(Player* player, House* house, bool enter)
{
	// Player:onHouseWalk(house, enter) or Player.onHouseWalk(self, house, enter)
	if (info.playerOnHouseWalk == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnHouseWalk] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnHouseWalk, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnHouseWalk);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<House>(L, house);
	LuaScriptInterface::setMetatable(L, -1, "House");

	LuaScriptInterface::pushBoolean(L, enter);

	scriptInterface.callVoidFunction(3);
}

void Events::eventPlayerOnWalk(Player* player, const Position& fromPosition, const Position& toPosition)
{
	if (info.playerOnWalk == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnWalk] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnWalk, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnWalk);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushPosition(L, fromPosition);
	LuaScriptInterface::pushPosition(L, toPosition);

	scriptInterface.callVoidFunction(3);
}

void Events::eventPlayerOnItemLoad(Player* player, Item* item)
{
	if (info.playerOnItemLoad == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnItemLoad] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnItemLoad, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnItemLoad);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Item>(L, item);
	LuaScriptInterface::setItemMetatable(L, -1, item);

	scriptInterface.callVoidFunction(2);
}

void Events::eventPlayerOnItemMoved(Player* player, Item* item, uint16_t count, const Position& fromPosition, const Position& toPosition, Cylinder* fromCylinder, Cylinder* toCylinder)
{
	// Player:onItemMoved(item, count, fromPosition, toPosition) or Player.onItemMoved(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if (info.playerOnItemMoved == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnItemMoved] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnItemMoved, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnItemMoved);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Item>(L, item);
	LuaScriptInterface::setItemMetatable(L, -1, item);

	lua_pushnumber(L, count);
	LuaScriptInterface::pushPosition(L, fromPosition);
	LuaScriptInterface::pushPosition(L, toPosition);

	LuaScriptInterface::pushCylinder(L, fromCylinder);
	LuaScriptInterface::pushCylinder(L, toCylinder);

	scriptInterface.callVoidFunction(7);
}

bool Events::eventPlayerOnMoveCreature(Player* player, Creature* creature, const Position& fromPosition, const Position& toPosition)
{
	// Player:onMoveCreature(creature, fromPosition, toPosition) or Player.onMoveCreature(self, creature, fromPosition, toPosition)
	if (info.playerOnMoveCreature == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnMoveCreature] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnMoveCreature, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnMoveCreature);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Creature>(L, creature);
	LuaScriptInterface::setCreatureMetatable(L, -1, creature);

	LuaScriptInterface::pushPosition(L, fromPosition);
	LuaScriptInterface::pushPosition(L, toPosition);

	return scriptInterface.callFunction(4);
}

void Events::eventPlayerOnReportRuleViolation(Player* player, const std::string& targetName, uint8_t reportType, uint8_t reportReason, const std::string& comment, const std::string& translation)
{
	// Player:onReportRuleViolation(targetName, reportType, reportReason, comment, translation)
	if (info.playerOnReportRuleViolation == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnReportRuleViolation] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnReportRuleViolation, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnReportRuleViolation);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushString(L, targetName);

	lua_pushnumber(L, reportType);
	lua_pushnumber(L, reportReason);

	LuaScriptInterface::pushString(L, comment);
	LuaScriptInterface::pushString(L, translation);

	scriptInterface.callVoidFunction(6);
}

bool Events::eventPlayerOnReportBug(Player* player, const std::string& message, const Position& position, uint8_t category)
{
	// Player:onReportBug(message, position, category)
	if (info.playerOnReportBug == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnReportBug] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnReportBug, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnReportBug);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushString(L, message);
	LuaScriptInterface::pushPosition(L, position);
	lua_pushnumber(L, category);

	return scriptInterface.callFunction(4);
}

bool Events::eventPlayerOnTurn(Player* player, Direction direction)
{
	// Player:onTurn(direction) or Player.onTurn(self, direction)
	if (info.playerOnTurn == -1) {
		return true;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnTurn] Call stack overflow" << std::endl;
		return false;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnTurn, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnTurn);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	lua_pushnumber(L, direction);

	return scriptInterface.callFunction(2);
}

void Events::eventPlayerOnGainExperience(Player* player, Creature* source, uint64_t& exp, uint64_t rawExp)
{
	// Player:onGainExperience(source, exp, rawExp)
	// rawExp gives the original exp which is not multiplied
	if (info.playerOnGainExperience == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnGainExperience] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnGainExperience, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnGainExperience);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	if (source) {
		LuaScriptInterface::pushUserdata<Creature>(L, source);
		LuaScriptInterface::setCreatureMetatable(L, -1, source);
	} else {
		lua_pushnil(L);
	}

	lua_pushnumber(L, exp);
	lua_pushnumber(L, rawExp);

	if (scriptInterface.protectedCall(L, 4, 1) != 0) {
		LuaScriptInterface::reportError(nullptr, LuaScriptInterface::popString(L));
	} else {
		exp = LuaScriptInterface::getNumber<uint64_t>(L, -1);
		lua_pop(L, 1);
	}

	scriptInterface.resetScriptEnv();
}

void Events::eventPlayerOnLoseExperience(Player* player, uint64_t& exp)
{
	// Player:onLoseExperience(exp)
	if (info.playerOnLoseExperience == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnLoseExperience] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnLoseExperience, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnLoseExperience);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	lua_pushnumber(L, exp);

	if (scriptInterface.protectedCall(L, 2, 1) != 0) {
		LuaScriptInterface::reportError(nullptr, LuaScriptInterface::popString(L));
	} else {
		exp = LuaScriptInterface::getNumber<uint64_t>(L, -1);
		lua_pop(L, 1);
	}

	scriptInterface.resetScriptEnv();
}

void Events::eventPlayerOnGainSkillTries(Player* player, skills_t skill, uint64_t& tries)
{
	// Player:onGainSkillTries(skill, tries)
	if (info.playerOnGainSkillTries == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnGainSkillTries] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnGainSkillTries, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnGainSkillTries);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	lua_pushnumber(L, skill);
	lua_pushnumber(L, tries);

	if (scriptInterface.protectedCall(L, 3, 1) != 0) {
		LuaScriptInterface::reportError(nullptr, LuaScriptInterface::popString(L));
	} else {
		tries = LuaScriptInterface::getNumber<uint64_t>(L, -1);
		lua_pop(L, 1);
	}

	scriptInterface.resetScriptEnv();
}

void Events::eventPlayerOnInventoryUpdate(Player* player, Item* item, slots_t slot, bool equip)
{
	// Player:onInventoryUpdate(item, slot, equip)
	if (info.playerOnInventoryUpdate == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnInventoryUpdate] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnInventoryUpdate, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnInventoryUpdate);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Item>(L, item);
	LuaScriptInterface::setItemMetatable(L, -1, item);

	lua_pushnumber(L, slot);
	LuaScriptInterface::pushBoolean(L, equip);

	scriptInterface.callVoidFunction(4);
}

void Events::eventPlayerOnBossAppear(Player* player, Creature* boss)
{
	// Player:onBossAppear(boss)
	if (info.playerOnBossAppear == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnBossAppear] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnBossAppear, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnBossAppear);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Creature>(L, boss);
	LuaScriptInterface::setCreatureMetatable(L, -1, boss);

	scriptInterface.callVoidFunction(2);
}

void Events::eventPlayerOnBossDisappear(Player* player, Creature* boss)
{
	// Player:onBossDisappear(boss)
	if (info.playerOnBossDisappear == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnBossDisappear] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnBossDisappear, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnBossDisappear);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<Creature>(L, boss);
	LuaScriptInterface::setCreatureMetatable(L, -1, boss);

	scriptInterface.callVoidFunction(2);
}

void Events::eventPlayerOnTileWidgetAppear(Player* player, const Position& position, const std::string& id, const std::string& data)
{
	// Player:OnTileWidgetAppear(player)
	if (info.playerOnTileWidgetAppear == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnTileWidgetAppear] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnTileWidgetAppear, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnTileWidgetAppear);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushPosition(L, position);
	LuaScriptInterface::pushString(L, id);
	LuaScriptInterface::pushString(L, data);

	scriptInterface.callVoidFunction(4);
}

void Events::eventPlayerOnMarketOfferAdd(Player* player, const uint32_t marketId, const uint64_t uid)
{
	// Player:OnTileWidgetAppear(player)
	if (info.playerOnMarketOfferAdd == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventPlayerOnMarketOfferAdd] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnMarketOfferAdd, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnMarketOfferAdd);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");
	lua_pushnumber(L, marketId);
	lua_pushnumber(L, uid);

	scriptInterface.callVoidFunction(3);
}

void Events::eventMonsterOnDropLoot(Monster* monster, Container* corpse)
{
	// Monster:onDropLoot(corpse)
	if (info.monsterOnDropLoot == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventMonsterOnDropLoot] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.monsterOnDropLoot, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.monsterOnDropLoot);

	LuaScriptInterface::pushUserdata<Monster>(L, monster);
	LuaScriptInterface::setMetatable(L, -1, "Monster");

	LuaScriptInterface::pushUserdata<Container>(L, corpse);
	LuaScriptInterface::setMetatable(L, -1, "Container");

	return scriptInterface.callVoidFunction(2);
}

void Events::eventDungeonOnQueue(Dungeon* dungeon)
{
	// Dungeon:onQueue()
	if (info.dungeonOnQueue == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnQueue] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnQueue, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnQueue);

	LuaScriptInterface::pushUserdata<Dungeon>(L, dungeon);
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	scriptInterface.callVoidFunction(1);
}

void Events::eventDungeonOnPrepare(Dungeon* dungeon, DungeonInstance* instance, Player* player)
{
	// Dungeon:onPrepare(player)
	if (info.dungeonOnPrepare == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnPrepare] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnPrepare, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnPrepare);

	LuaScriptInterface::pushUserdata<Dungeon>(L, dungeon);
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	scriptInterface.callVoidFunction(3);
}

void Events::eventDungeonOnStart(Dungeon* dungeon, DungeonInstance* instance, Player* player)
{
	// Dungeon:onStart(instance, player)
	if (info.dungeonOnStart == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnStart] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnStart, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnStart);

	LuaScriptInterface::pushUserdata<Dungeon>(L, dungeon);
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	scriptInterface.callVoidFunction(3);
}

void Events::eventDungeonOnSuccess( Dungeon* dungeon, DungeonInstance* instance)
{
	// Dungeon:onSuccess(instance)
	if (info.dungeonOnSuccess == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnSuccess] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnSuccess, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnSuccess);

	LuaScriptInterface::pushUserdata<Dungeon>(L, dungeon);
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");

	scriptInterface.callVoidFunction(2);
}

void Events::eventDungeonOnFail(Dungeon* dungeon, DungeonInstance* instance)
{
	// Dungeon:onFail(instance)
	if (info.dungeonOnFail == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnFail] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnFail, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnFail);

	LuaScriptInterface::pushUserdata<Dungeon>(L, dungeon);
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");

	scriptInterface.callVoidFunction(2);
}

void Events::eventDungeonOnPlayerLeave(Dungeon* dungeon, DungeonInstance* instance, Player* player)
{
	// Dungeon:onPlayerLeave(instance, player)
	if (info.dungeonOnPlayerLeave == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::evenDungeonOnPlayerLeave] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnPlayerLeave, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnPlayerLeave);

	LuaScriptInterface::pushUserdata<Dungeon>(L, dungeon);
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");
	
	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	scriptInterface.callVoidFunction(3);
}

void Events::eventDungeonOnMonstersCount(DungeonInstance* instance, uint16_t monsters)
{
	// Dungeon:onMonstersCount(instance, monsters)
	if (info.dungeonOnMonstersCount == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnMonstersCount] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnMonstersCount, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnMonstersCount);

	LuaScriptInterface::pushUserdata<Dungeon>(L, instance->getDungeon());
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");

	lua_pushnumber(L, monsters);

	scriptInterface.callVoidFunction(3);
}

void Events::eventDungeonOnMonsterSpawn(DungeonInstance* instance, Monster* monster)
{
	// Dungeon:onMonsterSpawn(monster)
	if (info.dungeonOnMonsterSpawn == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::eventDungeonOnMonsterSpawn] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.dungeonOnMonsterSpawn, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.dungeonOnMonsterSpawn);

	LuaScriptInterface::pushUserdata<Dungeon>(L, instance->getDungeon());
	LuaScriptInterface::setMetatable(L, -1, "Dungeon");

	LuaScriptInterface::pushUserdata<DungeonInstance>(L, instance);
	LuaScriptInterface::setMetatable(L, -1, "DungeonInstance");

	LuaScriptInterface::pushUserdata<Monster>(L, monster);
	LuaScriptInterface::setMetatable(L, -1, "Monster");

	scriptInterface.callVoidFunction(3);
}

void Events::eventPlayerOnQueueLeave(Player* player, DungeonQueue* queue)
{
	// Player:onQueueLeave(queue)
	if (info.playerOnQueueLeave == -1) {
		return;
	}

	if (!scriptInterface.reserveScriptEnv()) {
		std::cout << "[Error - Events::evenDungeonOnPlayerLeave] Call stack overflow" << std::endl;
		return;
	}

	ScriptEnvironment* env = scriptInterface.getScriptEnv();
	env->setScriptId(info.playerOnQueueLeave, &scriptInterface);

	lua_State* L = scriptInterface.getLuaState();
	scriptInterface.pushFunction(info.playerOnQueueLeave);

	LuaScriptInterface::pushUserdata<Player>(L, player);
	LuaScriptInterface::setMetatable(L, -1, "Player");

	LuaScriptInterface::pushUserdata<DungeonQueue>(L, queue);
	LuaScriptInterface::setMetatable(L, -1, "DungeonQueue");

	scriptInterface.callVoidFunction(2);
}