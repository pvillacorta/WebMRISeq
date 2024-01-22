#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QFileDialog>

#include <fstream>
#include <filesystem>

#ifdef Q_OS_WASM
    #include <emscripten.h>
    #include <emscripten/html5.h>
#endif

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

signals:
    void uploadFileSelected(const bool wasm);

public slots:
    void getUploadFile();
    void getDownloadFile(QVector<QVector<QVector<QVector<double>>>> seq, QString desc);
};

#endif // BACKEND_H
