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

#ifndef FS_EVENTS_H_BD444CC0EE167E5777E4C90C766B36DC
#define FS_EVENTS_H_BD444CC0EE167E5777E4C90C766B36DC

#include "luascript.h"
#include "creature.h"
#include "dungeon.h"

class Party;
class ItemType;
class Tile;

class Events
{
	struct EventsInfo {
		// Creature
		int32_t creatureOnChangeOutfit = -1;
		int32_t creatureOnAreaCombat = -1;
		int32_t creatureOnTargetCombat = -1;

		// Party
		int32_t partyOnJoin = -1;
		int32_t partyOnLeave = -1;
		int32_t partyOnDisband = -1;
		int32_t partyOnShareExperience = -1;
		int32_t partyOnLeaderPass = -1;

		// Player
		int32_t playerOnBrowseField = -1;
		int32_t playerOnLook = -1;
		int32_t playerOnLookInBattleList = -1;
		int32_t playerOnLookInShop = -1;
		int32_t playerOnMoveItem = -1;
		int32_t playerOnWalk = -1;
		int32_t playerOnHouseWalk = -1;
		int32_t playerOnItemLoad = -1;
		int32_t playerOnItemMoved = -1;
		int32_t playerOnMoveCreature = -1;
		int32_t playerOnReportRuleViolation = -1;
		int32_t playerOnReportBug = -1;
		int32_t playerOnTurn = -1;
		int32_t playerOnGainExperience = -1;
		int32_t playerOnLoseExperience = -1;
		int32_t playerOnGainSkillTries = -1;
		int32_t playerOnInventoryUpdate = -1;
		int32_t playerOnBossAppear = -1;
		int32_t playerOnBossDisappear = -1;
		int32_t playerOnTileWidgetAppear = -1;
		int32_t playerOnMarketOfferAdd = -1;
		int32_t playerOnQueueLeave = -1;

		// Monster
		int32_t monsterOnDropLoot = -1;
		int32_t monsterOnSpawn = -1;
		
		// Dungeon
		int32_t dungeonOnQueue = -1;
		int32_t dungeonOnPrepare = -1;
		int32_t dungeonOnStart = -1;
		int32_t dungeonOnSuccess = -1;
		int32_t dungeonOnFail = -1;
		int32_t dungeonOnPlayerLeave = -1;
		int32_t dungeonOnMonstersCount = -1;
		int32_t dungeonOnMonsterSpawn = -1;
	};

	public:
		Events();

		bool load();

		// Creature
		bool eventCreatureOnChangeOutfit(Creature* creature, const Outfit_t& outfit);
		ReturnValue eventCreatureOnAreaCombat(Creature* creature, Tile* tile, bool aggressive);
		ReturnValue eventCreatureOnTargetCombat(Creature* creature, Creature* target);

		// Party
		bool eventPartyOnJoin(Party* party, Player* player);
		bool eventPartyOnLeave(Party* party, Player* player);
		bool eventPartyOnDisband(Party* party);
		void eventPartyOnShareExperience(Party* party, uint64_t& exp);
		bool eventPartyOnLeaderPass(Party* party, Player* oldLeader, Player* newLeader);

		// Player
		bool eventPlayerOnBrowseField(Player* player, const Position& position);
		void eventPlayerOnLook(Player* player, const Position& position, Thing* thing, uint8_t stackpos, int32_t lookDistance);
		void eventPlayerOnLookInBattleList(Player* player, Creature* creature, int32_t lookDistance);
		bool eventPlayerOnLookInShop(Player* player, const ItemType* itemType, uint8_t count);
		void eventPlayerOnWalk(Player* player, const Position& fromPosition, const Position& toPosition);
		void eventPlayerOnHouseWalk(Player* player, House* house, bool enter);
		void eventPlayerOnItemLoad(Player* player, Item* item);
		bool eventPlayerOnMoveItem(Player* player, Item* item, uint16_t count, const Position& fromPosition, const Position& toPosition, Cylinder* fromCylinder, Cylinder* toCylinder);
		void eventPlayerOnItemMoved(Player* player, Item* item, uint16_t count, const Position& fromPosition, const Position& toPosition, Cylinder* fromCylinder, Cylinder* toCylinder);
		bool eventPlayerOnMoveCreature(Player* player, Creature* creature, const Position& fromPosition, const Position& toPosition);
		void eventPlayerOnReportRuleViolation(Player* player, const std::string& targetName, uint8_t reportType, uint8_t reportReason, const std::string& comment, const std::string& translation);
		bool eventPlayerOnReportBug(Player* player, const std::string& message, const Position& position, uint8_t category);
		bool eventPlayerOnTurn(Player* player, Direction direction);
		void eventPlayerOnGainExperience(Player* player, Creature* source, uint64_t& exp, uint64_t rawExp);
		void eventPlayerOnLoseExperience(Player* player, uint64_t& exp);
		void eventPlayerOnGainSkillTries(Player* player, skills_t skill, uint64_t& tries);
		void eventPlayerOnInventoryUpdate(Player* player, Item* item, slots_t slot, bool equip);
		void eventPlayerOnBossAppear(Player* player, Creature* boss);
		void eventPlayerOnBossDisappear(Player* player, Creature* boss);;
		void eventPlayerOnTileWidgetAppear(Player* player, const Position& position, const std::string& id, const std::string& data);
		void eventPlayerOnMarketOfferAdd(Player* player, const uint32_t marketId, const uint64_t uid);
		void eventPlayerOnQueueLeave(Player* player, DungeonQueue* queue);

		// Monster
		void eventMonsterOnDropLoot(Monster* monster, Container* corpse);
		bool eventMonsterOnSpawn(Monster* monster, const Position& position, bool startup, bool artificial, bool dungeon = false);
		
		// Dungeon
		void eventDungeonOnQueue(Dungeon* dungeon);
		void eventDungeonOnPrepare(Dungeon* dungeon, DungeonInstance* instance, Player* player);
		void eventDungeonOnStart(Dungeon* dungeon, DungeonInstance* instance, Player* player);
		void eventDungeonOnSuccess(Dungeon* dungeon, DungeonInstance* instance);
		void eventDungeonOnFail(Dungeon* dungeon, DungeonInstance* instance);
		void eventDungeonOnPlayerLeave(Dungeon* dungeon, DungeonInstance* instance, Player* player);
		void eventDungeonOnMonstersCount(DungeonInstance* instance, uint16_t monsters);
		void eventDungeonOnMonsterSpawn(DungeonInstance* instance, Monster* monster);

	private:
		LuaScriptInterface scriptInterface;
		EventsInfo info;
};

#endif
