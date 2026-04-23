#pragma once
#include <QtWidgets/QWidget>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QFrame>
#include <QtWidgets/QLabel>

class WorkerCard : public QFrame {
public:
    WorkerCard(const QString& name, QWidget* parent = nullptr) : QFrame(parent) {
        setFrameStyle(QFrame::StyledPanel | QFrame::Raised);
        setFixedSize(150, 100);

        auto* layout = new QVBoxLayout(this);
        layout->addWidget(new QLabel(name));
        layout->addWidget(new QLabel("Status: Active")); // Stub status
    }
};

class WorkerGrid : public QWidget {
public:
    WorkerGrid(QWidget* parent = nullptr) : QWidget(parent) {
        auto* layout = new QGridLayout(this);

        // Stub: Populate with 4 placeholder workers
        for (int i = 0; i < 4; ++i) {
            layout->addWidget(new WorkerCard(QString("Worker %1").arg(i)), i / 2, i % 2);
        }
        layout->setRowStretch(2, 1);
        layout->setColumnStretch(2, 1);
    }
};