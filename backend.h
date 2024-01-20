#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QFileDialog>

#include <fstream>
#include <filesystem>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

signals:
    void uploadFileSelected(const QString &fileName,const QByteArray &data);

public slots:
    void getUploadFile();
};

#endif // BACKEND_H
