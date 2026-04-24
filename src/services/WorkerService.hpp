#pragma once

#include "services/QueuedServiceBase.hpp"

namespace projectpotato::services {

class WorkerService final : public QueuedServiceBase {
public:
    explicit WorkerService(LogService& logService);

protected:
    bool handleCustomCommand(const projectpotato::core::ServiceCommand& command) override;
    void onHeartbeat() override;
};

} // namespace projectpotato::services
