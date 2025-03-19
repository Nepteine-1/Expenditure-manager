import QtQuick

Item {
    id: root
    property string list_title : "Titre"
    property string list_date_creation : new Date();
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

        Column {
            Text {
                id: title
                text: root.list_title
                font.pixelSize: 18
                font.bold: true
                color: "#333333"
            }

            Text {
                id: date_creation
                text: root.list_date_creation
                color: "black"
            }
        }

        Text {
            id: list_number
            anchors.bottom: parent.bottom
            text: root.list_number_element+ " élément(s)"

        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                selected(root.list_title)
            }
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
