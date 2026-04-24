#pragma once

#include <cstdint>

#include <QString>

namespace projectpotato::core {

enum class ServiceId : uint32_t {
    Log = 0,
    Launcher = 1,
    Game = 2,
    Update = 3,
    Worker = 4,
    Broadcast = 5,
};

enum class ServiceCommandType : uint32_t {
    Ping = 0,
    EmitTestLog = 1,
    Shutdown = 2,
    LaunchSelected = 3,
    CheckUpdates = 4,
    UpdateAll = 5,
};

struct ServiceCommand final {
    ServiceCommandType type{ServiceCommandType::Ping};
    QString origin;
    QString payload;
    uint32_t value{0};
};

QString serviceIdToString(ServiceId serviceId);
QString serviceCommandTypeToString(ServiceCommandType commandType);

} // namespace projectpotato::core
