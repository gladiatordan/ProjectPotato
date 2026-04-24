#pragma once

#include <QWidget>

class QButtonGroup;

namespace projectpotato::ui::widgets {

class PotatoSidebar final : public QWidget {
    Q_OBJECT

public:
    explicit PotatoSidebar(QWidget* parent = nullptr);

    void setCurrentIndex(int index);

signals:
    void pageSelected(int index);

private:
    QButtonGroup* buttonGroup_{nullptr};
};

} // namespace projectpotato::ui::widgets
