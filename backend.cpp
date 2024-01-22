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
            #ifdef Q_OS_WASM
                EM_ASM_({
                    var stream = FS.open('LoadedSequence.qml','w');
                    var dataPtr = $0; // Obtén el puntero al inicio del bloque de datos
                    var dataSize = $1; // Obtén el tamaño de los datos
                    FS.write(stream, HEAPU8, dataPtr, dataSize, 0);
                    FS.close(stream);
                }, data.data(), data.size());
                emit this->uploadFileSelected(true);
            #else
                // Aquí tendríamos que escribir data dentro del fichero LoadedSequence.qml
                ofstream MyFile("qml/LoadedSequence.qml");

                // Write to the file
                MyFile << data.toStdString();

                // Close the file
                MyFile.close();

                emit this->uploadFileSelected(false);
            #endif
        }
    });
}

void Backend::getDownloadFile(QVector<QVector<QVector<QVector<double>>>> seq, QString desc){
    QByteArray data = "Hola wenas";
    QFileDialog::saveFileContent(data,"Sequence.qml");

    int rows = 0;
    int cols = 0;
    int depth = 3;

    int elem = 0;
    int elem1 = 0;
    int elem2 = 0;

    int i,j;

    int children, chars;

    for(const auto& k : seq){
        rows++;
    }

    for(const auto& num : seq[0]){
        cols++;
    }

    for(const auto& i : seq[3][0][0]){
        elem1++;
    }

    for(const auto& j : seq[9][0][0]){
        elem2++;
    }

    if(elem1 > elem2){
        elem = elem1;
    } else {
        elem = elem2;
    }

    // Create and open a text file
    string description = desc.toStdString();

    // Write to the file
    MyFile << "import QtQuick 2.0" << endl;
    MyFile << "ListModel{" << endl;
    MyFile << " property string seqDescription: \"" << description << "\"" << endl;

    for(i=0;i<cols;i++){
        MyFile << "     ListElement{" << endl;
        MyFile << "     cod:" << seq[0][i][0] << endl;
        MyFile << "     dur:" << seq[1][i][0] << endl;
        MyFile << "     gx:" << seq[2][i][0] << endl;
        MyFile << "     gy:" << seq[3][i][0] << endl;
        MyFile << "     gz:" << seq[4][i][0] << endl;
        MyFile << "     gxStep:" << seq[5][i][0] << endl;
        MyFile << "     gyStep:" << seq[6][i][0] << endl;
        MyFile << "     gzStep:" << seq[7][i][0] << endl;
        MyFile << "     b1x:" << seq[8][i][0] << endl;
        MyFile << "     b1y:" << seq[9][i][0] << endl;
        MyFile << "     delta_f:" << seq[10][i][0] << endl;
        MyFile << "     fov:" << seq[11][i][0] << endl;
        MyFile << "     n:" << seq[12][i][0] << endl;
        MyFile << "     grouped:false" << endl;
        MyFile << "     ngroups:" << seq[13][i][0] << endl;

        chars = 0;
        for(const auto& m : seq[14][i]){
            chars++;
        }
        MyFile << "     name:\"";
        for(j=0;j<chars;j++){
            MyFile << char(seq[14][i][j]);
        }
        MyFile << "\"" << endl;

        MyFile << "     children:[" << endl;

        children = 0;
        for(const auto& n : seq[15][i]){
            children++;
        }
        for(j=0;j<children;j++){
            MyFile << "         ListElement{" << endl;
            MyFile << "             number:" << seq[15][i][j] << endl;
            MyFile << "         }";
            if(j!=(children-1)){
                MyFile << ",";
            }
            MyFile << endl;
        }

        MyFile << "     ]" << endl;

        if(seq[16][i][0]==0){
            MyFile << "     collapsed:false" << endl;
        } else if (seq[16][i][0]==1){
            MyFile << "     collapsed:true" << endl;
        }

        MyFile << "     reps:" << seq[17][i][0] << endl;

        MyFile << " }" << endl;
    }
    MyFile << "}" << endl;

    // Close the file
    MyFile.close();

    std::cout << rows << "x" << cols << "x" << depth << endl;
    std::cout << "PATH: " << file << endl;
}

