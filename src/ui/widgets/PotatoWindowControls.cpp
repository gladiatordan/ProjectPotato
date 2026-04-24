#include "ui/widgets/PotatoWindowControls.hpp"

#include <QHBoxLayout>
#include <QPushButton>

namespace projectpotato::ui::widgets {

PotatoWindowControls::PotatoWindowControls(QWidget* parent)
    : QWidget(parent) {
    auto* layout = new QHBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(8);

    minimizeButton_ = new QPushButton("-", this);
    maximizeButton_ = new QPushButton("[]", this);
    closeButton_ = new QPushButton("X", this);

    for (QPushButton* button : {minimizeButton_, maximizeButton_, closeButton_}) {
        button->setProperty("class", "windowControl");
        button->setFixedSize(42, 30);
        layout->addWidget(button);
    }

    closeButton_->setProperty("danger", true);

    connect(minimizeButton_, &QPushButton::clicked, this, &PotatoWindowControls::minimizeRequested);
    connect(maximizeButton_, &QPushButton::clicked, this, &PotatoWindowControls::toggleMaximizeRequested);
    connect(closeButton_, &QPushButton::clicked, this, &PotatoWindowControls::closeRequested);
}

void PotatoWindowControls::setMaximized(const bool maximized) {
    maximizeButton_->setText(maximized ? "o" : "[]");
}

} // namespace projectpotato::ui::widgets
