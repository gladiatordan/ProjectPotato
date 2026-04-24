#include "ui/delegates/CharacterComboDelegate.hpp"

#include <QComboBox>
#include <QPainter>

#include "ui/models/AccountTableModel.hpp"

namespace projectpotato::ui::delegates {

CharacterComboDelegate::CharacterComboDelegate(QObject* parent)
    : QStyledItemDelegate(parent) {
}

QWidget* CharacterComboDelegate::createEditor(
    QWidget* parent,
    const QStyleOptionViewItem&,
    const QModelIndex& index) const {
    auto* comboBox = new QComboBox(parent);
    comboBox->addItems(index.data(projectpotato::ui::models::AccountTableModel::CharacterOptionsRole)
                           .toStringList());
    comboBox->setObjectName("CharacterDropdownEditor");
    return comboBox;
}

void CharacterComboDelegate::paint(
    QPainter* painter,
    const QStyleOptionViewItem& option,
    const QModelIndex& index) const {
    static const QPixmap background(":/assets/inputs/dropdown_normal.png");

    painter->save();
    painter->setRenderHint(QPainter::SmoothPixmapTransform, true);

    const QRect dropdownRect = option.rect.adjusted(10, 6, -10, -6);
    painter->drawPixmap(dropdownRect, background);

    painter->setPen(QColor(240, 230, 208));
    painter->drawText(dropdownRect.adjusted(14, 0, -34, 0), Qt::AlignVCenter | Qt::AlignLeft,
        index.data(Qt::DisplayRole).toString());

    painter->restore();
}

void CharacterComboDelegate::setEditorData(QWidget* editor, const QModelIndex& index) const {
    auto* comboBox = qobject_cast<QComboBox*>(editor);
    if (comboBox == nullptr) {
        return;
    }

    const QString currentValue = index.data(Qt::DisplayRole).toString();
    const int comboIndex = comboBox->findText(currentValue);
    comboBox->setCurrentIndex(comboIndex >= 0 ? comboIndex : 0);
}

void CharacterComboDelegate::setModelData(
    QWidget* editor,
    QAbstractItemModel* model,
    const QModelIndex& index) const {
    auto* comboBox = qobject_cast<QComboBox*>(editor);
    if (comboBox == nullptr || model == nullptr) {
        return;
    }

    model->setData(index, comboBox->currentText(), Qt::EditRole);
}

} // namespace projectpotato::ui::delegates
