#include "ui/widgets/LogConsole.hpp"

#include <QLabel>
#include <QPlainTextEdit>
#include <QScrollBar>
#include <QVBoxLayout>

namespace projectpotato::ui::widgets {

LogConsole::LogConsole(QWidget* parent)
    : QWidget(parent) {
    setProperty("class", "panel");

    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(18, 18, 18, 18);
    layout->setSpacing(12);

    titleLabel_ = new QLabel("Session Log", this);
    titleLabel_->setProperty("class", "sectionTitle");

    editor_ = new QPlainTextEdit(this);
    editor_->setReadOnly(true);
    editor_->setMaximumBlockCount(4000);
    editor_->setObjectName("LauncherLogConsole");

    layout->addWidget(titleLabel_);
    layout->addWidget(editor_, 1);
}

void LogConsole::appendLogLine(const QString& line) {
    editor_->appendPlainText(line);
    editor_->verticalScrollBar()->setValue(editor_->verticalScrollBar()->maximum());
}

void LogConsole::clearLog() {
    editor_->clear();
}

} // namespace projectpotato::ui::widgets
