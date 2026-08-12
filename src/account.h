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

#ifndef FS_ACCOUNT_H_34817537BA2B4CB7B71AA562AFBB118F
#define FS_ACCOUNT_H_34817537BA2B4CB7B71AA562AFBB118F

#include "enums.h"

struct Account {
	std::vector<std::string> characters;
	std::vector<uint16_t> levels;
	std::vector<uint16_t> vocations;
	std::vector<uint16_t> lookbody;
	std::vector<uint16_t> lookfeet;
	std::vector<uint16_t> lookhead;
	std::vector<uint16_t> looklegs;
	std::vector<uint16_t> looktype;
	std::vector<uint16_t> lookaddons;
	std::vector<uint16_t> lookwings;
	std::vector<uint16_t> lookaura;
	std::vector<std::string> lookshader;
	std::vector<uint64_t> time;
	std::string email;
	std::string key;
	time_t lastDay = 0;
	uint32_t id = 0;
	uint16_t premiumDays = 0;
	bool whiteListed = false;
	AccountType_t accountType = ACCOUNT_TYPE_NORMAL;

	Account() = default;
};

#endif
