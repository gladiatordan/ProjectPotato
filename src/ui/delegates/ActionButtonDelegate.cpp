#include "ui/delegates/ActionButtonDelegate.hpp"

#include <QApplication>
#include <QMouseEvent>
#include <QPainter>
#include <QStyle>
#include <QStyleOptionButton>

namespace projectpotato::ui::delegates {

ActionButtonDelegate::ActionButtonDelegate(QObject* parent)
    : QStyledItemDelegate(parent) {
}

void ActionButtonDelegate::paint(
    QPainter* painter,
    const QStyleOptionViewItem& option,
    const QModelIndex& index) const {
    QStyleOptionButton buttonOption;
    buttonOption.rect = option.rect.adjusted(8, 6, -8, -6);
    buttonOption.state = QStyle::State_Enabled;
    if (option.state & QStyle::State_MouseOver) {
        buttonOption.state |= QStyle::State_MouseOver;
    }
    buttonOption.text = index.data(Qt::DisplayRole).toString();

    QApplication::style()->drawControl(QStyle::CE_PushButton, &buttonOption, painter);
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
