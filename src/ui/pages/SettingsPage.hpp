#pragma once

#include <QWidget>

class QListWidget;
class QPushButton;

namespace projectpotato::ui::pages {

class SettingsPage final : public QWidget {
    Q_OBJECT

public:
    explicit SettingsPage(QWidget* parent = nullptr);

    void setServiceStatuses(const QStringList& statuses);

signals:
    void emitTestLogBurstRequested();
    void pingServicesRequested();
    void clearGuiLogRequested();
    void openLogsFolderRequested();

private:
    QListWidget* statusList_{nullptr};
    QPushButton* emitTestLogsButton_{nullptr};
    QPushButton* pingServicesButton_{nullptr};
    QPushButton* clearGuiLogButton_{nullptr};
    QPushButton* openLogsFolderButton_{nullptr};
};

} // namespace projectpotato::ui::pages
