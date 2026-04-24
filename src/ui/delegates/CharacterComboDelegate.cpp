#include "ui/delegates/CharacterComboDelegate.hpp"

#include <QComboBox>

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
    return comboBox;
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
