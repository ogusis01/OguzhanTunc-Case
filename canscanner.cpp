#include "canmanager.h"
#include <QProcess>
#include <QDebug>

#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <net/if.h>
#include <unistd.h>
#include <cstring>
#include <arpa/inet.h>

CanManager::CanManager(QObject *parent) : QObject(parent),
    canSocketFd(-1),
    udpMulticastPort(0)
{
    canReadTimer = new QTimer(this);
    connect(canReadTimer, &QTimer::timeout, this, &CanManager::readCanMessage);

    udpSocket = new QUdpSocket(this);
}

QStringList CanManager::getCanInterfaces()
{
    QStringList canInterfaces;

    QProcess process;
    process.start("bash", QStringList() << "-c" << "ip -details -brief link show type can || ip -details -brief link show type vcan");
    process.waitForFinished();
    QString output = process.readAllStandardOutput();

    QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        QString iface = line.split(' ').first().trimmed();
        if (!iface.isEmpty())
            canInterfaces << iface;
    }

    qDebug() << "CAN Interfaces Found:" << canInterfaces;
    return canInterfaces;
}

bool CanManager::setBaudrate(const QString &iface, int baudrate)
{
    QProcess process;
    QString cmd = QString("sudo ip link set %1 down && sudo ip link set %2 type can bitrate %3 && sudo ip link set %4 up")
                      .arg(iface).arg(iface).arg(baudrate).arg(iface);

    qDebug() << "Setting baudrate with:" << cmd;
    process.start("bash", QStringList() << "-c" << cmd);
    return process.waitForFinished();
}

bool CanManager::startCanListener(const QString &iface)
{
    if (canSocketFd != -1) {
        stopCanListener();
    }

    struct ifreq ifr;
    struct sockaddr_can addr;

    if ((canSocketFd = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
        qDebug() << "CAN socket could not be created.";
        return false;
    }

    strcpy(ifr.ifr_name, iface.toUtf8().constData());
    ioctl(canSocketFd, SIOCGIFINDEX, &ifr);

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(canSocketFd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        qDebug() << "CAN socket bind error.";
        close(canSocketFd);
        canSocketFd = -1;
        return false;
    }

    canReadTimer->start(100); // 100ms'de bir CAN socket kontrolü yap
    return true;
}

void CanManager::stopCanListener()
{
    canReadTimer->stop();
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

        // UDP multicast yayınla
        if (!udpMulticastAddress.isEmpty() && udpMulticastPort != 0) {
            QByteArray data = msg.toUtf8();
            udpSocket->writeDatagram(data, QHostAddress(udpMulticastAddress), udpMulticastPort);
        }
    }
}
