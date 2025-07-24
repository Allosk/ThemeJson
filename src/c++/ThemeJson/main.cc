#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>

#include <ThemeJson/palette_model.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);    
    QQmlApplicationEngine engine;
    
    qmlRegisterType<PaletteModel>("ThemeJson", 1, 0, "PaletteModel");


    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    
    return app.exec();
}
