#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

// #include <emscripten.h>

// EM_JS(void, call_alert, (), {
//     prueba();
// });

int main(int argc, char *argv[])
{
    // Global property to enable/disable drag & drop:
    bool dragDrop = true;

    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("dragDrop", dragDrop);

    engine.addImportPath(":/");
    const QUrl url(u"qrc:/WebMRISequenceEditor/qml/Main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    // call_alert();

    return app.exec();
}
