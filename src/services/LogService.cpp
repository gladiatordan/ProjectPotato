#include "services/LogService.hpp"

#include <chrono>

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>

namespace projectpotato::services {

QString logLevelToString(const LogLevel level) {
    switch (level) {
    case LogLevel::Trace:
        return "Trace";
    case LogLevel::Debug:
        return "Debug";
    case LogLevel::Info:
        return "Info";
    case LogLevel::Warning:
        return "Warning";
    case LogLevel::Error:
        return "Error";
    case LogLevel::Critical:
        return "Critical";
    }

    return "Info";
}

LogService::LogService(const projectpotato::core::AppPaths& appPaths)
    : appPaths_(appPaths) {
}

LogService::~LogService() {
    stop();
}

QString LogService::name() const {
    return "LogService";
}

bool LogService::start() {
    if (running_.exchange(true)) {
        return false;
    }

    workerThread_ = std::jthread([this](std::stop_token stopToken) {
        process(stopToken);
    });
    return true;
}

void LogService::stop() {
    if (!running_.exchange(false)) {
        return;
    }

    postCommand({
        .type = projectpotato::core::ServiceCommandType::Shutdown,
        .origin = "ServiceManager",
        .payload = "LogService stopping",
        .value = 0,
    });

    if (workerThread_.joinable()) {
        queue_.notifyAll();
        workerThread_.join();
    }
}

bool LogService::isRunning() const {
    return running_.load();
}

void LogService::postCommand(const projectpotato::core::ServiceCommand& command) {
    queue_.push(QueueItem{
        .type = QueueItemType::Command,
        .logEvent = {},
        .command = command,
    });
}

void LogService::submit(const LogLevel level, const QString& source, const QString& message) {
    queue_.push(QueueItem{
        .type = QueueItemType::LogEvent,
        .logEvent = createEvent(level, source, message),
        .command = {},
    });
}

void LogService::setGuiForwarder(std::function<void(const LogEvent&)> forwarder) {
    std::scoped_lock<std::mutex> lock(forwarderMutex_);
    guiForwarder_ = std::move(forwarder);
}

QString LogService::logFilePath() const {
    return appPaths_.mainLogFilePath();
}

void LogService::process(std::stop_token stopToken) {
    writeEvent(createEvent(LogLevel::Info, name(), "Log service started."));

    bool shouldContinue = true;
    while (shouldContinue) {
        QueueItem item;
        const bool hasItem = queue_.waitPopFor(item, std::chrono::milliseconds(250), stopToken);

        if (!hasItem) {
            if (stopToken.stop_requested() && queue_.empty()) {
                break;
            }
            continue;
        }

        if (item.type == QueueItemType::LogEvent) {
            writeEvent(item.logEvent);
            continue;
        }

        shouldContinue = handleCommand(item.command);
    }

    writeEvent(createEvent(LogLevel::Info, name(), "Log service stopped."));
}

bool LogService::handleCommand(const projectpotato::core::ServiceCommand& command) {
    switch (command.type) {
    case projectpotato::core::ServiceCommandType::Ping:
        writeEvent(createEvent(LogLevel::Debug, name(),
            QString("Ping received from %1.").arg(command.origin)));
        return true;
    case projectpotato::core::ServiceCommandType::EmitTestLog: {
        const uint32_t burstCount = command.value == 0U ? 6U : command.value;
        for (uint32_t index = 0; index < burstCount; ++index) {
            const LogLevel level = static_cast<LogLevel>(index % 6U);
            writeEvent(createEvent(level, command.origin.isEmpty() ? name() : command.origin,
                QString("Test burst line %1 from LogService. %2")
                    .arg(index + 1U)
                    .arg(command.payload)));
        }
        return true;
    }
    case projectpotato::core::ServiceCommandType::Shutdown:
        writeEvent(createEvent(LogLevel::Info, name(),
            QString("Shutdown command received from %1.").arg(command.origin)));
        return false;
    case projectpotato::core::ServiceCommandType::LaunchSelected:
    case projectpotato::core::ServiceCommandType::CheckUpdates:
    case projectpotato::core::ServiceCommandType::UpdateAll:
        writeEvent(createEvent(LogLevel::Trace, name(),
            QString("Ignoring non-log command %1 from %2.")
                .arg(projectpotato::core::serviceCommandTypeToString(command.type))
                .arg(command.origin)));
        return true;
    }

    return true;
}

void LogService::writeEvent(const LogEvent& event) {
    const QByteArray encodedLine = QString("%1\n").arg(event.formattedLine).toUtf8();
    rotateIfNeeded(encodedLine);

    QFile logFile(logFilePath());
    if (logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        logFile.write(encodedLine);
        logFile.close();
    }

    forwardToGui(event);
}

void LogService::forwardToGui(const LogEvent& event) {
    std::function<void(const LogEvent&)> forwarderCopy;
    {
        std::scoped_lock<std::mutex> lock(forwarderMutex_);
        forwarderCopy = guiForwarder_;
    }

    if (forwarderCopy) {
        forwarderCopy(event);
    }
}

void LogService::rotateIfNeeded(const QByteArray& encodedLine) {
    QFileInfo info(logFilePath());
    if (!info.exists()) {
        return;
    }

    const qint64 currentSize = info.size();
    if (currentSize < 0) {
        return;
    }

    if (currentSize + encodedLine.size() <= static_cast<qint64>(maxLogBytes_)) {
        return;
    }

    QDir logDirectory(appPaths_.logsPath());
    const uint32_t highestArchiveIndex = maxLogFiles_ > 0U ? maxLogFiles_ - 1U : 0U;

    if (highestArchiveIndex > 0U) {
        const QString oldestFilePath =
            logDirectory.filePath(QString("ProjectPotato_%1.log").arg(highestArchiveIndex));
        QFile::remove(oldestFilePath);

        for (uint32_t index = highestArchiveIndex; index > 1U; --index) {
            const QString sourcePath =
                logDirectory.filePath(QString("ProjectPotato_%1.log").arg(index - 1U));
            const QString targetPath =
                logDirectory.filePath(QString("ProjectPotato_%1.log").arg(index));
            if (QFile::exists(sourcePath)) {
                QFile::remove(targetPath);
                QFile::rename(sourcePath, targetPath);
            }
        }

        const QString archivePath = logDirectory.filePath("ProjectPotato_1.log");
        QFile::remove(archivePath);
        QFile::rename(logFilePath(), archivePath);
    } else {
        QFile::remove(logFilePath());
    }
}

LogEvent LogService::createEvent(
    const LogLevel level,
    const QString& source,
    const QString& message) const {
    const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss.zzz");
    const QString formattedLine = QString("[%1] [%2] [%3] %4")
                                      .arg(timestamp, logLevelToString(level), source, message);
    return LogEvent{
        .level = level,
        .source = source,
        .message = message,
        .timestamp = timestamp,
        .formattedLine = formattedLine,
    };
}

} // namespace projectpotato::services
