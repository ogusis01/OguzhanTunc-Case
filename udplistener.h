#include <QObject>
#include <QUdpSocket>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

class UdpListener : public QObject
{
    Q_OBJECT
public:
    explicit UdpListener(QObject *parent = nullptr);
    Q_INVOKABLE void startListening(const QString &multicastAddress, quint16 port);
    Q_INVOKABLE void stopListening();
signals:
    void newMessage(QString message);
    void errorOccurred(QString message);

private slots:
    void onReadyRead();

private:
    QUdpSocket *socket;
    QFile logFile;
    void logError(const QString &errorMessage);
};
