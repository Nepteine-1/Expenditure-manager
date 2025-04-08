import QtQuick 2.15
import "./Form"
import QtQuick.Controls.Universal 2.15

Item {
    id:root
    width: 550
    height: 400

    property string form_title: "Name selected List"

    Rectangle {
        id: support
        anchors.fill: root
        radius: 15
        border.width: 1
        color:"ivory"

        Column {
            id:content
            spacing: 15
            anchors.horizontalCenter: support.horizontalCenter
            anchors.verticalCenter: support.verticalCenter

            Text {
                id: title
                text : form_title
                font.pixelSize: 24
                font.bold: false
            }

            ChooseNameWidget {
                id: nm_dep
                dbTableToFind: "Depense"
                dbAttributeToFind: "nom"
                placeholder: "Nom de l'article"
            }

            Row {
                spacing: 20
                ChooseNumberWidget {
                    id: prix
                    placeholder: "Prix"
                }

                ChooseNumberWidget {
                    id: quantite
                    placeholder: "Quantité"
                }

                ChooseDateWidget {
                    id: date_dep
                    width: 210
                    placeholder: "Date d'achat"
                }
            }

            ChooseNameWidget {
                id: marque
                dbTableToFind: "Depense"
                dbAttributeToFind: "marque"
                placeholder: "Marque"
            }

            ChooseNameWidget {
                id: fournisseur
                dbTableToFind: "Depense"
                dbAttributeToFind: "fournisseur"
                placeholder: "Nom du fournisseur"
            }

            Button {
                id: createExpenseBtn
                width:  content.width
                height:  45
                text: "Ajouter une dépense"

                onClicked: {
                    console.log(new Date(date_dep.getText()) <= new Date())
                    if(nm_dep.getText().length>0 && prix.getText().length>0 && quantite.getText().length>0
                            && date_dep.getText().length===10 && (new Date(date_dep.getText()) <= new Date())
                            && marque.getText().length>0 && fournisseur.getText().length>0) {
                        db.executeQuery("INSERT INTO `Depense` (`nom`, `quantite`, `date`, `marque`, `fournisseur`, `prix`) VALUES (\"%1\", %2, %3, \"%4\", \"%5\", %6)".arg(nm_dep.getText()).arg(quantite.getText()).arg(date_dep.getText()).arg(marque.getText()).arg(fournisseur.getText()).arg(prix.getText()))
                    }
                }
            }
        }
    }
}
