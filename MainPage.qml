import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id:root

    signal listChoosed(list: string)

    AllListWidget {
        anchors.fill: parent
        onListClicked: (list) => { listChoosed(list) }
    }
}
