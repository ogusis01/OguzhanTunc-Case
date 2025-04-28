#include "udppublisher.h"
#include <QHostAddress>
#include <QDebug>

UdpPublisher::UdpPublisher(QObject *parent)
    : QObject(parent)
{
    socket = new QUdpSocket(this);

    publishTimer = new QTimer(this);
    connect(publishTimer, &QTimer::timeout, this, &UdpPublisher::sendMessage);
}

void UdpPublisher::startPublishing(const QString &address, quint16 port, const QString &message)
{
    targetAddress = address;
    targetPort = port;
    messageToSend = message;

    if (socket->state() != QAbstractSocket::UnconnectedState) {
        socket->close();
    }

    QHostAddress groupAddress(address);

    if (!socket->bind(groupAddress, port, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        qDebug() << "Publisher socket bind failed:" << socket->errorString();
    } else {
        qDebug() << "Publisher socket bound to:" << groupAddress.toString() << ":" << port;
    }

    if (!publishTimer->isActive()) {
        publishTimer->start(1000);
    }
}

void UdpPublisher::stopPublishing()
{
    if (publishTimer->isActive()) {
        publishTimer->stop();
    }
    if (socket) {
        socket->close();
        qDebug() << "UDP socket closed.";
    }
}

void UdpPublisher::sendMessage()
{
    if (targetAddress.isEmpty() || targetPort == 0 || messageToSend.isEmpty()) {
        return;
    }

    QByteArray datagram = messageToSend.toUtf8();
    QHostAddress groupAddress(targetAddress);
    socket->writeDatagram(datagram, groupAddress, targetPort);
}

QString UdpPublisher::getPublishSocketInfo() const
{
    return QString("%1:%2").arg(targetAddress).arg(targetPort);
}
