#ifndef DUNGEON_H
#define DUNGEON_H

#include <deque>
#include <map>

#include "position.h"
#include "enums.h"

class Player;
class Dungeon;
class Monster;
class Item;

struct StorageRequire
{
	StorageRequire(uint32_t key, int32_t value, std::string details, std::string error) : key(key), value(value), details(std::move(details)), error(std::move(error)) {};

	uint32_t key;
	int32_t value;
	std::string details;
	std::string error;
};

struct PartyRequire
{
	uint8_t min = 1;
	uint8_t max = 1;
};

struct TimeRequire
{
	uint32_t storage = 0;
	uint32_t time = 0;
};

struct DungeonRequire
{
	uint16_t level = 0;
	uint16_t paragon = 0;
	uint16_t itemLevel = 0;

	TimeRequire time;

	uint64_t gold = 0;

	PartyRequire party;

	std::map<uint16_t, uint8_t> items;
	std::vector<StorageRequire> storage;
};

struct DungeonReward
{
	DungeonReward(uint16_t itemId, uint8_t amount, uint8_t chance) : itemId(itemId), amount(amount), chance(chance) {};
	uint16_t itemId;
	uint8_t amount;
	uint8_t chance;
};

class DungeonQueue
{
public:
	DungeonQueue() = default;
	virtual ~DungeonQueue() = default;

public:
	void sendUpdate();

	void onPlayerLeave(Player* player, bool sendNext = false);
	size_t addPlayer(Player* player);
	Player* popPlayer();
	bool removePlayer(Player* player);
	void switchPlayers(Player* oldPlayer, Player* newPlayer);

	std::deque<Player*> getPlayers() {
		return players;
	}

	size_t getPlayersNumber() const {
		return players.size();
	}

	int16_t getPlayerPosition(Player* player) const;

	void setDungeon(Dungeon* dungeon) {
		this->dungeon = dungeon;
	}

	Dungeon* getDungeon() {
		return dungeon;
	}

private:
	std::deque<Player*> players;

	Dungeon* dungeon = nullptr;
};

class DungeonInstance
{
public:
	DungeonInstance() = default;
	DungeonInstance(Position position) : position(std::move(position)) {};
	virtual ~DungeonInstance() = default;

public:
	void start(Dungeon* dungeon, Player* player);
	void start(Dungeon* dungeon, std::vector<Player*> members);

	void build(const std::string& mapFile, uint8_t players);
	void destroy();

	bool isFree() const {
		return free;
	}

	void setPosition(Position position) {
		this->position = std::move(position);
	}

	const Position& getPosition() const {
		return position;
	}

	void setId(uint16_t id) {
		this->id = id;
	}

	uint16_t getId() const {
		return id;
	}

	void setChunkId(uint16_t value) {
		this->chunkId = value;
	}

	uint16_t getChunkId() const {
		return chunkId;
	}

	void addRunner(Player* player) {
		runners.emplace_back(player);
		runners.shrink_to_fit();
	}

	bool hasRunner(Player* player) {
		return std::find(runners.begin(), runners.end(), player) != runners.end();
	}

	std::vector<Player*> getRunners() {
		return runners;
	}

	void addItem(Item* item);
	void clearAllItems();

	void addMonster(uint32_t id) {
		if (std::find(extraMonsters.begin(), extraMonsters.end(), id) != extraMonsters.end()) {
			return;
		}
	
		extraMonsters.push_back(id);
	}

	void clearAllMonsters();
	bool removeRunner(Player* player);

	void setStartTime(uint16_t time) {
		this->startTime = time;
	}

	int64_t getStartTime() const {
		return startTime;
	}

	void setRunTime(int64_t time) {
		this->runTime = time;
	}

	int64_t getRunTime() const {
		return runTime;
	}

	void setDungeon(Dungeon* dungeon) {
		this->dungeon = dungeon;
	}

	Dungeon* getDungeon() {
		return dungeon;
	}

	void setMonstersTotalCount(uint16_t monsters) {
		this->monsters = monsters;
		this->monstersTotal = monsters;
	}

	uint16_t getMonstersTotalCount() const {
		return monstersTotal;
	}

	void setMonstersCount(uint16_t monsters) {
		this->monsters = monsters;
	}

	uint16_t getMonstersCount() const {
		return monsters;
	}

	Monster* getBoss();
	bool spawnBoss();

	bool isBossSpawned() const {
		return bossSpawned;
	}

	uint64_t getKeyUID() const {
		return uid;
	}

	void setKeyUID(uint64_t uid) {
		this->uid = uid;
	}

	void setLives(int8_t lives) {
		this->lives = lives;
	}

	int8_t getLives() const {
		return lives;
	}

	// Objective tracking
	void completeObjective(uint8_t id) {
		completedObjectives[id] = true;
	}

	bool isObjectiveComplete(uint8_t id) const {
		auto it = completedObjectives.find(id);
		return it != completedObjectives.end() && it->second;
	}

	bool areAllObjectivesComplete() const;

	uint8_t getCompletedObjectivesCount() const {
		uint8_t count = 0;
		for (const auto& pair : completedObjectives) {
			if (pair.second) count++;
		}
		return count;
	}

private:
	Position position;

	std::vector<Player*> runners;
	std::vector<Item*> itemsInstance;

	Dungeon* dungeon = nullptr;

	Monster* boss = nullptr;

	std::list<uint32_t> extraMonsters;

	bool free = true;
	bool bossSpawned = false;
	bool preBuilt = false;

	int8_t lives = 0;
	uint16_t id = 0;
	uint16_t chunkId = 0;
	uint64_t uid = 0;
	int64_t startTime = 0;
	int64_t runTime = 0;
	uint16_t monsters = 0;
	uint16_t monstersTotal = 0;

	std::map<uint8_t, bool> completedObjectives;
};

class Dungeon
{
public:
	Dungeon();
	virtual ~Dungeon() = default;

public:
	bool joinQueue(Player* player, uint64_t uid);
	void prepare(Player* player, uint64_t uid = 0);
	void start(uint32_t pid, DungeonInstance* instance);
	void onStart(DungeonInstance* instance, Player* player);
	void timeout(uint32_t pid);
	void onPlayerLeave(Player* player);
	void sendNextPlayer();
	bool canJoin(Player* player, bool partyMember = false, bool prepare = false);
	void onDungeonSuccess(DungeonInstance* instance);
	void onDungeonFail(DungeonInstance* instance);
	void preBuild();

	void setTitle(std::string title) {
		this->title = std::move(title);
	}

	const std::string& getTitle() const {
		return title;
	}


	void setPlayers(uint8_t players) {
		this->players = players;
	}

	uint8_t getPlayers() const {
		return players;
	}

	void setDuration(uint32_t duration) {
		this->duration = duration;
	}

	uint32_t getDuration() const {
		return duration;
	}

	void setKillPercent(uint8_t value) {
		killPercent = value;
	}

	uint8_t getKillPercent() const {
		return killPercent;
	}

	void setCompleteType(DungeonCompleteType type) {
		completeType = type;
	}

	DungeonCompleteType getCompleteType() const {
		return completeType;
	}
	
	bool isSolo() const {
		return solo;
	}

	void setSolo(bool value) {
		solo = value;
	}

	void setRequiredLevel(uint16_t level) {
		require.level = level;
	}

	uint16_t getRequiredLevel() const {
		return require.level;
	}

	void setRequiredParagon(uint16_t paragon) {
		require.paragon = paragon;
	}

	uint16_t getRequiredParagon() const {
		return require.paragon;
	}

	void setRequiredItemLevel(uint16_t itemLevel) {
		require.itemLevel = itemLevel;
	}

	uint16_t getRequiredItemLevel() const {
		return require.itemLevel;
	}

	void setRequiredParty(uint8_t min, uint8_t max) {
		require.party.min = min;
		require.party.max = max;
	}

	const PartyRequire& getRequiredParty() const {
		return require.party;
	}

	void setRequiredGold(uint64_t value) {
		require.gold = value;
	}

	uint64_t getRequiredGold() const {
		return require.gold;
	}

	void addRequiredItem(uint16_t itemId, uint8_t count) {
		require.items.emplace(itemId, count);
	}

	const std::map<uint16_t, uint8_t>& getRequiredItems() const {
		return require.items;
	}

	void addRequiredStorage(uint32_t key, int32_t value, std::string details, std::string error) {
		require.storage.emplace_back(key, value, std::move(details), std::move(error));
		require.storage.shrink_to_fit();
	}

	const std::vector<StorageRequire>& getRequiredStorages() const {
		return require.storage;
	}

	void setRequiredTime(uint32_t timeStorage, uint32_t time) {
		require.time.storage = timeStorage;
		require.time.time = time;
	}

	const TimeRequire& getRequiredTime() const {
		return require.time;
	}

	void addReward(uint16_t itemId, uint8_t amount, uint8_t chance) {
		rewards.emplace_back(itemId, amount, chance);
	}

	const std::vector<DungeonReward>& getRewards() const {
		return rewards;
	}

	void addInstance(Position position);
	
	void onBossKill(DungeonInstance* instance);

	DungeonInstance* getInstance(size_t index) {
		return instances.at(index);
	}

	DungeonInstance* getFreeInstance();

	DungeonInstance* getPlayerInstance(Player* player);

	void setMapFile(std::string mapFile) {
		this->mapFile = std::move(mapFile);
	}

	const std::string& getMapFile() const {
		return mapFile;
	}

	DungeonQueue* getQueue() {
		return queue;
	}

	void setId(uint8_t id) {
		this->id = id;
	}

	uint8_t getId() const {
		return id;
	}

	void setBoss(std::string boss, Position spawnPosition) {
		this->boss = std::move(boss);
		this->bossPosition = std::move(spawnPosition);
	}

	const std::string& getBoss() const {
		return boss;
	}

	const Position& getBossPosition() const {
		return bossPosition;
	}

	void addChallenge(uint16_t id) {
		challenges.emplace_back(id);
		challenges.shrink_to_fit();
	}

	const std::vector<uint16_t>& getChallenges() const {
		return challenges;
	}

	void addObjective(std::string text) {
		objectives.emplace_back(std::move(text));
		objectives.shrink_to_fit();
	}

	// Backward compatibility alias
	void addBonusObjective(std::string text) {
		addObjective(std::move(text));
	}

	const std::vector<std::string>& getObjectives() const {
		return objectives;
	}

	// Backward compatibility alias
	const std::vector<std::string>& getBonusObjectives() const {
		return objectives;
	}

	uint8_t getObjectivesCount() const {
		return static_cast<uint8_t>(objectives.size());
	}

	void addRewardChestPosition(Position position) {
		rewardChestPositions.emplace_back(position);
		rewardChestPositions.shrink_to_fit();
	}

	const std::vector<Position>& getRewardChestPositions() const {
		return rewardChestPositions;
	}

	uint32_t getEstimatedQueueTime(Player* player) const;

	void setStartPosition(Position startPosition) {
		this->startPosition = std::move(startPosition);
	}

	const Position& getStartPosition() const {
		return startPosition;
	}

private:
	std::string title;
	std::string mapFile;
	std::string boss;

	Position bossPosition;
	Position startPosition;
	uint16_t lastInstanceId = 0;

	uint8_t id = 0;
	uint8_t killPercent = 100;

	DungeonCompleteType completeType = DUNGEONTYPE_KILL_PERCENT;

	bool solo = false;

	uint32_t duration = 0;
	uint8_t players = 1;

	std::map<uint32_t, uint64_t> timeoutEvent;

	std::vector<DungeonReward> rewards;
	std::vector<DungeonInstance*> instances;
	std::vector<uint16_t> challenges;
	std::vector<std::string> objectives;
	std::vector<Position> rewardChestPositions;

	DungeonRequire require;

	DungeonQueue* queue = nullptr;
};

#endif
