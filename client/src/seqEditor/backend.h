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
    QByteArray parseJSONSequenceToQML(QByteArray data);
    QByteArray parseJSONScannerToQML(QByteArray data);
    QByteArray processJSONSequence(QByteArray data);

    QByteArray parseQStringtoQByteArray(QString model);

    int fileNumber = 0;

signals:
    void uploadSequenceSelected(QString path);
    void uploadScannerSelected(QString path);

public slots:
    void getUploadSequence();
    void getDownloadSequence(QString qmlModel, QString extension);
    void plotSequence(QString qmlScan, QString qmlSeq);

    void getUploadScanner();
    void getDownloadScanner(QString qmlModel);
};

#endif // BACKEND_H
