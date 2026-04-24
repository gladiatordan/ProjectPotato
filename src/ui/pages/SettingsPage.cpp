#include "ui/pages/SettingsPage.hpp"

#include <QGridLayout>
#include <QLabel>
#include <QListWidget>
#include <QPushButton>
#include <QVBoxLayout>

#include "ui/widgets/NineSliceFrame.hpp"

namespace projectpotato::ui::pages {

SettingsPage::SettingsPage(QWidget* parent)
    : QWidget(parent) {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(16);

    auto* diagnosticsPanel = new projectpotato::ui::widgets::NineSliceFrame(
        projectpotato::ui::widgets::NineSliceFrame::Skin::Panel, this);
    diagnosticsPanel->setObjectName("SettingsPanel");

    auto* diagnosticsLayout = new QVBoxLayout(diagnosticsPanel);
    diagnosticsLayout->setContentsMargins(22, 22, 22, 22);
    diagnosticsLayout->setSpacing(14);

    auto* titleLabel = new QLabel("Developer Diagnostics", diagnosticsPanel);
    titleLabel->setProperty("class", "sectionTitle");

    auto* descriptionLabel = new QLabel(
        "Phase 1 exposes the minimum runtime controls needed to test service routing, GUI log forwarding, and clean shutdown behavior.",
        diagnosticsPanel);
    descriptionLabel->setWordWrap(true);
    descriptionLabel->setProperty("class", "sectionBody");

    auto* actionsLayout = new QGridLayout();
    actionsLayout->setHorizontalSpacing(12);
    actionsLayout->setVerticalSpacing(12);

    emitTestLogsButton_ = new QPushButton("Emit Test Log Burst", diagnosticsPanel);
    emitTestLogsButton_->setProperty("class", "accent");

    pingServicesButton_ = new QPushButton("Ping Services", diagnosticsPanel);
    clearGuiLogButton_ = new QPushButton("Clear GUI Log", diagnosticsPanel);
    openLogsFolderButton_ = new QPushButton("Open Logs Folder", diagnosticsPanel);
    openLogsFolderButton_->setProperty("class", "ghost");

    actionsLayout->addWidget(emitTestLogsButton_, 0, 0);
    actionsLayout->addWidget(pingServicesButton_, 0, 1);
    actionsLayout->addWidget(clearGuiLogButton_, 1, 0);
    actionsLayout->addWidget(openLogsFolderButton_, 1, 1);

    auto* statusTitleLabel = new QLabel("Service Status", diagnosticsPanel);
    statusTitleLabel->setProperty("class", "sectionTitle");

    statusList_ = new QListWidget(diagnosticsPanel);

    diagnosticsLayout->addWidget(titleLabel);
    diagnosticsLayout->addWidget(descriptionLabel);
    diagnosticsLayout->addLayout(actionsLayout);
    diagnosticsLayout->addSpacing(8);
    diagnosticsLayout->addWidget(statusTitleLabel);
    diagnosticsLayout->addWidget(statusList_, 1);

    layout->addWidget(diagnosticsPanel, 1);

    connect(emitTestLogsButton_, &QPushButton::clicked, this, &SettingsPage::emitTestLogBurstRequested);
    connect(pingServicesButton_, &QPushButton::clicked, this, &SettingsPage::pingServicesRequested);
    connect(clearGuiLogButton_, &QPushButton::clicked, this, &SettingsPage::clearGuiLogRequested);
    connect(openLogsFolderButton_, &QPushButton::clicked, this, &SettingsPage::openLogsFolderRequested);
}

void SettingsPage::setServiceStatuses(const QStringList& statuses) {
    statusList_->clear();
    statusList_->addItems(statuses);
}

} // namespace projectpotato::ui::pages
