import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Universal 2.15 as Univers

Item {
    id: root
    visible: true
    width: 210
    height: 45

    property bool categ_choosed : false

    Univers.Button {
        id: select_item
        width: parent.width
        height: parent.height
        text: "-  Choisir une catégorie  -"
        onClicked: popup.open()
    }

    Popup {
        id: popup
        width: root.width
        height: 200 // Limite la hauteur de la liste déroulante
        x:select_item.x
        y:select_item.y + select_item.height
        contentItem: Rectangle {
            width: popup.width - 10
            height: popup.height - 10
            anchors.centerIn: parent
            clip: true
            ListView {
                id: view
                width: parent.width
                height: parent.height -20
                boundsBehavior: Flickable.StopAtBounds
                model: ListModel { id:list
                }

                delegate: ItemDelegate {
                    text: model.text
                    width: view.width
                    onClicked: {
                        select_item.text = text
                        root.categ_choosed = true
                        popup.close()
                    }
                }

                ScrollBar.vertical: ScrollBar {}
            }
        }

        // Positionner le Popup par rapport au bouton
        onOpened: {
            contentItem.x = select_item.x
            contentItem.y = select_item.y + select_item.height
        }

        Component.onCompleted: { popup.refresh() }

        function refresh () {
            db.executeQuery("SELECT GROUP_CONCAT(nom) FROM Categorie");
            list.clear()
            for (const element of db.queryResult.split(",")) {
                list.append({"text": element})
            }
        }
    }

    function getText() { return select_item.text }
    function clear() {
        select_item.text="-  Choisir une catégorie  -"
        categ_choosed=false
    }
}
