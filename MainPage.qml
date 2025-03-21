import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id:root

    property int panelWidth: 250

    signal listChoosed(list: string)

    Row {
        anchors.fill: parent
        Rectangle {
            color : "coral"
            width:  panelWidth
            height: parent.height

            ColumnLayout {
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "orange"
                    Text {
                        text : "Créer une liste"
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 50
                    color: "orange"
                    Text {
                        text : "Créer une liste"
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
            }
        }

        AllListWidget {
            id: lists
            width:  root.width - panelWidth
            height: parent.height

            onListClicked: (list) => { listChoosed(list) }
        }
    }

    function update_list() {
        lists.update_list_view()
    }
}
