#pragma once

#include <QWidget>

class QLabel;

namespace projectpotato::ui::widgets {

class PotatoWindowControls;

class PotatoHeader final : public QWidget {
    Q_OBJECT

public:
    explicit PotatoHeader(QWidget* parent = nullptr);

    bool containsInteractiveControl(const QPoint& localPosition) const;
    PotatoWindowControls* windowControls() const;

protected:
    void paintEvent(QPaintEvent* event) override;

private:
    QLabel* logoLabel_{nullptr};
    QLabel* titleLabel_{nullptr};
    QLabel* subtitleLabel_{nullptr};
    PotatoWindowControls* windowControls_{nullptr};
};

} // namespace projectpotato::ui::widgets
