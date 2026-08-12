#ifndef FS_INSTANCEMANAGER_H
#define FS_INSTANCEMANAGER_H

#include "outputmessage.h"
#include "protocolgame.h"

class Instance
{
    public:
        std::string getIp() const {
            return ip;
        }
        int getPort() const {
            return port;
        }

        void setIp(const std::string value) {
            ip = value;
        }

        void setPort(int value) {
            port = value;
        }

        void addPlayer(uint32_t playerId) {
            players.push_back(playerId);
        }
    
        void removePlayer(uint32_t playerId) {
            players.remove(playerId);
        }
    
        bool hasPlayer(uint32_t playerId) const {
            return std::find(players.begin(), players.end(), playerId) != players.end();
        }
    
        const std::list<uint32_t>& getPlayers() const {
            return players;
        }

        void completStart(ProtocolGame_ptr p) {
            server = std::move(p);
        }

    private:
        std::list<uint32_t> players;
        std::string ip;
        int port;
        ProtocolGame_ptr server;
};

class InstanceManager
{
    public:
        void startInstance(Player* player, uint8_t type, const std::string map);
        int getFreePort();
        void addInstance(uint32_t id, Instance* instance);
        bool forceCloseInstance(uint32_t id);
        void checkIfInstanceIsReady(uint32_t id);
        Instance* getInstanceById(uint32_t id);

    private:
	    std::map<uint32_t, Instance*> instances;
};

class MainServerConnection : public std::enable_shared_from_this<MainServerConnection> {
    public:
        MainServerConnection(boost::asio::io_context& io, std::string host, uint16_t port)
            : io_context(io), socket(io), resolver(io), timer(io),
            host(std::move(host)), port(port), netMsg(std::make_shared<NetworkMessage>()) {}

        void start() {
            std::cout << ">> Connecting instance to main server: " << host << ":" << port << std::endl;
            doResolve();
        }

    private:
        void doResolve() {
            auto self = shared_from_this();
            resolver.async_resolve(host, std::to_string(port),
                [this, self](boost::system::error_code ec, auto results) {
                    if (ec) {
                        std::cout << "[Instance] Resolve failed: " << ec.message() << std::endl;
                        scheduleReconnect();
                        return;
                    }
                    doConnect(results);
                });
        }

        void doConnect(const boost::asio::ip::tcp::resolver::results_type& endpoints) {
            auto self = shared_from_this();
            boost::asio::async_connect(socket, endpoints,
                [this, self](boost::system::error_code ec, auto) {
                    if (ec) {
                        std::cout << "[Instance] Connect failed: " << ec.message() << std::endl;
                        scheduleReconnect();
                        return;
                    }

                    std::cout << "[Instance] Connected to main server." << std::endl;
                    sendHandshake();
                });
        }

        void sendHandshake() {
            auto self = shared_from_this();
            auto msg = OutputMessagePool::getOutputMessage();
            auto startPos = msg->getBufferPosition();
            msg->skipBytes(1);
            for (int i = 0; i < 6; ++i) msg->addByte(0);

            msg->addByte(255); // handshake opcode
            msg->addString(INSTANCE_PASSWORD);
            msg->addByte(0x01); // instance type or ID

            msg->setBufferPosition(startPos);
            msg->add<uint16_t>(msg->getLength());

            boost::asio::async_write(socket, boost::asio::buffer(msg->getOutputBuffer(), msg->getLength()),
                [this, self](boost::system::error_code ec, std::size_t) {
                    if (ec) {
                        std::cout << "[Instance] Handshake failed: " << ec.message() << std::endl;
                        scheduleReconnect();
                        return;
                    }
                    std::cout << "[Instance] Handshake sent to main server." << std::endl;
                    readHeader();
                });
        }

        void readHeader() {
            auto self = shared_from_this();

            netMsg->setLength(NetworkMessage::HEADER_LENGTH);
            boost::asio::async_read(socket, boost::asio::buffer(netMsg->getBuffer(), NetworkMessage::HEADER_LENGTH),
                [this, self](const boost::system::error_code& ec, std::size_t) {
                    if (ec) {
                        std::cout << "[InstanceManager] Read header failed for instance: " << ec.message() << std::endl;
                        return;
                    }
                    uint16_t bodySize = netMsg->getLengthHeader();
                    netMsg->setLength(NetworkMessage::HEADER_LENGTH + bodySize);
                    readBody(bodySize);
                });
        }

        void readBody(std::size_t bodySize) {
            auto self = shared_from_this();

            boost::asio::async_read(socket, boost::asio::buffer(netMsg->getBodyBuffer(), bodySize),
                [this, self](const boost::system::error_code& ec, std::size_t) {
                    if (ec) {
                        std::cout << "[InstanceManager] Read body failed for instance: " << ec.message() << std::endl;
                        return;
                    }

                    uint8_t opcode = netMsg->getByte();
                    handleOpcode(opcode, *netMsg);
                });
        }

        void handleDisconnect(const boost::system::error_code& ec) {
            if (ec == boost::asio::error::eof)
                std::cout << "[Instance] Disconnected from main server (EOF)." << std::endl;
            else
                std::cout << "[Instance] Connection lost: " << ec.message() << std::endl;

            socket.close();
            scheduleReconnect();
        }

        void scheduleReconnect() {
            auto self = shared_from_this();
            std::cout << "[Instance] Reconnecting in 5 seconds..." << std::endl;
            timer.expires_after(std::chrono::seconds(5));
            timer.async_wait([this, self](boost::system::error_code) {
                doResolve();
            });
        }

        void handleOpcode(uint8_t opcode, NetworkMessage& msg);

    private:
        boost::asio::io_context& io_context;
        boost::asio::ip::tcp::socket socket;
        boost::asio::ip::tcp::resolver resolver;
        boost::asio::steady_timer timer;
        std::string host;
        uint16_t port;
        std::shared_ptr<NetworkMessage> netMsg;
};
#endif