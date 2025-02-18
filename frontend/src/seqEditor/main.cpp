#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "backend.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");
    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qml/Main.qml"_qs);

    // Creation of an instance of the class Backend
    Backend backend;

    // We need to make the C++ objects available in QML:
    engine.rootContext()->setContextProperty("backend",&backend);

    engine.load(url);

    return app.exec();
}
