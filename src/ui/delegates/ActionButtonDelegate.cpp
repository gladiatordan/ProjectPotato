#include "ui/delegates/ActionButtonDelegate.hpp"

#include <QMouseEvent>
#include <QPainter>

#include "ui/models/AccountTableModel.hpp"

namespace projectpotato::ui::delegates {

ActionButtonDelegate::ActionButtonDelegate(QObject* parent)
    : QStyledItemDelegate(parent) {
}

void ActionButtonDelegate::paint(
    QPainter* painter,
    const QStyleOptionViewItem& option,
    const QModelIndex& index) const {
    const bool hovered = (option.state & QStyle::State_MouseOver) != 0;
    const bool isLaunch =
        index.column() == projectpotato::ui::models::AccountTableModel::LaunchColumn;
    const QPixmap asset = QPixmap(
        isLaunch
            ? (hovered ? ":/assets/buttons/launch_hover.png" : ":/assets/buttons/launch_normal.png")
            : (hovered ? ":/assets/buttons/update_hover.png" : ":/assets/buttons/update_normal.png"));

    painter->save();
    painter->setRenderHint(QPainter::SmoothPixmapTransform, true);
    painter->drawPixmap(option.rect.adjusted(8, 7, -8, -7), asset);
    painter->restore();
}

bool ActionButtonDelegate::editorEvent(
    QEvent* event,
    QAbstractItemModel*,
    const QStyleOptionViewItem& option,
    const QModelIndex& index) {
    if (event == nullptr) {
        return false;
    }

    if (event->type() == QEvent::MouseButtonRelease) {
        auto* mouseEvent = static_cast<QMouseEvent*>(event);
        const QRect buttonRect = option.rect.adjusted(8, 6, -8, -6);
        if (buttonRect.contains(mouseEvent->position().toPoint())) {
            emit buttonClicked(index.row(), index.column());
            return true;
        }
    }

    if (event->type() == QEvent::MouseButtonDblClick) {
        return true;
    }

    return false;
}

} // namespace projectpotato::ui::delegates
