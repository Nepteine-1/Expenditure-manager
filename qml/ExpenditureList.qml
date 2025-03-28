import QtQuick

Item {
    width: content.width
    height: content.height

    Column {
        id:content

        Text{
            text: "Toutes les dépenses"
        }

        Rectangle {
            id: liste_depense
            clip: true
            width:400
            height: 75
            border.width: 1
            ListView {
                id: liste_depense_view
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                model:ListModel { id: listmodel}
                delegate: Text { text: res}

                Component.onCompleted:  { refresh(); }
            }
        }
    }

    function refresh() {
        listmodel.clear()
        if(db.executeQuery("SELECT Depense.nom, Depense.date, Depense.quantite, Depense.prix, Categorie.nom AS categorie, Depense.marque, Depense.fournisseur FROM Depense JOIN Categorie ON Categorie.id = Depense.id_categorie WHERE id_liste=%1 ORDER BY Depense.date;".arg(queryBuilder.query_list))) {
            if(db.queryRowCount!==0) {
                listmodel.append({"res":db.queryResult})
                while(db.nextQuerry()) {
                    listmodel.append({"res":db.queryResult})
                }
                liste_depense_view.positionViewAtEnd()
            }
        }
    }
}
