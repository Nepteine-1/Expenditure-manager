#include <custom_db.h>

CustomDB::CustomDB(QObject *parent) : QObject(parent), db(QSqlDatabase::addDatabase("QSQLITE")){
    db.setHostName("localhost");
    db.setDatabaseName("./../../database/database");
    db.setUserName("username");
    db.setPassword("password");
    if (!db.open()) {
        qDebug() << "Cannot open database:";
    }
    query = new QSqlQuery();
    executeQuery("PRAGMA foreign_keys=ON"); // Useful for sqlite3, can be removed otherwise
}

// Execute la requête indiquée et place l'objet query sur le premier élement de la table.
// La fonction retourne True si la requête à bien été exécutée, sinon False
bool CustomDB::executeQuery(const QString& queryString) {
    qDebug() << "Query " << queryString;
    if(query->prepare(queryString)) {
        if(query->exec()) {
            numQueryDone++;
            queryRowCount=0;                                            //
            while(query->next()) queryRowCount++;                       // Those lines must be removed when using other sgdb than sqlite
            query->first();                                             // ---
            queryResult = "";                                           //
            for(int i=0; i<query->record().count();i++) {               // Necessary because sqlite driver doesn't handle query row count
                queryResult += query->value(i).toString();              //
                if(i != query->record().count()-1) queryResult += "|";  //
            }
            return true;
        } else qDebug() << "Query execution failed";
    } else qDebug() << "Query preparation failed";
    return false;
}

// Place l'objet query sur l'élément suivant de la table.
// La fonction retourne True si la requête à bien été exécutée, sinon False dans le cas où le dernier élément est déjà atteint
bool CustomDB::nextQuerry() {
    if(query == nullptr) {
        qDebug() << "No query executed";
        return false;
    }
    if(query->next()) {
        queryResult = "";
        for(int i=0; i<query->record().count();i++) {
            queryResult += query->value(i).toString();
            if(i != query->record().count()-1) queryResult += "|";
        }
        return true;
    }
    return false;
}

QString CustomDB::getQueryResult() { return queryResult; }
int CustomDB::getQueryColumnCount() { return query->record().count(); }
int CustomDB::getQueryRowCount() { return queryRowCount; }
int CustomDB::getNumQueryDone() { return numQueryDone; }

CustomDB::~CustomDB() {
    if(query!=nullptr) delete query;
    db.close();
}
