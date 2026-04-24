#include "ui/widgets/PotatoHeader.hpp"

#include <QHBoxLayout>
#include <QPainter>

#include "ui/widgets/PotatoWindowControls.hpp"

namespace projectpotato::ui::widgets {

PotatoHeader::PotatoHeader(QWidget* parent)
    : QWidget(parent)
    , headerArt_(":/assets/header/projectpotato_header_full.png") {
    setObjectName("PotatoHeader");
    setMinimumHeight(236);
    setMaximumHeight(236);

    auto* layout = new QHBoxLayout(this);
    layout->setContentsMargins(18, 16, 18, 18);
    layout->setSpacing(0);

    windowControls_ = new PotatoWindowControls(this);

    layout->addStretch(1);
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
    painter.setRenderHint(QPainter::SmoothPixmapTransform, true);

    painter.fillRect(rect(), QColor(6, 8, 12));

    if (!headerArt_.isNull()) {
        const QRect sourceRect(44, 12, headerArt_.width() - 214, headerArt_.height() - 26);
        const QRect targetRect(10, 0, width() - 104, height() - 8);
        painter.drawPixmap(targetRect, headerArt_, sourceRect);
    }

    painter.fillRect(QRect(width() - 188, 12, 176, 52), QColor(5, 7, 10, 210));

    QWidget::paintEvent(event);
}

} // namespace projectpotato::ui::widgets
