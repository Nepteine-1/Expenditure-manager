import CustomComponents 1.0
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import QtCharts as Charts
import QtCharts 2.15
import QtTest 1.0

Window {
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
        // Si il n'y a aucune dépense dans la liste donnée alors on masque le graphique (il sera automatiquement affiché à nouveau quand l'utilisateur aura ajouté sa 1ere dépense)
        function getChartPageFromList(list_id) {
            main_page.visible = false
            db.executeQuery("SELECT * FROM Depense WHERE id_liste=%1".arg(list_id))
            if(db.queryRowCount===0) chart_page.setChartVisibility(false)
            chart_page.initPage(list_id)
            chart_page.visible = true
        }

        // Permet de revenir à la page principale et réaffiche le graphique
        function getMainMenu() {
            chart_page.setChartVisibility(true)
            chart_page.visible = false
            main_page.visible = true
        }
    }

    /*                                                  */
    /*                                                  */
    /*                   CHART PAGE                     */
    /*                                                  */
    /*                                                  */

    ChartPage {
        id: chart_page
    }

    // Créer une nouvelle liste ou selectionner une liste de dépense
    MainPage {
        id: main_page
        onListChoosed: (list) => { view_handler.getChartPageFromList(list);}
    }
}
