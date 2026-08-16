/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2021  Arkadiusz <lach@includespark.eu>
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

 #include "dungeon.h"
 #include "player.h"
 #include "game.h"
 #include "events.h"
 #include "monster.h"
 #include "configmanager.h"
 #include <atomic>
 
 extern Events* g_events;
 extern Game g_game;
 extern ConfigManager g_config;
 
 static uint16_t lastChunkInstanceId = 0;

 // Static callback wrappers that safely look up dungeon by ID
 static void dungeonStartCallback(uint8_t dungeonId, uint32_t pid, DungeonInstance* instance)
 {
     Dungeon* dungeon = g_game.getDungeonById(dungeonId);
     if (dungeon) {
         dungeon->start(pid, instance);
     }
 }

 static void dungeonTimeoutCallback(uint8_t dungeonId, uint32_t pid)
 {
     Dungeon* dungeon = g_game.getDungeonById(dungeonId);
     if (dungeon) {
         dungeon->timeout(pid);
     }
 }

 Dungeon::Dungeon()
 {
     queue = new DungeonQueue();
     queue->setDungeon(this);
 }
 
 bool Dungeon::joinQueue(Player* player, uint64_t uid)
 {
     if (!canJoin(player)) {
         player->sendFYIBox("Can't join dungeon, you don't meet requirements!");
         return false;
     }
 
     uint8_t queuePosition = queue->addPlayer(player);
     size_t queueAmount = queue->getPlayersNumber();
 
     Party* party = player->getParty();
     if (require.party.max >= 2 && party && !isSolo()) {
         if (party) {
             Player* leader = party->getLeader();
             PlayerVector members = party->getMembers();
             for (Player* member : members) {
                 if (!canJoin(member, true)) {
                     std::stringExtended text(96);
                     text << "Can't join dungeon, " << member->getName() << " doesn't meet requirements!";
                     player->sendFYIBox(text);
                     queue->removePlayer(player);
                     return false;
                 }
                 }
             
             bool sent = false;
             for (Player* member : members) {
                 if (queueAmount == 1 && queuePosition == 1 && getFreeInstance()) {
                     std::stringExtended text(128);
                     text << "Party leader joined " << getTitle() << " dungeon, you will be teleported in 3 seconds.";
                     member->sendFYIBox(text);
                     member->setDungeon(this);
                     if (!sent) {
                         sent = true;
                         text.clear();
                         text << "Joined " << getTitle() << " dungeon, you will be teleported in 3 seconds.";
                         leader->sendFYIBox(text);
                     }
                 }
                 else {
                     std::stringExtended text(128);
                     text << "Party leader joined " << getTitle() << " dungeon queue! Position in queue: " << signed(queuePosition);
                     member->sendFYIBox(text);
                     if (!sent) {
                         sent = true;
                         text.clear();
                         text << "Joined " << getTitle() << " dungeon queue! Position in queue: " << signed(queuePosition);
                         leader->sendFYIBox(text);
                     }
                 }
             }
         }
     }
     else {
         std::stringExtended text(128);
         if (queueAmount == 1 && queuePosition == 1 && getFreeInstance()) {
             text << "Joined " << getTitle() << " dungeon, you will be teleported in 3 seconds";
             player->sendFYIBox(text);
         }
         else {
             text << "Joined " << getTitle() << " dungeon queue! Position in queue: " << signed(queuePosition);
             player->sendFYIBox(text);
         }
     }
 
     player->setDungeon(this);
     if (queueAmount == 1 && queuePosition == 1 && getFreeInstance()) {
         queue->popPlayer();
         prepare(player, uid);
     }
 
     g_events->eventDungeonOnQueue(this);
 
     return true;
 }
 
 void Dungeon::prepare(Player* player, uint64_t uid)
 {
     if (!canJoin(player, false, true)) {
         player->sendFYIBox("Can't join dungeon, you don't meet requirements!");
         queue->onPlayerLeave(player, true);
         return;
     }
 
     int32_t currentTime = OTSYS_TIME() / 1000;
     Party* party = player->getParty();
     int8_t lives = 3;
     uint8_t players = 1;
     if (require.party.max >= 2 && party && !isSolo()) {
         PlayerVector members = party->getMembers();
         players += members.size();
         lives -= members.size();
         if (party->getLeader() == player) {
             for (Player* member : members) {
                 if (!canJoin(member, true, true)) {
                     std::stringExtended text(96);
                     text << "Can't join dungeon, " << member->getName() << " doesn't meet requirements!";
                     player->sendFYIBox(text);
                     queue->onPlayerLeave(player, true);
                     return;
                 }
             }
             
             for (Player* member : members) {
                 member->setDungeon(this);
                 if (require.items.size() > 0) {
                     for (auto const& item : require.items) {
                         member->removeItemOfType(item.first, item.second, -1, true);
                     }
                 }
                 if (require.gold > 0) {
                     member->removeTotalMoney(require.gold);
                 }
                 if (require.time.storage > 0) {
                     member->addStorageValue(require.time.storage, currentTime + require.time.time);
                 }
             }
         }
         if (require.items.size() > 0) {
             for (auto const& item : require.items) {
                 player->removeItemOfType(item.first, item.second, -1, true);
             }
         }
         if (require.gold > 0) {
             player->removeTotalMoney(require.gold);
         }
         if (require.time.storage > 0) {
             player->addStorageValue(require.time.storage, currentTime + require.time.time);
         }
     }
     else {
         if (require.items.size() > 0) {
             for (auto const& item : require.items) {
                 player->removeItemOfType(item.first, item.second, -1, true);
             }
         }
         if (require.gold > 0) {
             player->removeTotalMoney(require.gold);
         }
         if (require.time.storage > 0) {
             player->addStorageValue(require.time.storage, currentTime + require.time.time);
         }
     }
 
     DungeonInstance* instance = getFreeInstance();
     if (instance) {
         setPlayers(players);
         if (uid > 0) {
             instance->setKeyUID(uid);
         }
         instance->setLives(lives);
         instance->build(mapFile, players);
         g_events->eventDungeonOnPrepare(this, instance, player);
         g_dispatcher.addEvent(2500, std::bind(dungeonStartCallback, getId(), player->getID(), instance));
     }
     else {
         std::cout << "[Error - Dungeon:prepare] Couldn't find free instance" << std::endl;
     }
 }
 
 void Dungeon::start(uint32_t pid, DungeonInstance* instance)
 {
     Player* player = g_game.getPlayerByID(pid);
     if (!player) {
         std::cout << "[Dungeon::start] Player " << pid << " not found." << std::endl;
         sendNextPlayer();
         instance->destroy();
         return;
     }
 
     Party* party = player->getParty();
     if (require.party.max >= 2 && party && !isSolo()) {
         PlayerVector members = party->getMembers();
         if (party->getMemberCount() + 1 < require.party.min) {
             for (Player* member : members) {
                 onPlayerLeave(member);
             }
             onPlayerLeave(player);
             return;
         }
         if (party->getMemberCount() + 1 > require.party.max) {
             for (Player* member : members) {
                 onPlayerLeave(member);
             }
             onPlayerLeave(player);
             return;
         }
         members.push_back(player);
         instance->start(this, members);
 
         for (Player* member : members) {
             pid = member->getID();
             if (timeoutEvent[pid] != 0) {
                 g_dispatcher.stopEvent(timeoutEvent[pid]);
                 uint64_t eventId = g_dispatcher.addEvent(getDuration(), std::bind(dungeonTimeoutCallback, getId(), pid));
                 timeoutEvent[pid] = eventId;
             }
             else {
                 uint64_t eventId = g_dispatcher.addEvent(getDuration(), std::bind(dungeonTimeoutCallback, getId(), pid));
                 timeoutEvent[pid] = eventId;
             }
         }
     }
     else {
         if (!player || player->isRemoved()) {
             std::cout << "[Dungeon::start] Player " << pid << " not found or is removed." << std::endl;
             sendNextPlayer();
             instance->destroy();
             return;
         }
 
         if (!player->getDungeon()) {
             std::cout << "[Dungeon::start] Player " << player->getName() << " has no dungeon data." << std::endl;
             onPlayerLeave(player);
             return;
         }
         
         instance->start(this, player);
 
         pid = player->getID();
         if (timeoutEvent[pid] != 0) {
             g_dispatcher.stopEvent(timeoutEvent[pid]);
             uint64_t eventId = g_dispatcher.addEvent(getDuration(), std::bind(dungeonTimeoutCallback, getId(), pid));
             timeoutEvent[pid] = eventId;
         }
         else {
             uint64_t eventId = g_dispatcher.addEvent(getDuration(), std::bind(dungeonTimeoutCallback, getId(), pid));
             timeoutEvent[pid] = eventId;
         }
     }
 }
 
 void Dungeon::timeout(uint32_t pid)
 {
     Player* player = g_game.getPlayerByID(pid);
     if (!player) {
         return;
     }
 
     onDungeonFail(getPlayerInstance(player));
     onPlayerLeave(player);
     g_game.internalTeleport(player, Position(671, 1024, 7), false);
     player->sendFYIBox("Time's up! You were teleported back to temple.");
 }
 
 void Dungeon::onPlayerLeave(Player* player)
 {
     if (!player) {
         return;
     }
     
     player->setDungeon(nullptr);
 
     uint32_t pid = player->getID();
     if (timeoutEvent[pid] != 0) {
         g_dispatcher.stopEvent(timeoutEvent[pid]);
         timeoutEvent[pid] = 0;
     }
     
     DungeonInstance* instance = getPlayerInstance(player);
     if (instance) {
         g_events->eventDungeonOnPlayerLeave(this, instance, player);
         
         g_game.internalTeleport(player, Position(671, 1024, 7), false);
         
         if (instance->removeRunner(player)) {
             instance->destroy();
             sendNextPlayer();
         }
     }
 }
 
 void Dungeon::sendNextPlayer()
 {
 
     if (queue->getPlayersNumber() > 0) {
         Player* player = queue->popPlayer();
         if (queue->getPlayersNumber() > 0) {
             queue->sendUpdate();
         }
         else {
             if (player) {
                 player->sendFYIBox("Queue update, you are next! You will be teleported in 3 seconds.");
             }
         }
         if (player) {
             prepare(player);
         }
     }
 }
 
 bool Dungeon::canJoin(Player* player, bool partyMember/*= false*/, bool prepare/*= false*/)
 {
     if (!prepare) {
         Dungeon* dungeon = player->getDungeon();
         if (dungeon) {
             player->sendFYIBox("You are already in a dungeon or queue!");
             return false;
         }
     }
 
     if (require.gold > 0) {
         if (player->getTotalMoney() < require.gold) {
             std::stringExtended text(64);
             text << "You need at least " << require.gold << " to join! Missing " << require.gold - player->getTotalMoney() << " gold.";
             player->sendFYIBox(text);
             return false;
         }
     }
 
     if (require.time.storage > 0) {
         int32_t savedTime;
         int64_t currentTime = OTSYS_TIME() / 1000;
         player->getStorageValue(require.time.storage, savedTime);
         if (savedTime > currentTime) {
             std::stringExtended text(140);
             text << "You have to wait " << timeFromSeconds(savedTime - currentTime) << "to join!";
             player->sendFYIBox(text);
             return false;
         }
     }
 
     if (require.level > 0) {
         if (player->getLevel() < require.level) {
             std::stringExtended text(64);
             text << "This Dungeon requires level " << require.level << "+ to join!";
             player->sendFYIBox(text);
             return false;
         }
     }
 
     
     if (require.paragon > 0) {
         int32_t paragon;
         player->getStorageValue(800025, paragon);
         if (paragon < require.paragon) {
             std::stringExtended text(64);
             text << "This Dungeon requires paragon " << require.paragon << "+ to join!";
             player->sendFYIBox(text);
             return false;
         }
     }
 
     if (require.itemLevel > 0) {
         if (player->getItemLevel() < require.itemLevel) {
             std::stringExtended text(96);
             text << "This Dungeon requires total Item Level " << require.itemLevel << "+ to join!";
             player->sendFYIBox(text);
             return false;
         }
     }
 
     if (require.items.size() > 0) {
         for (auto const& item : require.items) {
             if (player->getItemTypeCount(item.first, -1) < item.second) {
                 player->sendFYIBox("Missing required items to join dungeon!");
                 return false;
             }
         }
     }
 
     if (!partyMember) {
         if (require.party.max >= 2) {
             Party* party = player->getParty();
             if (party) {
                 size_t total = party->getMemberCount() + 1;
                 if (total >= require.party.min) {
                     if (total > require.party.max) {
                         player->sendFYIBox("Party size exceeds dungeon limit!");
                         return false;
                     }
                     if (party->getLeader() != player) {
                         player->sendFYIBox("Only party leader can join dungeon queue!");
                         return false;
                     }
                 }
                 else {
                     std::stringExtended text(96);
                     text << "Dungeon requires party of " << require.party.min << "-" << require.party.max << " players!";
                     player->sendFYIBox(text);
                     return false;
                 }
             }
             else if (require.party.min >= 2) {
                 std::stringExtended text(96);
                 text << "Dungeon requires party of " << require.party.min << "-" << require.party.max << " players!";
                 player->sendFYIBox(text);
                 return false;
             }			
         }
     }
 
     if (require.storage.size() > 0) {
         for (auto const& storage : require.storage) {
             int32_t value;
             player->getStorageValue(storage.key, value);
             if (value < storage.value) {
                 player->sendFYIBox(storage.error);
                 return false;
             }
         }
     }
     
     Tile* tile = player->getTile();
     if (tile && !tile->hasFlag(TILESTATE_PROTECTIONZONE)) {
         if (player->isPzLocked() || player->hasCondition(CONDITION_INFIGHT)) {
             player->sendFYIBox("You can't be in-fight to join dungeon queue!");
             return false;
         }
     }
 
     return true;
 }
 
 void Dungeon::addInstance(Position position)
 {
    DungeonInstance* instance = new DungeonInstance(position);
    instance->setDungeon(this);
    instance->setId(++lastInstanceId);
    instance->setChunkId(++lastChunkInstanceId);
    instances.push_back(std::move(instance));
 }
 
 void Dungeon::onBossKill(DungeonInstance* instance)
 {
     instance->setRunTime(OTSYS_TIME() - instance->getStartTime());
     onDungeonSuccess(instance);
 }
 
 void Dungeon::onStart(DungeonInstance* instance, Player* player)
 {
     g_events->eventDungeonOnStart(this, instance, player);
 }
 
 void Dungeon::onDungeonSuccess(DungeonInstance* instance)
 {
     g_events->eventDungeonOnSuccess(this, instance);
 }
 
 void Dungeon::onDungeonFail(DungeonInstance* instance)
 {
     g_events->eventDungeonOnFail(this, instance);
 }
 
 DungeonInstance* Dungeon::getFreeInstance()
 {
     for (DungeonInstance* instance : instances) {
         if (instance->isFree()) {
             return instance;
         }
     }
     return nullptr;
 }
 
 DungeonInstance* Dungeon::getPlayerInstance(Player* player)
 {
     if (!player) {
        return nullptr;
     }
     for (auto instance : instances) {
         if (instance && instance->hasRunner(player)) {
             return instance;
         }
     }
 
     return nullptr;
 }
 
 uint32_t Dungeon::getEstimatedQueueTime(Player* player) const
 {
     uint32_t time = 0;
     for (auto instance : instances) {
         if (instance->getRunTime() > 0) {
             time = time + instance->getRunTime();
         }
     }
 
     if (time == 0) {
         time = getDuration();
     }
     else {
         time /= instances.size() + 1;
     }
 
     int16_t playerPosition = queue->getPlayerPosition(player);
     time *= std::max<uint32_t>(1, playerPosition != -1 ? playerPosition : queue->getPlayersNumber());
 
     return time;
 }
 
 static std::atomic<size_t> s_totalDungeonMaps{0};
 static std::atomic<size_t> s_loadedDungeonMaps{0};
 static int64_t s_dungeonStartTime = 0;

 void Dungeon::preBuild()
 {
     const std::string& path = "data/dungeons/" + mapFile + ".otbm";

     if (s_totalDungeonMaps == 0) {
         s_dungeonStartTime = OTSYS_TIME();
         std::cout << ">> Loading dungeon maps..." << std::endl;
     }

     s_totalDungeonMaps += instances.size();

     for (DungeonInstance* instance : instances) {
         const Position& position = instance->getPosition();
         g_dispatcher.addTask([path, position]() {
             try {
                 g_game.loadDungeon(path, position);
             }
             catch (const std::exception& e) {
                 std::cout << "[Error - Dungeon::preBuild] Failed to load map: " << e.what() << std::endl;
             }

             size_t loaded = ++s_loadedDungeonMaps;
             size_t total = s_totalDungeonMaps.load();
             if (total > 0) {
                 size_t percent = (loaded * 100) / total;
                 if (isInteractiveTerminal()) {
                     int barWidth = 30;
                     int posBar = static_cast<int>((percent * barWidth) / 100);
                     std::cout << "\r   [";
                     for (int b = 0; b < barWidth; ++b) {
                         if (b < posBar) {
                             std::cout << "=";
                         } else if (b == posBar) {
                             std::cout << ">";
                         } else {
                             std::cout << " ";
                         }
                     }
                     std::cout << "] " << percent << "% (" << loaded << "/" << total << " maps)" << std::flush;
                 } else {
                     static size_t lastDungPercent = 101;
                     if ((percent % 10 == 0 && percent != lastDungPercent) || loaded == total) {
                         lastDungPercent = percent;
                         int barWidth = 30;
                         int posBar = static_cast<int>((percent * barWidth) / 100);
                         std::cout << ">> Dungeons: [";
                         for (int b = 0; b < barWidth; ++b) {
                             if (b < posBar) {
                                 std::cout << "=";
                             } else if (b == posBar) {
                                 std::cout << ">";
                             } else {
                                 std::cout << " ";
                             }
                         }
                         std::cout << "] " << percent << "% (" << loaded << "/" << total << " maps)" << std::endl;
                     }
                 }

                 if (loaded >= total) {
                     std::cout << std::endl << ">> All dungeon maps loaded in " << (OTSYS_TIME() - s_dungeonStartTime) / 1000.0 << "s" << std::endl;
                     std::cout << ">> " << g_config.getString(ConfigManager::SERVER_NAME) << " Server Online!!" << std::endl << std::endl;
                 }
             }
          });
     }
 }
 
 bool DungeonInstance::areAllObjectivesComplete() const
 {
     if (!dungeon) {
         return false;
     }
     
     uint8_t totalObjectives = dungeon->getObjectivesCount();
     if (totalObjectives == 0) {
         return true;
     }
     
     for (uint8_t i = 0; i < totalObjectives; ++i) {
         if (!isObjectiveComplete(i)) {
             return false;
         }
     }
     return true;
 }
 
 // Dungeon Instance
 void DungeonInstance::start(Dungeon* dungeon, Player* player)
 {
     addRunner(player);
     g_game.internalTeleport(player, position + dungeon->getStartPosition());
     g_game.addMagicEffect(position + dungeon->getStartPosition(), CONST_ME_TELEPORT);
     dungeon->onStart(this, player);
     startTime = OTSYS_TIME();
     dungeon->getQueue()->sendUpdate();
 }
 
 void DungeonInstance::start(Dungeon* dungeon, std::vector<Player*> members)
 {
     for (auto player : members) {
         addRunner(player);
         g_game.internalTeleport(player, position + dungeon->getStartPosition());
         g_game.addMagicEffect(position + dungeon->getStartPosition(), CONST_ME_TELEPORT);
         dungeon->onStart(this, player);
     }
     startTime = OTSYS_TIME();
     dungeon->getQueue()->sendUpdate();
 }
 
 void DungeonInstance::build(const std::string& mapFile, uint8_t players)
 {
     free = false;
     bossSpawned = false;
 
     const std::string& path = "data/dungeons/" + mapFile + ".otbm";
     const Position& position = getPosition();
     DungeonInstance* instance = this;
     g_dispatcher.addTask([path, position, instance, players]() {
         g_game.respawnDungeon(path, instance, position, players);
     });
 }
 
 void DungeonInstance::clearAllMonsters() {
     for (uint32_t id : extraMonsters) {
         Monster* monster = g_game.getMonsterByID(id);
         if (monster && !monster->isRemoved()) {
            g_game.removeCreature(monster);
         }
     }
     extraMonsters.clear();
 }

 void DungeonInstance::clearAllItems() {
    for (Item* item : itemsInstance) {
        if (item) {
            if (item->isRemoved()) {
                item->decrementReferenceCounter();
            } else {
                Tile* itemTile = item->getTile();
                if (itemTile) {
                    Position position = itemTile->getPosition();
                    position.y -= 1;
                    Tile* tile = g_game.map.getTile(position);
                    if (tile) {
                        tile->removeWidget();
                    }
                }
                g_game.internalRemoveItem(item);
            }
        }
    }
    itemsInstance.clear();
 }
 
 void DungeonInstance::destroy()
 {
     free = true;
     if (boss) {
         if (boss->isRemoved()) {
             boss->decrementReferenceCounter();
             boss = nullptr;
         }
         else {
             g_game.removeCreature(boss);
             boss = nullptr;
         }
     }
     clearAllMonsters();
     clearAllItems();
 }
 
 bool DungeonInstance::spawnBoss()
 {
    const std::string& bossName = dungeon->getBoss();
    if (bossName.empty()) {
        return false;
    }

    std::unique_ptr<Monster> monster_ptr(Monster::createMonster(dungeon->getBoss()));

    if (g_game.placeCreature(monster_ptr.get(), position + dungeon->getBossPosition(), false, true)) {
        boss = monster_ptr.release();
        g_game.addCreatureHealth(boss);
        boss->registerCreatureEvent("DungeonBossDeath");
        boss->incrementReferenceCounter();
        bossSpawned = true;
        return true;
    }
 
     return false;
 }
 
 Monster* DungeonInstance::getBoss() {
     if (boss && boss->isRemoved()) {
         boss->decrementReferenceCounter();
         boss = nullptr;
     }
     return boss;
 }
 
 bool DungeonInstance::removeRunner(Player* player)
 {
     runners.erase(std::remove(runners.begin(), runners.end(), player), runners.end());
     return runners.size() == 0;
 }

  
void DungeonInstance::addItem(Item* item) {
    itemsInstance.emplace_back(item);
    itemsInstance.shrink_to_fit();
    item->incrementReferenceCounter();
}
 
 // Dungeon Queue
 void DungeonQueue::sendUpdate()
 {
     std::vector<size_t> toRemove;
     std::stringExtended text(42);
     for (size_t i = 0; i < players.size(); ++i) {
         Player* player = players.at(i);
         if (!player || player->isOffline()) {
             toRemove.emplace_back(i);
         }
         else {
             text.clear();
             text << "Queue update!\nNew position: " << i;
             player->sendFYIBox(text);
         }
     }
 
     for (size_t i = 0; i < toRemove.size(); ++i) {
         players.erase(players.begin() + toRemove[i]);
     }
 
     players.shrink_to_fit();
 
     g_events->eventDungeonOnQueue(dungeon);
 }
 
 void DungeonQueue::onPlayerLeave(Player* player, bool sendNext)
 {
     removePlayer(player);
     Dungeon* dungeon = player->getDungeon();
     if (dungeon) {
         if (sendNext) {
             dungeon->sendNextPlayer();
         }
 
         player->setDungeon(nullptr);
         Party* party = player->getParty();
         if (dungeon->getRequiredParty().max >= 2 && party) {
             if (party->getLeader() == player) {
                 PlayerVector members = party->getMembers();
                 for (Player* member : members) {
                     member->setDungeon(nullptr);
                     g_events->eventPlayerOnQueueLeave(member, this);
                 }
             }
         }
         g_events->eventPlayerOnQueueLeave(player, this);
     }
     else {
         sendUpdate();
     }
 }
 
 size_t DungeonQueue::addPlayer(Player* player)
 {
     size_t queuePosition = players.size() + 1;
     players.emplace_back(player);
     players.shrink_to_fit();
     return queuePosition;
 }
 
 Player* DungeonQueue::popPlayer()
 {
     Player* last = std::move(players.front());
     players.pop_front();
     return last;
 }
 
 bool DungeonQueue::removePlayer(Player* player)
 {
     return players.erase(std::remove(players.begin(), players.end(), player), players.end()) != players.end();
 }
 
 void DungeonQueue::switchPlayers(Player* oldPlayer, Player* newPlayer)
 {
     size_t old = getPlayerPosition(oldPlayer);
     players.at(old) = newPlayer;
 }
 
 int16_t DungeonQueue::getPlayerPosition(Player* player) const
 {
     for (size_t i = 0; i < players.size(); ++i) {
         Player* queuePlayer = players.at(i);
         if (queuePlayer && queuePlayer == player) {
             return static_cast<int16_t>(i);
         }
     }
     return -1;
 }