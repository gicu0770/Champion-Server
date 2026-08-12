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

#ifndef FS_IOLOGINDATA_H_28B0440BEC594654AC0F4E1A5E42B2EF
#define FS_IOLOGINDATA_H_28B0440BEC594654AC0F4E1A5E42B2EF

#include "account.h"
#include "player.h"
#include "database.h"
#include "cams.h"

using ItemBlockList = std::vector<std::pair<int32_t, Item*>>;

class IOLoginData
{
	public:
		static Account loadAccount(uint32_t accno);
		static bool saveAccount(const Account& acc);
		static bool saveAccountStorages(Player* player);
		static bool loadAccountStorages(Player* player);

		// Account-based depot/inbox/balance functions
		static bool loadAccountDepot(Player* player);
		static bool loadAccountInbox(Player* player);
		static bool loadAccountBalance(Player* player);
		static bool saveAccountBalance(Player* player);
		static void increaseAccountBankBalance(uint32_t accountId, uint64_t bankBalance);

		static bool loginserverAuthentication(const std::string& name, const std::string& password, Account& account, uint32_t ip = 0);
		#if GAME_FEATURE_SESSIONKEY > 0
		static uint32_t gameworldAuthentication(const std::string& accountName, const std::string& password, std::string& characterName, std::string& token, uint32_t tokenTime);
		#else
		static uint32_t gameworldAuthentication(const std::string& accountName, const std::string& password, std::string& characterName);
		#endif
		#if GAME_FEATURE_SESSIONKEY > 0
		static uint32_t getAccountId(const std::string& accountName, const std::string& password, std::string& token, uint32_t tokenTime);
		#else
		static uint32_t getAccountId(const std::string& accountName, const std::string& password);
		#endif

		static AccountType_t getAccountType(uint32_t accountId);
		static void setAccountType(uint32_t accountId, AccountType_t accountType);
		static void updateOnlineStatus(uint32_t guid, bool login);
		static bool preloadPlayer(Player* player, const std::string& name);

		static bool loadPlayerById(Player* player, uint32_t id);
		static bool loadPlayerByName(Player* player, const std::string& name);
		static bool loadPlayer(Player* player, DBResult_ptr result);
		static bool savePlayer(Player* player, bool isLogout = true);
		static uint32_t getGuidByName(const std::string& name);
		static bool getGuidByNameEx(uint32_t& guid, bool& specialVip, std::string& name);
		static std::string getNameByGuid(uint32_t guid);
		static bool formatPlayerName(std::string& name);
		static void increaseBankBalance(uint32_t guid, uint64_t bankBalance);
		static bool hasBiddedOnHouse(uint32_t guid);

		static void addVIPEntry(uint32_t accountId, uint32_t guid, const std::string& description, uint32_t icon, bool notify);
		static void editVIPEntry(uint32_t accountId, uint32_t guid, const std::string& description, uint32_t icon, bool notify);
		static void removeVIPEntry(uint32_t accountId, uint32_t guid);

		static std::vector<CamInfo> getCamsByHash(const std::string& hash);
		static std::vector<CamInfo> getCamsByAccount(uint32_t accountId);

		static uint32_t getPlayerIP(uint32_t accountId);

		static void loadMarketItems();
		static bool saveMarketItems();

	private:
		static bool loadContainer(PropStream& propStream, Container* container, Player* player = nullptr);
		static void loadItems(ItemBlockList& itemMap, DBResult_ptr result, PropStream& stream, Player* player = nullptr);
		static void saveItem(PropWriteStream& stream, Item* item, std::map<Container*, int>& openContainers);
		static bool saveItems(const Player* player, const ItemBlockList& itemList, std::stringExtended& query, PropWriteStream& stream, const std::string& table, std::map<Container*, int>& openContainer);
		static bool saveItemsAsync(const Player* player, const ItemBlockList& itemList, PropWriteStream& stream, const std::string& table, std::map<Container*, int>& openContainer);
};

#endif