#include "services/WorkerService.hpp"

namespace projectpotato::services {

WorkerService::WorkerService(LogService& logService)
    : QueuedServiceBase("WorkerService", logService, 7U) {
}

bool WorkerService::handleCustomCommand(const projectpotato::core::ServiceCommand& command) {
    log(LogLevel::Trace,
        QString("Worker placeholder command %1 received from %2. Worker protocol is deferred past Phase 1.")
            .arg(projectpotato::core::serviceCommandTypeToString(command.type), command.origin));
    return true;
}

void WorkerService::onHeartbeat() {
    log(LogLevel::Debug, "Heartbeat. Worker harness is alive without external protocol wiring.");
}

} // namespace projectpotato::services
