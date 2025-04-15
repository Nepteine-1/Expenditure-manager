import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal 2.15 as Univers
import QtQuick.Layouts

Item {
    id:root
    width: 175
    height: 45
    Material.accent: Material.Blue

    property string placeholder: ""

    TextField {
        property bool settingUp_DateString: false
        id:txtfield
        placeholderText: root.placeholder
        width: root.width
        height: root.height
        maximumLength: 10
        
        onTextEdited: {
            txtfield.text = txtfield.text.replace(/[^0-9]/g, "")
            let mask = txtfield.text

            let res=""
            if(mask.length>6) res = mask.substring(0,4)+"-"+mask.substring(4,6)+"-"+mask.substring(6,mask.length)
            else if(mask.length>4) res = mask.substring(0,4)+"-"+mask.substring(4,mask.length)
            else res = mask.substring(0,mask.length)

            txtfield.text = res
        }

        Univers.Button {
            height: txtfield.height
            anchors.right: txtfield.right
            width: 45
            text: "📅"
            onClicked: dateDialog.open()
        }
    }

    Dialog {
        id: dateDialog
        title: "Sélectionner une date"
        modal: true
        x:txtfield.x + txtfield.width
        y:txtfield.y
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            let tmp = selectedDate.getFullYear()+"-"
                    + ((Number(selectedDate.getMonth())+1) > 10 ? (Number(selectedDate.getMonth())+1) : "0"+(Number(selectedDate.getMonth())+1))+"-"
                    + (Number(selectedDate.getDate()) > 10 ? Number(selectedDate.getDate()) : "0"+Number(selectedDate.getDate()))
            txtfield.text = tmp
        }

        contentItem: Column {
            spacing: 10
            width: 300

            Row {
                width: parent.width
                spacing: 10

                Button {
                    text: "<"
                    onClicked: {
                        currentMonth--;
                        if (currentMonth < 0) {
                            currentMonth = 11;
                            currentYear--;
                        }
                        monthGrid.month = currentMonth
                        monthGrid.year = currentYear
                    }
                }

                Text {
                    text: Qt.formatDateTime(new Date(currentYear, currentMonth, 1), "MMMM yyyy")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Button {
                    text: ">"
                    onClicked: {
                        currentMonth++;
                        if (currentMonth > 11) {
                            currentMonth = 0;
                            currentYear++;
                        }
                        monthGrid.month = currentMonth
                        monthGrid.year = currentYear
                    }
                }
            }

            Row {
                spacing: 25
                leftPadding: 10
                Repeater {
                    model: ["Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di"]
                    Text {
                        text: modelData
                        width: monthGrid.cellWidth
                        height: 30
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            MonthGrid {
                id: monthGrid
                width: 300
                height: 250
                month: currentMonth
                year: currentYear

                delegate: Item {
                    width: monthGrid.cellWidth
                    height: monthGrid.cellHeight

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: model.month === currentMonth && model.year === currentYear ? (model.day === selectedDate.getDate() ? "lightblue" : "transparent") : "transparent"
                        border.color: "gray"
                        radius: 15
                        visible: model.month === currentMonth && model.year === currentYear

                        Text {
                            anchors.centerIn: parent
                            text: model.day
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selectedDate = new Date(model.year, model.month, model.day)
                            }
                        }
                    }
                }
            }
        }
    }

    property date currentDate: new Date()
    property int currentYear: currentDate.getFullYear()
    property int currentMonth: currentDate.getMonth()
    property date selectedDate: currentDate

    function getText() { return txtfield.text }
    function clear() { txtfield.text="" }
}
