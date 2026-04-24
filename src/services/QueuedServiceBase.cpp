#include "services/QueuedServiceBase.hpp"

namespace projectpotato::services {

QueuedServiceBase::QueuedServiceBase(
    QString serviceName,
    LogService& logService,
    const uint32_t heartbeatSeconds)
    : serviceName_(std::move(serviceName))
    , logService_(logService)
    , heartbeatInterval_(std::chrono::seconds(heartbeatSeconds)) {
}

QueuedServiceBase::~QueuedServiceBase() {
    stop();
}

QString QueuedServiceBase::name() const {
    return serviceName_;
}

bool QueuedServiceBase::start() {
    if (running_.exchange(true)) {
        return false;
    }

    workerThread_ = std::jthread([this](std::stop_token stopToken) {
        process(stopToken);
    });
    return true;
}

void QueuedServiceBase::stop() {
    if (!running_.exchange(false)) {
        return;
    }

    postCommand({
        .type = projectpotato::core::ServiceCommandType::Shutdown,
        .origin = "ServiceManager",
        .payload = QString("%1 stop requested").arg(serviceName_),
        .value = 0,
    });

    if (workerThread_.joinable()) {
        queue_.notifyAll();
        workerThread_.join();
    }
}

bool QueuedServiceBase::isRunning() const {
    return running_.load();
}

void QueuedServiceBase::postCommand(const projectpotato::core::ServiceCommand& command) {
    queue_.push(command);
}

void QueuedServiceBase::log(const LogLevel level, const QString& message) const {
    logService_.submit(level, serviceName_, message);
}

void QueuedServiceBase::onStarted() {
    log(LogLevel::Info, "Service started.");
}

void QueuedServiceBase::onStopped() {
    log(LogLevel::Info, "Service stopped.");
}

void QueuedServiceBase::onHeartbeat() {
    log(LogLevel::Debug, "Heartbeat.");
}

void QueuedServiceBase::process(std::stop_token stopToken) {
    onStarted();

    bool shouldContinue = true;
    while (shouldContinue) {
        projectpotato::core::ServiceCommand command;
        const bool hasCommand =
            queue_.waitPopFor(command, heartbeatInterval_, stopToken);

        if (hasCommand) {
            shouldContinue = handleCommand(command);
            continue;
        }

        if (stopToken.stop_requested()) {
            break;
        }

        onHeartbeat();
    }

    onStopped();
}

bool QueuedServiceBase::handleCommand(const projectpotato::core::ServiceCommand& command) {
    switch (command.type) {
    case projectpotato::core::ServiceCommandType::Ping:
        log(LogLevel::Debug,
            QString("Ping received from %1.").arg(command.origin));
        return true;
    case projectpotato::core::ServiceCommandType::EmitTestLog: {
        const uint32_t burstCount = command.value == 0U ? 3U : command.value;
        for (uint32_t index = 0; index < burstCount; ++index) {
            log(LogLevel::Info,
                QString("Test log %1/%2 from %3. %4")
                    .arg(index + 1U)
                    .arg(burstCount)
                    .arg(command.origin)
                    .arg(command.payload));
        }
        return true;
    }
    case projectpotato::core::ServiceCommandType::Shutdown:
        log(LogLevel::Info,
            QString("Shutdown command received from %1.").arg(command.origin));
        return false;
    case projectpotato::core::ServiceCommandType::LaunchSelected:
    case projectpotato::core::ServiceCommandType::CheckUpdates:
    case projectpotato::core::ServiceCommandType::UpdateAll:
        return handleCustomCommand(command);
    }

    return true;
}

} // namespace projectpotato::services
