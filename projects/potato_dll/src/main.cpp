#include <QtWidgets/QApplication>
#include <main_window.hpp>

// Exporting for use by the .exe
extern "C" __declspec(dllexport) int __stdcall RunModule(int argc, char** argv) {
    // 1. Fix the High DPI warning
    QApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    // 2. Initialize Qt
    QApplication app(argc, argv);

    // 3. Apply your dark theme
    app.setStyleSheet(
        "QMainWindow { background-color: #1e1e1e; color: #ffffff; }"
        "QListWidget { background-color: #252526; border: none; color: #cccccc; }"
        "QListWidget::item:selected { background-color: #37373d; color: #ffffff; }"
        "QFrame { background-color: #2d2d30; border: 1px solid #3f3f46; border-radius: 4px; }"
    );

    // 4. Show the Window
    MainWindow window;
    window.setWindowTitle("ProjectPotato");
    window.resize(1000, 700); // Made it a bit wider to accommodate the sidebar
    window.show();

    return app.exec();
}