#pragma once

#include <atomic>
#include <cstdint>
#include <functional>
#include <mutex>
#include <thread>

#include <QString>

#include "core/AppPaths.hpp"
#include "core/ServiceCommand.hpp"
#include "services/IService.hpp"
#include "services/ThreadSafeQueue.hpp"

namespace projectpotato::services {

enum class LogLevel : uint32_t {
    Trace = 0,
    Debug = 1,
    Info = 2,
    Warning = 3,
    Error = 4,
    Critical = 5,
};

struct LogEvent final {
    LogLevel level{LogLevel::Info};
    QString source;
    QString message;
    QString timestamp;
    QString formattedLine;
};

QString logLevelToString(LogLevel level);

class LogService final : public IService {
public:
    explicit LogService(const projectpotato::core::AppPaths& appPaths);
    ~LogService() override;

    QString name() const override;
    bool start() override;
    void stop() override;
    bool isRunning() const override;
    void postCommand(const projectpotato::core::ServiceCommand& command) override;

    void submit(LogLevel level, const QString& source, const QString& message);
    void setGuiForwarder(std::function<void(const LogEvent&)> forwarder);
    QString logFilePath() const;

private:
    enum class QueueItemType : uint32_t {
        LogEvent = 0,
        Command = 1,
    };

    struct QueueItem final {
        QueueItemType type{QueueItemType::LogEvent};
        LogEvent logEvent;
        projectpotato::core::ServiceCommand command;
    };

    void process(std::stop_token stopToken);
    bool handleCommand(const projectpotato::core::ServiceCommand& command);
    void writeEvent(const LogEvent& event);
    void forwardToGui(const LogEvent& event);
    void rotateIfNeeded(const QByteArray& encodedLine);
    LogEvent createEvent(LogLevel level, const QString& source, const QString& message) const;

    projectpotato::core::AppPaths appPaths_;
    ThreadSafeQueue<QueueItem> queue_;
    std::jthread workerThread_;
    std::atomic_bool running_{false};
    mutable std::mutex forwarderMutex_;
    std::function<void(const LogEvent&)> guiForwarder_;
    const uint32_t maxLogBytes_{10U * 1024U * 1024U};
    const uint32_t maxLogFiles_{10U};
};

} // namespace projectpotato::services
