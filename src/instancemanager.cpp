
#include "otpch.h"

#include "dungeon.h"
#include "player.h"
#include "game.h"
#include "events.h"
#include "monster.h"
#include "instancemanager.h"
#include "configmanager.h"
#include "outputmessage.h"

#ifdef _WIN32
	#include <winsock2.h>
	#pragma comment(lib, "ws2_32.lib")
	#define close closesocket
#else
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <unistd.h>
#endif

extern Events* g_events;
extern Game g_game;
extern InstanceManager* g_instanceManager;
extern ConfigManager g_config;

int InstanceManager::getFreePort() {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) return -1;

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = 0;

    if (bind(sock, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
        close(sock);
        return -1;
    }

    socklen_t len = sizeof(addr);
    if (getsockname(sock, (struct sockaddr*)&addr, &len) != 0) {
        close(sock);
        return -1;
    }

    int free_port = ntohs(addr.sin_port);
    close(sock);
    return free_port;
} 

void InstanceManager::startInstance(Player* player, uint8_t type, const std::string map)
{
    int port = getFreePort();
    if (port == -1) {
        std::cout << "No Free port found: " << std::endl;
        return;
    }
    uint32_t playerId = player->getID();
	
    Instance* newInstance;
    newInstance->setIp(g_config.getString(ConfigManager::IP)); // for now all works on one server so ip is same
    newInstance->setPort(port);
    // newInstance->addPlayer(playerId);

    player->setInstanceId(port);
    std::cout << "[InstanceManager] Starting instance " << " on port " << port << std::endl;
    auto startInstance = std::async(std::launch::async, [map, type, port, newInstance] {
        std::string cmd = 
            "screen -dmS instance_" + std::to_string(port) +
            " bash -c \"cd /home/ubuntu/tfs-test/ && ./tfs '" + map + "' " +
            std::to_string(type) + " " + std::to_string(port) + "\"";

        int result = system(cmd.c_str());
        if (result != 0) {
            std::cout << "[InstanceManager] Warning: failed to start instance on port " << port << " (exit code: " << result << ")" << std::endl;
        }

        g_instanceManager->addInstance(port, newInstance);
        g_instanceManager->checkIfInstanceIsReady(port);
    });
}

void InstanceManager::addInstance(uint32_t id, Instance* instance)
{
    instances[id] = instance;
}

bool InstanceManager::forceCloseInstance(uint32_t id)
{
    Instance* instance = getInstanceById(id);
    if (!instance) {
        std::cout << "[InstanceManager] Can't find instance with id " << id << " to forec close it" << std::endl;
        return false;
    }
    int port = instance->getPort();
    std::string sessionName = "instance_" + std::to_string(port);

    std::cout << "[InstanceManager] Closing instance " << id << " (screen: " << sessionName << ", port: " << port << ")" << std::endl;

    std::string closeScreenCmd = "screen -S " + sessionName + " -X quit";
    int screenResult = system(closeScreenCmd.c_str());
    if (screenResult != 0) {
        std::cout << "[InstanceManager] Warning: failed to close screen session " << sessionName << " (exit code: " << screenResult << ")" << std::endl;
    }

    std::string killByPortCmd =
        "pid=$(lsof -ti tcp:" + std::to_string(port) + ") && "
        "if [ ! -z \"$pid\" ]; then kill -9 $pid; fi";

    int result = system(killByPortCmd.c_str());

    if (result != 0) {
        std::cout << "[InstanceManager] Warning: no process found on port " << port << " (it might have already exited)." << std::endl;
    }

    instances.erase(port);
    std::cout << "[InstanceManager] Instance " << id << " closed and removed." << std::endl;

    return true;
}

Instance* InstanceManager::getInstanceById(uint32_t id)
{
    auto it = instances.find(id);
    if (it == instances.end()) {
        std::cout << "[InstanceManager] No instance with ID " << id << " found." << std::endl;
        return nullptr;
    }

    return it->second;
}

void InstanceManager::checkIfInstanceIsReady(uint32_t id) {
    Instance* instance = getInstanceById(id);
    if (!instance) {
        std::cout << "[InstanceManager] No instance with ID " << id << " found." << std::endl;
        return;
    }

    static boost::asio::io_context io_context;
    #if BOOST_VERSION >= 106600
    static boost::asio::executor_work_guard<boost::asio::io_context::executor_type> work(io_context.get_executor());
    #else
    static auto work = std::make_shared<boost::asio::io_context::work>(io_context);
    #endif
    static std::once_flag flag;

    std::call_once(flag, []() {
        std::thread([]() { io_context.run(); }).detach();
    });

    // auto session = std::make_shared<InstanceSession>(io_context, id, instance->getIp(), instance->getPort());
    // session->start();
}

void MainServerConnection::handleOpcode(uint8_t opcode, NetworkMessage& msg) {
    std::cout << "handling opcode" << (uint32_t)opcode << std::endl;
    switch (opcode) {
        case STS_OPCODE_STATUS:
            std::cout << (uint32_t)msg.getByte() << std::endl;
            break;
        default:
            std::cout << "[InstanceManager] Unknown opcode " << (int)opcode << "\n";
            break;
    }
}
