#pragma once

#include <QPixmap>
#include <QWidget>

namespace projectpotato::ui::widgets {

class NineSliceFrame : public QWidget {
    Q_OBJECT

public:
    enum class Skin {
        Main,
        Panel,
    };

    explicit NineSliceFrame(Skin skin, QWidget* parent = nullptr);

protected:
    void paintEvent(QPaintEvent* event) override;

private:
    void loadSkin(Skin skin);

    QPixmap topLeft_;
    QPixmap top_;
    QPixmap topRight_;
    QPixmap left_;
    QPixmap center_;
    QPixmap right_;
    QPixmap bottomLeft_;
    QPixmap bottom_;
    QPixmap bottomRight_;
};

} // namespace projectpotato::ui::widgets
