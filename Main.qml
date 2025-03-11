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
            queryBuilder.query_list = list_id
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
                        console.log("CATEGORY CHOOSER COMPLETED")
                        db.executeQuery("SELECT GROUP_CONCAT(nom) FROM Categorie");
                        let barSetElmt = db.queryResult.split(",");
                        barSetElmt.unshift("Tout");
                        barChartsCbGrpCategoryChooser.model = barSetElmt;
                        barChartsCbGrpCategoryChooser.currentIndex=0;
                        chart_widget_updater.update_year_chooser()
                    }

                    onActivated: {
                        console.log("ACTIVATED : CATEGORY CHOOSER")
                        chart_widget_updater.full_update()
                    }
                }
            }

            // Choix d'afficher le total prix ou la quantité
            Row {
                id: barChartsRbGrpAttributeChooser

                RadioButton {
                    text: "<font color=\"black\">Prix</font>"
                    checked: true
                    onClicked: {
                        queryBuilder.query_attribute = "prix*quantite"
                        axisY8.labelFormat = "%.2f"
                        chart_widget_updater.update_chart()
                    }
                }

                RadioButton {
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
            Text{
                text: "Ajoutez une dépense"
            }

            TextField {
                id: nm_dep
                placeholderText: "Nom de la dépense"
                width: 150

            }

            TextField {
                id: quantite
                placeholderText: "Quantité"
                width: 150
            }

            ComboBox {
                id: categorie
                width: 150
                model: []

                Component.onCompleted: {
                    db.executeQuery("SELECT GROUP_CONCAT(nom) FROM Categorie");
                    model = db.queryResult.split(",");
                }
            }

            TextField {
                id: date_dep
                placeholderText: "Date de la dépense"
                width: 150
            }

            TextField {
                id: marque
                placeholderText: "Marque"
                width: 150
            }

            TextField {
                id: fournisseur
                placeholderText: "Fournisseur"
                width: 150
            }

            TextField {
                id: prix
                placeholderText: "Prix"
                width: 150
            }

            Button {
                text: "Ajouter"

                onClicked: {
                    if(db.executeQuery("SELECT id FROM Categorie WHERE nom=\"%1\";".arg(categorie.currentText))) {
                        let category_id = db.queryResult;
                        if(db.executeQuery("INSERT INTO Depense (nom, quantite, date, id_categorie, marque, fournisseur, prix, id_liste) VALUES (\"%1\", %2, \"%7\", %3, \"%4\", \"%5\", %6, %8);".arg(nm_dep.text).arg(quantite.text).arg(category_id).arg(marque.text).arg(fournisseur.text).arg(prix.text).arg(date_dep.text).arg(queryBuilder.query_list))) {
                            console.log("New Item added with success");
                            liste_depense.refresh();
                            chart_widget_updater.full_update()
                            chart_page.setChartVisibility(true)
                        }
                    }
                }
            }

            // Liste des dépenses
            Text{
                text: "Toutes les dépenses"
            }

            Rectangle {
                id: liste_depense
                clip: true
                width:400
                height: 75
                border.width: 1
                ListView {
                    id: liste_depense_view
                    anchors.fill: parent
                    boundsBehavior: Flickable.StopAtBounds
                    model:ListModel { id: listmodel}
                    delegate: Text { text: res}

                    Component.onCompleted:  { liste_depense.refresh(); }
                }

                function refresh() {
                    listmodel.clear()
                    db.executeQuery("SELECT Depense.nom, Depense.date, Depense.quantite, Depense.prix, Categorie.nom AS categorie, Depense.marque, Depense.fournisseur FROM Depense JOIN Categorie ON Categorie.id = Depense.id_categorie WHERE id_liste=%1 ORDER BY Depense.date;".arg(queryBuilder.query_list))
                    listmodel.append({"res":db.queryResult})
                    while(db.nextQuerry()) {
                        listmodel.append({"res":db.queryResult})
                    }
                    liste_depense_view.positionViewAtEnd()
                }
            }

            // Création de catégorie
            Text{
                text: "Créer une catégorie"
            }

            TextField {
                id: new_cat_dep_name
                placeholderText: "Nom de la catégorie"
                width: 150
            }

            Button {
                text: "Créer une catégorie"

                onClicked: {
                    if(new_cat_dep_name.text!=="") {
                        if(db.executeQuery("INSERT INTO Categorie (nom) VALUES (\"%1\");".arg(new_cat_dep_name.text))) {
                            categorie.model.push(new_cat_dep_name.text);
                            barChartsCbGrpCategoryChooser.model.push(new_cat_dep_name.text);
                            new_cat_dep_name.text = "";
                        }
                    }
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
