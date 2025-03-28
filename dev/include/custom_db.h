#ifndef CUSTOM_DB_H
#define CUSTOM_DB_H

#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>


class CustomDB : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit CustomDB(QObject *parent = nullptr);
    ~CustomDB();

    Q_PROPERTY(QString queryResult READ getQueryResult CONSTANT);
    Q_PROPERTY(int queryColumnCount READ getQueryColumnCount CONSTANT);
    Q_PROPERTY(int queryRowCount READ getQueryRowCount CONSTANT);
    Q_PROPERTY(int numQueryDone READ getQueryRowCount CONSTANT);
    Q_INVOKABLE bool executeQuery(const QString& queryString);
    Q_INVOKABLE bool nextQuerry();

    QString getQueryResult();
    int getQueryColumnCount();
    int getQueryRowCount();
    int getNumQueryDone();

private:
    QString queryResult { "Empty" };
    QSqlQuery* query { nullptr };
    int queryRowCount{ 0 }; // Should be deprecated with orther SGDB than sqlite
    int numQueryDone{ 0 };
    QSqlDatabase db;
};

#endif // CUSTOM_DB_H
