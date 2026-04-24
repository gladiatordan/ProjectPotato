#include "ui/widgets/PotatoSidebar.hpp"

#include <QAbstractButton>
#include <QButtonGroup>
#include <QPushButton>
#include <QVBoxLayout>

namespace projectpotato::ui::widgets {

PotatoSidebar::PotatoSidebar(QWidget* parent)
    : QWidget(parent) {
    setObjectName("SidebarRoot");
    setMinimumWidth(278);
    setMaximumWidth(298);

    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(8, 16, 8, 28);
    layout->setSpacing(12);

    buttonGroup_ = new QButtonGroup(this);
    buttonGroup_->setExclusive(true);

    const struct {
        const char* objectName;
        const char* label;
        QPushButton** outButton;
    } buttonConfigs[] = {
        {"SidebarLauncherButton", "Launcher", &launcherButton_},
        {"SidebarWorkersButton", "Workers", &workersButton_},
        {"SidebarSettingsButton", "Settings", &settingsButton_},
    };

    for (int index = 0; index < 3; ++index) {
        auto* button = new QPushButton(QString::fromUtf8(buttonConfigs[index].label), this);
        button->setObjectName(QString::fromUtf8(buttonConfigs[index].objectName));
        button->setProperty("class", "sidebarButton");
        button->setCheckable(true);
        button->setCursor(Qt::PointingHandCursor);
        button->setFocusPolicy(Qt::NoFocus);
        button->setMinimumHeight(71);
        button->setMaximumHeight(71);
        layout->addWidget(button, 0, Qt::AlignHCenter);
        buttonGroup_->addButton(button, index);
        *buttonConfigs[index].outButton = button;
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
