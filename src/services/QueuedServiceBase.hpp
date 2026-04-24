#pragma once

#include <atomic>
#include <chrono>
#include <thread>

#include <QString>

#include "core/ServiceCommand.hpp"
#include "services/IService.hpp"
#include "services/LogService.hpp"
#include "services/ThreadSafeQueue.hpp"

namespace projectpotato::services {

class QueuedServiceBase : public IService {
public:
    QueuedServiceBase(QString serviceName, LogService& logService, uint32_t heartbeatSeconds);
    ~QueuedServiceBase() override;

    QString name() const override;
    bool start() override;
    void stop() override;
    bool isRunning() const override;
    void postCommand(const projectpotato::core::ServiceCommand& command) override;

protected:
    void log(LogLevel level, const QString& message) const;
    virtual void onStarted();
    virtual void onStopped();
    virtual void onHeartbeat();
    virtual bool handleCustomCommand(const projectpotato::core::ServiceCommand& command) = 0;

private:
    void process(std::stop_token stopToken);
    bool handleCommand(const projectpotato::core::ServiceCommand& command);

    QString serviceName_;
    LogService& logService_;
    ThreadSafeQueue<projectpotato::core::ServiceCommand> queue_;
    std::jthread workerThread_;
    std::atomic_bool running_{false};
    const std::chrono::milliseconds heartbeatInterval_;
};

} // namespace projectpotato::services
