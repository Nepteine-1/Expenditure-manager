import QtQuick
import QtQuick.Controls

Item {
    width: content.width
    height: content.height

    signal categoryAdded()

    Column {
        id: content
        Text{
            text: "Créer une catégorie"
        }

        TextField {
            id: new_cat_dep_name
            placeholderText: "Nom de la catégorie"
            width: 150
        }

        Button {
            text: "Créer une catégorie"

            onClicked: {
                if(new_cat_dep_name.text!=="") {
                    if(db.executeQuery("INSERT INTO Categorie (nom) VALUES (\"%1\");".arg(new_cat_dep_name.text))) {
                        //categorie.model.push(new_cat_dep_name.text);
                        //barChartsCbGrpCategoryChooser.model.push(new_cat_dep_name.text);
                        new_cat_dep_name.text = "";
                        categoryAdded()
                    }
                }
            }
        }
    }
}
