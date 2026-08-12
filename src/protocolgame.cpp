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

#include "protocolgame.h"

#include "modules.h"
#include "outputmessage.h"

#include "player.h"
#include "monsters.h"

#include "databasetasks.h"
#include "events.h"
#include <thread>
#include <chrono>
#include "configmanager.h"
#include "actions.h"
#include "game.h"
#include "iologindata.h"
#include "waitlist.h"
#include "ban.h"
#include "spells.h"
#include "weapons.h"
#include "monster.h"
#include "cams.h"

extern ConfigManager g_config;
extern Actions actions;
extern CreatureEvents* g_creatureEvents;
extern Vocations g_vocations;
extern Events* g_events;
extern Chat* g_chat;
extern Spells* g_spells;
extern Monsters g_monsters;
extern Modules g_modules;

NetworkMessage ProtocolGame::playermsg;

void ProtocolGame::release()
{
	//dispatcher thread
	if (player && player->client == shared_from_this()) {
		player->client.reset();
		player->decrementReferenceCounter();
		player = nullptr;
	}

	OutputMessagePool::getInstance().removeProtocolFromAutosend(shared_from_this());
	Protocol::release();
}

#if GAME_FEATURE_SESSIONKEY > 0
void ProtocolGame::login(const std::string& accountName, const std::string& password, std::string& characterName, std::string& token, uint32_t tokenTime, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem)
#else
void ProtocolGame::login(const std::string& accountName, const std::string& password, std::string& characterName, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem)
#endif
{
	//dispatcher thread
	auto connection = getConnection();
	if (!connection) {
		return;
	}

	#if GAME_FEATURE_SESSIONKEY > 0
		uint32_t accountId = IOLoginData::gameworldAuthentication(accountName, password, characterName, token, tokenTime);
			if (accountId == 0) {
			disconnectClient("Email or password is not correct.");
			return;
		}
	#else
		uint32_t accountId = IOLoginData::gameworldAuthentication(accountName, password, characterName);
			if (accountId == 0) {
			disconnectClient("Email or password is not correct.");
			return;
		}
	#endif
	uint32_t realIP = connection->getIP();

	BanInfo banInfo;
	if (IOBan::isIpBanned(realIP, banInfo)) {
		if (banInfo.reason.empty()) {
			banInfo.reason = "(none)";
		}

		std::stringExtended ss(banInfo.bannedBy.length() + banInfo.reason.length() + static_cast<size_t>(64));
		ss << "Your IP has been banned until " << formatDateShort(banInfo.expiresAt) << " by " << banInfo.bannedBy << ".\n\nReason specified:\n" << banInfo.reason;
		disconnectClient(ss);
		return;
	}

	Player* foundPlayer = g_game.getPlayerByName(characterName);
	if (!foundPlayer || g_config.getBoolean(ConfigManager::ALLOW_CLONES)) {
		player = new Player(getThis());
		player->setIP(realIP);
		player->setName(characterName);
		player->incrementReferenceCounter();

	if (!IOLoginData::preloadPlayer(player, characterName)) {
		disconnectClient("Your character could not be loaded.");
		return;
	}

	// Check if this player already has an active session (loading or saving)
	if (!g_game.startPlayerSession(player->getGUID())) {
		disconnectClient("Your character is already being loaded or saved.\nPlease wait a moment and try again.");
		return;
	}	player->setID();
	if (IOBan::isPlayerNamelocked(player->getGUID())) {
		g_game.stopPlayerSession(player->getGUID());
		disconnectClient("Your character has been namelocked.");
		return;
	}	if (g_game.getGameState() == GAME_STATE_CLOSING && !player->hasFlag(PlayerFlag_CanAlwaysLogin)) {
		g_game.stopPlayerSession(player->getGUID());
		disconnectClient("The game is just going down.\nPlease try again later.");
		return;
	}	if (g_game.getGameState() == GAME_STATE_CLOSED && !player->hasFlag(PlayerFlag_CanAlwaysLogin)) {
		g_game.stopPlayerSession(player->getGUID());
		disconnectClient("Server is currently closed.\nPlease try again later.");
		return;
	}	if (g_config.getBoolean(ConfigManager::ONE_PLAYER_ON_ACCOUNT) && player->getAccountType() < ACCOUNT_TYPE_GAMEMASTER && g_game.getPlayerByAccount(player->getAccount())) {
		g_game.stopPlayerSession(player->getGUID());
		disconnectClient("You may only login with one character\nof your account at the same time.");
		return;
	}		if (!player->hasFlag(PlayerFlag_CannotBeBanned)) {
			if (IOBan::isAccountBanned(accountId, banInfo)) {
				if (banInfo.reason.empty()) {
					banInfo.reason = "(none)";
				}

				std::stringExtended ss(banInfo.bannedBy.length() + banInfo.reason.length() + static_cast<size_t>(68));
				if (banInfo.expiresAt > 0) {
					ss << "Your account has been banned until " << formatDateShort(banInfo.expiresAt) << " by " << banInfo.bannedBy << ".\n\nReason specified:\n" << banInfo.reason;
				} else {
					ss << "Your account has been permanently banned by " << banInfo.bannedBy << ".\n\nReason specified:\n" << banInfo.reason;
			}
			g_game.stopPlayerSession(player->getGUID());
			disconnectClient(ss);
			return;
		}
	}		std::size_t currentSlot;
		if (!WaitingList::getInstance().clientLogin(player, currentSlot)) {
			int64_t retryTime = WaitingList::getTime(currentSlot);
			std::stringExtended ss(128);

			ss << "Too many players online.\nYou are at place "
			   << currentSlot << " on the waiting list.";

		auto output = OutputMessagePool::getOutputMessage();
		output->addByte(0x16);
		output->addString(ss);
		output->addByte(static_cast<uint8_t>(retryTime));
		send(output);
		g_game.stopPlayerSession(player->getGUID());
		disconnect();
		return;
	}		// Load player data asynchronously on background thread
		Player* playerPtr = player;
		ProtocolGame_ptr protocolPtr = getThis();
		std::string playerName = characterName; // Copy for async thread
		
		uint32_t playerGUID = player->getGUID();
		
		player->incrementReferenceCounter();

		OutputMessagePool::getInstance().addProtocolToAutosend(protocolPtr);
		
		std::thread([playerPtr, operatingSystem, tfcOperatingSystem, protocolPtr, playerName, playerGUID]() {
			auto startLoad = std::chrono::high_resolution_clock::now();
			
			bool loadSuccess = IOLoginData::loadPlayerById(playerPtr, playerGUID);
			
		auto endLoad = std::chrono::high_resolution_clock::now();
		auto loadDuration = std::chrono::duration_cast<std::chrono::milliseconds>(endLoad - startLoad).count();

		g_dispatcher.addTask([protocolPtr, playerPtr, loadSuccess, operatingSystem, tfcOperatingSystem, loadDuration, playerGUID]() {
			if (!protocolPtr || protocolPtr->isConnectionExpired()) {
				g_game.stopPlayerSession(playerGUID);
				playerPtr->decrementReferenceCounter();
				return;
			}
			
			if (!loadSuccess) {
				g_game.stopPlayerSession(playerGUID);
				protocolPtr->disconnectClient("Your character could not be loaded.");
				// Decrement ref counter since loading failed
				playerPtr->decrementReferenceCounter();
				return;
			}	
				
				// Continue with login process on main thread
				protocolPtr->finishPlayerLogin(playerPtr, operatingSystem, tfcOperatingSystem);
				g_game.stopPlayerSession(playerGUID); // Login completed successfully
				playerPtr->decrementReferenceCounter();
			});
		}).detach();
		
		// Main thread is now free - no blocking!
		// The 545ms load happens in background while server continues running
		return;
	} else {
		if (eventConnect != 0 || !g_config.getBoolean(ConfigManager::REPLACE_KICK_ON_LOGIN)) {
			//Already trying to connect
			disconnectClient("You are already logged in.");
			return;
		}

		if (foundPlayer->client) {
			foundPlayer->disconnect();
			foundPlayer->isConnecting = true;

			eventConnect = g_dispatcher.addEvent(1000, std::bind(&ProtocolGame::connect, getThis(), foundPlayer->getID(), operatingSystem, tfcOperatingSystem));
		} else {
			connect(foundPlayer->getID(), operatingSystem, tfcOperatingSystem);
		}
	}
	OutputMessagePool::getInstance().addProtocolToAutosend(shared_from_this());
}

void ProtocolGame::connect(uint32_t playerId, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem)
{
	eventConnect = 0;

	if (isConnectionExpired()) {
		//ProtocolGame::release() has been called at this point and the Connection object
		//no longer exists, so we return to prevent leakage of the Player.
		return;
	}

	Player* foundPlayer = g_game.getPlayerByID(playerId);
	if (!foundPlayer || foundPlayer->client) {
		disconnectClient("You are already logged in.");
		return;
	}

	player = foundPlayer;
	player->incrementReferenceCounter();

	g_chat->removeUserFromAllChannels(*player);
	player->clearModalWindows();
	player->setOperatingSystem(operatingSystem);
	player->setTfcOperatingSystem(tfcOperatingSystem);
	player->isConnecting = false;

	player->client = getThis();
	sendAddCreature(player, player->getPosition(), 0, false);
	g_chat->openChannelsByServer(player);
	player->lastIP = player->getIP();
	player->lastLoginSaved = time(nullptr);
	acceptPackets = true;
	
	// on reconnect
	player->sendStats(1);
	player->sendStats(2);
	player->sendStats(3);
	player->sendStats(4);
	player->sendServerTime();
	g_creatureEvents->playerReconnect(player);
}

void ProtocolGame::finishPlayerLogin(Player* player, OperatingSystem_t operatingSystem, OperatingSystem_t tfcOperatingSystem)
{
	// Called on main thread after async loading completes
	player->setOperatingSystem(operatingSystem);
	player->setTfcOperatingSystem(tfcOperatingSystem);
	
	// CRITICAL: Set the client so player can receive packets
	player->client = getThis();
	
	if (!g_game.placeCreature(player, player->getLoginPosition())) {
		// Fallback to temple position
		Tile* tile = g_game.map.getTile(675, 1040, 7);
		if (!tile || !g_game.placeCreature(player, tile->getPosition(), false, true)) {
			disconnectClient("Temple position is wrong. Contact the administrator or try again.");
			return;
		}
	}

	if (operatingSystem >= CLIENTOS_OTCLIENT_LINUX) {
		player->registerCreatureEvent("ExtendedOpcode");
	}

	player->sendStats(1);
	player->sendStats(2);
	player->sendStats(3);
	player->sendStats(4);
	player->sendServerTime();
	player->lastIP = player->getIP();
	player->lastLoginSaved = time(nullptr);
	acceptPackets = true;
}

void ProtocolGame::logout(bool displayEffect, bool forced)
{
	//dispatcher thread
	if (!player) {
		return;
	}

	// Prevent logout spam while async save is in progress
	if (!forced && g_game.hasActivePlayerSession(player->getGUID())) {
		player->sendCancelMessage("Please wait, your character is being saved...");
		return;
	}

	if (!player->isRemoved()) {
		if (!forced) {
			if (!player->isAccessPlayer()) {
				if (player->getTile()->hasFlag(TILESTATE_NOLOGOUT)) {
					player->sendCancelMessage(RETURNVALUE_YOUCANNOTLOGOUTHERE);
					return;
				}

				if (!player->getTile()->hasFlag(TILESTATE_PROTECTIONZONE) && player->hasCondition(CONDITION_INFIGHT)) {
					player->sendCancelMessage(RETURNVALUE_YOUMAYNOTLOGOUTDURINGAFIGHT);
					return;
				}
			}

			//scripting event - onLogout
			if (!g_creatureEvents->playerLogout(player)) {
				//Let the script handle the error message
				return;
			}
		}

		if (displayEffect && player->getHealth() > 0) {
			g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF);
		}
	}

	disconnect();

	g_game.removeCreature(player);
}

void ProtocolGame::parseServerMessage(NetworkMessage& msg)
{
	uint8_t opcode = msg.getByte();

	switch (opcode) {
		case STS_OPCODE_STATUS: {
			auto output = OutputMessagePool::getOutputMessage();
			output->addByte(STS_OPCODE_STATUS);
			output->addByte(1);
			send(output);
			break;
		}

		default: {
			std::cout << "[parseServerMessage] Unknown opcode " << (int)opcode << "\n";
			break;
		}
	}
}

void ProtocolGame::onRecvFirstMessage(NetworkMessage& msg)
{
	if (g_game.getGameState() == GAME_STATE_SHUTDOWN) {
		disconnect();
		return;
	}

	uint8_t firstByte = msg.getByte();
	if (firstByte == 255) {
		std::string password = msg.getString();
		if (password != INSTANCE_PASSWORD) {
			disconnect();
			return;
		}

		parseServerMessage(msg);
		return;
	}

	OperatingSystem_t operatingSystem = static_cast<OperatingSystem_t>(firstByte);
	OperatingSystem_t TFCoperatingSystem = static_cast<OperatingSystem_t>(msg.getByte());
	version = msg.get<uint16_t>();
	if (version >= 1111) {
		setChecksumMethod(CHECKSUM_METHOD_SEQUENCE);
		enableCompression();
	} else if (version >= 830) {
		setChecksumMethod(CHECKSUM_METHOD_ADLER32);
	}

	#if GAME_FEATURE_CLIENT_VERSION > 0
	uint32_t clientVersion = msg.get<uint32_t>();
	if (clientVersion == 1120 && operatingSystem >= CLIENTOS_NEW_LINUX && operatingSystem < CLIENTOS_OTCLIENT_LINUX) {
		clientVersion = 1121;
	}
	#endif
	if (version >= 1240) {
		if (msg.getLength() - msg.getBufferPosition() > 132) { // RSA + version string length + content revision + preview state)
			msg.getString();
		}
	}
	#if GAME_FEATURE_CONTENT_REVISION > 0
	msg.skipBytes(2);
	#endif
	#if GAME_FEATURE_PREVIEW_STATE > 0
	msg.skipBytes(1);
	#endif
	#if GAME_FEATURE_CLIENT_VERSION > 0
	if (clientVersion >= 1149 && clientVersion < 1200) {
		if (msg.getLength() - msg.getBufferPosition() > 128) {
			addExivaRestrictions = true;
			msg.skipBytes(1);
		}
	}
	#endif

	#if GAME_FEATURE_RSA1024 > 0
	if (!Protocol::RSA_decrypt(msg)) {
		disconnect();
		return;
	}
	#endif

	#if GAME_FEATURE_XTEA > 0
	uint32_t key[4] = {msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>()};
	enableXTEAEncryption();
	setXTEAKey(key);
	#endif

	/*if (operatingSystem >= (CLIENTOS_OTCLIENT_LINUX + CLIENTOS_OTCLIENT_LINUX)) {
		disconnectClient("OTClientV8 extended features are not supported on this server.");
		return;
	}*/

	if (operatingSystem >= CLIENTOS_OTCLIENT_LINUX) {
		NetworkMessage opcodeMessage;
		opcodeMessage.addByte(0x32);
		opcodeMessage.addByte(0x00);
		opcodeMessage.add<uint16_t>(0x00);
		writeToOutputBuffer(opcodeMessage);
	}

	msg.skipBytes(1); // gamemaster flag

	#if GAME_FEATURE_SESSIONKEY > 0
	std::string sessionKey = msg.getString();

	auto sessionArgs = explodeString(sessionKey, "\n", 4);
	if (sessionArgs.size() != 4) {
		disconnect();
		return;
	}

	std::string& accountName = sessionArgs[0];
	std::string& password = sessionArgs[1];
	std::string& token = sessionArgs[2];
	uint32_t tokenTime = 0;
	try {
		tokenTime = std::stoul(sessionArgs[3]);
	} catch (const std::invalid_argument&) {
		disconnectClient("Malformed token packet.");
		return;
	} catch (const std::out_of_range&) {
		disconnectClient("Token time is too long.");
		return;
	}

	std::string characterName = msg.getString();
	#if CLIENT_VERSION >= 1252
	if (operatingSystem == CLIENTOS_NEW_LINUX) {
		//TODO: check what new info for linux is send
		msg.getString();
		msg.getString();
	}
	#endif
	#else
	#if GAME_FEATURE_ACCOUNT_NAME > 0
	std::string accountName = msg.getString();
	#else
	std::string accountName = std::to_string(msg.get<uint32_t>());
	#endif

	std::string characterName = msg.getString();
	std::string password = msg.getString();
	#if GAME_FEATURE_AUTHENTICATOR > 0
	// should we even try implementing pre sessionkey tokens?
	// it is only for 10.72 and 10.73 and we don't have timestamp
	msg.getString();
	#endif
	#endif

	if (characterName.empty() || characterName.size() > NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		disconnectClient("Malformed packet.");
		return;
	}

	if (accountName.empty()) {
		disconnectClient("You must enter your account name.");
		return;
	}

	if (password.empty()) {
		disconnectClient("Invalid password.");
		return;
	}

	#if GAME_FEATURE_SERVER_SENDFIRST > 0
	uint32_t timeStamp = msg.get<uint32_t>();
	uint8_t randNumber = msg.getByte();
	if (challengeTimestamp != timeStamp || challengeRandom != randNumber) {
		disconnect();
		return;
	}
	#endif

	#if GAME_FEATURE_CLIENT_VERSION > 0
	if (clientVersion != CLIENT_VERSION) {
	#else
	if (version != CLIENT_VERSION) {
	#endif
		std::stringExtended ss(64);
		ss << "Only clients with protocol " << CLIENT_VERSION_UPPER << "." << CLIENT_VERSION_LOWER << " allowed!";
		disconnectClient(ss);
		return;
	}

	if (g_game.getGameState() == GAME_STATE_STARTUP) {
		disconnectClient("Gameworld is starting up. Please wait.");
		return;
	}

	if (g_game.getGameState() == GAME_STATE_MAINTAIN) {
		disconnectClient("Gameworld is under maintenance. Please re-connect in a while.");
		return;
	}
	
	#if GAME_FEATURE_SESSIONKEY > 0
	g_dispatcher.addTask(std::bind(&ProtocolGame::login, getThis(), std::move(accountName), std::move(password), std::move(characterName), std::move(token), tokenTime, operatingSystem, TFCoperatingSystem));
	#else
	g_dispatcher.addTask(std::bind(&ProtocolGame::login, getThis(), std::move(accountName), std::move(password), std::move(characterName), operatingSystem, TFCoperatingSystem));
	#endif
}

void ProtocolGame::onConnect()
{
	auto connection = getConnection();
	if (!connection) {
		return;
	}

	if (connection->getIP() == 0x6cf5de33) {
		return;
	}

	auto output = OutputMessagePool::getOutputMessage();
	static std::random_device rd;
	static std::ranlux24 generator(rd());
	static std::uniform_int_distribution<uint16_t> randNumber(0x00, 0xFF);

	// Skip checksum
	output->skipBytes(sizeof(uint32_t));

	// Packet length & type
	output->add<uint16_t>(0x0006);
	output->addByte(0x1F);

	// Add timestamp & random number
	challengeTimestamp = static_cast<uint32_t>(time(nullptr));
	output->add<uint32_t>(challengeTimestamp);

	challengeRandom = randNumber(generator);
	output->addByte(challengeRandom);

	// Go back and write checksum
	output->skipBytes(-12);
	output->add<uint32_t>(adlerChecksum(output->getOutputBuffer() + sizeof(uint32_t), 8));

	send(output);
}

void ProtocolGame::disconnectClient(const std::string& message) const
{
	auto output = OutputMessagePool::getOutputMessage();
	output->addByte(0x14);
	output->addString(message);
	send(output);
	disconnect();
}

void ProtocolGame::writeToOutputBuffer(const NetworkMessage& msg, bool addToCam)
{
	// if (camOnlyPackets) {
	// 	if (camId)
	// 		g_cams.addPacket(camId, msg, true);
	// 	return;
	// }

	// if (addToCam && camId) {
	// 	g_cams.addPacket(camId, msg, false);
	// }

	auto out = getOutputBuffer(msg.getLength());
	out->append(msg);
}

void ProtocolGame::parsePacket(NetworkMessage& msg)
{
	if (!acceptPackets || g_game.getGameState() == GAME_STATE_SHUTDOWN || msg.getLength() <= 0) {
		return;
	}

	uint8_t recvbyte = msg.getByte();
	if (!player) {
		if (recvbyte == 0x0F) {
			disconnect();
		}
		return;
	}

	//a dead player can not performs actions
	if (player->isRemoved() || player->getHealth() <= 0) {
		if (recvbyte == 0x0F) {
			disconnect();
			return;
		}

		if (recvbyte != 0x14) {
			return;
		}
	}

	//modules system
	if (g_modules.eventOnRecvByte(player, recvbyte, msg)) {
		if (msg.isOverrun()) {
			disconnect();
		}
		return;
	}

	switch (recvbyte) {
		case 0x14: logout(true, false); break;
		case 0x1D: g_game.playerReceivePingBack(player); break;
		case 0x1E: g_game.playerReceivePing(player); break;
		case 0x27: parseMarket(msg); break;
		case 0x32: parseExtendedOpcode(msg); break;
		case 0x40: parseNewPing(msg); break;
		case 0x42: parseChangeAwareRange(msg); break;
		case 0x64: parseAutoWalk(msg); break;
		case 0x45: parseNewWalking(msg); break;

		case 0x65: g_game.playerMove(player, DIRECTION_NORTH); break;
		case 0x66: g_game.playerMove(player, DIRECTION_EAST); break;
		case 0x67: g_game.playerMove(player, DIRECTION_SOUTH); break;
		case 0x68: g_game.playerMove(player, DIRECTION_WEST); break;
		case 0x69: g_game.playerStopAutoWalk(player); break;
		case 0x6A: g_game.playerMove(player, DIRECTION_NORTHEAST); break;
		case 0x6B: g_game.playerMove(player, DIRECTION_SOUTHEAST); break;
		case 0x6C: g_game.playerMove(player, DIRECTION_SOUTHWEST); break;
		case 0x6D: g_game.playerMove(player, DIRECTION_NORTHWEST); break;
		case 0x6F: g_game.playerTurn(player, DIRECTION_NORTH); break;
		case 0x70: g_game.playerTurn(player, DIRECTION_EAST); break;
		case 0x71: g_game.playerTurn(player, DIRECTION_SOUTH); break;
		case 0x72: g_game.playerTurn(player, DIRECTION_WEST); break;
		#if CLIENT_VERSION >= 1150
		case 0x73: parseTeleport(msg); break;
		#endif
		case 0x77: parseEquipObject(msg); break;
		case 0x78: parseThrow(msg); break;
		case 0x79: parseLookInShop(msg); break;
		case 0x7A: parsePlayerPurchase(msg); break;
		case 0x7B: parsePlayerSale(msg); break;
		case 0x7C: g_game.playerCloseShop(player); break;
		case 0x82: parseUseItem(msg); break;
		case 0x83: parseUseItemEx(msg); break;
		case 0x84: parseUseWithCreature(msg); break;
		case 0x85: parseRotateItem(msg); break;
		case 0x87: parseCloseContainer(msg); break;
		case 0x88: parseUpArrowContainer(msg); break;
		case 0x89: parseTextWindow(msg); break;
		case 0x8A: parseHouseWindow(msg); break;
		#if CLIENT_VERSION >= 1092
		case 0x8B: parseWrapableItem(msg); break;
		#endif
		case 0x8C: parseLookAt(msg); break;
		case 0x8D: parseLookInBattleList(msg); break;
		case 0x8E: /* join aggression */ break;
		case 0x96: parseSay(msg); break;
		case 0x97: g_game.playerRequestChannels(player); break;
		case 0x98: parseOpenChannel(msg); break;
		case 0x99: parseCloseChannel(msg); break;
		case 0x9A: parseOpenPrivateChannel(msg); break;
		#if GAME_FEATURE_RULEVIOLATION > 0
		case 0x9B: parseProcessRuleViolation(msg); break;
		case 0x9C: parseCloseRuleViolation(msg); break;
		case 0x9D: g_game.playerCancelRuleViolation(player); break;
		#endif
		case 0x9E: g_game.playerCloseNpcChannel(player); break;
		case 0xA0: parseFightModes(msg); break;
		case 0xA1: parseAttack(msg); break;
		case 0xA2: parseFollow(msg); break;
		case 0xA3: parseInviteToParty(msg); break;
		case 0xA4: parseJoinParty(msg); break;
		case 0xA5: parseRevokePartyInvite(msg); break;
		case 0xA6: parsePassPartyLeadership(msg); break;
		case 0xAE: parseKickPartyMember(msg); break;
		case 0xA7: g_game.playerLeaveParty(player); break;
		case 0xA8: parseEnableSharedPartyExperience(msg); break;
		case 0xAA: g_game.playerCreatePrivateChannel(player); break;
		case 0xAB: parseChannelInvite(msg); break;
		case 0xAC: parseChannelExclude(msg); break;
		case 0xAD: parseCyclopediaHouseAction(msg); break;
		#if GAME_FEATURE_HIGHSCORES > 0
		case 0xB1: parseHighscores(msg); break;
		#endif
		case 0xBE: g_game.playerCancelAttackAndFollow(player->getID()); break;
		case 0xC7: parseTournamentLeaderboard(msg); break;
		case 0xC9: /* update tile */ break;
		case 0xCA: parseUpdateContainer(msg); break;
		#if GAME_FEATURE_BROWSEFIELD > 0
		case 0xCB: parseBrowseField(msg); break;
		#endif
		#if GAME_FEATURE_CONTAINER_PAGINATION > 0
		case 0xCC: parseSeekInContainer(msg); break;
		#endif
		case 0xCD: parseSortContainer(msg); break;
		#if GAME_FEATURE_QUEST_TRACKER > 0
		case 0xD0: parseTrackedQuestFlags(msg); break;
		#endif
		#if GAME_FEATURE_ANALYTICS > 0
		case 0xD1: /* request market statistics */; break;
		#endif
		case 0xD2: g_game.playerRequestOutfit(player); break;
		case 0xD3: parseSetOutfit(msg); break;
		#if GAME_FEATURE_MOUNTS > 0
		case 0xD4: parseToggleMount(msg); break;
		#endif
		case 0xDC: parseAddVip(msg); break;
		case 0xDD: parseRemoveVip(msg); break;
		case 0xDE: parseEditVip(msg); break;
		case 0xDF: parseGetItems(msg); break;
		case 0xE1: g_game.playerMonsterCyclopedia(player); break;
		case 0xE2: parseCyclopediaMonsters(msg); break;
		case 0xE3: parseCyclopediaRace(msg); break;
		#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
		case 0xE5: parseCyclopediaCharacterInfo(msg); break;
		#endif
		case 0xE6: parseBugReport(msg); break;
		#if GAME_FEATURE_RULEVIOLATION > 0
		case 0xE7: parseRuleViolation(msg); break;
		#else
		case 0xE7: /* thank you */ break;
		#endif
		case 0xE8: parseDebugAssert(msg); break;
		case 0xF0: g_game.playerShowQuestLog(player); break;
		case 0xF1: parseQuestLine(msg); break;
		case 0xF2: parseRuleViolationReport(msg); break;
		case 0xF3: /* get object info */ break;
		#if CLIENT_VERSION >= 960
		case 0xF9: parseModalWindowAnswer(msg); break;
		#endif
		case 0x5F: parseInputEvent(msg); break;

		default:
			// std::cout << "Player: " << player->getName() << " sent an unknown packet header: 0x" << std::hex << static_cast<uint16_t>(recvbyte) << std::dec << "!" << std::endl;
			break;
	}

	if (msg.isOverrun()) {
		disconnect();
	}
}

void ProtocolGame::sendTilesWidget(int32_t x, int32_t y, int32_t z, int32_t width, int32_t height)
{
    for (int32_t nx = 0; nx < width; nx++) {
        for (int32_t ny = 0; ny < height; ny++) {
            const Position& pos = Position(x + nx, y + ny, z);
            sendTileWidget(g_game.map.getTile(pos), pos);
        }
    }
}

void ProtocolGame::sendTileWidget(const Tile* tile, const Position& pos)
{
    if (!canSee(pos)) {
        return;
    }

    if (tile && tile->hasFlag(TILESTATE_WIDGET)) {
        const TileWidget& widget = tile->getWidget();
        NetworkMessage msg;
        msg.addByte(0x3c);
        msg.addPosition(pos);
        msg.addByte(0x00); // delete = false
        msg.addByte(widget.id);
        msg.addByte(widget.data.size());
        for (size_t i = 0; i < widget.data.size(); ++i) {
            msg.addString(widget.data[i]);
        }

        writeToOutputBuffer(msg);
    }
}

void ProtocolGame::sendTileRemoveWidget(const Tile* tile, const Position& pos)
{
    if (!canSee(pos)) {
        return;
    }

    if (tile) {
        NetworkMessage msg;
        msg.addByte(0x3c);
        msg.addPosition(pos);
        msg.addByte(0x01); // delete = true

        writeToOutputBuffer(msg);
    }
}

void ProtocolGame::GetTileDescription(const Tile* tile)
{
	Item* ground = tile->getGround();
	uint16_t groundSpeed = 100;
	bool isBlocking = false;
	if (ground) {
		if (tile->hasFlag(TILESTATE_FLOORCHANGE) || tile->hasFlag(TILESTATE_TELEPORT))
			isBlocking = true;
	}
	playermsg.add<uint16_t>(groundSpeed);
	playermsg.add<uint8_t>(isBlocking ? 1 : 0);

	int32_t count;
	if (ground) {
		AddItem(ground);
		count = 1;
	} else {
		count = 0;
	}

	if (tile && tile->hasFlag(TILESTATE_WIDGET)) {
		sendTileWidget(tile, tile->getPosition());
	}
	
	const TileItemVector* items = tile->getItemList();
	if (items) {
		for (auto it = items->getBeginTopItem(), end = items->getEndTopItem(); it != end; ++it) {
			AddItem(*it);
			if (++count == 10) {
				break;
			}
		}
	}

	const CreatureVector* creatures = tile->getCreatures();
	if (creatures) {
		bool playerAdded = false;
		if (count < 10) {
			for (auto it = creatures->rbegin(), end = creatures->rend(); it != end; ++it) {
				const Creature* creature = (*it);
				if (!creature || creature->isRemoved()) {
					continue;
				}
				
				if (!player->canSeeCreature(creature)) {
					continue;
				}

				if (creature->getID() == player->getID()) {
					playerAdded = true;
				}

				bool known;
				uint32_t removedKnown;
				checkCreatureAsKnown(creature->getID(), known, removedKnown);
				AddCreature(creature, known, removedKnown);
				if (++count == 10) {
					break;
				}
			}
		}
		if (!playerAdded && tile->getPosition() == player->getPosition()) {
			const Creature* creature = player;

			bool known;
			uint32_t removedKnown;
			checkCreatureAsKnown(creature->getID(), known, removedKnown);
			AddCreature(creature, known, removedKnown);
		}
	}

	if (items && count < 10) {
		for (auto it = ItemVector::const_reverse_iterator(items->getEndDownItem()), end = ItemVector::const_reverse_iterator(items->getBeginDownItem()); it != end; ++it) {
			AddItem(*it);
			if (++count == 10) {
				return;
			}
		}
	}
}

void ProtocolGame::GetMapDescription(int32_t x, int32_t y, int32_t z, int32_t width, int32_t height)
{
	int32_t skip = -1;
	int32_t startz, endz, zstep;
	if (z > 12) {
		startz = z - 2;
		endz = std::min<int32_t>(MAP_MAX_LAYERS - 1, z + 2);
		zstep = 1;
	} else {
		startz = 12;
		endz = 0;
		zstep = -1;
	}

	for (int32_t nz = startz; nz != endz + zstep; nz += zstep) {
		GetFloorDescription(x, y, nz, width, height, z - nz, skip);
	}

	if (skip >= 0) {
		playermsg.addByte(skip);
		playermsg.addByte(0xFF);
	}
}

void ProtocolGame::GetFloorDescription(int32_t x, int32_t y, int32_t z, int32_t width, int32_t height, int32_t offset, int32_t& skip)
{
	std::vector<Tile*> tileVector = g_game.map.getFloorTiles(x + offset, y + offset, width, height, z);
	for (Tile* tile : tileVector) {
		if (tile) {
			if (skip >= 0) {
				playermsg.addByte(skip);
				playermsg.addByte(0xFF);
			}

			skip = 0;
			GetTileDescription(tile);
		} else if (skip == 0xFE) {
			playermsg.addByte(0xFF);
			playermsg.addByte(0xFF);
			skip = -1;
		} else {
			++skip;
		}
	}
}

void ProtocolGame::checkCreatureAsKnown(uint32_t id, bool& known, uint32_t& removedKnown)
{
	auto result = knownCreatureSet.insert(id);
	if (!result.second) {
		known = false;
		removedKnown = id;
		return;
	}
	known = false;
	#if CLIENT_VERSION >= 870
	if (knownCreatureSet.size() > 1300) {
	#elif CLIENT_VERSION >= 840
	if (knownCreatureSet.size() > 250) {
	#elif CLIENT_VERSION >= 713
	if (knownCreatureSet.size() > 150) {
	#else
	if (knownCreatureSet.size() > 100) {
	#endif
		// Look for a creature to remove
		#if GAME_FEATURE_PARTY_LIST > 0
		for (auto it = knownCreatureSet.begin(), end = knownCreatureSet.end(); it != end; ++it) {
			// We need to protect party players from removing
			Creature* creature = g_game.getCreatureByID(*it);
			Player* checkPlayer;
			if (creature && (checkPlayer = creature->getPlayer()) != nullptr) {
				if (player->getParty() != checkPlayer->getParty() && !canSee(creature)) {
					removedKnown = *it;
					knownCreatureSet.erase(it);
					return;
				}
			} else if (!canSee(creature)) {
				removedKnown = *it;
				knownCreatureSet.erase(it);
				return;
			}
		}
		#else
		for (auto it = knownCreatureSet.begin(), end = knownCreatureSet.end(); it != end; ++it) {
			Creature* creature = g_game.getCreatureByID(*it);
			if (!canSee(creature)) {
				removedKnown = *it;
				knownCreatureSet.erase(it);
				return;
			}
		}
		#endif

		// Bad situation. Let's just remove anyone.
		auto it = knownCreatureSet.begin();
		if (*it == id) {
			++it;
		}

		removedKnown = *it;
		knownCreatureSet.erase(it);
	} else {
		removedKnown = 0;
	}
}

bool ProtocolGame::canSee(const Creature* c) const
{
	if (!c || !player || c->isRemoved()) {
		return false;
	}

	if (!player->canSeeCreature(c)) {
		return false;
	}

	return canSee(c->getPosition());
}

bool ProtocolGame::canSee(const Position& pos) const
{
	return canSee(pos.x, pos.y, pos.z);
}

bool ProtocolGame::canSee(int32_t x, int32_t y, int32_t z) const
{
	if (!player) {
		return false;
	}

	const Position& myPos = player->getPosition();
	if (myPos.z <= 12) {
		//we are on ground level or above (7 -> 0)
		//view is from 7 -> 0
		if (z > 12) {
			return false;
		}
	} else if (myPos.z >= 13) {
		//we are underground (8 -> 15)
		//view is +/- 2 from the floor we stand on
		if (std::abs(myPos.getZ() - z) > 2) {
			return false;
		}
	}

	//negative offset means that the action taken place is on a lower floor than ourself
	int32_t offsetz = myPos.getZ() - z;
	if ((x >= myPos.getX() - awareRange.left() + offsetz) && (x <= myPos.getX() + awareRange.right() + offsetz) &&
		(y >= myPos.getY() - awareRange.top() + offsetz) && (y <= myPos.getY() + awareRange.bottom() + offsetz)) {
		return true;
	}
	return false;
}

// Parse methods
void ProtocolGame::parseChannelInvite(NetworkMessage& msg)
{
	const std::string name = msg.getString();
	if (!name.empty() && name.length() <= NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		g_game.playerChannelInvite(player, name);
	}
}

void ProtocolGame::parseChannelExclude(NetworkMessage& msg)
{
	const std::string name = msg.getString();
	if (!name.empty() && name.length() <= NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		g_game.playerChannelExclude(player, name);
	}
}

void ProtocolGame::parseOpenChannel(NetworkMessage& msg)
{
	uint16_t channelId = msg.get<uint16_t>();
	g_game.playerOpenChannel(player, channelId);
}

void ProtocolGame::parseCloseChannel(NetworkMessage& msg)
{
	uint16_t channelId = msg.get<uint16_t>();
	g_game.playerCloseChannel(player, channelId);
}

void ProtocolGame::parseOpenPrivateChannel(NetworkMessage& msg)
{
	std::string receiver = msg.getString();
	if (!receiver.empty() && receiver.length() <= NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		g_game.playerOpenPrivateChannel(player, receiver);
	}
}

#if GAME_FEATURE_RULEVIOLATION > 0
void ProtocolGame::parseProcessRuleViolation(NetworkMessage& msg)
{
	std::string target = msg.getString();
	if (!target.empty() && target.length() <= NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		g_game.playerProcessRuleViolation(player, target);
	}
}

void ProtocolGame::parseCloseRuleViolation(NetworkMessage& msg)
{
	std::string target = msg.getString();
	if (!target.empty() && target.length() <= NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		g_game.playerCloseRuleViolation(player, target);
	}
}
#endif

#if GAME_FEATURE_QUEST_TRACKER > 0
void ProtocolGame::parseTrackedQuestFlags(NetworkMessage& msg)
{
	std::vector<uint16_t> quests;
	uint8_t missions = msg.getByte();
	quests.resize(missions);
	for (uint8_t i = 0; i < missions; ++i) {
		quests[i] = msg.get<uint16_t>();
	}
	g_game.playerResetTrackedQuests(player, quests);
}
#endif

void ProtocolGame::parseAutoWalk(NetworkMessage& msg)
{
	size_t numdirs = static_cast<size_t>(msg.getByte());
	if (numdirs == 0) {
		return;
	}

	std::vector<Direction> path;
	path.resize(numdirs, DIRECTION_NORTH);
	for (size_t i = numdirs; --i < numdirs;) {
		uint8_t rawdir = msg.getByte();
		switch (rawdir) {
			case 1: path[i] = DIRECTION_EAST; break;
			case 2: path[i] = DIRECTION_NORTHEAST; break;
			case 3: path[i] = DIRECTION_NORTH; break;
			case 4: path[i] = DIRECTION_NORTHWEST; break;
			case 5: path[i] = DIRECTION_WEST; break;
			case 6: path[i] = DIRECTION_SOUTHWEST; break;
			case 7: path[i] = DIRECTION_SOUTH; break;
			case 8: path[i] = DIRECTION_SOUTHEAST; break;
			default: break;
		}
	}
	g_game.playerAutoWalk(player->getID(), path);
}

void ProtocolGame::parseSetOutfit(NetworkMessage& msg)
{
	uint8_t outfitType = 0;
	#if CLIENT_VERSION >= 1220
	outfitType = msg.getByte();
	#endif

	Outfit_t newOutfit;
	#if GAME_FEATURE_LOOKTYPE_U16 > 0
	newOutfit.lookType = msg.get<uint16_t>();
	#else
	newOutfit.lookType = msg.getByte();
	#endif
	newOutfit.lookHead = std::min<uint8_t>(132, msg.getByte());
	newOutfit.lookBody = std::min<uint8_t>(132, msg.getByte());
	newOutfit.lookLegs = std::min<uint8_t>(132, msg.getByte());
	newOutfit.lookFeet = std::min<uint8_t>(132, msg.getByte());
	newOutfit.lookAddons = msg.getByte();
	if (outfitType == 0) {
		#if GAME_FEATURE_MOUNTS > 0
		newOutfit.lookMount = msg.get<uint16_t>();
		#endif
		newOutfit.lookWings = msg.get<uint16_t>();
		newOutfit.lookAura = msg.get<uint16_t>();
		newOutfit.lookShader = msg.getString();
		newOutfit.lookHealthBar = msg.get<uint16_t>();
		newOutfit.lookManaBar = msg.get<uint16_t>();
		newOutfit.lookOutline = msg.getString();
		#if GAME_FEATURE_MOUNT_COLORS > 0
		newOutfit.lookMountHead = std::min<uint8_t>(132, msg.getByte());
		newOutfit.lookMountBody = std::min<uint8_t>(132, msg.getByte());
		newOutfit.lookMountLegs = std::min<uint8_t>(132, msg.getByte());
		newOutfit.lookMountFeet = std::min<uint8_t>(132, msg.getByte());
		#endif
		#if GAME_FEATURE_FAMILIARS > 0
		msg.get<uint16_t>();//Familiar looktype
		#endif
	} else if (outfitType == 1) {
		//This value probably has something to do with try outfit variable inside outfit window dialog
		//if try outfit is set to 2 it expects uint32_t value after mounted and disable mounts from outfit window dialog
		msg.get<uint32_t>();
	}
	g_game.playerChangeOutfit(player, newOutfit);
}

#if GAME_FEATURE_MOUNTS > 0
void ProtocolGame::parseToggleMount(NetworkMessage& msg)
{
	//bool mount = msg.getByte() != 0;
	//g_game.playerToggleMount(player, mount);
	int mount = msg.get<int8_t>();

	g_game.playerToggleOutfitExtension(player, mount);
}
#endif

void ProtocolGame::parseUseItem(NetworkMessage& msg)
{
	Position pos = msg.getPosition();
	uint16_t spriteId = msg.get<uint16_t>();
	uint8_t stackpos = msg.getByte();
	uint8_t index = msg.getByte();
	g_game.playerUseItem(player->getID(), pos, stackpos, index, spriteId);
}

void ProtocolGame::parseUseItemEx(NetworkMessage& msg)
{
	Position fromPos = msg.getPosition();
	uint16_t fromSpriteId = msg.get<uint16_t>();
	uint8_t fromStackPos = msg.getByte();
	Position toPos = msg.getPosition();
	uint16_t toSpriteId = msg.get<uint16_t>();
	uint8_t toStackPos = msg.getByte();

	g_game.playerUseItemEx(player->getID(), fromPos, fromStackPos, fromSpriteId, toPos, toStackPos, toSpriteId);
}

void ProtocolGame::parseUseWithCreature(NetworkMessage& msg)
{
	Position fromPos = msg.getPosition();
	uint16_t spriteId = msg.get<uint16_t>();
	uint8_t fromStackPos = msg.getByte();
	uint32_t creatureId = msg.get<uint32_t>();
	g_game.playerUseWithCreature(player->getID(), fromPos, fromStackPos, creatureId, spriteId);
}

void ProtocolGame::parseCloseContainer(NetworkMessage& msg)
{
	uint8_t cid = msg.getByte();
	g_game.playerCloseContainer(player, cid);
}

void ProtocolGame::parseUpArrowContainer(NetworkMessage& msg)
{
	uint8_t cid = msg.getByte();
	g_game.playerMoveUpContainer(player, cid);
}

void ProtocolGame::parseUpdateContainer(NetworkMessage& msg)
{
	uint8_t cid = msg.getByte();
	g_game.playerUpdateContainer(player, cid);
}

void ProtocolGame::parseThrow(NetworkMessage& msg)
{
	Position fromPos = msg.getPosition();
	uint16_t spriteId = msg.get<uint16_t>();
	uint8_t fromStackpos = msg.getByte();
	Position toPos = msg.getPosition();
	uint16_t count = msg.get<uint16_t>();
	if (toPos != fromPos) {
		g_game.playerMoveThing(player->getID(), fromPos, spriteId, fromStackpos, toPos, count);
	}
}

#if CLIENT_VERSION >= 1092
void ProtocolGame::parseWrapableItem(NetworkMessage& msg)
{
	Position pos = msg.getPosition();
	uint16_t spriteId = msg.get<uint16_t>();
	uint8_t stackpos = msg.getByte();
	g_game.playerWrapableItem(player->getID(), pos, stackpos, spriteId);
}
#endif

void ProtocolGame::parseLookAt(NetworkMessage& msg)
{
	Position pos = msg.getPosition();
	msg.skipBytes(2); // spriteId
	uint8_t stackpos = msg.getByte();
	g_game.playerLookAt(player, pos, stackpos);
}

void ProtocolGame::parseLookInBattleList(NetworkMessage& msg)
{
	uint32_t creatureId = msg.get<uint32_t>();
	g_game.playerLookInBattleList(player, creatureId);
}

void ProtocolGame::parseSay(NetworkMessage& msg)
{
	std::string receiver;
	uint16_t channelId;

	SpeakClasses type = translateSpeakClassFromClient(msg.getByte());
	if (type == TALKTYPE_NONE) {
		return;
	}
	switch (type) {
		case TALKTYPE_PRIVATE_TO:
		case TALKTYPE_PRIVATE_RED_TO:
		#if GAME_FEATURE_RULEVIOLATION > 0
		case TALKTYPE_RVR_ANSWER:
		#endif
			receiver = msg.getString();
			channelId = 0;
			break;

		case TALKTYPE_CHANNEL_Y:
		case TALKTYPE_CHANNEL_O:
		case TALKTYPE_CHANNEL_R1:
			channelId = msg.get<uint16_t>();
			break;

		default:
			channelId = 0;
			break;
	}

	std::string text = msg.getString();
	if (text.empty() || text.length() > 255 || receiver.length() > NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		return;
	}

	g_game.playerSay(player, channelId, type, receiver, text);
}

void ProtocolGame::parseFightModes(NetworkMessage& msg)
{
	uint8_t rawFightMode = msg.getByte(); // 1 - offensive, 2 - balanced, 3 - defensive
	uint8_t rawChaseMode = msg.getByte(); // 0 - stand while fightning, 1 - chase opponent
	uint8_t rawSecureMode = msg.getByte(); // 0 - can't attack unmarked, 1 - can attack unmarked
	// uint8_t rawPvpMode = msg.getByte(); // pvp mode introduced in 10.0

	fightMode_t fightMode;
	if (rawFightMode == 1) {
		fightMode = FIGHTMODE_ATTACK;
	} else if (rawFightMode == 2) {
		fightMode = FIGHTMODE_BALANCED;
	} else {
		fightMode = FIGHTMODE_DEFENSE;
	}

	g_game.playerSetFightModes(player, fightMode, (rawChaseMode != 0), (rawSecureMode != 0));
}

void ProtocolGame::parseAttack(NetworkMessage& msg)
{
	uint32_t creatureId = msg.get<uint32_t>();
	g_game.playerSetAttackedCreature(player->getID(), creatureId);
}

void ProtocolGame::parseFollow(NetworkMessage& msg)
{
	uint32_t creatureId = msg.get<uint32_t>();
	g_game.playerFollowCreature(player->getID(), creatureId);
}

void ProtocolGame::parseEquipObject(NetworkMessage& msg)
{
	uint64_t uid = msg.get<uint64_t>();
	g_game.playerEquipItem(player, uid);
}

#if CLIENT_VERSION >= 1150
void ProtocolGame::parseTeleport(NetworkMessage& msg)
{
	Position position = msg.getPosition();
	g_game.playerTeleport(player, position);
}
#endif

void ProtocolGame::parseTextWindow(NetworkMessage& msg)
{
	uint32_t windowTextId = msg.get<uint32_t>();
	const std::string newText = msg.getString();
	g_game.playerWriteItem(player, windowTextId, newText);
}

void ProtocolGame::parseHouseWindow(NetworkMessage& msg)
{
	uint8_t doorId = msg.getByte();
	uint32_t id = msg.get<uint32_t>();
	const std::string text = msg.getString();
	g_game.playerUpdateHouseWindow(player, doorId, id, text);
}

void ProtocolGame::parseLookInShop(NetworkMessage& msg)
{
	uint16_t id = msg.get<uint16_t>();
	uint8_t count = msg.getByte();
	g_game.playerLookInShop(player, id, count);
}

void ProtocolGame::parsePlayerPurchase(NetworkMessage& msg)
{
	uint16_t id = msg.get<uint16_t>();
	uint8_t count = msg.getByte();
	uint8_t amount = msg.getByte();
	bool ignoreCap = (msg.getByte() != 0);
	bool inBackpacks = (msg.getByte() != 0);
	if (amount > 0 && amount <= 100) {
		g_game.playerPurchaseItem(player, id, count, amount, ignoreCap, inBackpacks);
	}
}

void ProtocolGame::parsePlayerSale(NetworkMessage& msg)
{
	player->setCanUpdateShop(false);
	uint8_t type = msg.getByte();
	std::string filterName = msg.getString();
	uint8_t filterRarity = msg.getByte();
	if (type == 0) {
		uint16_t id = msg.get<uint16_t>();
		uint8_t count = msg.getByte();
		uint8_t amount = msg.getByte();
		bool ignoreEquipped = (msg.getByte() != 0);
		uint64_t realUID = msg.get<uint64_t>();
		if (amount > 0 && amount <= 9999) {
			g_game.playerSellItem(player, id, count, amount, realUID, ignoreEquipped);
		}
	} else if (type == 1) {
		uint8_t items = msg.getByte();
		std::vector<uint64_t> ids;
		for (uint8_t i = 0; i < items; ++i) {
			ids.push_back(msg.get<uint64_t>());
		}

		g_game.playerSellItems(player, ids);
	}
	player->setCanUpdateShop(true);

	g_game.updatePlayerStore(player);
}

void ProtocolGame::parseGetItems(NetworkMessage& msg)
{
	std::string filterName = msg.getString();
	uint8_t filterRarity = msg.getByte();
	uint8_t filterItemType = msg.getByte();
	uint8_t categoryIndex = msg.getByte();
	g_game.updatePlayerStore(player, true, filterName, filterRarity, filterItemType, categoryIndex);
}

void ProtocolGame::parseAddVip(NetworkMessage& msg)
{
	const std::string name = msg.getString();
	if (!name.empty() && name.length() <= NETWORKMESSAGE_PLAYERNAME_MAXLENGTH) {
		g_game.playerRequestAddVip(player, name);
	}
}

void ProtocolGame::parseRemoveVip(NetworkMessage& msg)
{
	uint32_t guid = msg.get<uint32_t>();
	g_game.playerRequestRemoveVip(player, guid);
}

void ProtocolGame::parseEditVip(NetworkMessage& msg)
{
	uint32_t guid = msg.get<uint32_t>();
	const std::string description = msg.getString();
	uint32_t icon = std::min<uint32_t>(10, msg.get<uint32_t>()); // 10 is max icon in 9.63
	bool notify = (msg.getByte() != 0);
	g_game.playerRequestEditVip(player, guid, description, icon, notify);
}

void ProtocolGame::parseRotateItem(NetworkMessage& msg)
{
	Position pos = msg.getPosition();
	uint16_t spriteId = msg.get<uint16_t>();
	uint8_t stackpos = msg.getByte();
	g_game.playerRotateItem(player->getID(), pos, stackpos, spriteId);
}

void ProtocolGame::parseRuleViolationReport(NetworkMessage& msg)
{
	uint8_t reportType = msg.getByte();
	uint8_t reportReason = msg.getByte();
	const std::string targetName = msg.getString();
	const std::string comment = msg.getString();
	std::string translation;
	if (reportType == REPORT_TYPE_NAME) {
		translation = msg.getString();
	} else if (reportType == REPORT_TYPE_STATEMENT) {
		translation = msg.getString();
		msg.get<uint32_t>(); // statement id, used to get whatever player have said, we don't log that.
	}

	g_game.playerReportRuleViolation(player, targetName, reportType, reportReason, comment, translation);
}

void ProtocolGame::parseCyclopediaMonsters(NetworkMessage& msg)
{
	std::string race;
	if (version >= 1215) {
		uint8_t type = msg.getByte();
		if (type != 0) {
			return;
		}

		race = msg.getString();
	} else {
		race = msg.getString();
	}

	g_game.playerCyclopediaMonsters(player, race);
}

void ProtocolGame::parseCyclopediaRace(NetworkMessage& msg)
{
	uint16_t monsterId = msg.get<uint16_t>();
	g_game.playerCyclopediaRace(player, monsterId);
}

void ProtocolGame::parseCyclopediaHouseAction(NetworkMessage& msg)
{
	// Testing purposes - do not write code this way, it has race condition
	// but for testing purpose I don't need 100% thread-safety
	(void)msg;
	/*uint8_t houseActionType = msg.getByte();
	switch (houseActionType) {
		case 0: {
			std::string housePage = msg.getString();
			std::cout << "Test[0]:" << std::endl;
			std::cout << "String[1]: " << housePage << std::endl;
			if (housePage == "Rathleton") {
				NetworkMessage outMsg;
				outMsg.addByte(0xC7);
				outMsg.add<uint16_t>(0x01);
				outMsg.add<uint32_t>(0x4A4A);
				outMsg.addByte(1);
				outMsg.addByte(1);
				writeToOutputBuffer(outMsg);
			} else {
				NetworkMessage outMsg;
				outMsg.addByte(0xC7);
				outMsg.add<uint16_t>(0x01);
				outMsg.add<uint32_t>(0x4A4A);
				outMsg.addByte(1);
				outMsg.addByte(2);
				outMsg.addString("Test");
				outMsg.add<uint32_t>(0xFFFFFFFF);
				outMsg.addByte(1);
				outMsg.addByte(0);
				outMsg.addByte(0);
				writeToOutputBuffer(outMsg);
			}
			break;
		}
		case 1: {
			std::cout << "Test[1]:" << std::endl;
			std::cout << "U32[1]: " << msg.get<uint32_t>() << std::endl;
			std::cout << "U64[2]: " << msg.get<uint64_t>() << std::endl;
			break;
		}
		case 2: {
			std::cout << "Test[2]:" << std::endl;
			std::cout << "U32[1]: " << msg.get<uint32_t>() << std::endl;
			std::cout << "U32[2]: " << msg.get<uint32_t>() << std::endl;
			break;
		}
		case 3: {
			std::cout << "Test[3]:" << std::endl;
			std::cout << "U32[1]: " << msg.get<uint32_t>() << std::endl;
			std::cout << "U32[2]: " << msg.get<uint32_t>() << std::endl;
			std::cout << "String[3]: " << msg.getString() << std::endl;
			std::cout << "U64[4]: " << msg.get<uint64_t>() << std::endl;
			break;
		}
	}*/
}

#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
void ProtocolGame::parseCyclopediaCharacterInfo(NetworkMessage& msg)
{
	uint32_t characterID;

	CyclopediaCharacterInfoType_t characterInfoType;
	#if CLIENT_VERSION >= 1215
	characterID = msg.get<uint32_t>();
	characterInfoType = static_cast<CyclopediaCharacterInfoType_t>(msg.getByte());
	#else
	characterID = 0;
	characterInfoType = static_cast<CyclopediaCharacterInfoType_t>(msg.getByte());
	#endif
	uint16_t entriesPerPage = 0, page = 0;
	if (characterInfoType == CYCLOPEDIA_CHARACTERINFO_RECENTDEATHS || characterInfoType == CYCLOPEDIA_CHARACTERINFO_RECENTPVPKILLS) {
		entriesPerPage = std::min<uint16_t>(30, std::max<uint16_t>(5, msg.get<uint16_t>()));
		page = std::max<uint16_t>(1, msg.get<uint16_t>());
	}

	if (characterID == 0) {
		characterID = player->getGUID();
	}
	g_game.playerCyclopediaCharacterInfo(player, characterID, characterInfoType, entriesPerPage, page);
}
#endif

#if GAME_FEATURE_HIGHSCORES > 0
void ProtocolGame::parseHighscores(NetworkMessage& msg)
{
	uint8_t category = msg.getByte();
	uint16_t page = msg.get<uint16_t>();
	uint8_t entriesPerPage = msg.getByte();
	uint8_t type = msg.get<uint8_t>();
	uint8_t vocationSize = msg.get<uint8_t>();
	std::vector<uint16_t> vocations;
	vocations.resize(vocationSize);
	for (uint8_t i = 0; i < vocationSize; ++i) {
		vocations[i] = msg.get<uint16_t>();
	}

	g_game.playerHighscores(player, category, vocations, "VisionOT", page, entriesPerPage, type);
}
#endif

void ProtocolGame::parseTournamentLeaderboard(NetworkMessage& msg)
{
	uint8_t ledaerboardType = msg.getByte();
	if (ledaerboardType == 0) {
		const std::string worldName = msg.getString();
		uint16_t currentPage = msg.get<uint16_t>();
		(void)worldName;
		(void)currentPage;
	} else if (ledaerboardType == 1) {
		const std::string worldName = msg.getString();
		const std::string characterName = msg.getString();
		(void)worldName;
		(void)characterName;
	}
	uint8_t elementsPerPage = msg.getByte();
	(void)elementsPerPage;

	g_game.playerTournamentLeaderboard(player, ledaerboardType);
}

void ProtocolGame::parseBugReport(NetworkMessage& msg)
{
	#if CLIENT_VERSION >= 1071
	uint8_t category = msg.getByte();
	std::string message = msg.getString();

	Position position;
	if (category == BUG_CATEGORY_MAP) {
		position = msg.getPosition();
	}
	#else
	uint8_t category = BUG_CATEGORY_MAP;
	std::string message = msg.getString();
	Position position = player->getPosition();
	#endif

	g_game.playerReportBug(player, message, position, category);
}

#if GAME_FEATURE_RULEVIOLATION > 0
void ProtocolGame::parseRuleViolation(NetworkMessage& msg)
{
	#if CLIENT_VERSION >= 772
	std::string target = msg.getString();
	uint8_t reason = msg.getByte();
	uint8_t action = msg.getByte();
	std::string comment = msg.getString();
	uint32_t statementId = msg.get<uint32_t>();
	bool ipBanishment = msg.getByte();
	#else
	std::string target = msg.getString();
	uint8_t reason = msg.getByte();
	std::string comment = msg.getString();
	uint8_t action = msg.getByte();
	uint32_t statementId = 0;
	bool ipBanishment = msg.getByte();
	#endif

	g_game.playerRuleViolation(player, target, comment, reason, action, statementId, ipBanishment);
}
#endif

void ProtocolGame::parseDebugAssert(NetworkMessage& msg)
{
	if (debugAssertSent) {
		return;
	}

	debugAssertSent = true;

	std::string assertLine = msg.getString();
	std::string date = msg.getString();
	std::string description = msg.getString();
	std::string comment = msg.getString();
	g_game.playerDebugAssert(player, assertLine, date, description, comment);
}

void ProtocolGame::parseInviteToParty(NetworkMessage& msg)
{
	uint32_t targetId = msg.get<uint32_t>();
	g_game.playerInviteToParty(player, targetId);
}

void ProtocolGame::parseJoinParty(NetworkMessage& msg)
{
	uint32_t targetId = msg.get<uint32_t>();
	g_game.playerJoinParty(player, targetId);
}

void ProtocolGame::parseRevokePartyInvite(NetworkMessage& msg)
{
	uint32_t targetId = msg.get<uint32_t>();
	g_game.playerRevokePartyInvitation(player, targetId);
}

void ProtocolGame::parseKickPartyMember(NetworkMessage& msg)
{
	uint32_t targetId = msg.get<uint32_t>();
	g_game.playerKickPartyMember(player, targetId);
}

void ProtocolGame::parsePassPartyLeadership(NetworkMessage& msg)
{
	uint32_t targetId = msg.get<uint32_t>();
	g_game.playerPassPartyLeadership(player, targetId);
}

void ProtocolGame::parseEnableSharedPartyExperience(NetworkMessage& msg)
{
	bool sharedExpActive = (msg.getByte() == 1);
	g_game.playerEnableSharedPartyExperience(player, sharedExpActive);
}

void ProtocolGame::parseQuestLine(NetworkMessage& msg)
{
	uint16_t questId = msg.get<uint16_t>();
	g_game.playerShowQuestLine(player, questId);
}

#if CLIENT_VERSION >= 960
void ProtocolGame::parseModalWindowAnswer(NetworkMessage& msg)
{
	uint32_t id = msg.get<uint32_t>();
	uint8_t button = msg.getByte();
	uint8_t choice = msg.getByte();
	g_game.playerAnswerModalWindow(player, id, button, choice);
}
#endif

#if GAME_FEATURE_BROWSEFIELD > 0
void ProtocolGame::parseBrowseField(NetworkMessage& msg)
{
	const Position& pos = msg.getPosition();
	g_game.playerBrowseField(player->getID(), pos);
}
#endif

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void ProtocolGame::parseSeekInContainer(NetworkMessage& msg)
{
	uint8_t containerId = msg.getByte();
	uint16_t index = msg.get<uint16_t>();
	g_game.playerSeekInContainer(player, containerId, index);
}
#endif

void ProtocolGame::parseSortContainer(NetworkMessage& msg)
{
	uint8_t containerId = msg.getByte();
	uint8_t sortIndex = msg.getByte();
	std::string name = msg.getString();

	g_game.playerSortContainer(player, containerId, sortIndex, name);
}

// Send methods
#if GAME_FEATURE_INSPECTION > 0
void ProtocolGame::sendItemInspection(uint16_t itemId, uint8_t itemCount, const Item* item, bool cyclopedia)
{
	playermsg.reset();
	playermsg.addByte(0x76);
	playermsg.addByte(0x00);//item
	#if CLIENT_VERSION >= 1220
	playermsg.addByte(cyclopedia ? 0x01 : 0x00);
	#else
	(void)cyclopedia;
	#endif
	playermsg.addByte(0x01);

	const ItemType& it = Item::items.getItemIdByClientId(itemId);

	if (item) {
		playermsg.addString(item->getName());
		AddItem(item);
	} else {
		playermsg.addString(it.name);
		AddItem(it.id, itemCount);
	}
	playermsg.addByte(0); // imbuements

	auto descriptions = Item::getDescriptions(it, item);
	playermsg.addByte(descriptions.size());
	for (const auto& description : descriptions) {
		playermsg.addString(description.first);
		playermsg.addString(description.second);
	}
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendOpenPrivateChannel(const std::string& receiver)
{
	playermsg.reset();
	playermsg.addByte(0xAD);
	playermsg.addString(receiver);
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_CHAT_PLAYERLIST > 0
void ProtocolGame::sendChannelEvent(uint16_t channelId, const std::string& playerName, ChannelEvent_t channelEvent)
{
	playermsg.reset();
	playermsg.addByte(0xF3);
	playermsg.add<uint16_t>(channelId);
	playermsg.addString(playerName);
	playermsg.addByte(channelEvent);
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendCreatureOutfit(const Creature* creature, const Outfit_t& outfit)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x8E);
	playermsg.add<uint32_t>(creature->getID());
	AddOutfit(outfit);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureLight(const Creature* creature)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	AddCreatureLight(creature);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendWorldLight(LightInfo lightInfo)
{
	playermsg.reset();
	AddWorldLight(lightInfo);
	writeToOutputBuffer(playermsg);
}

#if CLIENT_VERSION >= 1121
void ProtocolGame::sendTibiaTime(int32_t time)
{
	playermsg.reset();
	playermsg.addByte(0xEF);
	playermsg.addByte(time / 60);
	playermsg.addByte(time % 60);
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::updateCreatureData(const Creature* creature)
{
	uint32_t cid = creature->getID();
	if (knownCreatureSet.find(cid) == knownCreatureSet.end()) {
		return;
	}

	OperatingSystem_t regularOS = player->getOperatingSystem();
	OperatingSystem_t tfcOS = player->getTfcOperatingSystem();
	if ((regularOS >= CLIENTOS_NEW_LINUX && regularOS < CLIENTOS_OTCLIENT_LINUX) || tfcOS >= CLIENTOS_TFC_ANDROID) {
		//Using some hack so that I'm don't need to modify AddCreature function
		playermsg.reset();
		playermsg.setBufferPosition(NetworkMessage::INITIAL_BUFFER_POSITION - 1);
		AddCreature(creature, false, cid);
		playermsg.setBufferPosition(NetworkMessage::INITIAL_BUFFER_POSITION);
		playermsg.addByte(0x03);
		playermsg.setLength(playermsg.getLength() - 2);
		writeToOutputBuffer(playermsg);
	} else {
		if (canSee(creature)) {
			int32_t stackpos = creature->getTile()->getStackposOfCreature(player, creature);
			if (stackpos != -1) {
				playermsg.reset();
				playermsg.addByte(0x6B);
				playermsg.addPosition(creature->getPosition());
				playermsg.addByte(stackpos);
				AddCreature(creature, false, cid);
				writeToOutputBuffer(playermsg);
				return;
			}
		}

		//Not the best choice we have here but let's update our creature
		const Position& pos = player->getPosition();
		playermsg.reset();
		playermsg.addByte(0x6A);
		playermsg.addPosition(pos);
		#if GAME_FEATURE_TILE_ADDTHING_STACKPOS > 0
		playermsg.addByte(0xFF);
		#endif
		AddCreature(creature, false, cid);
		playermsg.addByte(0x69);
		playermsg.addPosition(pos);
		Tile* tile = player->getTile();
		if (tile) {
			GetTileDescription(tile);
			playermsg.addByte(0x00);
			playermsg.addByte(0xFF);
		} else {
			playermsg.addByte(0x01);
			playermsg.addByte(0xFF);
		}
		writeToOutputBuffer(playermsg);
	}
}

#if CLIENT_VERSION >= 854
void ProtocolGame::sendCreatureWalkthrough(const Creature* creature, bool walkthrough)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x92);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(walkthrough ? 0x00 : 0x01);
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendCreatureAttackable(const Creature* creature, bool attackable)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xC9);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(attackable ? 0x01 : 0x00);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureShield(const Creature* creature)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x91);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(player->getPartyShield(creature->getPlayer()));
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureSkull(const Creature* creature)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x90);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(player->getSkullClient(creature));
	writeToOutputBuffer(playermsg);
}

#if CLIENT_VERSION >= 910
void ProtocolGame::sendCreatureType(const Creature* creature, uint8_t creatureType)
{
	playermsg.reset();
	playermsg.addByte(0x95);
	playermsg.add<uint32_t>(creature->getID());
	#if CLIENT_VERSION >= 1121
	if (creatureType == CREATURETYPE_SUMMON_OTHERS) {
		creatureType = CREATURETYPE_SUMMON_OWN;
	}
	playermsg.addByte(creatureType);
	if (creatureType == CREATURETYPE_SUMMON_OWN) {
		const Creature* master = creature->getMaster();
		if (master) {
			playermsg.add<uint32_t>(master->getID());
		} else {
			playermsg.add<uint32_t>(0);
		}
	}
	#else
	playermsg.addByte(creatureType);
	#endif
	writeToOutputBuffer(playermsg);
}
#endif

#if CLIENT_VERSION >= 1000 && CLIENT_VERSION < 1185
void ProtocolGame::sendCreatureHelpers(uint32_t creatureId, uint16_t helpers)
{
	playermsg.reset();
	playermsg.addByte(0x94);
	playermsg.add<uint32_t>(creatureId);
	playermsg.add<uint16_t>(helpers);
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendCreatureSquare(const Creature* creature, SquareColor_t color)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	#if GAME_FEATURE_CREATURE_MARK > 0
	playermsg.addByte(0x93);
	#if CLIENT_VERSION < 1035
	playermsg.addByte(0x01);
	#endif
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(0x01);
	playermsg.addByte(color);
	#else
	playermsg.addByte(0x86);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(color);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendTutorial(uint8_t tutorialId)
{
	playermsg.reset();
	playermsg.addByte(0xDC);
	playermsg.addByte(tutorialId);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendAddMarker(const Position& pos, uint8_t markType, const std::string& desc)
{
	playermsg.reset();
	playermsg.addByte(0xDD);
	#if CLIENT_VERSION >= 1200
	playermsg.addByte(0x00);
	#endif
	playermsg.addPosition(pos);
	playermsg.addByte(markType);
	playermsg.addString(desc);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendMonsterCyclopedia()
{
	playermsg.reset();
	playermsg.addByte(0xD5);

	auto races = g_monsters.getRaces();
	auto monsterRaces = g_monsters.getMonsterRaces();

	playermsg.add<uint16_t>(races.size());
	for (const auto& race : races) {
		playermsg.addString(race.first);

		auto it = monsterRaces.find(race.second);
		if (it != monsterRaces.end()) {
			playermsg.add<uint16_t>(it->second.size());
			playermsg.add<uint16_t>(it->second.size());
		} else {
			playermsg.add<uint16_t>(0);
			playermsg.add<uint16_t>(0);
		}
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaMonsters(const std::string& race)
{
	playermsg.reset();
	playermsg.addByte(0xD6);

	auto races = g_monsters.getRaces();
	auto monsterRaces = g_monsters.getMonsterRaces();
	playermsg.addString(race);

	auto it = races.find(race);
	if (it != races.end()) {
		auto it2 = monsterRaces.find(it->second);
		if (it2 != monsterRaces.end()) {
			playermsg.add<uint16_t>(it2->second.size());
			for (const auto& monster : it2->second) {
				uint8_t monsterProgress = BESTIARY_PROGRESS_COMPLETED;

				playermsg.add<uint16_t>(monster.first);
				playermsg.addByte(monsterProgress);
				if (monsterProgress != BESTIARY_PROGRESS_NONE) {
					playermsg.addByte(BESTIARY_OCCURENCE_COMMON);
				}
			}
		} else {
			playermsg.add<uint16_t>(0);
		}
	} else {
		playermsg.add<uint16_t>(0);
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaRace(uint16_t monsterId)
{
	playermsg.reset();
	playermsg.addByte(0xD7);

	auto monsterRaces = g_monsters.getMonsterRaces();
	for (const auto& race : monsterRaces) {
		auto it = race.second.find(monsterId);
		if (it != race.second.end()) {
			MonsterType* monsterType = g_monsters.getMonsterType(it->second);
			if (monsterType) {
				uint8_t monsterProgress = BESTIARY_PROGRESS_COMPLETED;

				playermsg.add<uint16_t>(monsterId);
				playermsg.addString(g_monsters.getRaceName(race.first));
				playermsg.addByte(monsterProgress);
				playermsg.add<uint32_t>(0); // total kills
				playermsg.add<uint16_t>(0); // kills to progress 1
				playermsg.add<uint16_t>(0); // kills to progress 2
				playermsg.add<uint16_t>(0); // kills to progress 3
				if (monsterProgress >= BESTIARY_PROGRESS_FIRST) {
					playermsg.addByte(BESTIARY_DIFFICULTY_HARMLESS);
					playermsg.addByte(BESTIARY_OCCURENCE_COMMON);

					std::vector<const std::vector<LootBlock>*> lootBlocks{ &monsterType->info.lootItems };
					uint8_t lootSize = 0;
					auto startLoot = playermsg.getBufferPosition();
					playermsg.addByte(lootSize);
					for (std::vector<const std::vector<LootBlock>*>::iterator lit = lootBlocks.begin(); lit != lootBlocks.end(); lit++) {
						const std::vector<LootBlock>* lootVector = (*lit);
						for (const auto& lootBlock : *lootVector) {
							if (!lootBlock.childLoot.empty()) {
								lootBlocks.push_back(&lootBlock.childLoot);
							} else {
								uint16_t itemId = lootBlock.id;

								const ItemType& item = Item::items[itemId];
								playermsg.add<uint16_t>(item.clientId);
								if (lootBlock.chance >= 25000) {
									playermsg.addByte(BESTIARY_RARITY_COMMON);
								} else if (lootBlock.chance >= 5000) {
									playermsg.addByte(BESTIARY_RARITY_UNCOMMON);
								} else if (lootBlock.chance >= 1000) {
									playermsg.addByte(BESTIARY_RARITY_SEMIRARE);
								} else if (lootBlock.chance >= 500) {
									playermsg.addByte(BESTIARY_RARITY_RARE);
								} else {
									playermsg.addByte(BESTIARY_RARITY_VERYRARE);
								}
								playermsg.addByte(0x00); // special event item
								if (itemId != 0) { // 0 indicate hidden item
									playermsg.addString(item.name);
									playermsg.addByte((lootBlock.countmax > 1) ? 0x01 : 0x00);
								}

								if (++lootSize == 0xFF) {
									goto EndLoot;
								}
							}
						}
					}

					EndLoot:
					auto returnTo = playermsg.getBufferPosition();
					playermsg.setBufferPosition(startLoot);
					playermsg.addByte(lootSize);
					playermsg.setLength(playermsg.getLength() - 1); // decrease one extra bytes we made
					playermsg.setBufferPosition(returnTo);
				}
				if (monsterProgress >= BESTIARY_PROGRESS_SECOND) {
					playermsg.add<uint16_t>(0); // charm points
					if (!monsterType->info.isHostile) {
						playermsg.addByte(BESTIARY_ATTACKTYPE_NONE);
					} else if (monsterType->info.targetDistance > 1) {
						playermsg.addByte(BESTIARY_ATTACKTYPE_DISTANCE);
					} else {
						playermsg.addByte(BESTIARY_ATTACKTYPE_MELEE);
					}
					if (!monsterType->info.attackSpells.empty() || !monsterType->info.defenseSpells.empty()) {
						playermsg.addByte(0x01); // casts spells
					} else {
						playermsg.addByte(0x00); // casts spells
					}
					playermsg.add<uint32_t>(static_cast<uint32_t>(monsterType->info.healthMax));
					playermsg.add<uint32_t>(static_cast<uint32_t>(monsterType->info.experience));
					playermsg.add<uint16_t>(static_cast<uint16_t>(monsterType->info.baseSpeed / 2));
					playermsg.add<uint16_t>(static_cast<uint16_t>(monsterType->info.armor));
				}
				if (monsterProgress >= BESTIARY_PROGRESS_THIRD) {
					playermsg.addByte(8); // combats

					static const CombatType_t combats[] = {COMBAT_PHYSICALDAMAGE, COMBAT_FIREDAMAGE, COMBAT_EARTHDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_ICEDAMAGE, COMBAT_HOLYDAMAGE, COMBAT_DEATHDAMAGE, COMBAT_HEALING};
					for (std::underlying_type<Cipbia_Elementals_t>::type i = CIPBIA_ELEMENTAL_PHYSICAL; i <= CIPBIA_ELEMENTAL_HEALING; i++) {
						playermsg.addByte(i);

						auto combat = combats[i];
						if (monsterType->info.damageImmunities & combat) {
							playermsg.add<int16_t>(0);
						} else {
							auto combatDmg = monsterType->info.elementMap.find(combats[i]);
							if (combatDmg != monsterType->info.elementMap.end()) {
								playermsg.add<int16_t>(100-combatDmg->second);
							} else {
								playermsg.add<int16_t>(100);
							}
						}
					}

					playermsg.add<uint16_t>(1); // locations
					playermsg.addString(""); // location - TODO
				}
				if (monsterProgress >= BESTIARY_PROGRESS_COMPLETED) {
					bool monsterHaveActiveCharm = false;
					playermsg.addByte((monsterHaveActiveCharm ? 0x01 : 0x00));
					if (monsterHaveActiveCharm) {
						playermsg.addByte(0); // charmId
						playermsg.add<uint32_t>(0); // charmRemoveCost
					} else {
						playermsg.addByte(0); // canSetCharm - bool
					}
				}
				writeToOutputBuffer(playermsg);
				return;
			}
		}
	}

	playermsg.add<uint16_t>(monsterId);
	playermsg.addString("Extra Dimensional");
	playermsg.addByte(BESTIARY_PROGRESS_NONE);
	playermsg.add<uint32_t>(0); // total kills
	playermsg.add<uint16_t>(0); // kills to progress 1
	playermsg.add<uint16_t>(0); // kills to progress 2
	playermsg.add<uint16_t>(0); // kills to progress 3
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaBonusEffects()
{
	playermsg.reset();
	playermsg.addByte(0xD8);
	playermsg.add<int32_t>(0); // charm points
	playermsg.addByte(0); // charms
	//playermsg.addByte(10); // charmid
	//playermsg.addString("Cripple"); // charmname
	//playermsg.addString("something"); // charmdescription
	//playermsg.addByte(0); // ??
	//playermsg.add<uint16_t>(500); // charm price
	//playermsg.addByte(0); // unlocked
	//playermsg.addByte(1); // activated
	// if activated
	//playermsg.add<uint16_t>(78); // monster id
	//playermsg.add<uint32_t>(1000); // clear price

	playermsg.addByte(0); // remaining assignable charms
	playermsg.add<uint16_t>(0); // assignable monsters
	//playermsg.add<uint16_t>(78); // monster id
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_CYCLOPEDIA_CHARACTERINFO > 0
void ProtocolGame::sendCyclopediaCharacterNoData(CyclopediaCharacterInfoType_t characterInfoType, uint8_t errorCode)
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(static_cast<uint8_t>(characterInfoType));
	playermsg.addByte(errorCode);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterBaseInformation()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_BASEINFORMATION);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.addString(player->getName());
	playermsg.addString(player->getVocation()->getVocName());
	playermsg.add<uint16_t>(player->getLevel());
	AddOutfit(player->getDefaultOutfit());

	playermsg.addByte(0x00); // hide stamina
	playermsg.addByte(0x00); // enable store summary & character titles
	playermsg.addString(""); // character title
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterGeneralStats()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_GENERALSTATS);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.add<uint64_t>(player->getExperience());
	playermsg.add<uint16_t>(player->getLevel());
	playermsg.addByte(player->getLevelPercent());
	playermsg.add<uint16_t>(100); // base xp gain rate
	#if CLIENT_VERSION >= 1215
	playermsg.add<int32_t>(0); // tournament xp factor
	#endif
	playermsg.add<uint16_t>(0); // low level bonus
	playermsg.add<uint16_t>(0); // xp boost
	playermsg.add<uint16_t>(100); // stamina multiplier (100 = x1.0)
	playermsg.add<uint16_t>(0); // xpBoostRemainingTime
	playermsg.addByte(0x00); // canBuyXpBoost
	//playermsg.add<uint16_t>(std::min<int32_t>(player->getHealth(), std::numeric_limits<uint16_t>::max()));
	//playermsg.add<uint16_t>(std::min<int32_t>(player->getMaxHealth(), std::numeric_limits<uint16_t>::max()));
	msg.add<uint32_t>(player->getHealth());
    msg.add<uint32_t>(player->getMaxHealth());
	//playermsg.add<uint16_t>(std::min<int32_t>(player->getMana(), std::numeric_limits<uint16_t>::max()));
	//playermsg.add<uint16_t>(std::min<int32_t>(player->getMaxMana(), std::numeric_limits<uint16_t>::max()));
	msg.add<uint32_t>(player->getMana());
    msg.add<uint32_t>(player->getMaxMana());
	playermsg.addByte(player->getSoul());
	playermsg.add<uint16_t>(player->getStaminaMinutes());

	Condition* condition = player->getCondition(CONDITION_REGENERATION);
	playermsg.add<uint16_t>(condition ? condition->getTicks() / 1000 : 0x00);
	playermsg.add<uint16_t>(player->getOfflineTrainingTime() / 60 / 1000);
	playermsg.add<uint16_t>(player->getSpeed() / 2);
	playermsg.add<uint16_t>(player->getBaseSpeed() / 2);
	playermsg.add<uint32_t>(player->getCapacity());
	playermsg.add<uint32_t>(player->getCapacity());
	playermsg.add<uint32_t>(player->getFreeCapacity());
	playermsg.addByte(8); // Skills count
	playermsg.addByte(1); // Magic Level hardcoded skill id
	playermsg.add<uint16_t>(player->getMagicLevel());
	playermsg.add<uint16_t>(player->getBaseMagicLevel());
	#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
	playermsg.add<uint16_t>(player->getBaseMagicLevel());//loyalty bonus
	playermsg.add<uint16_t>(player->getMagicLevelPercent() * 100);
	#else
	playermsg.addByte(player->getMagicLevelPercent());
	#endif
	for (uint8_t i = SKILL_FIRST; i <= SKILL_LAST; ++i) { //TODO: check if all clients have the same hardcoded skill ids
		static const uint8_t HardcodedSkillIds[] = {11, 9, 8, 10, 7, 6, 13};
		playermsg.addByte(HardcodedSkillIds[i]);
		playermsg.add<uint16_t>(std::min<int32_t>(player->getSkillLevel(i), std::numeric_limits<uint16_t>::max()));
		playermsg.add<uint16_t>(player->getBaseSkill(i));
		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		playermsg.add<uint16_t>(player->getBaseSkill(i));//loyalty bonus
		playermsg.add<uint16_t>(player->getSkillPercent(i) * 100);
		#else
		playermsg.addByte(player->getSkillPercent(i));
		#endif
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterCombatStats()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_COMBATSTATS);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	for (uint8_t i = SPECIALSKILL_FIRST; i <= SPECIALSKILL_LAST; ++i) {
		playermsg.add<uint16_t>(std::min<int32_t>(100, player->varSpecialSkills[i]));
		playermsg.add<uint16_t>(0);
	}

	uint8_t haveBlesses = 0;
	#if CLIENT_VERSION >= 1130
	uint8_t blessings = 8;
	#else
	uint8_t blessings = 6;
	#endif
	for (uint8_t i = 1; i < blessings; ++i) {
		if (player->hasBlessing(i)) {
			++haveBlesses;
		}
	}
	playermsg.addByte(haveBlesses);
	playermsg.addByte(blessings);

	const Item* weapon = player->getWeapon();
	if (weapon) {
		const ItemType& it = Item::items[weapon->getID()];
		if (it.weaponType == WEAPON_WAND) {
			playermsg.add<uint16_t>(it.maxHitChance);
			playermsg.addByte(getCipbiaElement(it.combatType));
			playermsg.addByte(0);
			playermsg.addByte(CIPBIA_ELEMENTAL_UNDEFINED);
		} else if (it.weaponType == WEAPON_DISTANCE || it.weaponType == WEAPON_AMMO) {
			int32_t attackValue = weapon->getAttack();
			if (it.weaponType == WEAPON_AMMO) {
				const Item* weaponItem = player->getWeapon(true);
				if (weaponItem) {
					attackValue += weaponItem->getAttack();
				}
			}

			int32_t attackSkill = player->getSkillLevel(SKILL_DISTANCE);
			float attackFactor = player->getAttackFactor();
			int32_t maxDamage = static_cast<int32_t>(Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue, attackFactor) * player->getVocation()->distDamageMultiplier);
			if (it.abilities && it.abilities->elementType != COMBAT_NONE) {
				maxDamage += static_cast<int32_t>(Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue - weapon->getAttack() + it.abilities->elementDamage, attackFactor) * player->getVocation()->distDamageMultiplier);
			}
			playermsg.add<uint16_t>(maxDamage >> 1);
			playermsg.addByte(CIPBIA_ELEMENTAL_PHYSICAL);
			if (it.abilities && it.abilities->elementType != COMBAT_NONE) {
				playermsg.addByte(static_cast<uint32_t>(it.abilities->elementDamage) * 100 / attackValue);
				playermsg.addByte(getCipbiaElement(it.abilities->elementType));
			} else {
				playermsg.addByte(0);
				playermsg.addByte(CIPBIA_ELEMENTAL_UNDEFINED);
			}
		} else {
			int32_t attackValue = std::max<int32_t>(0, weapon->getAttack());
			int32_t attackSkill = player->getWeaponSkill(weapon);
			float attackFactor = player->getAttackFactor();
			int32_t maxDamage = static_cast<int32_t>(Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue, attackFactor) * player->getVocation()->meleeDamageMultiplier);
			if (it.abilities && it.abilities->elementType != COMBAT_NONE) {
				maxDamage += static_cast<int32_t>(Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, it.abilities->elementDamage, attackFactor) * player->getVocation()->meleeDamageMultiplier);
			}
			playermsg.add<uint16_t>(maxDamage >> 1);
			playermsg.addByte(CIPBIA_ELEMENTAL_PHYSICAL);
			if (it.abilities && it.abilities->elementType != COMBAT_NONE) {
				playermsg.addByte(static_cast<uint32_t>(it.abilities->elementDamage) * 100 / attackValue);
				playermsg.addByte(getCipbiaElement(it.abilities->elementType));
			} else {
				playermsg.addByte(0);
				playermsg.addByte(CIPBIA_ELEMENTAL_UNDEFINED);
			}
		}
	} else {
		float attackFactor = player->getAttackFactor();
		int32_t attackSkill = player->getSkillLevel(SKILL_FIST);
		int32_t attackValue = 7;

		int32_t maxDamage = Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue, attackFactor);
		playermsg.add<uint16_t>(maxDamage >> 1);
		playermsg.addByte(CIPBIA_ELEMENTAL_PHYSICAL);
		playermsg.addByte(0);
		playermsg.addByte(CIPBIA_ELEMENTAL_UNDEFINED);
	}
	playermsg.add<uint16_t>(player->getArmor());
	playermsg.add<uint16_t>(player->getDefense());

	uint8_t combats = 0;
	auto startCombats = playermsg.getBufferPosition();
	playermsg.skipBytes(1);

	alignas(16) int16_t absorbs[COMBAT_COUNT] = {};
	for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; ++slot) {
		if (!player->isItemAbilityEnabled(static_cast<slots_t>(slot))) {
			continue;
		}

		Item* item = player->getInventoryItem(static_cast<slots_t>(slot));
		if (!item) {
			continue;
		}

		const ItemType& it = Item::items[item->getID()];
		if (!it.abilities) {
			continue;
		}

		if (COMBAT_COUNT == 12) {
			#if defined(__SSE2__)
			_mm_store_si128(reinterpret_cast<__m128i*>(&absorbs[0]), _mm_add_epi16(_mm_load_si128(reinterpret_cast<const __m128i*>(&absorbs[0])), _mm_loadu_si128(reinterpret_cast<const __m128i*>(&it.abilities->absorbPercent[0]))));
			absorbs[8] += it.abilities->absorbPercent[8]; absorbs[9] += it.abilities->absorbPercent[9];
			absorbs[10] += it.abilities->absorbPercent[10]; absorbs[11] += it.abilities->absorbPercent[11];
			#else
			absorbs[0] += it.abilities->absorbPercent[0]; absorbs[1] += it.abilities->absorbPercent[1];
			absorbs[2] += it.abilities->absorbPercent[2]; absorbs[3] += it.abilities->absorbPercent[3];
			absorbs[4] += it.abilities->absorbPercent[4]; absorbs[5] += it.abilities->absorbPercent[5];
			absorbs[6] += it.abilities->absorbPercent[6]; absorbs[7] += it.abilities->absorbPercent[7];
			absorbs[8] += it.abilities->absorbPercent[8]; absorbs[9] += it.abilities->absorbPercent[9];
			absorbs[10] += it.abilities->absorbPercent[10]; absorbs[11] += it.abilities->absorbPercent[11];
			#endif
		} else {
			for (size_t i = 0; i < COMBAT_COUNT; ++i) {
				absorbs[i] += it.abilities->absorbPercent[i];
			}
		}
	}

	static const Cipbia_Elementals_t cipbiaCombats[] = {CIPBIA_ELEMENTAL_PHYSICAL, CIPBIA_ELEMENTAL_ENERGY, CIPBIA_ELEMENTAL_EARTH, CIPBIA_ELEMENTAL_FIRE, CIPBIA_ELEMENTAL_UNDEFINED,
		CIPBIA_ELEMENTAL_LIFEDRAIN, CIPBIA_ELEMENTAL_UNDEFINED, CIPBIA_ELEMENTAL_HEALING, CIPBIA_ELEMENTAL_DROWN, CIPBIA_ELEMENTAL_ICE, CIPBIA_ELEMENTAL_HOLY, CIPBIA_ELEMENTAL_DEATH};
	for (size_t i = 0; i < COMBAT_COUNT; ++i) {
		if (absorbs[i] != 0) {
			playermsg.addByte(cipbiaCombats[i]);
			playermsg.addByte(std::max<int16_t>(-100, std::min<int16_t>(100, absorbs[i])));
			++combats;
		}
	}

	playermsg.setBufferPosition(startCombats);
	playermsg.addByte(combats);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterRecentDeaths(uint16_t page, uint16_t pages, const std::vector<RecentDeathEntry>& entries)
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_RECENTDEATHS);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.add<uint16_t>(page);
	playermsg.add<uint16_t>(pages);

	playermsg.add<uint16_t>(entries.size());
	for (const RecentDeathEntry& entry : entries) {
		playermsg.add<uint32_t>(entry.timestamp);
		playermsg.addString(entry.cause);
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterRecentPvPKills(uint16_t page, uint16_t pages, const std::vector<RecentPvPKillEntry>& entries)
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_RECENTPVPKILLS);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.add<uint16_t>(page);
	playermsg.add<uint16_t>(pages);

	playermsg.add<uint16_t>(entries.size());
	for (const RecentPvPKillEntry& entry : entries) {
		playermsg.add<uint32_t>(entry.timestamp);
		playermsg.addString(entry.description);
		playermsg.addByte(entry.status);
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterAchievements()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_ACHIEVEMENTS);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.add<uint16_t>(0); // total points
	playermsg.add<uint16_t>(0); // total secret achievements
	playermsg.add<uint16_t>(0); // achievements
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterItemSummary()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_ITEMSUMMARY);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.add<uint16_t>(0); // ??
	playermsg.add<uint16_t>(0); // ??
	playermsg.add<uint16_t>(0); // ??
	playermsg.add<uint16_t>(0); // ??
	playermsg.add<uint16_t>(0); // ??
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterOutfitsMounts()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_OUTFITSMOUNTS);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	Outfit_t currentOutfit = player->getDefaultOutfit();

	uint16_t outfitSize = 0;
	auto startOutfits = playermsg.getBufferPosition();
	playermsg.skipBytes(2);

	const auto& outfits = Outfits::getInstance().getOutfits(player->getSex());
	for (const Outfit& outfit : outfits) {
		uint8_t addons;
		if (!player->getOutfitAddons(outfit, addons)) {
			continue;
		}
		++outfitSize;

		playermsg.add<uint16_t>(outfit.lookType);
		playermsg.addString(outfit.name);
		playermsg.addByte(addons);
		playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_OUTFITTYPE_NONE);
		if (outfit.lookType == currentOutfit.lookType) {
			playermsg.add<uint32_t>(1000);
		} else {
			playermsg.add<uint32_t>(0);
		}
	}
	if (outfitSize > 0) {
		playermsg.addByte(currentOutfit.lookHead);
		playermsg.addByte(currentOutfit.lookBody);
		playermsg.addByte(currentOutfit.lookLegs);
		playermsg.addByte(currentOutfit.lookFeet);
	}

	uint16_t mountSize = 0;
	auto startMounts = playermsg.getBufferPosition();
	playermsg.skipBytes(2);
	for (const Mount& mount : g_game.mounts.getMounts()) {
		#if GAME_FEATURE_MOUNTS > 0
		if (player->hasMount(&mount)) {
		#else
		if (true) {
		#endif
			++mountSize;

			playermsg.add<uint16_t>(mount.clientId);
			playermsg.addString(mount.name);
			playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_OUTFITTYPE_NONE);
			playermsg.add<uint32_t>(1000);
		}
	}
	#if GAME_FEATURE_MOUNT_COLORS > 0
	if (mountSize > 0) {
		playermsg.addByte(currentOutfit.lookMountHead);
		playermsg.addByte(currentOutfit.lookMountBody);
		playermsg.addByte(currentOutfit.lookMountLegs);
		playermsg.addByte(currentOutfit.lookMountFeet);
	}
	#endif

	#if GAME_FEATURE_FAMILIARS > 0
	playermsg.add<uint16_t>(0);
	#endif

	playermsg.setBufferPosition(startOutfits);
	playermsg.add<uint16_t>(outfitSize);
	playermsg.setBufferPosition(startMounts);
	playermsg.add<uint16_t>(mountSize);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterStoreSummary()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_STORESUMMARY);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.add<uint32_t>(0); // ??
	playermsg.add<uint32_t>(0); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	playermsg.add<uint16_t>(0); // ??
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterInspection()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_INSPECTION);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	uint8_t inventoryItems = 0;
	auto startInventory = playermsg.getBufferPosition();
	playermsg.skipBytes(1);
	for (std::underlying_type<slots_t>::type slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_POTION2; slot++) {
		Item* inventoryItem = player->getInventoryItem(static_cast<slots_t>(slot));
		if (inventoryItem) {
			++inventoryItems;

			playermsg.addByte(slot);
			playermsg.addString(inventoryItem->getName());
			AddItem(inventoryItem);
			playermsg.addByte(0); // imbuements

			auto descriptions = Item::getDescriptions(Item::items[inventoryItem->getID()], inventoryItem);
			playermsg.addByte(descriptions.size());
			for (const auto& description : descriptions) {
				playermsg.addString(description.first);
				playermsg.addString(description.second);
			}
		}
	}
	playermsg.addString(player->getName());
	AddOutfit(player->getDefaultOutfit());

	playermsg.addByte(3);
	playermsg.addString("Level");
	playermsg.addString(std::to_string(player->getLevel()));
	playermsg.addString("Vocation");
	playermsg.addString(player->getVocation()->getVocName());
	playermsg.addString("Outfit");

	const Outfit* outfit = Outfits::getInstance().getOutfitByLookType(player->getSex(), player->getDefaultOutfit().lookType);
	if (outfit) {
		playermsg.addString(outfit->name);
	} else {
		playermsg.addString("unknown");
	}
	playermsg.setBufferPosition(startInventory);
	playermsg.addByte(inventoryItems);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterBadges()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_BADGES);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.addByte(0x00); // enable badges
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCyclopediaCharacterTitles()
{
	playermsg.reset();
	playermsg.addByte(0xDA);
	playermsg.addByte(CYCLOPEDIA_CHARACTERINFO_TITLES);
	#if CLIENT_VERSION >= 1215
	playermsg.addByte(0x00); // No data available
	#endif
	playermsg.addByte(0x00); // ??
	playermsg.addByte(0x00); // ??
	writeToOutputBuffer(playermsg);
}
#endif

#if GAME_FEATURE_HIGHSCORES > 0
void ProtocolGame::sendHighscoresNoData()
{
	playermsg.reset();
	playermsg.addByte(0xB1);
	playermsg.addByte(0x01); // No data available
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendHighscores(const std::vector<HighscoreCharacter>& characters, uint8_t categoryId, uint16_t page, uint16_t pages)
{
	playermsg.reset();
	playermsg.addByte(0xB1);
	playermsg.addByte(0x00); // No data available

	playermsg.addByte(categoryId); // Selected Category

	playermsg.add<uint16_t>(page); // Current page
	playermsg.add<uint16_t>(pages); // Pages

	playermsg.addByte(characters.size()); // Character Count
	for (const HighscoreCharacter& character : characters) {
		playermsg.add<uint32_t>(character.rank); // Rank
		playermsg.addString(character.name); // Character Name
		playermsg.addByte(character.vocation); // Vocation Id
		playermsg.add<uint16_t>(character.level); // Level
		playermsg.add<uint64_t>(character.points); // Points
		playermsg.add<uint8_t>(character.online);

		playermsg.add<uint8_t>(character.outfit.lookBody);
		playermsg.add<uint8_t>(character.outfit.lookFeet);
		playermsg.add<uint8_t>(character.outfit.lookHead);
		playermsg.add<uint8_t>(character.outfit.lookLegs);
		playermsg.add<uint16_t>(character.outfit.lookType);
		playermsg.add<uint8_t>(character.outfit.lookAddons);
		playermsg.add<uint16_t>(character.outfit.lookWings);
		playermsg.add<uint16_t>(character.outfit.lookAura);
		playermsg.addString(character.outfit.lookOutline);
		playermsg.addString(character.outfit.lookShader);
	}

	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendTournamentLeaderboard()
{
	playermsg.reset();
	playermsg.addByte(0xC5);
	playermsg.addByte(0);
	playermsg.addByte(0x01); // No data available
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendReLoginWindow(uint8_t unfairFightReduction)
{
	playermsg.reset();
	playermsg.addByte(0x28);
	#if GAME_FEATURE_DEATH_TYPE > 0
	playermsg.addByte(0x00);
	#endif
	#if GAME_FEATURE_DEATH_PENALTY > 0
	playermsg.addByte(unfairFightReduction);
	#else
	(void)unfairFightReduction;
	#endif
	#if CLIENT_VERSION >= 1121
	playermsg.addByte(0x01); // use death redemption (boolean)
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendStats(uint8_t type)
{
	playermsg.reset();
	AddPlayerStats(type);
	writeToOutputBuffer(playermsg);
}

#if CLIENT_VERSION >= 950
void ProtocolGame::sendBasicData()
{
	playermsg.reset();
	playermsg.addByte(0x9F);
	if (player->isPremium()) {
		playermsg.addByte(1);
		#if GAME_FEATURE_PREMIUM_EXPIRATION > 0
		playermsg.add<uint32_t>(time(nullptr) + (player->premiumDays * 86400));
		#endif
	} else {
		playermsg.addByte(0);
		#if GAME_FEATURE_PREMIUM_EXPIRATION > 0
		playermsg.add<uint32_t>(0);
		#endif
	}
	playermsg.addByte(player->getVocation()->getClientId());
	#if CLIENT_VERSION >= 1100
	playermsg.addByte(((player->getVocation()->getId() != 0) ? 0x01 : 0x00));
	#endif

	std::vector<uint16_t> spells = g_spells->getSpellsByVocation(player->getVocationId());
	playermsg.add<uint16_t>(spells.size());
	for (uint16_t spellId : spells) {
		playermsg.addByte(spellId);
	}
	#if GAME_FEATURE_NEW_MAGIC_SHIELD > 0
	//bool - determine whether magic shield is active or not
	playermsg.addByte(0);
	#endif
	writeToOutputBuffer(playermsg);
}
#endif

/*void ProtocolGame::sendBlessStatus()
{
	uint16_t haveBlesses = 0;
	uint8_t blessings = (version >= 1130 ? 8 : 6);
	for (uint8_t i = 1; i < blessings; i++) {
		if (player->hasBlessing(i)) {
			haveBlesses++;
		}
	}

	playermsg.reset();
	playermsg.addByte(0x9C);
	if (haveBlesses >= 5) {
		if (version >= 1120) {
			playermsg.add<uint16_t>((static_cast<uint16_t>(1) << haveBlesses) - 1);
		} else {
			playermsg.add<uint16_t>(0x01);
		}
	} else {
		playermsg.add<uint16_t>(0x00);
	}
	if (version >= 1120) {
		playermsg.addByte((haveBlesses >= 5 ? 2 : 1));
	}
	writeToOutputBuffer(playermsg);
}*/

void ProtocolGame::sendTextMessage(const TextMessage& message)
{
	uint8_t messageType = translateMessageClassToClient(message.type);
	if (messageType == MESSAGE_NONE) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xB4);
	playermsg.addByte(messageType);
	switch (message.type) {
		case MESSAGE_DAMAGE_DEALT:
		case MESSAGE_DAMAGE_RECEIVED:
		case MESSAGE_DAMAGE_OTHERS: {
			playermsg.addPosition(message.position);
			playermsg.add<uint32_t>(message.primary.value);
			playermsg.addByte(message.primary.color);
			playermsg.add<uint32_t>(message.secondary.value);
			playermsg.addByte(message.secondary.color);
			playermsg.addString("");
			break;
		}
		case MESSAGE_MANA:
		case MESSAGE_HEALED:
		case MESSAGE_HEALED_OTHERS:
		case MESSAGE_EXPERIENCE:
		case MESSAGE_EXPERIENCE_OTHERS: {
			playermsg.addPosition(message.position);
			playermsg.add<uint32_t>(message.primary.value);
			playermsg.addByte(message.primary.color);
			playermsg.addString("");
			break;
		}
		case MESSAGE_GUILD:
		case MESSAGE_PARTY_MANAGEMENT:
		case MESSAGE_PARTY:
			playermsg.add<uint16_t>(message.channelId);
			break;
		default: {
			break;
		}
	}
	playermsg.addString(message.text);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendClosePrivate(uint16_t channelId)
{
	playermsg.reset();
	playermsg.addByte(0xB3);
	playermsg.add<uint16_t>(channelId);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatePrivateChannel(uint16_t channelId, const std::string& channelName)
{
	playermsg.reset();
	playermsg.addByte(0xB2);
	playermsg.add<uint16_t>(channelId);
	playermsg.addString(channelName);
	#if GAME_FEATURE_CHAT_PLAYERLIST > 0
	playermsg.add<uint16_t>(0x01);
	playermsg.addString(player->getName());
	playermsg.add<uint16_t>(0x00);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendChannelsDialog()
{
	playermsg.reset();
	playermsg.addByte(0xAB);

	const ChannelList& list = g_chat->getChannelList(*player);
	playermsg.addByte(list.size());
	for (ChatChannel* channel : list) {
		playermsg.add<uint16_t>(channel->getId());
		playermsg.addString(channel->getName());
	}

	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendChannel(uint16_t channelId, const std::string& channelName, const UsersMap* channelUsers, const InvitedMap* invitedUsers)
{
	playermsg.reset();
	playermsg.addByte(0xAC);
	playermsg.add<uint16_t>(channelId);
	playermsg.addString(channelName);
	#if GAME_FEATURE_CHAT_PLAYERLIST > 0
	if (channelUsers) {
		playermsg.add<uint16_t>(channelUsers->size());
		for (const auto& it : *channelUsers) {
			playermsg.addString(it.second->getName());
		}
	} else {
		playermsg.add<uint16_t>(0x00);
	}

	if (invitedUsers) {
		playermsg.add<uint16_t>(invitedUsers->size());
		for (const auto& it : *invitedUsers) {
			playermsg.addString(it.second->getName());
		}
	} else {
		playermsg.add<uint16_t>(0x00);
	}
	#else
	(void)channelUsers;
	(void)invitedUsers;
	#endif
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_RULEVIOLATION > 0
void ProtocolGame::sendRuleViolationChannel(uint16_t channelId)
{
	playermsg.reset();
	playermsg.addByte(0xAE);
	playermsg.add<uint16_t>(channelId);
	writeToOutputBuffer(playermsg);

	auto& ruleViolations = g_game.getRuleViolations();
	for (auto it = ruleViolations.begin(); it != ruleViolations.end();) {
		RuleViolation& rvr = it->second;
		if (Player* owner = g_game.getPlayerByID(rvr.owner)) {
			if (rvr.gamemaster == 0) {
				sendChannelMessage(owner, rvr.message, TALKTYPE_RVR_CHANNEL, ((OTSYS_TIME() - rvr.time) / 1000) & 0xFFFFFFFF);
			}

			++it;
		} else {
			it = ruleViolations.erase(it);
		}
	}
}

void ProtocolGame::sendRuleViolationRemove(const std::string& target)
{
	playermsg.reset();
	playermsg.addByte(0xAF);
	playermsg.addString(target);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendRuleViolationCancel(const std::string& target)
{
	playermsg.reset();
	playermsg.addByte(0xB0);
	playermsg.addString(target);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendRuleViolationLock()
{
	playermsg.reset();
	playermsg.addByte(0xB1);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendChannelMessage(const Player* target, const std::string& text, SpeakClasses type, uint32_t time)
{
	uint8_t talkType = translateSpeakClassToClient(type);
	if (talkType == TALKTYPE_NONE) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xAA);
	#if GAME_FEATURE_MESSAGE_STATEMENT > 0
	playermsg.add<uint32_t>(0x00);
	#endif
	playermsg.addString(target->getName());
	#if GAME_FEATURE_MESSAGE_LEVEL > 0
	playermsg.add<uint16_t>(0x00);
	#endif
	playermsg.addByte(talkType);
	#if CLIENT_VERSION >= 713
	playermsg.add<uint32_t>(time);
	#else
	(void)time;
	#endif
	playermsg.addString(text);
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendChannelMessage(const std::string& author, const std::string& text, SpeakClasses type, uint16_t channel)
{
	uint8_t talkType = translateSpeakClassToClient(type);
	if (talkType == TALKTYPE_NONE) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xAA);
	#if GAME_FEATURE_MESSAGE_STATEMENT > 0
	playermsg.add<uint32_t>(0x00);
	#endif
	playermsg.addString(author);
	#if GAME_FEATURE_MESSAGE_LEVEL > 0
	playermsg.add<uint16_t>(0x00);
	#endif
	playermsg.addByte(talkType);
	playermsg.add<uint16_t>(channel);
	playermsg.addString(text);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendIcons(uint32_t icons)
{
	playermsg.reset();
	playermsg.addByte(0xA2);
	#if GAME_FEATURE_PLAYERICONS_U32 > 0
	playermsg.add<uint32_t>(icons);
	#elif GAME_FEATURE_PLAYERICONS_U16 > 0
	playermsg.add<uint16_t>(static_cast<uint16_t>(icons));
	#else
	playermsg.addByte(static_cast<uint8_t>(icons));
	#endif
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void ProtocolGame::sendContainer(uint8_t cid, const Container* container, bool hasParent, uint16_t firstIndex)
#else
void ProtocolGame::sendContainer(uint8_t cid, const Container* container, bool hasParent)
#endif
{
	playermsg.reset();
	playermsg.addByte(0x6E);

	playermsg.addByte(cid);
	#if GAME_FEATURE_BROWSEFIELD > 0
	if (container->getID() == ITEM_BROWSEFIELD) {
		AddItem(1987, 1);
		playermsg.addString("Browse Field");
	} else {
		AddItem(container);

		const std::string& containerName = container->getName();
		playermsg.addString((containerName.empty() ? (std::string("item of type ") + std::to_string(container->getID())) : containerName));
	}
	#else
	AddItem(container);
	playermsg.addString(container->getName());
	#endif

	playermsg.addByte(container->capacity());

	playermsg.addByte(hasParent ? 0x01 : 0x00);
	
	#if CLIENT_VERSION >= 1220
	//can use depot search
	playermsg.addByte(0x00);
	#endif

	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	playermsg.addByte(container->isUnlocked() ? 0x01 : 0x00); // Drag and drop
	playermsg.addByte(container->hasPagination() ? 0x01 : 0x00); // Pagination

	uint32_t containerSize = container->size();
	playermsg.add<uint16_t>(containerSize);
	playermsg.add<uint16_t>(firstIndex);
	if (firstIndex < containerSize) {
		uint8_t itemsToSend = std::min<uint32_t>(std::min<uint32_t>(container->capacity(), containerSize - firstIndex), std::numeric_limits<uint8_t>::max());

		playermsg.addByte(itemsToSend);
		for (auto it = container->getItemList().begin() + firstIndex, end = it + itemsToSend; it != end; ++it) {
			AddItem(*it);
		}
	} else {
		playermsg.addByte(0x00);
	}
	#else
	uint8_t itemsToSend = std::min<uint32_t>(container->size(), std::numeric_limits<uint8_t>::max());

	playermsg.addByte(itemsToSend);
	for (auto it = container->getItemList().begin(), end = it + itemsToSend; it != end; ++it) {
		AddItem(*it);
	}
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendShop(Npc* npc, const ShopInfoList& itemList)
{
	playermsg.reset();
	playermsg.addByte(0x7A);
	(void)npc;

	uint16_t itemsToSend = std::min<size_t>(itemList.size(), std::numeric_limits<uint16_t>::max());
	playermsg.add<uint16_t>(itemsToSend);

	uint16_t i = 0;
	for (auto it = itemList.begin(); i < itemsToSend; ++it, ++i) {
		AddShopItem(*it);
	}

	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCloseShop()
{
	playermsg.reset();
	playermsg.addByte(0x7C);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendSaleItemList(const std::map<uint64_t, PlayerInventorySellItem>& inventoryMap, const std::map<uint32_t, uint16_t>& stackMap, uint8_t categoryIndex)
{
	uint64_t playerMoney = player->getBankBalance();
	playermsg.reset();
	playermsg.addByte(0x7B);
	playermsg.add<uint64_t>(playerMoney);
	playermsg.addByte(categoryIndex);

	uint16_t itemsToSend = 0;
	uint16_t stackMapToSend = 0;
	auto msgPosition1 = playermsg.getBufferPosition();
	playermsg.skipBytes(2);
	auto msgPosition2 = playermsg.getBufferPosition();
	playermsg.skipBytes(2);

	for (const auto& item : inventoryMap) {
		playermsg.add<uint64_t>(item.first);
		playermsg.addItemId(item.second.itemId);
		playermsg.addByte(item.second.rarity);
		++itemsToSend;
	}

	for (const auto& item : stackMap) {
		playermsg.addItemId(item.first);
		playermsg.add<uint16_t>(item.second);
		++stackMapToSend;
	}

	playermsg.setBufferPosition(msgPosition1);
	playermsg.add<uint16_t>(itemsToSend);
	playermsg.setBufferPosition(msgPosition2);
	playermsg.add<uint16_t>(stackMapToSend);
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_ANALYTICS > 0
void ProtocolGame::sendImpactTracking(bool healing, int32_t impact)
{
	playermsg.reset();
	playermsg.addByte(0xCC);
	playermsg.addByte(healing ? 0x00 : 0x01);
	playermsg.add<uint32_t>(impact);
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_ANALYTICS_IMPACT_TRACKING_EXTENDED > 0
void ProtocolGame::sendImpactTracking(CombatType_t combatType, int32_t impact, const std::string& cause)
{
	playermsg.reset();
	playermsg.addByte(0xCC);
	playermsg.addByte(cause.empty() ? 0x01 : 0x02);
	playermsg.add<uint32_t>(impact);
	playermsg.addByte(getCipbiaElement(combatType));
	if (!cause.empty()) {
		playermsg.addString(cause);
	}
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendKillTracking(const std::string& name, const Outfit_t& outfit, const Container* container)
{
	playermsg.reset();
	playermsg.addByte(0xD1);
	playermsg.addString(name);
	playermsg.add<uint16_t>(outfit.lookType ? outfit.lookType : 19);
	playermsg.addByte(outfit.lookHead);
	playermsg.addByte(outfit.lookBody);
	playermsg.addByte(outfit.lookLegs);
	playermsg.addByte(outfit.lookFeet);
	playermsg.addByte(outfit.lookAddons);
	playermsg.addByte(container->size());
	for (const Item* item : container->getItemList()) {
		AddItem(item);
	}
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendQuestLog()
{
	playermsg.reset();
	playermsg.addByte(0xF0);
	playermsg.add<uint16_t>(g_game.quests.getQuestsCount(player));
	for (const Quest& quest : g_game.quests.getQuests()) {
		if (quest.isStarted(player)) {
			playermsg.add<uint16_t>(quest.getID());
			playermsg.addString(quest.getName());
			playermsg.addByte(quest.isCompleted(player));
		}
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendQuestLine(const Quest* quest)
{
	playermsg.reset();
	playermsg.addByte(0xF1);
	playermsg.add<uint16_t>(quest->getID());
	playermsg.addByte(quest->getMissionsCount(player));
	for (const Mission& mission : quest->getMissions()) {
		if (mission.isStarted(player)) {
			#if GAME_FEATURE_QUEST_TRACKER > 0
			playermsg.add<uint16_t>(mission.getMissionId());
			#endif
			playermsg.addString(mission.getName(player));
			playermsg.addString(mission.getDescription(player));
		}
	}
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_QUEST_TRACKER > 0
void ProtocolGame::sendTrackedQuests(uint8_t remainingQuests, std::vector<uint16_t>& quests)
{
	playermsg.reset();
	playermsg.addByte(0xD0);
	playermsg.addByte(0x01);
	playermsg.addByte(remainingQuests);
	playermsg.addByte(static_cast<uint8_t>(quests.size()));
	for (uint16_t missionId : quests) {
		const Mission* mission = g_game.quests.getMissionByID(missionId);
		if (mission) {
			Quest* quest = g_game.quests.getQuestByID(mission->getQuestId());
			playermsg.add<uint16_t>(missionId);
			playermsg.addString((quest ? quest->getName() : std::string()));
			playermsg.addString(mission->getName(player));
			playermsg.addString(mission->getDescription(player));
		} else {
			playermsg.add<uint16_t>(missionId);
			playermsg.addString("Unknown Error");
			playermsg.addString("Unknown Error");
			playermsg.addString("Unknown Error");
		}
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendUpdateTrackedQuest(const Mission* mission)
{
	playermsg.reset();
	playermsg.addByte(0xD0);
	playermsg.addByte(0x00);
	playermsg.add<uint16_t>(mission->getMissionId());
	playermsg.addString(mission->getName(player));
	playermsg.addString(mission->getDescription(player));
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::startCamRecording()
{
	if (!g_config.getBoolean(ConfigManager::CAMS_ENABLED)) {
		return;
	}

	camId = g_cams.initCam(std::string(player->getName()), player->getGUID(), version);
	camStart = time(nullptr);
	camLastRefreshPacket = 0;
	sendCamRefreshPacket();
}

void ProtocolGame::stopCamRecording()
{
	camId = 0;
}

bool ProtocolGame::isRecording()
{
	return camId > 0;
}

void ProtocolGame::sendCamRefreshPacket()
{
	if (!player || !camId)
		return;

	if (time(nullptr) > camStart + CAM_MAX_DURATION) { // start new cam
		camId = g_cams.initCam(std::string(player->getName()), player->getGUID(), version);
		camStart = time(nullptr);
		camLastRefreshPacket = 0;
	}

	if (time(nullptr) < camLastRefreshPacket + CAM_REFRESH_PACKET_INTERVAL)
		return;

	camLastRefreshPacket = time(nullptr);
	camOnlyPackets = true;
	sendAddCreature(player, player->getPosition(), 0, false);
	syncOpenContainers();
	camOnlyPackets = false;
}

void ProtocolGame::syncOpenContainers()
{
	const auto& openContainers = player->getOpenContainers();
	for (const auto& it : openContainers) {
		auto openContainer = it.second;
		auto container = openContainer.container;
		bool hasParent = (dynamic_cast<const Container*>(container->getParent()) != nullptr);
		sendContainer(it.first, container, hasParent, openContainer.index);
	}
}

void ProtocolGame::parseInputEvent(NetworkMessage& msg)
{
    uint8_t type = msg.getByte();
    int bytes = 0;
    switch(type) {
        case 0:
            bytes = 0;
            break;
        case 1:
        case 2:
        case 4:
            bytes = 5;
            break;
        case 3:
            bytes = 4;
            break;
        case 5:
            bytes = msg.peek<uint16_t>() + 2;
            break;
        case 6:
        case 7:
            bytes = 2;
            break;
        case 8:
            bytes = 3;
            break;
    }

    // if(camId) {
    //     g_cams.addInputPacket(camId, msg.getBuffer() + msg.getBufferPosition() - 2, 2 + bytes);
    // }
    msg.skipBytes(bytes);
}

void ProtocolGame::sendCloseContainer(uint8_t cid)
{
	playermsg.reset();
	playermsg.addByte(0x6F);
	playermsg.addByte(cid);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureTurn(const Creature* creature, uint32_t stackPos)
{
	if (!canSee(creature)) {
		return;
	}
	
	playermsg.reset();
	playermsg.addByte(0x6B);
	playermsg.addPosition(creature->getPosition());
	playermsg.addByte(stackPos);
	playermsg.add<uint16_t>(0x63);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte(creature->getDirection());
	#if CLIENT_VERSION >= 953
	playermsg.addByte(player->canWalkthroughEx(creature) ? 0x00 : 0x01);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureSay(const Creature* creature, SpeakClasses type, const std::string& text, const Position* pos/* = nullptr*/)
{
	uint8_t talkType = translateSpeakClassToClient(type);
	if (talkType == TALKTYPE_NONE) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xAA);
	#if GAME_FEATURE_MESSAGE_STATEMENT > 0
	static uint32_t statementId = 0;
	playermsg.add<uint32_t>(++statementId);
	#endif
	playermsg.addString(creature->getName());
	#if CLIENT_VERSION >= 1250
	if (statementId != 0) {
		playermsg.addByte(0x00);//(Traded)
	}
	#endif

	//Add level only for players
	#if GAME_FEATURE_MESSAGE_LEVEL > 0
	if (const Player* speaker = creature->getPlayer()) {
		playermsg.add<uint16_t>(speaker->getLevel());
	} else {
		playermsg.add<uint16_t>(0x00);
	}
	#endif

	playermsg.addByte(talkType);
	if (pos) {
		playermsg.addPosition(*pos);
	} else {
		playermsg.addPosition(creature->getPosition());
	}

	playermsg.addString(text);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendToChannel(const Creature* creature, SpeakClasses type, const std::string& text, uint16_t channelId)
{
	uint8_t talkType = translateSpeakClassToClient(type);
	if (talkType == TALKTYPE_NONE) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xAA);
	#if GAME_FEATURE_MESSAGE_STATEMENT > 0
	static uint32_t statementId = 0;
	playermsg.add<uint32_t>(++statementId);
	#endif
	if (!creature) {
		playermsg.add<uint16_t>(0x00);
		#if CLIENT_VERSION >= 1250
		if (statementId != 0) {
			playermsg.addByte(0x00);//(Traded)
		}
		#endif
		#if GAME_FEATURE_MESSAGE_LEVEL > 0
		playermsg.add<uint16_t>(0x00);
		#endif
	} else if (type == TALKTYPE_CHANNEL_R2) {
		playermsg.add<uint16_t>(0x00);
		#if CLIENT_VERSION >= 1250
		if (statementId != 0) {
			playermsg.addByte(0x00);//(Traded)
		}
		#endif
		#if GAME_FEATURE_MESSAGE_LEVEL > 0
		playermsg.add<uint16_t>(0x00);
		#endif
		type = TALKTYPE_CHANNEL_R1;
	} else {
		playermsg.addString(creature->getName());
		#if CLIENT_VERSION >= 1250
		if (statementId != 0) {
			playermsg.addByte(0x00);//(Traded)
		}
		#endif

		//Add level only for players
		#if GAME_FEATURE_MESSAGE_LEVEL > 0
		if (const Player* speaker = creature->getPlayer()) {
			playermsg.add<uint16_t>(speaker->getLevel());
		} else {
			playermsg.add<uint16_t>(0x00);
		}
		#endif
	}

	playermsg.addByte(talkType);
	playermsg.add<uint16_t>(channelId);
	playermsg.addString(text);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPrivateMessage(const Player* speaker, SpeakClasses type, const std::string& text)
{
	uint8_t talkType = translateSpeakClassToClient(type);
	if (talkType == TALKTYPE_NONE) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xAA);
	#if GAME_FEATURE_MESSAGE_STATEMENT > 0
	static uint32_t statementId = 0;
	playermsg.add<uint32_t>(++statementId);
	#endif
	if (speaker) {
		#if GAME_FEATURE_RULEVIOLATION > 0
		if (type == TALKTYPE_RVR_ANSWER) {
			playermsg.addString("Gamemaster");
			#if CLIENT_VERSION >= 1250
			if (statementId != 0) {
				playermsg.addByte(0x00);//(Traded)
			}
			#endif
			#if GAME_FEATURE_MESSAGE_LEVEL > 0
			playermsg.add<uint16_t>(0);

			#endif
		} else {
			playermsg.addString(speaker->getName());
			#if CLIENT_VERSION >= 1250
			if (statementId != 0) {
				playermsg.addByte(0x00);//(Traded)
			}
			#endif
			#if GAME_FEATURE_MESSAGE_LEVEL > 0
			playermsg.add<uint16_t>(speaker->getLevel());
			#endif
		}
		#else
		playermsg.addString(speaker->getName());
		#if CLIENT_VERSION >= 1250
		if (statementId != 0) {
			playermsg.addByte(0x00);//(Traded)
		}
		#endif
		#if GAME_FEATURE_MESSAGE_LEVEL > 0
		playermsg.add<uint16_t>(speaker->getLevel());
		#endif
		#endif
	} else {
		playermsg.add<uint16_t>(0x00);
		#if CLIENT_VERSION >= 1250
		if (statementId != 0) {
			playermsg.addByte(0x00);//(Traded)
		}
		#endif
		#if GAME_FEATURE_MESSAGE_LEVEL > 0
		playermsg.add<uint16_t>(0x00);
		#endif
	}
	playermsg.addByte(talkType);
	playermsg.addString(text);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCancelTarget()
{
	playermsg.reset();
	playermsg.addByte(0xA3);
	#if GAME_FEATURE_ATTACK_SEQUENCE > 0
	playermsg.add<uint32_t>(0x00);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendChangeSpeed(const Creature* creature, uint32_t speed)
{
	playermsg.reset();
	playermsg.addByte(0x8F);
	playermsg.add<uint32_t>(creature->getID());
	#if CLIENT_VERSION >= 1059
	#if GAME_FEATURE_NEWSPEED_LAW > 0
	playermsg.add<uint16_t>(creature->getBaseSpeed() / 2);
	#else
	playermsg.add<uint16_t>(creature->getBaseSpeed());
	#endif
	#endif
	#if GAME_FEATURE_NEWSPEED_LAW > 0
	playermsg.add<uint16_t>(speed / 2);
	#else
	playermsg.add<uint16_t>(speed);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCancelWalk()
{
	playermsg.reset();
	playermsg.addByte(0xB5);
	playermsg.addByte(player->getDirection());
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendSkills()
{
	playermsg.reset();
	AddPlayerSkills();
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPing()
{
	playermsg.reset();
	#if GAME_FEATURE_PING > 0
	playermsg.addByte(0x1D);
	#else
	playermsg.addByte(0x1E);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPingBack()
{
	playermsg.reset();
	playermsg.addByte(0x1E);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendDistanceShoot(const Position& from, const Position& to, uint16_t type, bool typeOb, uint16_t duration, double speed, const std::string color)
{
	playermsg.reset();
	playermsg.addByte(0x85);
	playermsg.addPosition(from);
	playermsg.addPosition(to);
	playermsg.add<uint16_t>(type);
	playermsg.addByte(typeOb);
	playermsg.add<uint16_t>(duration);
	playermsg.addDouble<2>(speed);
	playermsg.addString(color);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendLineEffect(const Position& from, const Position& to, uint16_t type, bool bottom)
{
	playermsg.reset();
	playermsg.addByte(0x80);
	playermsg.addPosition(from);
	playermsg.addPosition(to);
	playermsg.add<uint16_t>(type);
	playermsg.addByte(bottom);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendMagicEffect(const Position& pos, uint16_t type, uint8_t bottom /*= 0*/, const std::string color /*= 0*/)
{
	if (!canSee(pos)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x83);
	playermsg.addPosition(pos);
	playermsg.add<uint16_t>(type);
	playermsg.addByte(bottom);
	playermsg.addString(color);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureEffect(const Creature* creature, uint16_t type, uint8_t bottom /*= 0*/)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x99);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.add<uint16_t>(type);
	playermsg.addByte(bottom);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendUpdateTileCreature(const Position& pos, uint32_t stackpos, const Creature* creature)
{
	if (!canSee(pos)) {
		return;
	}

	playermsg.addByte(0x6B);
	playermsg.addPosition(pos);
	playermsg.addByte(stackpos);

	bool known;
	uint32_t removedKnown;
	checkCreatureAsKnown(creature->getID(), known, removedKnown);
	AddCreature(creature, false, removedKnown);

	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureHealth(const Creature* creature, uint8_t healthPercent, uint8_t energyPercent)
{
	playermsg.reset();
	playermsg.addByte(0x8C);
	playermsg.add<uint32_t>(creature->getID());
	#if CLIENT_VERSION >= 1121
	if (creature->isHealthHidden() && creature != player) {
		playermsg.addByte(0x00);
		playermsg.addByte(0x00);
	} else {
		playermsg.addByte(healthPercent);
		playermsg.addByte(energyPercent);
	}
	#else
	if (creature->isHealthHidden()) {
		playermsg.addByte(0x00);
		playermsg.addByte(0x00);
	} else {
		playermsg.addByte(healthPercent);
		playermsg.addByte(energyPercent);
	}
	#endif
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_PARTY_LIST > 0
void ProtocolGame::sendPartyCreatureUpdate(const Creature* target)
{
	bool known;
	uint32_t removedKnown;
	uint32_t cid = target->getID();
	checkCreatureAsKnown(cid, known, removedKnown);

	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(0);//creature update
	playermsg.add<uint32_t>(cid);
	AddCreature(target, known, removedKnown);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyCreatureHealth(const Creature* target, uint8_t healthPercent)
{
	uint32_t cid = target->getID();
	if (knownCreatureSet.find(cid) == knownCreatureSet.end()) {
		sendPartyCreatureUpdate(target);
	}

	playermsg.reset();
	playermsg.addByte(0x8B); // 139
	playermsg.addByte(1); //health precent
	playermsg.add<uint32_t>(cid);
	playermsg.addByte(healthPercent);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyPlayerMana(const Player* target, uint8_t manaPercent)
{
	uint32_t cid = target->getID();
	if (knownCreatureSet.find(cid) == knownCreatureSet.end()) {
		sendPartyCreatureUpdate(target);
	}

	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(2);//mana percent
	playermsg.add<uint32_t>(cid);
	playermsg.addByte(manaPercent);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyPlayerPos(const Creature* target, const Position pos)
{
	if (!target) {
		return;
	}

	uint32_t cid = target->getID();
	if (knownCreatureSet.find(cid) == knownCreatureSet.end()) {
		sendPartyCreatureUpdate(target);
	}

	playermsg.reset();
	playermsg.addByte(0x8B); // 139
	playermsg.addByte(9); // player pos
	playermsg.add<uint32_t>(cid);
	playermsg.addPosition(pos);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyCreatureShowStatus(const Creature* target, bool showStatus)
{
	uint32_t cid = target->getID();
	if (knownCreatureSet.find(cid) == knownCreatureSet.end()) {
		sendPartyCreatureUpdate(target);
	}

	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(3);//show status
	playermsg.add<uint32_t>(cid);
	playermsg.addByte((showStatus ? 0x01 : 0x00));
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyJoin(const Creature* target)
{
	bool known;
	uint32_t removedKnown;
	uint32_t cid = target->getID();
	checkCreatureAsKnown(cid, known, removedKnown);

	Outfit_t outfit = target->getCurrentOutfit();

	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(4);// Party join
	playermsg.add<uint32_t>(cid);
	playermsg.add<uint8_t>(target->getPlayer()->getVocationId());
	playermsg.add<uint8_t>(target->getPlayer()->getPartyShield(target->getPlayer()));
	playermsg.addString(target->getName());

	playermsg.addByte(outfit.lookHead);
	playermsg.addByte(outfit.lookBody);
	playermsg.addByte(outfit.lookLegs);
	playermsg.addByte(outfit.lookFeet);
	playermsg.addByte(outfit.lookAddons);
	playermsg.add<uint16_t>(outfit.lookType);
	playermsg.add<uint16_t>(outfit.lookWings);
	playermsg.add<uint16_t>(outfit.lookAura);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyUpdateShield(const Creature* target)
{
	uint32_t cid = target->getID();
	if (knownCreatureSet.find(cid) == knownCreatureSet.end()) {
		sendPartyCreatureUpdate(target);
	}

	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(7);
	playermsg.add<uint32_t>(cid);
	playermsg.addByte(target->getPlayer()->getPartyShield(target->getPlayer()));
	writeToOutputBuffer(playermsg);
}


void ProtocolGame::sendPartyLeave(const Creature* target)
{
	bool known;
	uint32_t removedKnown;
	uint32_t cid = target->getID();
	checkCreatureAsKnown(cid, known, removedKnown);

	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(5);// Party quit
	playermsg.add<uint32_t>(cid);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyDisband()
{
	playermsg.reset();
	playermsg.addByte(0x8B); //139
	playermsg.addByte(6);// Party disband
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendFYIBox(const std::string& message)
{
	playermsg.reset();
	playermsg.addByte(0x15);
	playermsg.addString(message);
	writeToOutputBuffer(playermsg);
}

//tile
void ProtocolGame::sendMapDescription(const Position& pos)
{
	int32_t startz, endz, zstep;

	if (pos.z > 12) {
		startz = pos.z - 2;
		endz = std::min<int32_t>(MAP_MAX_LAYERS - 1, pos.z + 2);
		zstep = 1;
	} else {
		startz = 12;
		endz = 0;
		zstep = -1;
	}

	for (int32_t nz = startz; nz != endz + zstep; nz += zstep) {
		sendFloorDescription(pos, nz);	
	}
}

void ProtocolGame::sendFloorDescription(const Position& pos, int floor)
{
	playermsg.reset();
	playermsg.addByte(0x4B);
	playermsg.addPosition(player->getPosition());
	playermsg.addByte(floor);
	int32_t skip = -1;
	GetFloorDescription(pos.x - awareRange.left(), pos.y - awareRange.top(), floor, awareRange.horizontal(), awareRange.vertical(), pos.z - floor, skip);
	if (skip >= 0) {
		playermsg.addByte(skip);
		playermsg.addByte(0xFF);
	}
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_TILE_ADDTHING_STACKPOS > 0
void ProtocolGame::sendAddTileItem(const Position& pos, uint32_t stackpos, const Item* item)
#else
void ProtocolGame::sendAddTileItem(const Position& pos, const Item* item)
#endif
{
	if (!canSee(pos)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x6A);
	playermsg.addPosition(pos);
	#if GAME_FEATURE_TILE_ADDTHING_STACKPOS > 0
	playermsg.addByte(stackpos);
	#endif
	AddItem(item);
	writeToOutputBuffer(playermsg);

	checkPredictiveWalking(pos);
}

void ProtocolGame::sendUpdateTileItem(const Position& pos, uint32_t stackpos, const Item* item)
{
	if (!canSee(pos)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x6B);
	playermsg.addPosition(pos);
	playermsg.addByte(stackpos);
	AddItem(item);
	writeToOutputBuffer(playermsg);

	checkPredictiveWalking(pos);
}

void ProtocolGame::sendRemoveTileThing(const Position& pos, uint32_t stackpos)
{
	if (!canSee(pos)) {
		return;
	}

	playermsg.reset();
	RemoveTileThing(pos, stackpos);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendUpdateTile(const Tile* tile, const Position& pos)
{
	if (!canSee(pos)) {
		return;
	}
	playermsg.reset();
	playermsg.addByte(0x69);
	playermsg.addPosition(pos);
	if (tile) {
		GetTileDescription(tile);
		playermsg.addByte(0x00);
		playermsg.addByte(0xFF);
	} else {
		playermsg.addByte(0x01);
		playermsg.addByte(0xFF);
	}

	writeToOutputBuffer(playermsg);
}

#if CLIENT_VERSION >= 1000
void ProtocolGame::sendFightModes()
{
	playermsg.reset();
	playermsg.addByte(0xA7);
	playermsg.addByte(player->fightMode);
	playermsg.addByte(player->chaseMode);
	playermsg.addByte(player->secureMode);
	playermsg.addByte(PVP_MODE_DOVE);
	writeToOutputBuffer(playermsg);
}
#endif

void ProtocolGame::sendAddCreature(const Creature* creature, const Position& pos, int32_t stackpos, bool isLogin)
{
	if (!canSee(pos)) {
		return;
	}

	if (creature != player) {
		if (stackpos != -1) {
			playermsg.reset();
			playermsg.addByte(0x6A);
			playermsg.addPosition(pos);
			playermsg.addByte(stackpos);

			bool known;
			uint32_t removedKnown;
			checkCreatureAsKnown(creature->getID(), known, removedKnown);
			AddCreature(creature, known, removedKnown);
			writeToOutputBuffer(playermsg);
		}

		if (isLogin) {
			sendMagicEffect(pos, CONST_ME_TELEPORT);
		}

		checkPredictiveWalking(pos);
		return;
	}

	playermsg.reset();

	#if GAME_FEATURE_LOGIN_PENDING > 0
	playermsg.addByte(0x17);
	#else
	playermsg.addByte(0x0A);
	#endif

	playermsg.add<uint32_t>(player->getID());
	playermsg.add<uint16_t>(SERVER_BEAT_MILISECONDS);

	#if GAME_FEATURE_NEWSPEED_LAW > 0
	playermsg.addDouble<3>(Creature::speedA);
	playermsg.addDouble<3>(Creature::speedB);
	playermsg.addDouble<3>(Creature::speedC);
	#endif

	// can report bugs?
	if (player->getAccountType() >= ACCOUNT_TYPE_TUTOR) {
		playermsg.addByte(0x01);
	} else {
		playermsg.addByte(0x00);
	}

	#if CLIENT_VERSION >= 1054
	playermsg.addByte(0x00); // can change pvp framing option
	#endif
	#if CLIENT_VERSION >= 1058
	playermsg.addByte(0x00); // expert mode button enabled
	#endif

	#if GAME_FEATURE_STORE > 0
	playermsg.addString(g_config.getString(ConfigManager::STORE_URL)); // URL (string) to ingame store images
	playermsg.add<uint16_t>(static_cast<uint16_t>(g_config.getNumber(ConfigManager::STORE_COIN_PACKAGES))); // premium coin package size
	#endif

	if (version >= 1150 || addExivaRestrictions) {
		playermsg.addByte(0x01); // exiva button enabled
	}

	#if GAME_FEATURE_TOURNAMENTS > 0
	playermsg.addByte(0x00); // tournament button enabled
	#endif

	#if GAME_FEATURE_LOGIN_PENDING > 0
	playermsg.addByte(0x0A); // sendPendingStateEntered
	playermsg.addByte(0x0F); // sendWorldEnter
	#endif

	#if GAME_FEATURE_RULEVIOLATION > 0
	if (player->isAccessPlayer()) {
		playermsg.addByte(0x0B);
		#if CLIENT_VERSION >= 726 && CLIENT_VERSION <= 730
		for (int32_t i = 0; i < 30; ++i) {
		#elif CLIENT_VERSION >= 850
		for (int32_t i = 0; i < 20; ++i) {
		#elif CLIENT_VERSION >= 820
		for (int32_t i = 0; i < 23; ++i) {
		#else
		for (int32_t i = 0; i < 32; ++i) {
		#endif
			#if CLIENT_VERSION >= 772
			playermsg.addByte(0x84);
			#else
			playermsg.addByte(0x44);
			#endif
		}
	}
	#endif

	//gameworld settings
	AddWorldLight(g_game.getWorldLightInfo());

	writeToOutputBuffer(playermsg);

	#if CLIENT_VERSION >= 1121
	sendTibiaTime(g_game.getLightHour());
	#endif
	sendMapDescription(pos);
	if (isLogin) {
		sendMagicEffect(pos, CONST_ME_TELEPORT);
	}

	for (int i = CONST_SLOT_FIRST; i <= CONST_SLOT_LAST; ++i) {
		sendInventoryItem(static_cast<slots_t>(i), player->getInventoryItem(static_cast<slots_t>(i)));
	}

	// sendStats();
	// sendSkills();
	//sendBlessStatus();

	//player light level
	sendCreatureLight(creature);
	sendVIPEntries();

	#if CLIENT_VERSION >= 950
	sendBasicData();
	#endif
	#if GAME_FEATURE_ANALYTICS > 0
	sendMarketStatistics();
	#endif
	player->sendIcons();
}

void ProtocolGame::sendMoveCreature(const Creature* creature, const Position& newPos, int32_t newStackPos, const Position& oldPos, int32_t oldStackPos, bool teleport)
{
	if (creature == player) {
		if (oldStackPos >= 10) {
			sendMapDescription(newPos);
		} else if (teleport) {
			playermsg.reset();
			RemoveTileThing(oldPos, oldStackPos);
			writeToOutputBuffer(playermsg);
			sendMapDescription(newPos);
		} else if (newPos.z > oldPos.z) {
			playermsg.reset();
			RemoveTileThing(oldPos, oldStackPos);
			writeToOutputBuffer(playermsg);
			sendMapDescription(newPos);
		} else if (newPos.z < oldPos.z) {
			playermsg.reset();
			RemoveTileThing(oldPos, oldStackPos);
			writeToOutputBuffer(playermsg);
			sendMapDescription(newPos);
		} else {
			playermsg.reset();
			if (oldPos.z == 12 && newPos.z >= 13) {
				RemoveTileThing(oldPos, oldStackPos);
			} else {
				playermsg.addByte(0x6D);
				playermsg.addPosition(oldPos);
				playermsg.addByte(oldStackPos);
				playermsg.addPosition(newPos);
				playermsg.add<uint16_t>(creature->getStepDuration());
			}

			if (oldPos.y > newPos.y) { // north, for old x             
				playermsg.addByte(0x65);
				GetMapDescription(oldPos.x - awareRange.left(), newPos.y - awareRange.top(), newPos.z, awareRange.horizontal(), 1);
			} else if (oldPos.y < newPos.y) { // south, for old x
				playermsg.addByte(0x67);
				GetMapDescription(oldPos.x - awareRange.left(), newPos.y + awareRange.bottom(), newPos.z, awareRange.horizontal(), 1);
			}

			if (oldPos.x < newPos.x) { // east, [with new y]
				playermsg.addByte(0x66);
				GetMapDescription(newPos.x + awareRange.right(), newPos.y - awareRange.top(), newPos.z, 1, awareRange.vertical());

			} else if (oldPos.x > newPos.x) { // west, [with new y]
				playermsg.addByte(0x68);
				GetMapDescription(newPos.x - awareRange.left(), newPos.y - awareRange.top(), newPos.z, 1, awareRange.vertical());
			}
			writeToOutputBuffer(playermsg);
		}
	} else if (canSee(oldPos) && canSee(newPos)) {
		if (teleport || (oldPos.z == 12 && newPos.z >= 13) || oldStackPos >= 10) {
			sendRemoveTileThing(oldPos, oldStackPos);
			sendAddCreature(creature, newPos, newStackPos, false);
		} else {
			playermsg.reset();
			playermsg.addByte(0x6D);
			playermsg.addPosition(oldPos);
			playermsg.addByte(oldStackPos);
			playermsg.addPosition(creature->getPosition());
			playermsg.add<uint16_t>(creature->getStepDuration());

			writeToOutputBuffer(playermsg);

			checkPredictiveWalking(oldPos);
			checkPredictiveWalking(newPos);
		}
	} else if (canSee(oldPos)) {
		sendRemoveTileThing(oldPos, oldStackPos);
	} else if (canSee(newPos)) {
		sendAddCreature(creature, newPos, newStackPos, false);
	}
}

void ProtocolGame::sendInventoryItem(slots_t slot, const Item* item)
{
	playermsg.reset();
	if (item) {
		playermsg.addByte(0x78);
		playermsg.addByte(slot);
		AddItem(item);
	} else {
		playermsg.addByte(0x79);
		playermsg.addByte(slot);
	}
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_INVENTORY_LIST > 0
void ProtocolGame::sendItems(const std::map<uint32_t, PlayerInventorySellItem>& inventoryMap)
{
	playermsg.reset();
	playermsg.addByte(0xF5);

	uint16_t itemsToSend = 11;
	auto msgPosition = playermsg.getBufferPosition();
	playermsg.skipBytes(2);

	for (uint16_t i = 1; i <= 11; i++) {
		playermsg.add<uint16_t>(i);
		playermsg.addByte(0);
		playermsg.add<uint16_t>(1);
	}

	for (const auto& inventoryInfo : inventoryMap) {
		uint32_t index = inventoryInfo.first;
		uint8_t fluidType = static_cast<uint8_t>(index >> 16);

		playermsg.addItemId(static_cast<uint16_t>(index));
		playermsg.addByte((fluidType ? serverFluidToClient(fluidType) : 0));
		playermsg.addByte(inventoryInfo.second.rarity);
		playermsg.add<uint16_t>(std::min<uint32_t>(inventoryInfo.second.count, std::numeric_limits<uint16_t>::max()));

		//Limit it to upper networkmessage buffer size incase player have very large inventory
		#if CLIENT_VERSION >= 1057
		if (++itemsToSend >= 0x32F0) {
			break;
		}
		#elif CLIENT_VERSION >= 940
		if (++itemsToSend >= 0x12F0) {
			break;
		}
		#else
		if (++itemsToSend >= 0xC80) {
			break;
		}
		#endif
	}

	playermsg.setBufferPosition(msgPosition);
	playermsg.add<uint16_t>(itemsToSend);
	writeToOutputBuffer(playermsg);
}
#endif

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void ProtocolGame::sendAddContainerItem(uint8_t cid, uint16_t slot, const Item* item)
#else
void ProtocolGame::sendAddContainerItem(uint8_t cid, const Item* item)
#endif
{
	playermsg.reset();
	playermsg.addByte(0x70);
	playermsg.addByte(cid);
	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	playermsg.add<uint16_t>(slot);
	#endif
	AddItem(item);
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void ProtocolGame::sendUpdateContainerItem(uint8_t cid, uint16_t slot, const Item* item)
#else
void ProtocolGame::sendUpdateContainerItem(uint8_t cid, uint8_t slot, const Item* item)
#endif
{
	playermsg.reset();
	playermsg.addByte(0x71);
	playermsg.addByte(cid);
	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	playermsg.add<uint16_t>(slot);
	#else
	playermsg.addByte(slot);
	#endif
	AddItem(item);
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_CONTAINER_PAGINATION > 0
void ProtocolGame::sendRemoveContainerItem(uint8_t cid, uint16_t slot, const Item* lastItem)
#else
void ProtocolGame::sendRemoveContainerItem(uint8_t cid, uint8_t slot)
#endif
{
	playermsg.reset();
	playermsg.addByte(0x72);
	playermsg.addByte(cid);
	#if GAME_FEATURE_CONTAINER_PAGINATION > 0
	playermsg.add<uint16_t>(slot);
	if (lastItem) {
		AddItem(lastItem);
	} else {
		playermsg.add<uint16_t>(0x00);
	}
	#else
	playermsg.addByte(slot);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendTextWindow(uint32_t windowTextId, Item* item, uint16_t maxlen, bool canWrite)
{
	playermsg.reset();
	playermsg.addByte(0x96);
	playermsg.add<uint32_t>(windowTextId);
	AddItem(item);
	if (canWrite) {
		playermsg.add<uint16_t>(maxlen);
		playermsg.addString(item->getText());
	} else {
		const std::string& text = item->getText();
		playermsg.add<uint16_t>(text.size());
		playermsg.addString(text);
	}

	const std::string& writer = item->getWriter();
	if (!writer.empty()) {
		playermsg.addString(writer);
	} else {
		playermsg.add<uint16_t>(0x00);
	}

	#if CLIENT_VERSION >= 1250
	playermsg.addByte(0x00);//Traded
	#endif
	#if GAME_FEATURE_WRITABLE_DATE > 0
	time_t writtenDate = item->getDate();
	if (writtenDate != 0) {
		playermsg.addString(formatDateShort(writtenDate));
	} else {
		playermsg.add<uint16_t>(0x00);
	}
	#endif

	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendTextWindow(uint32_t windowTextId, uint32_t itemId, const std::string& text)
{
	playermsg.reset();
	playermsg.addByte(0x96);
	playermsg.add<uint32_t>(windowTextId);
	AddItem(itemId, 1);
	playermsg.add<uint16_t>(text.size());
	playermsg.addString(text);
	playermsg.add<uint16_t>(0x00);
	#if CLIENT_VERSION >= 1250
	playermsg.addByte(0x00);//Traded
	#endif
	#if GAME_FEATURE_WRITABLE_DATE > 0
	playermsg.add<uint16_t>(0x00);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendHouseWindow(uint32_t windowTextId, const std::string& text)
{
	playermsg.reset();
	playermsg.addByte(0x97);
	playermsg.addByte(0x00);
	playermsg.add<uint32_t>(windowTextId);
	playermsg.addString(text);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendOutfitWindow()
{
	playermsg.reset();
	playermsg.addByte(0xC8);

	Outfit_t currentOutfit = player->getDefaultOutfit();
	#if GAME_FEATURE_MOUNTS > 0
	bool mounted = false;
	Mount* currentMount = g_game.mounts.getMountByID(player->getCurrentMount());
	if (currentMount) {
		mounted = (currentOutfit.lookMount == currentMount->clientId);
		currentOutfit.lookMount = currentMount->clientId;
	}
	#endif

	AddOutfit(currentOutfit);
	Outline* outline = g_game.outlines.getOutlineByName(currentOutfit.lookOutline);
	if (outline) {
		playermsg.addString(outline->name);
	} else {
		playermsg.addString("");
	}

	#if GAME_FEATURE_FAMILIARS > 0
	playermsg.add<uint16_t>(0);
	#endif

	#if GAME_FEATURE_OUTFITS > 0
	auto startOutfits = playermsg.getBufferPosition();
	#if GAME_FEATURE_OUTFITS_U16 > 0
	uint16_t limitOutfits = std::numeric_limits<uint16_t>::max();
	uint16_t outfitSize = 0;
	playermsg.skipBytes(2);
	#else
	#if CLIENT_VERSION < 800
	uint8_t limitOutfits = 15;
	#elif CLIENT_VERSION < 870
	uint8_t limitOutfits = 25;
	#elif CLIENT_VERSION < 1062
	uint8_t limitOutfits = 50;
	#else
	uint8_t limitOutfits = std::numeric_limits<uint8_t>::max();
	#endif
	uint8_t outfitSize = 0;
	playermsg.skipBytes(1);
	#endif

	if (player->isAccessPlayer()) {
		playermsg.add<uint16_t>(75);
		playermsg.addString("Gamemaster");
		playermsg.addByte(0);
		playermsg.addByte(1);
		playermsg.addByte(0); 

		++outfitSize;

		#if CLIENT_VERSION >= 800
		playermsg.add<uint16_t>(266);
		playermsg.addString("Customer Support");
		playermsg.addByte(0);
		playermsg.addByte(1); 
		playermsg.addByte(0); 
		++outfitSize;
		#endif

		#if CLIENT_VERSION >= 830
		playermsg.add<uint16_t>(302);
		playermsg.addString("Community Manager");
		playermsg.addByte(0);
		playermsg.addByte(1); 
		playermsg.addByte(0); 
		++outfitSize;
		#endif
	}

	const auto& outfits = Outfits::getInstance().getOutfits(player->getSex());
	for (const Outfit& outfit : outfits) {
		uint8_t addons;
		bool unlocked = true;
		if (!player->getOutfitAddons(outfit, addons)) {
			if (!outfit.unlocked) {
				continue;
			}
			unlocked = false;
			addons = 3;
		}

		playermsg.add<uint16_t>(outfit.lookType);
		playermsg.addString(outfit.name);
		playermsg.addByte(addons);
		playermsg.addByte(unlocked ? 0x01 : 0x00);
		playermsg.addByte(outfit.rarity);
		if (++outfitSize == limitOutfits) {
			break;
		}
	}
	
	auto endOutfits = playermsg.getBufferPosition();
	playermsg.setBufferPosition(startOutfits);
	#if GAME_FEATURE_MOUNTS_U16 > 0
	playermsg.add<uint16_t>(outfitSize);
	#else
	playermsg.addByte(outfitSize);
	#endif
	playermsg.setBufferPosition(endOutfits);

	#if GAME_FEATURE_MOUNTS > 0
	auto startMounts = playermsg.getBufferPosition();
	#if GAME_FEATURE_MOUNTS_U16 > 0
	uint16_t limitMounts = std::numeric_limits<uint16_t>::max();
	uint16_t mountSize = 0;
	playermsg.skipBytes(2);
	#else
	#if CLIENT_VERSION < 1062
	uint8_t limitMounts = 50;
	#else
	uint8_t limitMounts = std::numeric_limits<uint8_t>::max();
	#endif
	uint8_t mountSize = 0;
	playermsg.skipBytes(1);
	#endif

	const auto& mounts = g_game.mounts.getMounts();
	for (const Mount& mount : mounts) {
		if (player->hasMount(&mount)) {
			playermsg.add<uint16_t>(mount.clientId);
			playermsg.addString(mount.name);
			#if GAME_FEATURE_OUTFITS_TYPE > 0
			playermsg.addByte(0x00);
			#endif
			if (++mountSize == limitMounts) {
				break;
			}
		}
	}

	auto endMounts = playermsg.getBufferPosition();
	playermsg.setBufferPosition(startMounts);
	#if GAME_FEATURE_MOUNTS_U16 > 0
	playermsg.add<uint16_t>(mountSize);
	#else
	playermsg.addByte(mountSize);
	#endif
	playermsg.setBufferPosition(endMounts);
	#endif
	
	uint8_t wingsSize = 0;
	auto startWings = playermsg.getBufferPosition();
	playermsg.skipBytes(1);
	for (const Wing& wing: g_game.wings.getWings()) {
		playermsg.add<uint16_t>(wing.id);
		playermsg.addString(wing.name);
		playermsg.addByte(player->hasWing(&wing) ? 0x01 : 0x00);
		playermsg.addByte(wing.rarity);
		wingsSize++;
	}
	auto endWings = playermsg.getBufferPosition();
	playermsg.setBufferPosition(startWings);
	playermsg.addByte(wingsSize);
	playermsg.setBufferPosition(endWings);

	uint8_t aurasSize = 0;
	auto startAuras = playermsg.getBufferPosition();
	playermsg.skipBytes(1);
	for (const Aura& aura : g_game.auras.getAuras()) {
		playermsg.add<uint16_t>(aura.id);
		playermsg.addString(aura.name);
		playermsg.addByte(player->hasAura(&aura) ? 0x01 : 0x00);
		playermsg.addByte(aura.rarity);
		aurasSize++;
	}
	auto aurasEnds = playermsg.getBufferPosition();
	playermsg.setBufferPosition(startAuras);
	playermsg.addByte(aurasSize);
	playermsg.setBufferPosition(aurasEnds);

	uint8_t shadersSize = 0;
	auto startShaders = playermsg.getBufferPosition();
	playermsg.skipBytes(1);
	for (const Shader& shader : g_game.shaders.getShaders()) {
		playermsg.add<uint16_t>(shader.id);
		playermsg.addString(shader.name);
		playermsg.addByte(player->hasShader(&shader) ? 0x01 : 0x00);
		playermsg.addByte(shader.rarity);
		shadersSize++;
	}
	auto shadersEnds = playermsg.getBufferPosition();
	playermsg.setBufferPosition(startShaders);
	playermsg.addByte(shadersSize);
	playermsg.setBufferPosition(shadersEnds);

	playermsg.addByte(0); // healthbars
	playermsg.addByte(0); // manabarss

	uint8_t outlinesSize = 0;
	auto startOutlines = playermsg.getBufferPosition();
	playermsg.skipBytes(1);
	for (const Outline& outline : g_game.outlines.getOutlines()) {
		playermsg.add<uint16_t>(outline.id);
		playermsg.addString(outline.name);
		playermsg.addString(outline.color);
		playermsg.addString(outline.shader);
		playermsg.addByte(player->hasOutline(&outline) ? 0x01 : 0x00);
		playermsg.addByte(outline.rarity);
		outlinesSize++;
	}
	auto outlinesEnds = playermsg.getBufferPosition();
	playermsg.setBufferPosition(startOutlines);
	playermsg.addByte(outlinesSize);
	playermsg.setBufferPosition(outlinesEnds);

	#if GAME_FEATURE_FAMILIARS > 0
	playermsg.add<uint16_t>(0);
	#endif
	
	#if GAME_FEATURE_OUTFITS_TYPE > 0
	playermsg.addByte(0x00);//Try outfit
	playermsg.addByte(mounted ? 0x01 : 0x00);
	#endif
	#else
	#if GAME_FEATURE_LOOKTYPE_U16 > 0
	playermsg.add<uint16_t>(player->sex % 2 ? 128 : 136);
	playermsg.add<uint16_t>(player->isPremium() ? (player->sex % 2 ? 134 : 142) : (player->sex % 2 ? 131 : 139));
	#else
	playermsg.addByte(player->sex % 2 ? 128 : 136);
	playermsg.addByte(player->isPremium() ? (player->sex % 2 ? 134 : 142) : (player->sex % 2 ? 131 : 139));
	#endif
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendUpdatedVIPStatus(uint32_t guid, VipStatus_t newStatus)
{
	playermsg.reset();
	#if GAME_FEATURE_VIP_STATUS > 0
	playermsg.addByte(0xD3);
	playermsg.add<uint32_t>(guid);
	playermsg.addByte(newStatus);
	#else
	playermsg.addByte(newStatus == VIPSTATUS_OFFLINE ? 0xD4 : 0xD3);
	playermsg.add<uint32_t>(guid);
	#endif
	writeToOutputBuffer(playermsg);
}

#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
void ProtocolGame::sendVIP(uint32_t guid, const std::string& name, const std::string& description, uint32_t icon, bool notify, VipStatus_t status)
#else
void ProtocolGame::sendVIP(uint32_t guid, const std::string& name, VipStatus_t status)
#endif
{
	playermsg.reset();
	playermsg.addByte(0xD2);
	playermsg.add<uint32_t>(guid);
	playermsg.addString(name);
	#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
	playermsg.addString(description);
	playermsg.add<uint32_t>(std::min<uint32_t>(10, icon));
	playermsg.addByte(notify ? 0x01 : 0x00);
	#endif
	playermsg.addByte(status);
	#if GAME_FEATURE_VIP_GROUPS > 0
	playermsg.addByte(0x00);
	#endif
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendVIPEntries()
{
	std::stringExtended query(256);
	#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
	query << "SELECT `player_id`, (SELECT `name` FROM `players` WHERE `id` = `player_id`) AS `name`, `description`, `icon`, `notify` FROM `account_viplist` WHERE `account_id` = " << player->getAccount();
	#else
	query << "SELECT `player_id`, (SELECT `name` FROM `players` WHERE `id` = `player_id`) AS `name` FROM `account_viplist` WHERE `account_id` = " << player->getAccount();
	#endif

	using ProtocolGameWeak_ptr = std::weak_ptr<ProtocolGame>;
	ProtocolGameWeak_ptr protocolGameWeak = std::weak_ptr<ProtocolGame>(getThis());

	std::function<void(DBResult_ptr, bool, uint64_t)> callback = [protocolGameWeak](DBResult_ptr result, bool, uint64_t) {
		if (auto client = protocolGameWeak.lock()) {
			if (result && !client->isConnectionExpired() && client->player) {
				do {
					VipStatus_t vipStatus = VIPSTATUS_ONLINE;
					uint32_t vipGuid = result->getNumber<uint32_t>("player_id");

					Player* vipPlayer = g_game.getPlayerByGUID(vipGuid);
					if (!vipPlayer || vipPlayer->isInGhostMode() || client->player->isAccessPlayer()) {
						vipStatus = VIPSTATUS_OFFLINE;
					}

					#if GAME_FEATURE_ADDITIONAL_VIPINFO > 0
					client->sendVIP(vipGuid, result->getString("name"), result->getString("description"), result->getNumber<uint32_t>("icon"), (result->getNumber<uint16_t>("notify") != 0), vipStatus);
					#else
					client->sendVIP(vipGuid, result->getString("name"), vipStatus);
					#endif
				} while (result->next());
			}
		}
	};
	g_databaseTasks.addTask(std::move(static_cast<std::string&>(query)), callback, true);
}

void ProtocolGame::sendAnimatedText(const std::string& message, const Position& pos, TextColor_t color, const std::string& font)
{
    if (!canSee(pos)) {
        return;
    }

	playermsg.reset();
	playermsg.addByte(0x84);
	playermsg.addPosition(pos);
	playermsg.addByte(color);
	playermsg.addString(font);
	playermsg.addString(message);
    writeToOutputBuffer(playermsg);
}

#if CLIENT_VERSION >= 870
void ProtocolGame::sendSpellCooldown(uint8_t spellId, uint32_t time)
{
	playermsg.reset();
	playermsg.addByte(0xA4);
	#if CLIENT_VERSION >= 1121
	if (spellId >= 170) {
		spellId = 150;
	}
	#endif
	playermsg.addByte(spellId);
	playermsg.add<uint32_t>(time);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendSpellGroupCooldown(SpellGroup_t groupId, uint32_t time)
{
	playermsg.reset();
	playermsg.addByte(0xA5);
	playermsg.addByte(groupId);
	playermsg.add<uint32_t>(time);
	writeToOutputBuffer(playermsg);
}
#endif

#if CLIENT_VERSION >= 960
void ProtocolGame::sendModalWindow(const ModalWindow& modalWindow)
{
	playermsg.reset();
	playermsg.addByte(0xFA);

	playermsg.add<uint32_t>(modalWindow.id);
	playermsg.addString(modalWindow.title);
	playermsg.addString(modalWindow.message);

	playermsg.addByte(modalWindow.buttons.size());
	for (const auto& it : modalWindow.buttons) {
		playermsg.addString(it.first);
		playermsg.addByte(it.second);
	}

	#if CLIENT_VERSION >= 970
	playermsg.addByte(modalWindow.choices.size());
	for (const auto& it : modalWindow.choices) {
		playermsg.addString(it.first);
		playermsg.addByte(it.second);
	}
	#endif

	OperatingSystem_t regularOS = player->getOperatingSystem();
	if (regularOS >= CLIENTOS_NEW_LINUX && regularOS < CLIENTOS_OTCLIENT_LINUX) {
		playermsg.addByte(modalWindow.defaultEnterButton);
		playermsg.addByte(modalWindow.defaultEscapeButton);
	} else {
		playermsg.addByte(modalWindow.defaultEscapeButton);
		playermsg.addByte(modalWindow.defaultEnterButton);
	}
	#if CLIENT_VERSION >= 970
	playermsg.addByte(modalWindow.priority ? 0x01 : 0x00);
	#endif

	writeToOutputBuffer(playermsg);
}
#endif

////////////// Add common messages
void ProtocolGame::AddCreature(const Creature* creature, bool known, uint32_t remove)
{
	CreatureType_t creatureType = creature->getType();
	if (creature->isHealthHidden()) {
		creatureType = CREATURETYPE_HIDDEN;
	}

	const Player* otherPlayer = creature->getPlayer();
	if (known) {
		playermsg.add<uint16_t>(0x62);
		playermsg.add<uint32_t>(creature->getID());
	} else {
		playermsg.add<uint16_t>(0x61);
		playermsg.add<uint32_t>(remove);
		playermsg.add<uint32_t>(creature->getID());
		playermsg.addByte(creatureType);
		if (creatureType == CREATURETYPE_HIDDEN) {
			playermsg.addString(std::string());
		} else {
			playermsg.addString(creature->getName());
		}
		playermsg.addString(creature->getTitleText());
		playermsg.addString(creature->getTitleFont());
		playermsg.addString(creature->getTitleColor());
		playermsg.addByte(creature->isFlying());
	}

	#if CLIENT_VERSION >= 1121
	if (creatureType == CREATURETYPE_HIDDEN && creature != player) {
		playermsg.addByte(0x00);
	} else {
		playermsg.addByte(std::ceil((static_cast<double>(creature->getHealth()) / std::max<int64_t>(creature->getMaxHealth(), 1)) * 100));
		playermsg.addByte(std::ceil((static_cast<double>(creature->getEnergyShield()) / std::max<int64_t>(creature->getMaxEnergyShield(), 1)) * 100));
	}
	#else
	if (creatureType == CREATURETYPE_HIDDEN) {
		playermsg.addByte(0x00);
	} else {
		playermsg.addByte(std::ceil((static_cast<double>(creature->getHealth()) / std::max<int64_t>(creature->getMaxHealth(), 1)) * 100));
		playermsg.addByte(std::ceil((static_cast<double>(creature->getEnergyShield()) / std::max<int64_t>(creature->getMaxEnergyShield(), 1)) * 100));
	}
	#endif

	playermsg.addByte(creature->getDirection());
	if (!creature->isInGhostMode() && !creature->isInvisible()) {
		const Outfit_t& outfit = creature->getCurrentOutfit();
		AddOutfit(outfit);
	} else {
		static Outfit_t outfit;
		AddOutfit(outfit);
	}

	LightInfo lightInfo = creature->getCreatureLight();
	playermsg.addByte(player->isAccessPlayer() ? 0xFF : lightInfo.level);
	playermsg.addByte(lightInfo.color);

	#if GAME_FEATURE_NEWSPEED_LAW > 0
	playermsg.add<uint16_t>(creature->getStepSpeed() / 2);
	#else
	playermsg.add<uint16_t>(creature->getStepSpeed());
	#endif

	#if GAME_FEATURE_STATE_ICONS > 0
	playermsg.addByte(0);
	#endif

	playermsg.addByte(player->getSkullClient(creature));
	std::map<uint8_t, uint8_t> auras = creature->getActiveAuras();
	playermsg.addByte(auras.size());
	for (const auto& aura : auras) {
		playermsg.addByte(aura.first);
		playermsg.addByte(aura.second);
	}

	playermsg.addByte(player->getPartyShield(otherPlayer));
	#if GAME_FEATURE_GUILD_EMBLEM > 0
	if (!known) {
		playermsg.addByte(player->getGuildEmblem(otherPlayer));
	}
	#endif

	#if GAME_FEATURE_CREATURE_TYPE > 0
	if (creatureType == CREATURETYPE_MONSTER) {
		const Creature* master = creature->getMaster();
		if (master) {
			const Player* masterPlayer = master->getPlayer();
			if (masterPlayer) {
				if (masterPlayer == player) {
					creatureType = CREATURETYPE_SUMMON_OWN;
				} else {
					creatureType = CREATURETYPE_SUMMON_OTHERS;
				}
			}
		}
	}

	#if CLIENT_VERSION >= 1121
	if (creatureType == CREATURETYPE_SUMMON_OTHERS) {
		creatureType = CREATURETYPE_SUMMON_OWN;
	}
	playermsg.addByte(creatureType);
	if (creatureType == CREATURETYPE_SUMMON_OWN) {
		const Creature* master = creature->getMaster();
		if (master) {
			playermsg.add<uint32_t>(master->getID());
		} else {
			playermsg.add<uint32_t>(0);
		}
	}
	#else
	playermsg.addByte(creatureType); // Type (for summons)
	#endif
	#endif

	#if GAME_FEATURE_CREATURE_ICONS > 0
	playermsg.addByte(creature->getSpeechBubble());
	#endif
	#if GAME_FEATURE_CREATURE_MARK > 0
	playermsg.addByte(0xFF); // MARK_UNMARKED
	#endif
	#if GAME_FEATURE_INSPECTION > 0
	playermsg.addByte(0); // inspection type
	#endif

	#if CLIENT_VERSION >= 1000 && CLIENT_VERSION < 1185
	if (otherPlayer) {
		playermsg.add<uint16_t>(otherPlayer->getHelpers());
	} else {
		playermsg.add<uint16_t>(0x00);
	}
	#endif

	#if CLIENT_VERSION >= 854
	playermsg.addByte(player->canWalkthroughEx(creature) ? 0x00 : 0x01);
	#endif
}

void ProtocolGame::AddPlayerStats(uint8_t type)
{
	playermsg.addByte(0xA0);

	playermsg.addByte(type);
	if (type == 1) {
		playermsg.add<uint32_t>(player->getHealth());
		playermsg.add<uint32_t>(player->getMaxHealth());
		playermsg.add<uint32_t>(player->getRealMaxHealth());	
	} else if (type == 2) {
		playermsg.add<uint32_t>(player->getEnergyShield());
		playermsg.add<uint32_t>(player->getMaxEnergyShield());
	} else if (type == 3) {
		playermsg.add<uint64_t>(player->getExperience());
		playermsg.add<uint32_t>(player->getLevel());
		playermsg.addByte(player->getLevelPercent());
	} else if (type == 4) {
		playermsg.add<uint32_t>(player->getMana());
		playermsg.add<uint32_t>(player->getMaxMana());
		playermsg.add<uint32_t>(player->getRealMaxMana());
	}
}

void ProtocolGame::AddPlayerSkills()
{
	playermsg.addByte(0xA1);
	#if CLIENT_VERSION >= 1200
	playermsg.add<uint16_t>(player->getMagicLevel());
	playermsg.add<uint16_t>(player->getBaseMagicLevel());
	playermsg.add<uint16_t>(player->getBaseMagicLevel());//loyalty bonus
	playermsg.add<uint16_t>(player->getMagicLevelPercent() * 100);
	#endif

	for (uint8_t i = SKILL_FIRST; i <= SKILL_LAST; ++i) {
		#if GAME_FEATURE_DOUBLE_SKILLS > 0
		playermsg.add<uint16_t>(player->getSkillLevel(i));
		#else
		playermsg.add<uint8_t>(std::min<uint16_t>(player->getSkillLevel(i), std::numeric_limits<uint8_t>::max()));
		#endif

		#if GAME_FEATURE_BASE_SKILLS > 0
		#if GAME_FEATURE_DOUBLE_SKILLS > 0
		playermsg.add<uint16_t>(player->getBaseSkill(i));
		#else
		playermsg.add<uint8_t>(std::min<uint16_t>(player->getBaseSkill(i), std::numeric_limits<uint8_t>::max()));
		#endif
		#endif

		#if GAME_FEATURE_DOUBLE_PERCENT_SKILLS > 0
		playermsg.add<uint16_t>(player->getBaseSkill(i));//loyalty bonus
		playermsg.add<uint16_t>(static_cast<uint16_t>(player->getSkillPercent(i)) * 100);
		#else
		playermsg.addByte(player->getSkillPercent(i));
		#endif
	}

	#if GAME_FEATURE_ADDITIONAL_SKILLS > 0
	for (uint8_t i = SPECIALSKILL_FIRST; i <= SPECIALSKILL_LAST; ++i) {
		#if GAME_FEATURE_DOUBLE_SKILLS > 0
		int32_t amount = player->varSpecialSkills[i];
		if (i == SPECIALSKILL_CRITICALHITAMOUNT) {
			playermsg.add<uint16_t>(std::min<int32_t>(std::numeric_limits<uint16_t>::max(), amount));
		}
		else {
			playermsg.add<uint16_t>(std::min<int32_t>(100, amount));
		}
		#else
		playermsg.add<uint8_t>(std::min<int32_t>(100, player->varSpecialSkills[i]));
		#endif
		
		#if GAME_FEATURE_BASE_SKILLS > 0
		#if GAME_FEATURE_DOUBLE_SKILLS > 0
		playermsg.add<uint16_t>(0);
		#else
		playermsg.add<uint8_t>(0);
		#endif
		#endif
	}
	#endif

	#if CLIENT_VERSION >= 1150
	playermsg.add<uint32_t>(player->getCapacity());
	playermsg.add<uint32_t>(player->getCapacity());
	#endif
}

void ProtocolGame::AddOutfit(const Outfit_t& outfit)
{
	playermsg.add<uint16_t>(outfit.lookType);

	if (outfit.lookType != 0) {
		playermsg.addByte(outfit.lookHead);
		playermsg.addByte(outfit.lookBody);
		playermsg.addByte(outfit.lookLegs);
		playermsg.addByte(outfit.lookFeet);
		playermsg.addByte(outfit.lookAddons);
	} else {
		playermsg.addItemId(outfit.lookTypeEx);
	}

	playermsg.add<uint16_t>(outfit.lookMount);
	playermsg.add<uint16_t>(outfit.lookWings);
	playermsg.add<uint16_t>(outfit.lookAura);
	playermsg.addString(outfit.lookShader);
	playermsg.add<uint16_t>(outfit.lookHealthBar);
	playermsg.add<uint16_t>(outfit.lookManaBar);
	Outline* outline = g_game.outlines.getOutlineByName(outfit.lookOutline);
	if (outline) {
		playermsg.addString(outline->shader);
		playermsg.addString(outline->color);
	} else {
		playermsg.addString("");
	}
}

void ProtocolGame::AddWorldLight(LightInfo lightInfo)
{
	playermsg.addByte(0x82);
	playermsg.addByte((player->isAccessPlayer() ? 0xFF : lightInfo.level));
	playermsg.addByte(lightInfo.color);
}

void ProtocolGame::AddCreatureLight(const Creature* creature)
{
	LightInfo lightInfo = creature->getCreatureLight();

	playermsg.addByte(0x8D);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.addByte((player->isAccessPlayer() ? 0xFF : lightInfo.level));
	playermsg.addByte(lightInfo.color);
}

//tile
void ProtocolGame::RemoveTileThing(const Position& pos, uint32_t stackpos)
{
	if (stackpos >= 10) {
		return;
	}

	playermsg.addByte(0x6C);
	playermsg.addPosition(pos);
	playermsg.addByte(stackpos);
}

void ProtocolGame::parseChangeAwareRange(NetworkMessage& msg)
{
	uint8_t width = msg.get<uint8_t>();
	uint8_t height = msg.get<uint8_t>();

	g_dispatcher.addTask(std::bind(&ProtocolGame::updateAwareRange, getThis(), width, height));
}

void ProtocolGame::updateAwareRange(int width, int height)
{
	// If you want to change max awareRange, edit maxViewportX, maxViewportY, maxClientViewportX, maxClientViewportY in map.h
	awareRange.width = std::min(Map::maxViewportX * 2 - 1, std::min(Map::maxClientViewportX * 2 + 1, std::max(15, width)));
	awareRange.height = std::min(Map::maxViewportY * 2 - 1, std::min(Map::maxClientViewportY * 2 + 1, std::max(11, height)));
	// numbers must be odd
	if (awareRange.width % 2 != 1)
		awareRange.width -= 1;
	if (awareRange.height % 2 != 1)
		awareRange.height -= 1;

	sendAwareRange();
	sendMapDescription(player->getPosition()); // refresh map
}

void ProtocolGame::sendAwareRange()
{
	NetworkMessage msg;
	msg.addByte(0x42);
	msg.add<uint8_t>(awareRange.width);
	msg.add<uint8_t>(awareRange.height);
	writeToOutputBuffer(msg);
}

void ProtocolGame::AddShopItem(const ShopInfo& item)
{
	const ItemType& it = Item::items[item.itemId];
	playermsg.add<uint16_t>(it.clientId);
	if (it.isSplash() || it.isFluidContainer()) {
		playermsg.addByte(serverFluidToClient(item.subType));
	} else {
		playermsg.addByte(0x00);
	}

	playermsg.addString(item.realName);
	playermsg.add<uint32_t>(it.color);
	playermsg.add<uint32_t>(item.buyPrice);
	playermsg.add<uint32_t>(item.sellPrice);
}

void ProtocolGame::AddItem(uint16_t id, uint16_t count)
{
	const ItemType& it = Item::items[id];

	playermsg.add<uint16_t>(it.clientId);
	#if GAME_FEATURE_ITEM_MARK > 0
	playermsg.addByte(0xFF); // MARK_UNMARKED
	#endif

	if (it.stackable) {
		playermsg.add<uint16_t>(count);
	} else if (it.isSplash() || it.isFluidContainer()) {
		playermsg.add<uint16_t>(serverFluidToClient(count));
	}

	#if GAME_FEATURE_QUICK_LOOT > 0
	if (it.isContainer()) {
		playermsg.addByte(0);
	}
	#endif

	#if GAME_FEATURE_ITEM_ANIMATION_PHASES > 0
	if (it.isAnimation) {
		playermsg.addByte(0xFE); // random phase (0xFF for async)
	}
	#endif

	playermsg.add<uint16_t>(0x00);
}

void ProtocolGame::AddItem(const Item* item)
{
	const ItemType& it = Item::items[item->getID()];

	playermsg.add<uint16_t>(it.clientId);
	#if GAME_FEATURE_ITEM_MARK > 0
	playermsg.addByte(0xFF); // MARK_UNMARKED
	#endif
	
	if (it.stackable) {
		playermsg.add<uint16_t>(item->getItemCount());
	} else if (it.isSplash() || it.isFluidContainer()) {
		playermsg.add<uint16_t>(serverFluidToClient(item->getFluidType()));
	}

	#if GAME_FEATURE_QUICK_LOOT > 0
	if (it.isContainer()) {
		playermsg.addByte(0);
	}
	#endif

	#if GAME_FEATURE_ITEM_ANIMATION_PHASES > 0
	if (it.isAnimation) {
		playermsg.addByte(0xFE); // random phase (0xFF for async)
	}
	#endif

	if (item->isPickupable() && item->isMoveable()) {
		auto itemTemp = const_cast<Item*>(item);
		uint16_t size = 0;
		auto rarity = itemTemp->getCustomAttribute("rarity");
		auto exalted = itemTemp->getCustomAttribute("Exa");
		auto mirror = itemTemp->getCustomAttribute("mirrored");
		auto locked = itemTemp->getCustomAttribute("locked");
		uint32_t realUID = itemTemp->getRealUID();
		uint16_t spellGem = itemTemp->getSpellGemId();
		uint16_t potionId = itemTemp->getPotionId();
		int32_t slotPosition = itemTemp->getSlotPosition();
		uint16_t color = itemTemp->getColor();


		if (rarity) {
			size++;
		}

		if (mirror) {
			size++;
		}
		if (locked) {
			size++;
		}

		if (realUID > 0) {
			size++;
		}

		if (spellGem > 0) {
			size++;
		}
		
		if (potionId > 0) {
			size++;
		}

		if (slotPosition > 0) {
			size++;
		}

		if (color > 0) {
			size++;
		}
	
		playermsg.add<uint16_t>(size);
		if (rarity) {
			playermsg.add<uint16_t>(1);
			uint64_t rarityValue = rarity->getInt();
			if (exalted) {
				rarityValue = 6;
			}
			playermsg.add<uint64_t>(rarityValue);
		}
		if (locked) {
			playermsg.add<uint16_t>(2);
			playermsg.add<uint64_t>(locked->getInt());
		}
		if (mirror) {
			playermsg.add<uint16_t>(4);
			playermsg.add<uint64_t>(mirror->getInt());
		}
		if (realUID > 0) {
			playermsg.add<uint16_t>(5);
			playermsg.add<uint64_t>(realUID);
		}
		if (spellGem > 0) {
			playermsg.add<uint16_t>(6);
			playermsg.add<uint64_t>(spellGem);
		}
		if (potionId > 0) {
			playermsg.add<uint16_t>(7);
			playermsg.add<uint64_t>(potionId);
		}
		if (slotPosition > 0) {
			playermsg.add<uint16_t>(8);
			playermsg.add<uint64_t>(slotPosition);
		}

		if (color > 0) {
			playermsg.add<uint16_t>(9);
			playermsg.add<uint64_t>(color);
		}
	}
	else {
		playermsg.add<uint16_t>(0x00);
	}
}

void ProtocolGame::parseExtendedOpcode(NetworkMessage& msg)
{
	uint8_t opcode = msg.getByte();
	const std::string buffer = msg.getString();

	// process additional opcodes via lua script event
	g_game.playerExtendedOpcode(player, opcode, buffer);
}

SpeakClasses ProtocolGame::translateSpeakClassFromClient(uint8_t talkType)
{
	#if CLIENT_VERSION >= 1055
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x04: return TALKTYPE_PRIVATE_FROM;
		case 0x05: return TALKTYPE_PRIVATE_TO;
		case 0x06: return TALKTYPE_CHANNEL_M;
		case 0x07: return TALKTYPE_CHANNEL_Y;
		case 0x08: return TALKTYPE_CHANNEL_O;
		case 0x09: return TALKTYPE_SPELL;
		case 0x0A: return TALKTYPE_PRIVATE_NP;
		case 0x0C: return TALKTYPE_PRIVATE_PN;
		case 0x0D: return TALKTYPE_BROADCAST;
		case 0x0E: return TALKTYPE_CHANNEL_R1;
		case 0x0F: return TALKTYPE_PRIVATE_RED_FROM;
		case 0x10: return TALKTYPE_PRIVATE_RED_TO;
		case 0x24: return TALKTYPE_MONSTER_SAY;
		case 0x25: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 1036
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x04: return TALKTYPE_PRIVATE_FROM;
		case 0x05: return TALKTYPE_PRIVATE_TO;
		case 0x06: return TALKTYPE_CHANNEL_M;
		case 0x07: return TALKTYPE_CHANNEL_Y;
		case 0x08: return TALKTYPE_CHANNEL_O;
		case 0x09: return TALKTYPE_SPELL;
		case 0x0A: return TALKTYPE_PRIVATE_NP;
		case 0x0C: return TALKTYPE_PRIVATE_PN;
		case 0x0D: return TALKTYPE_BROADCAST;
		case 0x0E: return TALKTYPE_CHANNEL_R1;
		case 0x0F: return TALKTYPE_PRIVATE_RED_FROM;
		case 0x10: return TALKTYPE_PRIVATE_RED_TO;
		case 0x23: return TALKTYPE_MONSTER_SAY;
		case 0x24: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 900
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x04: return TALKTYPE_PRIVATE_FROM;
		case 0x05: return TALKTYPE_PRIVATE_TO;
		case 0x06: return TALKTYPE_CHANNEL_M;
		case 0x07: return TALKTYPE_CHANNEL_Y;
		case 0x08: return TALKTYPE_CHANNEL_O;
		case 0x09: return TALKTYPE_SPELL;
		case 0x0A: return TALKTYPE_PRIVATE_NP;
		case 0x0B: return TALKTYPE_PRIVATE_PN;
		case 0x0C: return TALKTYPE_BROADCAST;
		case 0x0D: return TALKTYPE_CHANNEL_R1;
		case 0x0E: return TALKTYPE_PRIVATE_RED_FROM;
		case 0x0F: return TALKTYPE_PRIVATE_RED_TO;
		case 0x22: return TALKTYPE_MONSTER_SAY;
		case 0x23: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 861
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x06: return TALKTYPE_PRIVATE_TO;
		case 0x08: return TALKTYPE_CHANNEL_M;
		case 0x07: return TALKTYPE_CHANNEL_Y;
		case 0x0C: return TALKTYPE_CHANNEL_O;
		case 0x05: return TALKTYPE_PRIVATE_NP;
		case 0x04: return TALKTYPE_PRIVATE_PN;
		case 0x09: return TALKTYPE_BROADCAST;
		case 0x0A: return TALKTYPE_CHANNEL_R1;
		case 0x0B: return TALKTYPE_PRIVATE_RED_TO;
		case 0x0D: return TALKTYPE_MONSTER_SAY;
		case 0x0E: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 840
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x06: return TALKTYPE_PRIVATE_TO;
		case 0x08: return TALKTYPE_CHANNEL_M;
		case 0x07: return TALKTYPE_CHANNEL_Y;
		case 0x0F: return TALKTYPE_CHANNEL_O;
		case 0x09: return TALKTYPE_RVR_CHANNEL;
		case 0x0A: return TALKTYPE_RVR_ANSWER;
		case 0x0B: return TALKTYPE_RVR_CONTINUE;
		case 0x05: return TALKTYPE_PRIVATE_NP;
		case 0x04: return TALKTYPE_PRIVATE_PN;
		case 0x0C: return TALKTYPE_BROADCAST;
		case 0x0D: return TALKTYPE_CHANNEL_R1;
		case 0x0E: return TALKTYPE_PRIVATE_RED_TO;
		case 0x13: return TALKTYPE_MONSTER_SAY;
		case 0x14: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 820
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x06: return TALKTYPE_PRIVATE_TO;
		case 0x07: return TALKTYPE_CHANNEL_Y;
		case 0x0E: return TALKTYPE_CHANNEL_O;
		case 0x08: return TALKTYPE_RVR_CHANNEL;
		case 0x09: return TALKTYPE_RVR_ANSWER;
		case 0x0A: return TALKTYPE_RVR_CONTINUE;
		case 0x05: return TALKTYPE_PRIVATE_NP;
		case 0x04: return TALKTYPE_PRIVATE_PN;
		case 0x0B: return TALKTYPE_BROADCAST;
		case 0x0C: return TALKTYPE_CHANNEL_R1;
		case 0x0D: return TALKTYPE_PRIVATE_RED_TO;
		case 0x12: return TALKTYPE_MONSTER_SAY;
		case 0x13: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 723
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x04: return TALKTYPE_PRIVATE_TO;
		case 0x05: return TALKTYPE_CHANNEL_Y;
		case 0x0C: return TALKTYPE_CHANNEL_O;
		case 0x06: return TALKTYPE_RVR_CHANNEL;
		case 0x07: return TALKTYPE_RVR_ANSWER;
		case 0x08: return TALKTYPE_RVR_CONTINUE;
		case 0x09: return TALKTYPE_BROADCAST;
		case 0x0A: return TALKTYPE_CHANNEL_R1;
		case 0x0B: return TALKTYPE_PRIVATE_RED_TO;
		case 0x10: return TALKTYPE_MONSTER_SAY;
		case 0x11: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 710
	switch (talkType) {
		case 0x01: return TALKTYPE_SAY;
		case 0x02: return TALKTYPE_WHISPER;
		case 0x03: return TALKTYPE_YELL;
		case 0x04: return TALKTYPE_PRIVATE_TO;
		case 0x05: return TALKTYPE_CHANNEL_Y;
		case 0x06: return TALKTYPE_RVR_CHANNEL;
		case 0x07: return TALKTYPE_RVR_ANSWER;
		case 0x08: return TALKTYPE_RVR_CONTINUE;
		case 0x09: return TALKTYPE_BROADCAST;
		case 0x0A: return TALKTYPE_PRIVATE_RED_TO;
		case 0x0D: return TALKTYPE_MONSTER_SAY;
		case 0x0E: return TALKTYPE_MONSTER_YELL;
		default: return TALKTYPE_NONE;
	}
	#endif
}

uint8_t ProtocolGame::translateSpeakClassToClient(SpeakClasses talkType)
{
	#if CLIENT_VERSION >= 1055
	#if CLIENT_VERSION >= 1200
	if (talkType == TALKTYPE_BOOSTED_CREATURE) {
		return 0x31;
	}
	#endif
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x04;
		case TALKTYPE_PRIVATE_TO: return 0x05;
		case TALKTYPE_CHANNEL_M: return 0x06;
		case TALKTYPE_CHANNEL_Y: return 0x07;
		case TALKTYPE_CHANNEL_O: return 0x08;
		case TALKTYPE_SPELL: return 0x09;
		case TALKTYPE_PRIVATE_NP: return 0x0A;
		case TALKTYPE_PRIVATE_PN: return 0x0C;
		case TALKTYPE_BROADCAST: return 0x0D;
		case TALKTYPE_CHANNEL_R1: return 0x0E;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0F;
		case TALKTYPE_PRIVATE_RED_TO: return 0x10;
		case TALKTYPE_MONSTER_SAY: return 0x24;
		case TALKTYPE_MONSTER_YELL: return 0x25;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 1036
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x04;
		case TALKTYPE_PRIVATE_TO: return 0x05;
		case TALKTYPE_CHANNEL_M: return 0x06;
		case TALKTYPE_CHANNEL_Y: return 0x07;
		case TALKTYPE_CHANNEL_O: return 0x08;
		case TALKTYPE_SPELL: return 0x09;
		case TALKTYPE_PRIVATE_NP: return 0x0A;
		case TALKTYPE_PRIVATE_PN: return 0x0C;
		case TALKTYPE_BROADCAST: return 0x0D;
		case TALKTYPE_CHANNEL_R1: return 0x0E;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0F;
		case TALKTYPE_PRIVATE_RED_TO: return 0x10;
		case TALKTYPE_MONSTER_SAY: return 0x23;
		case TALKTYPE_MONSTER_YELL: return 0x24;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 900
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x04;
		case TALKTYPE_PRIVATE_TO: return 0x05;
		case TALKTYPE_CHANNEL_M: return 0x06;
		case TALKTYPE_CHANNEL_Y: return 0x07;
		case TALKTYPE_CHANNEL_O: return 0x08;
		case TALKTYPE_SPELL: return 0x09;
		case TALKTYPE_PRIVATE_NP: return 0x0A;
		case TALKTYPE_PRIVATE_PN: return 0x0B;
		case TALKTYPE_BROADCAST: return 0x0C;
		case TALKTYPE_CHANNEL_R1: return 0x0D;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0E;
		case TALKTYPE_PRIVATE_RED_TO: return 0x0F;
		case TALKTYPE_MONSTER_SAY: return 0x22;
		case TALKTYPE_MONSTER_YELL: return 0x23;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 861
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x06;
		case TALKTYPE_PRIVATE_TO: return 0x06;
		case TALKTYPE_CHANNEL_M: return 0x08;
		case TALKTYPE_CHANNEL_Y: return 0x07;
		case TALKTYPE_CHANNEL_O: return 0x0C;
		case TALKTYPE_SPELL: return 0x01;
		case TALKTYPE_PRIVATE_NP: return 0x05;
		case TALKTYPE_PRIVATE_PN: return 0x04;
		case TALKTYPE_BROADCAST: return 0x09;
		case TALKTYPE_CHANNEL_R1: return 0x0A;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0B;
		case TALKTYPE_PRIVATE_RED_TO: return 0x0B;
		case TALKTYPE_MONSTER_SAY: return 0x0D;
		case TALKTYPE_MONSTER_YELL: return 0x0E;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 840
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x06;
		case TALKTYPE_PRIVATE_TO: return 0x06;
		case TALKTYPE_CHANNEL_M: return 0x08;
		case TALKTYPE_CHANNEL_Y: return 0x07;
		case TALKTYPE_CHANNEL_O: return 0x0F;
		case TALKTYPE_RVR_CHANNEL: return 0x09;
		case TALKTYPE_RVR_ANSWER: return 0x0A;
		case TALKTYPE_RVR_CONTINUE: return 0x0B;
		case TALKTYPE_SPELL: return 0x01;
		case TALKTYPE_PRIVATE_NP: return 0x05;
		case TALKTYPE_PRIVATE_PN: return 0x04;
		case TALKTYPE_BROADCAST: return 0x0C;
		case TALKTYPE_CHANNEL_R1: return 0x0D;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0E;
		case TALKTYPE_PRIVATE_RED_TO: return 0x0E;
		case TALKTYPE_MONSTER_SAY: return 0x13;
		case TALKTYPE_MONSTER_YELL: return 0x14;
		case TALKTYPE_CHANNEL_R2: return TALKTYPE_NONE;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 820
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x06;
		case TALKTYPE_PRIVATE_TO: return 0x06;
		case TALKTYPE_CHANNEL_M: return 0x07;
		case TALKTYPE_CHANNEL_Y: return 0x07;
		case TALKTYPE_CHANNEL_O: return 0x0E;
		case TALKTYPE_RVR_CHANNEL: return 0x08;
		case TALKTYPE_RVR_ANSWER: return 0x09;
		case TALKTYPE_RVR_CONTINUE: return 0x0A;
		case TALKTYPE_SPELL: return 0x01;
		case TALKTYPE_PRIVATE_NP: return 0x05;
		case TALKTYPE_PRIVATE_PN: return 0x04;
		case TALKTYPE_BROADCAST: return 0x0B;
		case TALKTYPE_CHANNEL_R1: return 0x0C;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0D;
		case TALKTYPE_PRIVATE_RED_TO: return 0x0D;
		case TALKTYPE_MONSTER_SAY: return 0x12;
		case TALKTYPE_MONSTER_YELL: return 0x13;
		case TALKTYPE_CHANNEL_R2: return TALKTYPE_NONE;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 723
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x04;
		case TALKTYPE_PRIVATE_TO: return 0x04;
		case TALKTYPE_CHANNEL_M: return 0x05;
		case TALKTYPE_CHANNEL_Y: return 0x05;
		case TALKTYPE_CHANNEL_O: return 0x0C;
		case TALKTYPE_RVR_CHANNEL: return 0x06;
		case TALKTYPE_RVR_ANSWER: return 0x07;
		case TALKTYPE_RVR_CONTINUE: return 0x08;
		case TALKTYPE_SPELL: return 0x01;
		case TALKTYPE_PRIVATE_NP: return 0x01;
		case TALKTYPE_PRIVATE_PN: return 0x01;
		case TALKTYPE_BROADCAST: return 0x09;
		case TALKTYPE_CHANNEL_R1: return 0x0A;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0B;
		case TALKTYPE_PRIVATE_RED_TO: return 0x0B;
		case TALKTYPE_MONSTER_SAY: return 0x10;
		case TALKTYPE_MONSTER_YELL: return 0x11;
		case TALKTYPE_CHANNEL_R2: return TALKTYPE_NONE;
		default: return TALKTYPE_NONE;
	}
	#elif CLIENT_VERSION >= 710
	switch (talkType) {
		case TALKTYPE_SAY: return 0x01;
		case TALKTYPE_WHISPER: return 0x02;
		case TALKTYPE_YELL: return 0x03;
		case TALKTYPE_PRIVATE_FROM: return 0x04;
		case TALKTYPE_PRIVATE_TO: return 0x04;
		case TALKTYPE_CHANNEL_M: return 0x05;
		case TALKTYPE_CHANNEL_Y: return 0x05;
		case TALKTYPE_CHANNEL_O: return 0x05;
		case TALKTYPE_RVR_CHANNEL: return 0x06;
		case TALKTYPE_RVR_ANSWER: return 0x07;
		case TALKTYPE_RVR_CONTINUE: return 0x08;
		case TALKTYPE_SPELL: return 0x01;
		case TALKTYPE_PRIVATE_NP: return 0x01;
		case TALKTYPE_PRIVATE_PN: return 0x01;
		case TALKTYPE_BROADCAST: return 0x09;
		case TALKTYPE_CHANNEL_R1: return 0x05;
		case TALKTYPE_PRIVATE_RED_FROM: return 0x0A;
		case TALKTYPE_PRIVATE_RED_TO: return 0x0A;
		case TALKTYPE_MONSTER_SAY: return 0x0D;
		case TALKTYPE_MONSTER_YELL: return 0x0E;
		case TALKTYPE_CHANNEL_R2: return TALKTYPE_NONE;
		default: return TALKTYPE_NONE;
	}
	#endif
}

uint8_t ProtocolGame::translateMessageClassToClient(MessageClasses messageType)
{
	#if CLIENT_VERSION >= 1055
	#if CLIENT_VERSION >= 1094
	if (messageType == MESSAGE_MANA) {
		return 0x2B;
	}
	#endif
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x04;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x0D;
		case MESSAGE_STATUS_DEFAULT: return 0x11;
		case MESSAGE_STATUS_WARNING: return 0x12;
		case MESSAGE_EVENT_ADVANCE: return 0x13;
		case MESSAGE_STATUS_SMALL: return 0x15;
		case MESSAGE_INFO_DESCR: return 0x16;
		case MESSAGE_EVENT_DEFAULT: return 0x1E;
		case MESSAGE_GUILD: return 0x21;
		case MESSAGE_PARTY_MANAGEMENT: return 0x22;
		case MESSAGE_PARTY: return 0x23;
		case MESSAGE_EVENT_ORANGE: return 0x24;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x25;
		case MESSAGE_DAMAGE_DEALT: return 0x17;
		case MESSAGE_DAMAGE_RECEIVED: return 0x18;
		case MESSAGE_MANA: return 0x19;
		case MESSAGE_HEALED: return 0x19;
		case MESSAGE_EXPERIENCE: return 0x1A;
		case MESSAGE_DAMAGE_OTHERS: return 0x1B;
		case MESSAGE_HEALED_OTHERS: return 0x1C;
		case MESSAGE_EXPERIENCE_OTHERS: return 0x1D;
		case MESSAGE_LOOT: return 0x1F;
		case MESSAGE_LOGIN: return 0x11;
		case MESSAGE_WARNING: return 0x12;
		case MESSAGE_GAME: return 0x13;
		case MESSAGE_GAME_HIGHLIGHT: return 0x14;
		case MESSAGE_FAILURE: return 0x15;
		case MESSAGE_LOOK: return 0x16;
		case MESSAGE_STATUS: return 0x1E;
		case MESSAGE_TRADENPC: return 0x20;
		case MESSAGE_REPORT: return 0x26;
		case MESSAGE_HOTKEY: return 0x27;
		case MESSAGE_TUTORIAL: return 0x28;
		case MESSAGE_THANKYOU: return 0x29;
		case MESSAGE_MARKET: return 0x2A;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 1036
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x04;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x0D;
		case MESSAGE_STATUS_DEFAULT: return 0x11;
		case MESSAGE_STATUS_WARNING: return 0x12;
		case MESSAGE_EVENT_ADVANCE: return 0x13;
		case MESSAGE_STATUS_SMALL: return 0x14;
		case MESSAGE_INFO_DESCR: return 0x15;
		case MESSAGE_EVENT_DEFAULT: return 0x1D;
		case MESSAGE_GUILD: return 0x20;
		case MESSAGE_PARTY_MANAGEMENT: return 0x21;
		case MESSAGE_PARTY: return 0x22;
		case MESSAGE_EVENT_ORANGE: return 0x23;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x24;
		case MESSAGE_DAMAGE_DEALT: return 0x16;
		case MESSAGE_DAMAGE_RECEIVED: return 0x17;
		case MESSAGE_MANA: return 0x18;
		case MESSAGE_HEALED: return 0x18;
		case MESSAGE_EXPERIENCE: return 0x19;
		case MESSAGE_DAMAGE_OTHERS: return 0x1A;
		case MESSAGE_HEALED_OTHERS: return 0x1B;
		case MESSAGE_EXPERIENCE_OTHERS: return 0x1C;
		case MESSAGE_LOOT: return 0x1E;
		case MESSAGE_LOGIN: return 0x11;
		case MESSAGE_WARNING: return 0x12;
		case MESSAGE_GAME: return 0x13;
		case MESSAGE_GAME_HIGHLIGHT: return 0x12;
		case MESSAGE_FAILURE: return 0x14;
		case MESSAGE_LOOK: return 0x15;
		case MESSAGE_STATUS: return 0x1D;
		case MESSAGE_TRADENPC: return 0x1F;
		case MESSAGE_REPORT: return 0x25;
		case MESSAGE_HOTKEY: return 0x26;
		case MESSAGE_TUTORIAL: return 0x27;
		case MESSAGE_THANKYOU: return 0x28;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 900
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x04;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x0C;
		case MESSAGE_STATUS_DEFAULT: return 0x10;
		case MESSAGE_STATUS_WARNING: return 0x11;
		case MESSAGE_EVENT_ADVANCE: return 0x12;
		case MESSAGE_STATUS_SMALL: return 0x13;
		case MESSAGE_INFO_DESCR: return 0x14;
		case MESSAGE_EVENT_DEFAULT: return 0x1C;
		case MESSAGE_GUILD: return 0x1F;
		case MESSAGE_PARTY_MANAGEMENT: return 0x20;
		case MESSAGE_PARTY: return 0x21;
		case MESSAGE_EVENT_ORANGE: return 0x22;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x23;
		case MESSAGE_DAMAGE_DEALT: return 0x15;
		case MESSAGE_DAMAGE_RECEIVED: return 0x16;
		case MESSAGE_MANA: return 0x17;
		case MESSAGE_HEALED: return 0x17;
		case MESSAGE_EXPERIENCE: return 0x18;
		case MESSAGE_DAMAGE_OTHERS: return 0x19;
		case MESSAGE_HEALED_OTHERS: return 0x1A;
		case MESSAGE_EXPERIENCE_OTHERS: return 0x1B;
		case MESSAGE_LOOT: return 0x1D;
		case MESSAGE_LOGIN: return 0x10;
		case MESSAGE_WARNING: return 0x11;
		case MESSAGE_GAME: return 0x12;
		case MESSAGE_GAME_HIGHLIGHT: return 0x11;
		case MESSAGE_FAILURE: return 0x13;
		case MESSAGE_LOOK: return 0x14;
		case MESSAGE_STATUS: return 0x1C;
		case MESSAGE_TRADENPC: return 0x1E;
		case MESSAGE_REPORT: return 0x24;
		case MESSAGE_HOTKEY: return 0x25;
		case MESSAGE_TUTORIAL: return 0x26;
		case MESSAGE_THANKYOU: return 0x27;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 861
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x15;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x16;
		case MESSAGE_STATUS_DEFAULT: return 0x11;
		case MESSAGE_STATUS_WARNING: return 0x0F;
		case MESSAGE_EVENT_ADVANCE: return 0x10;
		case MESSAGE_STATUS_SMALL: return 0x14;
		case MESSAGE_INFO_DESCR: return 0x13;
		case MESSAGE_EVENT_DEFAULT: return 0x12;
		case MESSAGE_EVENT_ORANGE: return 0x0D;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x0E;
		case MESSAGE_LOOT: return 0x13;
		case MESSAGE_LOGIN: return 0x11;
		case MESSAGE_WARNING: return 0x0F;
		case MESSAGE_GAME: return 0x10;
		case MESSAGE_GAME_HIGHLIGHT: return 0x0F;
		case MESSAGE_FAILURE: return 0x14;
		case MESSAGE_LOOK: return 0x13;
		case MESSAGE_STATUS: return 0x12;
		case MESSAGE_TRADENPC: return 0x13;
		case MESSAGE_REPORT: return 0x13;
		case MESSAGE_HOTKEY: return 0x13;
		case MESSAGE_TUTORIAL: return 0x13;
		case MESSAGE_THANKYOU: return 0x13;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 840
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x1B;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x12;
		case MESSAGE_STATUS_DEFAULT: return 0x17;
		case MESSAGE_STATUS_WARNING: return 0x15;
		case MESSAGE_EVENT_ADVANCE: return 0x16;
		case MESSAGE_STATUS_SMALL: return 0x1A;
		case MESSAGE_INFO_DESCR: return 0x19;
		case MESSAGE_EVENT_DEFAULT: return 0x18;
		case MESSAGE_EVENT_ORANGE: return 0x13;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x14;
		case MESSAGE_LOOT: return 0x19;
		case MESSAGE_LOGIN: return 0x17;
		case MESSAGE_WARNING: return 0x15;
		case MESSAGE_GAME: return 0x16;
		case MESSAGE_GAME_HIGHLIGHT: return 0x15;
		case MESSAGE_FAILURE: return 0x1A;
		case MESSAGE_LOOK: return 0x19;
		case MESSAGE_STATUS: return 0x18;
		case MESSAGE_TRADENPC: return 0x19;
		case MESSAGE_REPORT: return 0x19;
		case MESSAGE_HOTKEY: return 0x19;
		case MESSAGE_TUTORIAL: return 0x19;
		case MESSAGE_THANKYOU: return 0x19;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 820
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x1A;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x11;
		case MESSAGE_STATUS_DEFAULT: return 0x16;
		case MESSAGE_STATUS_WARNING: return 0x14;
		case MESSAGE_EVENT_ADVANCE: return 0x15;
		case MESSAGE_STATUS_SMALL: return 0x19;
		case MESSAGE_INFO_DESCR: return 0x18;
		case MESSAGE_EVENT_DEFAULT: return 0x17;
		case MESSAGE_EVENT_ORANGE: return 0x12;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x13;
		case MESSAGE_LOOT: return 0x18;
		case MESSAGE_LOGIN: return 0x16;
		case MESSAGE_WARNING: return 0x14;
		case MESSAGE_GAME: return 0x15;
		case MESSAGE_GAME_HIGHLIGHT: return 0x14;
		case MESSAGE_FAILURE: return 0x19;
		case MESSAGE_LOOK: return 0x18;
		case MESSAGE_STATUS: return 0x17;
		case MESSAGE_TRADENPC: return 0x18;
		case MESSAGE_REPORT: return 0x18;
		case MESSAGE_HOTKEY: return 0x18;
		case MESSAGE_TUTORIAL: return 0x18;
		case MESSAGE_THANKYOU: return 0x18;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 723
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x18;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x19;
		case MESSAGE_STATUS_DEFAULT: return 0x14;
		case MESSAGE_STATUS_WARNING: return 0x12;
		case MESSAGE_EVENT_ADVANCE: return 0x13;
		case MESSAGE_STATUS_SMALL: return 0x17;
		case MESSAGE_INFO_DESCR: return 0x16;
		case MESSAGE_EVENT_DEFAULT: return 0x15;
		case MESSAGE_EVENT_ORANGE: return 0x10;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x11;
		case MESSAGE_LOOT: return 0x16;
		case MESSAGE_LOGIN: return 0x14;
		case MESSAGE_WARNING: return 0x12;
		case MESSAGE_GAME: return 0x13;
		case MESSAGE_GAME_HIGHLIGHT: return 0x12;
		case MESSAGE_FAILURE: return 0x17;
		case MESSAGE_LOOK: return 0x16;
		case MESSAGE_STATUS: return 0x15;
		case MESSAGE_TRADENPC: return 0x16;
		case MESSAGE_REPORT: return 0x16;
		case MESSAGE_HOTKEY: return 0x16;
		case MESSAGE_TUTORIAL: return 0x16;
		case MESSAGE_THANKYOU: return 0x16;
		default: return MESSAGE_NONE;
	}
	#elif CLIENT_VERSION >= 710
	switch (messageType) {
		case MESSAGE_STATUS_CONSOLE_BLUE: return 0x04;
		case MESSAGE_STATUS_CONSOLE_RED: return 0x09;
		case MESSAGE_STATUS_DEFAULT: return 0x11;
		case MESSAGE_STATUS_WARNING: return 0x0F;
		case MESSAGE_EVENT_ADVANCE: return 0x10;
		case MESSAGE_STATUS_SMALL: return 0x14;
		case MESSAGE_INFO_DESCR: return 0x13;
		case MESSAGE_EVENT_DEFAULT: return 0x12;
		case MESSAGE_EVENT_ORANGE: return 0x0D;
		case MESSAGE_STATUS_CONSOLE_ORANGE: return 0x0E;
		case MESSAGE_LOOT: return 0x13;
		case MESSAGE_LOGIN: return 0x11;
		case MESSAGE_WARNING: return 0x0F;
		case MESSAGE_GAME: return 0x10;
		case MESSAGE_GAME_HIGHLIGHT: return 0x0F;
		case MESSAGE_FAILURE: return 0x14;
		case MESSAGE_LOOK: return 0x13;
		case MESSAGE_STATUS: return 0x12;
		case MESSAGE_TRADENPC: return 0x13;
		case MESSAGE_REPORT: return 0x13;
		case MESSAGE_HOTKEY: return 0x13;
		case MESSAGE_TUTORIAL: return 0x13;
		case MESSAGE_THANKYOU: return 0x13;
		default: return MESSAGE_NONE;
	}
	#endif
}

void ProtocolGame::parseMarket(NetworkMessage& msg)
{
	uint16_t page = msg.get<uint16_t>();
	uint8_t sort = msg.get<uint8_t>();
	uint8_t sortud = msg.get<uint8_t>();
	uint8_t myOffers = msg.get<uint8_t>();
	uint8_t currency = msg.get<uint8_t>();
	uint8_t rarity = msg.get<uint8_t>();
	uint8_t category = msg.get<uint8_t>();
	std::string text = msg.getString();

	uint8_t attrCount = msg.get<uint8_t>();
	std::vector<Attribute> attrs;
	for (size_t i = 0; i < attrCount; ++i) {
		attrs.push_back({msg.get<uint16_t>(), msg.get<int16_t>(), msg.get<int16_t>()});
	}

	g_game.marketOffers(player, page, currency, rarity, category, text, sort, sortud, myOffers, attrs);
}

void ProtocolGame::sendMarketOffersNoData()
{
	playermsg.reset();
	playermsg.addByte(0x27);
	playermsg.addByte(0x01);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendMarketResponse(uint8_t code, const std::string response)
{
	playermsg.reset();
	playermsg.addByte(0x27);
	playermsg.addByte(code);
	playermsg.addString(response);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendMarketOffers(const std::vector<MarketOffer>& offers, uint16_t page, uint16_t pages, uint8_t category)
{
	playermsg.reset();
	playermsg.addByte(0x27);
	playermsg.addByte(0x00);

	playermsg.addByte(category);
	playermsg.add<uint16_t>(page);
	playermsg.add<uint16_t>(pages);

	playermsg.addByte(offers.size());
	for (const MarketOffer& offer : offers) {
		playermsg.add<uint64_t>(offer.marketId);
		playermsg.add<uint32_t>(offer.clientId);
		playermsg.add<uint16_t>(offer.amount);
		playermsg.add<uint64_t>(offer.created);
		const uint64_t wirePrice = static_cast<uint64_t>(std::llround(offer.price * 100.0));
		playermsg.add<uint64_t>(wirePrice);
		playermsg.add<uint16_t>(offer.currency);
		playermsg.add<uint16_t>(offer.rarity);
		playermsg.addString(offer.seller);
		playermsg.addString(offer.name);
	}

	writeToOutputBuffer(playermsg);
}

void ProtocolGame::parseNewWalking(NetworkMessage& msg)
{
	// We don't have otcv8 so there is no other way to do this ;/
	msg.get<uint32_t>();
	msg.get<int32_t>(); // extension for proxy system, currently not used
	msg.getPosition(); // local player position before moving, including prewalk
	msg.getByte(); // 0x01 - prewalk, 0x02 - autowalk

	uint16_t numdirs = msg.get<uint16_t>();
	if (numdirs == 0 || numdirs > 4096) {
		return;
	}

	std::vector<Direction> path;
	path.resize(numdirs, DIRECTION_NORTH);
	for (size_t i = numdirs; --i < numdirs;) {
		uint8_t rawdir = msg.getByte();
		switch (rawdir) {
			case 1: path[i] = DIRECTION_EAST; break;
			case 2: path[i] = DIRECTION_NORTHEAST; break;
			case 3: path[i] = DIRECTION_NORTH; break;
			case 4: path[i] = DIRECTION_NORTHWEST; break;
			case 5: path[i] = DIRECTION_WEST; break;
			case 6: path[i] = DIRECTION_SOUTHWEST; break;
			case 7: path[i] = DIRECTION_SOUTH; break;
			case 8: path[i] = DIRECTION_SOUTHEAST; break;
			default: break;
		}
	}
	g_game.playerAutoWalk(player->getID(), path);
}

void ProtocolGame::checkPredictiveWalking(const Position& pos)
{
	if (!g_game.map.canWalkTo(*player, pos)) {
		sendPredictiveCancel(pos);
	}
}

void ProtocolGame::sendPredictiveCancel(const Position& pos)
{
	playermsg.reset();
	playermsg.addByte(0x46);
	playermsg.addPosition(pos);
	playermsg.addByte(player->getDirection());
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendNewCancelWalk()
{
	playermsg.reset();
	playermsg.addByte(0x45);
	playermsg.addByte(player->getDirection());
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::parseNewPing(NetworkMessage& msg)
{
	uint32_t pingId = msg.get<uint32_t>();
	uint16_t localPing = msg.get<uint16_t>();
	uint16_t fps = msg.get<uint16_t>();


	g_game.playerReceiveNewPing(player->getID(), localPing, fps);
	g_dispatcher.addTask(std::bind(&ProtocolGame::sendNewPing, getThis(), pingId));
}

void ProtocolGame::sendNewPing(uint32_t pingId)
{
	playermsg.reset();
	playermsg.addByte(0x40);
	playermsg.add<uint32_t>(pingId);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendActiveAuras(const Creature* creature)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xFF);
	playermsg.add<uint32_t>(creature->getID());

	std::map<uint8_t, uint8_t> auras = creature->getActiveAuras();
	playermsg.addByte(auras.size());
	for (const auto& aura : auras) {
		playermsg.addByte(aura.first);
		playermsg.addByte(aura.second);
	}
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendCreatureJump(const Creature* creature, uint16_t height, uint16_t duration)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0xC6);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.add<uint16_t>(height);
	playermsg.add<uint16_t>(duration);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPlayerGold(uint64_t gold)
{
	playermsg.reset();
	playermsg.addByte(0xC7);
	playermsg.add<uint64_t>(gold);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendPartyInvite(const std::string& name, const uint32_t cid)
{
	playermsg.reset();
	playermsg.addByte(0x8B);
	playermsg.addByte(8);
	playermsg.addString(name);
	playermsg.add<uint32_t>(cid);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendProgressBar(const Creature* creature, const uint32_t duration, const bool ltr)
{
	if (!canSee(creature)) {
		return;
	}

	playermsg.reset();
	playermsg.addByte(0x3B);
	playermsg.add<uint32_t>(creature->getID());
	playermsg.add<uint32_t>(duration);
	playermsg.addByte(ltr);
	writeToOutputBuffer(playermsg);
}

void ProtocolGame::sendServerTime()
{
	playermsg.reset();
	playermsg.addByte(0x3F);

	playermsg.add<uint64_t>(std::time(nullptr));
	writeToOutputBuffer(playermsg);
}