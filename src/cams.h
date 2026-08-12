#ifndef CAMS_H
#define CAMS_H

#include "thread_holder_base.h"
#include "enums.h"
#include "protocol.h"
#include "outputmessage.h"
#include <condition_variable>
#include <map>
#include <vector>
#include <mutex>
#include <string>
#include <memory>
#include <list>

using PacketList = std::list<std::pair<uint64_t, std::vector<uint8_t>>>;
using PacketMap_ptr = std::shared_ptr<PacketList>;

struct CamData {
    PacketMap_ptr packets;
    int64_t startTime;
    time_t lastPacket;
    time_t lastSave;
    std::string character;
    uint32_t playerId;
    uint16_t version;
};

struct CamInfo {
	std::string name;
	uint32_t playerId;
	std::string hash;	
};

using CamsMap = std::map<uint32_t, CamData>;
using CamsList = std::list<std::pair<std::string, std::string>>;

static constexpr int32_t CAM_MAX_DURATION = 3600; // in seconds
static constexpr int32_t CAM_REFRESH_PACKET_INTERVAL = 15; // in seconds
static constexpr int32_t CAM_PACKET_BUFFER_LIMIT = 1000; // in seconds
static constexpr int32_t CAM_MINIMUM_LENGTH = 10; // in seconds
static constexpr int32_t CAM_MAX_SAVE_INTERVAL = 600; // in seconds

class Cams : public ThreadHolder<Cams> {

public:
    void threadMain();
    uint32_t initCam(const std::string& character, uint32_t playerId, uint16_t version);
    void addPacket(uint32_t id, const NetworkMessage& msg, bool refresh);
    void addInputPacket(uint32_t id, const uint8_t* buffer, int size);
    void shutdown() {
        setState(THREAD_STATE_TERMINATED);
    }
    CamsList getCams(const std::string& login, const std::string& password, uint32_t player_id = 0);
	void addCamToDatabase(const CamData& data);

    static std::string CAMS_DIR;

private:
    uint32_t camId = 0;
    std::thread thread;
    std::mutex taskLock;
    CamsMap camsMap;
};

extern Cams g_cams;


#endif //CAMS_H
