#include <QtWidgets/QApplication>
#include <main_window.hpp>

// Exporting for use by the .exe
extern "C" __declspec(dllexport) int __stdcall RunModule(int argc, char** argv) {
    QApplication app(argc, argv);
    MainWindow window;
    window.setWindowTitle("ProjectPotato");
    window.resize(800, 600);
    window.show();

    app.setStyleSheet(
        "QMainWindow { background-color: #1e1e1e; color: #ffffff; }"
        "QListWidget { background-color: #252526; border: none; color: #cccccc; }"
        "QListWidget::item:selected { background-color: #37373d; color: #ffffff; }"
        "QFrame { background-color: #2d2d30; border: 1px solid #3f3f46; border-radius: 4px; }"
    );
    return app.exec();
}