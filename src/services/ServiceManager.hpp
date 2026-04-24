#pragma once

#include <functional>
#include <vector>

#include <QString>

#include "core/AppPaths.hpp"
#include "core/ServiceCommand.hpp"
#include "services/GameService.hpp"
#include "services/LauncherService.hpp"
#include "services/LogService.hpp"
#include "services/UpdateService.hpp"
#include "services/WorkerService.hpp"

namespace projectpotato::services {

struct ServiceStatusSnapshot final {
    QString name;
    bool running{false};
};

class ServiceManager final {
public:
    explicit ServiceManager(const projectpotato::core::AppPaths& appPaths);
    ~ServiceManager();

    void setGuiLogForwarder(std::function<void(const LogEvent&)> forwarder);

    bool startAll();
    void stopAll();

    void log(LogLevel level, const QString& source, const QString& message);
    void dispatchToService(
        projectpotato::core::ServiceId serviceId,
        const projectpotato::core::ServiceCommand& command);
    void pingAllServices(const QString& origin);
    void emitTestLogBurst(uint32_t burstCount, const QString& origin);
    std::vector<ServiceStatusSnapshot> serviceStatuses() const;
    QString logsDirectoryPath() const;

private:
    void postToAll(const projectpotato::core::ServiceCommand& command);

    projectpotato::core::AppPaths appPaths_;
    LogService logService_;
    LauncherService launcherService_;
    GameService gameService_;
    UpdateService updateService_;
    WorkerService workerService_;
};

} // namespace projectpotato::services
