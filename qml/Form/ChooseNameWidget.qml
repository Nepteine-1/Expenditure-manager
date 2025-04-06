import QtQuick 2.15
import QtQuick.Controls.Material 2.15

// This component allows to enter a string corresponding to any attribute of any table of the database.
// There is also a feature embedded which allows to auto-complete the string entered with the data already present in the database.
//
// To initialize this component, use dbAttributeToFind and dbTableToFind to selected where the auto-completion will work
// The user can also specify a placeholder for the TextField component
Item {
    id:root
    width: field.width
    height: field.height
    Material.accent: Material.Blue

    property string dbAttributeToFind : ""
    property string dbTableToFind: ""
    property string placeholder: ""

    TextField {
        id: field

        property string proposition:""

        placeholderText: root.placeholder
        width: 500
        height: 45
        maximumLength: 35
        onTextChanged: {
            if(field.text.length>0 && db.executeQuery("SELECT "+root.dbAttributeToFind+" FROM "+root.dbTableToFind+" WHERE "+root.dbAttributeToFind+" LIKE \"%1\%\" LIMIT 1".arg(field.text)) && db.queryResult.length > 0) {
                    completion.text = "<font color='#D3D3D3'>"+db.queryResult.substring(field.text.length).replace(/ /g, '&nbsp;')+"</font>"
                    field.proposition = db.queryResult
            } else {
                completion.text = ""
                field.proposition = field.text
            }
            console.log(field.proposition)
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return && field.text !== field.proposition)  {
                field.text = field.proposition
            }
            else if (event.key === Qt.Key_Delete && field.text.length > 0)  {
                field.text = ""
                field.proposition = field.text
            }
        }

        onFocusChanged: {
            if(field.activeFocus) completion.text="<font color='#D3D3D3'>"+field.proposition.substring(field.text.length).replace(/ /g, '&nbsp;')+"</font>"
            else completion.text = ""
        }

        Text {
            id:completion
            width: field.width - field.contentWidth - field.leftPadding*2
            text: ""
            x: field.x + field.leftPadding + field.contentWidth
            anchors.verticalCenter: field.verticalCenter
            clip: true
        }
    }
}
