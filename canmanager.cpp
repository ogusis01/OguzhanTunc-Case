#include "canmanager.h"
#include <QProcess>
#include <QDebug>

#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <linux/sockios.h>
#include <sys/ioctl.h>

#include <net/if.h>
#include <unistd.h>
#include <cstring>
#include <arpa/inet.h>
#include <QSocketNotifier>

CanManager::CanManager(QObject *parent) : QObject(parent),
    canSocketFd(-1),
    udpMulticastPort(0),
    canSocketNotifier(nullptr)
{
    udpSocket = new QUdpSocket(this);
}

QStringList CanManager::getCanInterfaces()
{
    QStringList canInterfaces;

    QProcess processCan;
    processCan.start("bash", QStringList() << "-c" << "ip -details -brief link show type can");
    processCan.waitForFinished();
    QString outputCan = processCan.readAllStandardOutput();

    QStringList linesCan = outputCan.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : linesCan) {
        QString iface = line.split(' ').first().trimmed();
        if (!iface.isEmpty())
            canInterfaces << iface;
    }

    // Sanal CAN arayüzlerini oku
    QProcess processVcan;
    processVcan.start("bash", QStringList() << "-c" << "ip -details -brief link show type vcan");
    processVcan.waitForFinished();
    QString outputVcan = processVcan.readAllStandardOutput();

    QStringList linesVcan = outputVcan.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : linesVcan) {
        QString iface = line.split(' ').first().trimmed();
        if (!iface.isEmpty())
            canInterfaces << iface;
    }
    return canInterfaces;
}



bool CanManager::startCanListener(const QString &iface)
{
    if (canSocketFd != -1) {
        stopCanListener();
    }

    struct ifreq ifr;
    struct sockaddr_can addr;

    if ((canSocketFd = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
        qDebug() << "CAN socket oluşturulamadı.";
        return false;
    }

    strcpy(ifr.ifr_name, iface.toUtf8().constData());
    if (ioctl(canSocketFd, SIOCGIFINDEX, &ifr) < 0) {
        qDebug() << "CAN interface index alınamadı.";
        close(canSocketFd);
        canSocketFd = -1;
        return false;
    }

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(canSocketFd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        qDebug() << "CAN socket bind hatası.";
        close(canSocketFd);
        canSocketFd = -1;
        return false;
    }

    // ✨ QSocketNotifier oluştur
    canSocketNotifier = new QSocketNotifier(canSocketFd, QSocketNotifier::Read, this);
    connect(canSocketNotifier, &QSocketNotifier::activated, this, &CanManager::readCanMessage);

    return true;
}

void CanManager::stopCanListener()
{
    if (canSocketNotifier) {
        canSocketNotifier->setEnabled(false);
        canSocketNotifier->deleteLater();
        canSocketNotifier = nullptr;
    }

    if (canSocketFd != -1) {
        close(canSocketFd);
        canSocketFd = -1;
    }
}

void CanManager::setUdpTarget(const QString &address, quint16 port)
{
    udpMulticastAddress = address;
    udpMulticastPort = port;
}

void CanManager::readCanMessage()
{
    if (canSocketFd == -1)
        return;

    struct can_frame frame;
    int nbytes = read(canSocketFd, &frame, sizeof(struct can_frame));

    if (nbytes > 0) {
        QString msg = QString("ID: %1 DLC: %2 DATA: ")
        .arg(frame.can_id, 0, 16)
            .arg(frame.can_dlc);

        for (int i = 0; i < frame.can_dlc; i++) {
            msg += QString("%1 ").arg(frame.data[i], 2, 16, QLatin1Char('0')).toUpper();
        }

        emit newCanMessage(msg);

        if (!udpMulticastAddress.isEmpty() && udpMulticastPort != 0) {
            QByteArray data = msg.toUtf8();
            udpSocket->writeDatagram(data, QHostAddress(udpMulticastAddress), udpMulticastPort);
        }
    }
}
