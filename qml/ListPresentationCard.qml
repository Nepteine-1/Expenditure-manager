import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string list_title : "Titre"
    property string list_date_creation : new Date();
    property string list_last_modif : new Date();
    property int list_number_element : 0;

    width: 250
    height: 100

    signal selected(list_title: string)

    Rectangle {
        id: content
        radius: 15
        anchors.fill: parent
        color: "#FAF9F6"
        border.width: 1
        border.color: "#333333"

        Rectangle {
            id: support
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            radius: 10

            Column {
                Text {
                    id: title
                    clip: true
                    width: content.width
                    text: root.list_title
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                }

                Text {
                    id: date_creation
                    text: "Créé le "+root.list_date_creation
                    color: "black"
                }

                Text {
                    id: date_last_modif
                    text: "Modifié le "+root.list_last_modif
                    color: "black"
                }
            }

            Text {
                id: list_number
                anchors.bottom: parent.bottom
                text: root.list_number_element+ " élément(s)"

            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                selected(root.list_title)
            }
        }

        Button {
            text: "X"
            width: 25
            height: 25
            anchors.top: support.top
            anchors.right: support.right

            onClicked: console.log("test")
        }

        states: State {
            name: "down"; when: mouseArea.containsMouse === true
            PropertyChanges {
                content {
                    color: "gainsboro"
                }
            }
        }

        transitions: Transition {
            from: "down"; to: "";
            ParallelAnimation {
                ColorAnimation { duration: 250 }
            }
        }
    }
}
