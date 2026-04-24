#pragma once

#include <QWidget>

class QLabel;
class QPlainTextEdit;

namespace projectpotato::ui::widgets {

class LogConsole final : public QWidget {
    Q_OBJECT

public:
    explicit LogConsole(QWidget* parent = nullptr);

    void appendLogLine(const QString& line);
    void clearLog();

private:
    QLabel* titleLabel_{nullptr};
    QPlainTextEdit* editor_{nullptr};
};

} // namespace projectpotato::ui::widgets
