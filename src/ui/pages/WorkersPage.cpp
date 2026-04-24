#include "ui/pages/WorkersPage.hpp"

#include <QLabel>
#include <QListWidget>
#include <QVBoxLayout>

#include "ui/widgets/NineSliceFrame.hpp"

namespace projectpotato::ui::pages {

WorkersPage::WorkersPage(QWidget* parent)
    : QWidget(parent) {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(16);

    auto* overviewPanel = new projectpotato::ui::widgets::NineSliceFrame(
        projectpotato::ui::widgets::NineSliceFrame::Skin::Panel, this);
    overviewPanel->setObjectName("WorkersPanel");

    auto* overviewLayout = new QVBoxLayout(overviewPanel);
    overviewLayout->setContentsMargins(22, 22, 22, 22);
    overviewLayout->setSpacing(10);

    auto* titleLabel = new QLabel("Workers Harness", overviewPanel);
    titleLabel->setProperty("class", "sectionTitle");

    auto* descriptionLabel = new QLabel(
        "Phase 1 keeps workers host-internal only. This page tracks the stub service harness without introducing the future Worker/PotatoService protocol.",
        overviewPanel);
    descriptionLabel->setWordWrap(true);
    descriptionLabel->setProperty("class", "sectionBody");

    statusList_ = new QListWidget(overviewPanel);

    overviewLayout->addWidget(titleLabel);
    overviewLayout->addWidget(descriptionLabel);
    overviewLayout->addWidget(statusList_, 1);

    layout->addWidget(overviewPanel, 1);
}

void WorkersPage::setServiceStatuses(const QStringList& statuses) {
    statusList_->clear();
    statusList_->addItems(statuses);
}

} // namespace projectpotato::ui::pages
