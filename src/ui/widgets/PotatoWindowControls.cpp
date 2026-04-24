#include "ui/widgets/PotatoWindowControls.hpp"

#include <QHBoxLayout>
#include <QPushButton>
#include <QStyle>

namespace projectpotato::ui::widgets {

PotatoWindowControls::PotatoWindowControls(QWidget* parent)
    : QWidget(parent) {
    auto* layout = new QHBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(6);

    minimizeButton_ = new QPushButton(this);
    maximizeButton_ = new QPushButton(this);
    closeButton_ = new QPushButton(this);

    minimizeButton_->setObjectName("MinimizeButton");
    maximizeButton_->setObjectName("MaximizeButton");
    closeButton_->setObjectName("CloseButton");

    for (QPushButton* button : {minimizeButton_, maximizeButton_, closeButton_}) {
        button->setProperty("class", "windowControl");
        button->setText({});
        button->setCursor(Qt::PointingHandCursor);
        button->setFocusPolicy(Qt::NoFocus);
        button->setFlat(true);
        button->setFixedSize(58, 42);
        layout->addWidget(button);
    }

    connect(minimizeButton_, &QPushButton::clicked, this, &PotatoWindowControls::minimizeRequested);
    connect(maximizeButton_, &QPushButton::clicked, this, &PotatoWindowControls::toggleMaximizeRequested);
    connect(closeButton_, &QPushButton::clicked, this, &PotatoWindowControls::closeRequested);
}

void PotatoWindowControls::setMaximized(const bool maximized) {
    maximizeButton_->setProperty("windowMaximized", maximized);
    maximizeButton_->style()->unpolish(maximizeButton_);
    maximizeButton_->style()->polish(maximizeButton_);
    maximizeButton_->update();
}

} // namespace projectpotato::ui::widgets
