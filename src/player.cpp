/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2020 Mark Samman <mark.samman@gmail.com>
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

#include <bitset>

#include "bed.h"
#include "chat.h"
#include "combat.h"
#include "configmanager.h"
#include "creatureevent.h"
#include "events.h"
#include "game.h"
#include "iologindata.h"
#include "monster.h"
#include "movement.h"
#include "weapons.h"

extern ConfigManager g_config;
extern Game g_game;
extern Chat* g_chat;
extern Vocations g_vocations;
extern MoveEvents* g_moveEvents;
extern Weapons* g_weapons;
extern CreatureEvents* g_creatureEvents;
extern Events* g_events;

MuteCountMap Player::muteCountMap;

uint32_t Player::playerAutoID = 0x10000000;

Player::Player(ProtocolGame_ptr p) :
	Creature(), 
	lastPing(OTSYS_TIME()), 
	lastPong(lastPing), 
	inbox(new Inbox(ITEM_INBOX)), 
	tempStorage(new TempStorage(ITEM_TEMP_STORAGE)),
	tradeStorage(new TradeStorage(ITEM_TRADE_STORAGE)),
	client(std::move(p))
{
	tempStorage->setParent(this);
	tradeStorage->setParent(this);
}

Player::~Player()
{
	// Clean up any stored conditions that weren't applied
	for (Condition* condition : storedConditionList) {
		if (condition) {
			delete condition;
		}
	}
	storedConditionList.clear();

	for (size_t i = 0; i < sizeof(inventory) / sizeof(inventory[0]); ++i) {
		Item* item = inventory[i];
		if (item) {
			if (item->getIsRealItem() && item->getRealUID() > 0) {
				g_game.removeRealUniqueItem(item->getRealUID());
			}
			item->setParent(nullptr);
			
			if (item->getReferenceCounter() > 0) {
				// Always release once - if async save has ref, item stays alive until it releases too
				g_game.ReleaseItem(item);
			} else {
				delete item;
			}
			inventory[i] = nullptr;
		}
	}

	for (const auto& it : depotChests) {
		if (!it.second->getRealParent()) {
			if (it.second->getReferenceCounter() > 0) {
				g_game.ReleaseItem(it.second);
			} else {
				delete it.second;
			}
		}
	}
	depotChests.clear();

	for (const auto& it : depotLockerMap) {
		it.second->removeInbox(inbox);
		
		if (it.second->getReferenceCounter() > 0) {
			g_game.ReleaseItem(it.second);
		} else {
			delete it.second;
		}
	}
	depotLockerMap.clear();

	if (inbox->getReferenceCounter() > 0) {
		// Don't call stopDecaying() - inbox items are handled by async save thread
		g_game.ReleaseItem(inbox);
	} else {
		delete inbox;
	}

	tempStorage->setParent(nullptr);
	g_game.ReleaseItem(tempStorage);
	
	tradeStorage->setParent(nullptr);
	g_game.ReleaseItem(tradeStorage);

	setWriteItem(nullptr);
	setEditHouse(nullptr);
}

bool Player::setVocation(uint16_t vocId, bool internal /*=false*/)
{
	Vocation* voc = g_vocations.getVocation(vocId);
	if (!voc) {
		return false;
	}
	vocation = voc;

	Condition* condition = getCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT);
	if (condition) {
		condition->setParam(CONDITION_PARAM_HEALTHGAIN, vocation->getHealthGainAmount());
		condition->setParam(CONDITION_PARAM_HEALTHTICKS, vocation->getHealthGainTicks() * 1000);
		condition->setParam(CONDITION_PARAM_MANAGAIN, vocation->getManaGainAmount());
		condition->setParam(CONDITION_PARAM_MANATICKS, vocation->getManaGainTicks() * 1000);
	}
	if (!internal) {
		#if CLIENT_VERSION >= 950
		sendBasicData();
		#endif
	}
	return true;
}

bool Player::isPushable() const
{
	if (hasFlag(PlayerFlag_CannotBePushed)) {
		return false;
	}
	return Creature::isPushable();
}

std::string Player::getDescription(int32_t lookDistance) const
{
	std::stringExtended sink(512);

	if (lookDistance == -1) {
		sink << "yourself.";

		if (group->access) {
			sink << " You are " << group->name << '.';
		} else if (vocation->getId() != VOCATION_NONE) {
			sink << " You are " << vocation->getVocDescription() << '.';
		} else {
			sink << " You have no vocation.";
		}
	} else {
		sink << name;
		if (!group->access) {
			sink << " (Level " << level << ')';
		}
		sink << '.';

		if (sex == PLAYERSEX_FEMALE) {
			sink << " She";
		} else {
			sink << " He";
		}

		if (group->access) {
			sink << " is " << group->name << '.';
		} else if (vocation->getId() != VOCATION_NONE) {
			sink << " is " << vocation->getVocDescription() << '.';
		} else {
			sink << " has no vocation.";
		}
	}

	if (party) {
		if (lookDistance == -1) {
			sink << " Your party has ";
		} else if (sex == PLAYERSEX_FEMALE) {
			sink << " She is in a party with ";
		} else {
			sink << " He is in a party with ";
		}

		size_t memberCount = party->getMemberCount() + 1;
		if (memberCount == 1) {
			sink << "1 member and ";
		} else {
			sink << memberCount << " members and ";
		}

		size_t invitationCount = party->getInvitationCount();
		if (invitationCount == 1) {
			sink << "1 pending invitation.";
		} else {
			sink << invitationCount << " pending invitations.";
		}
	}

	if (!guild || !guildRank) {
		return sink;
	}

	if (lookDistance == -1) {
		sink << " You are ";
	} else if (sex == PLAYERSEX_FEMALE) {
		sink << " She is ";
	} else {
		sink << " He is ";
	}

	sink << guildRank->name << " of the " << guild->getName();
	if (!guildNick.empty()) {
		sink << " (" << guildNick << ')';
	}

	size_t memberCount = guild->getMemberCount();
	if (memberCount == 1) {
		sink << ", which has 1 member, " << guild->getMembersOnline().size() << " of them online.";
	} else {
		sink << ", which has " << memberCount << " members, " << guild->getMembersOnline().size() << " of them online.";
	}
	return sink;
}

Item* Player::getInventoryItem(slots_t slot) const
{
	if (slot < CONST_SLOT_FIRST || slot > CONST_SLOT_LAST) {
		return nullptr;
	}
	return inventory[slot];
}

void Player::addConditionSuppressions(uint32_t conditions)
{
	conditionSuppressions |= conditions;
}

void Player::removeConditionSuppressions(uint32_t conditions)
{
	conditionSuppressions &= ~conditions;
}

Item* Player::getWeapon(slots_t slot, bool ignoreAmmo) const
{
	Item* item = inventory[slot];
	if (!item) {
		return nullptr;
	}

	WeaponType_t weaponType = item->getWeaponType();
	if (weaponType == WEAPON_NONE || weaponType == WEAPON_SHIELD || weaponType == WEAPON_AMMO) {
		return nullptr;
	}
	return item;
}

Item* Player::getWeapon(bool ignoreAmmo/* = false*/) const
{
	Item* item = getWeapon(CONST_SLOT_LEFT, ignoreAmmo);
	if (item) {
		return item;
	}

	item = getWeapon(CONST_SLOT_RIGHT, ignoreAmmo);
	if (item) {
		return item;
	}
	return nullptr;
}

WeaponType_t Player::getWeaponType() const
{
	Item* item = getWeapon();
	if (!item) {
		return WEAPON_NONE;
	}
	return item->getWeaponType();
}

int32_t Player::getWeaponSkill(const Item* item) const
{
	if (!item) {
		return getSkillLevel(SKILL_FIST);
	}

	int32_t attackSkill;

	WeaponType_t weaponType = item->getWeaponType();
	switch (weaponType) {
		case WEAPON_SWORD: {
			attackSkill = getSkillLevel(SKILL_MELEE);
			break;
		}

		case WEAPON_CLUB: {
			attackSkill = getSkillLevel(SKILL_MELEE);
			break;
		}

		case WEAPON_AXE: {
			attackSkill = getSkillLevel(SKILL_MELEE);
			break;
		}
		
		case WEAPON_WAND: {
	//		attackSkill = getMagicLevel();
			attackSkill = getSkillLevel(SKILL_FISHING);
			break;
		}

		case WEAPON_DISTANCE: case WEAPON_AMMO: {
			attackSkill = getSkillLevel(SKILL_DISTANCE);
			break;
		}

		default: {
			attackSkill = 0;
			break;
		}
	}
	return attackSkill;
}

int32_t Player::getArmor() const
{
	int32_t armor = 0;

	static const slots_t armorSlots[] = {CONST_SLOT_HEAD, CONST_SLOT_NECKLACE, CONST_SLOT_ARMOR, CONST_SLOT_LEGS, CONST_SLOT_FEET, CONST_SLOT_RING, CONST_SLOT_GLOVES, CONST_SLOT_RING2, CONST_SLOT_SPELL1, CONST_SLOT_SPELL2, CONST_SLOT_SPELL3, CONST_SLOT_SPELL4, CONST_SLOT_POTION1, CONST_SLOT_POTION2};
	for (slots_t slot : armorSlots) {
		Item* inventoryItem = inventory[slot];
		if (inventoryItem) {
			armor += inventoryItem->getArmor();
		}
	}
	return static_cast<int32_t>(armor * vocation->armorMultiplier);
}

void Player::getShieldAndWeapon(const Item*& shield, const Item*& weapon) const
{
	shield = nullptr;
	weapon = nullptr;

	for (uint32_t slot = CONST_SLOT_RIGHT; slot <= CONST_SLOT_LEFT; slot++) {
		Item* item = inventory[slot];
		if (!item) {
			continue;
		}

		switch (item->getWeaponType()) {
			case WEAPON_NONE:
				break;

			case WEAPON_SHIELD: {
				if (!shield || item->getDefense() > shield->getDefense()) {
					shield = item;
				}
				break;
			}

			default: { // weapons that are not shields
				weapon = item;
				break;
			}
		}
	}
}

float Player::getDefense() const
{    
    const Item* weapon;
    const Item* shield;
    getShieldAndWeapon(shield, weapon);

    float endValues = 0.0f;

    if (shield) {
        uint32_t defenseValue = shield->getDefense();
        endValues = (getSkillLevel(SKILL_SHIELD) + defenseValue) * vocation->defenseMultiplier;
    }

    return endValues;
}


float Player::getAttackFactor() const
{
	switch (fightMode) {
		case FIGHTMODE_ATTACK: return 1.0f;
		case FIGHTMODE_BALANCED: return 1.0f;
		case FIGHTMODE_DEFENSE: return 1.0f;
		//case FIGHTMODE_BALANCED: return 1.2f;
		//case FIGHTMODE_DEFENSE: return 2.0f;
		default: return 1.0f;
	}
}

float Player::getDefenseFactor() const
{
	switch (fightMode) {
		case FIGHTMODE_ATTACK: return (OTSYS_TIME() - lastAttack) < getAttackSpeed() ? 0.5f : 1.0f;
		case FIGHTMODE_BALANCED: return (OTSYS_TIME() - lastAttack) < getAttackSpeed() ? 0.75f : 1.0f;
		case FIGHTMODE_DEFENSE: return 1.0f;
	//	case FIGHTMODE_ATTACK: return (OTSYS_TIME() - lastAttack) < getAttackSpeed() ? 0.5f : 1.0f;
	//	case FIGHTMODE_BALANCED: return (OTSYS_TIME() - lastAttack) < getAttackSpeed() ? 0.75f : 1.0f;
	//	case FIGHTMODE_DEFENSE: return 1.0f;
		default: return 1.0f;
	}
}

uint32_t Player::getClientIcons() const
{
	uint32_t icons = 0;
	for (Condition* condition : conditions) {
		if (condition->getType() != CONDITION_NONE && !isSuppress(condition->getType())) {
			icons |= condition->getIcons();
		}
	}

	if (pzLocked) {
		icons |= ICON_REDSWORDS;
	}

	if (tile->hasFlag(TILESTATE_PROTECTIONZONE)) {
		icons |= ICON_PIGEON;

		// Don't show ICON_SWORDS if player is in protection zone.
		if (hasBitSet(ICON_SWORDS, icons)) {
			icons &= ~ICON_SWORDS;
		}
	}

	// Game client debugs with 10 or more icons
	// so let's prevent that from happening.
	std::bitset<32> icon_bitset(static_cast<uint64_t>(icons));
	for (size_t pos = 0, bits_set = icon_bitset.count(); bits_set >= 10; ++pos) {
		if (icon_bitset[pos]) {
			icon_bitset.reset(pos);
			--bits_set;
		}
	}
	return static_cast<uint32_t>(icon_bitset.to_ulong());
}

void Player::updateInventoryWeight()
{
	return;
}

void Player::addSkillAdvance(skills_t skill, uint64_t count)
{
	uint64_t currReqTries = vocation->getReqSkillTries(skill, skills[skill].level);
	uint64_t nextReqTries = vocation->getReqSkillTries(skill, skills[skill].level + 1);
	if (currReqTries >= nextReqTries) {
		//player has reached max skill
		return;
	}

	g_events->eventPlayerOnGainSkillTries(this, skill, count);
	if (count == 0) {
		return;
	}

	bool sendUpdateSkills = false;
	while ((skills[skill].tries + count) >= nextReqTries) {
		count -= nextReqTries - skills[skill].tries;
		skills[skill].level++;
		skills[skill].tries = 0;
		skills[skill].percent = 0;

		std::stringExtended ss(128);
		ss << "You advanced to " << getSkillName(skill) << " level " << skills[skill].level << '.';
		sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);

		g_creatureEvents->playerAdvance(this, skill, (skills[skill].level - 1), skills[skill].level);

		sendUpdateSkills = true;
		currReqTries = nextReqTries;
		nextReqTries = vocation->getReqSkillTries(skill, skills[skill].level + 1);
		if (currReqTries >= nextReqTries) {
			count = 0;
			break;
		}
	}

	skills[skill].tries += count;

	#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
	uint16_t newPercent;
	#else
	uint8_t newPercent;
	#endif
	if (nextReqTries > currReqTries) {
		newPercent = Player::getPercentSkillLevel(skills[skill].tries, nextReqTries);
	} else {
		newPercent = 0;
	}

	if (skills[skill].percent != newPercent) {
		skills[skill].percent = newPercent;
		sendUpdateSkills = true;
	}
}

int64_t Player::getMaxEnergyShield() const {
    return static_cast<int64_t>(
        (energyShieldMax + varStats[STAT_MAXENERGYSHIELD] + (getSkillLevel(SKILL_SHIELD) * 5) ) * getPrecentEnergyShieldMultiplier() // (getSkillLevel(SKILL_FISHING) * 3) +
    );
}

double Player::getPrecentEnergyShieldMultiplier() const {
	return 1.0 + ((double)varStats[STAT_MAXENERGYSHIELDPERCENT] + (getSkillLevel(SKILL_FISHING) * 0.25)) / 100.0; // + getSkillLevel(SKILL_FISHING) Inteligence 0.25% ES
}

int64_t Player::getRealMaxHealth() const {

    return static_cast<int64_t>(
        (healthMax + varStats[STAT_MAXHITPOINTS] + (getSkillLevel(SKILL_SHIELD) * 5)) * getPrecentHealthMultiplier() // (getSkillLevel(SKILL_MELEE) * 2)
    );
}

double Player::getPrecentHealthMultiplier() const {
	return 1.0 + ((double)varStats[STAT_MAXHITPOINTSPERCENT] + (getSkillLevel(SKILL_MELEE) * 0.25)) / 100.0; // Strengdt 0.25%
}

int64_t Player::getMaxHealth() const {
	if (limitMaxHealth > 0) {
		return static_cast<int64_t>(limitMaxHealth);
	}

	int64_t totalHealth = getRealMaxHealth();
    return static_cast<int64_t>(totalHealth * healthReservationTotal);
}

int64_t Player::getRealMaxMana() const {
    return static_cast<int64_t>(
        (manaMax + varStats[STAT_MAXMANAPOINTS] + (getSkillLevel(SKILL_SHIELD) * 2)) * getPrecentManaMultiplier()
    );
}

double Player::getPrecentManaMultiplier() const {
	return 1.0 + ((double)varStats[STAT_MAXMANAPOINTSPERCENT]) / 100.0;
}

int64_t Player::getMaxMana() const {
	int64_t totalMana = getRealMaxMana();
	return static_cast<int64_t>(totalMana * manaReservationTotal);
}

//uint32_t Player::getAttackSpeed() const {
//    uint32_t baseAttackSpeed = vocation->getAttackSpeed();

//    double adjustedAttackSpeed = static_cast<double>(baseAttackSpeed) * (1.0 - varStats[STAT_ATTACKSPEED] / 100.0);
//    double maxPercent = 0.80 + (varStats[STAT_MAXATTACKSPEED] * 0.01);
//	if (maxPercent > 0.95) {
//        maxPercent = 0.95;
//    }

//    double minAttackSpeedMs = baseAttackSpeed * (1.0 - maxPercent);
//    if (adjustedAttackSpeed < minAttackSpeedMs) {
//        adjustedAttackSpeed = minAttackSpeedMs;
//    }

//    return static_cast<uint32_t>(adjustedAttackSpeed);
//}

uint32_t Player::getAttackSpeed() const {
    uint32_t baseMs = vocation ? vocation->getAttackSpeed() : 1500;
    if (baseMs == 0) {
        baseMs = 1500;
    }
    double baseAPS = 1000.0 / static_cast<double>(baseMs);
    const double maxAPS  = 2.5;

    double bonus = static_cast<double>(varStats[STAT_ATTACKSPEED]);

    // Wzór LoL: APS = Base * (1 + bonus / 100)
    double aps = baseAPS * (1.0 + (bonus / 100.0));

    // HARD CAP
    if (aps > maxAPS) {
        aps = maxAPS;
    }

    // zamiana APS -> ms
    double attackSpeedMs = 1000.0 / aps;

    return static_cast<uint32_t>(attackSpeedMs + 0.5);
}

void Player::setVarStats(stats_t stat, int32_t modifier)
{
	varStats[stat] += modifier;

	switch (stat) {
		case STAT_MAXHITPOINTS: 
		case STAT_MAXHITPOINTSPERCENT:
		{
			if (getHealth() > getMaxHealth()) {
				Creature::changeHealth(getMaxHealth() - getHealth());
			} else {
				g_game.addCreatureHealth(this);
			}
			break;
		}

		case STAT_MAXMANAPOINTS: 
		case STAT_MAXMANAPOINTSPERCENT:
		{
			int64_t mana = static_cast<int64_t>(getMana());
			if (mana > getMaxMana()) {
				changeMana(getMaxMana() - mana);
			}
			#if GAME_FEATURE_PARTY_LIST > 0
			else {
				g_game.addPlayerMana(this);
			}
			#endif
			break;
		}

		case STAT_MAXENERGYSHIELD: 
		case STAT_MAXENERGYSHIELDPERCENT:
		{
			if (getEnergyShield() > getMaxEnergyShield()) {
				changeEnergyShield(getMaxEnergyShield() - getEnergyShield());
			} else {
				g_game.addCreatureHealth(this);
			}
			break;
		}

		default: {
			break;
		}
	}
}

int32_t Player::getDefaultStats(stats_t stat) const
{
	switch (stat) {
		case STAT_MAXHITPOINTS: return healthMax;
		case STAT_MAXMANAPOINTS: return manaMax;
		case STAT_MAGICPOINTS: return getBaseMagicLevel();
		default: return 0;
	}
}

void Player::addContainer(uint8_t cid, Container* container)
{
	if (cid > 0xF) {
		return;
	}

	#if GAME_FEATURE_BROWSEFIELD > 0
	if (container->getID() == ITEM_BROWSEFIELD) {
		container->incrementReferenceCounter();
	}
	#endif

	auto it = openContainers.find(cid);
	if (it != openContainers.end()) {
		OpenContainer& openContainer = it->second;
		#if GAME_FEATURE_BROWSEFIELD > 0
		Container* oldContainer = openContainer.container;
		if (oldContainer->getID() == ITEM_BROWSEFIELD) {
			oldContainer->decrementReferenceCounter();
		}
		#endif

		openContainer.container = container;
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		openContainer.index = 0;
		#endif
	} else {
		OpenContainer openContainer;
		openContainer.container = container;
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		openContainer.index = 0;
		#endif
		container->setAutoOpen(cid);
		openContainers[cid] = openContainer;
	}
}

void Player::closeContainer(uint8_t cid)
{
	auto it = openContainers.find(cid);
	if (it == openContainers.end()) {
		return;
	}

	
	#if GAME_FEATURE_BROWSEFIELD > 0
	OpenContainer openContainer = it->second;
	Container* container = openContainer.container;
	container->resetAutoOpen();
	#endif
	openContainers.erase(it); 

	#if GAME_FEATURE_BROWSEFIELD > 0
	if (container && container->getID() == ITEM_BROWSEFIELD) {
		container->decrementReferenceCounter();
	}
	#endif
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void Player::setContainerIndex(uint8_t cid, uint16_t index)
{
	auto it = openContainers.find(cid);
	if (it == openContainers.end()) {
		return;
	}
	it->second.index = index;
}
#endif

Container* Player::getContainerByID(uint8_t cid)
{
	auto it = openContainers.find(cid);
	if (it == openContainers.end()) {
		return nullptr;
	}
	return it->second.container;
}

int8_t Player::getContainerID(const Container* container) const
{
	for (const auto& it : openContainers) {
		if (it.second.container == container) {
			return it.first;
		}
	}
	return -1;
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
uint16_t Player::getContainerIndex(uint8_t cid) const
{
	auto it = openContainers.find(cid);
	if (it == openContainers.end()) {
		return 0;
	}
	return it->second.index;
}
#endif

bool Player::canOpenCorpse(uint32_t ownerId) const
{
	return getID() == ownerId || (party && party->canOpenCorpse(ownerId));
}

uint16_t Player::getLookCorpse() const
{
	if (sex == PLAYERSEX_FEMALE) {
		return ITEM_FEMALE_CORPSE;
	} else {
		return ITEM_MALE_CORPSE;
	}
}

void Player::addStorageValue(const uint32_t key, const int32_t value, const bool isLogin/* = false*/)
{
	if (value != -1) {
		int32_t oldValue;
		getStorageValue(key, oldValue);

		storageMap[key] = value;

		if (!isLogin) {
			auto currentFrameTime = g_dispatcher.getDispatcherCycle();
			if (lastQuestlogUpdate != currentFrameTime && g_game.quests.isQuestStorage(key, value, oldValue)) {
				lastQuestlogUpdate = currentFrameTime;
				sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your questlog has been updated.");
			}
			#if GAME_FEATURE_QUEST_TRACKER > 0
			if (!trackedQuests.empty()) {
				auto missions = g_game.quests.getMissions(key);
				for (auto mission : missions) {
					if (hasTrackingQuest(mission->getMissionId())) {
						sendUpdateTrackedQuest(mission);
					}
				}
			}
			#endif
		}
	} else {
		storageMap.erase(key);
	}
}

bool Player::getStorageValue(const uint32_t key, int32_t& value) const
{
	auto it = storageMap.find(key);
	if (it == storageMap.end()) {
		value = -1;
		return false;
	}

	value = it->second;
	return true;
}

#if GAME_FEATURE_QUEST_TRACKER > 0
size_t Player::getAllowedTrackedQuestCount() const
{
	if (isPremium()) {
		return g_config.getNumber(ConfigManager::MAX_TRACKED_QUESTS_PREMIUM);
	}
	return g_config.getNumber(ConfigManager::MAX_TRACKED_QUESTS);
}

bool Player::hasTrackingQuest(uint16_t missionId) const
{
	return std::find(trackedQuests.begin(), trackedQuests.end(), missionId) != trackedQuests.end();
}

void Player::resetTrackedQuests(std::vector<uint16_t>& quests)
{
	size_t maxAllowed = getAllowedTrackedQuestCount();
	trackedQuests.clear();
	for (size_t i = 0, end = quests.size(); i < end; ++i) {
		const Mission* mission = g_game.quests.getMissionByID(quests[i]);
		if (mission && mission->isStarted(this)) {
			trackedQuests.emplace_back(quests[i]);
			if (trackedQuests.size() >= maxAllowed) {
				break;
			}
		}
	}
	sendTrackedQuests(static_cast<uint8_t>(maxAllowed - trackedQuests.size()), trackedQuests);
}
#endif

bool Player::canSee(const Position& pos) const
{
	if (!client) {
		return false;
	}
	return client->canSee(pos);
}

bool Player::canSeeCreature(const Creature* creature) const
{
	if (!creature) {
		return false;
	}

	if (creature == this) {
		return true;
	}

	if (creature->isInGhostMode() && (!group || !group->access)) {
		return false;
	}

	if (!creature->getPlayer() && !canSeeInvisibility() && creature->isInvisible()) {
		return false;
	}
	return true;
}

bool Player::canWalkthrough(const Creature* creature) const
{
	if (group->access || creature->isInGhostMode()) {
		return true;
	}

	const Player* player = creature->getPlayer();
	const Monster* monster = creature->getMonster();
	const Npc* npc = creature->getNpc();
	if (monster) {
		if (!monster->isPet()) {
			return false;
		}
		return true;
	}

	if (player) {
		const Tile* playerTile = player->getTile();
		if (!playerTile || (!playerTile->hasFlag(TILESTATE_NOPVPZONE) && !playerTile->hasFlag(TILESTATE_PROTECTIONZONE) && player->getLevel() > static_cast<uint32_t>(g_config.getNumber(ConfigManager::PROTECTION_LEVEL)) && g_game.getWorldType() != WORLD_TYPE_NO_PVP)) {
			return false;
		}

		const Item* playerTileGround = playerTile->getGround();
		if (!playerTileGround || !playerTileGround->hasWalkStack()) {
			return false;
		}

		// Allow immediate walkthrough in protection zones and no-pvp zones
		if (playerTile->hasFlag(TILESTATE_PROTECTIONZONE) || playerTile->hasFlag(TILESTATE_NOPVPZONE)) {
			return true;
		}

		Player* thisPlayer = const_cast<Player*>(this);
		if ((OTSYS_TIME() - lastWalkthroughAttempt) > 2000) {
			thisPlayer->setLastWalkthroughAttempt(OTSYS_TIME());
			return false;
		}

		if (creature->getPosition() != lastWalkthroughPosition) {
			thisPlayer->setLastWalkthroughPosition(creature->getPosition());
			return false;
		}

		thisPlayer->setLastWalkthroughPosition(creature->getPosition());
		return true;
	} else if (npc) {
		const Tile* tile = npc->getTile();
		const HouseTile* houseTile = dynamic_cast<const HouseTile*>(tile);
		return (houseTile != nullptr);
	}

	return false;
}

bool Player::canWalkthroughEx(const Creature* creature) const
{
	if (group->access) {
		return true;
	}

	const Monster* monster = creature->getMonster();
	if (monster) {
		if (!monster->isPet()) {
			return false;
		}
		return true;
	}

	const Player* player = creature->getPlayer();
	const Npc* npc = creature->getNpc();
	if (player) {
		const Tile* playerTile = player->getTile();
		return playerTile && (playerTile->hasFlag(TILESTATE_NOPVPZONE) || playerTile->hasFlag(TILESTATE_PROTECTIONZONE) || player->getLevel() <= static_cast<uint32_t>(g_config.getNumber(ConfigManager::PROTECTION_LEVEL)) || g_game.getWorldType() == WORLD_TYPE_NO_PVP);
	} else if (npc) {
		const Tile* tile = npc->getTile();
		const HouseTile* houseTile = dynamic_cast<const HouseTile*>(tile);
		return (houseTile != nullptr);
	} else {
		return false;
	}

}

void Player::onReceiveMail() const
{
	if (isNearDepotBox()) {
		sendTextMessage(MESSAGE_EVENT_ADVANCE, "New mail has arrived.");
	}
}

bool Player::isNearDepotBox() const
{
	const Position& pos = getPosition();
	for (int32_t cx = -1; cx <= 1; ++cx) {
		for (int32_t cy = -1; cy <= 1; ++cy) {
			Tile* tile = g_game.map.getTile(pos.x + cx, pos.y + cy, pos.z);
			if (!tile) {
				continue;
			}

			if (tile->hasFlag(TILESTATE_DEPOT)) {
				return true;
			}
		}
	}
	return false;
}

DepotChest* Player::getDepotChest(uint32_t depotId, bool autoCreate)
{
	auto it = depotChests.find(depotId);
	if (it != depotChests.end()) {
		return it->second;
	}

	if (!autoCreate) {
		return nullptr;
	}

	DepotChest* depotChest = new DepotChest(ITEM_DEPOT);
	depotChest->incrementReferenceCounter();
	depotChest->setMaxDepotItems(getMaxDepotItems());
	depotChests[depotId] = depotChest;
	return depotChest;
}

DepotLocker* Player::getDepotLocker(uint32_t depotId)
{
	auto it = depotLockerMap.find(depotId);
	if (it != depotLockerMap.end()) {
		inbox->setParent(it->second);
		return it->second;
	}

	DepotLocker* depotLocker = new DepotLocker(ITEM_LOCKER1);
	depotLocker->incrementReferenceCounter();
	depotLocker->setDepotId(depotId);
	depotLocker->internalAddThing(Item::CreateItem(ITEM_MARKET));
	depotLocker->internalAddThing(inbox);
	depotLocker->internalAddThing(getDepotChest(depotId, true));
	depotLockerMap[depotId] = depotLocker;
	return depotLocker;
}

void Player::sendCancelMessage(ReturnValue message) const
{
	if (message == RETURNVALUE_EMPTY)
		return;

	sendCancelMessage(getReturnMessage(message));
}

void Player::sendStats(uint8_t type)
{
	if (client) {
		client->sendStats(type);
	}
}

void Player::sendPing()
{
	int64_t timeNow = OTSYS_TIME();

	bool hasLostConnection = false;
	if ((timeNow - lastPing) >= 5000) {
		lastPing = timeNow;
		if (client) {
			client->sendPing();
		} else {
			hasLostConnection = true;
		}
	}

	int64_t noPongTime = timeNow - lastPong;
	if ((hasLostConnection || noPongTime >= 7000) && attackedCreature && attackedCreature->getPlayer()) {
		setAttackedCreature(nullptr);
	}

	if (noPongTime >= 60000 && canLogout()) {
		if (g_creatureEvents->playerLogout(this)) {
			addInfoLog("[SERVER] Kicked by auto kick.");
			if (client) {
				client->logout(true, true);
			} else {
				g_game.removeCreature(this, true);
			}
		}
	}
}

void Player::autoOpenContainers()
{
	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; i++) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		if (Container* container = item->getContainer()) {
			if (container->getAutoOpen() >= 0) {
				addContainer(container->getAutoOpen(), container);
				onSendContainer(container);
			}
			for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
				if (Container* subContainer = (*it)->getContainer()) {
					if (subContainer->getAutoOpen() >= 0) {
						addContainer(subContainer->getAutoOpen(), subContainer);
						onSendContainer(subContainer);
					}
				}
			}
		}
	}
}

Item* Player::getWriteItem(uint32_t& windowTextId, uint16_t& maxWriteLen)
{
	windowTextId = this->windowTextId;
	maxWriteLen = this->maxWriteLen;
	return writeItem;
}

void Player::setWriteItem(Item* item, uint16_t maxWriteLen /*= 0*/)
{
	windowTextId++;
	if (writeItem) {
		writeItem->decrementReferenceCounter();
	}

	if (item) {
		writeItem = item;
		this->maxWriteLen = maxWriteLen;
		writeItem->incrementReferenceCounter();
	} else {
		writeItem = nullptr;
		this->maxWriteLen = 0;
	}
}

House* Player::getEditHouse(uint32_t& windowTextId, uint32_t& listId)
{
	windowTextId = this->windowTextId;
	listId = this->editListId;
	return editHouse;
}

void Player::setEditHouse(House* house, uint32_t listId /*= 0*/)
{
	windowTextId++;
	editHouse = house;
	editListId = listId;
}

void Player::sendHouseWindow(House* house, uint32_t listId) const
{
	if (!client) {
		return;
	}

	std::string text;
	if (house->getAccessList(listId, text)) {
		client->sendHouseWindow(windowTextId, text);
	}
}

//container
void Player::sendAddContainerItem(const Container* container, const Item* item)
{
	if (!client) {
		return;
	}

	for (const auto& it : openContainers) {
		const OpenContainer& openContainer = it.second;
		if (openContainer.container != container) {
			continue;
		}

		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		uint16_t slot = openContainer.index;
		if (container->getID() == ITEM_BROWSEFIELD) {
			uint16_t containerSize = container->size() - 1;
			uint16_t pageEnd = openContainer.index + container->capacity() - 1;
			if (containerSize > pageEnd) {
				slot = pageEnd;
				item = container->getItemByIndex(pageEnd);
			} else {
				slot = containerSize;
			}
		} else if (openContainer.index >= container->capacity()) {
			item = container->getItemByIndex(openContainer.index);
		}
		if (item) {
			client->sendAddContainerItem(it.first, slot, item);
		}
		#else
		client->sendAddContainerItem(it.first, item);
		#endif
		return;
	}
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void Player::sendUpdateContainerItem(const Container* container, uint16_t slot, const Item* newItem)
#else
void Player::sendUpdateContainerItem(const Container* container, uint8_t slot, const Item* newItem)
#endif
{
	if (!client) {
		return;
	}

	for (const auto& it : openContainers) {
		const OpenContainer& openContainer = it.second;
		if (openContainer.container != container) {
			continue;
		}

		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		if (slot < openContainer.index) {
			continue;
		}

		uint16_t pageEnd = openContainer.index + container->capacity();
		if (slot >= pageEnd) {
			continue;
		}

		client->sendUpdateContainerItem(it.first, slot, newItem);
		#else
		client->sendUpdateContainerItem(it.first, slot, newItem);
		#endif
		return;
	}
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void Player::sendRemoveContainerItem(const Container* container, uint16_t slot)
#else
void Player::sendRemoveContainerItem(const Container* container, uint8_t slot)
#endif
{
	if (!client) {
		return;
	}

	for (auto& it : openContainers) {
		OpenContainer& openContainer = it.second;
		if (openContainer.container != container) {
			continue;
		}

		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		uint16_t& firstIndex = openContainer.index;
		if (firstIndex > 0 && firstIndex >= container->size() - 1) {
			firstIndex -= container->capacity();
			sendContainer(it.first, container, false, firstIndex);
		}

		client->sendRemoveContainerItem(it.first, std::max<uint16_t>(slot, firstIndex), container->getItemByIndex(container->capacity() + firstIndex));
		#else
		client->sendRemoveContainerItem(it.first, slot);
		#endif
		return;
	}
}

void Player::onUpdateTileItem(const Tile* tile, const Position& pos, const Item* oldItem,
                              const ItemType& oldType, const Item* newItem, const ItemType& newType)
{
	Creature::onUpdateTileItem(tile, pos, oldItem, oldType, newItem, newType);

	if (oldItem != newItem) {
		onRemoveTileItem(tile, pos, oldType, oldItem);
	}
}

void Player::onRemoveTileItem(const Tile* tile, const Position& pos, const ItemType& iType,
                              const Item* item)
{
	Creature::onRemoveTileItem(tile, pos, iType, item);
}

void Player::onCreatureAppear(Creature* creature, bool isLogin)
{
	Creature::onCreatureAppear(creature, isLogin);

	if (isLogin && creature == this) {
		for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; ++slot) {
			Item* item = inventory[slot];
			if (item) {
				g_moveEvents->onPlayerEquip(this, item, static_cast<slots_t>(slot), false);
			}
		}

		for (Condition* condition : storedConditionList) {
			addCondition(condition);
		}
		storedConditionList.clear();

		BedItem* bed = g_game.getBedBySleeper(guid);
		if (bed) {
			bed->wakeUp(this);
		}
		
		Account account = IOLoginData::loadAccount(accountNumber);
		Game::updatePremium(account);

		std::cout << name << " has logged in." << std::endl;

		if (guild) {
			guild->addMember(this);
		}

		int32_t offlineTime;
		if (getLastLogout() != 0) {
			// Not counting more than 21 days to prevent overflow when multiplying with 1000 (for milliseconds).
			offlineTime = std::min<int32_t>(time(nullptr) - getLastLogout(), 86400 * 21);
		} else {
			offlineTime = 0;
		}

		for (Condition* condition : getMuteConditions()) {
			condition->setTicks(condition->getTicks() - (offlineTime * 1000));
			if (condition->getTicks() <= 0) {
				removeCondition(condition);
			}
		}
		
		g_game.checkPlayersRecord();
		IOLoginData::updateOnlineStatus(guid, true);
		#if GAME_FEATURE_INVENTORY_LIST > 0
		addScheduledUpdates(PlayerUpdate_Inventory);
		#endif
		uint32_t real = 0;

		std::map<uint32_t, uint32_t> listIP;

		for (const auto& it : g_game.getPlayers()) {
			if (it.second->getIP() != 0) {
				auto ip = listIP.find(it.second->getIP());
				if (ip != listIP.end()) {
					listIP[it.second->getIP()]++;
				//	if (listIP[it.second->getIP()] < 5) {
				//		real++;
				//	}
				}
				else {
					listIP[it.second->getIP()] = 1;
					real++;
				}
			}
		}
		std::cout << "Real Online Players: " << real << std::endl;
		g_game.checkPlayersExpiredOffers(this);
	} else {
		const Monster* monster = creature->getMonster();
		if (monster) {
			if (monster->isBoss()) {
				g_events->eventPlayerOnBossAppear(this, creature);
			}
		}
	}
}

void Player::onAttackedCreatureDisappear(bool isLogout)
{
	sendCancelTarget();

	if (!isLogout) {
		sendTextMessage(MESSAGE_STATUS_SMALL, "Target lost.");
	}
}

void Player::onFollowCreatureDisappear(bool isLogout)
{
	sendCancelTarget();

	if (!isLogout) {
		sendTextMessage(MESSAGE_STATUS_SMALL, "Target lost.");
	}
}

void Player::onChangeZone(ZoneType_t zone)
{
	if (zone == ZONE_PROTECTION) {
		if (attackedCreature && !hasFlag(PlayerFlag_IgnoreProtectionZone)) {
			setAttackedCreature(nullptr);
			onAttackedCreatureDisappear(false);
		}

		#if GAME_FEATURE_MOUNTS > 0
		if (!group->access && isMounted()) {
			dismount();
			g_game.internalCreatureChangeOutfit(this, defaultOutfit);
			wasMounted = true;
		}
		#endif
	}
	#if GAME_FEATURE_MOUNTS > 0
	else {
		if (wasMounted) {
			toggleMount(true);
			wasMounted = false;
		}
	}
	#endif
	sendIcons();
}

void Player::onAttackedCreatureChangeZone(ZoneType_t zone)
{
	if (zone == ZONE_PROTECTION) {
		if (!hasFlag(PlayerFlag_IgnoreProtectionZone)) {
			setAttackedCreature(nullptr);
			onAttackedCreatureDisappear(false);
		}
	}
}

void Player::onRemoveCreature(Creature* creature, bool isLogout)
{
	Creature::onRemoveCreature(creature, isLogout);

	if (creature == this) {
		if (isLogout) {
			loginPosition = getPosition();
		}

		lastLogout = time(nullptr);

		if (eventWalk != 0) {
			stopEventWalk();
			setFollowCreature(nullptr);
		}

		closeShopWindow();		
		openContainers.clear();

		clearPartyInvitations();

		if (party) {
			party->leaveParty(this);
		}

		g_chat->removeUserFromAllChannels(*this);
		#if GAME_FEATURE_RULEVIOLATION > 0
		g_game.playerCheckRuleViolation(this);
		#endif

		std::cout << getName() << " has logged out." << std::endl;

		if (guild) {
			guild->removeMember(this);
		}

		IOLoginData::updateOnlineStatus(guid, false);
		IOLoginData::savePlayer(this);	
		addInfoLog("[SERVER] logout");

		spdlog::drop("player_" + getName());
		playerLogger = nullptr;
	}
	else {
		const Monster* monster = creature->getMonster();
		if (monster && monster->isBoss()) {
			g_events->eventPlayerOnBossDisappear(this, creature);
		}
	}
}

void Player::openShopWindow(Npc* npc, std::vector<ShopInfo>& shop)
{
	shopItemList = std::move(shop);
	sendShop(npc);
}

bool Player::closeShopWindow(bool sendCloseShopWindow /*= true*/)
{
	//unreference callbacks
	int32_t onBuy;
	int32_t onSell;

	Npc* npc = getShopOwner(onBuy, onSell);
	if (!npc) {
		shopItemList.clear();
		return false;
	}

	setShopOwner(nullptr, -1, -1);
	npc->onPlayerEndTrade(this, onBuy, onSell);

	if (sendCloseShopWindow) {
		sendCloseShop();
	}

	shopItemList.clear();
	return true;
}

void Player::onWalk(Direction& dir)
{
	Creature::onWalk(dir);
	stopNextActionTask();
	setNextAction(OTSYS_TIME() + getStepDuration(dir));
	if (Party* party = getParty()) {
		party->updatePlayerPosition(this, getPosition());
	}
}

void Player::onCreatureMove(Creature* creature, const Tile* newTile, const Position& newPos,
                            const Tile* oldTile, const Position& oldPos, bool teleport)
{
	Creature::onCreatureMove(creature, newTile, newPos, oldTile, oldPos, teleport);

	if (creature == this) {
		// close modal windows
        HouseTile* houseTile = dynamic_cast<HouseTile*>(const_cast<Tile*>(oldTile));
		HouseTile* houseTile2 = dynamic_cast<HouseTile*>(const_cast<Tile*>(newTile));
        if (houseTile && !houseTile2) {
            House* house = houseTile->getHouse();
            if (house && house->getHouseAccessLevel(this) >= HOUSE_SUBOWNER) {
                g_events->eventPlayerOnHouseWalk(this, house, false);
            }
        } else if (!houseTile && houseTile2) {
            House* house = houseTile2->getHouse();
            if (house && house->getHouseAccessLevel(this) >= HOUSE_SUBOWNER) {
                g_events->eventPlayerOnHouseWalk(this, house, true);
            }
        }

		if (!modalWindows.empty()) {
			// TODO: This shouldn't be hardcoded
			for (uint32_t modalWindowId : modalWindows) {
				if (modalWindowId == std::numeric_limits<uint32_t>::max()) {
					sendTextMessage(MESSAGE_EVENT_ADVANCE, "Offline training aborted.");
					break;
				}
			}
			modalWindows.clear();
		}

		if (party) {
			party->updateSharedExperience();
			#if GAME_FEATURE_PARTY_LIST > 0
			party->updatePlayerStatus(this, oldPos, newPos);
			#endif
		}

		if (teleport || oldPos.z != newPos.z) {
			int32_t ticks = g_config.getNumber(ConfigManager::STAIRHOP_DELAY);
			if (ticks > 0) {
				if (Condition* condition = Condition::createCondition(CONDITIONID_DEFAULT, CONDITION_PACIFIED, ticks, 0)) {
					addCondition(condition);
				}
			}
		}
	}
}


void Player::onCloseContainer(const Container* container)
{
	if (!client) {
		return;
	}

	for (const auto& it : openContainers) {
		if (it.second.container == container) {
			client->sendCloseContainer(it.first);
		}
	}
}

void Player::onSendContainer(const Container* container)
{
	if (!client) {
		return;
	}

	bool hasParent = container->hasParent();
	for (const auto& it : openContainers) {
		const OpenContainer& openContainer = it.second;
		if (openContainer.container == container) {
			#if GAME_FEATURE_CONTAINER_PAGINATION > 0
			client->sendContainer(it.first, container, hasParent, openContainer.index);
			#else
			client->sendContainer(it.first, container, hasParent);
			#endif
		}
	}
}


void Player::stopNextWalkActionTask()
{
	if (walkTaskEvent != 0) {
		g_dispatcher.stopEvent(walkTaskEvent);
		walkTaskEvent = 0;
	}

	delete walkTask;
	walkTask = nullptr;
}

void Player::stopNextWalkTask()
{
	if (nextStepEvent != 0) {
		g_dispatcher.stopEvent(nextStepEvent);
		nextStepEvent = 0;
	}
}

void Player::stopNextActionTask()
{
	if (actionTaskEvent != 0) {
		g_dispatcher.stopEvent(actionTaskEvent);
		actionTaskEvent = 0;
	}
}

void Player::setNextWalkActionTask(uint32_t delay, std::function<void (void)> f)
{
	stopNextWalkActionTask();
	walkTask = new std::pair<uint32_t, std::function<void (void)>>(delay, std::move(f));
}

void Player::setNextWalkTask(uint32_t delay, std::function<void (void)> f)
{
	stopNextWalkTask();
	nextStepEvent = g_dispatcher.addEvent(delay, std::move(f));
	resetIdleTime();
}

void Player::setNextActionTask(uint32_t delay, std::function<void (void)> f)
{
	stopNextActionTask();
	actionTaskEvent = g_dispatcher.addEvent(delay, std::move(f));
	resetIdleTime();
}

uint32_t Player::getNextActionTime() const
{
	return std::max<int64_t>(SERVER_BEAT_MILISECONDS, nextAction - OTSYS_TIME());
}

void Player::onThink(uint32_t interval)
{
	Creature::onThink(interval);

	sendPing();
	sendCamRefreshPacket();

	MessageBufferTicks += interval;
	if (MessageBufferTicks >= 1500) {
		MessageBufferTicks = 0;
		addMessageBuffer();
	}

	if (!isShop()) {
		if (!getTile()->hasFlag(TILESTATE_NOLOGOUT) && !isAccessPlayer()) {
			idleTime += interval;
			const int32_t kickAfterMinutes = g_config.getNumber(ConfigManager::KICK_AFTER_MINUTES);
			if (idleTime > (kickAfterMinutes * 60000) + 60000) {
				addInfoLog("[SERVER] kickAfterMinutes");
				kickPlayer(true);
			} else if (client && idleTime == 60000 * kickAfterMinutes) {
				std::stringExtended ss(128);
				ss << "You have been idle for " << kickAfterMinutes << " minutes. You will be disconnected in one minute if you are still idle then.";
				client->sendTextMessage(TextMessage(MESSAGE_STATUS_WARNING, ss));
			}
		}
	}

	if (g_game.getWorldType() != WORLD_TYPE_PVP_ENFORCED) {
		checkSkullTicks(interval / 1000);
	}
}

uint32_t Player::isMuted() const
{
	if (hasFlag(PlayerFlag_CannotBeMuted)) {
		return 0;
	}

	int32_t muteTicks = 0;
	for (Condition* condition : conditions) {
		if (condition->getType() == CONDITION_MUTED && condition->getTicks() > muteTicks) {
			muteTicks = condition->getTicks();
		}
	}
	return static_cast<uint32_t>(muteTicks) / 1000;
}

void Player::addMessageBuffer()
{
	if (MessageBufferCount > 0 && g_config.getNumber(ConfigManager::MAX_MESSAGEBUFFER) != 0 && !hasFlag(PlayerFlag_CannotBeMuted)) {
		--MessageBufferCount;
	}
}

void Player::removeMessageBuffer()
{
	if (hasFlag(PlayerFlag_CannotBeMuted)) {
		return;
	}

	const int32_t maxMessageBuffer = g_config.getNumber(ConfigManager::MAX_MESSAGEBUFFER);
	if (maxMessageBuffer != 0 && MessageBufferCount <= maxMessageBuffer + 1) {
		if (++MessageBufferCount > maxMessageBuffer) {
			uint32_t muteCount = 1;
			auto it = muteCountMap.find(guid);
			if (it != muteCountMap.end()) {
				muteCount = it->second;
			}

			uint32_t muteTime = 5 * muteCount * muteCount;
			muteCountMap[guid] = muteCount + 1;
			Condition* condition = Condition::createCondition(CONDITIONID_DEFAULT, CONDITION_MUTED, muteTime * 1000, 0);
			addCondition(condition);

			std::stringExtended ss(64);
			ss << "You are muted for " << muteTime << " seconds.";
			sendTextMessage(MESSAGE_STATUS_SMALL, ss);
		}
	}
}

void Player::drainHealth(Creature* attacker, int64_t damage)
{
	Creature::drainHealth(attacker, damage);
	sendStats(1);
}

void Player::drainMana(Creature* attacker, int64_t manaLoss)
{
	onAttacked();
	changeMana(-manaLoss);

	if (attacker) {
		addDamagePoints(attacker, manaLoss);
	}

	sendStats(4);
}

void Player::addManaSpent(uint64_t amount)
{
	if (hasFlag(PlayerFlag_NotGainMana)) {
		return;
	}

	uint64_t currReqMana = vocation->getReqMana(magLevel);
	uint64_t nextReqMana = vocation->getReqMana(magLevel + 1);
	if (currReqMana >= nextReqMana) {
		//player has reached max magic level
		return;
	}

	g_events->eventPlayerOnGainSkillTries(this, SKILL_MAGLEVEL, amount);
	if (amount == 0) {
		return;
	}

	bool sendUpdateStats = false;
	while ((manaSpent + amount) >= nextReqMana) {
		amount -= nextReqMana - manaSpent;

		magLevel++;
		manaSpent = 0;

		std::stringExtended ss(64);
		ss << "You advanced to mastery " << magLevel << '.';
		sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);

		g_creatureEvents->playerAdvance(this, SKILL_MAGLEVEL, magLevel - 1, magLevel);

		sendUpdateStats = true;
		currReqMana = nextReqMana;
		nextReqMana = vocation->getReqMana(magLevel + 1);
		if (currReqMana >= nextReqMana) {
			return;
		}
	}

	manaSpent += amount;

	#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
	uint16_t oldPercent = magLevelPercent;
	#else
	uint8_t oldPercent = magLevelPercent;
	#endif
	if (nextReqMana > currReqMana) {
		magLevelPercent = Player::getPercentSkillLevel(manaSpent, nextReqMana);
	} else {
		magLevelPercent = 0;
	}

	if (oldPercent != magLevelPercent) {
		sendUpdateStats = true;
	}

	if (sendUpdateStats) {
		sendStats(4);
	}
}

void Player::addExperience(Creature* source, uint64_t exp, bool sendText/* = false*/)
{
	uint64_t currLevelExp = Player::getExpForLevel(level);
	uint64_t nextLevelExp = Player::getExpForLevel(level + 1);

	uint64_t rawExp = exp;
	if (currLevelExp >= nextLevelExp) {
		//player has reached max level
		levelPercent = 0;
		sendStats(3);
		return;
	}

	g_events->eventPlayerOnGainExperience(this, source, exp, rawExp);
	if (exp == 0) {
		return;
	}

//	if (g_game.isGlobalBuffActive(BUFF_GLOBAL_EXP))
//	{
//		exp += round(exp * 0.5);
//	}

	experience += exp;

	if (sendText) {
		std::string expString = std::to_string(exp) + (exp != 1 ? " experience points." : " experience point.");

		TextMessage message(MESSAGE_EXPERIENCE, "You gained " + expString);
	//	message.position = position;
	//	message.primary.value = exp;
	//	message.primary.color = TEXTCOLOR_WHITE_EXP;
	//	sendTextMessage(message);
		
	//	std::stringExtended expAnim(32);
	//	if (level >= 1500) {
	//			expAnim << "PEXP +" << exp / 10;
	//	} else {
	//			expAnim << "EXP +" << exp;
	//	}
	//	g_game.addAnimatedText(expAnim, position, TEXTCOLOR_WHITE_EXP, "");

		SpectatorVector spectators;
		g_game.map.getSpectators(spectators, position, false, true);
		spectators.erase(this);
		if (!spectators.empty()) {
			message.type = MESSAGE_EXPERIENCE_OTHERS;
			message.text = getName() + " gained " + expString;
			for (Creature* spectator : spectators) {
				spectator->getPlayer()->sendTextMessage(message);
			}
		}
	}

	uint32_t prevLevel = level;
	while (experience >= nextLevelExp) {
		++level;
		healthMax += vocation->getHPGain();
		health += vocation->getHPGain();
		manaMax += vocation->getManaGain();
		mana += vocation->getManaGain();
		capacity += vocation->getCapGain();

		currLevelExp = nextLevelExp;
		nextLevelExp = Player::getExpForLevel(level + 1);
		if (currLevelExp >= nextLevelExp) {
			//player has reached max level
			break;
		}
	}

	if (prevLevel != level) {
		health = healthMax;
		mana = manaMax;

		updateBaseSpeed();
		g_game.changeSpeed(this, 0);
		g_game.addCreatureHealth(this);
		#if GAME_FEATURE_PARTY_LIST > 0
		g_game.addPlayerMana(this);
		#endif

		if (party) {
			party->updateSharedExperience();
		}

		g_creatureEvents->playerAdvance(this, SKILL_LEVEL, prevLevel, level);

		std::stringExtended ss(64);
		ss << "You advanced from Level " << prevLevel << " to Level " << level << '.';
		sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);
	}

	if (nextLevelExp > currLevelExp) {
		levelPercent = Player::getPercentLevel(experience - currLevelExp, nextLevelExp - currLevelExp);
	} else {
		levelPercent = 0;
	}
	sendStats(1);
	sendStats(2);
	sendStats(3);
	sendStats(4);
}

void Player::removeExperience(uint64_t exp, bool sendText/* = false*/, bool canRemoveLevel/* = true*/)
{
	if (experience == 0 || exp == 0) {
		return;
	}

	g_events->eventPlayerOnLoseExperience(this, exp);
	if (exp == 0) {
		return;
	}

	uint64_t lostExp = experience;
	experience = std::max<int64_t>(0, experience - exp);

	if (sendText) {
		lostExp -= experience;

		std::string expString = std::to_string(lostExp) + (lostExp != 1 ? " experience points." : " experience point.");

		TextMessage message(MESSAGE_EXPERIENCE, "You lost " + expString);
		message.position = position;
		message.primary.value = lostExp;
		message.primary.color = TEXTCOLOR_RED;
		sendTextMessage(message);

		SpectatorVector spectators;
		g_game.map.getSpectators(spectators, position, false, true);
		spectators.erase(this);
		if (!spectators.empty()) {
			message.type = MESSAGE_EXPERIENCE_OTHERS;
			message.text = getName() + " lost " + expString;
			for (Creature* spectator : spectators) {
				spectator->getPlayer()->sendTextMessage(message);
			}
		}
	}

	uint32_t oldLevel = level;
	uint64_t currLevelExp = Player::getExpForLevel(level);

	if (canRemoveLevel) {
		while (level > 1 && experience < currLevelExp) {
			--level;
			healthMax = std::max<int64_t>(0, healthMax - vocation->getHPGain());
			manaMax = std::max<int64_t>(0, manaMax - vocation->getManaGain());
			capacity = std::max<int32_t>(0, capacity - vocation->getCapGain());
			currLevelExp = Player::getExpForLevel(level);
		}
	} else {
		if (experience < currLevelExp) {
			experience = currLevelExp;
		}
	}

	if (oldLevel != level) {
		health = healthMax;
		mana = manaMax;

		updateBaseSpeed();
		g_game.changeSpeed(this, 0);
		g_game.addCreatureHealth(this);
		#if GAME_FEATURE_PARTY_LIST > 0
		g_game.addPlayerMana(this);
		#endif

		if (party) {
			party->updateSharedExperience();
		}

		std::stringExtended ss(64);
		ss << "You were downgraded from Level " << oldLevel << " to Level " << level << '.';
		sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);
	}

	uint64_t nextLevelExp = Player::getExpForLevel(level + 1);
	if (nextLevelExp > currLevelExp) {
		levelPercent = Player::getPercentLevel(experience - currLevelExp, nextLevelExp - currLevelExp);
	} else {
		levelPercent = 0;
	}
	sendStats(1);
	sendStats(2);
	sendStats(3);
	sendStats(4);
}

#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
uint16_t Player::getPercentSkillLevel(uint64_t count, uint64_t nextLevelCount)
#else
uint8_t Player::getPercentSkillLevel(uint64_t count, uint64_t nextLevelCount)
#endif
{
	if (nextLevelCount == 0) {
		return 0;
	}

	#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
	uint16_t result;
	if (nextLevelCount > 1000000000000000ULL) {
		result = count / (nextLevelCount / 10000);
	} else {
		result = (count * 10000) / nextLevelCount;
	}
	if (result > 10000) {
		return 0;
	}
	#else
	uint8_t result;
	if (nextLevelCount > 100000000000000000ULL) {
		result = count / (nextLevelCount / 100);
	} else {
		result = (count * 100) / nextLevelCount;
	}
	if (result > 100) {
		return 0;
	}
	#endif
	return result;
}

uint8_t Player::getPercentLevel(uint64_t count, uint64_t nextLevelCount)
{
	if (nextLevelCount == 0) {
		return 0;
	}

	uint8_t result;
	if (nextLevelCount > 100000000000000000ULL) {
		result = count / (nextLevelCount / 100);
	} else {
		result = (count * 100) / nextLevelCount;
	}
	if (result > 100) {
		return 0;
	}
	return result;
}

void Player::onBlockHit()
{
		if (hasShield()) {
		//	addSkillAdvance(SKILL_SHIELD, 1);
		}
}

void Player::onAttackedCreatureBlockHit(BlockType_t blockType)
{
	lastAttackBlockType = blockType;

	switch (blockType) {
		case BLOCK_NONE: {
			addAttackSkillPoint = true;
			bloodHitCount = 300;
			shieldBlockCount = 300;
			break;
		}

		case BLOCK_DEFENSE:
		case BLOCK_ARMOR: {
			//need to draw blood every 30 hits
			if (bloodHitCount > 0) {
				addAttackSkillPoint = true;
				--bloodHitCount;
			} else {
				addAttackSkillPoint = false;
			}
			break;
		}

		default: {
			addAttackSkillPoint = false;
			break;
		}
	}
}

bool Player::hasShield() const
{
	Item* item = inventory[CONST_SLOT_LEFT];
	if (item && item->getWeaponType() == WEAPON_SHIELD) {
		return true;
	}

	item = inventory[CONST_SLOT_RIGHT];
	if (item && item->getWeaponType() == WEAPON_SHIELD) {
		return true;
	}
	return false;
}

BlockType_t Player::blockHit(Creature* attacker, CombatType_t combatType, int64_t& damage,
                             bool checkDefense /* = false*/, bool checkArmor /* = false*/, bool field /* = false*/)
{
//	std::cout << "1. Damage Taken " << damage << std::endl; // lola
	BlockType_t blockType = Creature::blockHit(attacker, combatType, damage, checkDefense, checkArmor, field);
	int32_t armor = getArmor();
	int32_t defense = getDefense();
	addStorageValue(6786790, armor);
	addStorageValue(6786791, defense);

	if (attacker) {
		sendCreatureSquare(attacker, SQ_COLOR_BLACK);
	}

	if (blockType != BLOCK_NONE) {
		return blockType;
	}

	if (damage <= 0) {
		damage = 0;
		return BLOCK_ARMOR;
	}
	if (hasShield()) {
	//	addSkillAdvance(SKILL_SHIELD, 1);
	}
	uint16_t characterEndurance = (charStats[CHARSTAT_SPIRIT] / 4.f);
	uint16_t endValues = 0;
	float armorPercent = (armor / (4000.f + armor)) * 100;
	endValues += std::ceil(armorPercent + characterEndurance);
	for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; ++slot) {
		if (!isItemAbilityEnabled(static_cast<slots_t>(slot))) {
			continue;
		}

		Item* item = inventory[slot];
		if (!item) {
			continue;
		}

		const ItemType& it = Item::items[item->getID()];
		if (!it.abilities) {
			if (damage <= 0) {
				damage = 0;
				return BLOCK_ARMOR;
			}

			continue;
		}

		const int16_t& absorbPercent = it.abilities->absorbPercent[combatTypeToIndex(combatType)];
		if (absorbPercent != 0) {
		endValues += absorbPercent;

			uint16_t charges = item->getCharges();
			if (charges != 0) {
				g_game.transformItem(item, item->getID(), charges - 1);
			}
		}

		if (field) {
			const int16_t& fieldAbsorbPercent = it.abilities->fieldAbsorbPercent[combatTypeToIndex(combatType)];
			if (fieldAbsorbPercent != 0) {
				endValues += fieldAbsorbPercent;
				uint16_t charges = item->getCharges();
				if (charges != 0) {
					g_game.transformItem(item, item->getID(), charges - 1);
				}
			}
		}
	}
	if (endValues >= 85) {
		endValues = 85;
	}
	addStorageValue(800078, endValues);
//	damage -= std::round((damage * endValues) / 100.);
//	if (defense > 0) {
//		damage -= defense;
//	}

	if (damage <= 0) {
		damage = 0;
		blockType = BLOCK_ARMOR;
	}
	return blockType;
}

void Player::death(Creature* lastHitCreature)
{
	loginPosition = Position( 675, 1040, 7);

	if (skillLoss) {
		uint8_t unfairFightReduction = 100;
		bool lastHitPlayer = Player::lastHitIsPlayer(lastHitCreature);

		if (lastHitPlayer) {
			uint32_t sumLevels = 0;
			uint32_t inFightTicks = g_config.getNumber(ConfigManager::PZ_LOCKED);
			for (const auto& it : damageMap) {
				CountBlock_t cb = it.second;
				if ((OTSYS_TIME() - cb.ticks) <= inFightTicks) {
					Player* damageDealer = g_game.getPlayerByID(it.first);
					if (damageDealer) {
						sumLevels += damageDealer->getLevel();
					}
				}
			}

			if (sumLevels > level) {
				double reduce = level / static_cast<double>(sumLevels);
				unfairFightReduction = std::max<uint8_t>(20, std::floor((reduce * 100) + 0.5));
			}
		}

		//Magic level loss
		uint64_t sumMana = 0;
		uint64_t lostMana = 0;

		//sum up all the mana
		for (uint32_t i = 1; i <= magLevel; ++i) {
			sumMana += vocation->getReqMana(i);
		}

		sumMana += manaSpent;

		double deathLossPercent = getLostPercent() * (unfairFightReduction / 100.);
	//	double deathLossPercent = getLostPercent();

		lostMana = static_cast<uint64_t>(sumMana * deathLossPercent);

		while (lostMana > manaSpent && magLevel > 0) {
			lostMana -= manaSpent;
			manaSpent = vocation->getReqMana(magLevel);
			magLevel--;
		}

		manaSpent -= lostMana;

		uint64_t nextReqMana = vocation->getReqMana(magLevel + 1);
		if (nextReqMana > vocation->getReqMana(magLevel)) {
			magLevelPercent = Player::getPercentSkillLevel(manaSpent, nextReqMana);
		} else {
			magLevelPercent = 0;
		}

		//Skill loss
		for (uint8_t i = SKILL_FIRST; i <= SKILL_LAST; ++i) { //for each skill
			uint64_t sumSkillTries = 0;
			for (uint16_t c = 11; c <= skills[i].level; ++c) { //sum up all required tries for all skill levels
				sumSkillTries += vocation->getReqSkillTries(i, c);
			}

			sumSkillTries += skills[i].tries;

			uint32_t lostSkillTries = static_cast<uint32_t>(sumSkillTries * deathLossPercent);
			while (lostSkillTries > skills[i].tries) {
				lostSkillTries -= skills[i].tries;

				if (skills[i].level <= 10) {
					skills[i].level = 10;
					skills[i].tries = 0;
					lostSkillTries = 0;
					break;
				}

				skills[i].tries = vocation->getReqSkillTries(i, skills[i].level);
				skills[i].level--;
			}

			skills[i].tries = std::max<int32_t>(0, skills[i].tries - lostSkillTries);
			skills[i].percent = Player::getPercentSkillLevel(skills[i].tries, vocation->getReqSkillTries(i, skills[i].level));
		}

		//Level loss
		uint64_t expLoss = static_cast<uint64_t>(experience * deathLossPercent);
		g_events->eventPlayerOnLoseExperience(this, expLoss);
		
		if (level >= 1500) {
			expLoss = 0;
		}

		if (expLoss != 0) {
			uint32_t oldLevel = level;

			if (vocation->getId() == VOCATION_NONE || level > 7) {
				experience -= expLoss;
			}

			while (level > 1 && experience < Player::getExpForLevel(level)) {
				--level;
				healthMax = std::max<int64_t>(0, healthMax - vocation->getHPGain());
				manaMax = std::max<int64_t>(0, manaMax - vocation->getManaGain());
				capacity = std::max<int32_t>(0, capacity - vocation->getCapGain());
			}

			if (oldLevel != level) {
				std::stringExtended ss(64);
				ss << "You were downgraded from Level " << oldLevel << " to Level " << level << '.';
				sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);
			}

			uint64_t currLevelExp = Player::getExpForLevel(level);
			uint64_t nextLevelExp = Player::getExpForLevel(level + 1);
			if (nextLevelExp > currLevelExp) {
				levelPercent = Player::getPercentLevel(experience - currLevelExp, nextLevelExp - currLevelExp);
			} else {
				levelPercent = 0;
			}
		}

		std::bitset<6> bitset(blessings);
		if (bitset[5]) {
			if (lastHitPlayer) {
				bitset.reset(5);
				blessings = bitset.to_ulong();
			} else {
				blessings = 32;
			}
		} else {
			blessings = 0;
		}

		sendStats(1);
		sendStats(2);
		sendStats(3);
		sendStats(4);
		sendReLoginWindow(unfairFightReduction);

		if (getSkull() == SKULL_BLACK) {
			health = 40;
			mana = 0;
		} else {
			health = healthMax;
			mana = manaMax;
		}
	} else {
		setSkillLoss(true);

		health = healthMax;
		g_game.internalTeleport(this, Position( 675, 1040, 7), true);
		g_game.addCreatureHealth(this);
		#if GAME_FEATURE_PARTY_LIST > 0
		g_game.addPlayerMana(this);
		#endif
		onThink(EVENT_CREATURE_THINK_INTERVAL);
		onIdleStatus();
		sendStats(1);
		sendStats(2);
		sendStats(3);
		sendStats(4);
	}
}

bool Player::dropCorpse(Creature* lastHitCreature, Creature* mostDamageCreature, bool lastHitUnjustified, bool mostDamageUnjustified)
{
	if (getZone() != ZONE_PVP || !Player::lastHitIsPlayer(lastHitCreature)) {
		return Creature::dropCorpse(lastHitCreature, mostDamageCreature, lastHitUnjustified, mostDamageUnjustified);
	}

	setDropLoot(true);
	return false;
}

Item* Player::getCorpse(Creature* lastHitCreature, Creature* mostDamageCreature)
{
	Item* corpse = Creature::getCorpse(lastHitCreature, mostDamageCreature);
	if (corpse && corpse->getContainer()) {
		std::stringExtended ss(getNameDescription().length() + static_cast<size_t>(64));
		if (lastHitCreature) {
			ss << "You recognize " << getNameDescription() << ". " << (getSex() == PLAYERSEX_FEMALE ? "She" : "He") << " was killed by " << lastHitCreature->getNameDescription() << '.';
		} else {
			ss << "You recognize " << getNameDescription() << '.';
		}

		corpse->setSpecialDescription(ss);
	}
	return corpse;
}

void Player::addInFightTicks(bool pzlock /*= false*/)
{
	if (hasFlag(PlayerFlag_NotGainInFight)) {
		return;
	}

	if (pzlock) {
		pzLocked = true;
	}

	Condition* condition = Condition::createCondition(CONDITIONID_DEFAULT, CONDITION_INFIGHT, g_config.getNumber(ConfigManager::PZ_LOCKED), 0);
	addCondition(condition);
}

void Player::removeList()
{
	g_game.removePlayer(this);

	for (const auto& it : g_game.getPlayers()) {
		it.second->notifyStatusChange(this, VIPSTATUS_OFFLINE);
	}
}

void Player::addList()
{
	for (const auto& it : g_game.getPlayers()) {
		it.second->notifyStatusChange(this, VIPSTATUS_ONLINE);
	}

	g_game.addPlayer(this);
}

void Player::kickPlayer(bool displayEffect)
{

	g_creatureEvents->playerLogout(this);
	if (client) {
		client->logout(displayEffect, true);
	} else {
		g_game.removeCreature(this);
	}
}

void Player::notifyStatusChange(Player* loginPlayer, VipStatus_t status)
{
	if (!client) {
		return;
	}

	auto it = VIPList.find(loginPlayer->guid);
	if (it == VIPList.end()) {
		return;
	}

	client->sendUpdatedVIPStatus(loginPlayer->guid, status);

	if (status == VIPSTATUS_ONLINE) {
		client->sendTextMessage(TextMessage(MESSAGE_STATUS_SMALL, loginPlayer->getName() + " has logged in."));
	} else if (status == VIPSTATUS_OFFLINE) {
		client->sendTextMessage(TextMessage(MESSAGE_STATUS_SMALL, loginPlayer->getName() + " has logged out."));
	}
}

void Player::setAccountStorageValue(const uint32_t key, const int32_t value)
{
	if (value != -1) {
		int32_t oldValue;
		getAccountStorageValue(key, oldValue);

		accountStorageMap[key] = value;
		
	} else {
		accountStorageMap.erase(key);
	}
}

bool Player::getAccountStorageValue(const uint32_t key, int32_t& value) const
{
	auto it = accountStorageMap.find(key);
	if (it == accountStorageMap.end()) {
		value = -1;
		return false;
	}

	value = it->second;
	return true;
}

bool Player::removeVIP(uint32_t vipGuid)
{
	if (VIPList.erase(vipGuid) == 0) {
		return false;
	}

	IOLoginData::removeVIPEntry(accountNumber, vipGuid);
	return true;
}

bool Player::addVIP(uint32_t vipGuid, const std::string& vipName, VipStatus_t status)
{
	if (VIPList.size() >= getMaxVIPEntries() || VIPList.size() == 200) { // max number of buddies is 200 in 9.53
		sendTextMessage(MESSAGE_STATUS_SMALL, "You cannot add more buddies.");
		return false;
	}

	auto result = VIPList.insert(vipGuid);
	if (!result.second) {
		sendTextMessage(MESSAGE_STATUS_SMALL, "This player is already in your list.");
		return false;
	}

	IOLoginData::addVIPEntry(accountNumber, vipGuid, "", 0, false);
	if (client) {
		#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
		client->sendVIP(vipGuid, vipName, "", 0, false, status);
		#else
		client->sendVIP(vipGuid, vipName, status);
		#endif
	}
	return true;
}

bool Player::addVIPInternal(uint32_t vipGuid)
{
	if (VIPList.size() >= getMaxVIPEntries() || VIPList.size() == 200) { // max number of buddies is 200 in 9.53
		return false;
	}

	return VIPList.insert(vipGuid).second;
}

bool Player::editVIP(uint32_t vipGuid, const std::string& description, uint32_t icon, bool notify)
{
	auto it = VIPList.find(vipGuid);
	if (it == VIPList.end()) {
		return false; // player is not in VIP
	}

	IOLoginData::editVIPEntry(accountNumber, vipGuid, description, icon, notify);
	return true;
}

//close container and its child containers
void Player::autoCloseContainers(const Container* container)
{
	std::vector<uint32_t> closeList;
	closeList.reserve(openContainers.size());

	for (const auto& it : openContainers) {
		Container* tmpContainer = it.second.container;
		while (tmpContainer) {
			if (tmpContainer->isRemoved() || tmpContainer == container) {
				closeList.push_back(it.first);
				break;
			}

			tmpContainer = dynamic_cast<Container*>(tmpContainer->getParent());
		}
	}

	for (uint32_t containerId : closeList) {
		closeContainer(containerId);
		if (client) {
			client->sendCloseContainer(containerId);
		}
	}
}

ReturnValue Player::queryAdd(int32_t index, const Thing& thing, uint32_t count, uint32_t flags, Creature*) const
{
	const Item* item = thing.getItem();
	if (item == nullptr) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	bool childIsOwner = hasBitSet(FLAG_CHILDISOWNER, flags);
	if (childIsOwner) {
		return RETURNVALUE_NOERROR;
	}

	if (!item->isPickupable()) {
		return RETURNVALUE_CANNOTPICKUP;
	}


	ReturnValue ret = RETURNVALUE_NOERROR;

	const int32_t& slotPosition = item->getSlotPosition();
	if ((slotPosition & SLOTP_HEAD) || (slotPosition & SLOTP_NECKLACE) ||
	    (slotPosition & SLOTP_BACKPACK) || (slotPosition & SLOTP_ARMOR) ||
	    (slotPosition & SLOTP_LEGS) || (slotPosition & SLOTP_FEET) || 
		(slotPosition & SLOTP_GLOVES) || (slotPosition & SLOTP_RING2) || 
		(slotPosition & SLOTP_RING) || (slotPosition & SLOTP_SPELL1) ||
		(slotPosition & SLOTP_SPELL2) || (slotPosition & SLOTP_SPELL3) ||
		(slotPosition & SLOTP_RIGHT) || (slotPosition & SLOTP_LEFT) ||
		(slotPosition & SLOTP_SPELL4) || (slotPosition & SLOTP_POTION1)
		) {
		ret = RETURNVALUE_CANNOTBEDRESSED;
	} else if (slotPosition & SLOTP_TWO_HAND) {
		ret = RETURNVALUE_PUTTHISOBJECTINBOTHHANDS;
	}

	switch (index) {
		case CONST_SLOT_HEAD:
		case CONST_SLOT_NECKLACE:
		case CONST_SLOT_ARMOR:
		case CONST_SLOT_LEGS:
		case CONST_SLOT_FEET:
		case CONST_SLOT_RING:
		case CONST_SLOT_GLOVES:
		case CONST_SLOT_RING2: {
			if (slotPosition & (SLOTP_HEAD | SLOTP_NECKLACE | SLOTP_ARMOR | SLOTP_LEGS | SLOTP_FEET | SLOTP_RING | SLOTP_GLOVES | SLOTP_RING2 | SLOTP_LEFT | SLOTP_RIGHT | SLOTP_TWO_HAND | SLOTP_HAND)) {
				ret = RETURNVALUE_NOERROR;
			}
			break;
		}

		case CONST_SLOT_BACKPACK: {
			if (slotPosition & SLOTP_BACKPACK) {
				ret = RETURNVALUE_NOERROR;
			}
			break;
		}

		case CONST_SLOT_LEFT: {
			if (slotPosition & SLOTP_LEFT) {
				if (slotPosition & SLOTP_TWO_HAND) {
					if (inventory[CONST_SLOT_RIGHT] && inventory[CONST_SLOT_RIGHT] != item) {
						ret = RETURNVALUE_BOTHHANDSNEEDTOBEFREE;
					} else {
						ret = RETURNVALUE_NOERROR;
					}
				} else if (inventory[CONST_SLOT_RIGHT]) {
					const Item* rightItem = inventory[CONST_SLOT_RIGHT];
					WeaponType_t rightType = rightItem->getWeaponType();

					if (rightItem->getSlotPosition() & SLOTP_TWO_HAND) {
						ret = RETURNVALUE_DROPTWOHANDEDITEM;
					} else if (item->getWeaponType() == WEAPON_NONE) {
						ret = RETURNVALUE_CANNOTBEDRESSED;
					} else {
						ret = RETURNVALUE_NOERROR;
					}
				} else {
					if (item->getWeaponType() == WEAPON_NONE) {
						ret = RETURNVALUE_CANNOTBEDRESSED;
					} else {
						ret = RETURNVALUE_NOERROR;
					}
				}
			}
			break;
		}

		case CONST_SLOT_RIGHT: {
			if (slotPosition & SLOTP_RIGHT) {
				if (slotPosition & SLOTP_TWO_HAND) {
					if (inventory[CONST_SLOT_LEFT] && inventory[CONST_SLOT_LEFT] != item) {
						ret = RETURNVALUE_BOTHHANDSNEEDTOBEFREE;
					} else {
						ret = RETURNVALUE_NOERROR;
					}
				} else if (inventory[CONST_SLOT_LEFT]) {
					const Item* leftItem = inventory[CONST_SLOT_LEFT];
					WeaponType_t leftType = leftItem->getWeaponType();

					if (leftItem->getSlotPosition() & SLOTP_TWO_HAND) {
						ret = RETURNVALUE_DROPTWOHANDEDITEM;
					} else if (item->getWeaponType() == WEAPON_NONE) {
						ret = RETURNVALUE_CANNOTBEDRESSED;
					} else {
						ret = RETURNVALUE_NOERROR;
					}
				} else {
					if (item->getWeaponType() == WEAPON_NONE) {
						ret = RETURNVALUE_CANNOTBEDRESSED;
					} else {
						ret = RETURNVALUE_NOERROR;
					}
				}
			}
			break;
		}

		case CONST_SLOT_SPELL1: {
				if ((slotPosition & SLOTP_SPELL1) || (slotPosition & SLOTP_SPELL2) || (slotPosition & SLOTP_SPELL3) || (slotPosition & SLOTP_SPELL4)) {
						ret = RETURNVALUE_NOERROR;
				}
				break;
		}

		case CONST_SLOT_SPELL2: {
				if ((slotPosition & SLOTP_SPELL1) || (slotPosition & SLOTP_SPELL2) || (slotPosition & SLOTP_SPELL3) || (slotPosition & SLOTP_SPELL4)) {
						ret = RETURNVALUE_NOERROR;
				}
				break;
		}

		case CONST_SLOT_SPELL3: {
				if ((slotPosition & SLOTP_SPELL1) || (slotPosition & SLOTP_SPELL2) || (slotPosition & SLOTP_SPELL3) || (slotPosition & SLOTP_SPELL4)) {
						ret = RETURNVALUE_NOERROR;
				}
				break;
		}

		case CONST_SLOT_SPELL4: {
				if ((slotPosition & SLOTP_SPELL1) || (slotPosition & SLOTP_SPELL2) || (slotPosition & SLOTP_SPELL3) || (slotPosition & SLOTP_SPELL4)) {
						ret = RETURNVALUE_NOERROR;
				}
				break;
		}

		case CONST_SLOT_POTION1: {
				if ((slotPosition & SLOTP_POTION1)) {
						ret = RETURNVALUE_NOERROR;
				}
				break;
		}

		case CONST_SLOT_FORGE: {
				ret = RETURNVALUE_NOERROR;
				break;
		}

		case CONST_SLOT_SUPPORT1_1:
		case CONST_SLOT_SUPPORT1_2: 
		case CONST_SLOT_SUPPORT1_3:
		case CONST_SLOT_SUPPORT1_4:
		case CONST_SLOT_SUPPORT2_1:
		case CONST_SLOT_SUPPORT2_2:
		case CONST_SLOT_SUPPORT2_3:
		case CONST_SLOT_SUPPORT2_4:
		case CONST_SLOT_SUPPORT3_1:
		case CONST_SLOT_SUPPORT3_2:
		case CONST_SLOT_SUPPORT3_3:
		case CONST_SLOT_SUPPORT3_4:
		case CONST_SLOT_SUPPORT4_1:
		case CONST_SLOT_SUPPORT4_2:
		case CONST_SLOT_SUPPORT4_3:
		case CONST_SLOT_SUPPORT4_4:
		{
			if ((slotPosition & SLOTP_SUPPORT1_1)) {
				ret = RETURNVALUE_NOERROR;
			}
			break;
		}

		case CONST_SLOT_WHEREEVER:
		case -1:
			ret = RETURNVALUE_NOTENOUGHROOM;
			break;

		default:
			ret = RETURNVALUE_NOTPOSSIBLE;
			break;
	}


	if (ret != RETURNVALUE_NOERROR && ret != RETURNVALUE_NOTENOUGHROOM) {
		return ret;
	}

	//need an exchange with source?
	const Item* inventoryItem = getInventoryItem(static_cast<slots_t>(index));
	if (inventoryItem && (!inventoryItem->isStackable() || inventoryItem->getID() != item->getID())) {
		return RETURNVALUE_NEEDEXCHANGE;
	}

	if (!g_moveEvents->onPlayerEquip(const_cast<Player*>(this), const_cast<Item*>(item), static_cast<slots_t>(index), true)) {
		return RETURNVALUE_CANNOTBEDRESSED;
	}
	return ret;
}

ReturnValue Player::queryMaxCount(int32_t index, const Thing& thing, uint32_t count, uint32_t& maxQueryCount,
		uint32_t flags) const
{
	const Item* item = thing.getItem();
	if (item == nullptr) {
		maxQueryCount = 0;
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (index == INDEX_WHEREEVER) {
		uint32_t n = 0;
		for (int32_t slotIndex = CONST_SLOT_FIRST; slotIndex <= CONST_SLOT_LAST; ++slotIndex) {
			Item* inventoryItem = inventory[slotIndex];
			if (inventoryItem) {
				if (Container* subContainer = inventoryItem->getContainer()) {
					uint32_t queryCount = 0;
					subContainer->queryMaxCount(INDEX_WHEREEVER, *item, item->getItemCount(), queryCount, flags);
					n += queryCount;

					//iterate through all items, including sub-containers (deep search)
					for (ContainerIterator it = subContainer->iterator(); it.hasNext(); it.advance()) {
						if (Container* tmpContainer = (*it)->getContainer()) {
							queryCount = 0;
							tmpContainer->queryMaxCount(INDEX_WHEREEVER, *item, item->getItemCount(), queryCount, flags);
							n += queryCount;
						}
					}
				} else if (inventoryItem->isStackable() && item->equals(inventoryItem) && inventoryItem->getItemCount() < 9999) {
					uint32_t remainder = (9999 - inventoryItem->getItemCount());

					if (queryAdd(slotIndex, *item, remainder, flags) == RETURNVALUE_NOERROR) {
						n += remainder;
					}
				}
			} else if (queryAdd(slotIndex, *item, item->getItemCount(), flags) == RETURNVALUE_NOERROR) { //empty slot
				if (item->isStackable()) {
					n += 9999;
				} else {
					++n;
				}
			}
		}

		maxQueryCount = n;
	} else {
		const Item* destItem = nullptr;

		const Thing* destThing = getThing(index);
		if (destThing) {
			destItem = destThing->getItem();
		}

		if (destItem) {
			if (destItem->isStackable() && item->equals(destItem) && destItem->getItemCount() < 9999) {
				maxQueryCount = 9999 - destItem->getItemCount();
			} else {
				maxQueryCount = 0;
			}
		} else if (queryAdd(index, *item, count, flags) == RETURNVALUE_NOERROR) { //empty slot
			if (item->isStackable()) {
				maxQueryCount = 9999;
			} else {
				maxQueryCount = 1;
			}

			return RETURNVALUE_NOERROR;
		}
	}

	if (maxQueryCount < count) {
		return RETURNVALUE_NOTENOUGHROOM;
	} else {
		return RETURNVALUE_NOERROR;
	}
}

ReturnValue Player::queryRemove(const Thing& thing, uint32_t count, uint32_t flags, Creature* /*= nullptr */) const
{
	int32_t index = getThingIndex(&thing);
	if (index == -1) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	const Item* item = thing.getItem();
	if (item == nullptr) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (count == 0 || (item->isStackable() && count > item->getItemCount())) {
		return RETURNVALUE_NOTPOSSIBLE;
	}

	if (!item->isMoveable() && !hasBitSet(FLAG_IGNORENOTMOVEABLE, flags)) {
		return RETURNVALUE_NOTMOVEABLE;
	}

	return RETURNVALUE_NOERROR;
}

Cylinder* Player::queryDestination(int32_t& index, const Thing& thing, Item** destItem,
		uint32_t& flags)
{
	if (index == 0 /*drop to capacity window*/ || index == INDEX_WHEREEVER) {
		*destItem = nullptr;

		const Item* item = thing.getItem();
		if (item == nullptr) {
			return this;
		}

		bool autoStack = !((flags & FLAG_IGNOREAUTOSTACK) == FLAG_IGNOREAUTOSTACK);
		bool isStackable = item->isStackable();

		std::vector<Container*> containers;
		containers.reserve(32);

		Item* inventoryItem = inventory[CONST_SLOT_BACKPACK];
		if (inventoryItem && inventoryItem != item) {
			if (autoStack && isStackable) {
				//try find an already existing item to stack with
				if (queryAdd(CONST_SLOT_BACKPACK, *item, item->getItemCount(), 0) == RETURNVALUE_NOERROR) {
					if (inventoryItem->equals(item) && inventoryItem->getItemCount() < 9999) {
						index = CONST_SLOT_BACKPACK;
						*destItem = inventoryItem;
						return this;
					}
				}

				if (Container* subContainer = inventoryItem->getContainer()) {
					containers.push_back(subContainer);
				}
			} else if (Container* subContainer = inventoryItem->getContainer()) {
				containers.push_back(subContainer);
			}
		} else if (queryAdd(CONST_SLOT_BACKPACK, *item, item->getItemCount(), flags) == RETURNVALUE_NOERROR) { //empty slot
			index = CONST_SLOT_BACKPACK;
			*destItem = nullptr;
			return this;
		}

		size_t i = static_cast<size_t>(-1);
		while (++i < containers.size()) {
			Container* tmpContainer = containers[i];
			if (!autoStack || !isStackable) {
				//we need to find first empty container as fast as we can for non-stackable items
				uint32_t c = tmpContainer->capacity();
				uint32_t n = c - tmpContainer->size();
				while (--n < c) {
					int32_t testIndex = c - n - 1;
					if (tmpContainer->queryAdd(testIndex, *item, item->getItemCount(), flags) == RETURNVALUE_NOERROR) {
						index = testIndex;
						*destItem = nullptr;
						return tmpContainer;
					}
				}

				for (Item* tmpContainerItem : tmpContainer->getItemList()) {
					if (Container* subContainer = tmpContainerItem->getContainer()) {
						containers.push_back(subContainer);
					}
				}

				continue;
			}

			uint32_t n = 0;
			for (Item* tmpItem : tmpContainer->getItemList()) {
				if (tmpItem == item) {
					continue;
				}

				//try find an already existing item to stack with
				if (tmpItem->equals(item) && tmpItem->getItemCount() < 9999) {
					index = n;
					*destItem = tmpItem;
					return tmpContainer;
				}

				if (Container* subContainer = tmpItem->getContainer()) {
					containers.push_back(subContainer);
				}
				++n;
			}

			if (n < tmpContainer->capacity() && tmpContainer->queryAdd(n, *item, item->getItemCount(), flags) == RETURNVALUE_NOERROR) {
				index = n;
				*destItem = nullptr;
				return tmpContainer;
			}
		}

		return this;
	}

	Thing* destThing = getThing(index);
	if (destThing) {
		*destItem = destThing->getItem();
	}

	Cylinder* subCylinder = dynamic_cast<Cylinder*>(destThing);
	if (subCylinder) {
		index = INDEX_WHEREEVER;
		*destItem = nullptr;
		return subCylinder;
	} else {
		return this;
	}
}

void Player::addThing(int32_t index, Thing* thing)
{
	if (index < CONST_SLOT_FIRST || index > CONST_SLOT_LAST) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	Item* item = thing->getItem();
	if (!item) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	item->setParent(this);
	inventory[index] = item;

	//send to client
	sendInventoryItem(static_cast<slots_t>(index), item);
}

void Player::updateThing(Thing* thing, uint16_t itemId, uint32_t count)
{
	int32_t index = getThingIndex(thing);
	if (index == -1) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	Item* item = thing->getItem();
	if (!item) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	item->setID(itemId);
	item->setSubType(count);

	//send to client
	sendInventoryItem(static_cast<slots_t>(index), item);
}

void Player::replaceThing(uint32_t index, Thing* thing)
{
	if (index > CONST_SLOT_LAST) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	Item* oldItem = getInventoryItem(static_cast<slots_t>(index));
	if (!oldItem) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	Item* item = thing->getItem();
	if (!item) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	//send to client
	sendInventoryItem(static_cast<slots_t>(index), item);

	item->setParent(this);
	inventory[index] = item;
}

void Player::removeThing(Thing* thing, uint32_t count)
{
	Item* item = thing->getItem();
	if (!item) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	int32_t index = getThingIndex(thing);
	if (index == -1) {
		return /*RETURNVALUE_NOTPOSSIBLE*/;
	}

	if (item->isStackable()) {
		if (count == item->getItemCount()) {
			//send change to client
			sendInventoryItem(static_cast<slots_t>(index), nullptr);

			item->setParent(nullptr);
			inventory[index] = nullptr;
		} else {
			uint16_t newCount = static_cast<uint16_t>(std::max<int32_t>(0, item->getItemCount() - count));
			item->setItemCount(newCount);

			//send change to client
			sendInventoryItem(static_cast<slots_t>(index), item);
		}
	} else {
		//send change to client
		sendInventoryItem(static_cast<slots_t>(index), nullptr);

		item->setParent(nullptr);
		inventory[index] = nullptr;
	}
}

int32_t Player::getThingIndex(const Thing* thing) const
{
	for (int i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; ++i) {
		if (inventory[i] == thing) {
			return i;
		}
	}
	return -1;
}

size_t Player::getFirstIndex() const
{
	return CONST_SLOT_FIRST;
}

size_t Player::getLastIndex() const
{
	return CONST_SLOT_LAST + 1;
}

uint32_t Player::getItemTypeCount(uint16_t itemId, int32_t subType /*= -1*/, bool ignoreEquipped /*= false*/) const
{
	uint32_t count = 0;
	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; i++) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		if (!ignoreEquipped && item->getID() == itemId) {
			count += Item::countByType(item, subType);
		}
		
		if (Container* container = item->getContainer()) {
			for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
				if ((*it)->getID() == itemId) {
					count += Item::countByType(*it, subType);
				}
			}
		}
	}
	return count;
}

bool Player::removeItemOfType(uint16_t itemId, uint32_t amount, int32_t subType, bool ignoreEquipped/* = false*/) const
{
	if (amount == 0) {
		return true;
	}

	std::vector<Item*> itemList;
	itemList.reserve(32);

	uint32_t count = 0;
	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; i++) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		if (!ignoreEquipped && item->getID() == itemId) {
			uint32_t itemCount = Item::countByType(item, subType);
			if (itemCount == 0) {
				continue;
			}

			itemList.push_back(item);

			count += itemCount;
			if (count >= amount) {
				g_game.internalRemoveItems(itemList, amount, Item::items[itemId].stackable);
				return true;
			}
		} else if (Container* container = item->getContainer()) {
			for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
				Item* containerItem = *it;
				if (containerItem->getID() == itemId) {
					uint32_t itemCount = Item::countByType(containerItem, subType);
					if (itemCount == 0) {
						continue;
					}

					itemList.push_back(containerItem);

					count += itemCount;
					if (count >= amount) {
						g_game.internalRemoveItems(itemList, amount, Item::items[itemId].stackable);
						return true;
					}
				}
			}
		}
	}
	return false;
}

std::map<uint32_t, uint32_t>& Player::getAllItemTypeCount(std::map<uint32_t, uint32_t>& countMap) const
{
	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; i++) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		countMap[item->getID()] += Item::countByType(item, -1);

		if (Container* container = item->getContainer()) {
			for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
				countMap[(*it)->getID()] += Item::countByType(*it, -1);
			}
		}
	}
	return countMap;
}

void Player::getAllItemTypeCountAndSubtype(std::map<uint64_t, PlayerInventorySellItem>& uniqueMap, std::map<uint32_t, uint16_t>& stackMap) const
{
	Item* item = nullptr;
	
	if (filterCategoryIndex == 1) {
		Item* storeInbox = inventory[CONST_SLOT_STORE_INBOX];
		if (!storeInbox) {
			return;
		}
		
		Container* storeInboxContainer = storeInbox->getContainer();
		if (!storeInboxContainer) {
			return;
		}
		
		item = storeInboxContainer->getItemById(38390);
		if (!item) {
			return;
		}
	} else {
		item = inventory[CONST_SLOT_BACKPACK];
		if (!item) {
			return;
		}
	}

	// Temporary storage for filterCategoryIndex == 1 logic
	std::map<uint32_t, std::map<uint8_t, std::vector<std::pair<uint64_t, Item*>>>> itemRarityMap;

	uint16_t maxIndex = 100;
	uint16_t index = 0;
	uint16_t completeSets = 0;
	const uint16_t maxCompleteSets = 16; // For filterCategoryIndex == 1
	
	if (Container* container = item->getContainer()) {
		for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
			// For filterCategoryIndex == 1, check if we have enough complete sets
			if (filterCategoryIndex == 1 && completeSets >= maxCompleteSets) {
				break;
			}
			
			if (filterCategoryIndex != 1 && index >= maxIndex)
				break;
				
			Item* itemx = (*it);
			if (itemx->isStackable() || itemx->getContainer()) {
				continue;
			}

			uint16_t itemId = itemx->getID();
			auto locked = itemx->getCustomAttribute("locked");
			if (locked && locked->getInt() == 1) {
				continue;
			}

			if (filterItemType != 0 && itemx->formatItemType() != filterItemType) {
				continue;
			}

			auto rarity = itemx->getCustomAttribute("rarity");
			uint8_t rarityId = rarity ? rarity->getInt() : itemx->getColor();
			if (rarityId == 8) {
				continue;
			}

			if (filterCategoryIndex == 1 && rarityId > 3) {
				continue;
			}

			if (filterRarity != 0) {
				if (filterRarity == 7) {
					if (rarityId != 5) {
						continue;
					}
				} else {

					if (rarityId == 5) {
						continue;
					}

					uint8_t maxRarity = (filterRarity == 6) ? 6 : (filterRarity - 1);
					if (rarityId > maxRarity) {
						continue;
					}
				}
			}			

			if (!filterName.empty()) {
				std::string loweredFilter   = asLowerCaseString(filterName);
				std::string loweredItemName = asLowerCaseString(itemx->getName());
			
				if (loweredItemName.find(loweredFilter) == std::string::npos) {
					continue;
				}
			}

			uint64_t uniqueId = itemx->getRealUID();
			if (uniqueId == 0) {
				stackMap[itemId] += itemx->getItemCount();
			} else {
				if (filterCategoryIndex == 1) {
					// Store items temporarily to check for 3 items with same itemId and rarity
					itemRarityMap[itemId][rarityId].push_back({uniqueId, itemx});
					
					// Check if we just completed a set of 3
					if (itemRarityMap[itemId][rarityId].size() % 3 == 0) {
						completeSets++;
					}
				} else {
					uniqueMap[uniqueId].itemId = itemId;
					uniqueMap[uniqueId].rarity = rarityId;
				}
			}
			++index;
		}
	}

	if (filterCategoryIndex == 1) {
		for (const auto& itemPair : itemRarityMap) {
			for (const auto& rarityPair : itemPair.second) {
				size_t count = rarityPair.second.size();
				size_t setsOfThree = count / 3;
				if (setsOfThree > 0) {
					for (size_t i = 0; i < setsOfThree * 3; ++i) {
						uint64_t uniqueId = rarityPair.second[i].first;
						uniqueMap[uniqueId].itemId = itemPair.first;
						uniqueMap[uniqueId].rarity = rarityPair.first;
					}
				}
			}
		}
	}
}

Thing* Player::getThing(size_t index) const
{
	if (isRemoved()) {
		return nullptr;
	}

	if (index >= CONST_SLOT_FIRST && index <= CONST_SLOT_LAST) {
		return inventory[index];
	}
	return nullptr;
}

void Player::postAddNotification(Thing* thing, const Cylinder* oldParent, int32_t index, cylinderlink_t link /*= LINK_OWNER*/)
{
	if (link == LINK_OWNER) {
		//calling movement scripts
		g_moveEvents->onPlayerEquip(this, thing->getItem(), static_cast<slots_t>(index), false);
		g_events->eventPlayerOnInventoryUpdate(this, thing->getItem(), static_cast<slots_t>(index), true);
	}

	bool requireListUpdate = false;

	if (link == LINK_OWNER || link == LINK_TOPPARENT) {
		const Item* i = (oldParent ? oldParent->getItem() : nullptr);

		// Check if we owned the old container too, so we don't need to do anything,
		// as the list was updated in postRemoveNotification
		assert(i ? i->getContainer() != nullptr : true);

		if (i) {
			requireListUpdate = i->getContainer()->getHoldingPlayer() != this;
		} else {
			requireListUpdate = oldParent != this;
		}

		addScheduledUpdates((PlayerUpdate_Light));
		sendStats(1);
		sendStats(2);
		sendStats(3);
		sendStats(4);
	}

	if (const Item* item = thing->getItem()) {
		if (const Container* container = item->getContainer()) {
			onSendContainer(container);
		}

		if (requireListUpdate) {
			if (shopOwner) {
				updateSaleShopList(item);
			}
		}
	} else if (const Creature* creature = thing->getCreature()) {
		if (creature == this) {
			//check containers
			std::vector<Container*> containers;
			containers.reserve(openContainers.size());

			for (const auto& it : openContainers) {
				Container* container = it.second.container;
				if (!Position::areInRange<1, 1, 0>(container->getPosition(), getPosition())) {
					containers.push_back(container);
				}
			}

			for (const Container* container : containers) {
				autoCloseContainers(container);
			}
		}
	}
}

void Player::postRemoveNotification(Thing* thing, const Cylinder* newParent, int32_t index, cylinderlink_t link /*= LINK_OWNER*/)
{
	if (link == LINK_OWNER) {
		//calling movement scripts
		g_moveEvents->onPlayerDeEquip(this, thing->getItem(), static_cast<slots_t>(index));
		g_events->eventPlayerOnInventoryUpdate(this, thing->getItem(), static_cast<slots_t>(index), false);
	}

	bool requireListUpdate = false;

	if (link == LINK_OWNER || link == LINK_TOPPARENT) {
		const Item* i = (newParent ? newParent->getItem() : nullptr);

		// Check if we owned the old container too, so we don't need to do anything,
		// as the list was updated in postRemoveNotification
		assert(i ? i->getContainer() != nullptr : true);

		if (i) {
			requireListUpdate = i->getContainer()->getHoldingPlayer() != this;
		} else {
			requireListUpdate = newParent != this;
		}
	}

	if (const Item* item = thing->getItem()) {
		if (const Container* container = item->getContainer()) {
			if (container->isRemoved() || !Position::areInRange<1, 1, 0>(getPosition(), container->getPosition())) {
				autoCloseContainers(container);
			} else if (container->getTopParent() == this) {
				onSendContainer(container);
			} else if (const Container* topContainer = dynamic_cast<const Container*>(container->getTopParent())) {
				if (const DepotChest* depotChest = dynamic_cast<const DepotChest*>(topContainer)) {
					bool isOwner = false;

					for (const auto& it : depotChests) {
						if (it.second == depotChest) {
							isOwner = true;
							onSendContainer(container);
						}
					}

					if (!isOwner) {
						autoCloseContainers(container);
					}
				} else {
					onSendContainer(container);
				}
			} else {
				autoCloseContainers(container);
			}
		}

		if (requireListUpdate) {
			if (shopOwner) {
				updateSaleShopList(item);
			}
		}
	}
}

bool Player::updateSaleShopList(const Item* item)
{
	uint16_t itemId = item->getID();
	if (itemId != ITEM_GOLD_COIN && itemId != ITEM_PLATINUM_COIN && itemId != ITEM_CRYSTAL_COIN) {
		auto it = std::find_if(shopItemList.begin(), shopItemList.end(), [itemId](const ShopInfo& shopInfo) { return shopInfo.itemId == itemId && shopInfo.sellPrice != 0; });
		if (it == shopItemList.end()) {
			const Container* container = item->getContainer();
			if (!container) {
				return false;
			}

			const auto& items = container->getItemList();
			return std::any_of(items.begin(), items.end(), [this](const Item* containerItem) {
				return updateSaleShopList(containerItem);
			});
		}
	}

	return true;
}

bool Player::hasShopItemForSale(uint32_t itemId, uint8_t subType) const
{
	const ItemType& itemType = Item::items[itemId];
	return std::any_of(shopItemList.begin(), shopItemList.end(), [&](const ShopInfo& shopInfo) {
		return shopInfo.itemId == itemId && shopInfo.buyPrice != 0;
	});
}

bool Player::hasShopItemForBuy(uint32_t itemId) const
{
	const ItemType& itemType = Item::items[itemId];
	return std::any_of(shopItemList.begin(), shopItemList.end(), [&](const ShopInfo& shopInfo) {
		return shopInfo.itemId == itemId && shopInfo.sellPrice != 0;
	});

}

void Player::internalAddThing(Thing* thing)
{
	internalAddThing(0, thing);
}

void Player::internalAddThing(uint32_t index, Thing* thing)
{
	Item* item = thing->getItem();
	if (!item) {
		return;
	}

	//index == 0 means we should equip this item at the most appropiate slot (no action required here)
	if (index >= 1 && index <= CONST_SLOT_LAST + 1) {

		if (inventory[index]) {
			return;
		}

		inventory[index] = item;
		item->setParent(this);
	}
}

bool Player::setFollowCreature(Creature* creature)
{
	if (!Creature::setFollowCreature(creature)) {
		setFollowCreature(nullptr);
		setAttackedCreature(nullptr);

		sendCancelMessage(RETURNVALUE_THEREISNOWAY);
		sendCancelTarget();
		stopWalk();
		return false;
	}
	return true;
}

bool Player::setAttackedCreature(Creature* creature)
{
	if (!Creature::setAttackedCreature(creature)) {
		sendCancelTarget();
		return false;
	}

	if (chaseMode && creature) {
		if (followCreature != creature) {
			//chase opponent
			setFollowCreature(creature);
		}
	} else if (followCreature) {
		setFollowCreature(nullptr);
	}

	if (creature) {
		g_dispatcher.addTask(std::bind(&Game::checkCreatureAttack, &g_game, getID()));
	}
	return true;
}

void Player::goToFollowCreature()
{
	if (!walkTask) {
		if ((OTSYS_TIME() - lastFailedFollow) < 2000) {
			return;
		}

		Creature::goToFollowCreature();

		if (followCreature && !hasFollowPath) {
			lastFailedFollow = OTSYS_TIME();
		}
	}
}

void Player::getPathSearchParams(const Creature* creature, FindPathParams& fpp) const
{
	Creature::getPathSearchParams(creature, fpp);
	fpp.fullPathSearch = true;
}

void Player::doAttacking(uint32_t)
{
	if (lastAttack == 0) {
		lastAttack = OTSYS_TIME() - getAttackSpeed() - 1;
	}

	if (hasCondition(CONDITION_PACIFIED)) {
		return;
	}
	
	if (hasCondition(CONDITION_STUN)) {
    sendCancelTarget(); // might need to add a 0 inbetween the brackets if you use older TFS build
    return;
	}

	if ((OTSYS_TIME() - lastAttack) >= getAttackSpeed()) {
		bool result = false;
		bool result2 = false;
		const Weapon* weapon = nullptr;
		const Weapon* weapon2 = nullptr;
		Item* tool1 = getInventoryItem(CONST_SLOT_LEFT);
		if (tool1) {
			weapon = g_weapons->getWeapon(tool1);
		}
		Item* tool2 = getInventoryItem(CONST_SLOT_RIGHT);
		if (tool2) {
			weapon2 = g_weapons->getWeapon(tool2);
		}

		uint32_t delay = getAttackSpeed();
		bool classicSpeed = g_config.getBoolean(ConfigManager::CLASSIC_ATTACK_SPEED);

		if (weapon) {
			result = weapon->useWeapon(this, tool1, attackedCreature);
		} else {
			if (!weapon2) {
				result = Weapon::useFist(this, attackedCreature);
			}
		}

		if (weapon2) {
			result2 = weapon2->useWeapon(this, tool2, attackedCreature);
		}

		g_dispatcher.addEvent(std::max<uint32_t>(SERVER_BEAT_MILISECONDS, delay), std::bind(&Game::checkCreatureAttack, &g_game, getID()));

		if (result || result2) {
			lastAttack = OTSYS_TIME();
		}
	}
}

uint64_t Player::getGainedExperience(Creature* attacker) const
{
	if (g_config.getBoolean(ConfigManager::EXPERIENCE_FROM_PLAYERS)) {
		Player* attackerPlayer = attacker->getPlayer();
		if (attackerPlayer && attackerPlayer != this && skillLoss && std::abs(static_cast<int32_t>(attackerPlayer->getLevel() - level)) <= g_config.getNumber(ConfigManager::EXP_FROM_PLAYERS_LEVEL_RANGE)) {
			return std::max<uint64_t>(0, std::floor(getLostExperience() * 100));
		}
	}
	return 0;
}

void Player::onFollowCreature(const Creature* creature)
{
	if (!creature) {
		stopWalk();
	}
}

void Player::setChaseMode(bool mode)
{
	bool prevChaseMode = chaseMode;
	chaseMode = mode;

	if (prevChaseMode != chaseMode) {
		if (chaseMode) {
			if (!followCreature && attackedCreature) {
				//chase opponent
				setFollowCreature(attackedCreature);
			}
		} else if (attackedCreature) {
			setFollowCreature(nullptr);
			cancelNextWalk = true;
		}
	}
}

void Player::onWalkAborted()
{
	stopNextWalkActionTask();
	sendCancelWalk();
	sendNewCancelWalk();
}

void Player::onWalkComplete()
{
	if (walkTask) {
		walkTaskEvent = g_dispatcher.addEvent(walkTask->first, std::move(walkTask->second));
		walkTask = nullptr;
	}
}

void Player::stopWalk()
{
	cancelNextWalk = true;
}

LightInfo Player::getCreatureLight() const
{
	if (internalLight.level > itemsLight.level) {
		return internalLight;
	}
	return itemsLight;
}

void Player::updateItemsLight(bool internal /*=false*/)
{
	LightInfo maxLight;

	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; ++i) {
		Item* item = inventory[i];
		if (item) {
			LightInfo curLight = item->getLightInfo();

			if (curLight.level > maxLight.level) {
				maxLight = std::move(curLight);
			}
		}
	}

	if (itemsLight.level != maxLight.level || itemsLight.color != maxLight.color) {
		itemsLight = maxLight;

		if (!internal) {
			g_game.changeLight(this);
		}
	}
}

void Player::onAddCondition(ConditionType_t type)
{
	Creature::onAddCondition(type);

	#if GAME_FEATURE_MOUNTS > 0
	//if (type == CONDITION_OUTFIT && isMounted()) {
	if (type == CONDITION_OUTFIT) {
		dismount();
	}
	#endif

	sendIcons();
}

void Player::onAddCombatCondition(ConditionType_t type)
{
	switch (type) {
		case CONDITION_POISON:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are poisoned.");
			break;

		case CONDITION_DROWN:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are drowning.");
			break;

		case CONDITION_PARALYZE:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are paralyzed.");
			break;

		case CONDITION_DRUNK:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are drunk.");
			break;

		case CONDITION_CURSED:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are cursed.");
			break;

		case CONDITION_FREEZING:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are freezing.");
			break;

		case CONDITION_DAZZLED:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are dazzled.");
			break;

		case CONDITION_BLEEDING:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are bleeding.");
			break;
			
		case CONDITION_STUN:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You have been stunned.");
			break;
		
		case CONDITION_HARD_DRUNK:
			sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are scared.");
			break;

		default:
			break;
	}
}

void Player::onEndCondition(ConditionType_t type)
{
	Creature::onEndCondition(type);

	if (type == CONDITION_INFIGHT) {
		onIdleStatus();
		pzLocked = false;
		clearAttacked();

		if (getSkull() != SKULL_RED && getSkull() != SKULL_BLACK) {
			setSkull(SKULL_NONE);
		}
	}

	sendIcons();
}

void Player::onCombatRemoveCondition(Condition* condition)
{
	//Creature::onCombatRemoveCondition(condition);
	if (condition->getId() > 0) {
		//Means the condition is from an item, id == slot
		if (g_game.getWorldType() == WORLD_TYPE_PVP_ENFORCED) {
			Item* item = getInventoryItem(static_cast<slots_t>(condition->getId()));
			if (item) {
				//25% chance to destroy the item
				if (25 >= uniform_random(1, 100)) {
					g_game.internalRemoveItem(item);
				}
			}
		}
	} else {
		if (!canDoAction()) {
			const uint32_t delay = getNextActionTime();
			const int32_t ticks = delay - (delay % EVENT_CREATURE_THINK_INTERVAL);
			if (ticks < 0) {
				removeCondition(condition);
			} else {
				condition->setTicks(ticks);
			}
		} else {
			removeCondition(condition);
		}
	}
}

void Player::onAttackedCreature(Creature* target)
{
	Creature::onAttackedCreature(target);

	if (target->getZone() == ZONE_PVP) {
		return;
	}

	if (target == this) {
		addInFightTicks();
		return;
	}

	if (hasFlag(PlayerFlag_NotGainInFight)) {
		return;
	}

	Player* targetPlayer = target->getPlayer();
	if (targetPlayer && !isPartner(targetPlayer) && !isGuildMate(targetPlayer)) {
		if (!pzLocked) {
			pzLocked = true;
			sendIcons();
		}
		addAttacked(targetPlayer);
	}

	addInFightTicks();
}

void Player::onAttacked()
{
	Creature::onAttacked();

	addInFightTicks();
}

void Player::onIdleStatus()
{
	Creature::onIdleStatus();

	if (party) {
		party->clearPlayerPoints(this);
	}
}

void Player::onPlacedCreature()
{
	std::string playerName = getName();
    std::string logFile = "logs/players/" + playerName + ".log";
    
    try {
        playerLogger = spdlog::rotating_logger_mt("player_" + playerName, logFile, 1024 * 1024 * 5, 5);
        playerLogger->set_pattern("[%Y-%m-%d %H:%M:%S] [%l] %v");
        playerLogger->info("[SERVER] logged in");
    } catch (const spdlog::spdlog_ex& ex) {
        std::cerr << "Failed to initialize logger for player: " << ex.what() << std::endl;
    }

	//scripting event - onLogin
	
	if (!g_creatureEvents->playerLogin(this)) {
		kickPlayer(true);
	}

	sendPlayerGold(getBankBalance());
}

void Player::onAttackedCreatureDrainHealth(Creature* target, int64_t points)
{
	Creature::onAttackedCreatureDrainHealth(target, points);

	if (target) {
		if (party && !Combat::isPlayerCombat(target)) {
			Monster* tmpMonster = target->getMonster();
			if (tmpMonster && tmpMonster->isHostile()) {
				//We have fulfilled a requirement for shared experience
				party->updatePlayerTicks(this, points);
			}
		}
	}
}

void Player::onTargetCreatureGainHealth(Creature* target, int64_t points)
{
	if (target && party) {
		Player* tmpPlayer = nullptr;

		if (target->getPlayer()) {
			tmpPlayer = target->getPlayer();
		} else if (Creature* targetMaster = target->getMaster()) {
			if (Player* targetMasterPlayer = targetMaster->getPlayer()) {
				tmpPlayer = targetMasterPlayer;
			}
		}

		if (isPartner(tmpPlayer)) {
			party->updatePlayerTicks(this, points);
		}
	}
}

bool Player::onKilledCreature(Creature* target, bool lastHit/* = true*/)
{
	bool unjustified = false;

	if (hasFlag(PlayerFlag_NotGenerateLoot)) {
		target->setDropLoot(false);
	}

	Creature::onKilledCreature(target, lastHit);

	Player* targetPlayer = target->getPlayer();
	if (!targetPlayer) {
		return false;
	}

	if (targetPlayer->getZone() == ZONE_PVP) {
		targetPlayer->setDropLoot(false);
		targetPlayer->setSkillLoss(false);
	}

	return false;
}

void Player::gainExperience(uint64_t gainExp, Creature* source)
{
	if (hasFlag(PlayerFlag_NotGainExperience) || gainExp == 0 || staminaMinutes == 0) {
		return;
	}

	addExperience(source, gainExp, true);
}

void Player::onGainExperience(uint64_t gainExp, Creature* target)
{
	if (hasFlag(PlayerFlag_NotGainExperience)) {
		return;
	}

	if (target && !target->getPlayer() && party && party->isSharedExperienceActive() && party->isSharedExperienceEnabled()) {
		party->shareExperience(gainExp, target);
		//We will get a share of the experience through the sharing mechanism
		return;
	}

	Creature::onGainExperience(gainExp, target);
	gainExperience(gainExp, target);
}

void Player::onGainSharedExperience(uint64_t gainExp, Creature* source)
{
	gainExperience(gainExp, source);
}

bool Player::isImmune(CombatType_t type) const
{
	if (hasFlag(PlayerFlag_CannotBeAttacked)) {
		return true;
	}
	return Creature::isImmune(type);
}

bool Player::isImmune(ConditionType_t type) const
{
	if (hasFlag(PlayerFlag_CannotBeAttacked)) {
		return true;
	}
	return Creature::isImmune(type);
}

bool Player::isAttackable() const
{
	return !isInGhostMode();
}

bool Player::lastHitIsPlayer(Creature* lastHitCreature)
{
	if (!lastHitCreature) {
		return false;
	}

	if (lastHitCreature->getPlayer()) {
		return true;
	}

	Creature* lastHitMaster = lastHitCreature->getMaster();
	return lastHitMaster && lastHitMaster->getPlayer();
}

void Player::changeHealth(int64_t healthChange, bool sendHealthChange/* = true*/)
{
	Creature::changeHealth(healthChange, sendHealthChange);
	sendStats(1);
}

void Player::changeEnergyShield(int64_t energyShieldChange, bool sendHealthChange/* = true*/)
{
	Creature::changeEnergyShield(energyShieldChange, sendHealthChange);
	sendStats(2);
}

void Player::changeMana(int64_t manaChange)
{
	if (manaChange == 0) {
		return;
	}

	if (!hasFlag(PlayerFlag_HasInfiniteMana)) {
		if (manaChange > 0) {
			mana += std::min<int64_t>(manaChange, getMaxMana() - mana);
		} else {
			mana = std::max<int64_t>(0, mana + manaChange);
		}
	}

	#if GAME_FEATURE_PARTY_LIST > 0
	g_game.addPlayerMana(this);
	#endif
	sendStats(4);
}

void Player::changeSoul(int32_t soulChange)
{
	if (soulChange > 0) {
		soul += std::min<int32_t>(soulChange, vocation->getSoulMax() - soul);
	} else {
		soul = std::max<int32_t>(0, soul + soulChange);
	}
}


bool Player::hasOutfit(uint16_t looktype, uint8_t addon) const
{
	if (group->access) {
		return true;
	}
	
	int32_t value;
	if (!getAccountStorageValue(PSTRG_OUTFITS_RANGE_START + (looktype*2), value)) {
		return false;
	}

	int32_t valueAddon;
	if (!getAccountStorageValue(PSTRG_OUTFITS_RANGE_START + (looktype*2 - 1), valueAddon)) {
		return false;
	}

	return value == 1;
}


bool Player::canWear(uint32_t lookType, uint8_t addons) const
{
	if (group->access) {
		return true;
	}

	const Outfit* outfit = Outfits::getInstance().getOutfitByLookType(getSex(), lookType);
	if (!outfit) {
		return false;
	}

	uint8_t outfitAddons;
	if (getOutfitAddons(*outfit, outfitAddons)) {
		return (outfitAddons & addons) == addons;
	}

	return false;
}

bool Player::canLogout()
{
	if (isConnecting) {
		return false;
	}

	if (getTile()->hasFlag(TILESTATE_NOLOGOUT)) {
		return false;
	}

	if (getTile()->hasFlag(TILESTATE_PROTECTIONZONE)) {
		return true;
	}

	return !isPzLocked() && !hasCondition(CONDITION_INFIGHT);
}

bool Player::addOutfit(uint16_t lookType, uint8_t addons)
{
	const Outfit* outfit = Outfits::getInstance().getOutfitByLookType(getSex(), lookType);
	const Outfit* outfit2 = Outfits::getInstance().getOutfitByLookType(getSex() == PLAYERSEX_MALE ? PLAYERSEX_FEMALE : PLAYERSEX_MALE, lookType);
	if (!outfit && !outfit2) {
		return false;
	}

	setAccountStorageValue(PSTRG_OUTFITS_RANGE_START + (lookType*2), 1);
	setAccountStorageValue(PSTRG_OUTFITS_RANGE_START + (lookType*2 - 1), addons);
	return true;
}

bool Player::getOutfitAddons(const Outfit& outfit, uint8_t& addons) const
{
	if (isAccessPlayer()) {
		addons = 3;
		return true;
	}

	if (outfit.free) {
		addons = 3;
		return true;
	}

	if (outfit.vocation == translate_vocations[getVocationId()]) {
		addons = 3;
		return true;
	}

	int32_t value;
	if (!getAccountStorageValue(PSTRG_OUTFITS_RANGE_START + (outfit.lookType*2), value)) {
		return false;
	}

	if (value != 1) {
		return false;
	}
	
	int32_t addonsValue;
	if (!getAccountStorageValue(PSTRG_OUTFITS_RANGE_START + (outfit.lookType*2 - 1), addonsValue)) {
		return false;
	}

	addons = static_cast<uint8_t>(addonsValue);
	return true;
}

void Player::setSex(PlayerSex_t newSex)
{
	sex = newSex;
}

Skulls_t Player::getSkull() const
{
	return SKULL_NONE;
}

Skulls_t Player::getSkullClient(const Creature* creature) const
{
	const Player* player = creature->getPlayer();
	if (!player) {
		return Creature::getSkullClient(creature);
	}

	if (isPartner(player)) {
		return SKULL_GREEN;
	}
	return SKULL_NONE;
}

bool Player::hasAttacked(const Player* attacked) const
{
	if (hasFlag(PlayerFlag_NotGainInFight) || !attacked) {
		return false;
	}

	return attackedSet.find(attacked->guid) != attackedSet.end();
}

void Player::addAttacked(const Player* attacked)
{
	if (hasFlag(PlayerFlag_NotGainInFight) || !attacked || attacked == this) {
		return;
	}

	attackedSet.insert(attacked->guid);
}

void Player::removeAttacked(const Player* attacked)
{
	if (!attacked || attacked == this) {
		return;
	}

	auto it = attackedSet.find(attacked->guid);
	if (it != attackedSet.end()) {
		attackedSet.erase(it);
	}
}

void Player::clearAttacked()
{
	attackedSet.clear();
}

void Player::addUnjustifiedDead(const Player*)
{
	return;
}

void Player::checkSkullTicks(int64_t ticks)
{
	int64_t newTicks = skullTicks - ticks;
	if (newTicks < 0) {
		skullTicks = 0;
	} else {
		skullTicks = newTicks;
	}

	if ((skull == SKULL_RED || skull == SKULL_BLACK) && skullTicks < 1 && !hasCondition(CONDITION_INFIGHT)) {
		setSkull(SKULL_NONE);
	}
}

bool Player::isPromoted() const
{
	uint16_t promotedVocation = g_vocations.getPromotedVocation(vocation->getId());
	return promotedVocation == VOCATION_NONE && vocation->getId() != promotedVocation;
}

double Player::getLostPercent() const
{
	int32_t blessingCount = std::bitset<5>(blessings).count();
	int32_t deathLosePercent = g_config.getNumber(ConfigManager::DEATH_LOSE_PERCENT);
	if (deathLosePercent != -1) {
		if (isPromoted()) {
			deathLosePercent -= 3;
		}

		deathLosePercent -= blessingCount;
		return std::max<int32_t>(0, deathLosePercent) / 100.;
	}

	double lossPercent;
	if (level >= 25) {
		double tmpLevel = level + (levelPercent / 100.);
		lossPercent = static_cast<double>((tmpLevel + 50) * 50 * ((tmpLevel * tmpLevel) - (5 * tmpLevel) + 8)) / experience;
	} else {
		lossPercent = 10;
	}

	double percentReduction = 0;
	if (isPromoted()) {
		percentReduction += 30;
		std::cout << "Promotion LossPercent " << lossPercent << std::endl;
	}
	percentReduction += blessingCount * 8;
	std::cout << "LossPercent " << lossPercent << std::endl;
	if (getSkull() == SKULL_RED || getSkull() == SKULL_BLACK) {
	 lossPercent *= 2;
	}
	return lossPercent * (1 - (percentReduction / 100.)) / 100.;
}

void Player::learnInstantSpell(const std::string& spellName)
{
	if (!hasLearnedInstantSpell(spellName)) {
		learnedInstantSpellList.emplace(asLowerCaseString(spellName));
	}
}

void Player::forgetInstantSpell(const std::string& spellName)
{
	learnedInstantSpellList.erase(asLowerCaseString(spellName));
}

bool Player::hasLearnedInstantSpell(const std::string& spellName) const
{
	if (hasFlag(PlayerFlag_CannotUseSpells)) {
		return false;
	}

	if (hasFlag(PlayerFlag_IgnoreSpellCheck)) {
		return true;
	}

	auto it = learnedInstantSpellList.find(asLowerCaseString(spellName));
	if (it != learnedInstantSpellList.end()) {
		return true;
	}
	return false;
}

bool Player::isInWar(const Player* player) const
{
	if (!player || !guild) {
		return false;
	}

	const Guild* playerGuild = player->getGuild();
	if (!playerGuild) {
		return false;
	}

	return isInWarList(playerGuild->getId()) && player->isInWarList(guild->getId());
}

bool Player::isInWarList(uint32_t guildId) const
{
	return std::find(guildWarVector.begin(), guildWarVector.end(), guildId) != guildWarVector.end();
}

bool Player::isPremium() const
{
	if (g_config.getBoolean(ConfigManager::FREE_PREMIUM) || hasFlag(PlayerFlag_IsAlwaysPremium)) {
		return true;
	}

	return premiumDays > 0;
}

void Player::setPremiumDays(int32_t v)
{
	premiumDays = v;
	#if CLIENT_VERSION >= 950
	sendBasicData();
	#endif
}

PartyShields_t Player::getPartyShield(const Player* player) const
{
	if (!player) {
		return SHIELD_NONE;
	}

	if (party) {
		if (party->getLeader() == player) {
			if (party->isSharedExperienceActive()) {
				if (party->isSharedExperienceEnabled()) {
					return SHIELD_YELLOW_SHAREDEXP;
				}

				if (party->canUseSharedExperience(player)) {
					return SHIELD_YELLOW_NOSHAREDEXP;
				}

				return SHIELD_YELLOW_NOSHAREDEXP_BLINK;
			}

			return SHIELD_YELLOW;
		}

		if (player->party == party) {
			if (party->isSharedExperienceActive()) {
				if (party->isSharedExperienceEnabled()) {
					return SHIELD_BLUE_SHAREDEXP;
				}

				if (party->canUseSharedExperience(player)) {
					return SHIELD_BLUE_NOSHAREDEXP;
				}

				return SHIELD_BLUE_NOSHAREDEXP_BLINK;
			}

			return SHIELD_BLUE;
		}

		if (isInviting(player)) {
			return SHIELD_WHITEBLUE;
		}
	}

	if (player->isInviting(this)) {
		return SHIELD_WHITEYELLOW;
	}

	#if CLIENT_VERSION >= 1000
	if (player->party) {
		return SHIELD_GRAY;
	}
	#endif

	return SHIELD_NONE;
}

bool Player::isInviting(const Player* player) const
{
	if (!player || !party || party->getLeader() != this) {
		return false;
	}
	return party->isPlayerInvited(player);
}

bool Player::isPartner(const Player* player) const
{
	if (!player || !party || player == this) {
		return false;
	}
	return party == player->party;
}

bool Player::isGuildMate(const Player* player) const
{
	if (!player || !guild) {
		return false;
	}
	return guild == player->guild;
}

void Player::sendPlayerPartyIcons(Player* player)
{
	sendCreatureShield(player);
	sendCreatureSkull(player);
}

bool Player::addPartyInvitation(Party* party)
{
	auto it = std::find(invitePartyList.begin(), invitePartyList.end(), party);
	if (it != invitePartyList.end()) {
		return false;
	}

	invitePartyList.push_back(party);
	return true;
}

void Player::removePartyInvitation(Party* party)
{
	auto it = std::find(invitePartyList.begin(), invitePartyList.end(), party);
	if (it != invitePartyList.end()) {
		invitePartyList.erase(it);
	}
}

void Player::clearPartyInvitations()
{
	for (Party* invitingParty : invitePartyList) {
		invitingParty->removeInvite(*this, false);
	}
	invitePartyList.clear();
}

GuildEmblems_t Player::getGuildEmblem(const Player* player) const
{
	if (!player) {
		return GUILDEMBLEM_NONE;
	}

	const Guild* playerGuild = player->getGuild();
	if (!playerGuild) {
		return GUILDEMBLEM_NONE;
	}

	if (player->getGuildWarVector().empty()) {
		#if CLIENT_VERSION >= 1000
		if (guild == playerGuild) {
			return GUILDEMBLEM_MEMBER;
		} else {
			return GUILDEMBLEM_OTHER;
		}
		#else
		return GUILDEMBLEM_NONE;
		#endif
	} else if (guild == playerGuild) {
		return GUILDEMBLEM_ALLY;
	} else if (isInWar(player)) {
		return GUILDEMBLEM_ENEMY;
	}

	return GUILDEMBLEM_NEUTRAL;
}

#if GAME_FEATURE_MOUNTS > 0
uint8_t Player::getCurrentMount() const
{
	int32_t value;
	if (getStorageValue(PSTRG_MOUNTS_CURRENTMOUNT, value)) {
		return value;
	}
	return 0;
}

void Player::setCurrentMount(uint8_t mountId)
{
	addStorageValue(PSTRG_MOUNTS_CURRENTMOUNT, mountId);
}

bool Player::toggleMount(bool mount)
{
	if ((OTSYS_TIME() - lastToggleMount) < 3000 && !wasMounted) {
		sendCancelMessage(RETURNVALUE_YOUAREEXHAUSTED);
		return false;
	}

	if (mount) {
		if (isMounted()) {
			return false;
		}

		if (!group->access && tile->hasFlag(TILESTATE_PROTECTIONZONE)) {
			sendCancelMessage(RETURNVALUE_ACTIONNOTPERMITTEDINPROTECTIONZONE);
			return false;
		}

		const Outfit* playerOutfit = Outfits::getInstance().getOutfitByLookType(getSex(), defaultOutfit.lookType);
		if (!playerOutfit) {
			return false;
		}

		uint8_t currentMountId = getCurrentMount();
		if (currentMountId == 0) {
			sendOutfitWindow();
			return false;
		}

		Mount* currentMount = g_game.mounts.getMountByID(currentMountId);
		if (!currentMount) {
			return false;
		}

		if (!hasMount(currentMount)) {
			setCurrentMount(0);
			sendOutfitWindow();
			return false;
		}

		if (currentMount->premium && !isPremium()) {
			sendCancelMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT);
			return false;
		}

		if (hasCondition(CONDITION_OUTFIT)) {
			sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
			return false;
		}

		defaultOutfit.lookMount = currentMount->clientId;

		if (currentMount->speed != 0) {
			g_game.changeSpeed(this, currentMount->speed);
		}
	} else {
		if (!isMounted()) {
			return false;
		}

		dismount();
	}

	g_game.internalCreatureChangeOutfit(this, defaultOutfit);
	lastToggleMount = OTSYS_TIME();
	return true;
}

bool Player::setShop(bool shop)
{
	Shop = shop;
	return true;
}

bool Player::tameMount(uint8_t mountId)
{
	if (!g_game.mounts.getMountByID(mountId)) {
		return false;
	}

	const uint8_t tmpMountId = mountId - 1;
	const uint32_t key = PSTRG_MOUNTS_RANGE_START + (tmpMountId / 31);

	int32_t value;
	if (getStorageValue(key, value)) {
		value |= (1 << (tmpMountId % 31));
	} else {
		value = (1 << (tmpMountId % 31));
	}

	addStorageValue(key, value);
	return true;
}


bool Player::untameMount(uint8_t mountId)
{
	if (!g_game.mounts.getMountByID(mountId)) {
		return false;
	}

	const uint8_t tmpMountId = mountId - 1;
	const uint32_t key = PSTRG_MOUNTS_RANGE_START + (tmpMountId / 31);

	int32_t value;
	if (!getStorageValue(key, value)) {
		return true;
	}

	value &= ~(1 << (tmpMountId % 31));
	addStorageValue(key, value);

	if (getCurrentMount() == mountId) {
		if (isMounted()) {
			dismount();
			g_game.internalCreatureChangeOutfit(this, defaultOutfit);
		}

		setCurrentMount(0);
	}

	return true;
}

bool Player::hasMount(const Mount* mount) const
{
	if (isAccessPlayer()) {
		return true;
	}

	if (mount->premium && !isPremium()) {
		return false;
	}

	const uint8_t tmpMountId = mount->id - 1;

	int32_t value;
	if (!getStorageValue(PSTRG_MOUNTS_RANGE_START + (tmpMountId / 31), value)) {
		return false;
	}

	return ((1 << (tmpMountId % 31)) & value) != 0;
}

void Player::dismount()
{
	Mount* mount = g_game.mounts.getMountByID(getCurrentMount());
	if (mount && mount->speed > 0) {
		g_game.changeSpeed(this, -mount->speed);
	}

	defaultOutfit.lookMount = 0;
}
#endif

bool Player::addWings(uint16_t wingId)
{
	if (!g_game.wings.getWingByID(wingId)) {
		return false;
	}

	setAccountStorageValue(PSTRG_WINGS_RANGE_START + wingId, 1);
	return true;
}

bool Player::hasWing(const Wing* wing) const
{
	if (isAccessPlayer()) {
		return true;
	}

	int32_t value;
	if (!getAccountStorageValue(PSTRG_WINGS_RANGE_START + wing->id, value)) {
		return false;
	}

	return value == 1;
}

bool Player::addAura(uint16_t auraId)
{
	if (!g_game.auras.getAuraByID(auraId)) {
		return false;
	}

	setAccountStorageValue(PSTRG_AURAS_RANGE_START + auraId, 1);
	return true;
}

bool Player::hasAura(const Aura* aura) const
{
	if (isAccessPlayer()) {
		return true;
	}

	int32_t value;
	if (!getAccountStorageValue(PSTRG_AURAS_RANGE_START + aura->id, value)) {
		return false;
	}

	return value == 1;
}

bool Player::addShader(uint8_t shaderId)
{
	if (!g_game.shaders.getShaderByID(shaderId)) {
		return false;
	}

	setAccountStorageValue(PSTRG_SHADERS_RANGE_START + shaderId, 1);
	return true;
}

bool Player::hasShader(const Shader* shader) const
{
	if (isAccessPlayer()) {
		return true;
	}

	int32_t value;
	if (!getAccountStorageValue(PSTRG_SHADERS_RANGE_START + shader->id, value)) {
		return false;
	}

	return value == 1;
}

bool Player::addOutline(uint8_t outlineId)
{
	if (!g_game.outlines.getOutlineByID(outlineId)) {
		return false;
	}

	setAccountStorageValue(PSTRG_OUTLINE_RANGE_START + outlineId, 1);
	return true;
}

bool Player::hasOutline(const Outline* outline) const
{
	if (isAccessPlayer()) {
		return true;
	}

	int32_t value;
	if (!getAccountStorageValue(PSTRG_OUTLINE_RANGE_START + outline->id, value)) {
		return false;
	}

	return value == 1;
}

bool Player::addOfflineTrainingTries(skills_t skill, uint64_t tries)
{
	if (tries == 0 || skill == SKILL_LEVEL) {
		return false;
	}

	bool sendUpdate = false;
	uint32_t oldSkillValue, newSkillValue;
	long double oldPercentToNextLevel, newPercentToNextLevel;

	if (skill == SKILL_MAGLEVEL) {
		uint64_t currReqMana = vocation->getReqMana(magLevel);
		uint64_t nextReqMana = vocation->getReqMana(magLevel + 1);

		if (currReqMana >= nextReqMana) {
			return false;
		}

		oldSkillValue = magLevel;
		oldPercentToNextLevel = static_cast<long double>(manaSpent * 100) / nextReqMana;

		g_events->eventPlayerOnGainSkillTries(this, SKILL_MAGLEVEL, tries);
		uint32_t currMagLevel = magLevel;

		while ((manaSpent + tries) >= nextReqMana) {
			tries -= nextReqMana - manaSpent;

			magLevel++;
			manaSpent = 0;

			g_creatureEvents->playerAdvance(this, SKILL_MAGLEVEL, magLevel - 1, magLevel);

			sendUpdate = true;
			currReqMana = nextReqMana;
			nextReqMana = vocation->getReqMana(magLevel + 1);

			if (currReqMana >= nextReqMana) {
				tries = 0;
				break;
			}
		}

		manaSpent += tries;

		if (magLevel != currMagLevel) {
			std::stringExtended ss(64);
			ss << "You advanced to mastery " << magLevel << '.';
			sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);
		}

		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		uint16_t newPercent;
		#else
		uint8_t newPercent;
		#endif
		if (nextReqMana > currReqMana) {
			newPercent = Player::getPercentSkillLevel(manaSpent, nextReqMana);
			newPercentToNextLevel = static_cast<long double>(manaSpent * 100) / nextReqMana;
		} else {
			newPercent = 0;
			newPercentToNextLevel = 0;
		}

		if (newPercent != magLevelPercent) {
			magLevelPercent = newPercent;
			sendUpdate = true;
		}

		newSkillValue = magLevel;
	} else {
		uint64_t currReqTries = vocation->getReqSkillTries(skill, skills[skill].level);
		uint64_t nextReqTries = vocation->getReqSkillTries(skill, skills[skill].level + 1);
		if (currReqTries >= nextReqTries) {
			return false;
		}

		oldSkillValue = skills[skill].level;
		oldPercentToNextLevel = static_cast<long double>(skills[skill].tries * 100) / nextReqTries;

		g_events->eventPlayerOnGainSkillTries(this, skill, tries);
		uint32_t currSkillLevel = skills[skill].level;

		while ((skills[skill].tries + tries) >= nextReqTries) {
			tries -= nextReqTries - skills[skill].tries;

			skills[skill].level++;
			skills[skill].tries = 0;
			skills[skill].percent = 0;

			g_creatureEvents->playerAdvance(this, skill, (skills[skill].level - 1), skills[skill].level);

			sendUpdate = true;
			currReqTries = nextReqTries;
			nextReqTries = vocation->getReqSkillTries(skill, skills[skill].level + 1);

			if (currReqTries >= nextReqTries) {
				tries = 0;
				break;
			}
		}

		skills[skill].tries += tries;

		if (currSkillLevel != skills[skill].level) {
			std::stringExtended ss(128);
			ss << "You advanced to " << getSkillName(skill) << " level " << skills[skill].level << '.';
			sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);
		}

		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		uint16_t newPercent;
		#else
		uint8_t newPercent;
		#endif
		if (nextReqTries > currReqTries) {
			newPercent = Player::getPercentSkillLevel(skills[skill].tries, nextReqTries);
			newPercentToNextLevel = static_cast<long double>(skills[skill].tries * 100) / nextReqTries;
		} else {
			newPercent = 0;
			newPercentToNextLevel = 0;
		}

		if (skills[skill].percent != newPercent) {
			skills[skill].percent = newPercent;
			sendUpdate = true;
		}

		newSkillValue = skills[skill].level;
	}

	// change to int with 2-decimal precision
	int64_t oldPercentToNextLevel_U64 = static_cast<int64_t>(oldPercentToNextLevel * 100.0);
	int64_t newPercentToNextLevel_U64 = static_cast<int64_t>(newPercentToNextLevel * 100.0);

	std::stringExtended ss(256);
	ss << "Your " << ucwords(getSkillName(skill)) << " skill changed from level " << oldSkillValue << " (with " << oldPercentToNextLevel_U64;
	ss.insert(ss.end() - 2, '.'); // add comma to fixed-precision percentage
	ss << "% progress towards level " << (oldSkillValue + 1) << ") to level " << newSkillValue << " (with " << newPercentToNextLevel_U64;
	ss.insert(ss.end() - 2, '.'); // add comma to fixed-precision percentage
	ss << "% progress towards level " << (newSkillValue + 1) << ')';
	sendTextMessage(MESSAGE_EVENT_ADVANCE, ss);
	return sendUpdate;
}

bool Player::hasModalWindowOpen(uint32_t modalWindowId) const
{
	return find(modalWindows.begin(), modalWindows.end(), modalWindowId) != modalWindows.end();
}

void Player::onModalWindowHandled(uint32_t modalWindowId)
{
	auto it = std::find(modalWindows.begin(), modalWindows.end(), modalWindowId);
	if (it != modalWindows.end()) {
		modalWindows.erase(it);
	}
}

void Player::sendModalWindow(const ModalWindow& modalWindow)
{
	if (!client) {
		return;
	}

	if (modalWindows.size() >= 10) {
		// Avoid memory leak - it is possible to leak memory here
		clearModalWindows();
	}

	#if CLIENT_VERSION >= 960
	modalWindows.push_back(modalWindow.id);
	client->sendModalWindow(modalWindow);
	#else
	(void)modalWindow;
	#endif
}

void Player::clearModalWindows()
{
	modalWindows.clear();
}

uint16_t Player::getHelpers() const
{
	uint16_t helpers;

	if (guild && party) {
		std::unordered_set<Player*> helperSet;

		const auto& guildMembers = guild->getMembersOnline();
		helperSet.insert(guildMembers.begin(), guildMembers.end());

		const auto& partyMembers = party->getMembers();
		helperSet.insert(partyMembers.begin(), partyMembers.end());

		const auto& partyInvitees = party->getInvitees();
		helperSet.insert(partyInvitees.begin(), partyInvitees.end());

		helperSet.insert(party->getLeader());

		helpers = helperSet.size();
	} else if (guild) {
		helpers = guild->getMembersOnline().size();
	} else if (party) {
		helpers = party->getMemberCount() + party->getInvitationCount() + 1;
	} else {
		helpers = 0;
	}

	return helpers;
}

void Player::sendClosePrivate(uint16_t channelId)
{
	if (channelId == CHANNEL_GUILD || channelId == CHANNEL_PARTY) {
		g_chat->removeUserFromChannel(*this, channelId);
	}

	if (client) {
		client->sendClosePrivate(channelId);
	}
}

uint64_t Player::getMoney() const
{
	std::vector<const Container*> containers;
	containers.reserve(32);

	uint64_t moneyCount = 0;
	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; ++i) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		const Container* container = item->getContainer();
		if (container) {
			containers.push_back(container);
		} else {
			moneyCount += item->getWorth();
		}
	}

	size_t i = static_cast<size_t>(-1);
	while (++i < containers.size()) {
		const Container* container = containers[i];
		for (const Item* item : container->getItemList()) {
			const Container* tmpContainer = item->getContainer();
			if (tmpContainer) {
				containers.push_back(tmpContainer);
			} else {
				moneyCount += item->getWorth();
			}
		}
	}
	return moneyCount;
}

bool Player::removeTotalMoney(uint64_t amount)
{
	uint64_t moneyCount = getMoney();
	uint64_t bankCount = getBankBalance();

	if (amount <= moneyCount) {
		return g_game.removeMoney(this, amount);
	}
	else if (amount <= (moneyCount + bankCount)) {
		if (moneyCount != 0) {
			g_game.removeMoney(this, moneyCount);
			uint64_t remains = amount - moneyCount;
			setBankBalance(bankCount - remains);
			std::stringExtended txt(140);
			txt << "Paid " << moneyCount << " from inventory and " << amount - moneyCount << " gold from bank account. Your account balance is now " << getBankBalance() << " gold.";
			sendTextMessage(MESSAGE_INFO_DESCR, txt);
			return true;
		}
		else {
			setBankBalance(bankCount - amount);
			std::stringExtended txt(120);
			txt << "Paid " << amount << " gold from bank account. Your account balance is now " << getBankBalance() << " gold.";
			sendTextMessage(MESSAGE_INFO_DESCR, txt);
			return true;
		}
	}

	return false;
}

size_t Player::getMaxVIPEntries() const
{
	if (group->maxVipEntries != 0) {
		return group->maxVipEntries;
	} else if (isPremium()) {
		return 100;
	}
	return 20;
}

size_t Player::getMaxDepotItems() const
{
	if (group->maxDepotItems != 0) {
		return group->maxDepotItems;
	} else if (isPremium()) {
		return 2000;
	}
	return 1000;
}

std::vector<Condition*> Player::getMuteConditions() const
{
	std::vector<Condition*> muteConditions;
	muteConditions.reserve(conditions.size());

	for (Condition* condition : conditions) {
		if (condition->getTicks() <= 0) {
			continue;
		}

		ConditionType_t type = condition->getType();
		if (type != CONDITION_MUTED && type != CONDITION_CHANNELMUTEDTICKS && type != CONDITION_YELLTICKS) {
			continue;
		}

		muteConditions.push_back(condition);
	}
	return muteConditions;
}

void Player::setGuild(Guild* guild)
{
	if (guild == this->guild) {
		return;
	}

	Guild* oldGuild = this->guild;

	this->guildNick.clear();
	this->guild = nullptr;
	this->guildRank = nullptr;

	if (guild) {
		const GuildRank* rank = guild->getRankByLevel(1);
		if (!rank) {
			return;
		}

		this->guild = guild;
		this->guildRank = rank;
		guild->addMember(this);
	}

	if (oldGuild) {
		oldGuild->removeMember(this);
	}
}

void Player::addScheduledUpdates(uint32_t flags)
{
	scheduledUpdates |= flags;
	if (!scheduledUpdate) {
		g_dispatcher.addEvent(SERVER_BEAT_MILISECONDS, std::bind(&Game::updatePlayerEvent, &g_game, getID()));
		scheduledUpdate = true;
	}
}

Item* Player::getItemByUID(uint32_t uid) const {
	if (uid == 0) {
		return nullptr;
	}

	std::vector<Item*> itemList;

	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; i++) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		if (item->getRealUID() == uid) {
			return item;
		}
		else if (Container* container = item->getContainer()) {
			for (ContainerIterator it = container->iterator(); it.hasNext(); it.advance()) {
				Item* containerItem = *it;
				if (containerItem->getRealUID() == uid) {
					return containerItem;
				}
			}
		}
	}
	return nullptr;
}

void Player::setCharacterStat(CharacterStats_t stat, int16_t value)
{
	charStats[stat] = value;
	if (stat == CHARSTAT_VITALITY || stat == CHARSTAT_SPIRIT) {
		if (stat == CHARSTAT_VITALITY)
			g_game.addCreatureHealth(this);
		sendStats(1);
		sendStats(2);
		sendStats(4);
	}
}

void Player::addCharacterStat(CharacterStats_t stat, int16_t value)
{
	charStats[stat] += value;
	if (stat == CHARSTAT_VITALITY || stat == CHARSTAT_SPIRIT) {
		if (stat == CHARSTAT_VITALITY)
			g_game.addCreatureHealth(this);
		sendStats(1);
		sendStats(2);
		sendStats(4);
	}
}

uint16_t Player::getItemLevel() const
{
	uint16_t iLvl = 0;
	for (int32_t i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; i++) {
		Item* item = inventory[i];
		if (!item) {
			continue;
		}

		auto attr = item->getCustomAttribute("item_level");
		if (attr) {
			if ((item->getSlotPosition() & SLOTP_TWO_HAND)) {
				iLvl += attr->getInt() * 2;
			}
			else {
				iLvl += attr->getInt();
			}
		}
	}
	return iLvl;
}

uint16_t Player::getFreeBackpackSlots() const
{
	Thing* thing = getThing(CONST_SLOT_BACKPACK);
	if (!thing) {
		return 0;
	}

	Container* backpack = thing->getContainer();
	if (!backpack) {
		return 0;
	}

	uint16_t counter = std::max<uint16_t>(0, backpack->getFreeSlots());

	return counter;
} 