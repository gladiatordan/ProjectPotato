#include "ui/widgets/PotatoSidebar.hpp"

#include <QAbstractButton>
#include <QButtonGroup>
#include <QPushButton>
#include <QVBoxLayout>

namespace projectpotato::ui::widgets {

PotatoSidebar::PotatoSidebar(QWidget* parent)
    : QWidget(parent) {
    setObjectName("SidebarRoot");
    setMinimumWidth(220);
    setMaximumWidth(260);

    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 28, 20, 28);
    layout->setSpacing(10);

    buttonGroup_ = new QButtonGroup(this);
    buttonGroup_->setExclusive(true);

    const QStringList labels{"Launcher", "Workers", "Settings"};
    for (int index = 0; index < labels.count(); ++index) {
        auto* button = new QPushButton(labels.at(index), this);
        button->setProperty("class", "sidebarButton");
        button->setCheckable(true);
        button->setMinimumHeight(52);
        layout->addWidget(button);
        buttonGroup_->addButton(button, index);
    }

    layout->addStretch(1);

    connect(buttonGroup_, &QButtonGroup::idClicked, this, &PotatoSidebar::pageSelected);
    setCurrentIndex(0);
}

void PotatoSidebar::setCurrentIndex(const int index) {
    if (QAbstractButton* button = buttonGroup_->button(index)) {
        button->setChecked(true);
    }
}

} // namespace projectpotato::ui::widgets
