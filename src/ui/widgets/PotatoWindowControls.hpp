#pragma once

#include <QWidget>

class QPushButton;

namespace projectpotato::ui::widgets {

class PotatoWindowControls final : public QWidget {
    Q_OBJECT

public:
    explicit PotatoWindowControls(QWidget* parent = nullptr);

    void setMaximized(bool maximized);

signals:
    void minimizeRequested();
    void toggleMaximizeRequested();
    void closeRequested();

private:
    QPushButton* minimizeButton_{nullptr};
    QPushButton* maximizeButton_{nullptr};
    QPushButton* closeButton_{nullptr};
};

} // namespace projectpotato::ui::widgets
