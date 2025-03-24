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
                text: "Nouvelle liste"
            }

            TextField {
                id: search_bar
                text: ""
                placeholderText: "Rechercher.."

                onTextChanged: {
                    lists.update_list_view(search_bar.text)
                }
            }

            Text  {
                text: "Trier par "
            }

            ComboBox {
                model: ["Nom", "Date de modification", "Nombre d'éléments", "Date de création"]
            }
        }

        AllListWidget {
            id: lists
            width:  root.width
            height: 500

            onListClicked: (list) => { listChoosed(list) }
        }
    }

    function update_list() {
        lists.update_list_view()
    }
}
