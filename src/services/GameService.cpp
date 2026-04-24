#include "services/GameService.hpp"

namespace projectpotato::services {

GameService::GameService(LogService& logService)
    : QueuedServiceBase("GameService", logService, 5U) {
}

bool GameService::handleCustomCommand(const projectpotato::core::ServiceCommand& command) {
    log(LogLevel::Trace,
        QString("Host-internal command %1 observed from %2. No Phase 1 gameplay action is implemented.")
            .arg(projectpotato::core::serviceCommandTypeToString(command.type), command.origin));
    return true;
}

void GameService::onHeartbeat() {
    log(LogLevel::Debug, "Heartbeat. Guild Wars process control is intentionally stubbed in Phase 1.");
}

} // namespace projectpotato::services
