#ifndef UDPSCANNER_H
#define UDPSCANNER_H

#include <QObject>
#include <QStringList>

class UdpScanner : public QObject
{
    Q_OBJECT
public:
    explicit UdpScanner(QObject *parent = nullptr);

    Q_INVOKABLE QStringList scanUdpSockets();
};

#endif // UDPSCANNER_H
