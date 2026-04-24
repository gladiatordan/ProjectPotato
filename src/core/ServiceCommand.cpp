#include "core/ServiceCommand.hpp"

namespace projectpotato::core {

QString serviceIdToString(const ServiceId serviceId) {
    switch (serviceId) {
    case ServiceId::Log:
        return "LogService";
    case ServiceId::Launcher:
        return "LauncherService";
    case ServiceId::Game:
        return "GameService";
    case ServiceId::Update:
        return "UpdateService";
    case ServiceId::Worker:
        return "WorkerService";
    case ServiceId::Broadcast:
        return "Broadcast";
    }

    return "UnknownService";
}

QString serviceCommandTypeToString(const ServiceCommandType commandType) {
    switch (commandType) {
    case ServiceCommandType::Ping:
        return "Ping";
    case ServiceCommandType::EmitTestLog:
        return "EmitTestLog";
    case ServiceCommandType::Shutdown:
        return "Shutdown";
    case ServiceCommandType::LaunchSelected:
        return "LaunchSelected";
    case ServiceCommandType::CheckUpdates:
        return "CheckUpdates";
    case ServiceCommandType::UpdateAll:
        return "UpdateAll";
    }

    return "UnknownCommand";
}

} // namespace projectpotato::core
