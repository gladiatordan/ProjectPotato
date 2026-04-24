#pragma once

#include <QStyledItemDelegate>

namespace projectpotato::ui::delegates {

class CharacterComboDelegate final : public QStyledItemDelegate {
    Q_OBJECT

public:
    explicit CharacterComboDelegate(QObject* parent = nullptr);

    QWidget* createEditor(
        QWidget* parent,
        const QStyleOptionViewItem& option,
        const QModelIndex& index) const override;
    void paint(
        QPainter* painter,
        const QStyleOptionViewItem& option,
        const QModelIndex& index) const override;
    void setEditorData(QWidget* editor, const QModelIndex& index) const override;
    void setModelData(
        QWidget* editor,
        QAbstractItemModel* model,
        const QModelIndex& index) const override;
};

} // namespace projectpotato::ui::delegates
