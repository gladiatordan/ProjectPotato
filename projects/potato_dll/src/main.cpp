#include <QtWidgets/QApplication>
#include <main_window.hpp>

// Exporting for use by the .exe
extern "C" __declspec(dllexport) int __stdcall RunModule(int argc, char** argv) {
    QApplication app(argc, argv);
    MainWindow window;
    window.setWindowTitle("ProjectPotato");
    window.resize(800, 600);
    window.show();
    return app.exec();
}