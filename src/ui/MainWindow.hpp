#pragma once

#include <QMainWindow>

namespace projectpotato::ui::pages {
class LauncherPage;
class SettingsPage;
class WorkersPage;
}

namespace projectpotato::ui::widgets {
class PotatoHeader;
class PotatoSidebar;
}

class QStackedWidget;

namespace projectpotato::ui {

class MainWindow final : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = nullptr);

    pages::LauncherPage* launcherPage() const;
    pages::WorkersPage* workersPage() const;
    pages::SettingsPage* settingsPage() const;

protected:
    bool nativeEvent(const QByteArray& eventType, void* message, qintptr* result) override;
    void changeEvent(QEvent* event) override;

private:
    widgets::PotatoHeader* header_{nullptr};
    widgets::PotatoSidebar* sidebar_{nullptr};
    QStackedWidget* pageStack_{nullptr};
    pages::LauncherPage* launcherPage_{nullptr};
    pages::WorkersPage* workersPage_{nullptr};
    pages::SettingsPage* settingsPage_{nullptr};
};

} // namespace projectpotato::ui
