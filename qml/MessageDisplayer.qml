import QtQuick

Item {
    id:root
    opacity: 0
    width:  Math.min(message.width + 40, parent.width)
    height: 100
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 20

    Rectangle {
        anchors.fill:parent
        color: "grey"

        Text {
            id:message
            text: "Your message.."
            color:"white"
            font.pixelSize: 18
            anchors.centerIn: parent
        }
    }

    function setMessage(msg) {
        message.text=msg
        root.opacity=1
        if(timer.running===true) timer.restart()
        else timer.running=true
    }

    Timer {
        id: timer
        interval: 2500; running: false; repeat: false
        onTriggered: root.opacity = 0
    }

    Behavior on opacity {
        NumberAnimation { duration: 250 }
    }
}
