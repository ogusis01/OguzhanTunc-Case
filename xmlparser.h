#ifndef XMLPARSER_H
#define XMLPARSER_H

#include <QObject>
#include <QVariantMap>
#include <QFileSystemWatcher>

class XmlParser : public QObject
{
    Q_OBJECT
public:
    explicit XmlParser(QObject *parent = nullptr);
    Q_INVOKABLE QList<QVariantMap> parseScene(const QString &filePath);

private:
    QFileSystemWatcher *watcher;

signals:
    void errorOccurred(const QString &message);
    void sceneChanged(const QList<QVariantMap> &newScene);

private:
    void logXmlError(const QString &errorMessage);
};

#endif // XMLPARSER_H

