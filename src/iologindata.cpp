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

#include "databasetasks.h"
#include "iologindata.h"
#include "configmanager.h"
#include "game.h"
#include "events.h"
#include <chrono>

extern ConfigManager g_config;
extern Game g_game;
extern Events* g_events;

Account IOLoginData::loadAccount(uint32_t accno)
{
	Account account;

	std::stringExtended query(128);
	query << "SELECT `id`, `email`, `password`, `type`, `lastday` FROM `accounts` WHERE `id` = " << accno << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return account;
	}

	account.id = result->getNumber<uint32_t>("id");
	account.email = std::move(result->getString("email"));
	account.accountType = static_cast<AccountType_t>(result->getNumber<int32_t>("type"));
	account.premiumDays = 0;
	account.lastDay = result->getNumber<time_t>("lastday");
	return account;
}

bool IOLoginData::saveAccount(const Account& acc)
{
	std::stringExtended query(128);
	query << "UPDATE `accounts` SET `lastday` = " << acc.lastDay << " WHERE `id` = " << acc.id;
	return g_database.executeQuery(query);
}

bool IOLoginData::saveAccountStorages(Player* player)
{
	std::stringExtended query(1024);
	query << "UPDATE `accounts` SET ";

	size_t attributesSize;
	PropWriteStream propWriteStream;
	propWriteStream.write<size_t>(player->accountStorageMap.size());
	for (const auto& it : player->accountStorageMap) {
		propWriteStream.write<uint32_t>(it.first);
		propWriteStream.write<int32_t>(it.second);
	}

	const char* attributes = propWriteStream.getStream(attributesSize);
	if (attributesSize > 0) {
		query << "`storages` = " << g_database.escapeBlob(attributes, attributesSize);
	} else {
		query << "`storages` = NULL";
	}

	query << " WHERE `id` = " << player->getAccount();

	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
	return true;
}

bool IOLoginData::loadAccountStorages(Player* player)
{
	std::stringExtended query(1024);
	query << "SELECT `storages` FROM `accounts` WHERE `id` = " << player->getAccount() << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	//load storage map
	PropStream propStream;
	unsigned long attrSize;
	const char* attr = result->getStream("storages", attrSize);
	propStream.init(attr, attrSize);

	size_t storage_sizes;
	if (propStream.read<size_t>(storage_sizes)) {
		player->storageMap.reserve(storage_sizes);

		uint32_t storage_key;
		int32_t storage_value;
		while (propStream.read<uint32_t>(storage_key) && propStream.read<int32_t>(storage_value)) {
			player->setAccountStorageValue(storage_key, storage_value);
		}
	}

	return true;
}

bool IOLoginData::loadAccountBalance(Player* player)
{
	std::stringExtended query(128);
	query << "SELECT `balance` FROM `accounts` WHERE `id` = " << player->getAccount() << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	player->bankBalance = result->getNumber<uint64_t>("balance");
	return true;
}

bool IOLoginData::loadAccountDepot(Player* player)
{
	std::stringExtended query(128);
	query << "SELECT `depotitems`, `depotlockeritems` FROM `accounts` WHERE `id` = " << player->getAccount() << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	ItemBlockList itemMap;
	PropStream propStream;
	unsigned long attrSize;

	// Load depot locker items
	const char* attr = result->getStream("depotlockeritems", attrSize);
	if (attrSize > 0) {
		propStream.init(attr, attrSize);
		loadItems(itemMap, result, propStream, player);
		for (const auto& it : itemMap) {
			Item* item = it.second;
			uint32_t pid = static_cast<uint32_t>(it.first);
			if (pid >= 0 && pid < 100) {
				DepotLocker* depotLocker = player->getDepotLocker(pid);
				if (depotLocker) {
					g_events->eventPlayerOnItemLoad(player, item);
					depotLocker->internalAddThing(item);
					item->startDecaying();
				} else {
					std::cout << "[Error - IOLoginData::loadAccountDepot " << item->getID() << "] Cannot load depot locker " << pid << " for player " << player->name << std::endl;
					delete item;
				}
			}
		}
	}

	// Load depot items
	itemMap.clear();
	attr = result->getStream("depotitems", attrSize);
	if (attrSize > 0) {
		propStream.init(attr, attrSize);
		loadItems(itemMap, result, propStream, player);
		for (const auto& it : itemMap) {
			Item* item = it.second;
			uint32_t pid = static_cast<uint32_t>(it.first);
			if (pid >= 0 && pid < 100) {
				DepotChest* depotChest = player->getDepotChest(pid, true);
				if (depotChest) {
					g_events->eventPlayerOnItemLoad(player, item);
					depotChest->internalAddThing(item);
					item->startDecaying();
				} else {
					std::cout << "[Error - IOLoginData::loadAccountDepot " << item->getID() << "] Cannot load depot " << pid << " for player " << player->name << std::endl;
					delete item;
				}
			}
		}
	}

	return true;
}

bool IOLoginData::loadAccountInbox(Player* player)
{
	std::stringExtended query(128);
	query << "SELECT `inboxitems` FROM `accounts` WHERE `id` = " << player->getAccount() << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	unsigned long attrSize;
	const char* attr = result->getStream("inboxitems", attrSize);
	if (attrSize > 0) {
		PropStream propStream;
		propStream.init(attr, attrSize);
		ItemBlockList itemMap;
		loadItems(itemMap, result, propStream, player);
		for (const auto& it : itemMap) {
			Item* item = it.second;
			g_events->eventPlayerOnItemLoad(player, item);
			player->getInbox()->internalAddThing(item);
			item->startDecaying();
		}
	}

	return true;
}

bool IOLoginData::saveAccountBalance(Player* player)
{
	std::stringExtended query(128);
	query << "UPDATE `accounts` SET `balance` = " << player->bankBalance << " WHERE `id` = " << player->getAccount();
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
	return true;
}

void IOLoginData::increaseAccountBankBalance(uint32_t accountId, uint64_t bankBalance)
{
	std::stringExtended query(128);
	query << "UPDATE `accounts` SET `balance` = `balance` + " << bankBalance << " WHERE `id` = " << accountId;
	g_database.executeQuery(query);
}

std::string decodeSecret(const std::string& secret)
{
	// simple base32 decoding
	std::string key;
	key.reserve(10);

	uint32_t buffer = 0, left = 0;
	for (const auto& ch : secret) {
		buffer <<= 5;
		if (ch >= 'A' && ch <= 'Z') {
			buffer |= (ch & 0x1F) - 1;
		} else if (ch >= '2' && ch <= '7') {
			buffer |= ch - 24;
		} else {
			// if a key is broken, return empty and the comparison
			// will always be false since the token must not be empty
			return {};
		}

		left += 5;
		if (left >= 8) {
			left -= 8;
			key.push_back(static_cast<char>(buffer >> left));
		}
	}

	return key;
}

bool IOLoginData::loginserverAuthentication(const std::string& name, const std::string& password, Account& account, uint32_t ip /*= 0*/)
{
	const std::string& escapedName = g_database.escapeString(name);
	std::stringExtended query(escapedName.length() + static_cast<size_t>(128));
	query << "SELECT `id`, `email`, `password`, `secret`, `type`, `lastday`, `whitelist` FROM `accounts` WHERE `email` = " << escapedName << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	if (transformToAES(password) != result->getString("password")) {
		return false;
	}

	account.id = result->getNumber<uint32_t>("id");
	account.email = std::move(result->getString("email"));
	account.key = std::move(decodeSecret(result->getString("secret")));
	account.accountType = static_cast<AccountType_t>(result->getNumber<int32_t>("type"));
	account.premiumDays = 0;
	account.lastDay = result->getNumber<time_t>("lastday");
	account.whiteListed = result->getNumber<uint32_t>("whitelist");

	query.clear();
	query << "SELECT `name`, `level`, `vocation`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `lookwings`, `lookaura`, `lookshader`, `lookoutline`, `deletion`, `delete_time` FROM `players` WHERE `account_id` = " << account.id;
	result = g_database.storeQuery(query);
	if (result) {
		account.characters.reserve(result->countResults());
		do {
			//check if character time to delete has passed
			if (result->getNumber<uint64_t>("deletion") == 1) {
				if (result->getNumber<int64_t>("delete_time") <= (time(nullptr)*1000)) {
					query.clear();
					query << "DELETE FROM `players` WHERE `name` = " << g_database.escapeString(result->getString("name"));
					g_database.executeQuery(query);
					continue;
				}
			} 


			account.characters.emplace_back(std::move(result->getString("name")));
			account.levels.emplace_back(std::move(result->getNumber<uint16_t>("level")));
			account.vocations.emplace_back(std::move(result->getNumber<uint16_t>("vocation")));
			account.lookbody.emplace_back(std::move(result->getNumber<uint16_t>("lookbody")));
			account.lookfeet.emplace_back(std::move(result->getNumber<uint16_t>("lookfeet")));
			account.lookhead.emplace_back(std::move(result->getNumber<uint16_t>("lookhead")));
			account.looklegs.emplace_back(std::move(result->getNumber<uint16_t>("looklegs")));
			account.looktype.emplace_back(std::move(result->getNumber<uint16_t>("looktype")));
			account.lookaddons.emplace_back(std::move(result->getNumber<uint16_t>("lookaddons")));
			account.lookwings.emplace_back(std::move(result->getNumber<uint16_t>("lookwings")));
			account.lookaura.emplace_back(std::move(result->getNumber<uint16_t>("lookaura")));
			account.lookshader.emplace_back(std::move(result->getString("lookshader")));
			//account.lookoutline.emplace_back(std::move(result->getString("lookoutline")));
			account.time.emplace_back(std::move(result->getNumber<uint64_t>("delete_time")));
		} while (result->next());
		//std::sort(account.characters.begin(), account.characters.end());
	}

	query.clear();
	query << "UPDATE `accounts` SET `ip` = " << ip << " WHERE `id` = " << account.id;
	g_database.executeQuery(query);

	return true;
}

#if GAME_FEATURE_SESSIONKEY > 0
uint32_t IOLoginData::gameworldAuthentication(const std::string& accountName, const std::string& password, std::string& characterName, std::string& token, uint32_t tokenTime)
#else
uint32_t IOLoginData::gameworldAuthentication(const std::string& accountName, const std::string& password, std::string& characterName)
#endif
{
	const std::string& escapedAccountName = g_database.escapeString(accountName);
	const std::string& escapedCharacterName = g_database.escapeString(characterName);
	std::stringExtended query(std::max<size_t>(escapedAccountName.length(), escapedCharacterName.length()) + static_cast<size_t>(128));

	#if GAME_FEATURE_SESSIONKEY > 0
	query << "SELECT `id`, `password`, `secret` FROM `accounts` WHERE `email` = " << escapedAccountName << " LIMIT 1";
	#else
	query << "SELECT `id`, `password` FROM `accounts` WHERE `email` = " << escapedAccountName << " LIMIT 1";
	#endif
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return 0;
	}

	#if GAME_FEATURE_SESSIONKEY > 0
	std::string secret = decodeSecret(result->getString("secret"));
	if (!secret.empty()) {
		if (token.empty()) {
			return 0;
		}

		bool tokenValid = token == generateToken(secret, tokenTime) || token == generateToken(secret, tokenTime - 1) || token == generateToken(secret, tokenTime + 1);
		if (!tokenValid) {
			return 0;
		}
	}
	#endif

	if (transformToAES(password) != result->getString("password")) {
		return 0;
	}

	uint32_t accountId = result->getNumber<uint32_t>("id");

	query.clear();
	query << "SELECT `account_id`, `name`, `deletion` FROM `players` WHERE `name` = " << escapedCharacterName << " LIMIT 1";
	result = g_database.storeQuery(query);
	if (!result) {
		return 0;
	}

	if (result->getNumber<uint32_t>("account_id") != accountId || result->getNumber<uint64_t>("deletion") != 0) {
		return 0;
	}
	characterName = std::move(result->getString("name"));
	return accountId;
}

#if GAME_FEATURE_SESSIONKEY > 0
uint32_t IOLoginData::getAccountId(const std::string& accountName, const std::string& password, std::string& token, uint32_t tokenTime)
#else
uint32_t IOLoginData::getAccountId(const std::string& accountName, const std::string& password)
#endif
{
	const std::string& escapedAccountName = g_database.escapeString(accountName);
	std::stringExtended query(escapedAccountName.length() + static_cast<size_t>(128));

#if GAME_FEATURE_SESSIONKEY > 0
	query << "SELECT `id`, `password`, `secret` FROM `accounts` WHERE `email` = " << escapedAccountName << " LIMIT 1";
#else
	query << "SELECT `id`, `password` FROM `accounts` WHERE `email` = " << escapedAccountName << " LIMIT 1";
#endif
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return 0;
	}

#if GAME_FEATURE_SESSIONKEY > 0
	std::string secret = decodeSecret(result->getString("secret"));
	if (!secret.empty()) {
		if (token.empty()) {
			return 0;
		}

		bool tokenValid = token == generateToken(secret, tokenTime) || token == generateToken(secret, tokenTime - 1) || token == generateToken(secret, tokenTime + 1);
		if (!tokenValid) {
			return 0;
		}
	}
#endif

	if (transformToAES(password) != result->getString("password")) {
		return 0;
	}

	return result->getNumber<uint32_t>("id");
}

AccountType_t IOLoginData::getAccountType(uint32_t accountId)
{
	std::stringExtended query(64);
	query << "SELECT `type` FROM `accounts` WHERE `id` = " << accountId << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return ACCOUNT_TYPE_NORMAL;
	}
	return static_cast<AccountType_t>(result->getNumber<uint16_t>("type"));
}

void IOLoginData::setAccountType(uint32_t accountId, AccountType_t accountType)
{
	std::stringExtended query(128);
	query << "UPDATE `accounts` SET `type` = " << accountType << " WHERE `id` = " << accountId;
	g_database.executeQuery(query);
}

void IOLoginData::updateOnlineStatus(uint32_t guid, bool login)
{
	if (g_config.getBoolean(ConfigManager::ALLOW_CLONES)) {
		return;
	}

	std::stringExtended query(64);
	if (login) {
		query << "INSERT INTO `players_online` VALUES (" << guid << ')';
	} else {
		query << "DELETE FROM `players_online` WHERE `player_id` = " << guid;
	}
	g_database.executeQuery(query);

	std::stringExtended querx(64);
	if (login) {
		querx << "UPDATE `players` SET `online` = 1 WHERE `id` = " << guid;
	} else {
		querx << "UPDATE `players` SET `online` = 0 WHERE `id` = " << guid;
	}
	g_database.executeQuery(querx);
}

bool IOLoginData::preloadPlayer(Player* player, const std::string& name)
{
	const std::string& escapedName = g_database.escapeString(name);
	std::stringExtended query(escapedName.length() + static_cast<size_t>(280));

	query << "SELECT `id`, `account_id`, `group_id`, `deletion`, (SELECT `type` FROM `accounts` WHERE `accounts`.`id` = `account_id`) AS `account_type`";
	query << " FROM `players` WHERE `name` = " << escapedName << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	if (result->getNumber<uint64_t>("deletion") != 0) {
		return false;
	}

	player->setGUID(result->getNumber<uint32_t>("id"));
	Group* group = g_game.groups.getGroup(result->getNumber<uint16_t>("group_id"));
	if (!group) {
		std::cout << "[Error - IOLoginData::preloadPlayer] " << player->name << " has Group ID " << result->getNumber<uint16_t>("group_id") << " which doesn't exist." << std::endl;
		return false;
	}
	player->setGroup(group);
	player->accountNumber = result->getNumber<uint32_t>("account_id");
	player->accountType = static_cast<AccountType_t>(result->getNumber<uint16_t>("account_type"));
	player->premiumDays = 0;

	query.clear();
	query << "SELECT `guild_id`, `rank_id`, `nick` FROM `guild_membership` WHERE `player_id` = " << player->getGUID() << " LIMIT 1";
	if ((result = g_database.storeQuery(query))) {
		uint32_t guildId = result->getNumber<uint32_t>("guild_id");
		uint32_t playerRankId = result->getNumber<uint32_t>("rank_id");
		player->guildNick = std::move(result->getString("nick"));

		Guild* guild = g_game.getGuild(guildId);
		if (!guild) {
			guild = IOGuild::loadGuild(guildId);
		}

		if (guild) {
			g_game.addGuild(guild);

			player->guild = guild;
			const GuildRank* rank = guild->getRankById(playerRankId);
			if (!rank) {
				query.clear();
				query << "SELECT `id`, `name`, `level` FROM `guild_ranks` WHERE `id` = " << playerRankId << " LIMIT 1";
				if ((result = g_database.storeQuery(query))) {
					guild->addRank(result->getNumber<uint32_t>("id"), result->getString("name"), result->getNumber<uint16_t>("level"));
				}

				rank = guild->getRankById(playerRankId);
				if (!rank) {
					player->guild = nullptr;
				}
			}

			player->guildRank = rank;

			IOGuild::getWarList(guildId, player->guildWarVector);

			query.clear();
			query << "SELECT COUNT(*) AS `members` FROM `guild_membership` WHERE `guild_id` = " << guildId << " LIMIT 1";
			if ((result = g_database.storeQuery(query))) {
				guild->setMemberCount(result->getNumber<uint32_t>("members"));
			}
		}
	}
	return true;
}

bool IOLoginData::loadPlayerById(Player* player, uint32_t id)
{
	std::stringExtended query(1024);
	query << "SELECT `id`, `name`, `account_id`, `group_id`, `sex`, `vocation`, `experience`, `level`, `health`, `healthmax`, `mana`, `manamax`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `posx`, `posy`, `posz`, `lastlogin`, `onlinetime`, `firstlogin`, `lastlogout`, `lastip`, `conditions`, `storages`, `town_id`, `direction`, `stat_str`, `stat_int`, `stat_speed`, `stat_vit`, `stat_ski`, `stat_dex`, `stat_spr`, `stat_wis`, `stat_per`, `stat_dmg`, `stat_reg`, `stat_lif`, `stat_move`, `stat_one`, `stat_two`, `stat_hphit`, `stat_eshit`, `lookwings`, `lookaura`, `lookshader`, `lookoutline`, `dungeontier`, `dps`, `kills`, `deaths` FROM `players` WHERE `id` = " << id << " LIMIT 1";
	return loadPlayer(player, g_database.storeQuery(query));
}

bool IOLoginData::loadPlayerByName(Player* player, const std::string& name)
{
	const std::string& escapedName = g_database.escapeString(name);
	std::stringExtended query(escapedName.length() + static_cast<size_t>(1024));
	query << "SELECT `id`, `name`, `account_id`, `group_id`, `sex`, `vocation`, `experience`, `level`, `health`, `healthmax`, `mana`, `manamax`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `posx`, `posy`, `posz`, `lastlogin`, `onlinetime`, `firstlogin`, `lastlogout`, `lastip`, `conditions`, `storages`, `town_id`, `direction`, `stat_str`, `stat_int`, `stat_speed`, `stat_vit`, `stat_ski`, `stat_dex`, `stat_spr`, `stat_wis`, `stat_per`, `stat_dmg`, `stat_reg`, `stat_lif`, `stat_move`, `stat_one`, `stat_two`, `stat_hphit`, `stat_eshit`, `lookwings`, `lookaura`, `lookshader`, `lookoutline`, `dungeontier`, `dps`, `kills`, `deaths` FROM `players` WHERE `name` = " << escapedName << " LIMIT 1";
	return loadPlayer(player, g_database.storeQuery(query));
}

bool IOLoginData::loadContainer(PropStream& propStream, Container* mainContainer, Player* player)
{
	//Reserve a little space before to avoid massive reallocations
	std::vector<Container*> loadingContainers; loadingContainers.reserve(100);
	loadingContainers.push_back(mainContainer);
	while (!loadingContainers.empty()) {
		StartLoadingContainers:
		Container* container = loadingContainers.back();
		while (container->serializationCount > 0) {
			uint16_t id;
			if (!propStream.read<uint16_t>(id)) {
				std::cout << "[Warning - IOLoginData::loadContainer] Failed to read item ID from container: " << container->getID() << std::endl;
				return false;
			}

			Item* item = Item::CreateItem(id, 0);
			if (item) {
				if (item->unserializeAttr(propStream)) {
					Container* c = item->getContainer();
					if (c) {
						--container->serializationCount; // Since we're going out of loop decrease our iterator here
						loadingContainers.push_back(c);
						goto StartLoadingContainers;
					}

					if (player) {
						g_events->eventPlayerOnItemLoad(player, item);
					}
					container->internalAddThing(item);
				} else {
					delete item;
					std::cout << "[Warning - IOLoginData::loadContainer] Failed to unserialize attributes for item ID: " << id << " in container: " << container->getID() << std::endl;
					return false;
				}
			} else {
				std::cout << "[Warning - IOLoginData::loadContainer] Cannot create item with ID: " << id << " in container: " << container->getID() << std::endl;
				// Item doesn't exist - this could be from a removed item type
				// Skip this item and continue
				--container->serializationCount;
				continue;
			}
			--container->serializationCount;
		}
		uint8_t endAttr;
		if (!propStream.read<uint8_t>(endAttr) || endAttr != 0) {
			std::cout << "[Warning - IOLoginData::loadContainer] Unserialization error for container item: " << container->getID() << std::endl;
			return false;
		}
		loadingContainers.pop_back();
		if (!loadingContainers.empty()) {
			loadingContainers.back()->internalAddThing(container);
		}
	}
	return true;
}

void IOLoginData::loadItems(ItemBlockList& itemMap, DBResult_ptr result, PropStream& propStream, Player* player)
{
	int32_t pid;
	uint16_t id;
	while (propStream.read<int32_t>(pid) && propStream.read<uint16_t>(id)) {
		Item* item = Item::CreateItem(id, 0);
		if (item) {
			if (item->unserializeAttr(propStream)) {
				Container* container = item->getContainer();
				if (container && !loadContainer(propStream, container, player)) {
					delete item;
					std::cout << "[Warning - IOLoginData::loadItems] Failed to load container (ID: " << id << ", PID: " << pid << ")" << std::endl;
					return;
				}
				itemMap.emplace_back(pid, item);
			} else {
				delete item;
				std::cout << "[Warning - IOLoginData::loadItems] Failed to unserialize item attributes (Item ID: " << id << ", PID: " << pid << ")" << std::endl;
				return;
			}
		} else {
			std::cout << "[Warning - IOLoginData::loadItems] Cannot create item with ID: " << id << " (PID: " << pid << ") - item type may not exist" << std::endl;
			// Continue trying to load other items instead of returning
			// Try to skip this item's attributes to continue loading
			uint8_t attr_type;
			while (propStream.read<uint8_t>(attr_type)) {
				if (attr_type == 0x00) {
					break; // End of attributes
				}
				// Skip attribute data based on type - this is a simplified approach
				// In practice, you'd need to handle each attribute type properly
			}
		}
	}
}

bool IOLoginData::loadPlayer(Player* player, DBResult_ptr result)
{
	if (!result) {
		return false;
	}
	
	// Clear isSaving flags in case previous save thread couldn't clear them
	player->isSaving.store(false);
	g_game.stopPlayerSession(player->getGUID());

	uint32_t accno = result->getNumber<uint32_t>("account_id");

	// Check if account is currently saving (another character on same account)
	// This prevents loading stale depot/inbox data while a save is in progress
	if (g_game.hasActiveAccountSession(accno)) {
		std::cout << "[IOLoginData::loadPlayer] " << result->getString("name") << " - Account is currently saving, cannot login." << std::endl;
		return false;
	}

	Account acc = loadAccount(accno);

	player->setGUID(result->getNumber<uint32_t>("id"));
	player->name = std::move(result->getString("name"));
	player->accountNumber = accno;

	player->accountType = acc.accountType;
	if (g_config.getBoolean(ConfigManager::FREE_PREMIUM)) {
		player->premiumDays = std::numeric_limits<uint16_t>::max();
	} else {
		player->premiumDays = acc.premiumDays;
	}

	Group* group = g_game.groups.getGroup(result->getNumber<uint16_t>("group_id"));
	if (!group) {
		std::cout << "[Error - IOLoginData::loadPlayer] " << player->name << " has Group ID " << result->getNumber<uint16_t>("group_id") << " which doesn't exist" << std::endl;
		return false;
	}
	player->setGroup(group);

	// Load balance from account table (shared across all characters)
	loadAccountBalance(player);

	player->setSex(static_cast<PlayerSex_t>(result->getNumber<uint16_t>("sex")));
	player->level = std::max<uint32_t>(1, result->getNumber<uint32_t>("level"));

	uint64_t experience = result->getNumber<uint64_t>("experience");

	uint64_t currExpCount = Player::getExpForLevel(player->level);
	uint64_t nextExpCount = Player::getExpForLevel(player->level + 1);
	if (experience < currExpCount || experience > nextExpCount) {
		experience = currExpCount;
	}

	player->experience = experience;
	if (currExpCount < nextExpCount) {
		player->levelPercent = Player::getPercentLevel(player->experience - currExpCount, nextExpCount - currExpCount);
	} else {
		player->levelPercent = 0;
	}

	// Clear any existing stored conditions before loading
	for (Condition* condition : player->storedConditionList) {
		if (condition) {
			delete condition;
		}
	}
	player->storedConditionList.clear();

	unsigned long conditionsSize;
	const char* conditions = result->getStream("conditions", conditionsSize);
	PropStream propStream;
	propStream.init(conditions, conditionsSize);

	Condition* condition = Condition::createCondition(propStream);
	while (condition) {
		if (condition->unserialize(propStream)) {
			player->storedConditionList.push_back(condition);
		} else {
			delete condition;
		}
		condition = Condition::createCondition(propStream);
	}

	//load storage map
	unsigned long attrSize;
	const char* attr = result->getStream("storages", attrSize);
	propStream.init(attr, attrSize);

	size_t storage_sizes;
	if (propStream.read<size_t>(storage_sizes)) {
		player->storageMap.reserve(storage_sizes);

		uint32_t storage_key;
		int32_t storage_value;
		while (propStream.read<uint32_t>(storage_key) && propStream.read<int32_t>(storage_value)) {
			player->addStorageValue(storage_key, storage_value, true);
		}
	}

	if (!player->setVocation(result->getNumber<uint16_t>("vocation"), true)) {
		std::cout << "[Error - IOLoginData::loadPlayer] " << player->name << " has Vocation ID " << result->getNumber<uint16_t>("vocation") << " which doesn't exist" << std::endl;
		return false;
	}

	player->mana = result->getNumber<uint64_t>("mana");
	player->manaMax = result->getNumber<uint64_t>("manamax");

	player->health = result->getNumber<int64_t>("health");
	player->healthMax = result->getNumber<int64_t>("healthmax");

	player->defaultOutfit.lookType = result->getNumber<uint16_t>("looktype");
	player->defaultOutfit.lookHead = result->getNumber<uint16_t>("lookhead");
	player->defaultOutfit.lookBody = result->getNumber<uint16_t>("lookbody");
	player->defaultOutfit.lookLegs = result->getNumber<uint16_t>("looklegs");
	player->defaultOutfit.lookFeet = result->getNumber<uint16_t>("lookfeet");
	player->defaultOutfit.lookAddons = result->getNumber<uint16_t>("lookaddons");
	player->defaultOutfit.lookWings = result->getNumber<uint16_t>("lookwings");
	player->defaultOutfit.lookAura = result->getNumber<uint16_t>("lookaura");
	player->defaultOutfit.lookShader = result->getString("lookshader");
	player->defaultOutfit.lookOutline = result->getString("lookoutline");
	player->currentOutfit = player->defaultOutfit;
	player->direction = static_cast<Direction> (result->getNumber<uint16_t>("direction"));

	player->dungeonTier = result->getNumber<uint16_t>("dungeontier");
	player->dps = result->getNumber<uint64_t>("dps");
	player->kills = result->getNumber<uint32_t>("kills");
	player->deaths = result->getNumber<uint32_t>("deaths");

	player->loginPosition.x = result->getNumber<uint16_t>("posx");
	player->loginPosition.y = result->getNumber<uint16_t>("posy");
	player->loginPosition.z = result->getNumber<uint16_t>("posz");

	player->lastLoginSaved = result->getNumber<time_t>("lastlogin");
	player->onlineTime = result->getNumber<time_t>("onlinetime");
	player->firstLogin = result->getNumber<time_t>("firstlogin");
	player->lastLogout = result->getNumber<time_t>("lastlogout");

	Town* town = g_game.map.towns.getTown(result->getNumber<uint32_t>("town_id"));
	if (!town) {
		std::cout << "[Error - IOLoginData::loadPlayer] " << player->name << " has Town ID " << result->getNumber<uint32_t>("town_id") << " which doesn't exist" << std::endl;
		return false;
	}

	player->town = town;

	const Position& loginPos = player->loginPosition;
	if (loginPos.x == 0 && loginPos.y == 0 && loginPos.z == 0) {
		player->loginPosition = Position(675, 1040, 7);
	}

	static const std::string charStatNames[] = { "stat_str", "stat_int", "stat_speed", "stat_vit", "stat_ski", "stat_dex", "stat_spr", "stat_wis", "stat_per", "stat_dmg", "stat_reg", "stat_lif", "stat_move", "stat_one", "stat_two", "stat_hphit", "stat_eshit" };
	for (auto i = 0; i < CHARSTAT_LAST + 1; ++i) {
		player->charStats[i] = result->getNumber<uint16_t>(charStatNames[i]);
	}

	//load inventory items
	ItemBlockList itemMap;

	std::stringExtended query(128);
	query << "SELECT `items` FROM `players` WHERE `id` = " << player->getGUID() << " LIMIT 1";
	if ((result = g_database.storeQuery(query))) {
		attr = result->getStream("items", attrSize);
		propStream.init(attr, attrSize);
		loadItems(itemMap, result, propStream, player);
		for (const auto& it : itemMap) {
			Item* item = it.second;
			g_events->eventPlayerOnItemLoad(player, item);
			uint32_t pid = static_cast<uint32_t>(it.first);		
			if (pid >= 1 && pid <= CONST_SLOT_LAST + 1) {
				player->internalAddThing(pid, item);
				item->startDecaying();
			}
		}
	}

	#if GAME_FEATURE_STORE_INBOX > 0
		if (!player->inventory[CONST_SLOT_STORE_INBOX]) {
			player->internalAddThing(CONST_SLOT_STORE_INBOX, Item::CreateItem(ITEM_STORE_INBOX));
		}
	#endif
	
	if (!player->inventory[CONST_SLOT_RELICT_BOX]) {
		player->internalAddThing(CONST_SLOT_RELICT_BOX, Item::CreateItem(ITEM_RELICT_BOX));
	}

	// Load depot and inbox from account table (shared across all characters)
	loadAccountDepot(player);
	loadAccountInbox(player);

	// temp storage
	itemMap.clear();

	query.clear();
	query << "SELECT `tempstorage` FROM `players` WHERE `id` = " << player->getGUID() << " LIMIT 1";
	if ((result = g_database.storeQuery(query))) {
		attr = result->getStream("tempstorage", attrSize);
		propStream.init(attr, attrSize);
		loadItems(itemMap, result, propStream, player);
		Container* storage = player->getTempStorage();
		if (!storage) {
			std::cout << "[Error - IOLoginData::loadPlayer Cannot load temp storage for player " << player->name << std::endl;
		} else {
			for (const auto& it : itemMap) {
				Item* item = it.second;
				g_events->eventPlayerOnItemLoad(player, item);
				storage->internalAddThing(item);
				item->startDecaying();
			}
		}
	}

	//load vip
	query.clear();
	query << "SELECT `player_id` FROM `account_viplist` WHERE `account_id` = " << player->getAccount();
	if ((result = g_database.storeQuery(query))) {
		do {
			player->addVIPInternal(result->getNumber<uint32_t>("player_id"));
		} while (result->next());
	}

	player->updateBaseSpeed();
	player->updateInventoryWeight();
	player->updateItemsLight(true);
	loadAccountStorages(player);
	return true;
}

void IOLoginData::saveItem(PropWriteStream& stream, Item* item, std::map<Container*, int>& openContainers)
{
	Container* container = item->getContainer();
	if (!container) {
		// Write ID & props
		stream.write<uint16_t>(item->getID());
		item->serializeAttr(stream);
		stream.write<uint8_t>(0x00); // attr end
		return;
	}

	// Write ID & props
	stream.write<uint16_t>(item->getID());
	item->serializeAttr(stream);

	// Hack our way into the attributes
	stream.write<uint8_t>(ATTR_CONTAINER_ITEMS);
	stream.write<uint32_t>(container->size());

	//Reserve a little space before to avoid massive reallocations
	std::vector<std::pair<Container*, ItemDeque::const_reverse_iterator>> savingContainers; savingContainers.reserve(100);
	savingContainers.emplace_back(container, container->getReversedItems());
	while (!savingContainers.empty()) {
		StartSavingContainers:
		container = savingContainers.back().first;
		ItemDeque::const_reverse_iterator& it = savingContainers.back().second;
		for (auto end = container->getReversedEnd(); it != end; ++it) {
			item = (*it);
			Container* containerx = item->getContainer();
			if (!containerx) {
				// Write ID & props
				stream.write<uint16_t>(item->getID());
				item->serializeAttr(stream);
				stream.write<uint8_t>(0x00); // attr end
			} else {
				// Write ID & props

				stream.write<uint16_t>(item->getID());
				item->serializeAttr(stream);

				// Hack our way into the attributes
				stream.write<uint8_t>(ATTR_CONTAINER_ITEMS);
				stream.write<uint32_t>(containerx->size());

				++it; // Since we're going out of loop increase our iterator here
				savingContainers.emplace_back(containerx, containerx->getReversedItems());
				goto StartSavingContainers;
			}
		}
		stream.write<uint8_t>(0x00); // attr end
		savingContainers.pop_back();
	}
}

bool IOLoginData::saveItems(const Player* player, const ItemBlockList& itemList, std::stringExtended& query, PropWriteStream& propWriteStream, const std::string& table, std::map<Container*, int>& openContainers)
{
	for (const auto& it : itemList) {
		int32_t pid = it.first;
		Item* item = it.second;
		propWriteStream.write<int32_t>(pid);
		saveItem(propWriteStream, item, openContainers);
	}

	size_t attributesSize;
	const char* attributes = propWriteStream.getStream(attributesSize);
	if (attributesSize > 0) {
		query << "UPDATE `players` SET `" << table << "` = " << g_database.escapeBlob(attributes, attributesSize) << " WHERE `id` = " << player->getGUID();
		if (!g_database.executeQuery(query)) {
			return false;
		}
	} else {
		query << "UPDATE `players` SET `" << table << "` = NULL WHERE `id` = " << player->getGUID();
		if (!g_database.executeQuery(query)) {
			return false;
		}
	}
	return true;
}

bool IOLoginData::saveItemsAsync(const Player* player, const ItemBlockList& itemList, PropWriteStream& propWriteStream, const std::string& table, std::map<Container*, int>& openContainers)
{
	// Serialize items (must be done in main thread to access game objects safely)
	for (const auto& it : itemList) {
		int32_t pid = it.first;
		Item* item = it.second;
		propWriteStream.write<int32_t>(pid);
		saveItem(propWriteStream, item, openContainers);
	}

	// Get serialized data
	size_t attributesSize;
	const char* attributes = propWriteStream.getStream(attributesSize);
	uint32_t playerGUID = player->getGUID();
	
	if (attributesSize > 0) {
		// Copy the binary data to pass to background thread
		std::string serializedData(attributes, attributesSize);
		std::string tableName = table;
		
		// Move expensive escapeBlob and DB write to background thread
		std::thread([serializedData, tableName, playerGUID]() {
			Database db;
			if (!db.connect()) {
				std::cout << "[IOLoginData::saveItemsAsync] Failed to connect to database in background thread" << std::endl;
				return;
			}
			
			std::string blobData = db.escapeBlob(serializedData.c_str(), serializedData.length());
			std::string queryStr = "UPDATE `players` SET `" + tableName + "` = " + blobData + " WHERE `id` = " + std::to_string(playerGUID);
			
			if (!db.executeQuery(queryStr)) {
				std::cout << "[IOLoginData::saveItemsAsync] Failed to save " << tableName << " for player " << playerGUID << std::endl;
			}

			db.disconnect();
		}).detach();
	} else {
		std::string tableName = table;
		
		// Empty data - still need to update to NULL in background
		std::thread([tableName, playerGUID]() {
			Database db;
			if (!db.connect()) {
				std::cout << "[IOLoginData::saveItemsAsync] Failed to connect to database in background thread" << std::endl;
				return;
			}
			
			std::string queryStr = "UPDATE `players` SET `" + tableName + "` = NULL WHERE `id` = " + std::to_string(playerGUID);
			
			if (!db.executeQuery(queryStr)) {
				std::cout << "[IOLoginData::saveItemsAsync] Failed to save " << tableName << " for player " << playerGUID << std::endl;
			}
			db.disconnect();
		}).detach();
	}
	return true;
}

bool IOLoginData::savePlayer(Player* player, bool isLogout)
{
	// Safety check: ensure player is valid
	if (!player) {
		std::cout << "[IOLoginData::savePlayer] ERROR: Attempted to save NULL player" << std::endl;
		return false;
	}

	if (player->isRemoved()) {
		std::cout << "[IOLoginData::savePlayer] WARNING: Player " << player->name << " is already removed, skipping save" << std::endl;
		return false;
	}

	if (player->getHealth() <= 0) {
		player->changeHealth(1);
	}

	player->sendServerTime();

	// For online saves, do a fast async save without synchronous database checks
	if (!isLogout) {
		// Build UPDATE query with player stats and conditions/storages
		std::stringExtended query(4096);
		query << "UPDATE `players` SET ";
		query << "`level` = " << player->level;
		query << ",`group_id` = " << player->group->id;
		query << ",`vocation` = " << player->getVocationId();
		query << ",`health` = " << player->health;
		query << ",`healthmax` = " << player->healthMax;
		query << ",`experience` = " << player->experience;
		query << ",`mana` = " << player->mana;
		query << ",`manamax` = " << player->manaMax;
		query << ",`dungeontier` = " << player->dungeonTier;
		query << ",`dps` = " << player->dps;
		query << ",`kills` = " << player->kills;
		query << ",`deaths` = " << player->deaths;
		query << ",`town_id` = " << player->town->getID();
		query << ",`sex` = " << player->sex;
		
		// Outfit fields
		query << ",`lookbody` = " << player->defaultOutfit.lookBody;
		query << ",`lookfeet` = " << player->defaultOutfit.lookFeet;
		query << ",`lookhead` = " << player->defaultOutfit.lookHead;
		query << ",`looklegs` = " << player->defaultOutfit.lookLegs;
		query << ",`looktype` = " << player->defaultOutfit.lookType;
		query << ",`lookaddons` = " << player->defaultOutfit.lookAddons;
		query << ",`lookwings` = " << player->defaultOutfit.lookWings;
		query << ",`lookaura` = " << player->defaultOutfit.lookAura;
		query << ",`lookoutline` = '" << player->defaultOutfit.lookOutline;
		query << "' ,`lookshader` = '" << player->defaultOutfit.lookShader << "'";
		
		const Position& loginPos = player->getLoginPosition();
		query << ",`posx` = " << loginPos.getX();
		query << ",`posy` = " << loginPos.getY();
		query << ",`posz` = " << loginPos.getZ();
		
		if (player->lastLoginSaved != 0) {
			query << ",`lastlogin` = " << player->lastLoginSaved;
		}
		if (player->lastIP != 0) {
			query << ",`lastip` = " << player->lastIP;
		}
		if (player->firstLogin == 0) {
			query << ",`firstLogin` = " << time(nullptr);
			player->firstLogin = time(nullptr);
		}
		
		// Serialize conditions (buffs/debuffs)
		PropWriteStream conditionStream;
		for (Condition* condition : player->conditions) {
			if (condition->isPersistent()) {
				if (condition->getType() != CONDITION_OUTFIT) {
					condition->serialize(conditionStream);
					conditionStream.write<uint8_t>(CONDITIONATTR_END);
				}
			}
		}
		size_t conditionSize;
		const char* conditionData = conditionStream.getStream(conditionSize);
		query << ",`conditions` = " << g_database.escapeBlob(conditionData, conditionSize);
		
		// Serialize player storages (quest progress, etc.)
		PropWriteStream storageStream;
		storageStream.write<size_t>(player->storageMap.size());
		for (const auto& it : player->storageMap) {
			storageStream.write<uint32_t>(it.first);
			storageStream.write<int32_t>(it.second);
		}
		size_t storageSize;
		const char* storageData = storageStream.getStream(storageSize);
		if (storageSize > 0) {
			query << ",`storages` = " << g_database.escapeBlob(storageData, storageSize);
		} else {
			query << ",`storages` = NULL";
		}
		
		query << ",`lastlogout` = " << player->getLastLogout();
		query << ",`stat_str` = " << player->charStats[CHARSTAT_STRENGTH];
		query << ",`stat_int` = " << player->charStats[CHARSTAT_INTELLIGENCE];
		query << ",`stat_speed` = " << player->charStats[CHARSTAT_SPEED];
		query << ",`stat_vit` = " << player->charStats[CHARSTAT_VITALITY];
		query << ",`stat_ski` = " << player->charStats[CHARSTAT_SKILL];
		query << ",`stat_dex` = " << player->charStats[CHARSTAT_DEXTERITY];
		query << ",`stat_spr` = " << player->charStats[CHARSTAT_SPIRIT];
		query << ",`stat_wis` = " << player->charStats[CHARSTAT_WISDOM];
		query << ",`stat_per` = " << player->charStats[CHARSTAT_PERCEPTION];
		query << ",`stat_dmg` = " << player->charStats[CHARSTAT_CRITICAL_DAMAGE];
		query << ",`stat_reg` = " << player->charStats[CHARSTAT_REGEN];
		query << ",`stat_lif` = " << player->charStats[CHARSTAT_LIFE];
		query << ",`stat_move` = " << player->charStats[CHARSTAT_MOVEMENT_SPEED];
		query << ",`stat_one` = " << player->charStats[CHARSTAT_ONE];
		query << ",`stat_two` = " << player->charStats[CHARSTAT_TWO];
		query << ",`stat_hphit` = " << player->charStats[CHARSTAT_HPHIT];
		query << ",`stat_eshit` = " << player->charStats[CHARSTAT_ESHIT];
		query << ",`direction` = " << player->getDirection();
		
		if (!player->isOffline() && player->lastLoginSaved != 0) {
			time_t now = time(nullptr);
			query << ",`onlinetime` = `onlinetime` + " << (now - player->lastLoginSaved);
			player->lastLoginSaved = now;
		}
		query << " WHERE `id` = " << player->getGUID();
		
		// Send stats query to async database task queue
		g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
		
		// Save account balance and storages async
		saveAccountBalance(player);
		saveAccountStorages(player);
		
		// Now serialize items on main thread (safe - just reading data)
		// Then send serialized data to background thread for database writes
		std::map<Container*, int> openContainers;
		for (auto container : player->getOpenContainers()) {
			if (!container.second.container) continue;
			openContainers[container.second.container] = container.first;
		}
		
		// Structure to hold serialized item data
		struct SerializedItemData {
			std::string serializedData;
			std::string tableName;
			bool isAccountTable;
		};
		std::vector<SerializedItemData> serializedItems;
		
		// Helper lambda to serialize an item list
		auto serializeItemList = [&](const ItemBlockList& itemList, const std::string& tableName) {
			PropWriteStream propWriteStream;
			std::map<Container*, int> openContainersCopy = openContainers;
			
			for (const auto& it : itemList) {
				int32_t pid = it.first;
				Item* item = it.second;
				if (!item) continue;
				
				propWriteStream.write<int32_t>(pid);
				saveItem(propWriteStream, item, openContainersCopy);
			}
			
			size_t attributesSize;
			const char* attributes = propWriteStream.getStream(attributesSize);
			
			SerializedItemData data;
			data.serializedData = std::string(attributes, attributesSize);
			data.tableName = tableName;
			data.isAccountTable = (tableName == "depotitems" || tableName == "depotlockeritems" || tableName == "inboxitems");
			serializedItems.push_back(std::move(data));
		};
		
		// Serialize inventory items
		ItemBlockList itemList;
		for (int32_t slotId = 1; slotId <= CONST_SLOT_LAST + 1; ++slotId) {
			Item* item = player->inventory[slotId];
			if (item) {
				itemList.emplace_back(slotId, item);
			}
		}
		serializeItemList(itemList, "items");
		
		// Serialize depot locker items
		if (player->lastDepotId != -1) {
			itemList.clear();
			for (const auto& it : player->depotLockerMap) {
				DepotLocker* depotLocker = it.second;
				for (auto item = depotLocker->getReversedItems(), end = depotLocker->getReversedEnd(); item != end; ++item) {
					uint16_t itemId = (*item)->getID();
					if (itemId == ITEM_DEPOT || itemId == ITEM_INBOX || itemId == ITEM_MARKET) {
						continue;
					}
					itemList.emplace_back(static_cast<int32_t>(it.first), *item);
				}
			}
			serializeItemList(itemList, "depotlockeritems");
			
			// Serialize depot items
			itemList.clear();
			for (const auto& it : player->depotChests) {
				DepotChest* depotChest = it.second;
				for (auto item = depotChest->getReversedItems(), end = depotChest->getReversedEnd(); item != end; ++item) {
					itemList.emplace_back(static_cast<int32_t>(it.first), *item);
				}
			}
			serializeItemList(itemList, "depotitems");
		}
		
		// Serialize inbox items
		itemList.clear();
		for (auto item = player->getInbox()->getReversedItems(), end = player->getInbox()->getReversedEnd(); item != end; ++item) {
			itemList.emplace_back(0, *item);
		}
		serializeItemList(itemList, "inboxitems");
		
		// Serialize temp storage items
		itemList.clear();
		for (auto item = player->getTempStorage()->getReversedItems(), end = player->getTempStorage()->getReversedEnd(); item != end; ++item) {
			itemList.emplace_back(0, *item);
		}
		serializeItemList(itemList, "tempstorage");
		
		// Now send serialized item data to background thread for database writes
		uint32_t playerGUID = player->getGUID();
		uint32_t accountId = player->getAccount();
		std::string playerName = player->name;
		
		std::thread([serializedItems, playerGUID, accountId, playerName]() {
			Database db;
			if (!db.connect()) {
				std::cout << "[IOLoginData::savePlayer] " << playerName << " - CRITICAL: Failed to connect to database for item save!" << std::endl;
				return;
			}
			
			// Save each serialized item group
			for (const auto& saveData : serializedItems) {
				std::stringExtended query(1024);
				
				if (saveData.serializedData.length() > 0) {
					if (saveData.isAccountTable) {
						query << "UPDATE `accounts` SET `" << saveData.tableName << "` = " << db.escapeBlob(saveData.serializedData.c_str(), saveData.serializedData.length()) << " WHERE `id` = " << accountId;
					} else {
						query << "UPDATE `players` SET `" << saveData.tableName << "` = " << db.escapeBlob(saveData.serializedData.c_str(), saveData.serializedData.length()) << " WHERE `id` = " << playerGUID;
					}
				} else {
					if (saveData.isAccountTable) {
						query << "UPDATE `accounts` SET `" << saveData.tableName << "` = NULL WHERE `id` = " << accountId;
					} else {
						query << "UPDATE `players` SET `" << saveData.tableName << "` = NULL WHERE `id` = " << playerGUID;
					}
				}
				
				if (!db.executeQuery(query)) {
					std::cout << "[IOLoginData::savePlayer] " << playerName << " - CRITICAL: Failed to save " << saveData.tableName << std::endl;
				}
			}
			
			db.disconnect();
		}).detach();
		
		return true;
	}

	// Full logout save with synchronous checks below
	std::stringExtended query(2048);
	query << "SELECT `save` FROM `players` WHERE `id` = " << player->getGUID() << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		std::cout << "[IOLoginData::savePlayer] ERROR: Player " << player->name << " not found in database" << std::endl;
		return false;
	}

	if (result->getNumber<uint16_t>("save") == 0) {
		query.clear();
		query << "UPDATE `players` SET `lastlogin` = " << player->lastLoginSaved << ", `lastip` = " << player->lastIP << " WHERE `id` = " << player->getGUID();
		return g_database.executeQuery(query);
	}

	// Build full UPDATE query with all player data
	query.clear();
	query << "UPDATE `players` SET ";
	query << "`level` = " << player->level;
	query << ",`group_id` = " << player->group->id;
	query << ",`vocation` = " << player->getVocationId();
	query << ",`health` = " << player->health;
	query << ",`healthmax` = " << player->healthMax;
	query << ",`experience` = " << player->experience;
	query << ",`lookbody` = " << player->defaultOutfit.lookBody;
	query << ",`lookfeet` = " << player->defaultOutfit.lookFeet;
	query << ",`lookhead` = " << player->defaultOutfit.lookHead;
	query << ",`looklegs` = " << player->defaultOutfit.lookLegs;
	query << ",`looktype` = " << player->defaultOutfit.lookType;
	query << ",`lookaddons` = " << player->defaultOutfit.lookAddons;
	query << ",`lookwings` = " << player->defaultOutfit.lookWings;
	query << ",`lookaura` = " << player->defaultOutfit.lookAura;
	query << ",`lookoutline` = '" << player->defaultOutfit.lookOutline;
	query << "' ,`lookshader` = '" << player->defaultOutfit.lookShader;
	query << "' ,`mana` = " << player->mana;
	query << ",`manamax` = " << player->manaMax;
	query << ",`dungeontier` = " << player->dungeonTier;
	query << ",`dps` = " << player->dps;
	query << ",`kills` = " << player->kills;
	query << ",`deaths` = " << player->deaths;
	query << ",`town_id` = " << player->town->getID();

	const Position& loginPosition = player->getLoginPosition();
	query << ",`posx` = " << loginPosition.getX();
	query << ",`posy` = " << loginPosition.getY();
	query << ",`posz` = " << loginPosition.getZ();

	query << ",`sex` = " << player->sex;
	if (player->lastLoginSaved != 0) {
		query << ",`lastlogin` = " << player->lastLoginSaved;
	}

	if (player->firstLogin == 0) {
		query << ",`firstLogin` = " << time(nullptr);
	}

	if (player->lastIP != 0) {
		query << ",`lastip` = " << player->lastIP;
	}

	//serialize conditions
	PropWriteStream propWriteStream;
	for (Condition* condition : player->conditions) {
		if (condition->isPersistent()) {
			if (condition->getType() != CONDITION_OUTFIT) {
				condition->serialize(propWriteStream);
				propWriteStream.write<uint8_t>(CONDITIONATTR_END);
			}
		}
	}

	size_t attributesSize;
	const char* attributes = propWriteStream.getStream(attributesSize);

	query << ",`conditions` = " << g_database.escapeBlob(attributes, attributesSize);

	// storages
	propWriteStream.clear();
	propWriteStream.write<size_t>(player->storageMap.size());
	for (const auto& it : player->storageMap) {
		propWriteStream.write<uint32_t>(it.first);
		propWriteStream.write<int32_t>(it.second);
	}

	attributes = propWriteStream.getStream(attributesSize);
	if (attributesSize > 0) {
		query << ",`storages` = " << g_database.escapeBlob(attributes, attributesSize);
	} else {
		query << ",`storages` = NULL";
	}

	query << ",`lastlogout` = " << player->getLastLogout();
	query << ",`stat_str` = " << player->charStats[CHARSTAT_STRENGTH];
	query << ",`stat_int` = " << player->charStats[CHARSTAT_INTELLIGENCE];
	query << ",`stat_speed` = " << player->charStats[CHARSTAT_SPEED];
	query << ",`stat_vit` = " << player->charStats[CHARSTAT_VITALITY];
	query << ",`stat_ski` = " << player->charStats[CHARSTAT_SKILL];
	query << ",`stat_dex` = " << player->charStats[CHARSTAT_DEXTERITY];
	query << ",`stat_spr` = " << player->charStats[CHARSTAT_SPIRIT];
	query << ",`stat_wis` = " << player->charStats[CHARSTAT_WISDOM];
	query << ",`stat_per` = " << player->charStats[CHARSTAT_PERCEPTION];
	query << ",`stat_dmg` = " << player->charStats[CHARSTAT_CRITICAL_DAMAGE];
	query << ",`stat_reg` = " << player->charStats[CHARSTAT_REGEN];
	query << ",`stat_lif` = " << player->charStats[CHARSTAT_LIFE];
	query << ",`stat_move` = " << player->charStats[CHARSTAT_MOVEMENT_SPEED];
	query << ",`stat_one` = " << player->charStats[CHARSTAT_ONE];
	query << ",`stat_two` = " << player->charStats[CHARSTAT_TWO];
	query << ",`stat_hphit` = " << player->charStats[CHARSTAT_HPHIT];
	query << ",`stat_eshit` = " << player->charStats[CHARSTAT_ESHIT];

	query << ",`direction` = " << player->getDirection();
	if (!player->isOffline() && player->lastLoginSaved != 0) {
		time_t now = time(nullptr);
		query << ",`onlinetime` = `onlinetime` + " << (now - player->lastLoginSaved);
		player->lastLoginSaved = now;
	}
	query << " WHERE `id` = " << player->getGUID();

	// Execute player data update synchronously
	if (!g_database.executeQuery(query)) {
		return false;
	}

	// Save account-level balance
	saveAccountBalance(player);

	// CRITICAL: Check if items are already being saved in background
	// This prevents death from triggering a redundant item save while one is in progress
	if (!g_game.startPlayerSession(player->getGUID())) {
		std::cout << "[IOLoginData::savePlayer] " << player->name << " - Stats saved, but item save already in progress. Skipping redundant item save." << std::endl;
		return true;
	}
	
	// Start account-level session to block other characters on same account from logging in during save
	if (!g_game.startAccountSession(player->getAccount())) {
		std::cout << "[IOLoginData::savePlayer] " << player->name << " - Account save already in progress by another character." << std::endl;
		g_game.stopPlayerSession(player->getGUID());
		return true;
	}
	
	// Set local flag for legacy code compatibility
	player->isSaving.store(true);

	//item saving - prepare data in main thread, serialize and save in background thread
	std::map<Container*, int> openContainers;
	for (auto container : player->getOpenContainers()) {
		if (!container.second.container) continue;
		openContainers[container.second.container] = container.first;
	}

	// Collect all item lists that need to be saved
	struct ItemSaveData {
		ItemBlockList itemList;
		std::string tableName;
	};
	
	std::vector<ItemSaveData> allItemData;
	
	// Inventory items
	query.clear();
	ItemBlockList itemList;
	for (int32_t slotId = 1; slotId <= CONST_SLOT_LAST + 1; ++slotId) {
		Item* item = player->inventory[slotId];
		if (item) {
			itemList.emplace_back(slotId, item);
		}
	}
	allItemData.push_back({itemList, "items"});

	// Depot locker items
	if (player->lastDepotId != -1) {
		itemList.clear();
		for (const auto& it : player->depotLockerMap) {
			DepotLocker* depotLocker = it.second;
			for (auto item = depotLocker->getReversedItems(), end = depotLocker->getReversedEnd(); item != end; ++item) {
				uint16_t itemId = (*item)->getID();
				if (itemId == ITEM_DEPOT || itemId == ITEM_INBOX || itemId == ITEM_MARKET) {
					continue;
				}
				itemList.emplace_back(static_cast<int32_t>(it.first), *item);
			}
		}
		allItemData.push_back({itemList, "depotlockeritems"});

		// Depot items
		itemList.clear();
		for (const auto& it : player->depotChests) {
			DepotChest* depotChest = it.second;
			for (auto item = depotChest->getReversedItems(), end = depotChest->getReversedEnd(); item != end; ++item) {
				itemList.emplace_back(static_cast<int32_t>(it.first), *item);
			}
		}
		allItemData.push_back({itemList, "depotitems"});
	}

	// Inbox items
	itemList.clear();
	for (auto item = player->getInbox()->getReversedItems(), end = player->getInbox()->getReversedEnd(); item != end; ++item) {
		itemList.emplace_back(0, *item);
	}
	allItemData.push_back({itemList, "inboxitems"});

	// Temp storage items
	itemList.clear();
	for (auto item = player->getTempStorage()->getReversedItems(), end = player->getTempStorage()->getReversedEnd(); item != end; ++item) {
		itemList.emplace_back(0, *item);
	}
	allItemData.push_back({itemList, "tempstorage"});

	// Only increment refCounts on logout to prevent deletion during async save
	// For online players, items can't be deleted while they're in the game,
	// so we don't need to touch refCounts (which could cause issues with active items)
	if (isLogout) {
		for (const auto& saveData : allItemData) {
			for (const auto& it : saveData.itemList) {
				if (it.second) {
					it.second->incrementReferenceCounter();
				}
			}
		}
	}

	// Prepare data for background thread
	uint32_t playerGUID = player->getGUID();
	uint32_t accountId = player->getAccount();
	std::string playerName = player->name;
	bool shouldReleaseItems = isLogout; // Only release items (allow deletion) on logout
	
	// Spawn background thread to serialize and save all items
	// For logout: reference counters protect against deletion
	// For online: items can't be deleted while player is in game
	std::thread([allItemData, openContainers, playerGUID, accountId, playerName, shouldReleaseItems]() {
		Database db;
		if (!db.connect()) {
			std::cout << "[IOLoginData::savePlayer] " << playerName << " - CRITICAL: Failed to connect to database in background thread - items NOT saved!" << std::endl;
			// Only need to handle refCounts on logout
			if (shouldReleaseItems) {
				g_dispatcher.addTask([allItemData, playerGUID, accountId]() {
					for (const auto& saveData : allItemData) {
						for (const auto& it : saveData.itemList) {
							if (it.second) {
								g_game.ReleaseItem(it.second);
							}
						}
					}
					g_game.stopPlayerSession(playerGUID);
					g_game.stopAccountSession(accountId);
				});
			} else {
				g_dispatcher.addTask([playerGUID, accountId]() {
					g_game.stopPlayerSession(playerGUID);
					g_game.stopAccountSession(accountId);
				});
			}
			return;
		}
		
		// Serialize and save each item group
		for (const auto& saveData : allItemData) {
			try {
				PropWriteStream propWriteStream;
				std::map<Container*, int> openContainersCopy = openContainers;
				
				// Serialize items
				for (const auto& it : saveData.itemList) {
					int32_t pid = it.first;
					Item* item = it.second;
					if (!item) {
						std::cout << "[IOLoginData::savePlayer] " << playerName << " - WARNING: NULL item in " << saveData.tableName << std::endl;
						continue;
					}
					
					propWriteStream.write<int32_t>(pid);
					saveItem(propWriteStream, item, openContainersCopy);
				}
				
				// Save to database
				size_t attributesSize;
				const char* attributes = propWriteStream.getStream(attributesSize);
				
				std::stringExtended query(1024);
				bool isAccountTable = (saveData.tableName == "depotitems" || 
				                       saveData.tableName == "depotlockeritems" || 
				                       saveData.tableName == "inboxitems");
				
				if (attributesSize > 0) {
					if (isAccountTable) {
						query << "UPDATE `accounts` SET `" << saveData.tableName << "` = " << db.escapeBlob(attributes, attributesSize) << " WHERE `id` = " << accountId;
					} else {
						query << "UPDATE `players` SET `" << saveData.tableName << "` = " << db.escapeBlob(attributes, attributesSize) << " WHERE `id` = " << playerGUID;
					}
				} else {
					if (isAccountTable) {
						query << "UPDATE `accounts` SET `" << saveData.tableName << "` = NULL WHERE `id` = " << accountId;
					} else {
						query << "UPDATE `players` SET `" << saveData.tableName << "` = NULL WHERE `id` = " << playerGUID;
					}
				}
				
				if (!db.executeQuery(query)) {
					std::cout << "[IOLoginData::savePlayer] " << playerName << " - CRITICAL: Failed to save " << saveData.tableName << " (async)" << std::endl;
				}
			} catch (const std::exception& e) {
				std::cout << "[IOLoginData::savePlayer] " << playerName << " - EXCEPTION while saving " << saveData.tableName << ": " << e.what() << std::endl;
			} catch (...) {
				std::cout << "[IOLoginData::savePlayer] " << playerName << " - UNKNOWN EXCEPTION while saving " << saveData.tableName << std::endl;
			}
		}
		
		// Cleanup on main thread
		if (shouldReleaseItems) {
			// Logout: release items (allows deletion when refCount reaches 0)
			g_dispatcher.addTask([allItemData, playerGUID, accountId]() {
				for (const auto& saveData : allItemData) {
					for (const auto& it : saveData.itemList) {
						if (it.second) {
							g_game.ReleaseItem(it.second);
						}
					}
				}
				g_game.stopPlayerSession(playerGUID);
				g_game.stopAccountSession(accountId);
			});
		} else {
			// Online: just clear session flags, don't touch items
			g_dispatcher.addTask([playerGUID, accountId]() {
				g_game.stopPlayerSession(playerGUID);
				g_game.stopAccountSession(accountId);
			});
		}
		
		db.disconnect();
	}).detach();

	saveAccountStorages(player);
	
	return true;
}

std::string IOLoginData::getNameByGuid(uint32_t guid)
{
	std::stringExtended query(64);
	query << "SELECT `name` FROM `players` WHERE `id` = " << guid << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return std::string();
	}
	return result->getString("name");
}

uint32_t IOLoginData::getGuidByName(const std::string& name)
{
	const std::string& escapedName = g_database.escapeString(name);
	std::stringExtended query(escapedName.length() + static_cast<size_t>(64));
	query << "SELECT `id` FROM `players` WHERE `name` = " << escapedName << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return 0;
	}
	return result->getNumber<uint32_t>("id");
}

bool IOLoginData::getGuidByNameEx(uint32_t& guid, bool& specialVip, std::string& name)
{
	const std::string& escapedName = g_database.escapeString(name);
	std::stringExtended query(escapedName.length() + static_cast<size_t>(128));
	query << "SELECT `name`, `id`, `group_id`, `account_id` FROM `players` WHERE `name` = " << escapedName << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	name = std::move(result->getString("name"));
	guid = result->getNumber<uint32_t>("id");
	Group* group = g_game.groups.getGroup(result->getNumber<uint16_t>("group_id"));

	uint64_t flags;
	if (group) {
		flags = group->flags;
	} else {
		flags = 0;
	}

	specialVip = (flags & PlayerFlag_SpecialVIP) != 0;
	return true;
}

bool IOLoginData::formatPlayerName(std::string& name)
{
	const std::string& escapedName = g_database.escapeString(name);
	std::stringExtended query(escapedName.length() + static_cast<size_t>(64));
	query << "SELECT `name` FROM `players` WHERE `name` = " << escapedName << " LIMIT 1";

	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return false;
	}

	name = std::move(result->getString("name"));
	return true;
}

void IOLoginData::increaseBankBalance(uint32_t guid, uint64_t bankBalance)
{
	// Note: Balance is now stored in accounts table (shared across all characters)
	// This function looks up the account_id from the player guid and updates the account balance
	std::stringExtended query(256);
	query << "UPDATE `accounts` SET `balance` = `balance` + " << bankBalance 
	      << " WHERE `id` = (SELECT `account_id` FROM `players` WHERE `id` = " << guid << " LIMIT 1)";
	g_database.executeQuery(query);
}

bool IOLoginData::hasBiddedOnHouse(uint32_t guid)
{
	std::stringExtended query(128);
	query << "SELECT `id` FROM `houses` WHERE `highest_bidder` = " << guid << " LIMIT 1";
	return g_database.storeQuery(query).get() != nullptr;
}

void IOLoginData::addVIPEntry(uint32_t accountId, uint32_t guid, const std::string& description, uint32_t icon, bool notify)
{
	const std::string& escapedDescription = g_database.escapeString(description);
	std::stringExtended query(escapedDescription.length() + static_cast<size_t>(256));
	query << "INSERT IGNORE INTO `account_viplist` (`account_id`, `player_id`, `description`, `icon`, `notify`) VALUES (" << accountId << ',' << guid << ',';
	query << escapedDescription << ',' << icon << ',' << (notify ? "1" : "0") << ')';
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
}

void IOLoginData::editVIPEntry(uint32_t accountId, uint32_t guid, const std::string& description, uint32_t icon, bool notify)
{
	const std::string& escapedDescription = g_database.escapeString(description);
	std::stringExtended query(escapedDescription.length() + static_cast<size_t>(256));
	query << "UPDATE `account_viplist` SET `description` = " << escapedDescription << ", `icon` = " << icon << ", `notify` = " << (notify ? "1" : "0");
	query << " WHERE `account_id` = " << accountId << " AND `player_id` = " << guid;
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
}

void IOLoginData::removeVIPEntry(uint32_t accountId, uint32_t guid)
{
	std::stringExtended query(128);
	query << "DELETE FROM `account_viplist` WHERE `account_id` = " << accountId << " AND `player_id` = " << guid;
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)));
}

uint32_t IOLoginData::getPlayerIP(uint32_t accountId)
{
	std::stringExtended query(64);
	query << "SELECT `ip` FROM `accounts` WHERE `id` = " << accountId << " LIMIT 1";
	DBResult_ptr result = g_database.storeQuery(query);
	if (!result) {
		return 0;
	}

	return result->getNumber<uint32_t>("ip");
}

std::vector<CamInfo> IOLoginData::getCamsByHash(const std::string& hash)
{
	std::vector<CamInfo> entries;

	std::stringExtended query(128);
	query << "SELECT `players`.`name` as `name`, `cams`.`hash` as `hash`, `players`.`id` as `playerId` FROM `cams` LEFT JOIN `players` on `players`.`id` = `cams`.`player` WHERE `cams`.`hash` = " << hash;

	DBResult_ptr result = g_database.storeQuery(query);
	if (result) {
		do {
			entries.push_back(CamInfo{
				result->getString("name"),
				result->getNumber<uint32_t>("playerId"),
				result->getString("hash")
							  });
		} while (result->next());
	}
	return entries;
}

std::vector<CamInfo> IOLoginData::getCamsByAccount(uint32_t accountId)
{
	std::vector<CamInfo> entries;

	std::stringExtended query(128);
	query << "SELECT `players`.`name` as `name`, `cams`.`hash` as `hash`, `players`.`id` as `playerId` FROM `cams` LEFT JOIN `players` on `players`.`id` = `cams`.`player` WHERE `players`.`account_id` = " << accountId;

	DBResult_ptr result = g_database.storeQuery(query);
	if (result) {
		do {
			entries.push_back(CamInfo{
				result->getString("name"),
				result->getNumber<uint32_t>("playerId"),
				result->getString("hash")
							  });
		} while (result->next());
	}
	return entries;
}

void IOLoginData::loadMarketItems()
{
	Container* marketBox = g_game.createMarketBox();;
	std::stringExtended query(64);
	query << "SELECT `items` FROM `market_items` WHERE `id` = 1";
	DBResult_ptr result = g_database.storeQuery(query);
	unsigned long attrSize;
	const char* attr;
	ItemBlockList itemMap;
	if (result) {
		attr = result->getStream("items", attrSize);
		PropStream propStream;
		propStream.init(attr, attrSize);
		loadItems(itemMap, result, propStream, nullptr);
		for (const auto& it : itemMap) {
			Item* item = it.second;
			marketBox->internalAddThing(item);
			item->startDecaying();
		}
	}
}

bool IOLoginData::saveMarketItems()
{
	std::stringExtended query(1024);
	PropWriteStream propWriteStream;
	ItemBlockList itemList;

	for (auto item = g_game.getMarketBox()->getReversedItems(), end = g_game.getMarketBox()->getReversedEnd(); item != end; ++item) {
		itemList.emplace_back(0, *item);
	}

	for (const auto& it : itemList) {
		int32_t pid = it.first;
		Item* item = it.second;

		propWriteStream.write<int32_t>(pid);
		std::map<Container*, int> openContainers;
		saveItem(propWriteStream, item, openContainers);
	}

	size_t attributesSize;
	const char* attributes = propWriteStream.getStream(attributesSize);
	if (attributesSize > 0) {
		query << "UPDATE `market_items` SET `items` = " << g_database.escapeBlob(attributes, attributesSize) << " WHERE `id` = 1";
		if (!g_database.executeQuery(query)) {
			return false;
		}
	} else {
		query << "UPDATE `market_items` SET `items` = NULL WHERE `id` = 1";
		if (!g_database.executeQuery(query)) {
			return false;
		}
	}
	return true;
}