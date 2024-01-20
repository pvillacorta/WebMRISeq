#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
// #include <QQuickView>

#include "backend.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    /*
    QApplication app(argc, argv);
    
    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    const QUrl url(u"qrc:/WebMRISequenceEditor/qml/Main.qml"_qs);
    view.setSource(url);
    view.show();
    */

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/WebMRISequenceEditor/qml/Main.qml"_qs);

    // Creation of an instance of the class Backend
    Backend backend;

    // We need to make the Backend object available in QML:
    engine.rootContext()->setContextProperty("backend",&backend);

    engine.load(url);

    return app.exec();
}
