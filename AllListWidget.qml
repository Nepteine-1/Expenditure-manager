import QtQuick
import QtQuick.Controls

Item {
    id:root
    width: parent.width
    height: parent.height

    property double sideMargin: 0.15
    property int spacing: 20
    property var cellSize: [250,100]

    signal listClicked(list: string)

    Rectangle {
        id: viewPlaceholder
        anchors.centerIn: parent
        width: parent.width * (1-sideMargin)
        height: parent.height

        GridView {
            id: gridView
            anchors.centerIn: parent

            width: parent.width * (1-sideMargin)
            height: parent.height

            model: ListModel { id: listmodel }

            cellWidth: cellSize[0]+spacing
            cellHeight: cellSize[1]+spacing

            delegate: Rectangle {
                width: gridView.cellWidth
                height: gridView.cellHeight

                ListPresentationCard {
                    id: card
                    list_title: model.nom
                    list_date_creation: model.datetime
                    list_number_element: model.nb_elmt

                    width: cellSize[0]
                    height: cellSize[1]
                    anchors.centerIn: parent

                    onSelected: {
                        db.executeQuery("SELECT id FROM Liste WHERE nom LIKE \"%1\"".arg(model.nom))
                        listChoosed(db.queryResult)
                    }
                }
            }

            Component.onCompleted:  { gridView.update(); }

            function update() {
                listmodel.clear()
                if(db.executeQuery("SELECT nom, date_creation, nb_elements FROM Liste")) {
                    if(db.queryRowCount!==0) {
                        listmodel.append({"nom":db.queryResult.split("|")[0], "datetime":db.queryResult.split("|")[1], "nb_elmt":db.queryResult.split("|")[2]})
                        while(db.nextQuerry()) {
                            listmodel.append({"nom":db.queryResult.split("|")[0], "datetime":db.queryResult.split("|")[1], "nb_elmt":db.queryResult.split("|")[2]})
                        }

                    }
                }
            }
        }

        onWidthChanged: {
            let column_num = Math.floor(viewPlaceholder.width/gridView.cellWidth) >= 1 ? Math.floor(viewPlaceholder.width/gridView.cellWidth) : 1
            gridView.width = column_num*gridView.cellWidth
        }
    }

    function update_list_view() {
        gridView.update();
    }
}
