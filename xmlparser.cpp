#include "xmlparser.h"
#include <QFile>
#include <QXmlStreamReader>
#include <QDebug>
#include <QDateTime>
#include <QTextStream>

XmlParser::XmlParser(QObject *parent) : QObject(parent)
{
    watcher = new QFileSystemWatcher(this);
    watcher->addPath("scene.xml");

    connect(watcher, &QFileSystemWatcher::fileChanged, this, [=]() {
        watcher->addPath("scene.xml");
        emit sceneChanged(parseScene("scene.xml"));
    });
}

QList<QVariantMap> XmlParser::parseScene(const QString &filePath)
{
    QList<QVariantMap> shapes;
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit errorOccurred("XML dosyası açılamadı.");
        return shapes;
    }

    QXmlStreamReader xml(&file);

    while (!xml.atEnd() && !xml.hasError()) {
        xml.readNext();

        if (xml.isStartElement()) {
            QString tag = xml.name().toString();

            if (tag == "Rectangle" || tag == "Text" || tag == "Line" || tag == "Circle" || tag == "Image") {
                QVariantMap item;
                item["type"] = tag;

                const auto attrs = xml.attributes();
                for (const QXmlStreamAttribute &attr : attrs) {
                    item[attr.name().toString()] = attr.value().toString();
                }

                if (tag == "Text") {
                    xml.readNext();
                    if (xml.isCharacters()) {
                        item["text"] = xml.text().toString();
                    }
                }
                if (tag == "Image") {
                    qDebug() << "Image item:" << item;
                }
                shapes.append(item);
            }
        }
    }

    if (xml.hasError()) {
        QString errorMsg = "XML parse error: " + xml.errorString();
        emit errorOccurred(errorMsg);
        logXmlError(errorMsg);
    }

    file.close();
    return shapes;
}
void XmlParser::logXmlError(const QString &errorMessage)
{
    QFile logFile("xmlLog.log");

    if (logFile.open(QIODevice::Append | QIODevice::Text)) {
        QTextStream out(&logFile);
        QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
        out << "[" << timestamp << "] " << errorMessage << "\n";
        logFile.close();
    } else {
        qDebug() << "Log dosyasına yazılamadı!";
    }
}
