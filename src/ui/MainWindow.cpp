#include "ui/MainWindow.hpp"

#include <QEvent>
#include <QHBoxLayout>
#include <QStackedWidget>
#include <QVBoxLayout>
#include <QWidget>

#ifdef Q_OS_WIN
#include <windows.h>
#include <windowsx.h>
#endif

#include "ui/pages/LauncherPage.hpp"
#include "ui/pages/SettingsPage.hpp"
#include "ui/pages/WorkersPage.hpp"
#include "ui/widgets/NineSliceFrame.hpp"
#include "ui/widgets/PotatoHeader.hpp"
#include "ui/widgets/PotatoSidebar.hpp"
#include "ui/widgets/PotatoWindowControls.hpp"

namespace projectpotato::ui {

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent) {
    setWindowTitle("ProjectPotato");
    setWindowFlags(Qt::Window | Qt::FramelessWindowHint);
    setMinimumSize(1280, 820);
    resize(1480, 920);

    auto* shell = new widgets::NineSliceFrame(widgets::NineSliceFrame::Skin::Main, this);
    shell->setObjectName("WindowShell");

    auto* shellLayout = new QVBoxLayout(shell);
    shellLayout->setContentsMargins(14, 14, 14, 14);
    shellLayout->setSpacing(10);

    header_ = new widgets::PotatoHeader(shell);
    sidebar_ = new widgets::PotatoSidebar(shell);
    pageStack_ = new QStackedWidget(shell);

    launcherPage_ = new pages::LauncherPage(pageStack_);
    workersPage_ = new pages::WorkersPage(pageStack_);
    settingsPage_ = new pages::SettingsPage(pageStack_);

    pageStack_->addWidget(launcherPage_);
    pageStack_->addWidget(workersPage_);
    pageStack_->addWidget(settingsPage_);

    auto* bodyContainer = new QWidget(shell);
    bodyContainer->setObjectName("BodyRoot");

    auto* bodyLayout = new QHBoxLayout(bodyContainer);
    bodyLayout->setContentsMargins(0, 0, 0, 0);
    bodyLayout->setSpacing(12);
    bodyLayout->addWidget(sidebar_);
    bodyLayout->addWidget(pageStack_, 1);

    shellLayout->addWidget(header_);
    shellLayout->addWidget(bodyContainer, 1);

    setCentralWidget(shell);

    connect(sidebar_, &widgets::PotatoSidebar::pageSelected, pageStack_, &QStackedWidget::setCurrentIndex);
    connect(sidebar_, &widgets::PotatoSidebar::pageSelected, sidebar_, &widgets::PotatoSidebar::setCurrentIndex);
    connect(header_->windowControls(), &widgets::PotatoWindowControls::minimizeRequested, this, &QWidget::showMinimized);
    connect(header_->windowControls(), &widgets::PotatoWindowControls::toggleMaximizeRequested, this, [this]() {
        isMaximized() ? showNormal() : showMaximized();
    });
    connect(header_->windowControls(), &widgets::PotatoWindowControls::closeRequested, this, &QWidget::close);
}

pages::LauncherPage* MainWindow::launcherPage() const {
    return launcherPage_;
}

pages::WorkersPage* MainWindow::workersPage() const {
    return workersPage_;
}

pages::SettingsPage* MainWindow::settingsPage() const {
    return settingsPage_;
}

bool MainWindow::nativeEvent(const QByteArray& eventType, void* message, qintptr* result) {
#ifdef Q_OS_WIN
    Q_UNUSED(eventType);

    auto* nativeMessage = static_cast<MSG*>(message);
    if (nativeMessage->message == WM_NCHITTEST) {
        const POINT globalPoint{
            GET_X_LPARAM(nativeMessage->lParam),
            GET_Y_LPARAM(nativeMessage->lParam),
        };
        const QPoint localPoint = mapFromGlobal(QPoint(globalPoint.x, globalPoint.y));

        if (!isMaximized()) {
            constexpr int resizeBorder = 8;

            const bool onLeft = localPoint.x() >= 0 && localPoint.x() < resizeBorder;
            const bool onRight = localPoint.x() <= width() && localPoint.x() > width() - resizeBorder;
            const bool onTop = localPoint.y() >= 0 && localPoint.y() < resizeBorder;
            const bool onBottom = localPoint.y() <= height() && localPoint.y() > height() - resizeBorder;

            if (onTop && onLeft) {
                *result = HTTOPLEFT;
                return true;
            }
            if (onTop && onRight) {
                *result = HTTOPRIGHT;
                return true;
            }
            if (onBottom && onLeft) {
                *result = HTBOTTOMLEFT;
                return true;
            }
            if (onBottom && onRight) {
                *result = HTBOTTOMRIGHT;
                return true;
            }
            if (onLeft) {
                *result = HTLEFT;
                return true;
            }
            if (onRight) {
                *result = HTRIGHT;
                return true;
            }
            if (onTop) {
                *result = HTTOP;
                return true;
            }
            if (onBottom) {
                *result = HTBOTTOM;
                return true;
            }
        }

        const QPoint headerPoint = header_->mapFromGlobal(QPoint(globalPoint.x, globalPoint.y));
        if (header_->rect().contains(headerPoint) && !header_->containsInteractiveControl(headerPoint)) {
            *result = HTCAPTION;
            return true;
        }
    }
#else
    Q_UNUSED(eventType);
    Q_UNUSED(message);
    Q_UNUSED(result);
#endif

    return QMainWindow::nativeEvent(eventType, message, result);
}

void MainWindow::changeEvent(QEvent* event) {
    if (event->type() == QEvent::WindowStateChange) {
        header_->windowControls()->setMaximized(isMaximized());
    }

    QMainWindow::changeEvent(event);
}

} // namespace projectpotato::ui
