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
        id: queryBuilder
        property string query_operation: "SUM"
        property string query_periode: "%Y"
        property string query_where : ""
        property string query_selected_year : { db.executeQuery("SELECT MAX(strftime('%Y',date)) FROM Depense"); db.queryResult; }
        property string query_attribute: "prix*quantite"
        property string query_completed: ""

        function buildQuerry() {
            queryBuilder.query_completed = "SELECT " + queryBuilder.query_operation + "(" + queryBuilder.query_attribute + ") as op, strftime('" + queryBuilder.query_periode + "', date) FROM Depense " + queryBuilder.query_where + " GROUP BY strftime('" + queryBuilder.query_periode + "', date)";
        }
    }

    Column{
        id: chart_widget

        // Test de graphiques en barres
        // Choix de compte total, sum des prix selon la périodicité ou la moyenne
        Row {
            id: barChartsRbGrpOperationChooser

            RadioButton {
                text: "<font color=\"black\">Sum</font>"
                checked: true
                onClicked: {
                    queryBuilder.query_operation = "SUM";
                    barCharts.update();
                    barChartsRbGrpYearChooser.update();
                }
            }

            RadioButton {
                text: "<font color=\"black\">Count</font>"
                onClicked: {
                    queryBuilder.query_operation = "COUNT";
                    barCharts.update();
                    barChartsRbGrpYearChooser.update();
                }
            }
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
                    barChartsCbGrpCategoryChooser.update();
                    barCharts.update();
                    barChartsRbGrpYearChooser.update();
                }
            }

            RadioButton {
                id: barChartsRbGrpPeriodChooserMonthBtn
                text: "<font color=\"black\">Month</font>"
                onClicked: {
                    console.log("*** MONTH MODE SELECTED ***")
                    queryBuilder.query_periode = "%m";
                    barChartsCbGrpCategoryChooser.update();
                    barCharts.update();
                    barChartsRbGrpYearChooser.update();
                }
            }

            SpinBox {
                property bool changedbyUser: true
                id: barChartsRbGrpYearChooser
                from: 1950
                to: 9999
                visible: barChartsRbGrpPeriodChooserMonthBtn.checked

                onValueChanged:  {
                        console.log("VALUE CHANGED : YEAR CHOOSER")
                        queryBuilder.query_selected_year = barChartsRbGrpYearChooser.value;
                        if(changedbyUser) {
                            barChartsCbGrpCategoryChooser.update();
                            barCharts.update();
                        }
                }

                function update() {
                    console.log("*** UPDATE YEAR CHOOSER ***")
                    if(barChartsCbGrpCategoryChooser.currentIndex === 0) db.executeQuery("SELECT MAX(strftime('%Y',date)), MIN(strftime('%Y',date)) FROM Depense JOIN Categorie on Categorie.id = Depense.id_categorie");
                    else db.executeQuery("SELECT MAX(strftime('%Y',date)), MIN(strftime('%Y',date)) FROM Depense JOIN Categorie on Categorie.id = Depense.id_categorie WHERE Categorie.nom = '"+barChartsCbGrpCategoryChooser.currentText+"'");
                    if(!isNaN(Number(db.queryResult.split("|")[0])) && !isNaN(Number(db.queryResult.split("|")[1]))) {
                        if(Number(db.queryResult.split("|")[0]) < Number(queryBuilder.query_selected_year)) queryBuilder.query_selected_year = Number(db.queryResult.split("|")[0]);
                        if(Number(db.queryResult.split("|")[1]) > Number(queryBuilder.query_selected_year)) queryBuilder.query_selected_year = Number(db.queryResult.split("|")[1]);
                        barChartsRbGrpYearChooser.to = Number(db.queryResult.split("|")[0]);
                        barChartsRbGrpYearChooser.from = Number(db.queryResult.split("|")[1]);
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
                    model = barSetElmt;
                    barChartsCbGrpCategoryChooser.currentIndex=0;
                    barChartsRbGrpYearChooser.update();
                }

                onActivated: {
                    console.log("ACTIVATED : CATEGORY CHOOSER")
                    barChartsRbGrpYearChooser.changedbyUser = false
                    barChartsRbGrpYearChooser.update();
                    barChartsRbGrpYearChooser.changedbyUser = true
                    barChartsCbGrpCategoryChooser.update();
                    barCharts.update();
                }

                function update() {
                    console.log("*** UPDATE CATEGORY CHOOSER ***")
                    if(barChartsCbGrpCategoryChooser.currentIndex === 0)
                        if(barChartsRbGrpPeriodChooserMonthBtn.checked) {
                            queryBuilder.query_where = "WHERE strftime('%Y',date) = '"+queryBuilder.query_selected_year+"'";
                        }
                        else {
                            queryBuilder.query_where = "";
                        }
                    else {
                        queryBuilder.query_where = "JOIN Categorie on Categorie.id = Depense.id_categorie WHERE Categorie.nom LIKE '"+barChartsCbGrpCategoryChooser.currentText+"'";
                        if(barChartsRbGrpPeriodChooserMonthBtn.checked) {
                            queryBuilder.query_where+= " AND strftime('%Y',date) = '"+queryBuilder.query_selected_year+"'";
                        }
                    }
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
                    barChartsCbGrpCategoryChooser.update();
                    barChartsRbGrpYearChooser.update();
                    barCharts.update();
                }
            }

            RadioButton {
                text: "<font color=\"black\">Quantite</font>"
                onClicked: {
                    queryBuilder.query_attribute = "quantite"
                    axisY8.labelFormat = "%d"
                    barChartsCbGrpCategoryChooser.update();
                    barChartsRbGrpYearChooser.update();
                    barCharts.update();
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
                    barCharts.update();
                }
            }

            BarSeries {
                id: mySeries
                axisX: chart_legend
                axisY: axisY8
            }

            function update() {
                console.log("*** UPDATE CHARTS ***")
                mySeries.clear()

                queryBuilder.buildQuerry();
                db.executeQuery("SELECT MAX(op) FROM ("+queryBuilder.query_completed+")")
                axisY8.max = Number(db.queryResult.split("|")[0])+ Number(db.queryResult.split("|")[0])*(0.1)
                db.executeQuery(queryBuilder.query_completed)

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
                    if(db.executeQuery("INSERT INTO Depense (nom, quantite, date, id_categorie, marque, fournisseur, prix) VALUES (\"%1\", %2, \"%7\", %3, \"%4\", \"%5\", %6);".arg(nm_dep.text).arg(quantite.text).arg(category_id).arg(marque.text).arg(fournisseur.text).arg(prix.text).arg(date_dep.text))) {
                        console.log("New Item added with success");
                        liste_depense.refresh();
                    } else console.log("ERROR -> INSERT INTO Depense (nom, quantite, date, id_categorie, marque, fournisseur, prix) VALUES (\"%1\", %2, \"%7\", %3, \"%4\", \"%5\", %6);".arg(nm_dep.text).arg(quantite.text).arg(category_id).arg(marque.text).arg(fournisseur.text).arg(prix.text).arg(date_dep.text))
                } else console.log("ERROR -> SELECT id FROM Categorie WHERE nom=\"%1\";".arg(categorie.currentText));
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
                db.executeQuery("SELECT Depense.nom, Depense.date, Depense.quantite, Depense.prix, Categorie.nom AS categorie, Depense.marque, Depense.fournisseur FROM Depense JOIN Categorie ON Categorie.id = Depense.id_categorie ORDER BY Depense.date;")
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
