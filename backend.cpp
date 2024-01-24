#include "backend.h"

using namespace std;

Backend::Backend(QObject *parent)
    : QObject{parent}
{}

bool Backend::active(int code, std::vector<int> vector){
    return std::find(vector.begin(), vector.end(), code) != vector.end();
}

QByteArray Backend::parseJSONtoQML(QByteArray data){
    std::string str = QString(data).toStdString();
    json j = json::parse(str);
    json blocksArray = j["blocks"];
    qDebug() << "Description: " << j["description"].template get<std::string>();
    qDebug() << "Number of blocks: " << blocksArray.size() << "\n";

    QByteArray qmlData;

    qmlData.append("import QtQuick \n");
    qmlData.append("ListModel{ \n");
    qmlData.append("    property string description: \"" + j["description"].template get<std::string>() + "\" \n");

    // Iterar sobre los elementos de la matriz "blocks"
    for (const auto& block : blocksArray) {
        int code = block["cod"];

        // Verificar si el valor 'code' está presente en cada vector
        bool durationActive = this->active(code,{1, 2, 3, 4});
        bool linesActive = this->active(code,{5, 6});
        bool samplesActive = this->active(code,{4, 5, 6});
        bool fovActive = this->active(code,{5, 6});
        bool rfActive = this->active(code,{1, 6});
        bool gradientsActive = this->active(code,{1, 3, 4});
        bool tActive = this->active(code,{6});
        bool groupActive = this->active(code,{0});


        std::cout << "  Cod: " << code << std::endl;


        qmlData.append("    ListElement { \n");
        qmlData.append("        cod: " + block["cod"].dump() + " \n");
        qmlData.append("        name: " + block["name"].dump() + " \n");
        qmlData.append("        collapsed: " + block["collapsed"].dump() + " \n");
        qmlData.append("        ngroups: " + block["ngroups"].dump() + " \n");

        if(durationActive){
            std::cout << "  Duration: " << block["duration"] << std::endl;
            // qmlData.append("        duration: " + std::to_string(block["duration"]) + " \n");
        }

        if(linesActive){
            std::cout << "  Lines: " << block["lines"] << std::endl;
            // qmlData.append("        lines: " + std::to_string(block["lines"]) + " \n");
        }

        //...

        // Acceder a elementos dentro de "gradients" si existen
        if (gradientsActive) {
            json gradientsArray = block["gradients"];
            std::cout << "  Gradients:" << std::endl;
            for (const auto& gradient : gradientsArray) {
                std::cout << "    Axis: " << gradient["axis"] << std::endl;
                std::cout << "    Amplitude: " << gradient["amplitude"] << std::endl;
                // ... puedes acceder a otros elementos dentro de "gradients"
            }
        }

        qmlData.append("    } \n");

        std::cout << std::endl;
    }

    qmlData.append("}");

    return qmlData;
}

void Backend::getUploadFile()
{
    QFileDialog::getOpenFileContent("(*.json *.qml)", [this](const QString &fileName, const QByteArray &data){
        if (fileName.isEmpty()) {
            // No file was selected
        } else {
            QByteArray qmlData;
            std::string name = fileName.toStdString();
            // Encuentra la posición del último punto en la cadena
            size_t lastDotPosition = name.find_last_of('.');

            // Verifica si se encontró un punto y extrae la extensión
            if (lastDotPosition != std::string::npos) {
                std::string extension = name.substr(lastDotPosition + 1);
                if (extension == "json"){
                    qmlData = parseJSONtoQML(data);
                } else {
                    qmlData = data;
                }
            } else {
                std::cout << "No se encontró ningún punto en la ruta del archivo." << std::endl;
                return;
            }

            std::cout << qmlData.data();

            /*
            #ifdef Q_OS_WASM
                EM_ASM_({
                    var stream = FS.open('LoadedSequence.qml','w');
                    var dataPtr = $0; // Obtén el puntero al inicio del bloque de datos
                    var dataSize = $1; // Obtén el tamaño de los datos
                    FS.write(stream, HEAPU8, dataPtr, dataSize, 0);
                    FS.close(stream);
                }, data.qmlData(), qmlData.size());
                emit this->uploadFileSelected("file:///LoadedSequence.qml");
            #else
                // Aquí tendríamos que escribir data dentro del fichero LoadedSequence.qml
                // ofstream MyFile("qml/LoadedSequence.qml");

                // // Write to the file
                // MyFile << qmlData.toStdString();

                // // Close the file
                // MyFile.close();

                emit this->uploadFileSelected("file:///"+fileName);
            #endif
            */
        }
    });
}

void Backend::getDownloadFile(QString qmlModel){
    QByteArray data; // obtained from e.g. QImage::save()
    std::string str = qmlModel.toStdString();
    json j = json::parse(str);
    std::string s = j.dump(4);
    data.append(s);
    QFileDialog::saveFileContent(data, "Sequence.json");
}

