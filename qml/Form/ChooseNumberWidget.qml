import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item {
    id:root
    width: 125
    height: 45
    Material.accent: Material.Blue

    property string placeholder: ""

    TextField {
        id: field

        property string proposition:""

        placeholderText: root.placeholder
        width: root.width
        height: root.height
        maximumLength: 7

        onTextChanged: {
            // Remove non-digit characters
            field.text = field.text.replace(/[^0-9]/g, "")
        }
    }

    function getText() { return field.text }
    function clear() { field.text="" }
}
