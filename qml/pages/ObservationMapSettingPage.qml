import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/document.js" as Doc

Dialog {
    id: observation_map_setting_page
    property var start_date: new Date()
    property var end_date: new Date()
    property string taxo_id
    property string taxo_name
    property bool own_observations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: parent.width

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            DialogHeader { title: qsTr("Observation search settings") }

            ValueButton {
                id: species_button

                function openTaxoDialog() {
                    var dialog = pageStack.push("TaxoSearchPage.qml", {})
                    dialog.accepted.connect(function() {
                        taxo_name = dialog.selected_taxo.name
                        taxo_id = dialog.selected_taxo.id
                    })
                }

                label: qsTr("Taxon: ")
                value: taxo_name ? taxo_name : qsTr("All")
                width: parent.width
                onClicked: openTaxoDialog()
            }

            ValueButton {
                id: start_date_button

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: start_date
                                 })

                    dialog.accepted.connect(function() {
                        start_date = dialog.date
                    })
                }

                label: qsTr("Start date")
                value: start_date.toDateString()
                width: parent.width
                onClicked: openDateDialog()
            }

            ValueButton {
                id: end_date_button

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: end_date
                                 })

                    dialog.accepted.connect(function() {
                        end_date = dialog.date
                    })
                }

                label: qsTr("End date")
                value: end_date.toDateString()
                width: parent.width
                onClicked: openDateDialog()
            }

            TextSwitch {
                 id: own_observations_switch
                 text: qsTr("Only own observations")
                 checked: own_observations
                 onCheckedChanged: {
                     own_observations = checked
                 }
             }

        }
    }
}
