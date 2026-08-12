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

#ifndef FS_CHUNK_SPAWN
#define FS_CHUNK_SPAWN

#include "tile.h"
#include "position.h"
#include "spawn.h"
#include "dungeon.h"

class Monster;
class MonsterType;
class Npc;

class ChunkSpawn
{
	public:
		ChunkSpawn(Position pos) : centerPos(std::move(pos)) {}
		~ChunkSpawn();

		// non-copyable
		ChunkSpawn(const ChunkSpawn&) = delete;
		ChunkSpawn& operator=(const ChunkSpawn&) = delete;

		// moveable
		ChunkSpawn(ChunkSpawn&& rhs) noexcept : spawnMap(std::move(rhs.spawnMap)),
			checkSpawnEvent(rhs.checkSpawnEvent), centerPos(std::move(rhs.centerPos)), interval(rhs.interval) {}
		ChunkSpawn& operator=(ChunkSpawn&& rhs) noexcept {
			if (this != &rhs) {
				spawnMap = std::move(rhs.spawnMap);
				checkSpawnEvent = rhs.checkSpawnEvent;
				centerPos = std::move(rhs.centerPos);
				interval = rhs.interval;
			}
			return *this;
		}

		void cleanup();

		bool addMonster(const std::string& name, const Position& pos, Direction dir);

		void startup(uint16_t& count, uint8_t players, DungeonInstance* instance);

	private:
		std::vector<spawnBlock_t> spawnMap;
		uint64_t checkSpawnEvent = 0;

		Position centerPos;
		uint32_t interval = 60000;
		uint32_t spawnIndex = 0;
		bool spawned = false;

		bool spawnMonster(spawnBlock_t& sb, DungeonInstance* instance = nullptr);
};

class ChunkSpawns
{
	public:
		bool loadFromXml(const std::string& filename, const Position& pos);
		void startup(DungeonInstance* instance, uint8_t players);
		void clear();

		bool isStarted() const {
			return started;
		}

	private:
		std::vector<ChunkSpawn> spawnList;
		std::string filename;
		bool loaded = false;
		bool started = false;
};

#endif