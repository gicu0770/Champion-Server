/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2020  Mark Samman <mark.samman@gmail.com>
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

#include "iomapserialize.h"
#include "game.h"
#include "bed.h"
#include <thread>
#include <vector>

extern Game g_game;

void IOMapSerialize::loadHouseItems(Map* map)
{
	int64_t start = OTSYS_TIME();

	DBResult_ptr result = g_database.storeQuery("SELECT `data` FROM `tile_store`");
	if (!result) {
		return;
	}

	do {
		unsigned long attrSize;
		const char* attr = result->getStream("data", attrSize);

		PropStream propStream;
		propStream.init(attr, attrSize);

		uint16_t x, y;
		uint8_t z;
		if (!propStream.read<uint16_t>(x) || !propStream.read<uint16_t>(y) || !propStream.read<uint8_t>(z)) {
			continue;
		}

		Tile* tile = map->getTile(x, y, z);
		if (!tile) {
			continue;
		}

		uint32_t item_count;
		if (!propStream.read<uint32_t>(item_count)) {
			continue;
		}

		while (item_count--) {
			loadItem(propStream, tile);
		}
	} while (result->next());
}

bool IOMapSerialize::saveHouseItems()
{
	int64_t start = OTSYS_TIME();

	//Start the transaction
	DBTransaction transaction(&g_database);
	if (!transaction.begin()) {
		return false;
	}

	//clear old tile data
	if (!g_database.executeQuery("DELETE FROM `tile_store`")) {
		return false;
	}

	DBInsert stmt(&g_database, "INSERT INTO `tile_store` (`house_id`, `data`) VALUES ");

	std::stringExtended query(1024);
	PropWriteStream stream;
	for (auto& it : g_game.map.houses.getHouses()) {
		//save house items
		House* house = &it.second;
		for (HouseTile* tile : house->getTiles()) {
			saveTile(stream, tile);

			size_t attributesSize;
			const char* attributes = stream.getStream(attributesSize);
			if (attributesSize > 0) {
				query.clear();
				query << house->getId() << ',' << g_database.escapeBlob(attributes, attributesSize);
				if (!stmt.addRow(query)) {
					return false;
				}
				stream.clear();
			}
		}
	}

	if (!stmt.execute()) {
		return false;
	}

	//End the transaction
	bool success = transaction.commit();
	std::cout << "> Saved house items in: " <<
	          (OTSYS_TIME() - start) / (1000.) << " s" << std::endl;
	return success;
}

void IOMapSerialize::saveHouseItemsAsync()
{
	// Step 1: Collect ALL house tile data and increment reference counters in main thread
	struct HouseTileData {
		uint32_t houseId;
		Position pos;
		std::vector<Item*> items;
	};
	
	std::vector<HouseTileData> allHouseTilesData;
	std::vector<Item*> allItems;
	
	for (auto& it : g_game.map.houses.getHouses()) {
		House* house = &it.second;
		uint32_t houseId = house->getId();
		
		for (HouseTile* tile : house->getTiles()) {
			const TileItemVector* tileItems = tile->getItemList();
			if (!tileItems) {
				continue;
			}

			HouseTileData tileData;
			tileData.houseId = houseId;
			tileData.pos = tile->getPosition();
			
			for (Item* item : *tileItems) {
				const ItemType& itemType = Item::items[item->getID()];
				// Only serialize items that are saved
				if (!(itemType.moveable || itemType.forceSerialize || item->getDoor() || 
				      (item->getContainer() && !item->getContainer()->empty()) || 
				      itemType.canWriteText || item->getBed())) {
					continue;
				}
				item->incrementReferenceCounter();
				allItems.push_back(item);
				tileData.items.push_back(item);
			}
			
			if (!tileData.items.empty()) {
				allHouseTilesData.push_back(std::move(tileData));
			}
		}
	}

	// Step 2: Move to background thread for serialization and database operations
	std::thread([allHouseTilesData, allItems]() {
		int64_t start = OTSYS_TIME();
		
		// Serialize all house tiles in background thread
		std::map<uint32_t, std::vector<std::vector<uint8_t>>> houseSerializedData;
		
		for (const auto& tileData : allHouseTilesData) {
			PropWriteStream stream;
			
			// Write tile position
			stream.write<uint16_t>(tileData.pos.x);
			stream.write<uint16_t>(tileData.pos.y);
			stream.write<uint8_t>(tileData.pos.z);
			
			// Write item count
			stream.write<uint32_t>(static_cast<uint32_t>(tileData.items.size()));
			
			// Serialize each item
			for (const Item* item : tileData.items) {
				saveItem(stream, item);
			}
			
			size_t attributesSize;
			const char* attributes = stream.getStream(attributesSize);
			if (attributesSize > 0) {
				houseSerializedData[tileData.houseId].emplace_back(attributes, attributes + attributesSize);
			}
		}
		
		// Connect to database
		Database db;
		if (!db.connect()) {
			std::cout << "[IOMapSerialize::saveHouseItemsAsync] CRITICAL: Failed to connect to database!" << std::endl;
			
			// Decrement refCounts since we're aborting
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Begin transaction
		DBTransaction transaction(&db);
		if (!transaction.begin()) {
			std::cout << "[IOMapSerialize::saveHouseItemsAsync] Failed to begin transaction" << std::endl;
			db.disconnect();
			
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Clear old tile data
		if (!db.executeQuery("DELETE FROM `tile_store`")) {
			std::cout << "[IOMapSerialize::saveHouseItemsAsync] Failed to delete old data" << std::endl;
			db.disconnect();
			
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Insert new house items
		DBInsert stmt(&db, "INSERT INTO `tile_store` (`house_id`, `data`) VALUES ");
		std::stringExtended query(1024);

		for (const auto& housePair : houseSerializedData) {
			uint32_t houseId = housePair.first;
			for (const auto& serializedData : housePair.second) {
				query.clear();
				query << houseId << ',' << db.escapeBlob(reinterpret_cast<const char*>(serializedData.data()), serializedData.size());
				if (!stmt.addRow(query)) {
					std::cout << "[IOMapSerialize::saveHouseItemsAsync] Failed to add row for house " << houseId << std::endl;
					db.disconnect();
					
					g_dispatcher.addTask([allItems]() {
						for (Item* item : allItems) {
							if (item) {
								g_game.ReleaseItem(item);
							}
						}
					});
					return;
				}
			}
		}

		if (!stmt.execute()) {
			std::cout << "[IOMapSerialize::saveHouseItemsAsync] Failed to execute insert" << std::endl;
			db.disconnect();
			
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Commit transaction
		if (!transaction.commit()) {
			std::cout << "[IOMapSerialize::saveHouseItemsAsync] Failed to commit transaction" << std::endl;
		}

		db.disconnect();

		// Decrement refCounts for all items now that save is complete
		g_dispatcher.addTask([allItems, start]() {
			for (Item* item : allItems) {
				if (item) {
					g_game.ReleaseItem(item);
				}
			}
			std::cout << "> Saved house items in: " << (OTSYS_TIME() - start) / (1000.) << " s (async)" << std::endl;
		});
	}).detach();
}

void IOMapSerialize::savePlayerHouseItems(House* xHouse, bool repeat)
{
	DBTransaction transaction(&g_database);
	if (!transaction.begin()) {
		return;
	}

	std::stringExtended deleteq(1024);
	deleteq << "DELETE FROM tile_store WHERE house_id = " << xHouse->getId();
	if (!g_database.executeQuery(deleteq)) {
		std::cout << "> FAIL DELETE: " << std::endl;
		return;
	}


	DBInsert stmt(&g_database, "INSERT INTO `tile_store` (`house_id`, `data`) VALUES ");

	std::stringExtended query(1024);
	PropWriteStream stream;
	for (HouseTile* tile : xHouse->getTiles()) {
		saveTile(stream, tile);

		size_t attributesSize;
		const char* attributes = stream.getStream(attributesSize);
		if (attributesSize > 0) {
			query.clear();
			query << xHouse->getId() << ',' << g_database.escapeBlob(attributes, attributesSize);
			if (!stmt.addRow(query)) {
				return;
			}
			stream.clear();
		}
	}

	if (!stmt.execute()) {
		return;
	}

	if (repeat) {
		g_dispatcher.addEvent(550, std::bind(&IOMapSerialize::savePlayerHouseItems, xHouse, false));
	}
}

void IOMapSerialize::savePlayerHouseItemsAsync(House* xHouse)
{
	if (!xHouse) {
		std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] ERROR: NULL house pointer" << std::endl;
		return;
	}

	uint32_t houseId = xHouse->getId();
	std::string houseName = xHouse->getName();

	// Step 1: Collect tile data and increment reference counters in main thread (fast operation)
	struct TileData {
		Position pos;
		std::vector<Item*> items;
	};
	
	std::vector<TileData> tilesData;
	tilesData.reserve(xHouse->getTiles().size());
	std::vector<Item*> allItems;

	for (HouseTile* tile : xHouse->getTiles()) {
		const TileItemVector* tileItems = tile->getItemList();
		if (!tileItems) {
			continue;
		}

		TileData tileData;
		tileData.pos = tile->getPosition();
		
		for (Item* item : *tileItems) {
			const ItemType& it = Item::items[item->getID()];
			// Only serialize items that are saved (same logic as saveTile)
			if (!(it.moveable || it.forceSerialize || item->getDoor() || (item->getContainer() && !item->getContainer()->empty()) || it.canWriteText || item->getBed())) {
				continue;
			}
			item->incrementReferenceCounter();
			allItems.push_back(item);
			tileData.items.push_back(item);
		}
		
		if (!tileData.items.empty()) {
			tilesData.push_back(std::move(tileData));
		}
	}

	// Step 2: Move to background thread for serialization and database operations
	std::thread([houseId, houseName, tilesData, allItems]() {
		// Serialize tiles in background thread (safe because items have incremented refcounts)
		std::vector<std::vector<uint8_t>> serializedTiles;
		serializedTiles.reserve(tilesData.size());
		
		for (const auto& tileData : tilesData) {
			PropWriteStream stream;
			
			// Write tile position
			stream.write<uint16_t>(tileData.pos.x);
			stream.write<uint16_t>(tileData.pos.y);
			stream.write<uint8_t>(tileData.pos.z);
			
			// Write item count
			stream.write<uint32_t>(static_cast<uint32_t>(tileData.items.size()));
			
			// Serialize each item
			for (const Item* item : tileData.items) {
				saveItem(stream, item);
			}
			
			size_t attributesSize;
			const char* attributes = stream.getStream(attributesSize);
			if (attributesSize > 0) {
				serializedTiles.emplace_back(attributes, attributes + attributesSize);
			}
		}
		
		// Connect to database
		Database db;
		if (!db.connect()) {
			std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - CRITICAL: Failed to connect to database in background thread!" << std::endl;
			
			// Decrement refCounts since we're aborting
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Begin transaction
		DBTransaction transaction(&db);
		if (!transaction.begin()) {
			std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - Failed to begin transaction" << std::endl;
			db.disconnect();
			
			// Decrement refCounts
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Delete old house items
		std::stringExtended deleteq(1024);
		deleteq << "DELETE FROM tile_store WHERE house_id = " << houseId;
		if (!db.executeQuery(deleteq)) {
			std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - Failed to delete old house items" << std::endl;
			db.disconnect();
			
			// Decrement refCounts
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Insert new house items
		DBInsert stmt(&db, "INSERT INTO `tile_store` (`house_id`, `data`) VALUES ");
		std::stringExtended query(1024);

		for (const auto& serializedData : serializedTiles) {
			query.clear();
			query << houseId << ',' << db.escapeBlob(reinterpret_cast<const char*>(serializedData.data()), serializedData.size());
			if (!stmt.addRow(query)) {
				std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - Failed to add row" << std::endl;
				db.disconnect();
				
				// Decrement refCounts
				g_dispatcher.addTask([allItems]() {
					for (Item* item : allItems) {
						if (item) {
							g_game.ReleaseItem(item);
						}
					}
				});
				return;
			}
		}

		if (!stmt.execute()) {
			std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - Failed to execute insert" << std::endl;
			db.disconnect();
			
			// Decrement refCounts
			g_dispatcher.addTask([allItems]() {
				for (Item* item : allItems) {
					if (item) {
						g_game.ReleaseItem(item);
					}
				}
			});
			return;
		}

		// Commit transaction
		if (!transaction.commit()) {
			std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - Failed to commit transaction" << std::endl;
		}

		db.disconnect();

		// Decrement refCounts for all items now that save is complete
		// Use g_dispatcher to ensure this happens on the main thread
		g_dispatcher.addTask([allItems, houseName, houseId]() {
			for (Item* item : allItems) {
				if (item) {
					g_game.ReleaseItem(item);
				}
			}
			// Optional: log success
			// std::cout << "[IOMapSerialize::savePlayerHouseItemsAsync] " << houseName << " (ID: " << houseId << ") - Save completed successfully" << std::endl;
		});
	}).detach();
}

bool IOMapSerialize::loadContainer(PropStream& propStream, Container* mainContainer)
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
				std::cout << "[Warning - IOMapSerialize::loadContainer] Unserialization error for container item: " << container->getID() << std::endl;
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
					container->internalAddThing(item);
				} else {
					delete item;
					return false;
				}
			}
			--container->serializationCount;
		}
		uint8_t endAttr;
		if (!propStream.read<uint8_t>(endAttr) || endAttr != 0) {
			std::cout << "[Warning - IOMapSerialize::loadContainer] Unserialization error for container item: " << container->getID() << std::endl;
			return false;
		}
		loadingContainers.pop_back();
		if (!loadingContainers.empty()) {
			loadingContainers.back()->internalAddThing(container);
		}
	}
	return true;
}

bool IOMapSerialize::loadItem(PropStream& propStream, Cylinder* parent)
{
	uint16_t id;
	if (!propStream.read<uint16_t>(id)) {
		return false;
	}

	Tile* tile = nullptr;
	if (parent->getParent() == nullptr) {
		tile = parent->getTile();
	}

	const ItemType& iType = Item::items[id];
	if (iType.moveable || iType.forceSerialize || !tile) {
		//create a new item
		Item* item = Item::CreateItem(id, 0);
		if (item) {
			if (item->unserializeAttr(propStream)) {
				Container* container = item->getContainer();
				if (container && !loadContainer(propStream, container)) {
					delete item;
					return false;
				}

				parent->internalAddThing(item);
				item->startDecaying();
			} else {
				std::cout << "WARNING: Unserialization error in IOMapSerialize::loadItem()" << id << std::endl;
				delete item;
				return false;
			}
		}
	} else {
		// Stationary items like doors/beds/blackboards/bookcases
		Item* item = nullptr;
		if (const TileItemVector* items = tile->getItemList()) {
			for (Item* findItem : *items) {
				if (findItem->getID() == id) {
					item = findItem;
					break;
				} else if (iType.isDoor() && findItem->getDoor()) {
					item = findItem;
					break;
				} else if (iType.isBed() && findItem->getBed()) {
					item = findItem;
					break;
				}
			}
		}

		if (item) {
			if (item->unserializeAttr(propStream)) {
				Container* container = item->getContainer();
				if (container && !loadContainer(propStream, container)) {
					return false;
				}

				g_game.transformItem(item, id);
			} else {
				std::cout << "WARNING: Unserialization error in IOMapSerialize::loadItem()" << id << std::endl;
			}
		} else {
			//The map changed since the last save, just read the attributes
			std::unique_ptr<Item> dummy(Item::CreateItem(id, 0));
			if (dummy) {
				dummy->unserializeAttr(propStream);
				Container* container = dummy->getContainer();
				if (container) {
					if (!loadContainer(propStream, container)) {
						return false;
					}
				} else if (BedItem* bedItem = dynamic_cast<BedItem*>(dummy.get())) {
					uint32_t sleeperGUID = bedItem->getSleeper();
					if (sleeperGUID != 0) {
						g_game.removeBedSleeper(sleeperGUID);
					}
				}
			}
		}
	}
	return true;
}

void IOMapSerialize::saveItem(PropWriteStream& stream, const Item* item)
{
	const Container* container = item->getContainer();
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
	std::vector<std::pair<const Container*, ItemDeque::const_reverse_iterator>> savingContainers; savingContainers.reserve(100);
	savingContainers.emplace_back(container, container->getReversedItems());
	while (!savingContainers.empty()) {
		StartSavingContainers:
		container = savingContainers.back().first;
		ItemDeque::const_reverse_iterator& it = savingContainers.back().second;
		for (auto end = container->getReversedEnd(); it != end; ++it) {
			item = (*it);
			container = item->getContainer();
			if (!container) {
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
				stream.write<uint32_t>(container->size());

				++it; // Since we're going out of loop increase our iterator here
				savingContainers.emplace_back(container, container->getReversedItems());
				goto StartSavingContainers;
			}
		}
		stream.write<uint8_t>(0x00); // attr end
		savingContainers.pop_back();
	}
}

void IOMapSerialize::saveTile(PropWriteStream& stream, const Tile* tile)
{
	const TileItemVector* tileItems = tile->getItemList();
	if (!tileItems) {
		return;
	}

	std::vector<Item*> items;
	items.reserve(32);

	uint16_t count = 0;
	for (Item* item : *tileItems) {
		const ItemType& it = Item::items[item->getID()];

		// Note that these are NEGATED, ie. these are the items that will be saved.
		if (!(it.moveable || it.forceSerialize || item->getDoor() || (item->getContainer() && !item->getContainer()->empty()) || it.canWriteText || item->getBed())) {
			continue;
		}

		items.push_back(item);
		++count;
	}

	if (!items.empty()) {
		const Position& tilePosition = tile->getPosition();
		stream.write<uint16_t>(tilePosition.x);
		stream.write<uint16_t>(tilePosition.y);
		stream.write<uint8_t>(tilePosition.z);

		stream.write<uint32_t>(count);
		for (const Item* item : items) {
			saveItem(stream, item);
		}
	}
}

bool IOMapSerialize::loadHouseInfo()
{
	DBResult_ptr result = g_database.storeQuery("SELECT `id`, `owner`, `paid`, `warnings` FROM `houses`");
	if (!result) {
		return false;
	}

	do {
		House* house = g_game.map.houses.getHouse(result->getNumber<uint32_t>("id"));
		if (house) {
			house->setOwner(result->getNumber<uint32_t>("owner"), false);
			house->setPaidUntil(result->getNumber<time_t>("paid"));
			house->setPayRentWarnings(result->getNumber<uint32_t>("warnings"));
		}
	} while (result->next());

	result = g_database.storeQuery("SELECT `house_id`, `listid`, `list` FROM `house_lists`");
	if (result) {
		do {
			House* house = g_game.map.houses.getHouse(result->getNumber<uint32_t>("house_id"));
			if (house) {
				house->setAccessList(result->getNumber<uint32_t>("listid"), result->getString("list"));
			}
		} while (result->next());
	}
	return true;
}

bool IOMapSerialize::saveHouseInfo()
{
	DBTransaction transaction(&g_database);
	if (!transaction.begin()) {
		return false;
	}

	if (!g_database.executeQuery("DELETE FROM `house_lists`")) {
		return false;
	}

	std::stringExtended query(1024);
	for (auto& it : g_game.map.houses.getHouses()) {
		House* house = &it.second;

		const std::string& escapedName = g_database.escapeString(house->getName());
		query.clear();
		query << "INSERT INTO `houses` (`id`, `owner`, `paid`, `warnings`, `name`, `town_id`, `rent`, `size`, `beds`) VALUES (";
		query << house->getId() << ',';
		query << house->getOwner() << ',';
		query << house->getPaidUntil() << ',';
		query << house->getPayRentWarnings() << ',';
		query << escapedName << ',';
		query << house->getTownId() << ',';
		query << house->getRent() << ',';
		query << house->getTiles().size() << ',';
		query << house->getBedCount() << ')';
		query << "ON DUPLICATE KEY UPDATE `owner` = " << house->getOwner();
		query << ",`paid` = " << house->getPaidUntil();
		query << ",`warnings` = " << house->getPayRentWarnings();
		query << ",`name` = " << escapedName;
		query << ",`town_id` = " << house->getTownId();
		query << ",`rent` = " << house->getRent();
		query << ",`size` = " << house->getTiles().size();
		query << ",`beds` = " << house->getBedCount();
		g_database.executeQuery(query);
	}

	DBInsert stmt(&g_database, "INSERT INTO `house_lists` (`house_id` , `listid` , `list`) VALUES ");
	for (auto& it : g_game.map.houses.getHouses()) {
		House* house = &it.second;

		std::string listText;
		if (house->getAccessList(GUEST_LIST, listText) && !listText.empty()) {
			query.clear();
			query << house->getId() << ',' << GUEST_LIST << ',' << g_database.escapeString(listText);
			if (!stmt.addRow(query)) {
				return false;
			}

			listText.clear();
		}

		if (house->getAccessList(SUBOWNER_LIST, listText) && !listText.empty()) {
			query.clear();
			query << house->getId() << ',' << SUBOWNER_LIST << ',' << g_database.escapeString(listText);
			if (!stmt.addRow(query)) {
				return false;
			}

			listText.clear();
		}

		for (Door* door : house->getDoors()) {
			if (door->getAccessList(listText) && !listText.empty()) {
				query.clear();
				query << house->getId() << ',' << door->getDoorId() << ',' << g_database.escapeString(listText);
				if (!stmt.addRow(query)) {
					return false;
				}

				listText.clear();
			}
		}
	}

	if (!stmt.execute()) {
		return false;
	}

	return transaction.commit();
}