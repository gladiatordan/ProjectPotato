#include "core/AppPaths.hpp"

#include <QCoreApplication>
#include <QDir>

namespace projectpotato::core {

AppPaths::AppPaths(QString rootPath)
    : rootPath_(std::move(rootPath)) {
    initializeDerivedPaths();
}

AppPaths AppPaths::fromApplicationDir() {
    return AppPaths(QCoreApplication::applicationDirPath());
}

bool AppPaths::ensureRuntimeDirectories(QString* errorMessage) const {
    QDir rootDirectory(rootPath_);
    const QStringList requiredPaths{
        assetsPath_,
        configsPath_,
        potatoBoxConfigPath_,
        crashesPath_,
        gwCrashPath_,
        logsPath_,
    };

    for (const QString& path : requiredPaths) {
        if (!rootDirectory.mkpath(path)) {
            if (errorMessage != nullptr) {
                *errorMessage = QString("Failed to create runtime directory: %1").arg(path);
            }
            return false;
        }
    }

    return true;
}

const QString& AppPaths::rootPath() const {
    return rootPath_;
}

const QString& AppPaths::assetsPath() const {
    return assetsPath_;
}

const QString& AppPaths::configsPath() const {
    return configsPath_;
}

const QString& AppPaths::potatoBoxConfigPath() const {
    return potatoBoxConfigPath_;
}

const QString& AppPaths::crashesPath() const {
    return crashesPath_;
}

const QString& AppPaths::gwCrashPath() const {
    return gwCrashPath_;
}

const QString& AppPaths::logsPath() const {
    return logsPath_;
}

QString AppPaths::mainLogFilePath() const {
    return QDir(logsPath_).filePath("ProjectPotato.log");
}

void AppPaths::initializeDerivedPaths() {
    QDir rootDirectory(rootPath_);
    assetsPath_ = rootDirectory.filePath("assets");
    configsPath_ = rootDirectory.filePath("configs");
    potatoBoxConfigPath_ = rootDirectory.filePath("configs/PotatoBox");
    crashesPath_ = rootDirectory.filePath("crashes");
    gwCrashPath_ = rootDirectory.filePath("crashes/gw");
    logsPath_ = rootDirectory.filePath("logs");
}

} // namespace projectpotato::core
