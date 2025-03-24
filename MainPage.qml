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
                    lists.update_list_view(search_bar.text, sort_type.currentIndex)
                }
            }

            Text  {
                text: "Trier par "
            }

            ComboBox {
                id: sort_type
                model: ["Aucun filtre", "Nom ASC", "Nom DESC", "Date de modification", "Nombre d'éléments", "Date de création"]
                onActivated: {
                    lists.update_list_view(search_bar.text, sort_type.currentIndex)
                }
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
