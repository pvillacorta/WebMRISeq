#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    QQuickView view;
    view.setSource(QUrl::fromLocalFile("../qml/Main.qml"));
    view.show();
    

    return app.exec();
}
