import CustomComponents 1.0
import QtQuick 2.15

Window {
    id : container
    width: 640
    height: 480
    visible: true
    title: qsTr("Dépense")

    CustomDB {
        id:db
    }

    Item {
        id: view_handler

        // Permet de passer du menu principale à une liste de dépense
        // Si il n'y a aucune dépense dans la liste donnée alors on masque le graphique
        // (il sera automatiquement affiché à nouveau quand l'utilisateur aura ajouté sa 1ere dépense)
        function getChartPageFromList(list_id) {
            main_page.visible = false
            db.executeQuery("SELECT * FROM Depense WHERE id_liste=%1;".arg(list_id))
            if(db.queryRowCount===0) chart_page.setChartVisibility(false)
            chart_page.initPage(list_id)
            chart_page.visible = true
        }

        // Permet de revenir à la page principale
        function getMainMenu() {
            chart_page.setChartVisibility(true)
            main_page.update_list()
            chart_page.visible = false
            main_page.visible = true
        }
    }

    ChartPage {
        id: chart_page
    }

    MainPage {
        id: main_page
        anchors.fill: parent
        onListChoosed: (list) => { view_handler.getChartPageFromList(list);}
    }

    MessageDisplayer {
        id:msgDisplayer
    }
}
