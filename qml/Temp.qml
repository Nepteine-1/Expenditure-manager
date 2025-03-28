import QtQuick

Item {
    /*
    // Graphe évolutif du prix ou de la quantité sur la durée
    // Section DATE
    RowLayout {
        TextField {
            id: start_date
            placeholderText: "Date de départ"
            width: 150
        }

        TextField {
            id: end_date
            placeholderText: "Date de fin"
            width: 150
        }

        Button {
            text: "Appliquer"

            onClicked: {
                axisX.max = new Date(end_date.text);
                axisX.min = new Date(start_date.text)
            }
        }
    }

    // Section PRIX ou QUANTITE
    RowLayout {
        id: test1
        property string sumOf: "SUM(prix) as sum";
        RadioButton {
            checked:true
            text: "<font color=\"black\">Prix</font>"
            onClicked: {
                test1.sumOf = "SUM(prix) as sum";
                axisY.labelFormat= "%.2f EUR."
                charts.update_graph(); }
        }
        RadioButton {
            text: "<font color=\"black\">Quantité</font>"
            onClicked: {
                test1.sumOf = "SUM(quantite) as sum";
                axisY.labelFormat= "%d"
                charts.update_graph();}
        }
    }

    // Section Mois/An/jOURS
    RowLayout {
        id: test2
        property string select: ", strftime('%m', date) as month, strftime('%Y', date) as year";
        property string groupBy : "month, year";
        property string orderBy : "year, month";
        property string where: "";
        RadioButton {
            text: "<font color=\"black\">Par année</font>"
            onClicked: {
                test2.select = ", strftime('%Y', date) as year";
                test2.groupBy = "year";
                test2.orderBy = "year";
                axisX.format = "yyyy";
                test2.where = "WHERE year BETWEEN '"+axisX.min.getFullYear()+"' AND '"+axisX.max.getFullYear()+"'";
                charts.update_graph();
            }
        }
        RadioButton {
            id: cas_part_month
            checked: true
            text: "<font color=\"black\">Par mois</font>"
            onClicked: {
                test2.select = ", strftime('%m', date) as month, strftime('%Y', date) as year";
                test2.groupBy= "month, year";
                test2.orderBy= "year, month";
                axisX.format = "MMMM yyyy";
                test2.where = "";
                charts.update_graph();
            }
        }
        RadioButton {
            text: "<font color=\"black\">Par jours</font>"
            onClicked: {
                test2.select = ", date";
                test2.groupBy = "date";
                test2.orderBy="date";
                axisX.format = "dd MMMM yyyy";
                test2.where ="WHERE date BETWEEN '"+axisX.getFullDate(axisX.min)+"' AND '"+axisX.getFullDate(axisX.max)+"'";
                charts.update_graph();
            }
        }
    }

    Charts.ChartView {
        id: charts
        width: 1000
        height: 500
        visible: true
        antialiasing: true

        Charts.ValuesAxis {
            id: axisY
            min: 0
            max: 3000
            labelFormat: "%.2f EUR." // "%.2f"
        }

        Charts.DateTimeAxis {
            id: axisX
            format: "MMMM yyyy"
            min: new Date("2023-01-01")
            max: new Date("2023-12-31")

            Component.onCompleted: {
                db.executeQuery("SELECT MIN(date), Max(date) FROM Depense");
                axisX.min = new Date(db.queryResult.split("|")[0]);
                axisX.max = new Date(db.queryResult.split("|")[1]);
            }

            function getFullDate(date) {
                const year = date.getFullYear();
                const month = (date.getMonth() + 1).toString().padStart(2, '0'); // Les mois sont indexés à zéro
                const day = date.getDate().toString().padStart(2, '0');

                const formattedDate = `${year}-${month}-${day}`;
                return formattedDate;
            }
        }

        Charts.LineSeries {
            id:series
            name: "Série de données"
            axisX: axisX
            axisY: axisY
        }

        Component.onCompleted: {
            update_graph();
        }

        function update_graph() {
            series.clear();
            let query="SELECT "+test1.sumOf+test2.select+" FROM Depense "+test2.where+" GROUP BY "+test2.groupBy+" ORDER BY "+test2.orderBy;
            db.executeQuery("SELECT MIN(sum), MAX(sum), AVG(sum), SUM(sum), COUNT(sum) FROM ("+query+");");
            let temp = db.queryResult.split("|");
            axisY.min = temp[0];
            axisY.max = temp[1];
            console.log(temp[4]);
            if(db.executeQuery(query)) {
                temp = db.queryResult.split("|");
                if(cas_part_month.checked) {
                    //console.log(temp[2]+"-"+temp[1]+" " + temp[0]);
                    series.append(new Date(temp[2]+"-"+temp[1]).getTime(), temp[0]);
                } else {
                    //console.log(temp[1]+" "+temp[0]);
                    series.append(new Date(temp[1]).getTime(), temp[0]);
                }

                while(db.nextQuerry()) {
                    temp = db.queryResult.split("|");
                    if(cas_part_month.checked) {
                        series.append(new Date(temp[2]+"-"+temp[1]).getTime(), temp[0]);
                    } else {
                        series.append(new Date(temp[1]).getTime(), temp[0]);
                    }
                }
            } else {
                console.log("Can't execute "+query);
            }
        }
    }*/
}
