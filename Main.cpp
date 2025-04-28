#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "xmlparser.h"
#include "udpscanner.h"
#include "udplistener.h"
#include "udppublisher.h"
#include "canmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    UdpScanner udpScanner;
    engine.rootContext()->setContextProperty("udpScanner", &udpScanner);

    XmlParser parser;
    engine.rootContext()->setContextProperty("xmlParser", &parser);

    UdpListener udpListener;
    engine.rootContext()->setContextProperty("udpListener", &udpListener);

    UdpPublisher udpPublisher;
    engine.rootContext()->setContextProperty("udpPublisher", &udpPublisher);

    CanManager canManager;
    engine.rootContext()->setContextProperty("canManager", &canManager);


    const QUrl url(u"qrc:/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);



    engine.load(url);
    return app.exec();
}
