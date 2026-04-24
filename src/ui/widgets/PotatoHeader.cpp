#include "ui/widgets/PotatoHeader.hpp"

#include <QHBoxLayout>
#include <QLabel>
#include <QPainter>
#include <QPixmap>
#include <QVBoxLayout>

#include "ui/widgets/PotatoWindowControls.hpp"

namespace projectpotato::ui::widgets {

PotatoHeader::PotatoHeader(QWidget* parent)
    : QWidget(parent) {
    setObjectName("PotatoHeader");
    setMinimumHeight(132);
    setMaximumHeight(132);

    auto* layout = new QHBoxLayout(this);
    layout->setContentsMargins(24, 18, 18, 18);
    layout->setSpacing(18);

    logoLabel_ = new QLabel(this);
    logoLabel_->setFixedSize(76, 76);
    logoLabel_->setPixmap(QPixmap(":/projectpotato_logo.png")
                              .scaled(76, 76, Qt::KeepAspectRatio, Qt::SmoothTransformation));

    titleLabel_ = new QLabel("ProjectPotato", this);
    titleLabel_->setObjectName("HeaderTitle");

    subtitleLabel_ = new QLabel("Portable launcher shell, diagnostics harness, and service console", this);
    subtitleLabel_->setObjectName("HeaderSubtitle");

    auto* textLayout = new QVBoxLayout();
    textLayout->setContentsMargins(0, 4, 0, 0);
    textLayout->setSpacing(6);
    textLayout->addWidget(titleLabel_);
    textLayout->addWidget(subtitleLabel_);
    textLayout->addStretch(1);

    auto* textContainer = new QWidget(this);
    textContainer->setLayout(textLayout);

    windowControls_ = new PotatoWindowControls(this);

    layout->addWidget(logoLabel_, 0, Qt::AlignTop);
    layout->addWidget(textContainer, 1);
    layout->addWidget(windowControls_, 0, Qt::AlignTop);
}

bool PotatoHeader::containsInteractiveControl(const QPoint& localPosition) const {
    return windowControls_->geometry().contains(localPosition);
}

PotatoWindowControls* PotatoHeader::windowControls() const {
    return windowControls_;
}

void PotatoHeader::paintEvent(QPaintEvent* event) {
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, true);

    QLinearGradient backgroundGradient(rect().topLeft(), rect().bottomLeft());
    backgroundGradient.setColorAt(0.0, QColor(48, 29, 18, 245));
    backgroundGradient.setColorAt(0.45, QColor(18, 18, 24, 220));
    backgroundGradient.setColorAt(1.0, QColor(10, 11, 15, 255));
    painter.fillRect(rect(), backgroundGradient);

    const QPixmap banner(":/projectpotato_headerbanner.png");
    if (!banner.isNull()) {
        painter.setOpacity(0.23);
        painter.drawPixmap(rect(), banner);
        painter.setOpacity(1.0);
    }

    QLinearGradient edgeGlow(rect().topLeft(), rect().topRight());
    edgeGlow.setColorAt(0.0, QColor(176, 124, 67, 210));
    edgeGlow.setColorAt(1.0, QColor(79, 141, 181, 170));
    painter.fillRect(QRect(0, height() - 3, width(), 3), edgeGlow);

    QWidget::paintEvent(event);
}

} // namespace projectpotato::ui::widgets
