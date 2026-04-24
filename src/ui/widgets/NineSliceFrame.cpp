#include "ui/widgets/NineSliceFrame.hpp"

#include <QPainter>

namespace projectpotato::ui::widgets {

namespace {

QString skinPrefix(const NineSliceFrame::Skin skin) {
    switch (skin) {
    case NineSliceFrame::Skin::Main:
        return ":/assets/borders/main";
    case NineSliceFrame::Skin::Panel:
        return ":/assets/borders/panel";
    }

    return ":/assets/borders/panel";
}

QPixmap loadPiece(const QString& prefix, const QString& name) {
    return QPixmap(QString("%1/%2").arg(prefix, name));
}

} // namespace

NineSliceFrame::NineSliceFrame(const Skin skin, QWidget* parent)
    : QWidget(parent) {
    setAttribute(Qt::WA_OpaquePaintEvent, false);
    setAttribute(Qt::WA_StyledBackground, false);
    loadSkin(skin);
}

void NineSliceFrame::paintEvent(QPaintEvent* event) {
    Q_UNUSED(event);

    if (topLeft_.isNull() || center_.isNull()) {
        return;
    }

    QPainter painter(this);
    painter.setRenderHint(QPainter::SmoothPixmapTransform, true);

    const int leftWidth = topLeft_.width();
    const int rightWidth = topRight_.width();
    const int topHeight = topLeft_.height();
    const int bottomHeight = bottomLeft_.height();
    const QRect frameRect = rect();
    const int centerWidth = qMax(0, frameRect.width() - leftWidth - rightWidth);
    const int centerHeight = qMax(0, frameRect.height() - topHeight - bottomHeight);

    painter.drawPixmap(0, 0, topLeft_);
    painter.drawPixmap(frameRect.width() - rightWidth, 0, topRight_);
    painter.drawPixmap(0, frameRect.height() - bottomHeight, bottomLeft_);
    painter.drawPixmap(frameRect.width() - rightWidth, frameRect.height() - bottomHeight, bottomRight_);

    painter.drawPixmap(QRect(leftWidth, 0, centerWidth, topHeight), top_);
    painter.drawPixmap(QRect(leftWidth, frameRect.height() - bottomHeight, centerWidth, bottomHeight), bottom_);
    painter.drawPixmap(QRect(0, topHeight, leftWidth, centerHeight), left_);
    painter.drawPixmap(QRect(frameRect.width() - rightWidth, topHeight, rightWidth, centerHeight), right_);
    painter.drawPixmap(QRect(leftWidth, topHeight, centerWidth, centerHeight), center_);
}

void NineSliceFrame::loadSkin(const Skin skin) {
    const QString prefix = skinPrefix(skin);
    topLeft_ = loadPiece(prefix, "tl.png");
    top_ = loadPiece(prefix, "t.png");
    topRight_ = loadPiece(prefix, "tr.png");
    left_ = loadPiece(prefix, "l.png");
    center_ = loadPiece(prefix, "c.png");
    right_ = loadPiece(prefix, "r.png");
    bottomLeft_ = loadPiece(prefix, "bl.png");
    bottom_ = loadPiece(prefix, "b.png");
    bottomRight_ = loadPiece(prefix, "br.png");
}

} // namespace projectpotato::ui::widgets
