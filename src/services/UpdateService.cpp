#include "services/UpdateService.hpp"

namespace projectpotato::services {

UpdateService::UpdateService(LogService& logService)
    : QueuedServiceBase("UpdateService", logService, 6U) {
}

bool UpdateService::handleCustomCommand(const projectpotato::core::ServiceCommand& command) {
    switch (command.type) {
    case projectpotato::core::ServiceCommandType::CheckUpdates:
        log(LogLevel::Info,
            QString("CheckUpdates placeholder received from %1 for [%2].")
                .arg(command.origin, command.payload));
        return true;
    case projectpotato::core::ServiceCommandType::UpdateAll:
        log(LogLevel::Info,
            QString("UpdateAll placeholder received from %1. Scope: [%2].")
                .arg(command.origin, command.payload));
        return true;
    case projectpotato::core::ServiceCommandType::LaunchSelected:
        log(LogLevel::Trace,
            QString("UpdateService ignoring LaunchSelected placeholder from %1.")
                .arg(command.origin));
        return true;
    case projectpotato::core::ServiceCommandType::Ping:
    case projectpotato::core::ServiceCommandType::EmitTestLog:
    case projectpotato::core::ServiceCommandType::Shutdown:
        break;
    }

    return true;
}

} // namespace projectpotato::services
