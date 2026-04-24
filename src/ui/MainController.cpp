#include "ui/MainController.hpp"

#include <QDesktopServices>
#include <QMetaObject>
#include <QUrl>

#include "ui/MainWindow.hpp"
#include "ui/pages/LauncherPage.hpp"
#include "ui/pages/SettingsPage.hpp"
#include "ui/pages/WorkersPage.hpp"

namespace projectpotato::ui {

MainController::MainController(
    const projectpotato::core::AppPaths& appPaths,
    QObject* parent)
    : QObject(parent)
    , appPaths_(appPaths)
    , serviceManager_(appPaths_) {
    statusTimer_.setInterval(1500);
    connect(&statusTimer_, &QTimer::timeout, this, [this]() {
        publishServiceStatuses();
    });

    serviceManager_.setGuiLogForwarder([this](const projectpotato::services::LogEvent& event) {
        QMetaObject::invokeMethod(this, [this, event]() {
            emit appendLogLineRequested(event.formattedLine);
        }, Qt::QueuedConnection);
    });
}

MainController::~MainController() {
    shutdown();
}

void MainController::bindMainWindow(MainWindow* mainWindow) {
    mainWindow_ = mainWindow;
    if (mainWindow_ == nullptr) {
        return;
    }

    connect(this, &MainController::appendLogLineRequested,
        mainWindow_->launcherPage(), &pages::LauncherPage::appendLogLine);
    connect(this, &MainController::serviceStatusesChanged,
        mainWindow_->workersPage(), &pages::WorkersPage::setServiceStatuses);
    connect(this, &MainController::serviceStatusesChanged,
        mainWindow_->settingsPage(), &pages::SettingsPage::setServiceStatuses);

    connect(mainWindow_->launcherPage(), &pages::LauncherPage::launchSelectedRequested, this,
        [this](const QStringList& accounts) {
            if (accounts.isEmpty()) {
                serviceManager_.log(projectpotato::services::LogLevel::Warning, "MainController",
                    "Launch Selected requested without any checked accounts.");
                return;
            }

            serviceManager_.dispatchToService(projectpotato::core::ServiceId::Launcher, {
                .type = projectpotato::core::ServiceCommandType::LaunchSelected,
                .origin = "LauncherPage",
                .payload = accounts.join(", "),
                .value = static_cast<uint32_t>(accounts.count()),
            });
        });

    connect(mainWindow_->launcherPage(), &pages::LauncherPage::checkUpdatesRequested, this, [this]() {
        serviceManager_.dispatchToService(projectpotato::core::ServiceId::Update, {
            .type = projectpotato::core::ServiceCommandType::CheckUpdates,
            .origin = "LauncherPage",
            .payload = "All configured accounts",
            .value = 0,
        });
    });

    connect(mainWindow_->launcherPage(), &pages::LauncherPage::updateAllRequested, this, [this]() {
        serviceManager_.dispatchToService(projectpotato::core::ServiceId::Update, {
            .type = projectpotato::core::ServiceCommandType::UpdateAll,
            .origin = "LauncherPage",
            .payload = "Update all placeholder",
            .value = 0,
        });
    });

    connect(mainWindow_->launcherPage(), &pages::LauncherPage::rowLaunchRequested, this,
        [this](const QString& accountName) {
            serviceManager_.dispatchToService(projectpotato::core::ServiceId::Launcher, {
                .type = projectpotato::core::ServiceCommandType::LaunchSelected,
                .origin = "LauncherPage",
                .payload = accountName,
                .value = 1,
            });
        });

    connect(mainWindow_->launcherPage(), &pages::LauncherPage::rowUpdateRequested, this,
        [this](const QString& accountName) {
            serviceManager_.dispatchToService(projectpotato::core::ServiceId::Update, {
                .type = projectpotato::core::ServiceCommandType::CheckUpdates,
                .origin = "LauncherPage",
                .payload = accountName,
                .value = 1,
            });
        });

    connect(mainWindow_->settingsPage(), &pages::SettingsPage::emitTestLogBurstRequested, this, [this]() {
        serviceManager_.emitTestLogBurst(6U, "SettingsPage");
    });

    connect(mainWindow_->settingsPage(), &pages::SettingsPage::pingServicesRequested, this, [this]() {
        serviceManager_.pingAllServices("SettingsPage");
    });

    connect(mainWindow_->settingsPage(), &pages::SettingsPage::clearGuiLogRequested, this, [this]() {
        if (mainWindow_ != nullptr) {
            mainWindow_->launcherPage()->clearLogConsole();
        }
    });

    connect(mainWindow_->settingsPage(), &pages::SettingsPage::openLogsFolderRequested, this, [this]() {
        const bool opened = QDesktopServices::openUrl(
            QUrl::fromLocalFile(serviceManager_.logsDirectoryPath()));
        serviceManager_.log(
            opened ? projectpotato::services::LogLevel::Info : projectpotato::services::LogLevel::Warning,
            "MainController",
            opened ? "Opened logs folder in the shell." : "Failed to open the logs folder.");
    });
}

bool MainController::initialize() {
    if (initialized_) {
        return true;
    }

    initialized_ = serviceManager_.startAll();
    if (initialized_) {
        publishServiceStatuses();
        statusTimer_.start();
    }

    return initialized_;
}

void MainController::shutdown() {
    if (!initialized_) {
        return;
    }

    statusTimer_.stop();
    serviceManager_.stopAll();
    publishServiceStatuses();
    initialized_ = false;
}

QStringList MainController::formatServiceStatuses() const {
    QStringList statuses;
    const std::vector<projectpotato::services::ServiceStatusSnapshot> snapshots =
        serviceManager_.serviceStatuses();
    for (const projectpotato::services::ServiceStatusSnapshot& snapshot : snapshots) {
        statuses.append(QString("%1: %2")
                            .arg(snapshot.name, snapshot.running ? "Running" : "Stopped"));
    }

    return statuses;
}

void MainController::publishServiceStatuses() {
    emit serviceStatusesChanged(formatServiceStatuses());
}

} // namespace projectpotato::ui
