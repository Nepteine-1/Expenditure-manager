import QtQuick
import QtQuick.Controls

Item {
    id:root
    width: parent.width
    height: parent.height

    property double sideMargin: 0.00
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
            boundsBehavior: Flickable.StopAtBounds
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
                    list_last_modif: model.last_modif
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

            function update(list_research_token = null, sort_by = null) {
                listmodel.clear()
                let query_to_execute = "SELECT nom, date_creation, nb_elements, date_last_modif FROM Liste"
                if(list_research_token!== null && list_research_token.length!==0) {
                    query_to_execute+=" WHERE nom LIKE \""+list_research_token+"%\""
                }
                if(sort_by!== null && typeof sort_by === "number" && sort_by !==0) {
                    query_to_execute+=" ORDER BY \""
                    switch(sort_by) {
                        case 1:
                            query_to_execute+="nom\""
                            break;

                        case 2:
                            query_to_execute+="nom\" DESC"
                            break;

                        case 3:
                            query_to_execute+="nb_elements\" DESC"

                            break;

                        case 4:
                            query_to_execute+="date_last_modif\" DESC"
                            break;

                        case 5:
                            query_to_execute+="date_creation\" DESC"
                            break;
                    }
                }

                if(db.executeQuery(query_to_execute)) {
                    if(db.queryRowCount!==0) {
                        listmodel.append({"nom":db.queryResult.split("|")[0], "datetime":db.queryResult.split("|")[1], "nb_elmt":db.queryResult.split("|")[2], "last_modif":db.queryResult.split("|")[3]})
                        while(db.nextQuerry()) {
                            listmodel.append({"nom":db.queryResult.split("|")[0], "datetime":db.queryResult.split("|")[1], "nb_elmt":db.queryResult.split("|")[2], "last_modif":db.queryResult.split("|")[3]})
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

    function update_list_view(list_research_token = null, sort_by = null) {
        gridView.update(list_research_token, sort_by);
    }
}
