#include "services/LauncherService.hpp"

namespace projectpotato::services {

LauncherService::LauncherService(LogService& logService)
    : QueuedServiceBase("LauncherService", logService, 4U) {
}

bool LauncherService::handleCustomCommand(const projectpotato::core::ServiceCommand& command) {
    switch (command.type) {
    case projectpotato::core::ServiceCommandType::LaunchSelected:
        log(LogLevel::Info,
            QString("LaunchSelected placeholder received from %1 for [%2].")
                .arg(command.origin, command.payload));
        return true;
    case projectpotato::core::ServiceCommandType::CheckUpdates:
        log(LogLevel::Trace,
            QString("LauncherService ignoring CheckUpdates placeholder from %1.")
                .arg(command.origin));
        return true;
    case projectpotato::core::ServiceCommandType::UpdateAll:
        log(LogLevel::Trace,
            QString("LauncherService ignoring UpdateAll placeholder from %1.")
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
