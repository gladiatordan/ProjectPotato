#pragma once

#include <QPixmap>
#include <QWidget>

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
    QPixmap headerArt_;
    PotatoWindowControls* windowControls_{nullptr};
};

} // namespace projectpotato::ui::widgets
