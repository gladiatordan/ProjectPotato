#pragma once

#include <QObject>
#include <QTimer>

#include "core/AppPaths.hpp"
#include "services/ServiceManager.hpp"

namespace projectpotato::ui {

class MainWindow;

class MainController final : public QObject {
    Q_OBJECT

public:
    explicit MainController(const projectpotato::core::AppPaths& appPaths, QObject* parent = nullptr);
    ~MainController() override;

    void bindMainWindow(MainWindow* mainWindow);
    bool initialize();
    void shutdown();

signals:
    void appendLogLineRequested(const QString& line);
    void serviceStatusesChanged(const QStringList& statuses);

private:
    QStringList formatServiceStatuses() const;
    void publishServiceStatuses();

    projectpotato::core::AppPaths appPaths_;
    projectpotato::services::ServiceManager serviceManager_;
    MainWindow* mainWindow_{nullptr};
    QTimer statusTimer_;
    bool initialized_{false};
};

} // namespace projectpotato::ui
