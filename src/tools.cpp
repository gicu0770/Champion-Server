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

#include <openssl/aes.h>
#include <openssl/rand.h>
#include <openssl/evp.h>
#include <openssl/sha.h>

#include "tools.h"
#include "configmanager.h"

extern ConfigManager g_config;

void printXMLError(const std::string& where, const std::string& fileName, const pugi::xml_parse_result& result)
{
	std::cout << '[' << where << "] Failed to load " << fileName << ": " << result.description() << std::endl;

	FILE* file = fopen(fileName.c_str(), "rb");
	if (!file) {
		return;
	}

	char buffer[32768];
	uint32_t currentLine = 1;
	std::string line;

	size_t offset = static_cast<size_t>(result.offset);
	size_t lineOffsetPosition = 0;
	size_t index = 0;
	size_t bytes;
	do {
		bytes = fread(buffer, 1, 32768, file);
		for (size_t i = 0; i < bytes; ++i) {
			char ch = buffer[i];
			if (ch == '\n') {
				if ((index + i) >= offset) {
					lineOffsetPosition = line.length() - ((index + i) - offset);
					bytes = 0;
					break;
				}
				++currentLine;
				line.clear();
			} else {
				line.push_back(ch);
			}
		}
		index += bytes;
	} while (bytes == 32768);
	fclose(file);

	std::cout << "Line " << currentLine << ':' << std::endl;
	std::cout << line << std::endl;
	for (size_t i = 0; i < lineOffsetPosition; i++) {
		if (line[i] == '\t') {
			std::cout << '\t';
		} else {
			std::cout << ' ';
		}
	}
	std::cout << '^' << std::endl;
}

std::string transformToSHA1(const std::string& input)
{
	unsigned char hash[SHA_DIGEST_LENGTH];
	SHA1(reinterpret_cast<const unsigned char*>(input.c_str()), input.length(), hash);

	char hexstring[41];
	static const char hexDigits[] = {"0123456789abcdef"};
	for (int i = 0; i < SHA_DIGEST_LENGTH; ++i) {
		hexstring[i * 2] = hexDigits[hash[i] >> 4];
		hexstring[i * 2 + 1] = hexDigits[hash[i] & 15];
	}
	hexstring[40] = '\0';
	return std::string(hexstring, 40);
}

std::string generateToken(const std::string& key, uint32_t ticks)
{
	// generate message from ticks
	std::string message(8, 0);
	for (uint8_t i = 8; --i; ticks >>= 8) {
		message[i] = static_cast<char>(ticks & 0xFF);
	}

	// hmac key pad generation
	std::string iKeyPad(64, 0x36), oKeyPad(64, 0x5C);
	for (uint8_t i = 0; i < key.length(); ++i) {
		iKeyPad[i] ^= key[i];
		oKeyPad[i] ^= key[i];
	}

	oKeyPad.reserve(84);

	// hmac concat inner pad with message
	iKeyPad.append(message);

	// hmac first pass
	message.assign(transformToSHA1(iKeyPad));

	// hmac concat outer pad with message, conversion from hex to int needed
	for (uint8_t i = 0; i < message.length(); i += 2) {
		oKeyPad.push_back(static_cast<char>(std::strtoul(message.substr(i, 2).c_str(), nullptr, 16)));
	}

	// hmac second pass
	message.assign(transformToSHA1(oKeyPad));

	// calculate hmac offset
	uint32_t offset = static_cast<uint32_t>(std::strtoul(message.substr(39, 1).c_str(), nullptr, 16) & 0xF);

	// get truncated hash
	uint32_t truncHash = static_cast<uint32_t>(std::strtoul(message.substr(2 * offset, 8).c_str(), nullptr, 16)) & 0x7FFFFFFF;
	message.assign(std::to_string(truncHash));

	// return only last AUTHENTICATOR_DIGITS (default 6) digits, also asserts exactly 6 digits
	uint32_t hashLen = message.length();
	message.assign(message.substr(hashLen - std::min(hashLen, AUTHENTICATOR_DIGITS)));
	message.insert(0, AUTHENTICATOR_DIGITS - std::min(hashLen, AUTHENTICATOR_DIGITS), '0');
	return message;
}

void replaceString(std::string& str, const std::string& sought, const std::string& replacement)
{
	size_t pos = 0;
	size_t start = 0;
	size_t soughtLen = sought.length();
	size_t replaceLen = replacement.length();
	while ((pos = str.find(sought, start)) != std::string::npos) {
		str = str.substr(0, pos) + replacement + str.substr(pos + soughtLen);
		start = pos + replaceLen;
	}
}

void trim_right(std::string& source, char t)
{
	source.erase(source.find_last_not_of(t) + 1);
}

void trim_left(std::string& source, char t)
{
	source.erase(0, source.find_first_not_of(t));
}

void toLowerCaseString(std::string& source)
{
	#if defined(__SSE4_2__)
	if (source.empty()) {
		return;
	}
	
	const __m128i ranges = _mm_setr_epi8('A', 'Z', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	const __m128i diff = _mm_set1_epi8(0x20);
	const uint8_t mode = (_SIDD_UBYTE_OPS | _SIDD_CMP_RANGES | _SIDD_UNIT_MASK);
	
	size_t len = source.length();
	char* data = &source[0];
	size_t i = 0;
	
	// Process 16-byte chunks
	for (; i + 16 <= len; i += 16) {
		__m128i chunk = _mm_loadu_si128(reinterpret_cast<const __m128i*>(data + i));
		if (_mm_cmpistrc(ranges, chunk, mode)) {
			const __m128i tmp1 = _mm_cmpistrm(ranges, chunk, mode);
			const __m128i mask = _mm_and_si128(tmp1, diff);
			chunk = _mm_xor_si128(chunk, mask);
			_mm_storeu_si128(reinterpret_cast<__m128i*>(data + i), chunk);
		}
	}
	
	// Process remaining bytes
	for (; i < len; ++i) {
		if (data[i] >= 'A' && data[i] <= 'Z') {
			data[i] += 0x20;
		}
	}
	#elif defined(__SSE2__)
	const __m128i ranges1 = _mm_set1_epi8(static_cast<unsigned char>('A' + 128));
	const __m128i ranges2 = _mm_set1_epi8(-128 + ('Z' - 'A'));
	const __m128i diff = _mm_set1_epi8(0x20);

	__m128i* mem = reinterpret_cast<__m128i*>(&source[0]);
	size_t len = source.length();
	for (; len >= 16; ++mem) {
		const __m128i chunk = _mm_loadu_si128(mem);
		const __m128i ranges = _mm_sub_epi8(chunk, ranges1);
		const __m128i tmp1 = _mm_cmpgt_epi8(ranges, ranges2);
		const __m128i mask = _mm_andnot_si128(tmp1, diff);
		_mm_storeu_si128(mem, _mm_xor_si128(chunk, mask));
		len -= 16;
	}
	char* src = reinterpret_cast<char*>(mem);
	while (len--) {
		*src = (('A' <= *src && *src <= 'Z') ? *src+0x20 : *src);
		++src;
	}
	#else
	std::transform(source.begin(), source.end(), source.begin(), tolower);
	#endif
}

void toUpperCaseString(std::string& source)
{
	#if defined(__SSE4_2__)
	if (source.empty()) {
		return;
	}
	
	const __m128i ranges = _mm_setr_epi8('a', 'z', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	const __m128i diff = _mm_set1_epi8(0x20);
	const uint8_t mode = (_SIDD_UBYTE_OPS | _SIDD_CMP_RANGES | _SIDD_UNIT_MASK);
	
	size_t len = source.length();
	char* data = &source[0];
	size_t i = 0;
	
	// Process 16-byte chunks
	for (; i + 16 <= len; i += 16) {
		__m128i chunk = _mm_loadu_si128(reinterpret_cast<const __m128i*>(data + i));
		if (_mm_cmpistrc(ranges, chunk, mode)) {
			const __m128i tmp1 = _mm_cmpistrm(ranges, chunk, mode);
			const __m128i mask = _mm_and_si128(tmp1, diff);
			chunk = _mm_xor_si128(chunk, mask);
			_mm_storeu_si128(reinterpret_cast<__m128i*>(data + i), chunk);
		}
	}
	
	// Process remaining bytes
	for (; i < len; ++i) {
		if (data[i] >= 'a' && data[i] <= 'z') {
			data[i] -= 0x20;
		}
	}
	#elif defined(__SSE2__)
	const __m128i ranges1 = _mm_set1_epi8(static_cast<unsigned char>('a' + 128));
	const __m128i ranges2 = _mm_set1_epi8(-128 + ('z' - 'a'));
	const __m128i diff = _mm_set1_epi8(0x20);

	__m128i* mem = reinterpret_cast<__m128i*>(&source[0]);
	size_t len = source.length();
	for (; len >= 16; ++mem) {
		const __m128i chunk = _mm_loadu_si128(mem);
		const __m128i ranges = _mm_sub_epi8(chunk, ranges1);
		const __m128i tmp1 = _mm_cmpgt_epi8(ranges, ranges2);
		const __m128i mask = _mm_andnot_si128(tmp1, diff);
		_mm_storeu_si128(mem, _mm_xor_si128(chunk, mask));
		len -= 16;
	}
	char* src = reinterpret_cast<char*>(mem);
	while (len--) {
		*src = (('a' <= *src && *src <= 'z') ? *src-0x20 : *src);
		++src;
	}
	#else
	std::transform(source.begin(), source.end(), source.begin(), toupper);
	#endif
}

std::string asLowerCaseString(std::string source)
{
	toLowerCaseString(source);
	return source;
}

std::string asUpperCaseString(std::string source)
{
	toUpperCaseString(source);
	return source;
}

StringVector explodeString(const std::string& inString, const std::string& separator, int32_t limit/* = -1*/)
{
	StringVector returnVector;
	std::string::size_type start = 0, end = 0;
	while (--limit != -1 && (end = inString.find(separator, start)) != std::string::npos) {
		returnVector.emplace_back(std::move(inString.substr(start, end - start)));
		start = end + separator.size();
	}

	returnVector.emplace_back(std::move(inString.substr(start)));
	return returnVector;
}

IntegerVector vectorAtoi(const StringVector& stringVector)
{
	IntegerVector returnVector;
	for (const auto& string : stringVector) {
		returnVector.push_back(std::stoi(string));
	}
	return returnVector;
}

std::mt19937& getRandomGenerator()
{
	static std::random_device rd;
	static std::mt19937 generator(rd());
	return generator;
}

int64_t uniform_random(int64_t minNumber, int64_t maxNumber)
{
	static std::uniform_int_distribution<int64_t> uniformRand;
	if (minNumber == maxNumber) {
		return minNumber;
	} else if (minNumber > maxNumber) {
		std::swap(minNumber, maxNumber);
	}
	return uniformRand(getRandomGenerator(), std::uniform_int_distribution<int64_t>::param_type(minNumber, maxNumber));
}

double uniform_random()
{
	static std::uniform_real_distribution<double> uniformRand(0.0, 1.0);
	return uniformRand(getRandomGenerator());
}

int64_t normal_random(int64_t minNumber, int64_t maxNumber)
{
	static std::normal_distribution<float> normalRand(0.5f, 0.25f);
	if (minNumber == maxNumber) {
		return minNumber;
	} else if (minNumber > maxNumber) {
		std::swap(minNumber, maxNumber);
	}

	int64_t increment;
	const int64_t diff = maxNumber - minNumber;
	const float v = normalRand(getRandomGenerator());
	if (v < 0.0) {
		increment = diff / 2;
	} else if (v > 1.0) {
		increment = (diff + 1) / 2;
	} else {
		increment = round(v * diff);
	}
	return minNumber + increment;
}

bool boolean_random(double probability/* = 0.5*/)
{
	static std::bernoulli_distribution booleanRand;
	return booleanRand(getRandomGenerator(), std::bernoulli_distribution::param_type(probability));
}

void trimString(std::string& str)
{
	str.erase(str.find_last_not_of(' ') + 1);
	str.erase(0, str.find_first_not_of(' '));
}

std::string convertIPToString(uint32_t ip)
{
	char buffer[17];

	int res = sprintf(buffer, "%u.%u.%u.%u", ip & 0xFF, (ip >> 8) & 0xFF, (ip >> 16) & 0xFF, (ip >> 24));
	if (res < 0) {
		return {};
	}

	return buffer;
}

std::string formatDate(time_t time)
{
	const tm* tms = localtime(&time);
	if (!tms) {
		return {};
	}

	char buffer[80];
	int res = sprintf(buffer, "%02d/%02d/%04d %02d:%02d:%02d", tms->tm_mday, tms->tm_mon + 1, tms->tm_year + 1900, tms->tm_hour, tms->tm_min, tms->tm_sec);
	if (res < 0) {
		return {};
	}
	return buffer;
}

std::string formatDateShort(time_t time)
{
	const tm* tms = localtime(&time);
	if (!tms) {
		return {};
	}

	char buffer[12];
	size_t res = strftime(buffer, 12, "%d %b %Y", tms);
	if (res == 0) {
		return {};
	}
	return {buffer, 11};
}

std::string timeFromSeconds(uint64_t time)
{	
	uint64_t days, hours, minutes, seconds;
	seconds = time % 60;
	minutes = time % 3600 / 60;
	hours = time % 86400 / 3600;
	days = time / 86400;

	std::stringExtended ss(128);
	if (days > 0) {
		ss << days << " days ";
	}
	if (hours > 0) {
		ss << hours << " hours ";
	}
	if (minutes > 0) {
		ss << minutes << " minutes ";
	}
	if (seconds > 0) {
		ss << seconds << " seconds ";
	}
	return ss;
}

Direction getDirection(const std::string& string)
{
	Direction direction = DIRECTION_NORTH;

	const char* cstr = string.c_str();
	if (!tfs_strcmp(cstr, "north") || !tfs_strcmp(cstr, "n") || !tfs_strcmp(cstr, "0")) {
		direction = DIRECTION_NORTH;
	} else if (!tfs_strcmp(cstr, "east") || !tfs_strcmp(cstr, "e") || !tfs_strcmp(cstr, "1")) {
		direction = DIRECTION_EAST;
	} else if (!tfs_strcmp(cstr, "south") || !tfs_strcmp(cstr, "s") || !tfs_strcmp(cstr, "2")) {
		direction = DIRECTION_SOUTH;
	} else if (!tfs_strcmp(cstr, "west") || !tfs_strcmp(cstr, "w") || !tfs_strcmp(cstr, "3")) {
		direction = DIRECTION_WEST;
	} else if (!tfs_strcmp(cstr, "southwest") || !tfs_strcmp(cstr, "south west") || !tfs_strcmp(cstr, "south-west") || !tfs_strcmp(cstr, "sw") || !tfs_strcmp(cstr, "4")) {
		direction = DIRECTION_SOUTHWEST;
	} else if (!tfs_strcmp(cstr, "southeast") || !tfs_strcmp(cstr, "south east") || !tfs_strcmp(cstr, "south-east") || !tfs_strcmp(cstr, "se") || !tfs_strcmp(cstr, "5")) {
		direction = DIRECTION_SOUTHEAST;
	} else if (!tfs_strcmp(cstr, "northwest") || !tfs_strcmp(cstr, "north west") || !tfs_strcmp(cstr, "north-west") || !tfs_strcmp(cstr, "nw") || !tfs_strcmp(cstr, "6")) {
		direction = DIRECTION_NORTHWEST;
	} else if (!tfs_strcmp(cstr, "northeast") || !tfs_strcmp(cstr, "north east") || !tfs_strcmp(cstr, "north-east") || !tfs_strcmp(cstr, "ne") || !tfs_strcmp(cstr, "7")) {
		direction = DIRECTION_NORTHEAST;
	}

	return direction;
}

Position getNextPosition(Direction direction, Position pos)
{
	switch (direction) {
		case DIRECTION_NORTH:
			pos.y--;
			break;

		case DIRECTION_SOUTH:
			pos.y++;
			break;

		case DIRECTION_WEST:
			pos.x--;
			break;

		case DIRECTION_EAST:
			pos.x++;
			break;

		case DIRECTION_SOUTHWEST:
			pos.x--;
			pos.y++;
			break;

		case DIRECTION_NORTHWEST:
			pos.x--;
			pos.y--;
			break;

		case DIRECTION_NORTHEAST:
			pos.x++;
			pos.y--;
			break;

		case DIRECTION_SOUTHEAST:
			pos.x++;
			pos.y++;
			break;

		default:
			break;
	}

	return pos;
}

Direction getDirectionTo(const Position& from, const Position& to)
{
	Direction dir;

	int32_t x_offset = Position::getOffsetX(from, to);
	if (x_offset < 0) {
		dir = DIRECTION_EAST;
		x_offset = std::abs(x_offset);
	} else {
		dir = DIRECTION_WEST;
	}

	int32_t y_offset = Position::getOffsetY(from, to);
	if (y_offset >= 0) {
		if (y_offset > x_offset) {
			dir = DIRECTION_NORTH;
		} else if (y_offset == x_offset) {
			if (dir == DIRECTION_EAST) {
				dir = DIRECTION_NORTHEAST;
			} else {
				dir = DIRECTION_NORTHWEST;
			}
		}
	} else {
		y_offset = std::abs(y_offset);
		if (y_offset > x_offset) {
			dir = DIRECTION_SOUTH;
		} else if (y_offset == x_offset) {
			if (dir == DIRECTION_EAST) {
				dir = DIRECTION_SOUTHEAST;
			} else {
				dir = DIRECTION_SOUTHWEST;
			}
		}
	}
	return dir;
}

MagicEffectClasses getMagicEffect(const std::string& strValue)
{
	if (!tfs_strcmp(strValue.c_str(), "redspark")) {
		return CONST_ME_DRAWBLOOD;
	} else if (!tfs_strcmp(strValue.c_str(), "bluebubble")) {
		return CONST_ME_LOSEENERGY;
	} else if (!tfs_strcmp(strValue.c_str(), "poff")) {
		return CONST_ME_POFF;
	} else if (!tfs_strcmp(strValue.c_str(), "yellowspark")) {
		return CONST_ME_BLOCKHIT;
	} else if (!tfs_strcmp(strValue.c_str(), "explosionarea")) {
		return CONST_ME_EXPLOSIONAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "explosion")) {
		return CONST_ME_EXPLOSIONHIT;
	} else if (!tfs_strcmp(strValue.c_str(), "firearea")) {
		return CONST_ME_FIREAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "yellowbubble")) {
		return CONST_ME_YELLOW_RINGS;
	} else if (!tfs_strcmp(strValue.c_str(), "greenbubble")) {
		return CONST_ME_GREEN_RINGS;
	} else if (!tfs_strcmp(strValue.c_str(), "blackspark")) {
		return CONST_ME_HITAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "teleport")) {
		return CONST_ME_TELEPORT;
	} else if (!tfs_strcmp(strValue.c_str(), "energy")) {
		return CONST_ME_ENERGYHIT;
	} else if (!tfs_strcmp(strValue.c_str(), "blueshimmer")) {
		return CONST_ME_MAGIC_BLUE;
	} else if (!tfs_strcmp(strValue.c_str(), "redshimmer")) {
		return CONST_ME_MAGIC_RED;
	} else if (!tfs_strcmp(strValue.c_str(), "greenshimmer")) {
		return CONST_ME_MAGIC_GREEN;
	} else if (!tfs_strcmp(strValue.c_str(), "fire")) {
		return CONST_ME_HITBYFIRE;
	} else if (!tfs_strcmp(strValue.c_str(), "greenspark")) {
		return CONST_ME_HITBYPOISON;
	} else if (!tfs_strcmp(strValue.c_str(), "mortarea")) {
		return CONST_ME_MORTAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "greennote")) {
		return CONST_ME_SOUND_GREEN;
	} else if (!tfs_strcmp(strValue.c_str(), "rednote")) {
		return CONST_ME_SOUND_RED;
	} else if (!tfs_strcmp(strValue.c_str(), "poison")) {
		return CONST_ME_POISONAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "yellownote")) {
		return CONST_ME_SOUND_YELLOW;
	} else if (!tfs_strcmp(strValue.c_str(), "purplenote")) {
		return CONST_ME_SOUND_PURPLE;
	} else if (!tfs_strcmp(strValue.c_str(), "bluenote")) {
		return CONST_ME_SOUND_BLUE;
	} else if (!tfs_strcmp(strValue.c_str(), "whitenote")) {
		return CONST_ME_SOUND_WHITE;
	} else if (!tfs_strcmp(strValue.c_str(), "bubbles")) {
		return CONST_ME_BUBBLES;
	} else if (!tfs_strcmp(strValue.c_str(), "dice")) {
		return CONST_ME_CRAPS;
	} else if (!tfs_strcmp(strValue.c_str(), "giftwraps")) {
		return CONST_ME_GIFT_WRAPS;
	} else if (!tfs_strcmp(strValue.c_str(), "yellowfirework")) {
		return CONST_ME_FIREWORK_YELLOW;
	} else if (!tfs_strcmp(strValue.c_str(), "redfirework")) {
		return CONST_ME_FIREWORK_RED;
	} else if (!tfs_strcmp(strValue.c_str(), "bluefirework")) {
		return CONST_ME_FIREWORK_BLUE;
	} else if (!tfs_strcmp(strValue.c_str(), "stun")) {
		return CONST_ME_STUN;
	} else if (!tfs_strcmp(strValue.c_str(), "sleep")) {
		return CONST_ME_SLEEP;
	} else if (!tfs_strcmp(strValue.c_str(), "watercreature")) {
		return CONST_ME_WATERCREATURE;
	} else if (!tfs_strcmp(strValue.c_str(), "groundshaker")) {
		return CONST_ME_GROUNDSHAKER;
	} else if (!tfs_strcmp(strValue.c_str(), "hearts")) {
		return CONST_ME_HEARTS;
	} else if (!tfs_strcmp(strValue.c_str(), "fireattack")) {
		return CONST_ME_FIREATTACK;
	} else if (!tfs_strcmp(strValue.c_str(), "energyarea")) {
		return CONST_ME_ENERGYAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "smallclouds")) {
		return CONST_ME_SMALLCLOUDS;
	} else if (!tfs_strcmp(strValue.c_str(), "holydamage")) {
		return CONST_ME_HOLYDAMAGE;
	} else if (!tfs_strcmp(strValue.c_str(), "bigclouds")) {
		return CONST_ME_BIGCLOUDS;
	} else if (!tfs_strcmp(strValue.c_str(), "icearea")) {
		return CONST_ME_ICEAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "icetornado")) {
		return CONST_ME_ICETORNADO;
	} else if (!tfs_strcmp(strValue.c_str(), "iceattack")) {
		return CONST_ME_ICEATTACK;
	} else if (!tfs_strcmp(strValue.c_str(), "stones")) {
		return CONST_ME_STONES;
	} else if (!tfs_strcmp(strValue.c_str(), "smallplants")) {
		return CONST_ME_SMALLPLANTS;
	} else if (!tfs_strcmp(strValue.c_str(), "carniphila")) {
		return CONST_ME_CARNIPHILA;
	} else if (!tfs_strcmp(strValue.c_str(), "purpleenergy")) {
		return CONST_ME_PURPLEENERGY;
	} else if (!tfs_strcmp(strValue.c_str(), "yellowenergy")) {
		return CONST_ME_YELLOWENERGY;
	} else if (!tfs_strcmp(strValue.c_str(), "holyarea")) {
		return CONST_ME_HOLYAREA;
	} else if (!tfs_strcmp(strValue.c_str(), "bigplants")) {
		return CONST_ME_BIGPLANTS;
	} else if (!tfs_strcmp(strValue.c_str(), "cake")) {
		return CONST_ME_CAKE;
	} else if (!tfs_strcmp(strValue.c_str(), "giantice")) {
		return CONST_ME_GIANTICE;
	} else if (!tfs_strcmp(strValue.c_str(), "watersplash")) {
		return CONST_ME_WATERSPLASH;
	} else if (!tfs_strcmp(strValue.c_str(), "plantattack")) {
		return CONST_ME_PLANTATTACK;
	} else if (!tfs_strcmp(strValue.c_str(), "tutorialarrow")) {
		return CONST_ME_TUTORIALARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "tutorialsquare")) {
		return CONST_ME_TUTORIALSQUARE;
	} else if (!tfs_strcmp(strValue.c_str(), "mirrorhorizontal")) {
		return CONST_ME_MIRRORHORIZONTAL;
	} else if (!tfs_strcmp(strValue.c_str(), "mirrorvertical")) {
		return CONST_ME_MIRRORVERTICAL;
	} else if (!tfs_strcmp(strValue.c_str(), "skullhorizontal")) {
		return CONST_ME_SKULLHORIZONTAL;
	} else if (!tfs_strcmp(strValue.c_str(), "skullvertical")) {
		return CONST_ME_SKULLVERTICAL;
	} else if (!tfs_strcmp(strValue.c_str(), "assassin")) {
		return CONST_ME_ASSASSIN;
	} else if (!tfs_strcmp(strValue.c_str(), "stepshorizontal")) {
		return CONST_ME_STEPSHORIZONTAL;
	} else if (!tfs_strcmp(strValue.c_str(), "bloodysteps")) {
		return CONST_ME_BLOODYSTEPS;
	} else if (!tfs_strcmp(strValue.c_str(), "stepsvertical")) {
		return CONST_ME_STEPSVERTICAL;
	} else if (!tfs_strcmp(strValue.c_str(), "yalaharighost")) {
		return CONST_ME_YALAHARIGHOST;
	} else if (!tfs_strcmp(strValue.c_str(), "bats")) {
		return CONST_ME_BATS;
	} else if (!tfs_strcmp(strValue.c_str(), "smoke")) {
		return CONST_ME_SMOKE;
	} else if (!tfs_strcmp(strValue.c_str(), "insects")) {
		return CONST_ME_INSECTS;
	} else if (!tfs_strcmp(strValue.c_str(), "dragonhead")) {
		return CONST_ME_DRAGONHEAD;
	} else if (!tfs_strcmp(strValue.c_str(), "orcshaman")) {
		return CONST_ME_ORCSHAMAN;
	} else if (!tfs_strcmp(strValue.c_str(), "orcshamanfire")) {
		return CONST_ME_ORCSHAMAN_FIRE;
	} else if (!tfs_strcmp(strValue.c_str(), "thunder")) {
		return CONST_ME_THUNDER;
	} else if (!tfs_strcmp(strValue.c_str(), "ferumbras")) {
		return CONST_ME_FERUMBRAS;
	} else if (!tfs_strcmp(strValue.c_str(), "confettihorizontal")) {
		return CONST_ME_CONFETTI_HORIZONTAL;
	} else if (!tfs_strcmp(strValue.c_str(), "confettivertical")) {
		return CONST_ME_CONFETTI_VERTICAL;
	} else if (!tfs_strcmp(strValue.c_str(), "blacksmoke")) {
		return CONST_ME_BLACKSMOKE;
	} else if (!tfs_strcmp(strValue.c_str(), "redsmoke")) {
		return CONST_ME_REDSMOKE;
	} else if (!tfs_strcmp(strValue.c_str(), "yellowsmoke")) {
		return CONST_ME_YELLOWSMOKE;
	} else if (!tfs_strcmp(strValue.c_str(), "greensmoke")) {
		return CONST_ME_GREENSMOKE;
	} else if (!tfs_strcmp(strValue.c_str(), "purplesmoke")) {
		return CONST_ME_PURPLESMOKE;
	}
	return CONST_ME_NONE;
}

ShootType_t getShootType(const std::string& strValue)
{
	if (!tfs_strcmp(strValue.c_str(), "spear")) {
		return CONST_ANI_SPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "bolt")) {
		return CONST_ANI_BOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "arrow")) {
		return CONST_ANI_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "fire")) {
		return CONST_ANI_FIRE;
	} else if (!tfs_strcmp(strValue.c_str(), "energy")) {
		return CONST_ANI_ENERGY;
	} else if (!tfs_strcmp(strValue.c_str(), "poisonarrow")) {
		return CONST_ANI_POISONARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "burstarrow")) {
		return CONST_ANI_BURSTARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "throwingstar")) {
		return CONST_ANI_THROWINGSTAR;
	} else if (!tfs_strcmp(strValue.c_str(), "throwingknife")) {
		return CONST_ANI_THROWINGKNIFE;
	} else if (!tfs_strcmp(strValue.c_str(), "smallstone")) {
		return CONST_ANI_SMALLSTONE;
	} else if (!tfs_strcmp(strValue.c_str(), "death")) {
		return CONST_ANI_DEATH;
	} else if (!tfs_strcmp(strValue.c_str(), "largerock")) {
		return CONST_ANI_LARGEROCK;
	} else if (!tfs_strcmp(strValue.c_str(), "snowball")) {
		return CONST_ANI_SNOWBALL;
	} else if (!tfs_strcmp(strValue.c_str(), "powerbolt")) {
		return CONST_ANI_POWERBOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "poison")) {
		return CONST_ANI_POISON;
	} else if (!tfs_strcmp(strValue.c_str(), "infernalbolt")) {
		return CONST_ANI_INFERNALBOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "huntingspear")) {
		return CONST_ANI_HUNTINGSPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "enchantedspear")) {
		return CONST_ANI_ENCHANTEDSPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "redstar")) {
		return CONST_ANI_REDSTAR;
	} else if (!tfs_strcmp(strValue.c_str(), "greenstar")) {
		return CONST_ANI_GREENSTAR;
	} else if (!tfs_strcmp(strValue.c_str(), "royalspear")) {
		return CONST_ANI_ROYALSPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "sniperarrow")) {
		return CONST_ANI_SNIPERARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "onyxarrow")) {
		return CONST_ANI_ONYXARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "piercingbolt")) {
		return CONST_ANI_PIERCINGBOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "whirlwindsword")) {
		return CONST_ANI_WHIRLWINDSWORD;
	} else if (!tfs_strcmp(strValue.c_str(), "whirlwindaxe")) {
		return CONST_ANI_WHIRLWINDAXE;
	} else if (!tfs_strcmp(strValue.c_str(), "whirlwindclub")) {
		return CONST_ANI_WHIRLWINDCLUB;
	} else if (!tfs_strcmp(strValue.c_str(), "etherealspear")) {
		return CONST_ANI_ETHEREALSPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "ice")) {
		return CONST_ANI_ICE;
	} else if (!tfs_strcmp(strValue.c_str(), "earth")) {
		return CONST_ANI_EARTH;
	} else if (!tfs_strcmp(strValue.c_str(), "holy")) {
		return CONST_ANI_HOLY;
	} else if (!tfs_strcmp(strValue.c_str(), "suddendeath")) {
		return CONST_ANI_SUDDENDEATH;
	} else if (!tfs_strcmp(strValue.c_str(), "flasharrow")) {
		return CONST_ANI_FLASHARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "flammingarrow")) {
		return CONST_ANI_FLAMMINGARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "shiverarrow")) {
		return CONST_ANI_SHIVERARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "energyball")) {
		return CONST_ANI_ENERGYBALL;
	} else if (!tfs_strcmp(strValue.c_str(), "smallice")) {
		return CONST_ANI_SMALLICE;
	} else if (!tfs_strcmp(strValue.c_str(), "smallholy")) {
		return CONST_ANI_SMALLHOLY;
	} else if (!tfs_strcmp(strValue.c_str(), "smallearth")) {
		return CONST_ANI_SMALLEARTH;
	} else if (!tfs_strcmp(strValue.c_str(), "eartharrow")) {
		return CONST_ANI_EARTHARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "explosion")) {
		return CONST_ANI_EXPLOSION;
	} else if (!tfs_strcmp(strValue.c_str(), "cake")) {
		return CONST_ANI_CAKE;
	} else if (!tfs_strcmp(strValue.c_str(), "tarsalarrow")) {
		return CONST_ANI_TARSALARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "vortexbolt")) {
		return CONST_ANI_VORTEXBOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "prismaticbolt")) {
		return CONST_ANI_PRISMATICBOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "crystallinearrow")) {
		return CONST_ANI_CRYSTALLINEARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "drillbolt")) {
		return CONST_ANI_DRILLBOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "envenomedarrow")) {
		return CONST_ANI_ENVENOMEDARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "gloothspear")) {
		return CONST_ANI_GLOOTHSPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "simplearrow")) {
		return CONST_ANI_SIMPLEARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "distancea")) {
		return CONST_55;
	} else if (!tfs_strcmp(strValue.c_str(), "distanceb")) {
		return CONST_56;
	} else if (!tfs_strcmp(strValue.c_str(), "distancec")) {
		return CONST_57;
	} else if (!tfs_strcmp(strValue.c_str(), "distanced")) {
		return CONST_58;
	} else if (!tfs_strcmp(strValue.c_str(), "distancee")) {
		return CONST_59;
	} else if (!tfs_strcmp(strValue.c_str(), "distancef")) {
		return CONST_60;
	} else if (!tfs_strcmp(strValue.c_str(), "distanceg")) {
		return CONST_61;
	} else if (!tfs_strcmp(strValue.c_str(), "distanceh")) {
		return CONST_62;
	} else if (!tfs_strcmp(strValue.c_str(), "distancei")) {
		return CONST_63;
	} else if (!tfs_strcmp(strValue.c_str(), "distancej")) {
		return CONST_64;
	} else if (!tfs_strcmp(strValue.c_str(), "distancek")) {
		return CONST_65;
	} else if (!tfs_strcmp(strValue.c_str(), "distancel")) {
		return CONST_66;
	} else if (!tfs_strcmp(strValue.c_str(), "distancem")) {
		return CONST_67;
	} else if (!tfs_strcmp(strValue.c_str(), "distancen")) {
		return CONST_68;
	} else if (!tfs_strcmp(strValue.c_str(), "distancep")) {
		return CONST_69;
	} else if (!tfs_strcmp(strValue.c_str(), "distanceq")) {
		return CONST_70;
	} else if (!tfs_strcmp(strValue.c_str(), "distancer")) {
		return CONST_71;
	} else if (!tfs_strcmp(strValue.c_str(), "distances")) {
		return CONST_72;
	} else if (!tfs_strcmp(strValue.c_str(), "distancet")) {
		return CONST_73;
	} else if (!tfs_strcmp(strValue.c_str(), "distancew")) {
		return CONST_74;
	} else if (!tfs_strcmp(strValue.c_str(), "distancex")) {
		return CONST_75;
	} else if (!tfs_strcmp(strValue.c_str(), "distancey")) {
		return CONST_76;
	} else if (!tfs_strcmp(strValue.c_str(), "knifea")) {
		return CONST_77;
	} else if (!tfs_strcmp(strValue.c_str(), "knifeb")) {
		return CONST_78;
	} else if (!tfs_strcmp(strValue.c_str(), "knifec")) {
		return CONST_79;
	} else if (!tfs_strcmp(strValue.c_str(), "knifed")) {
		return CONST_80;
	} else if (!tfs_strcmp(strValue.c_str(), "knifee")) {
		return CONST_81;
	} else if (!tfs_strcmp(strValue.c_str(), "knifef")) {
		return CONST_82;
	} else if (!tfs_strcmp(strValue.c_str(), "knifeg")) {
		return CONST_83;
	} else if (!tfs_strcmp(strValue.c_str(), "knifeh")) {
		return CONST_84;
	} else if (!tfs_strcmp(strValue.c_str(), "knifei")) {
		return CONST_85;
	} else if (!tfs_strcmp(strValue.c_str(), "knifej")) {
		return CONST_86;
	} else if (!tfs_strcmp(strValue.c_str(), "knifek")) {
		return CONST_87;
	} else if (!tfs_strcmp(strValue.c_str(), "knifel")) {
		return CONST_88;
	} else if (!tfs_strcmp(strValue.c_str(), "knifem")) {
		return CONST_89;
	} else if (!tfs_strcmp(strValue.c_str(), "knifen")) {
		return CONST_90;
	} else if (!tfs_strcmp(strValue.c_str(), "knifen")) {
		return CONST_91;
	} else if (!tfs_strcmp(strValue.c_str(), "knifeo")) {
		return CONST_92;
	} else if (!tfs_strcmp(strValue.c_str(), "knifep")) {
		return CONST_93;
	} else if (!tfs_strcmp(strValue.c_str(), "knifeq")) {
		return CONST_94;
	} else if (!tfs_strcmp(strValue.c_str(), "knifer")) {
		return CONST_95;
	} else if (!tfs_strcmp(strValue.c_str(), "knifes")) {
		return CONST_96;
	} else if (!tfs_strcmp(strValue.c_str(), "knifet")) {
		return CONST_97;
	} else if (!tfs_strcmp(strValue.c_str(), "knifeu")) {
		return CONST_98;
	} else if (!tfs_strcmp(strValue.c_str(), "knifew")) {
		return CONST_99;
	} else if (!tfs_strcmp(strValue.c_str(), "knifex")) {
		return CONST_100;




	
	}
	return CONST_ANI_NONE;
}

std::string getCombatName(CombatType_t combatType)
{
	switch (combatType) {
		case COMBAT_PHYSICALDAMAGE: return "physical";
		case COMBAT_ENERGYDAMAGE: return "energy";
		case COMBAT_EARTHDAMAGE: return "earth";
		case COMBAT_FIREDAMAGE: return "fire";
		case COMBAT_UNDEFINEDDAMAGE: return "undefined";
		case COMBAT_LIFEDRAIN: return "lifedrain";
		case COMBAT_MANADRAIN: return "manadrain";
		case COMBAT_HEALING: return "healing";
		case COMBAT_DROWNDAMAGE: return "drown";
		case COMBAT_ICEDAMAGE: return "ice";
		case COMBAT_HOLYDAMAGE: return "holy";
		case COMBAT_DEATHDAMAGE: return "death";
		case COMBAT_PHYSICAL_PROC_DAMAGE: return "procphysical";
		case COMBAT_ELEMENTAL_PROC_DAMAGE: return "procelemental";
		case COMBAT_PHYSICAL_DOT: return "dotphysical";
		case COMBAT_ELEMENTAL_DOT: return "dotelemental";
		default: return "unknown";
	}
}

Ammo_t getAmmoType(const std::string& strValue)
{
	if (!tfs_strcmp(strValue.c_str(), "spear")) {
		return AMMO_SPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "bolt")) {
		return AMMO_BOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "arrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "poisonarrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "burstarrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "throwingstar")) {
		return AMMO_THROWINGSTAR;
	} else if (!tfs_strcmp(strValue.c_str(), "throwingknife")) {
		return AMMO_THROWINGKNIFE;
	} else if (!tfs_strcmp(strValue.c_str(), "smallstone")) {
		return AMMO_STONE;
	} else if (!tfs_strcmp(strValue.c_str(), "largerock")) {
		return AMMO_STONE;
	} else if (!tfs_strcmp(strValue.c_str(), "snowball")) {
		return AMMO_SNOWBALL;
	} else if (!tfs_strcmp(strValue.c_str(), "powerbolt")) {
		return AMMO_BOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "infernalbolt")) {
		return AMMO_BOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "huntingspear")) {
		return AMMO_SPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "enchantedspear")) {
		return AMMO_SPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "royalspear")) {
		return AMMO_SPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "sniperarrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "onyxarrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "piercingbolt")) {
		return AMMO_BOLT;
	} else if (!tfs_strcmp(strValue.c_str(), "etherealspear")) {
		return AMMO_SPEAR;
	} else if (!tfs_strcmp(strValue.c_str(), "flasharrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "flammingarrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "shiverarrow")) {
		return AMMO_ARROW;
	} else if (!tfs_strcmp(strValue.c_str(), "eartharrow")) {
		return AMMO_ARROW;
	}
	return AMMO_NONE;
}

WeaponAction_t getWeaponAction(const std::string& strValue)
{
	if (!tfs_strcmp(strValue.c_str(), "move")) {
		return WEAPONACTION_MOVE;
	} else if (!tfs_strcmp(strValue.c_str(), "removecharge")) {
		return WEAPONACTION_REMOVECHARGE;
	} else if (!tfs_strcmp(strValue.c_str(), "removecount")) {
		return WEAPONACTION_REMOVECOUNT;
	}
	return WEAPONACTION_NONE;
}

Skulls_t getSkullType(const std::string& strValue)
{
	if (!tfs_strcmp(strValue.c_str(), "yellow")) {
		return SKULL_YELLOW;
	} else if (!tfs_strcmp(strValue.c_str(), "green")) {
		return SKULL_GREEN;
	} else if (!tfs_strcmp(strValue.c_str(), "white")) {
		return SKULL_WHITE;
	} else if (!tfs_strcmp(strValue.c_str(), "red")) {
		return SKULL_RED;
	} else if (!tfs_strcmp(strValue.c_str(), "black")) {
		return SKULL_BLACK;
	} else if (!tfs_strcmp(strValue.c_str(), "orange")) {
		return SKULL_ORANGE;
	}
	return SKULL_NONE;
}

std::string getSpecialSkillName(uint8_t skillid)
{
	switch (skillid) {
		case SPECIALSKILL_CRITICALHITCHANCE:
			return "Critical Chance";

		case SPECIALSKILL_CRITICALHITAMOUNT:
			return "Critical Damage";

		case SPECIALSKILL_LIFELEECHCHANCE:
			return "Life Leech Chance";

		case SPECIALSKILL_LIFELEECHAMOUNT:
			return "Life Leech Amount";

		case SPECIALSKILL_MANALEECHCHANCE:
			return "Mana Leech Chance";

		case SPECIALSKILL_MANALEECHAMOUNT:
			return "Mana Leech Amount";

		default:
			return "unknown";
	}
}

std::string getSkillName(uint8_t skillid)
{
	switch (skillid) {
		case SKILL_FIST:
			return "Healing Power";

		case SKILL_MELEE:
			return "Strenght"; // Melee Fighting

		case SKILL_DISTANCE:
			return "Dexterity"; // Distance Fighting

		case SKILL_SHIELD:
			return "Vitality"; // Shielding

		case SKILL_FISHING:
			return "Intelligence"; // Magic Power

		case SKILL_MAGLEVEL:
			return "Mastery";

		case SKILL_LEVEL:
			return "Level";

		default:
			return "unknown";
	}
}

uint32_t adlerChecksum(const uint8_t* data, size_t length)
{
	if (length > NETWORKMESSAGE_MAXSIZE) {
		return 0;
	}

	const uint16_t adler = 65521;
	#if defined(__SSE2__)
	const __m128i h16 = _mm_setr_epi16(16, 15, 14, 13, 12, 11, 10, 9);
	const __m128i h8 = _mm_setr_epi16(8, 7, 6, 5, 4, 3, 2, 1);
	const __m128i zeros = _mm_setzero_si128();
	#endif

	uint32_t a = 1, b = 0;

	while (length > 0) {
		size_t tmp = length > 5552 ? 5552 : length;
		length -= tmp;

		#if defined(__SSE2__)
		while (tmp >= 16) {
			__m128i vdata = _mm_loadu_si128(reinterpret_cast<const __m128i*>(data));
			__m128i v = _mm_sad_epu8(vdata, zeros);
			__m128i v32 = _mm_add_epi32(_mm_madd_epi16(_mm_unpacklo_epi8(vdata, zeros), h16), _mm_madd_epi16(_mm_unpackhi_epi8(vdata, zeros), h8));
			v32 = _mm_add_epi32(v32, _mm_shuffle_epi32(v32, _MM_SHUFFLE(2, 3, 0, 1)));
			v32 = _mm_add_epi32(v32, _mm_shuffle_epi32(v32, _MM_SHUFFLE(0, 1, 2, 3)));
			v = _mm_add_epi32(v, _mm_shuffle_epi32(v, _MM_SHUFFLE(1, 0, 3, 2)));
			b += (a << 4) + _mm_cvtsi128_si32(v32);
			a += _mm_cvtsi128_si32(v);

			data += 16;
			tmp -= 16;
		}

		while (tmp--) {
			a += *data++; b += a;
		}
		#else
		do {
			a += *data++;
			b += a;
		} while (--tmp);
		#endif

		a %= adler;
		b %= adler;
	}

	return (b << 16) | a;
}

std::string ucfirst(std::string str)
{
	for (char& i : str) {
		if (i != ' ') {
			i = toupper(i);
			break;
		}
	}
	return str;
}

std::string ucwords(std::string str)
{
	size_t strLength = str.length();
	if (strLength == 0) {
		return str;
	}

	str[0] = toupper(str.front());
	for (size_t i = 1; i < strLength; ++i) {
		if (str[i - 1] == ' ') {
			str[i] = toupper(str[i]);
		}
	}

	return str;
}

bool booleanString(const std::string& str)
{
	if (str.empty()) {
		return false;
	}

	char ch = tolower(str.front());
	return ch != 'f' && ch != 'n' && ch != '0';
}

std::string getWeaponName(WeaponType_t weaponType)
{
	switch (weaponType) {
		case WEAPON_SWORD: return "sword";
		case WEAPON_CLUB: return "club";
		case WEAPON_AXE: return "axe";
		case WEAPON_DISTANCE: return "distance";
		case WEAPON_WAND: return "wand";
		case WEAPON_AMMO: return "ammunition";
		default: return std::string();
	}
}

size_t combatTypeToIndex(CombatType_t combatType)
{
	switch (combatType) {
		case COMBAT_PHYSICALDAMAGE:
			return 0;
		case COMBAT_ENERGYDAMAGE:
			return 1;
		case COMBAT_EARTHDAMAGE:
			return 2;
		case COMBAT_FIREDAMAGE:
			return 3;
		case COMBAT_UNDEFINEDDAMAGE:
			return 4;
		case COMBAT_LIFEDRAIN:
			return 5;
		case COMBAT_MANADRAIN:
			return 6;
		case COMBAT_HEALING:
			return 7;
		case COMBAT_DROWNDAMAGE:
			return 8;
		case COMBAT_ICEDAMAGE:
			return 9;
		case COMBAT_HOLYDAMAGE:
			return 10;
		case COMBAT_DEATHDAMAGE:
			return 11;
		default:
			return 0;
	}
}

CombatType_t indexToCombatType(size_t v)
{
	return static_cast<CombatType_t>(1 << v);
}

uint8_t serverFluidToClient(uint8_t serverFluid)
{
	#if GAME_FEATURE_NEWFLUIDS > 0
	uint8_t size = sizeof(clientToServerFluidMap) / sizeof(clientToServerFluidMap[0]);
	for (uint8_t i = 0; i < size; ++i) {
		if (clientToServerFluidMap[i] == serverFluid) {
			return i;
		}
	}
	return 0;
	#else
	return serverFluid;
	#endif
}

uint8_t clientFluidToServer(uint8_t clientFluid)
{
	#if GAME_FEATURE_NEWFLUIDS > 0
	uint8_t size = sizeof(clientToServerFluidMap) / sizeof(clientToServerFluidMap[0]);
	if (clientFluid >= size) {
		return 0;
	}
	return clientToServerFluidMap[clientFluid];
	#else
	return clientFluid;
	#endif
}

itemAttrTypes stringToItemAttribute(const std::string& str)
{
	const char* cstr = str.c_str();
	if (!tfs_strcmp(cstr, "aid")) {
		return ITEM_ATTRIBUTE_ACTIONID;
	} else if (!tfs_strcmp(cstr, "uid")) {
		return ITEM_ATTRIBUTE_UNIQUEID;
	} else if (!tfs_strcmp(cstr, "description")) {
		return ITEM_ATTRIBUTE_DESCRIPTION;
	} else if (!tfs_strcmp(cstr, "text")) {
		return ITEM_ATTRIBUTE_TEXT;
	} else if (!tfs_strcmp(cstr, "date")) {
		return ITEM_ATTRIBUTE_DATE;
	} else if (!tfs_strcmp(cstr, "writer")) {
		return ITEM_ATTRIBUTE_WRITER;
	} else if (!tfs_strcmp(cstr, "name")) {
		return ITEM_ATTRIBUTE_NAME;
	} else if (!tfs_strcmp(cstr, "article")) {
		return ITEM_ATTRIBUTE_ARTICLE;
	} else if (!tfs_strcmp(cstr, "pluralname")) {
		return ITEM_ATTRIBUTE_PLURALNAME;
	} else if (!tfs_strcmp(cstr, "weight")) {
		return ITEM_ATTRIBUTE_WEIGHT;
	} else if (!tfs_strcmp(cstr, "attack")) {
		return ITEM_ATTRIBUTE_ATTACK;
	} else if (!tfs_strcmp(cstr, "defense")) {
		return ITEM_ATTRIBUTE_DEFENSE;
	} else if (!tfs_strcmp(cstr, "extradefense")) {
		return ITEM_ATTRIBUTE_EXTRADEFENSE;
	} else if (!tfs_strcmp(cstr, "armor")) {
		return ITEM_ATTRIBUTE_ARMOR;
	} else if (!tfs_strcmp(cstr, "hitchance")) {
		return ITEM_ATTRIBUTE_HITCHANCE;
	} else if (!tfs_strcmp(cstr, "shootrange")) {
		return ITEM_ATTRIBUTE_SHOOTRANGE;
	} else if (!tfs_strcmp(cstr, "owner")) {
		return ITEM_ATTRIBUTE_OWNER;
	} else if (!tfs_strcmp(cstr, "duration")) {
		return ITEM_ATTRIBUTE_DURATION;
	} else if (!tfs_strcmp(cstr, "decaystate")) {
		return ITEM_ATTRIBUTE_DECAYSTATE;
	} else if (!tfs_strcmp(cstr, "corpseowner")) {
		return ITEM_ATTRIBUTE_CORPSEOWNER;
	} else if (!tfs_strcmp(cstr, "charges")) {
		return ITEM_ATTRIBUTE_CHARGES;
	} else if (!tfs_strcmp(cstr, "fluidtype")) {
		return ITEM_ATTRIBUTE_FLUIDTYPE;
	} else if (!tfs_strcmp(cstr, "doorid")) {
		return ITEM_ATTRIBUTE_DOORID;
	}
	return ITEM_ATTRIBUTE_NONE;
}

void getMailDetails(const std::string& str, std::string& playerName, std::string& townName)
{
	std::string* currentLine = &playerName;
	for (const char c : str) {
		if (c == '\n') {
			if (currentLine == &townName) {
				break;
			} else {
				currentLine = &townName;
				continue;
			}
		}
		currentLine->push_back(c);
	}
}

const char* getReturnMessage(ReturnValue value)
{
	switch (value) {
		case RETURNVALUE_DESTINATIONOUTOFREACH:
			return "Destination is out of reach.";

		case RETURNVALUE_NOTMOVEABLE:
			return "You cannot move this object.";

		case RETURNVALUE_DROPTWOHANDEDITEM:
			return "Drop the double-handed object first.";

		case RETURNVALUE_BOTHHANDSNEEDTOBEFREE:
			return "Both hands need to be free.";

		case RETURNVALUE_CANNOTBEDRESSED:
			return "You cannot dress this object there.";

		case RETURNVALUE_PUTTHISOBJECTINYOURHAND:
			return "Put this object in your hand.";

		case RETURNVALUE_PUTTHISOBJECTINBOTHHANDS:
			return "Put this object in both hands.";

		case RETURNVALUE_CANONLYUSEONEWEAPON:
			return "You may only use one weapon.";

		case RETURNVALUE_TOOFARAWAY:
			return "Too far away.";

		case RETURNVALUE_FIRSTGODOWNSTAIRS:
			return "First go downstairs.";

		case RETURNVALUE_FIRSTGOUPSTAIRS:
			return "First go upstairs.";

		case RETURNVALUE_NOTENOUGHCAPACITY:
			return "This object is too heavy for you to carry.";

		case RETURNVALUE_CONTAINERNOTENOUGHROOM:
			return "You cannot put more objects in this container.";

		case RETURNVALUE_CONTAINERONLYSPELLRUNES:
			return "You can only put support runes in this rune.";

		case RETURNVALUE_CONTAINERONLYONE:
			return "You can't put duplicates in this container.";

		case RETURNVALUE_NEEDEXCHANGE:
		case RETURNVALUE_NOTENOUGHROOM:
			return "There is not enough room.";

		case RETURNVALUE_CANNOTPICKUP:
			return "You cannot take this object.";

		case RETURNVALUE_CANNOTTHROW:
			return "You cannot throw there.";

		case RETURNVALUE_THEREISNOWAY:
			return "There is no way.";

		case RETURNVALUE_THISISIMPOSSIBLE:
			return "This is impossible.";

		case RETURNVALUE_PLAYERISPZLOCKED:
			return "You can not enter a protection zone after attacking another player.";

		case RETURNVALUE_PLAYERISNOTINVITED:
			return "You are not invited.";

		case RETURNVALUE_CREATUREDOESNOTEXIST:
			return "Creature does not exist.";

		case RETURNVALUE_DEPOTISFULL:
			return "You cannot put more items in this depot.";

		case RETURNVALUE_CANNOTUSETHISOBJECT:
			return "You cannot use this object.";

		case RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE:
			return "A player with this name is not online.";

		case RETURNVALUE_NOTREQUIREDLEVELTOUSERUNE:
			return "You do not have the required mastery to use this rune.";

		case RETURNVALUE_YOUAREALREADYTRADING:
			return "You are already trading.";

		case RETURNVALUE_THISPLAYERISALREADYTRADING:
			return "This player is already trading.";

		case RETURNVALUE_YOUMAYNOTLOGOUTDURINGAFIGHT:
			return "You may not logout during or immediately after a fight!";

		case RETURNVALUE_DIRECTPLAYERSHOOT:
			return "You are not allowed to shoot directly on players.";

		case RETURNVALUE_NOTENOUGHLEVEL:
			return "You do not have enough level.";

		case RETURNVALUE_NOTENOUGHMAGICLEVEL:
			return "You do not have enough mastery.";

		case RETURNVALUE_NOTENOUGHMANA:
			return "You do not have enough mana.";

		case RETURNVALUE_NOTENOUGHSOUL:
			return "You do not have enough soul.";

		case RETURNVALUE_YOUAREEXHAUSTED:
			return "You are exhausted.";

		case RETURNVALUE_CANONLYUSETHISRUNEONCREATURES:
			return "You can only use this rune on creatures.";

		case RETURNVALUE_PLAYERISNOTREACHABLE:
			return "Player is not reachable.";

		case RETURNVALUE_CREATUREISNOTREACHABLE:
			return "Creature is not reachable.";

		case RETURNVALUE_ACTIONNOTPERMITTEDINPROTECTIONZONE:
			return "This action is not permitted in a protection zone.";
		
		case RETURNVALUE_SPAWNBLOCKINGTHISCREATURE:
			return "You've spawn-blocked this creature. You can't attack it right now, move away first, then you'll be able to attack.";

		case RETURNVALUE_YOUCANONLYUSEITONCREATURES:
			return "You can only use it on creatures.";

		case RETURNVALUE_TURNSECUREMODETOATTACKUNMARKEDPLAYERS:
			return "Turn secure mode off if you really want to attack unmarked players.";

		case RETURNVALUE_YOUNEEDPREMIUMACCOUNT:
			return "You need a premium account.";

		case RETURNVALUE_YOUNEEDTOLEARNTHISSPELL:
			return "You need to learn this spell first.";

		case RETURNVALUE_YOURVOCATIONCANNOTUSETHISSPELL:
			return "Your vocation cannot use this spell.";

		case RETURNVALUE_YOUNEEDAWEAPONTOUSETHISSPELL:
			return "You need to equip a weapon to use this spell.";

		case RETURNVALUE_PLAYERISPZLOCKEDLEAVEPVPZONE:
			return "You can not leave a pvp zone after attacking another player.";

		case RETURNVALUE_PLAYERISPZLOCKEDENTERPVPZONE:
			return "You can not enter a pvp zone after attacking another player.";

		case RETURNVALUE_ACTIONNOTPERMITTEDINANOPVPZONE:
			return "This action is not permitted in a non pvp zone.";

		case RETURNVALUE_YOUCANNOTLOGOUTHERE:
			return "You can not logout here.";

		case RETURNVALUE_YOUNEEDAMAGICITEMTOCASTSPELL:
			return "You need a magic item to cast this spell.";

		case RETURNVALUE_CANNOTCONJUREITEMHERE:
			return "You cannot conjure items here.";

		case RETURNVALUE_YOUNEEDTOSPLITYOURSPEARS:
			return "You need to split your spears first.";

		case RETURNVALUE_NAMEISTOOAMBIGUOUS:
			return "Player name is ambiguous.";

		case RETURNVALUE_CANONLYUSEONESHIELD:
			return "You may use only one shield.";

		case RETURNVALUE_NOPARTYMEMBERSINRANGE:
			return "No party members in range.";

		case RETURNVALUE_YOUARENOTTHEOWNER:
			return "You are not the owner.";

		case RETURNVALUE_NOSUCHRAIDEXISTS:
			return "No such raid exists.";

		case RETURNVALUE_ANOTHERRAIDISALREADYEXECUTING:
			return "Another raid is already executing.";

		case RETURNVALUE_TRADEPLAYERFARAWAY:
			return "Trade player is too far away.";

		case RETURNVALUE_YOUDONTOWNTHISHOUSE:
			return "You don't own this house.";

		case RETURNVALUE_TRADEPLAYERALREADYOWNSAHOUSE:
			return "Trade player already owns a house.";

		case RETURNVALUE_TRADEPLAYERHIGHESTBIDDER:
			return "Trade player is currently the highest bidder of an auctioned house.";

		case RETURNVALUE_YOUCANNOTTRADETHISHOUSE:
			return "You can not trade this house.";

		default: // RETURNVALUE_NOTPOSSIBLE, etc
			return "Sorry, not possible.";
	}
}

int64_t OTSYS_TIME()
{
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
}

SpellGroup_t stringToSpellGroup(const std::string& value)
{
	std::string tmpStr = asLowerCaseString(value);
	if (!tfs_strcmp(tmpStr.c_str(), "attack") || !tfs_strcmp(tmpStr.c_str(), "1")) {
		return SPELLGROUP_ATTACK;
	} else if (!tfs_strcmp(tmpStr.c_str(), "healing") || !tfs_strcmp(tmpStr.c_str(), "2")) {
		return SPELLGROUP_HEALING;
	} else if (!tfs_strcmp(tmpStr.c_str(), "support") || !tfs_strcmp(tmpStr.c_str(), "3")) {
		return SPELLGROUP_SUPPORT;
	} else if (!tfs_strcmp(tmpStr.c_str(), "special") || !tfs_strcmp(tmpStr.c_str(), "4")) {
		return SPELLGROUP_SPECIAL;
	}
	return SPELLGROUP_NONE;
}

std::string formatDateEx(time_t _time/* = 0*/, std::string format/* = "%d %b %Y, %H:%M:%S"*/)
{
	if (!_time)
		_time = time(NULL);

	const tm* tms = localtime(&_time);
	char buffer[100];
	if (tms)
		strftime(buffer, 25, format.c_str(), tms);
	else
		sprintf(buffer, "UNIX Time: %d", (int32_t)_time);

	return buffer;
}

#if defined(__SSE4_2__)
int tfs_strncmp(const char* s1, const char* s2, size_t n)
{
	// Use standard strncmp which is safe and optimized
	return std::strncmp(s1, s2, n);
}

int tfs_strcmp(const char* s1, const char* s2)
{
	if (s1 == nullptr || s2 == nullptr) {
		if (s1 == s2) return 0;
		return (s1 == nullptr) ? -1 : 1;
	}
	
	// Use standard strcmp which is safe and optimized
	return std::strcmp(s1, s2);
}
#endif

std::string transformToAES(const std::string& input) {
    // Hardcoded AES key and IV
    const unsigned char key[32] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
    };

    unsigned char iv[16] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
    };

    // Use EVP API (OpenSSL 3.0+ compatible)
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) {
        return "";
    }

    // Initialize encryption operation with AES-256-CBC
    if (EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), nullptr, key, iv) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return "";
    }

    int inputLength = input.length();
    int maxOutputLength = inputLength + AES_BLOCK_SIZE;
    unsigned char* encrypted = new unsigned char[maxOutputLength];
    
    int encryptedLength = 0;
    int finalLength = 0;

    // Perform encryption
    if (EVP_EncryptUpdate(ctx, encrypted, &encryptedLength, 
                          reinterpret_cast<const unsigned char*>(input.c_str()), inputLength) != 1) {
        delete[] encrypted;
        EVP_CIPHER_CTX_free(ctx);
        return "";
    }

    // Finalize encryption (adds padding)
    if (EVP_EncryptFinal_ex(ctx, encrypted + encryptedLength, &finalLength) != 1) {
        delete[] encrypted;
        EVP_CIPHER_CTX_free(ctx);
        return "";
    }

    int totalLength = encryptedLength + finalLength;

    // Convert to hex string
    std::string encryptedHex;
    encryptedHex.reserve(totalLength * 2);
    for (int i = 0; i < totalLength; ++i) {
        char hex[3];
        sprintf(hex, "%02x", encrypted[i]);
        encryptedHex.append(hex);
    }

    delete[] encrypted;
    EVP_CIPHER_CTX_free(ctx);

    return encryptedHex;
}