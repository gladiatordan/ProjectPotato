#pragma once

#include <QWidget>

class QListWidget;

namespace projectpotato::ui::pages {

class WorkersPage final : public QWidget {
    Q_OBJECT

public:
    explicit WorkersPage(QWidget* parent = nullptr);

    void setServiceStatuses(const QStringList& statuses);

private:
    QListWidget* statusList_{nullptr};
};

} // namespace projectpotato::ui::pages
