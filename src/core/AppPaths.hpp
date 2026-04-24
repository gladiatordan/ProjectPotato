#pragma once

#include <QString>

namespace projectpotato::core {

class AppPaths final {
public:
    AppPaths() = default;

    static AppPaths fromApplicationDir();

    bool ensureRuntimeDirectories(QString* errorMessage = nullptr) const;

    const QString& rootPath() const;
    const QString& assetsPath() const;
    const QString& configsPath() const;
    const QString& potatoBoxConfigPath() const;
    const QString& crashesPath() const;
    const QString& gwCrashPath() const;
    const QString& logsPath() const;
    QString mainLogFilePath() const;

private:
    explicit AppPaths(QString rootPath);

    void initializeDerivedPaths();

    QString rootPath_;
    QString assetsPath_;
    QString configsPath_;
    QString potatoBoxConfigPath_;
    QString crashesPath_;
    QString gwCrashPath_;
    QString logsPath_;
};

} // namespace projectpotato::core
