import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Dialog {
    id: unit_page
    property var unit_model

    Component.onCompleted: {
        console.log("Species: " + unit_model.taxo_name)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: parent.width

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            DialogHeader { title: "Unit information" }

            ValueButton {
                id: species_button

                function openTaxoDialog() {
                    var dialog = pageStack.push("../components/TaxoPage.qml", {})
                    dialog.accepted.connect(function() {
                        unit_model.taxo_name = dialog.selected_taxo.name
                        unit_model.taxo_id = dialog.selected_taxo.id
                        amount_field.forceActiveFocus()
                    })
                }

                label: "Species: "
                value: unit_model.taxo_name ? unit_model.taxo_name : "None"
                width: parent.width
                onClicked: openTaxoDialog()
            }

            TextField {
                id: amount_field
                width: parent.width
                text: unit_model.amount
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: "Amount "
                placeholderText: label //"Amount e.g. '5m2f' or '7'"
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {unit_model.amount = text}
                onFocusChanged: {unit_model.amount = text}
            }

            TextField {
                id: unit_notes
                width: parent.width
                label: "Notes"
                text: unit_model.notes
                placeholderText: label
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    unit_model.notes = text
                    focus = false
                }
                onFocusChanged: {unit_model.notes = text}
            }


        }
    }
}
