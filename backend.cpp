#include "backend.h"

using namespace std;

Backend::Backend(QObject *parent)
    : QObject{parent}
{}

bool Backend::active(int code, std::vector<int> vector){
    return std::find(vector.begin(), vector.end(), code) != vector.end();
}

QByteArray Backend::processJSON(QByteArray data){
    std::string str = QString(data).toStdString();
    json j = json::parse(str);
    QByteArray processedData;

    for (auto& block : j["blocks"]) {
        int code = block["cod"];
        int cont = 0;

        // Verificar si el valor 'code' está presente en cada vector
        bool durationActive = this->active(code,{1, 2, 3, 4});
        bool linesActive = this->active(code,{5, 6});
        bool samplesActive = this->active(code,{4, 5, 6});
        bool fovActive = this->active(code,{5, 6});
        bool rfActive = this->active(code,{1, 6});
        bool gradientsActive = this->active(code,{1, 3, 4});
        bool tActive = this->active(code,{6});
        bool groupActive = this->active(code,{0});

        block.erase("collapsed");
        block.erase("grouped");

        if(rfActive){
            cont = 0;
            for (auto& rf : block["rf"]) {
                int select = rf["select"];
                switch(select){
                case 0: //FLip angle and duration
                    rf.erase("b1Module");
                    break;
                case 1: // Flip angle and amplitude
                    block.erase("duration");
                    break;
                case 2: // Duration and amplitude
                    rf.erase("flipAngle");
                    break;
                }
                rf.erase("select");
            }
        } else {
            block.erase("rf");
        }

        if(!durationActive){
            block.erase("duration");
        }

        if(!linesActive){
            block.erase("lines");
        }

        if(!samplesActive){
            block.erase("samples");
        }

        if(!fovActive){
            block.erase("fov");
        }

        if(!gradientsActive){
            block.erase("gradients");
        }

        if(!tActive){
            block.erase("t");
        }

        if(!groupActive){
            block.erase("repetitions");
        }

        // More processing if necessary
    }

    processedData.append(j.dump(4));
    return processedData;
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
    qmlData.append("    property string description: " + j["description"].dump() + " \n");

    // Iterar sobre los elementos de la matriz "blocks"

    for (const auto& block : blocksArray) {
        int code = block["cod"];
        int cont = 0;

        // Verificar si el valor 'code' está presente en cada vector
        bool durationActive = this->active(code,{1, 2, 3, 4});
        bool linesActive = this->active(code,{5, 6});
        bool samplesActive = this->active(code,{4, 5, 6});
        bool fovActive = this->active(code,{5, 6});
        bool rfActive = this->active(code,{1, 6});
        bool gradientsActive = this->active(code,{1, 3, 4});
        bool tActive = this->active(code,{6});
        bool groupActive = this->active(code,{0});

        qmlData.append("    ListElement { \n");
        qmlData.append("        cod: " + block["cod"].dump() + " \n");
        qmlData.append("        name: " + block["name"].dump() + " \n");
        qmlData.append("        ngroups: " + block["ngroups"].dump() + " \n");
        qmlData.append("        grouped: false \n");
        qmlData.append("        collapsed: false \n");

        qmlData.append("        children: [");
        json childrenArray = block["children"];
        cont = 0;
        if(childrenArray.size()>0){
            for (const auto& child : childrenArray) {
                cont++;
                qmlData.append("\n            ListElement { number: " + child["number"].dump() + " }");
                if(cont<childrenArray.size()){
                    qmlData.append(",");
                } else {
                    qmlData.append("\n");
                }
            }
            qmlData.append("        ");
        }
        qmlData.append("] \n");

        if(durationActive & (code != 1)){
            qmlData.append("        duration: " + block["duration"].dump() + " \n");
        }

        if(linesActive){
            qmlData.append("        lines: " + block["lines"].dump() + " \n");
        }

        if(samplesActive){
            qmlData.append("        samples: " + block["samples"].dump() + " \n");
        }

        if(fovActive){
            qmlData.append("        fov: " + block["fov"].dump() + " \n");
        }


        qmlData.append("        rf: [");
        int select = 1;
        if(rfActive){
            json rfArray = block["rf"];
            cont = 0;
            for (const auto& rf : rfArray) {
                bool flipAngle, b1Module = false;

                cont ++;
                qmlData.append("\n            ListElement { \n");
                qmlData.append("                shape: " +      rf["shape"].dump() + "\n");
                if (rf.find("flipAngle") != rf.end()){
                    qmlData.append("                flipAngle: " +  rf["flipAngle"].dump() + "\n");
                    flipAngle = true;
                }
                if (rf.find("b1Module") != rf.end()){
                    qmlData.append("                b1Module: " +   rf["b1Module"].dump() + "\n");
                    b1Module = true;
                }
                qmlData.append("                deltaf: " +     rf["deltaf"].dump() + "\n");

                if (flipAngle & b1Module){
                    select = 1;
                } else if (flipAngle & !b1Module){
                    select = 0;
                } else if (!flipAngle) {
                    select = 2;
                }

                qmlData.append("                select: " +     to_string(select) + "\n");

                if(cont<rfArray.size()){
                    qmlData.append("            },");
                } else {
                    qmlData.append("            } \n");
                }
            }
            qmlData.append("        ");
        }
        qmlData.append("] \n");

        if (code==1 & select !=1){
            qmlData.append("        duration: " + block["duration"].dump() + " \n");
        }


        qmlData.append("        gradients: [");
        if (gradientsActive) {
            json gradientsArray = block["gradients"];
            cont = 0;
            for (const auto& gradient : gradientsArray) {
                cont++;
                qmlData.append("\n            ListElement { \n");
                qmlData.append("                axis: " +       gradient["axis"].dump() + "\n");
                qmlData.append("                delay: " +      gradient["delay"].dump() + "\n");
                qmlData.append("                rise: " +       gradient["rise"].dump() + "\n");
                qmlData.append("                flatTop: " +    gradient["flatTop"].dump() + "\n");
                qmlData.append("                amplitude: " +  gradient["amplitude"].dump() + "\n");
                qmlData.append("                step: " +       gradient["step"].dump() + "\n");
                if(cont<gradientsArray.size()){
                    qmlData.append("            },");
                } else {
                    qmlData.append("            } \n");
                }
            }
            qmlData.append("        ");
        }
        qmlData.append("] \n");

        qmlData.append("        t: [");
        if(tActive){
            json tArray = block["t"];
            cont = 0;
            for (const auto& t : tArray) {
                cont++;
                qmlData.append("\n            ListElement { \n");
                qmlData.append("                te: " + t["te"].dump() + "\n");
                qmlData.append("                tr: " + t["tr"].dump() + "\n");
                if(cont<tArray.size()){
                    qmlData.append("            },");
                } else {
                    qmlData.append("            } \n");
                }
            }
            qmlData.append("        ");
        }
        qmlData.append("] \n");

        if(groupActive){
            qmlData.append("        repetitions: " + block["repetitions"].dump() + " \n");
        }

        qmlData.append("    } \n");
    }

    qmlData.append("} \n");

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

            #ifdef Q_OS_WASM
                EM_ASM({
                    var tempFileName = $2 + ".qml";
                    var stream = FS.open(tempFileName,'w');
                    var dataPtr = $0; // Obtén el puntero al inicio del bloque de datos
                    var dataSize = $1; // Obtén el tamaño de los datos
                    FS.write(stream, HEAPU8, dataPtr, dataSize, 0);
                    FS.close(stream);
                }, qmlData.data(), qmlData.size(), fileNumber);
                emit this->uploadFileSelected("file:///" + QString::fromStdString(to_string(fileNumber)) + ".qml");
                fileNumber++;
            #else
                std::string tempFileName =  std::filesystem::temp_directory_path().string() + std::to_string(fileNumber) + ".qml";

                // Aquí tendríamos que escribir data dentro del fichero LoadedSequence.qml
                ofstream MyFile(tempFileName);

                // Write to the file
                MyFile << qmlData.toStdString();

                // Close the file
                MyFile.close();

                emit this->uploadFileSelected("file:///"+QString::fromStdString(tempFileName));

                fileNumber++;
            #endif
        }
    });
}

void Backend::getDownloadFile(QString qmlModel, QString extension){
    QByteArray data;
    std::string str = qmlModel.toStdString();
    json j = json::parse(str);
    std::string s = j.dump(4);
    data.append(s);
    if(extension == "json"){
        QFileDialog::saveFileContent(processJSON(data), "Sequence.json");
    } else if(extension == "qml"){
        QFileDialog::saveFileContent(parseJSONtoQML(processJSON(data)), "Sequence.qml");
    }

}

