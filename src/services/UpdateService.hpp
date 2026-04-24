#pragma once

#include "services/QueuedServiceBase.hpp"

namespace projectpotato::services {

class UpdateService final : public QueuedServiceBase {
public:
    explicit UpdateService(LogService& logService);

protected:
    bool handleCustomCommand(const projectpotato::core::ServiceCommand& command) override;
};

} // namespace projectpotato::services
