#pragma once

#include <QWidget>

class QPushButton;
class QTableView;

namespace projectpotato::ui::delegates {
class ActionButtonDelegate;
class CharacterComboDelegate;
}

namespace projectpotato::ui::models {
class AccountTableModel;
}

namespace projectpotato::ui::widgets {
class LogConsole;
}

namespace projectpotato::ui::pages {

class LauncherPage final : public QWidget {
    Q_OBJECT

public:
    explicit LauncherPage(QWidget* parent = nullptr);

    void appendLogLine(const QString& line);
    void clearLogConsole();

signals:
    void launchSelectedRequested(const QStringList& accounts);
    void checkUpdatesRequested();
    void updateAllRequested();
    void rowLaunchRequested(const QString& accountName);
    void rowUpdateRequested(const QString& accountName);

private:
    void configureTable();

    QTableView* accountTable_{nullptr};
    QPushButton* launchSelectedButton_{nullptr};
    QPushButton* checkUpdatesButton_{nullptr};
    QPushButton* updateAllButton_{nullptr};
    projectpotato::ui::models::AccountTableModel* model_{nullptr};
    projectpotato::ui::delegates::CharacterComboDelegate* characterDelegate_{nullptr};
    projectpotato::ui::delegates::ActionButtonDelegate* launchDelegate_{nullptr};
    projectpotato::ui::delegates::ActionButtonDelegate* updateDelegate_{nullptr};
    projectpotato::ui::widgets::LogConsole* logConsole_{nullptr};
};

} // namespace projectpotato::ui::pages
