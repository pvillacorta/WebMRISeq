#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QFileDialog>

#include <iostream>
#include <fstream>
#include <filesystem>
#include <string>

#include <nlohmann/json.hpp>
// for convenience
using json = nlohmann::json;


#ifdef Q_OS_WASM
    #include <emscripten.h>
    #include <emscripten/html5.h>
#endif

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

private:
    bool active(int code, std::vector<int> vector);
    QByteArray parseJSONtoQML(QByteArray data);
    int fileNumber = 0;

signals:
    void uploadFileSelected(QString path);

public slots:
    void getUploadFile();
    void getDownloadFile(QString qmlModel, QString extension);
};

#endif // BACKEND_H
