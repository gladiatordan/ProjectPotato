#pragma once

#include "services/QueuedServiceBase.hpp"

namespace projectpotato::services {

class GameService final : public QueuedServiceBase {
public:
    explicit GameService(LogService& logService);

protected:
    bool handleCustomCommand(const projectpotato::core::ServiceCommand& command) override;
    void onHeartbeat() override;
};

} // namespace projectpotato::services
