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
            chart_widget_updater.full_update()
            liste_depense.refresh()
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

    Item {
        id: chart_page
        visible: false

        function initPage(list_choosed) {
            queryBuilder.query_list = list_choosed
            queryBuilder.query_operation = "SUM"
            queryBuilder.query_periode = "%Y"
            queryBuilder.query_where = "WHERE id_liste="+queryBuilder.query_list
            queryBuilder.query_selected_year = (function () { db.executeQuery("SELECT MAX(strftime('%Y',date)) FROM Depense WHERE id_liste="+queryBuilder.query_list); return db.queryResult;})()
            queryBuilder.query_attribute = "prix*quantite"
            expAddWidget.selected_list = list_choosed
            expAddWidget.clear()
            barChartsCbGrpCategoryChooser.currentIndex=0
            barChartsRbGrpPeriodChooserMonthBtn.checked = false
            barChartsRbGrpPeriodChooserYearBtn.checked = true
            barChartsRbGrpAttributeChooserQuantite.checked = false
            barChartsRbGrpAttributeChooserPrix.checked = true
        }

        function setChartVisibility(value) {
            barChartsRbGrpPeriodChooser.visible=value
            barChartsCbGrpCategoryChooser.visible=value
            barChartsRbGrpAttributeChooser.visible=value
            barChartsRbGrpPeriodChooserMonthBtn.visible=value
            barCharts.visible=value
        }

        Item {
            id: queryBuilder
            property string query_list: ""
            property string query_operation: "SUM"
            property string query_periode: "%Y"
            property string query_where : "WHERE id_liste="+queryBuilder.query_list
            property string query_selected_year : (function () { db.executeQuery("SELECT MAX(strftime('%Y',date)) FROM Depense WHERE id_liste="+queryBuilder.query_list); return db.queryResult;})()
            property string query_attribute: "prix*quantite"

            function buildQuerry() {
                return "SELECT " + queryBuilder.query_operation + "(" + queryBuilder.query_attribute + ") as op, strftime('" + queryBuilder.query_periode + "', date) FROM Depense " + queryBuilder.query_where + " GROUP BY strftime('" + queryBuilder.query_periode + "', date)";
            }
        }

        Item {
            // useful for chart widget only
            id:chart_widget_updater

            function update_year_chooser() {
                console.log("*** UPDATE YEAR CHOOSER ***")
                if(barChartsCbGrpCategoryChooser.currentIndex === 0) db.executeQuery("SELECT MAX(strftime('%Y',date)), MIN(strftime('%Y',date)) FROM Depense WHERE id_liste="+queryBuilder.query_list);
                else db.executeQuery("SELECT MAX(strftime('%Y',date)), MIN(strftime('%Y',date)) FROM Depense JOIN Categorie on Categorie.id = Depense.id_categorie WHERE Categorie.nom = '"+barChartsCbGrpCategoryChooser.currentText+"' AND id_liste="+queryBuilder.query_list);
                if(!isNaN(Number(db.queryResult.split("|")[0])) && !isNaN(Number(db.queryResult.split("|")[1]))) {
                    if(barChartsRbGrpYearChooser.to !== Number(db.queryResult.split("|")[0]) || barChartsRbGrpYearChooser.from !== Number(db.queryResult.split("|")[1])) barChartsRbGrpYearChooser.changedbyUser=false;
                    barChartsRbGrpYearChooser.to = Number(db.queryResult.split("|")[0]);
                    barChartsRbGrpYearChooser.from = Number(db.queryResult.split("|")[1]);
                    barChartsRbGrpYearChooser.changedbyUser=true
                }
            }

            function update_category() {
                console.log("*** UPDATE CATEGORY CHOOSER ***")
                console.log(queryBuilder.query_selected_year)
                if(barChartsCbGrpCategoryChooser.currentIndex === 0)
                    if(barChartsRbGrpPeriodChooserMonthBtn.checked) {
                        queryBuilder.query_where = "WHERE strftime('%Y',date) = '"+queryBuilder.query_selected_year+"' AND id_liste="+queryBuilder.query_list;
                    }
                    else {
                        queryBuilder.query_where = "WHERE id_liste="+queryBuilder.query_list;
                    }
                else {
                    queryBuilder.query_where = "JOIN Categorie on Categorie.id = Depense.id_categorie WHERE Categorie.nom LIKE '"+barChartsCbGrpCategoryChooser.currentText+"' AND id_liste="+queryBuilder.query_list;
                    if(barChartsRbGrpPeriodChooserMonthBtn.checked) {
                        queryBuilder.query_where+= " AND strftime('%Y',date) = '"+queryBuilder.query_selected_year+"'";
                    }
                }
            }

            function update_chart() {
                console.log("*** UPDATE CHARTS ***")
                mySeries.clear()

                let query = queryBuilder.buildQuerry();
                db.executeQuery("SELECT MAX(op) FROM ("+query+")")
                axisY8.max = Number(db.queryResult.split("|")[0])+ Number(db.queryResult.split("|")[0])*(0.1)
                db.executeQuery(query)

                let newCategories = []
                let barSetElmt = []

                newCategories.push(db.queryResult.split("|")[1])
                barSetElmt.push(db.queryResult.split("|")[0])
                while(db.nextQuerry()) {
                    newCategories.push(db.queryResult.split("|")[1])
                    barSetElmt.push(db.queryResult.split("|")[0])
                }

                chart_legend.categories = newCategories
                mySeries.append(queryBuilder.query_operation + " " + queryBuilder.query_attribute, barSetElmt)
            }

            function full_update() {
                chart_widget_updater.update_year_chooser()
                chart_widget_updater.update_category()
                chart_widget_updater.update_chart()
            }
        }

        Column{
            id: chart_widget

            Button {
                text: "Back to main menu"

                onClicked: { view_handler.getMainMenu() }
            }

            // Choix d'afficher l'année ou le mois
            Row {
                id: barChartsRbGrpPeriodChooser

                RadioButton {
                    id: barChartsRbGrpPeriodChooserYearBtn
                    text: "<font color=\"black\">Year</font>"
                    checked: true
                    onClicked: {
                        console.log("*** YEAR MODE SELECTED ***")
                        queryBuilder.query_periode = "%Y";
                        chart_widget_updater.full_update()

                    }
                }

                RadioButton {
                    id: barChartsRbGrpPeriodChooserMonthBtn
                    text: "<font color=\"black\">Month</font>"
                    onClicked: {
                        console.log("*** MONTH MODE SELECTED ***")
                        queryBuilder.query_periode = "%m";
                        chart_widget_updater.full_update()
                    }
                }

                SpinBox {
                    property bool changedbyUser: true
                    id: barChartsRbGrpYearChooser
                    visible: barChartsRbGrpPeriodChooserMonthBtn.checked

                    onValueChanged:  {
                            console.log("VALUE CHANGED : YEAR CHOOSER")
                            queryBuilder.query_selected_year = barChartsRbGrpYearChooser.value;
                            if(changedbyUser) {
                                chart_widget_updater.update_category()
                                chart_widget_updater.update_chart()
                            }
                    }
                }
            }

            // Choix de la catégorie
            Row {
                ComboBox {
                    id: barChartsCbGrpCategoryChooser
                    width: 150
                    model: []

                    Component.onCompleted: {
                        barChartsCbGrpCategoryChooser.update()
                        barChartsCbGrpCategoryChooser.currentIndex=0
                    }

                    onActivated: {
                        console.log("ACTIVATED : CATEGORY CHOOSER")
                        chart_widget_updater.full_update()
                    }

                    function update() {
                        let prev_indx = barChartsCbGrpCategoryChooser.currentIndex
                        db.executeQuery("SELECT GROUP_CONCAT(nom) FROM Categorie");
                        let barSetElmt = db.queryResult.split(",");
                        barSetElmt.unshift("Tout");
                        barChartsCbGrpCategoryChooser.model = barSetElmt;
                        barChartsCbGrpCategoryChooser.currentIndex=prev_indx;
                        chart_widget_updater.update_year_chooser()
                    }
                }
            }

            // Choix d'afficher le total prix ou la quantité
            Row {
                id: barChartsRbGrpAttributeChooser

                RadioButton {
                    id: barChartsRbGrpAttributeChooserPrix
                    text: "<font color=\"black\">Prix</font>"
                    checked: true
                    onClicked: {
                        queryBuilder.query_attribute = "prix*quantite"
                        axisY8.labelFormat = "%.2f"
                        chart_widget_updater.update_chart()
                    }
                }

                RadioButton {
                    id: barChartsRbGrpAttributeChooserQuantite
                    text: "<font color=\"black\">Quantite</font>"
                    onClicked: {
                        queryBuilder.query_attribute = "quantite"
                        axisY8.labelFormat = "%d"
                        chart_widget_updater.update_chart()
                    }
                }
            }

            // CHARTS DE BARS AFFICHANT LE RÉSULTAT DE LA RECHERCHE
            ChartView {
                id: barCharts
                title: "Bar Chart"
                legend.alignment: Qt.AlignBottom
                antialiasing: true
                width :500
                height:400

                ValuesAxis {
                    id: axisY8
                    min: 0
                    max: 10
                    labelFormat: "%.2f" // "%.2f"
                }

                BarCategoryAxis {
                    id: chart_legend
                    categories: []

                    Component.onCompleted: {
                        console.log("BAR CHARTS COMPLETED")
                        chart_widget_updater.update_chart()
                    }
                }

                BarSeries {
                    id: mySeries
                    axisX: chart_legend
                    axisY: axisY8
                }
            }

            // Section ajout dépense
            AddExpenditureWidget {
                id: expAddWidget
                onObjectAdded : {
                    liste_depense.refresh();
                    chart_widget_updater.full_update()
                    chart_page.setChartVisibility(true)
                }

                Component.onCompleted: {expAddWidget.selected_list = query_list}
            }

            // Liste des dépenses
            ExpenditureList {
                id:liste_depense
            }

            // Création de catégorie  
            CreateCategory {
                id:category_creator

                onCategoryAdded: {
                    expAddWidget.updateCategoryCB()
                    barChartsCbGrpCategoryChooser.update()
                }
            }
        }
    }

    /*                                                  */
    /*                                                  */
    /*                    MAIN PAGE                     */
    /*                                                  */
    /*                                                  */

    Column {
        id: main_page
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
                    view_handler.getChartPageFromList(db.queryResult)
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
