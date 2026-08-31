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

#ifndef FS_CREATURE_H_5363C04015254E298F84E6D59A139508
#define FS_CREATURE_H_5363C04015254E298F84E6D59A139508

#include "map.h"
#include "position.h"
#include "condition.h"
#include "const.h"
#include "tile.h"
#include "enums.h"
#include "creatureevent.h"

using ConditionList = std::vector<Condition*>;
using CreatureEventList = std::vector<CreatureEvent*>;
using CreatureList = std::list<Creature*>;

enum slots_t : uint8_t {
	CONST_SLOT_WHEREEVER = 0,
	CONST_SLOT_HEAD = 1,
	CONST_SLOT_NECKLACE = 2,
	CONST_SLOT_BACKPACK = 3,
	CONST_SLOT_ARMOR = 4,
	CONST_SLOT_RIGHT = 5,
	CONST_SLOT_LEFT = 6,
	CONST_SLOT_LEGS = 7,
	CONST_SLOT_FEET = 8,
	CONST_SLOT_RING = 9,
	CONST_SLOT_GLOVES = 10,
	CONST_SLOT_RING2 = 11,

	CONST_SLOT_SPELL1 = 12,
	CONST_SLOT_SPELL2 = 13,
	CONST_SLOT_SPELL3 = 14,
	CONST_SLOT_SPELL4 = 15,
	CONST_SLOT_POTION1 = 16,
	CONST_SLOT_POTION2 = 17,

	CONST_SLOT_FORGE = 18,

	CONST_SLOT_SUPPORT1_1 = 19,
	CONST_SLOT_SUPPORT1_2 = 20,
	CONST_SLOT_SUPPORT1_3 = 21,
	CONST_SLOT_SUPPORT1_4 = 22,

	CONST_SLOT_SUPPORT2_1 = 23,
	CONST_SLOT_SUPPORT2_2 = 24,
	CONST_SLOT_SUPPORT2_3 = 25,
	CONST_SLOT_SUPPORT2_4 = 26,

	CONST_SLOT_SUPPORT3_1 = 27,
	CONST_SLOT_SUPPORT3_2 = 28,
	CONST_SLOT_SUPPORT3_3 = 29,
	CONST_SLOT_SUPPORT3_4 = 30,

	CONST_SLOT_SUPPORT4_1 = 31,
	CONST_SLOT_SUPPORT4_2 = 32,
	CONST_SLOT_SUPPORT4_3 = 33,
	CONST_SLOT_SUPPORT4_4 = 34,
	
	CONST_SLOT_STORE_INBOX = 35,
	CONST_SLOT_RELICT_BOX = 36,
	
	CONST_SLOT_LAST = CONST_SLOT_RELICT_BOX,
	CONST_SLOT_FIRST = CONST_SLOT_HEAD,
};

struct FindPathParams {
	bool fullPathSearch = true;
	bool clearSight = false;
	bool allowDiagonal = true;
	bool keepDistance = false;
	bool ignoreDiagonalCost = false;
	int32_t maxSearchDist = 0;
	int32_t minTargetDist = -1;
	int32_t maxTargetDist = -1;
};

class Map;
class Thing;
class Container;
class Player;
class Monster;
class Npc;
class Item;
class Tile;

static constexpr int32_t EVENT_CREATURECOUNT = 10;
static constexpr int32_t EVENT_CREATURE_THINK_INTERVAL = 1000;
static constexpr int32_t EVENT_CHECK_CREATURE_INTERVAL = (EVENT_CREATURE_THINK_INTERVAL / EVENT_CREATURECOUNT);

class FrozenPathingConditionCall
{
	public:
		explicit FrozenPathingConditionCall(Position targetPos) : targetPos(std::move(targetPos)) {}

		bool operator()(const Position& startPos, const Position& testPos,
		                const FindPathParams& fpp, int32_t& bestMatchDist) const;

		bool isInRange(const Position& startPos, const Position& testPos,
		               const FindPathParams& fpp) const;

	private:
		Position targetPos;
};

//////////////////////////////////////////////////////////////////////
// Defines the Base class for all creatures and base functions which
// every creature has

class Creature : virtual public Thing
{
	protected:
		Creature();

	public:
		static double speedA, speedB, speedC;

		virtual ~Creature();

		// non-copyable
		Creature(const Creature&) = delete;
		Creature& operator=(const Creature&) = delete;

		Creature* getCreature() override final {
			return this;
		}
		const Creature* getCreature() const override final {
			return this;
		}
		virtual Player* getPlayer() {
			return nullptr;
		}
		virtual const Player* getPlayer() const {
			return nullptr;
		}
		virtual Npc* getNpc() {
			return nullptr;
		}
		virtual const Npc* getNpc() const {
			return nullptr;
		}
		virtual Monster* getMonster() {
			return nullptr;
		}
		virtual const Monster* getMonster() const {
			return nullptr;
		}

		virtual const std::string& getName() const = 0;
		virtual void setName(std::string name) = 0;

		virtual const std::string& getNameDescription() const = 0;

		virtual CreatureType_t getType() const = 0;

		virtual void setID() = 0;
		void setRemoved() {
			isInternalRemoved = true;
		}

		uint32_t getID() const {
			return id;
		}
		virtual void removeList() = 0;
		virtual void addList() = 0;

		virtual bool canSee(const Position& pos) const;
		virtual bool canSeeCreature(const Creature* creature) const;

		virtual RaceType_t getRace() const {
			return RACE_NONE;
		}
		virtual Skulls_t getSkull() const {
			return skull;
		}
		virtual Skulls_t getSkullClient(const Creature* creature) const {
			return creature->getSkull();
		}
		void setSkull(Skulls_t newSkull);
		Direction getDirection() const {
			return direction;
		}
		void setDirection(Direction dir) {
			direction = dir;
		}

		const std::string& getTitleText() const {
			return titleText;
		}
		const std::string& getTitleFont() const {
			return titleFont;
		}
		const std::string& getTitleColor() const {
			return titleColor;
		}
		void setTitle(std::string title, std::string font, std::string color) {
			this->titleText = std::move(title);
			this->titleFont = std::move(font);
			this->titleColor = std::move(color);
		}

		virtual uint32_t getZoneId() const {
			return 0;
		}

		virtual uint32_t getBestiaryId() const {
			return 0;
		}

		void setFlying(bool value) {
			this->flying = value;
		}

		const bool isFlying() const {
			return flying;
		}

		bool isHealthHidden() const {
			return hiddenHealth;
		}
		void setHiddenHealth(bool b) {
			hiddenHealth = b;
		}

		int32_t getThrowRange() const override final {
			return 1;
		}
		bool isPushable() const override {
			return getWalkDelay() <= 0;
		}
		bool isRemoved() const override final {
			return isInternalRemoved;
		}
		virtual bool canSeeInvisibility() const {
			return false;
		}
		virtual bool isInGhostMode() const {
			return false;
		}
		virtual bool isPet() const {
			return false;
		}

		int32_t getWalkDelay(Direction dir) const;
		int32_t getWalkDelay() const;
		int64_t getTimeSinceLastMove() const;

		int64_t getEventStepTicks() const;
		int64_t getStepDuration(Direction dir) const;
		int64_t getStepDuration(bool forAnimation = false) const;
		virtual int32_t getStepSpeed() const {
			return getSpeed();
		}
		int32_t getSpeed() const {
			return baseSpeed + varSpeed;
		}
		void setSpeed(int32_t varSpeedDelta) {
			int32_t oldSpeed = getSpeed();
			varSpeed = varSpeedDelta;
			
			#if GAME_FEATURE_NEWSPEED_LAW > 0
			cacheSpeed();
			#endif
			if (getSpeed() <= 0) {
				stopEventWalk();
				cancelNextWalk = true;
			} else if (oldSpeed <= 0 && !listWalkDir.empty()) {
				addEventWalk();
			}
		}

		#if GAME_FEATURE_NEWSPEED_LAW > 0
		void cacheSpeed() {
			int32_t stepSpeed = getStepSpeed();
			if (stepSpeed > -Creature::speedB) {
				cachedFormulatedSpeed = std::floor((Creature::speedA * std::log((stepSpeed / 2) + Creature::speedB) + Creature::speedC) + 0.5);
				if (cachedFormulatedSpeed == 0) {
					cachedFormulatedSpeed = 1;
				}
			} else {
				cachedFormulatedSpeed = 1;
			}
		}
		#endif

		void setBaseSpeed(uint32_t newBaseSpeed) {
			baseSpeed = newBaseSpeed;
		}
		uint32_t getBaseSpeed() const {
			return baseSpeed;
		}

		int64_t getHealth() const {
			return health;
		}
		virtual int64_t getMaxHealth() const {
			return healthMax;
		}

		virtual int64_t getRealMaxHealth() const {
			return healthMax;
		}

		int64_t getEnergyShield() const {
			return energyShield;
		}
		virtual int64_t getMaxEnergyShield() const {
			return energyShieldMax;
		}
		void setEnergyShield(int64_t newEnergyShield) {
			energyShield = newEnergyShield;
		}
		void setMaxEnergyShield(int64_t newEnergyShield) {
			energyShieldMax = newEnergyShield;
		}
		void setCanRegenerateShield(bool canRegen) {
			regenerateShield = canRegen;
		}
		bool canRegenerateShield() const {
			return regenerateShield;
		}

		void addEnergyShieldGain(uint32_t id, int32_t energyShieldGain, bool setup) {
			energyShieldGainMap[id] = energyShieldGain;
			if (setup) {
				setupRegenrations(2);
			}
		}
		int32_t getEnergyShieldGain(uint32_t id) {
			return energyShieldGainMap[id];
		}
		void removeEnergyShieldGain(uint32_t id, bool setup) {
			energyShieldGainMap.erase(id);
			if (setup) {
				setupRegenrations(2);
			}
		}

		bool isFullEnergyShield() const {
			return getEnergyShield() >= getMaxEnergyShield();
		}

		double getEnergyShieldRest() const {
			return energyShieldRest;
		}
		void setEnergyShieldRest(double rest) {
			energyShieldRest = rest;
		}
		double getEnergyShieldRestGain() const {
			return energyShieldRestGain;
		}
		void setEnergyShieldRestGain(double rest) {
			energyShieldRestGain = rest;
		}
		int32_t getEnergyShieldTotalGain() const {
			return energyShieldGain;
		}
		void setEnergyShieldGain(int32_t newEnergyShieldGain) {
			energyShieldGain = newEnergyShieldGain;
		}
		void setEnergyShieldGainTicks(uint32_t newEnergyShieldGainTicks) {
			energyShieldGainTicks = newEnergyShieldGainTicks;
		}
		uint32_t getEnergyShieldGainTicks() const {
			return energyShieldGainTicks;
		}

		void addEnergyShieldPrecentGain(uint32_t id, int32_t energyShieldGain, bool setup) {
			energyShieldGainPrecentMap[id] = energyShieldGain;
			if (setup) {
				setupRegenrations(2);
			}
		}
		int32_t getEnergyShieldPrecentGain(uint32_t id) {
			return energyShieldGainPrecentMap[id];
		}
		void removeEnergyShieldPrecentGain(uint32_t id, bool setup) {
			energyShieldGainPrecentMap.erase(id);
			if (setup) {
				setupRegenrations(2);
			}
		}

		void addEnergyShieldGainForce(uint32_t id, int32_t energyShieldGain, bool setup) {
			energyShieldGainMapForce[id] = energyShieldGain;
			if (setup) {
				setupRegenrations(4);
			}
		}

		int32_t getEnergyShieldGainForce(uint32_t id) {
			return energyShieldGainMapForce[id];
		}

		int32_t getEnergyShieldGainForceTotal() {
			int value = 0;
			for (auto& it : energyShieldGainMapForce) {
				value += it.second;
			}
			return value;
		}

		int32_t getEnergyShieldPrecentGainForceTotal() {
			int value = 0;
			for (auto& it : energyShieldGainPrecentMapForce) {
				value += it.second;
			}
			return value;
		}

		void removeEnergyShieldGainForce(uint32_t id, bool setup) {
			energyShieldGainMapForce.erase(id);
			if (setup) {
				setupRegenrations(4);
			}
		}

		void addEnergyShieldPrecentGainForce(uint32_t id, int32_t energyShieldGain, bool setup) {
			energyShieldGainPrecentMapForce[id] = energyShieldGain;
			if (setup) {
				setupRegenrations(4);
			}
		}

		int32_t getEnergyShieldPrecentGainForce(uint32_t id) {
			return energyShieldGainPrecentMapForce[id];
		}

		void removeEnergyShieldPrecentGainForce(uint32_t id, bool setup) {
			energyShieldGainPrecentMapForce.erase(id);
			if (setup) {
				setupRegenrations(4);
			}
		}

		double getEnergyShieldRestForce() const {
			return energyShieldRestForce;
		}
		void setEnergyShieldRestForce(double rest) {
			energyShieldRestForce = rest;
		}
		double getEnergyShieldRestGainForce() const {
			return energyShieldRestGainForce;
		}
		void setEnergyShieldRestGainForce(double rest) {
			energyShieldRestGainForce = rest;
		}
		int32_t getEnergyShieldTotalGainForce() const {
			return energyShieldGainForce;
		}
		void setEnergyShieldGainForce(int32_t newEnergyShieldGain) {
			energyShieldGainForce = newEnergyShieldGain;
		}
		void setEnergyShieldGainTicksForce(uint32_t newEnergyShieldGainTicks) {
			energyShieldGainTicksForce = newEnergyShieldGainTicks;
		}
		uint32_t getEnergyShieldGainTicksForce() const {
			return energyShieldGainTicksForce;
		}

		bool isFullHealth() const {
			return getHealth() >= getMaxHealth();
		}

		void setHealthRestGain(double rest) {
			healthRestGain = rest;
		}
		double getHealthRestGain() const {
			return healthRestGain;
		}
		void setHealthRest(double rest) {
			healthRest = rest;
		}
		double getHealthRest() const {
			return healthRest;
		}
		void addHealthGain(uint32_t id, int32_t healthGain, bool setup) {
			healthGainMap[id] = healthGain;
			if (setup) {
				setupRegenrations(1);
			}
		}
		void removeHealthGain(uint32_t id, bool setup) {
			healthGainMap.erase(id);
			if (setup) {
				setupRegenrations(1);
			}
		}
		int32_t getHealthGain(uint32_t id) {
			return healthGainMap[id];
		}

		int32_t getTotalHealthGain() {
			int32_t positiveHealthGain = 0;
			int32_t negativeHealthGain = 0;
			for (auto& it : healthGainMap) {
				if (it.second > 0) {
					positiveHealthGain += it.second;
				} else {
					negativeHealthGain += it.second;
				}
			}

			int32_t healthGainPrecent = 100;
			for (auto& it : healthGainPrecentMap) {
				healthGainPrecent += it.second;
			}

			double positiveResult = positiveHealthGain * ((double)healthGainPrecent / 100);
			double totalResult = positiveResult + negativeHealthGain;

			return std::ceil(totalResult);
		}

		int32_t getTotalPrecentHealthGain() {
			int totalHealthGain = 0;
			for (auto& it : healthGainPrecentMap) {
				totalHealthGain += it.second;
			}
			return totalHealthGain;
		}

		int32_t getTotalEnergyShieldGain() {
			int totalEnergyShieldGain = 0;
			for (auto& it : energyShieldGainMap) {
				totalEnergyShieldGain += it.second;
			}
			return totalEnergyShieldGain;
		}

		int32_t getTotalPrecentEnergyShieldGain() {
			int totalEnergyShieldGain = 0;
			for (auto& it : energyShieldGainPrecentMap) {
				totalEnergyShieldGain += it.second;
			}
			return totalEnergyShieldGain;
		}

		int32_t getHealthTotalGain() const {
			return healthGain;
		}
		void setHealthGain(int32_t newHealthGain) {
			healthGain = newHealthGain;
		}
		void setHealthGainTicks(uint32_t newHealthGainTicks) {
			healthGainTicks = newHealthGainTicks;
		}
		uint32_t getHealthGainTicks() const {
			return healthGainTicks;
		}

		bool canDrainHealth(int64_t drainHealth) const {
			return health >= std::abs(drainHealth);
		}

		void addHealthPrecentGain(uint32_t id, int32_t healthGain, bool setup) {
			healthGainPrecentMap[id] = healthGain;
			if (setup) {
				setupRegenrations(1);
			}
		}
		int32_t getHealthPrecentGain(uint32_t id) {
			return healthGainPrecentMap[id];
		}
		void removeHealthPrecentGain(uint32_t id, bool setup) {
			healthGainPrecentMap.erase(id);
			if (setup) {
				setupRegenrations(1);
			}
		}
		
		void setupRegenrations(uint8_t type);

		void setRegenEvent(uint64_t newRegenEvent) {
			esRegenEvent = newRegenEvent;
		}
		uint64_t getRegenEvent() const {
			return esRegenEvent;
		}

		const Outfit_t getCurrentOutfit() const {
			return currentOutfit;
		}
		void setCurrentOutfit(Outfit_t outfit) {
			currentOutfit = outfit;
		}
		const Outfit_t getDefaultOutfit() const {
			return defaultOutfit;
		}
		bool isInvisible() const;
		ZoneType_t getZone() const {
			return getTile()->getZone();
		}

		//walk functions
		void startAutoWalk();
		void startAutoWalk(Direction direction);
		void startAutoWalk(std::vector<Direction> listDir);
		void addEventWalk();
		void stopEventWalk();
		virtual void goToFollowCreature();

		//walk events
		virtual void onWalk(Direction& dir);
		virtual void onWalkAborted() {}
		virtual void onWalkComplete() {}

		//follow functions
		Creature* getFollowCreature() const {
			return followCreature;
		}
		virtual bool setFollowCreature(Creature* creature);

		//follow events
		virtual void onFollowCreature(const Creature*) {}
		virtual void onFollowCreatureComplete(const Creature*) {}

		//combat functions
		Creature* getAttackedCreature() {
			return attackedCreature;
		}
		virtual bool setAttackedCreature(Creature* creature);
		virtual BlockType_t blockHit(Creature* attacker, CombatType_t combatType, int64_t& damage,
		                             bool checkDefense = false, bool checkArmor = false, bool field = false);

		bool setMaster(Creature* newMaster);

		void removeMaster() {
			if (master) {
				master = nullptr;
				decrementReferenceCounter();
			}
		}

		bool isSummon() const {
			return master != nullptr;
		}
		Creature* getMaster() const {
			return master;
		}

		const std::vector<Creature*>& getSummons() const {
			return summons;
		}

		virtual int32_t getArmor() const {
			return 0;
		}
		virtual float getDefense() const {
			return 0;
		}
		virtual float getAttackFactor() const {
			return 1.0f;
		}
		virtual float getDefenseFactor() const {
			return 1.0f;
		}

		virtual uint8_t getSpeechBubble() const {
			return SPEECHBUBBLE_NONE;
		}

		bool addCondition(Condition* condition, bool force = false);
		bool addCombatCondition(Condition* condition);
		void removeCondition(ConditionType_t type, ConditionId_t conditionId, bool force = false);
		void removeCondition(ConditionType_t type, bool force = false);
		void removeCondition(Condition* condition, bool force = false);
		void removeCombatCondition(ConditionType_t type);
		Condition* getCondition(ConditionType_t type) const;
		Condition* getCondition(ConditionType_t type, ConditionId_t conditionId, uint32_t subId = 0) const;
		void executeConditions(uint32_t interval);
		bool hasCondition(ConditionType_t type, uint32_t subId = 0, bool anyId = false) const;
		virtual bool isImmune(ConditionType_t type) const;
		virtual bool isImmune(CombatType_t type) const;
		virtual bool isSuppress(ConditionType_t type) const;
		virtual uint32_t getDamageImmunities() const {
			return 0;
		}
		virtual uint32_t getConditionImmunities() const {
			return 0;
		}
		virtual uint32_t getConditionSuppressions() const {
			return 0;
		}
		virtual bool isAttackable() const {
			return true;
		}

		virtual void changeHealth(int64_t healthChange, bool sendHealthChange = true);
		virtual void changeEnergyShield(int64_t energyShieldChange, bool sendEnergyShieldChange = true);

		void gainHealth(Creature* healer, int64_t healthGain);
		virtual void drainHealth(Creature* attacker, int64_t damage);

		virtual bool challengeCreature(Creature*) {
			return false;
		}

		void onDeath();
		virtual uint64_t getGainedExperience(Creature* attacker) const;
		void addDamagePoints(Creature* attacker, int64_t damagePoints);
		bool hasBeenAttacked(uint32_t attackerId);

		//combat event functions
		virtual void onAddCondition(ConditionType_t type);
		virtual void onAddCombatCondition(ConditionType_t type);
		virtual void onEndCondition(ConditionType_t type);
		void onTickCondition(ConditionType_t type, bool& bRemove);
		virtual void onCombatRemoveCondition(Condition* condition);
		virtual void onAttackedCreature(Creature*) {}
		virtual void onAttacked();
		virtual void onAttackedCreatureDrainHealth(Creature* target, int64_t points);
		virtual void onTargetCreatureGainHealth(Creature*, int64_t) {}
		virtual bool onKilledCreature(Creature* target, bool lastHit = true);
		virtual void onGainExperience(uint64_t gainExp, Creature* target);
		virtual void onAttackedCreatureBlockHit(BlockType_t) {}
		virtual void onBlockHit() {}
		virtual void onChangeZone(ZoneType_t zone);
		virtual void onAttackedCreatureChangeZone(ZoneType_t zone);
		virtual void onIdleStatus();

		virtual LightInfo getCreatureLight() const;
		virtual void setNormalCreatureLight();
		void setCreatureLight(LightInfo lightInfo);

		virtual void onThink(uint32_t interval);
		void onAttacking(uint32_t interval);
		virtual void onWalk();
		virtual bool getNextStep(Direction& dir, uint32_t& flags);

		void onAddTileItem(const Tile* tile, const Position& pos);
		virtual void onUpdateTileItem(const Tile* tile, const Position& pos, const Item* oldItem,
		                              const ItemType& oldType, const Item* newItem, const ItemType& newType);
		virtual void onRemoveTileItem(const Tile* tile, const Position& pos, const ItemType& iType,
		                              const Item* item);

		virtual void onCreatureAppear(Creature* creature, bool isLogin);
		virtual void onRemoveCreature(Creature* creature, bool isLogout);
		virtual void onCreatureMove(Creature* creature, const Tile* newTile, const Position& newPos,
		                            const Tile* oldTile, const Position& oldPos, bool teleport);

		virtual void onAttackedCreatureDisappear(bool) {}
		virtual void onFollowCreatureDisappear(bool) {}

		virtual void onCreatureSay(Creature*, SpeakClasses, const std::string&) {}

		virtual void onPlacedCreature() {}

		virtual bool getCombatValues(int64_t&, int64_t&) {
			return false;
		}

		size_t getSummonCount() const {
			return summons.size();
		}
		void setDropLoot(bool lootDrop) {
			this->lootDrop = lootDrop;
		}
		void setSkillLoss(bool skillLoss) {
			this->skillLoss = skillLoss;
		}
		void setUseDefense(bool useDefense) {
			canUseDefense = useDefense;
		}

		//creature script events
		bool registerCreatureEvent(const std::string& name);
		bool unregisterCreatureEvent(const std::string& name);

		Cylinder* getParent() const override final {
			return tile;
		}
		void setParent(Cylinder* cylinder) override final {
			tile = static_cast<Tile*>(cylinder);
			position = tile->getPosition();
		}

		const Position& getPosition() const override final {
			return position;
		}

		Tile* getTile() override final {
			return tile;
		}
		const Tile* getTile() const override final {
			return tile;
		}

		int32_t getWalkCache(const Position& pos) const;

		const Position& getLastPosition() const {
			return lastPosition;
		}
		void setLastPosition(Position newLastPos) {
			lastPosition = newLastPos;
		}

		static bool canSee(const Position& myPos, const Position& pos, int32_t viewRangeX, int32_t viewRangeY);

		double getDamageRatio(Creature* attacker) const;

		bool getPathTo(const Position& targetPos, std::vector<Direction>& dirList, const FindPathParams& fpp) const;
		bool getPathTo(const Position& targetPos, std::vector<Direction>& dirList, int32_t minTargetDist, int32_t maxTargetDist, bool fullPathSearch = true, bool clearSight = true, int32_t maxSearchDist = 0) const;

		void incrementReferenceCounter() {
			++referenceCounter;
		}
		void decrementReferenceCounter() {
			if (--referenceCounter == 0) {
				delete this;
			}
		}
		
		uint32_t getReferenceCounter() const {
			return referenceCounter;
		}

		void setInPlace(bool value) {
			stayInPlace = value;
		}

		bool isInPlace() const {
			return stayInPlace;
		}

		std::vector<Direction>& getListWalkDir()
		{
			return listWalkDir;
		}

		const std::map<uint8_t, uint8_t>& getActiveAuras() const {
				return activeAuras;
		}

		void addActiveAura(uint8_t auraId, uint8_t auraLevel);
		void jump(uint16_t height, uint16_t duration);
		void setProgressBar(uint32_t duration, bool ltr);
		void removeActiveAura(uint8_t auraId);

		void addFear(Creature* attacker, uint32_t duration, uint32_t interval);
		bool hasFear() const
		{
			return feared;
		}
		void removeFear();
		void moveFeared();
		virtual bool isSpawnBlocking(Creature*) const {
			return false;
		}

		void clearTargetingPlayersList();
		void addTargetingPlayer(Creature* creature);
		void removeTargetingPlayer(Creature* creature);
		const CreatureList& getTargetingPlayers() const {
			return targetingPlayersList;
		}

	protected:
		virtual bool useCacheMap() const {
			return false;
		}

		struct CountBlock_t {
			int64_t total;
			int64_t ticks;
		};

		static constexpr int32_t mapWalkWidth = Map::maxViewportX * 2 + 1;
		static constexpr int32_t mapWalkHeight = Map::maxViewportY * 2 + 1;
		static constexpr int32_t maxWalkCacheWidth = (mapWalkWidth - 1) / 2;
		static constexpr int32_t maxWalkCacheHeight = (mapWalkHeight - 1) / 2;

		Position position;

		using CountMap = std::map<uint64_t, CountBlock_t>;
		CountMap damageMap;

		std::map<uint8_t, uint8_t> activeAuras;

		std::vector<Creature*> summons;
		CreatureEventList eventsList;
		ConditionList conditions;
		CreatureList targetingPlayersList;

		std::vector<Direction> listWalkDir;

		Tile* tile = nullptr;
		Creature* attackedCreature = nullptr;
		Creature* master = nullptr;
		Creature* followCreature = nullptr;
		Creature* fearedCreature = nullptr;
		uint32_t fearInterval = 0;
		int64_t fearEndtime = 0;
		uint64_t eventWalk = 0;

		uint64_t lastStep = 0;
		uint32_t referenceCounter = 0;
		uint32_t id = 0;
		uint32_t scriptEventsBitField = 0;
		#if GAME_FEATURE_NEWSPEED_LAW > 0
		uint32_t cachedFormulatedSpeed = 1;
		#endif
		uint32_t walkUpdateTicks = 0;
		uint32_t lastHitCreatureId = 0;
		uint32_t blockCount = 0;
		uint32_t blockTicks = 0;
		float lastStepCost = 1.0f;
		uint32_t baseSpeed = 220;
		int32_t varSpeed = 0;
		int32_t tempSpeed = 0;
		int64_t health = 1000;
		int64_t healthMax = 1000;
		int64_t energyShield = 0;
		int64_t energyShieldMax = 0;
		bool regenerateShield = true;


		double energyShieldRest = 0;
		double energyShieldRestGain = 0;
		int32_t energyShieldGain = 0;
		uint32_t energyShieldGainTicks = 1000;
		std::map<uint32_t, int32_t> energyShieldGainMap;
		std::map<uint32_t, int32_t> energyShieldGainPrecentMap;

		double energyShieldRestForce = 0;
		double energyShieldRestGainForce = 0;
		int32_t energyShieldGainForce = 0;
		uint32_t energyShieldGainTicksForce = 1000;
		std::map<uint32_t, int32_t> energyShieldGainMapForce;
		std::map<uint32_t, int32_t> energyShieldGainPrecentMapForce;

		double healthRest = 0;
		double healthRestGain = 0;
		int32_t healthGain = 0;
		uint32_t healthGainTicks = 1000;
		std::map<uint32_t, int32_t> healthGainMap;
		std::map<uint32_t, int32_t> healthGainPrecentMap;

		uint64_t esRegenEvent = 0;

		Outfit_t currentOutfit;
		Outfit_t defaultOutfit;
		std::string titleText;
		std::string titleFont;
		std::string titleColor;

		uint32_t zoneId = 0;
		uint32_t bestiaryId = 0;
		bool flying = false;

		Position lastPosition;
		LightInfo internalLight;

		Direction direction = DIRECTION_SOUTH;
		Skulls_t skull = SKULL_NONE;
		int32_t level = 0;

		bool localMapCache[mapWalkHeight][mapWalkWidth] = {{ false }};
		bool isInternalRemoved = false;
		bool isMapLoaded = false;
		bool isUpdatingPath = false;
		bool creatureCheck = false;
		bool inCheckCreaturesVector = false;
		bool skillLoss = true;
		bool lootDrop = true;
		bool cancelNextWalk = false;
		bool hasFollowPath = false;
		bool forceUpdateFollowPath = false;
		bool hiddenHealth = false;
		bool canUseDefense = true;
		bool stayInPlace = false;
		bool feared = false;

		//creature script events
		bool hasEventRegistered(CreatureEventType_t event) const {
			return (0 != (scriptEventsBitField & (static_cast<uint32_t>(1) << event)));
		}
		void resetEventsRegistered() {
			scriptEventsBitField = 0;
		}
		CreatureEventList getCreatureEvents(CreatureEventType_t type);
		CreatureEventList& getCreatureEvents() {
			return eventsList;
		}

		void updateMapCache();
		void updateTileCache(const Tile* tile, int32_t dx, int32_t dy);
		void updateTileCache(const Tile* tile, const Position& pos);
		void onCreatureDisappear(const Creature* creature, bool isLogout);
		virtual void doAttacking(uint32_t) {}
		virtual bool hasExtraSwing() {
			return false;
		}

		virtual uint64_t getLostExperience() const {
			return 0;
		}
		virtual void dropLoot(Container*, Creature*) {}
		virtual uint16_t getLookCorpse() const {
			return 0;
		}
		virtual void getPathSearchParams(const Creature* creature, FindPathParams& fpp) const;
		virtual void death(Creature*) {}
		virtual bool dropCorpse(Creature* lastHitCreature, Creature* mostDamageCreature, bool lastHitUnjustified, bool mostDamageUnjustified);
		virtual Item* getCorpse(Creature* lastHitCreature, Creature* mostDamageCreature);

		friend class Game;
		friend class Map;
		friend class LuaScriptInterface;
};

#endif