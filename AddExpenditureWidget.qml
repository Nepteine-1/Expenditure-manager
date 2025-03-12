import QtQuick
import QtQuick.Controls


Item {
    property string selected_list;

    width: content.width
    height: content.height

    signal objectAdded()

    Column {
        id: content
        Text{
            text: "Ajoutez une dépense"
        }

        TextField {
            id: nm_dep
            placeholderText: "Nom de la dépense"
            width: 150
        }

        TextField {
            id: quantite
            placeholderText: "Quantité"
            width: 150
        }

        ComboBox {
            id: categorie
            width: 150
            model: []

            Component.onCompleted: {
                updateCategoryCB()
            }
        }

        TextField {
            id: date_dep
            placeholderText: "Date de la dépense"
            width: 150
        }

        TextField {
            id: marque
            placeholderText: "Marque"
            width: 150
        }

        TextField {
            id: fournisseur
            placeholderText: "Fournisseur"
            width: 150
        }

        TextField {
            id: prix
            placeholderText: "Prix"
            width: 150
        }

        Button {
            text: "Ajouter"

            onClicked: {
                if(db.executeQuery("SELECT id FROM Categorie WHERE nom=\"%1\";".arg(categorie.currentText))) {
                    let category_id = db.queryResult;
                    if(db.executeQuery("INSERT INTO Depense (nom, quantite, date, id_categorie, marque, fournisseur, prix, id_liste) VALUES (\"%1\", %2, \"%7\", %3, \"%4\", \"%5\", %6, %8);".arg(nm_dep.text).arg(quantite.text).arg(category_id).arg(marque.text).arg(fournisseur.text).arg(prix.text).arg(date_dep.text).arg(selected_list))) {
                        console.log("New Item added with success");
                        objectAdded()
                        clear()
                    }
                }
            }
        }
    }

    function updateCategoryCB() {
        db.executeQuery("SELECT GROUP_CONCAT(nom) FROM Categorie");
        categorie.model = db.queryResult.split(",");
    }

    function clear() {
        nm_dep.text = ""
        quantite.text = ""
        categorie.currentIndex = 0
        date_dep.text = ""
        marque.text = ""
        fournisseur.text = ""
        prix.text = ""
    }
}
