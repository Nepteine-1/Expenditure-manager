import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    visible: true
    width: 640
    height: 480

    Button {
        text: "Ouvrir le calendrier"
        anchors.centerIn: parent
        onClicked: dateDialog.open()
    }

    Dialog {
        id: dateDialog
        title: "Sélectionner une date"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            console.log("Date sélectionnée: " + selectedDate.toLocaleDateString("fr-FR", { year: "numeric", month: "2-digit", day: "2-digit" }))
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
                spacing: 10
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
}
