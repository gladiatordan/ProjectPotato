#include <QApplication>
#include <QFile>
#include <QMessageBox>

#include "core/AppPaths.hpp"
#include "core/BuildInfo.hpp"
#include "ui/MainController.hpp"
#include "ui/MainWindow.hpp"

namespace {

void loadStyleSheet(QApplication& application) {
    QFile styleFile(":/style.qss");
    if (!styleFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }

    application.setStyleSheet(QString::fromUtf8(styleFile.readAll()));
}

} // namespace

int main(int argc, char* argv[]) {
    QApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QApplication application(argc, argv);
    application.setApplicationName(projectpotato::core::BuildInfo::kAppName);
    application.setOrganizationName(projectpotato::core::BuildInfo::kOrganizationName);
    application.setApplicationVersion(projectpotato::core::BuildInfo::kVersion);

    const projectpotato::core::AppPaths appPaths =
        projectpotato::core::AppPaths::fromApplicationDir();

    QString pathError;
    if (!appPaths.ensureRuntimeDirectories(&pathError)) {
        QMessageBox::critical(nullptr, "ProjectPotato", pathError);
        return 1;
    }

    loadStyleSheet(application);

    projectpotato::ui::MainWindow mainWindow;
    projectpotato::ui::MainController mainController(appPaths);
    mainController.bindMainWindow(&mainWindow);

    if (!mainController.initialize()) {
        QMessageBox::critical(
            &mainWindow,
            "ProjectPotato",
            "Failed to initialize the Phase 1 service harness.");
        return 1;
    }

    QObject::connect(&application, &QApplication::aboutToQuit, &mainController, [&mainController]() {
        mainController.shutdown();
    });

    mainWindow.show();
    return application.exec();
}
