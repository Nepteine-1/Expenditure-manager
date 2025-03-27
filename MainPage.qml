import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id:root

    signal listChoosed(list: string)

    Column{
        anchors.fill: parent
        Row {
            Button {
                width: 250
                id:add_button
                text: "Nouvelle liste"
                onClicked: addItemDialog.open()
            }

            TextField {
                id: search_bar
                text: ""
                placeholderText: "Rechercher.."

                onTextChanged: {
                    lists.update_list_view(search_bar.text, sort_type.currentIndex)
                }
            }

            Text  {
                text: "Trier par "
            }

            ComboBox {
                id: sort_type
                width: 200
                model: ["Aucun filtre", "Nom ASC", "Nom DESC", "Nombre d'éléments", "Date de modification", "Date de création"]
                onActivated: {
                    lists.update_list_view(search_bar.text, sort_type.currentIndex)
                }
            }
        }

        Rectangle {
            id: lists_container
            width: root.width
            height: 600
            clip: true

            AllListWidget {
                id: lists
                anchors.fill: parent

                onListClicked: (list) => { listChoosed(list) }
            }
        }
    }

    Dialog {
        id: addItemDialog
        title: "Ajouter un élément"
        modal: false
        width: add_button.width
        x: add_button.x
        y: add_button.y + add_button.height

        standardButtons: Dialog.Ok | Dialog.Cancel

        contentItem: Column {
            TextField {
                id: itemNameField
                placeholderText: "Nom de l'élément"
            }
        }

        onAccepted: {
            if(db.executeQuery("INSERT INTO Liste(`nom`) VALUES('"+itemNameField.text+"')")) {
                msgDisplayer.setMessage("Liste de dépense <b>"+itemNameField.text+"</b> ajoutée")
                itemNameField.text = ""
                lists.update_list_view(search_bar.text, sort_type.currentIndex)
            } else {
                msgDisplayer.setMessage("Erreur : la liste <b>"+itemNameField.text+"</b> n'a pas pu être ajoutée")
            }
        }

        onRejected: {
            itemNameField.text = ""
        }
    }

    function update_list() {
        lists.update_list_view()
    }
}
