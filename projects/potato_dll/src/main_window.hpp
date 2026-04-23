#pragma once
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QListWidget>
#include <QtWidgets/QStackedWidget>
#include <QtWidgets/QHBoxLayout>
#include "services.hpp"

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    MainWindow(QWidget* parent = nullptr) : QMainWindow(parent) {
        auto* central = new QWidget(this);
        auto* layout = new QHBoxLayout(central);

        // Sidebar for Workers/Accounts
        auto* sidebar = new QListWidget();
        sidebar->setFixedWidth(200);
        sidebar->addItem("Dashboard");
        sidebar->addItem("Accounts");
        sidebar->addItem("Settings");
        sidebar->addItem("Logs");

        // Main Content Area
        auto* contentStack = new QStackedWidget();

        // Placeholder for the "Worker Grid"
        // Replace the dashboard placeholder
        auto* dashboard = new WorkerGrid();
        contentStack->addWidget(dashboard); // Index 0: Dashboard
        contentStack->addWidget(new QLabel("Account Manager Stub")); // Index 1: Accounts
        contentStack->addWidget(new QLabel("Settings Stub"));        // Index 2: Settings
        contentStack->addWidget(new QLabel("Log Console Stub"));     // Index 3: Logs

        layout->addWidget(sidebar);
        layout->addWidget(contentStack);
        setCentralWidget(central);

        setup_stubs();
    }

private:
    std::vector<std::unique_ptr<potato::services::IService>> services;

    void setup_stubs() {
        services.push_back(std::make_unique<potato::services::StubService>("LauncherService"));
        services.push_back(std::make_unique<potato::services::StubService>("GameService"));
        services.push_back(std::make_unique<potato::services::StubService>("WorkerService"));

        for (auto& s : services) s->start();
    }
};