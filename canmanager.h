#ifndef CANMANAGER_H
#define CANMANAGER_H

#include <QObject>
#include <QStringList>
#include <QTimer>
#include <QUdpSocket>

class CanManager : public QObject
{
    Q_OBJECT
public:
    explicit CanManager(QObject *parent = nullptr);

    Q_INVOKABLE QStringList getCanInterfaces();
    Q_INVOKABLE bool startCanListener(const QString &iface);
    Q_INVOKABLE void stopCanListener();
    Q_INVOKABLE void setUdpTarget(const QString &address, quint16 port);

signals:
    void newCanMessage(QString message);

private slots:
    void readCanMessage();

private:
    int canSocketFd;
    QTimer *canReadTimer;

    QUdpSocket *udpSocket;
    QString udpMulticastAddress;
    quint16 udpMulticastPort;
    QSocketNotifier *canSocketNotifier;
};

#endif // CANMANAGER_H
