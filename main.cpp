#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    const QUrl url(u"qrc:/WebMRISequenceEditor/qml/Main.qml"_qs);
    view.setSource(url);
    view.show();
    

    return app.exec();
}
