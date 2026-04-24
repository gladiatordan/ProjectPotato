#pragma once

#include <QAbstractTableModel>
#include <QStringList>
#include <QVector>

namespace projectpotato::ui::models {

class AccountTableModel final : public QAbstractTableModel {
    Q_OBJECT

public:
    enum Column : int {
        SelectedColumn = 0,
        AccountColumn = 1,
        CharacterColumn = 2,
        InjectDllsColumn = 3,
        InjectModsColumn = 4,
        LaunchColumn = 5,
        UpdateColumn = 6,
        ColumnCount = 7,
    };

    enum Role : int {
        CharacterOptionsRole = Qt::UserRole + 1,
    };

    explicit AccountTableModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;

    QStringList selectedAccountNames() const;
    QString accountNameAt(int row) const;

private:
    struct AccountRecord final {
        bool selected{false};
        QString accountName;
        QStringList characters;
        int characterIndex{0};
        bool injectDlls{false};
        bool injectMods{false};
    };

    QVector<AccountRecord> accounts_;
};

} // namespace projectpotato::ui::models
