import QtQuick
import QtQuick.Controls

Item {
    id:root
    width: parent.width
    height: parent.height

    property double sideMargin: 0.00
    property int spacing: 20
    property var cellSize: [300,125]
    property int nb_column: Math.floor(gridView.width / (cellSize[0]+spacing))+1

    signal listClicked(list: string)

    GridView {
        id: gridView
        boundsBehavior: Flickable.StopAtBounds
        height: parent.height
        width: parent.width * (1-sideMargin)

        model: ListModel { id: listmodel }

        cellWidth: gridView.width/nb_column
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

                width: parent.width-spacing
                height: parent.height-spacing
                anchors.centerIn: parent

                onSelected: {
                    db.executeQuery("SELECT id FROM Liste WHERE nom LIKE \"%1\"".arg(model.nom))
                    listChoosed(db.queryResult)
                }

                onDeleted: {
                    deleteListDialog.list_name = model.nom
                    deleteListDialog.nb_elmt = model.nb_elmt
                    deleteListDialog.title="Êtes-vous sûr(e) de vouloir supprimer la liste \"%1\" ?".arg(model.nom)
                    deleteListDialog.open()
                }
            }
        }

        Component.onCompleted:  { gridView.update(search_bar.text, sort_type.currentText); }

        function update(list_research_token="", sort_by="") {
            listmodel.clear()
            let query_to_execute = "SELECT nom, date_creation, nb_elements, date_last_modif FROM Liste"

            if(list_research_token!== null && list_research_token.length!==0) query_to_execute+=" WHERE nom LIKE \""+list_research_token+"%\""

            if(sort_by!== null && sort_by.length!==0) {
                query_to_execute+=" ORDER BY \""
                switch(sort_by) {
                    case "Date de modification":
                        query_to_execute+="date_last_modif\" DESC"
                        break;

                    case "Nom ASC":
                        query_to_execute+="nom\" COLLATE NOCASE DESC"
                        break;

                    case "Nom DESC":
                        query_to_execute+="nom\" COLLATE NOCASE"
                        break;

                    case "Nombre d'éléments":
                        query_to_execute+="nb_elements\" DESC"
                        break;

                    case "Date de création":
                        query_to_execute+="date_creation\" DESC"
                        break;
                }
            } else query_to_execute+=" ORDER BY \"date_last_modif\" DESC"

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

    function update_list_view(list_research_token, sort_by) {
        gridView.update(list_research_token, sort_by);
    }

    function delete_list(list_name) {
        db.executeQuery("DELETE FROM Liste WHERE nom LIKE \"%1\"".arg(list_name))
        msgDisplayer.setMessage("La liste <b>\"%1\"</b> a été supprimée".arg(list_name))
        gridView.update(search_bar.text, sort_type.currentText);
    }
}
