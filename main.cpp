#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickView>


// #include <emscripten.h>

// EM_JS(void, call_alert, (), {
//     prueba();
// });

int main(int argc, char *argv[])
{
    // QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QApplication app(argc, argv);

    // QQuickStyle::setStyle("Basic");

    
    QQuickView view;
    view.setSource(QUrl::fromLocalFile("../qml/Main.qml"));
    view.show();
    

    /*
    QQmlApplicationEngine engine;

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
    */

    return app.exec();
}
