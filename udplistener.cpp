#include "udplistener.h"
#include <QHostAddress>
#include <QNetworkInterface>
#include <QDebug>

UdpListener::UdpListener(QObject *parent)
    : QObject(parent),
    logFile("udp_listener_log.log")
{
    socket = new QUdpSocket(this);
    connect(socket, &QUdpSocket::readyRead, this, &UdpListener::onReadyRead);
}

void UdpListener::startListening(const QString &multicastAddress, quint16 port)
{
    if (socket->state() != QAbstractSocket::UnconnectedState) {
        socket->close();
    }

    if (!socket->bind(QHostAddress::AnyIPv4, port, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        QString errorMsg = "UDP bind failed: " + socket->errorString();
        emit errorOccurred(errorMsg);
        logError(errorMsg);
        return;
    }

    QHostAddress groupAddress(multicastAddress);
    if (!socket->joinMulticastGroup(groupAddress)) {
        QString errorMsg = "Failed to join multicast group: " + groupAddress.toString();
        emit errorOccurred(errorMsg);
        logError(errorMsg);
    }
}
void UdpListener::stopListening()
{
    if (socket) {
        if (socket->state() != QAbstractSocket::UnconnectedState) {
            socket->close();
            qDebug() << "UDP socket for listening closed.";
        }
    }
}
void UdpListener::onReadyRead()
{
    while (socket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(int(socket->pendingDatagramSize()));
        if (socket->readDatagram(datagram.data(), datagram.size()) < 0) {
            QString errorMsg = "Error reading datagram: " + socket->errorString();
            emit errorOccurred(errorMsg);
            logError(errorMsg);
            return;
        }

        QString message = QString::fromUtf8(datagram);
        emit newMessage(message);
    }
}

void UdpListener::logError(const QString &errorMessage)
{
    if (!logFile.isOpen()) {
        logFile.open(QIODevice::Append | QIODevice::Text);
    }

    QTextStream out(&logFile);
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    out << timestamp << " [ERROR]: " << errorMessage << "\n";
}


