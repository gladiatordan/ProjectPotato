#pragma once

#include "services/QueuedServiceBase.hpp"

namespace projectpotato::services {

class LauncherService final : public QueuedServiceBase {
public:
    explicit LauncherService(LogService& logService);

protected:
    bool handleCustomCommand(const projectpotato::core::ServiceCommand& command) override;
};

} // namespace projectpotato::services
