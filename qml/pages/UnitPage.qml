import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/document.js" as Doc

Page {
    id: unit_page
    property var unit_model
    property int model_index

    Component.onCompleted: {
        console.log("Species: " + unit_model.taxo_name)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: parent.width

        PullDownMenu {

            MenuItem {
                text: qsTr("Delete unit")
                onClicked: {
                    pageStack.previousPage(pageStack.currentPage).unit_model.remove(model_index)
                    pageStack.pop()
                }
            }
        }

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader { title: qsTr("Unit information") }

            ValueButton {
                id: species_button

                function openTaxoDialog() {
                    var dialog = pageStack.push("TaxoSearchPage.qml", {})
                    dialog.accepted.connect(function() {
                        unit_model.taxo_name = dialog.selected_taxo.name
                        unit_model.taxo_id = dialog.selected_taxo.id
                        amount_field.forceActiveFocus()
                    })
                }

                label: qsTr("Species: ")
                value: unit_model ? (unit_model.taxo_name ? unit_model.taxo_name : "None") : ""
                width: parent.width
                onClicked: openTaxoDialog()
            }

            BackgroundItem {
                id: amount_row
                width: parent.width
                height: amount_field.height

                property bool is_numeric: true

                TextField {
                    id: amount_field
                    width: parent.width - amount_input_method_button.width - Theme.paddingLarge
                    text: unit_model ? unit_model.amount : ""
                    inputMethodHints: amount_row.is_numeric ? Qt.ImhFormattedNumbersOnly : Qt.ImhNoPredictiveText
                    label: qsTr("Amount ")
                    placeholderText: amount_row.is_numeric ? qsTr("Amount e.g. '7'") : qsTr("Amount e.g. '5m2f'")
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    onTextChanged: {unit_model.amount = text}
                }

                IconButton {
                    id: amount_input_method_button
                    anchors.left: amount_field.right
                    anchors.top: amount_field.top
                    icon.source: amount_row.is_numeric ? "image://theme/icon-m-keyboard" : "image://theme/icon-m-dialpad"
                    onClicked: {
                        amount_row.is_numeric = !amount_row.is_numeric
                        amount_field.forceActiveFocus()
                    }
                }
            }

            TextField {
                id: unit_notes
                width: parent.width
                label: qsTr("Notes")
                text: unit_model ? unit_model.notes : ""
                placeholderText: label
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"

                onTextChanged: {
                    unit_model.notes = text
                }
            }

            ComboBox {
                id: taxon_confidence_combobox
                property var taxon_confidence_model: Doc.taxonConfidence

                Component.onCompleted: {
                    for (var i in taxon_confidence_model) {
                        console.log("checking " + taxon_confidence_model[i].property)
                        if (taxon_confidence_model[i].property === unit_model.taxon_confidence) {
                            currentIndex = i
                            console.log("setting currentIndex to " + i)
                        }
                    }
                }

                width: parent.width
                label: qsTr("Taxon confidence")
                menu: ContextMenu {
                    Repeater {
                        model: taxon_confidence_combobox.taxon_confidence_model
                        MenuItem {
                            id: taxon_confidence_item
                            text: modelData.label.fi
                            onClicked: {
                                unit_model.taxon_confidence = modelData.property
                            }
                        }
                    }
                }
            }

            ComboBox {

                property var record_basis_model: Doc.recordBasis

                Component.onCompleted: {
                    for (var i in record_basis_model) {
                        console.log("checking " + record_basis_model[i].property)
                        if (record_basis_model[i].property === unit_model.record_basis) {
                            currentIndex = i
                            console.log("setting currentIndex to " + i)
                        }
                    }
                }

                id: record_basis_combobox
                width: parent.width
                label: qsTr("Record basis")
                menu: ContextMenu {
                    Repeater {
                        id: record_basis_list
                        model: record_basis_combobox.record_basis_model
                        MenuItem {
                            id: record_basis_item
                            text: modelData.label.fi
                            onClicked: {
                                unit_model.record_basis = modelData.property
                            }
                        }
                    }
                }
            }
        }
    }
}
