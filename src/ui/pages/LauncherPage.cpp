#include "ui/pages/LauncherPage.hpp"

#include <QHeaderView>
#include <QHBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QTableView>
#include <QVBoxLayout>

#include "ui/delegates/ActionButtonDelegate.hpp"
#include "ui/delegates/CharacterComboDelegate.hpp"
#include "ui/models/AccountTableModel.hpp"
#include "ui/widgets/LogConsole.hpp"

namespace projectpotato::ui::pages {

LauncherPage::LauncherPage(QWidget* parent)
    : QWidget(parent) {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(16);

    auto* accountsPanel = new QWidget(this);
    accountsPanel->setProperty("class", "panel");

    auto* accountsLayout = new QVBoxLayout(accountsPanel);
    accountsLayout->setContentsMargins(20, 20, 20, 20);
    accountsLayout->setSpacing(12);

    auto* titleLabel = new QLabel("Accounts", accountsPanel);
    titleLabel->setProperty("class", "sectionTitle");

    auto* descriptionLabel = new QLabel(
        "This Phase 1 table is the locked launcher layout: account selection, character choice, injection toggles, and placeholder launch/update actions routed into the service harness.",
        accountsPanel);
    descriptionLabel->setWordWrap(true);
    descriptionLabel->setProperty("class", "sectionBody");

    model_ = new projectpotato::ui::models::AccountTableModel(this);
    accountTable_ = new QTableView(accountsPanel);
    characterDelegate_ = new projectpotato::ui::delegates::CharacterComboDelegate(this);
    launchDelegate_ = new projectpotato::ui::delegates::ActionButtonDelegate(this);
    updateDelegate_ = new projectpotato::ui::delegates::ActionButtonDelegate(this);

    configureTable();

    accountsLayout->addWidget(titleLabel);
    accountsLayout->addWidget(descriptionLabel);
    accountsLayout->addWidget(accountTable_, 1);

    auto* actionsPanel = new QWidget(this);
    actionsPanel->setProperty("class", "panel");

    auto* actionsLayout = new QHBoxLayout(actionsPanel);
    actionsLayout->setContentsMargins(18, 16, 18, 16);
    actionsLayout->setSpacing(12);

    launchSelectedButton_ = new QPushButton("Launch Selected", actionsPanel);
    launchSelectedButton_->setProperty("class", "accent");

    checkUpdatesButton_ = new QPushButton("Check for Updates", actionsPanel);
    updateAllButton_ = new QPushButton("Update All", actionsPanel);

    actionsLayout->addWidget(launchSelectedButton_);
    actionsLayout->addWidget(checkUpdatesButton_);
    actionsLayout->addWidget(updateAllButton_);
    actionsLayout->addStretch(1);

    logConsole_ = new projectpotato::ui::widgets::LogConsole(this);

    layout->addWidget(accountsPanel, 4);
    layout->addWidget(actionsPanel, 0);
    layout->addWidget(logConsole_, 3);

    connect(launchSelectedButton_, &QPushButton::clicked, this, [this]() {
        emit launchSelectedRequested(model_->selectedAccountNames());
    });
    connect(checkUpdatesButton_, &QPushButton::clicked, this, &LauncherPage::checkUpdatesRequested);
    connect(updateAllButton_, &QPushButton::clicked, this, &LauncherPage::updateAllRequested);
    connect(launchDelegate_, &projectpotato::ui::delegates::ActionButtonDelegate::buttonClicked, this,
        [this](const int row, const int) {
            emit rowLaunchRequested(model_->accountNameAt(row));
        });
    connect(updateDelegate_, &projectpotato::ui::delegates::ActionButtonDelegate::buttonClicked, this,
        [this](const int row, const int) {
            emit rowUpdateRequested(model_->accountNameAt(row));
        });
}

void LauncherPage::appendLogLine(const QString& line) {
    logConsole_->appendLogLine(line);
}

void LauncherPage::clearLogConsole() {
    logConsole_->clearLog();
}

void LauncherPage::configureTable() {
    accountTable_->setModel(model_);
    accountTable_->setAlternatingRowColors(true);
    accountTable_->setSelectionBehavior(QAbstractItemView::SelectRows);
    accountTable_->setSelectionMode(QAbstractItemView::SingleSelection);
    accountTable_->setSortingEnabled(false);
    accountTable_->setShowGrid(false);
    accountTable_->setWordWrap(false);
    accountTable_->verticalHeader()->setVisible(false);
    accountTable_->verticalHeader()->setDefaultSectionSize(42);
    accountTable_->horizontalHeader()->setStretchLastSection(false);
    accountTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);

    accountTable_->setItemDelegateForColumn(
        projectpotato::ui::models::AccountTableModel::CharacterColumn,
        characterDelegate_);
    accountTable_->setItemDelegateForColumn(
        projectpotato::ui::models::AccountTableModel::LaunchColumn,
        launchDelegate_);
    accountTable_->setItemDelegateForColumn(
        projectpotato::ui::models::AccountTableModel::UpdateColumn,
        updateDelegate_);

    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::SelectedColumn, 48);
    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::AccountColumn, 230);
    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::CharacterColumn, 190);
    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::InjectDllsColumn, 120);
    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::InjectModsColumn, 120);
    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::LaunchColumn, 118);
    accountTable_->setColumnWidth(projectpotato::ui::models::AccountTableModel::UpdateColumn, 118);
}

} // namespace projectpotato::ui::pages
