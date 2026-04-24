#pragma once

#include <QString>

#include "core/ServiceCommand.hpp"

namespace projectpotato::services {

class IService {
public:
    virtual ~IService() = default;

    virtual QString name() const = 0;
    virtual bool start() = 0;
    virtual void stop() = 0;
    virtual bool isRunning() const = 0;
    virtual void postCommand(const projectpotato::core::ServiceCommand& command) = 0;
};

} // namespace projectpotato::services
