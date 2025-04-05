import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item {
    id:root
    width: field.width
    height: field.height
    Material.accent: Material.Blue

    property string placeholder: ""

    TextField {
        id: field

        property string proposition:""

        placeholderText: root.placeholder
        width: 125
        height: 45
        maximumLength: 7

        onTextChanged: {
            // Remove non-digit characters
            field.text = text.replace(/[^0-9]/g, "")
        }
    }
}
