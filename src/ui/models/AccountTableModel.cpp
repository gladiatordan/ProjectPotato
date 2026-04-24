#include "ui/models/AccountTableModel.hpp"

namespace projectpotato::ui::models {

AccountTableModel::AccountTableModel(QObject* parent)
    : QAbstractTableModel(parent)
    , accounts_{
          {
              .selected = true,
              .accountName = "Nightfall Vanguard",
              .characters = {"None", "Mhenlo Prime", "Cynn Prime", "Dunkoro Prime"},
              .characterIndex = 1,
              .injectDlls = true,
              .injectMods = false,
          },
          {
              .selected = false,
              .accountName = "Ascalon Watch",
              .characters = {"None", "Gwen", "Livia", "Pyre Fierceshot"},
              .characterIndex = 0,
              .injectDlls = false,
              .injectMods = true,
          },
          {
              .selected = true,
              .accountName = "Kurzick Archive",
              .characters = {"None", "Vekk", "Razah", "Xandra"},
              .characterIndex = 2,
              .injectDlls = true,
              .injectMods = true,
          },
          {
              .selected = false,
              .accountName = "Ebon Vanguard",
              .characters = {"None", "Jora", "Ogden", "Koss"},
              .characterIndex = 0,
              .injectDlls = false,
              .injectMods = false,
          },
      } {
}

int AccountTableModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) {
        return 0;
    }

    return accounts_.count();
}

int AccountTableModel::columnCount(const QModelIndex& parent) const {
    if (parent.isValid()) {
        return 0;
    }

    return ColumnCount;
}

QVariant AccountTableModel::data(const QModelIndex& index, const int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= accounts_.count()) {
        return {};
    }

    const AccountRecord& account = accounts_.at(index.row());

    if (role == Qt::TextAlignmentRole) {
        if (index.column() == SelectedColumn
            || index.column() == InjectDllsColumn
            || index.column() == InjectModsColumn
            || index.column() == LaunchColumn
            || index.column() == UpdateColumn) {
            return static_cast<int>(Qt::AlignCenter);
        }
        return static_cast<int>(Qt::AlignVCenter | Qt::AlignLeft);
    }

    if (role == Qt::CheckStateRole) {
        if (index.column() == SelectedColumn) {
            return account.selected ? Qt::Checked : Qt::Unchecked;
        }
        if (index.column() == InjectDllsColumn) {
            return account.injectDlls ? Qt::Checked : Qt::Unchecked;
        }
        if (index.column() == InjectModsColumn) {
            return account.injectMods ? Qt::Checked : Qt::Unchecked;
        }
    }

    if (role == CharacterOptionsRole && index.column() == CharacterColumn) {
        return account.characters;
    }

    if (role == Qt::DisplayRole || role == Qt::EditRole) {
        switch (index.column()) {
        case AccountColumn:
            return account.accountName;
        case CharacterColumn:
            return account.characters.value(account.characterIndex);
        case LaunchColumn:
            return "Launch";
        case UpdateColumn:
            return "Update";
        default:
            return {};
        }
    }

    return {};
}

bool AccountTableModel::setData(
    const QModelIndex& index,
    const QVariant& value,
    const int role) {
    if (!index.isValid() || index.row() < 0 || index.row() >= accounts_.count()) {
        return false;
    }

    AccountRecord& account = accounts_[index.row()];

    if (role == Qt::CheckStateRole) {
        const bool checked = value.toInt() == Qt::Checked;
        if (index.column() == SelectedColumn) {
            account.selected = checked;
        } else if (index.column() == InjectDllsColumn) {
            account.injectDlls = checked;
        } else if (index.column() == InjectModsColumn) {
            account.injectMods = checked;
        } else {
            return false;
        }

        emit dataChanged(index, index, {role});
        return true;
    }

    if ((role == Qt::EditRole || role == Qt::DisplayRole) && index.column() == CharacterColumn) {
        const QString characterName = value.toString();
        const int newCharacterIndex = account.characters.indexOf(characterName);
        if (newCharacterIndex < 0) {
            return false;
        }

        account.characterIndex = newCharacterIndex;
        emit dataChanged(index, index, {Qt::DisplayRole, Qt::EditRole});
        return true;
    }

    return false;
}

Qt::ItemFlags AccountTableModel::flags(const QModelIndex& index) const {
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }

    Qt::ItemFlags itemFlags = Qt::ItemIsEnabled | Qt::ItemIsSelectable;
    if (index.column() == SelectedColumn
        || index.column() == InjectDllsColumn
        || index.column() == InjectModsColumn) {
        itemFlags |= Qt::ItemIsUserCheckable;
    }
    if (index.column() == CharacterColumn) {
        itemFlags |= Qt::ItemIsEditable;
    }

    return itemFlags;
}

QVariant AccountTableModel::headerData(
    const int section,
    const Qt::Orientation orientation,
    const int role) const {
    if (orientation != Qt::Horizontal || role != Qt::DisplayRole) {
        return QAbstractTableModel::headerData(section, orientation, role);
    }

    switch (section) {
    case SelectedColumn:
        return "Sel";
    case AccountColumn:
        return "Account";
    case CharacterColumn:
        return "Character";
    case InjectDllsColumn:
        return "Inject DLLs";
    case InjectModsColumn:
        return "Inject Mods";
    case LaunchColumn:
        return "Launch";
    case UpdateColumn:
        return "Update";
    default:
        return {};
    }
}

QStringList AccountTableModel::selectedAccountNames() const {
    QStringList selectedAccounts;
    for (const AccountRecord& account : accounts_) {
        if (account.selected) {
            selectedAccounts.append(account.accountName);
        }
    }

    return selectedAccounts;
}

QString AccountTableModel::accountNameAt(const int row) const {
    if (row < 0 || row >= accounts_.count()) {
        return {};
    }

    return accounts_.at(row).accountName;
}

} // namespace projectpotato::ui::models
