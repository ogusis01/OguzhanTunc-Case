#ifndef CANSCANNER_H
#define CANSCANNER_H

#include <QObject>
#include <QStringList>

class CanScanner : public QObject
{
    Q_OBJECT
public:
    explicit CanScanner(QObject *parent = nullptr);

    Q_INVOKABLE QStringList scanCanInterfaces();
};

#endif // CANSCANNER_H
