import QtQuick
import QtQuick.Controls

Item {
    id:root
    width: content.width
    height: content.height

    signal listChoosed(list: string)

    Column {
        id: content
        Row {
            TextField {
                id: new_list_dep_name
                placeholderText: "new liste name"
                width: 150
            }

            Button {
                text: "Créer"

                onClicked: {
                    if(new_list_dep_name.text!=="") {
                        if(db.executeQuery("INSERT INTO Liste (nom) VALUES (\"%1\");".arg(new_list_dep_name.text))) {
                            new_list_dep_name.text = "";
                            listCbGrpCategoryChooser.update()
                        }
                    }
                }
            }
        }

        Row {
            Label {
                text: "<font color=\"black\">Selectionner une liste:</font>"
            }

            ComboBox {
                id: listCbGrpCategoryChooser
                width: 150
                model: []

                Component.onCompleted: {
                    listCbGrpCategoryChooser.update()
                }

                onActivated: {
                    console.log("ACTIVATED : LIST CHOOSER")
                    db.executeQuery("SELECT id FROM Liste WHERE nom LIKE \"%1\"".arg(listCbGrpCategoryChooser.currentText));
                    root.listChoosed(db.queryResult)
                }

                function update() {
                    console.log("*** LIST CHOOSER UPDATE ***")
                    db.executeQuery("SELECT GROUP_CONCAT(nom) FROM Liste");
                    let barSetElmt = db.queryResult.split(",");
                    listCbGrpCategoryChooser.model = barSetElmt;
                    listCbGrpCategoryChooser.currentIndex=0;
                }
            }
        }
    }
}
