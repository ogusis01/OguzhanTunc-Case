#ifndef UDPPUBLISHER_H
#define UDPPUBLISHER_H

#include <QObject>
#include <QUdpSocket>
#include <QTimer>

class UdpPublisher : public QObject
{
    Q_OBJECT
public:
    explicit UdpPublisher(QObject *parent = nullptr);
    Q_INVOKABLE void startPublishing(const QString &address, quint16 port, const QString &message);
    Q_INVOKABLE void stopPublishing();
    Q_INVOKABLE QString getPublishSocketInfo() const;

private slots:
    void sendMessage();

private:
    QUdpSocket *socket;
    QTimer *publishTimer;
    QString targetAddress;
    quint16 targetPort;
    QString messageToSend;
};

#endif // UDPPUBLISHER_H
