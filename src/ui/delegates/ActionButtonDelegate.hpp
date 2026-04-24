#pragma once

#include <QStyledItemDelegate>

namespace projectpotato::ui::delegates {

class ActionButtonDelegate final : public QStyledItemDelegate {
    Q_OBJECT

public:
    explicit ActionButtonDelegate(QObject* parent = nullptr);

    void paint(
        QPainter* painter,
        const QStyleOptionViewItem& option,
        const QModelIndex& index) const override;
    bool editorEvent(
        QEvent* event,
        QAbstractItemModel* model,
        const QStyleOptionViewItem& option,
        const QModelIndex& index) override;

signals:
    void buttonClicked(int row, int column);
};

} // namespace projectpotato::ui::delegates
