#include "udpscanner.h"
#include <QProcess>
#include <QDebug>

UdpScanner::UdpScanner(QObject *parent) : QObject(parent) {}

QStringList UdpScanner::scanUdpSockets()
{
    QStringList udpList;

    QProcess process;
    process.start("/usr/bin/ss", QStringList() << "-u" << "-a");
    process.waitForFinished();

    QString output = process.readAllStandardOutput();
    QStringList lines = output.split("\n", Qt::SkipEmptyParts);

    for (const QString &line : lines) {
        if (line.contains("UNCONN") || line.contains("ESTAB")) {
            QStringList tokens = line.simplified().split(' ');
            if (tokens.size() >= 5) {
                QString localAddress = tokens[3];
                udpList.append(localAddress);
            }
        }
    }

    return udpList;
}

