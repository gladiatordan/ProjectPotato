#include "services/ServiceManager.hpp"

namespace projectpotato::services {

ServiceManager::ServiceManager(const projectpotato::core::AppPaths& appPaths)
    : appPaths_(appPaths)
    , logService_(appPaths_)
    , launcherService_(logService_)
    , gameService_(logService_)
    , updateService_(logService_)
    , workerService_(logService_) {
}

ServiceManager::~ServiceManager() {
    stopAll();
}

void ServiceManager::setGuiLogForwarder(std::function<void(const LogEvent&)> forwarder) {
    logService_.setGuiForwarder(std::move(forwarder));
}

bool ServiceManager::startAll() {
    const bool logStarted = logService_.start();
    launcherService_.start();
    gameService_.start();
    updateService_.start();
    workerService_.start();

    log(LogLevel::Info, "ServiceManager", "Phase 1 service harness started.");
    return logStarted;
}

void ServiceManager::stopAll() {
    workerService_.stop();
    updateService_.stop();
    gameService_.stop();
    launcherService_.stop();
    logService_.stop();
}

void ServiceManager::log(const LogLevel level, const QString& source, const QString& message) {
    logService_.submit(level, source, message);
}

void ServiceManager::dispatchToService(
    const projectpotato::core::ServiceId serviceId,
    const projectpotato::core::ServiceCommand& command) {
    switch (serviceId) {
    case projectpotato::core::ServiceId::Log:
        logService_.postCommand(command);
        return;
    case projectpotato::core::ServiceId::Launcher:
        launcherService_.postCommand(command);
        return;
    case projectpotato::core::ServiceId::Game:
        gameService_.postCommand(command);
        return;
    case projectpotato::core::ServiceId::Update:
        updateService_.postCommand(command);
        return;
    case projectpotato::core::ServiceId::Worker:
        workerService_.postCommand(command);
        return;
    case projectpotato::core::ServiceId::Broadcast:
        postToAll(command);
        return;
    }
}

void ServiceManager::pingAllServices(const QString& origin) {
    const projectpotato::core::ServiceCommand command{
        .type = projectpotato::core::ServiceCommandType::Ping,
        .origin = origin,
        .payload = "Diagnostics ping",
        .value = 0,
    };
    postToAll(command);
    log(LogLevel::Info, "ServiceManager", QString("Broadcast ping issued by %1.").arg(origin));
}

void ServiceManager::emitTestLogBurst(const uint32_t burstCount, const QString& origin) {
    const projectpotato::core::ServiceCommand command{
        .type = projectpotato::core::ServiceCommandType::EmitTestLog,
        .origin = origin,
        .payload = "Diagnostics burst",
        .value = burstCount,
    };

    logService_.postCommand(command);
    launcherService_.postCommand(command);
    gameService_.postCommand(command);
    updateService_.postCommand(command);
    workerService_.postCommand(command);
}

std::vector<ServiceStatusSnapshot> ServiceManager::serviceStatuses() const {
    return {
        {.name = logService_.name(), .running = logService_.isRunning()},
        {.name = launcherService_.name(), .running = launcherService_.isRunning()},
        {.name = gameService_.name(), .running = gameService_.isRunning()},
        {.name = updateService_.name(), .running = updateService_.isRunning()},
        {.name = workerService_.name(), .running = workerService_.isRunning()},
    };
}

QString ServiceManager::logsDirectoryPath() const {
    return appPaths_.logsPath();
}

void ServiceManager::postToAll(const projectpotato::core::ServiceCommand& command) {
    logService_.postCommand(command);
    launcherService_.postCommand(command);
    gameService_.postCommand(command);
    updateService_.postCommand(command);
    workerService_.postCommand(command);
}

} // namespace projectpotato::services
