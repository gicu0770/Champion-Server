//
// Created by Acer on 18.04.2018.
// OTCv8
//

#include "otpch.h"
#include <chrono>
#include <queue>
#include <fstream>
#include <boost/filesystem.hpp>
#include "cams.h"
#include "databasetasks.h"

std::string Cams::CAMS_DIR = "";

void Cams::threadMain() {
    std::unique_lock<std::mutex> taskLockUnique(taskLock, std::defer_lock);
    std::queue<std::pair<CamData, bool>> toProcess;
    bool last_iteration = false;
    time_t lastSpaceCheck = 0;
    bool hasSpace = false;
    while(true) {
        taskLockUnique.lock();
        for(auto it = camsMap.begin(); it != camsMap.end(); ) {
            if(it->second.lastPacket + CAM_REFRESH_PACKET_INTERVAL * 2 < time(nullptr) || last_iteration) {
                if(it->second.lastPacket > CAM_MINIMUM_LENGTH + it->second.startTime / 1000)
                    toProcess.push(std::make_pair(it->second, true));
                it = camsMap.erase(it);
            } else if(it->second.packets->size() > CAM_PACKET_BUFFER_LIMIT || it->second.lastSave + CAM_MAX_SAVE_INTERVAL < time(nullptr)) {
                toProcess.push(std::make_pair(it->second, false));
                it->second.packets = std::make_shared<PacketList>();
                it->second.lastSave = time(nullptr);
                ++it;
            } else
                ++it;
        }
        taskLockUnique.unlock();
        if(last_iteration && toProcess.size() > 0)
            std::cout << "Saving " << toProcess.size() << " cams, it may take a moment" << std::endl;
        if(lastSpaceCheck + 60 < time(nullptr) && !CAMS_DIR.empty()) {
            lastSpaceCheck = time(nullptr);
            boost::system::error_code ec;
            auto space_info = boost::filesystem::space(boost::filesystem::path(CAMS_DIR), ec);
            hasSpace = true;
            if(ec || (space_info.free / (1024 * 1024)) < (1024)) { // stop if less than 1 gb
                std::cerr << "ERROR: NO ENOUGH DISC SPACE FOR CAMS, ONLY " << (space_info.free / (1024 * 1024)) << " MBs FREE" << std::endl;
                hasSpace = false;
            }                
        }
        while(!toProcess.empty()) {
            auto it = toProcess.front().first;
            bool rename = toProcess.front().second;
            toProcess.pop();
            boost::filesystem::path path(CAMS_DIR);
            path /= std::to_string(it.playerId);
            if(!boost::filesystem::is_directory(path) && !boost::filesystem::create_directories(path)) {
                std::cout << "Can't create directory " << path.string() << " for cam system (check permissions)" << std::endl;
                continue;
            }
            path /= it.character + "." + std::to_string(it.startTime) + ".cam";
            if(hasSpace) {
                std::ofstream out(path.string(), std::ofstream::out | std::ofstream::app | std::ofstream::binary);
                if (!out.is_open()) {
                    std::cout << "Can't open " << path.string() << " (check if directory exists and has correct permissions)" << std::endl;
                } else {
                    if((int)out.tellp() == 0) { // empty file, add header
                        out.write("TIBIACAM", 8);
                        out.put(0x01); // version
                        out.write((char*)&it.playerId, sizeof(it.playerId));
                        uint16_t name_length = it.character.length();
                        out.write((char*)&name_length, sizeof(name_length));
                        out.write(it.character.c_str(), name_length); // character name
                        out.write((char*)&it.version, sizeof(it.version)); // protocol version
                        out.write((char*)&it.startTime, sizeof(it.startTime)); // start time
                    }
                    for(auto pit = it.packets->begin(); pit != it.packets->end(); ++pit) {
                        uint16_t packet_size = pit->second.size();
                        if(packet_size == 0)
                            continue;
                        out.write((char*)&pit->first, sizeof(pit->first));
                        out.write((char*)&packet_size, sizeof(packet_size));
                        out.write((char*)&pit->second[0], packet_size);
                    }
                    out.close();
                }
            }
            if(rename) {
                boost::filesystem::path new_path(path);
                new_path += ".ready";
                boost::system::error_code ec;
                boost::filesystem::rename(path, new_path, ec);
				addCamToDatabase(it);
            }

            if(!last_iteration) // do only 1 file write per check
                break;
        }
        if(last_iteration)
            break;
        if(getState() == THREAD_STATE_TERMINATED) {
            last_iteration = true;
            continue;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
}


uint32_t Cams::initCam(const std::string& character, uint32_t playerId, uint16_t version) {
    if(CAMS_DIR.empty()) {
        std::cout << "ERROR: camsDir is empty! set it in config.lua" << std::endl;
        return 0;
    }
    std::lock_guard<std::mutex> lockClass(taskLock);
    camsMap[++camId] = CamData({std::make_shared<PacketList>(), OTSYS_TIME(), time(nullptr), time(nullptr), character, playerId, version});
    return camId;
}

void Cams::addPacket(uint32_t id, const NetworkMessage& msg, bool refresh) {
    std::lock_guard<std::mutex> lockClass(taskLock);
    auto it = camsMap.find(id);
    if(it == camsMap.end())
        return;

    it->second.lastPacket = time(nullptr);
    std::vector<uint8_t> buffer(msg.getBuffer() + NetworkMessage::INITIAL_BUFFER_POSITION - 1, msg.getBuffer() + msg.getBufferPosition());
    buffer[0] = (refresh ? 0x05 : 0x01);
    it->second.packets->push_back(std::make_pair(OTSYS_TIME(), std::move(buffer)));
}

void Cams::addInputPacket(uint32_t id, const uint8_t* buffer, int size)
{
    std::lock_guard<std::mutex> lockClass(taskLock);
    auto it = camsMap.find(id);
    if(it == camsMap.end())
        return;

    it->second.lastPacket = time(nullptr);
    std::vector<uint8_t> vbuffer(buffer - 1, buffer + size);
    vbuffer[0] = 0x10;
    it->second.packets->push_back(std::make_pair(OTSYS_TIME(), std::move(vbuffer)));    
}

CamsList Cams::getCams(const std::string& login, const std::string& password, uint32_t player_id) {
    CamsList ret;
	
	std::string lower = asLowerCaseString(login);
	std::string pass_lower = asLowerCaseString(password);
	if(player_id == 0) {
		if(lower.length() < 5 || lower.substr(0, 4) != "!cam")
			return ret;

		std::string player_id_str = lower.substr(4);
		player_id = 0;
		try {
			player_id = std::stoul(player_id_str);
		} catch(...) {
			return ret;
		}

		if(!player_id)
			return ret;
	}
	
    boost::filesystem::path path(CAMS_DIR);
    path /= std::to_string(player_id);

    boost::filesystem::recursive_directory_iterator end;
    boost::system::error_code ec;
    boost::filesystem::recursive_directory_iterator i(path, ec);
    if(ec)
        return ret;

    std::map<uint64_t, std::pair<std::string, std::string>> file_names;

    for (; i != end; ++i)
    {
        const boost::filesystem::path p = (*i);
        auto v = explodeString(asLowerCaseString(p.string()), ".");
        // ... .ms_timestamp.cam.gz
        if(v.size() < 4 || v[v.size()-1] != "gz" || v[v.size()-2] != "cam")
            continue;

        uint64_t cam_time = 0;
        try {
            cam_time = std::stoull(v[v.size()-3]);
        } catch(const std::exception&) {
            continue;
        }

        if(!cam_time)
            continue;

        std::string cam_time_str = std::to_string(cam_time);
        std::string cam_pass = asLowerCaseString(transformToSHA1(cam_time_str).substr(0, 6));

        //if(!password.empty() && cam_pass != pass_lower)
        //    continue;

        file_names[cam_time] = std::make_pair(std::to_string(player_id) + " " + cam_pass, v[0]);
    }

    for(auto it = file_names.rbegin(); it != file_names.rend(); ++it)
        ret.push_back(std::make_pair(it->second.first, formatDateEx((uint32_t)(it->first / 1000), "%H:%M %d/%m")));

    return ret;
}

void Cams::addCamToDatabase(const CamData& data) {
	std::string hash = asLowerCaseString(transformToSHA1(std::to_string(data.startTime)).substr(0, 6));
	std::stringstream query;
	query << "INSERT INTO `cams` (`player`, `date`, `hash`) VALUES ('" << data.playerId << "', NOW(), '" << hash << "');";
	g_databaseTasks.addTask(query.str());
}
