import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/document.js" as Doc

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

            DialogHeader { title: qsTr("Unit information") }

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

                label: qsTr("Species: ")
                value: unit_model.taxo_name ? unit_model.taxo_name : "None"
                width: parent.width
                onClicked: openTaxoDialog()
            }

            TextField {
                id: amount_field
                width: parent.width
                text: unit_model.amount
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Amount ")
                placeholderText: label //"Amount e.g. '5m2f' or '7'"
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {unit_model.amount = text}
                onFocusChanged: {unit_model.amount = text}
            }

            TextField {
                id: unit_notes
                width: parent.width
                label: qsTr("Notes")
                text: unit_model.notes
                placeholderText: label
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    unit_model.notes = text
                    focus = false
                }
                onFocusChanged: {unit_model.notes = text}
            }

            ComboBox {
                id: taxon_confidence_combobox
                width: parent.width
                label: qsTr("Taxon confidence")
                currentIndex: 1
                menu: ContextMenu {
                    Repeater {
                        function build_model() {
                            var ret = []
                            for (var key in Doc.taxonConfidence) {
                                ret.push(key)
                            }
                            return ret
                        }
                        model: build_model()
                        MenuItem {
                            id: taxon_confidence_item
                            text: modelData
                            onClicked: {
                                unit_model.taxon_confidence = taxon_confidence_item.text
                            }
                        }
                    }
                }
            }

            ComboBox {
                id: record_basis_combobox
                width: parent.width
                label: qsTr("Record basis")
                currentIndex: 1
                menu: ContextMenu {
                    Repeater {
                        id: record_basis_list
                        model: Doc.recordBasis
                        MenuItem {
                            id: record_basis_item
                            text: modelData
                            onClicked: {
                                unit_model.record_basis = record_basis_item.text
                            }
                        }
                    }
                }
            }
        }
    }
}
