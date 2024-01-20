#include "backend.h"

using namespace std;

Backend::Backend(QObject *parent)
    : QObject{parent}
{}

void Backend::getUploadFile()
{
    QFileDialog::getOpenFileContent("(*.txt *.qml)", [this](const QString &fileName, const QByteArray &data){
        if (fileName.isEmpty()) {
            // No file was selected
        } else {
            qDebug() << "File name: " + fileName;
            // qDebug() << "data: " + data;

            // Aquí tendríamos que escribir data dentro del fichero LoadedSequence.qml
            ofstream MyFile("D:/work/WebMRISequenceEditor/qml/LoadedSequence.qml");

            // Write to the file
            MyFile << data.toStdString();

            // Close the file
            MyFile.close();

            emit this->uploadFileSelected(fileName,data);
        }
    });
}


