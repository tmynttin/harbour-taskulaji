import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.3
import "../components"
import "../js/logic.js" as Logic
import "../js/document.js" as Doc
import "../js/database.js" as DB


Dialog {
    id: observation_page
    objectName: "ObservationPage"

    property var locale: Qt.locale()
    property var currentDate: new Date()
    property var selectedCoordinate
    property var country
    property var municipation
    property var selectedTaxo: {"name": "", "id": ""}
    property var obs
    property var user_data

    onAccepted: {
        build_document()
        send_data()
    }

    function get_municipality(geometry) {
        Logic.api_post(location_label.update_location_label, "coordinates/location", geometry)
    }

    function build_document() {
        obs = new Doc.Document()
        obs.gatheringEvent = new Doc.GatheringEvent()
        obs.gatherings.push(new Doc.Gathering())

        // Fill document information
        user_data = DB.dbGetUser()
        obs.creator = user_data.person_id
        obs.editors.push(user_data.person_id)
        obs.secureLevel = Doc.secureLevel[secure_level.sec_lev]

        // Fill gathering event information
        obs.gatheringEvent.dateBegin = Qt.formatDate(date_button.selectedDate, "yyyy-MM-dd")
        obs.gatheringEvent.leg.push(user_data.person_id)
        obs.gatheringEvent.legUserID.push(user_data.person_id)
        obs.gatheringEvent.timeStart = time_button.value
        obs.gatheringEvent.legPublic = !hide_user.checked

        // Fill gathering information
        obs.gatherings[0].dateBegin = Qt.formatDate(date_button.selectedDate, "yyyy-MM-dd")
        obs.gatherings[0].geometry.coordinates = selectedCoordinate
        obs.gatherings[0].municipality = location_label.text
        obs.gatherings[0].locality = locality.text
        obs.gatherings[0].localityDescription = locality_description.text

        // Fill unit information
        for (var j = 0; j < unit_model.count; j++) {
            var unit_doc = new Doc.Unit()
            var unit = unit_model.get(j)
            console.log("Index: " + j + ", Unit: " + unit.taxo_name)

            unit_doc.count = unit.amount
            var identification = new Doc.Identification()
            identification.taxon = unit.taxo_name
            unit_doc.identifications.push(identification)
            unit_doc.notes = unit.notes
            unit_doc.recordBasis = Doc.recordBasis[unit.record_basis]
            unit_doc.taxonConfidence = Doc.taxonConfidence[unit.taxon_confidence]

            obs.gatherings[0].units.push(unit_doc)
        }
    }

    function send_data() {
        Logic.api_post(pass_func, "documents", obs)
    }

    function pass_func() {
        console.log("Send successful")
    }

    PositionSource {
        // Added to speed up positioning on MapPage
        id: positionSource
        updateInterval: 1000
        active: Qt.application.active
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

            DialogHeader { title: qsTr("Observation") }

            SectionHeader { text: qsTr("Observer")}

            TextSwitch {
                id: hide_user
                text: qsTr("Hide observer")
                checked: false
            }

            SectionHeader { text: qsTr("Observation Time") }

            ValueButton {
                id: date_button
                property date selectedDate: currentDate

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: selectedDate
                                 })

                    dialog.accepted.connect(function() {
                        selectedDate = dialog.date
                    })
                }

                label: qsTr("Date")
                value: selectedDate.toDateString()
                width: parent.width
                onClicked: openDateDialog()
            }

            ValueButton {
                id: time_button
                property var selectedTime: currentDate

                function openTimeDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                    hourMode: DateTime.TwentyFourHours,
                                    hour: selectedTime.getHours(),
                                    minute: selectedTime.getMinutes()
                                 })

                    dialog.accepted.connect(function() {
                        selectedTime = dialog.time
                    })
                }

                label: qsTr("Time")
                value: selectedTime.toTimeString()
                width: parent.width
                onClicked: openTimeDialog()
            }

            SectionHeader {
                text: qsTr("Location")
            }

            TextSwitch {
                property string sec_lev: "none"

                id: secure_level
                text: qsTr("Coarse location")
                checked: false

                onCheckedChanged: {
                    if (checked) {
                        sec_lev = "KM10"
                    }
                    else {
                        sec_lev = "none"
                    }
                }
            }

            Row {
                id: map_buttons
                spacing: Theme.paddingLarge
                width: parent.width
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge

                function openMapDialog() {
                    var dialog = pageStack.push("../components/MapPage.qml", {})

                }

                IconButton {
                    id: position_button
                    icon.source: "image://theme/icon-m-gps"
                    onClicked: {
                        map_buttons.openMapDialog()
                    }
                }

                BackgroundItem {
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.verticalCenter: position_button.verticalCenter
                    onClicked: {
                        map_buttons.openMapDialog()
                    }

                    Label {
                        id: coordinate_label
                        anchors.verticalCenter: parent.verticalCenter
                        text: selectedCoordinate ? String(selectedCoordinate) : qsTr("Position")
                        color: Theme.highlightColor
                    }
                }
            }

            Item {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*Theme.horizontalPageMargin
                height: childrenRect.height

                Label {
                    id: location_label
                    width: parent.width
                    text:  ""

                    function update_location_label(response) {
                        console.log("Updating label")

                        console.log(JSON.stringify(response))
                        var response_locations = response.results;

                        for (var i in response_locations) {
                            var location = response_locations[i];
                            console.log("Location type: " + location.types[0])
                            if (location.types[0] === "municipality") {
                                console.log(location.formatted_address)
                                location_label.text = location.formatted_address
                                return
                            }
                        }
                    }
                }
            }

            TextField {
                id: locality
                width: parent.width
                label: qsTr("Locality names")
                placeholderText: label
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            }

            TextField {
                id: locality_description
                width: parent.width
                label: qsTr("Locality description")
                placeholderText: label
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            }

            SectionHeader {
                text: qsTr("Observations")
            }

            ListModel {
                id: unit_model
                ListElement {
                    taxo_name: ""
                    taxo_id: ""
                    amount: ""
                    notes: ""
                    taxon_confidence: "Sure"
                    record_basis: "MY.recordBasisHumanObservation"
                }
            }

            Repeater {
                id: unit_repeater
                model: unit_model
                delegate: delegate_item

                Column {
                    id: delegate_item
                    height: childrenRect.height
                    width: parent.width

                    BackgroundItem {
                        width: parent.width

                        ValueButton {
                            id: species_button

                            function openTaxoDialog() {
                                var dialog = pageStack.push("../components/TaxoPage.qml", {})
                                dialog.accepted.connect(function() {
                                    taxo_name = dialog.selected_taxo.name
                                    taxo_id = dialog.selected_taxo.id
                                    amount_field.forceActiveFocus()
                                })
                            }

                            label: qsTr("Species: ")
                            value: taxo_name ? taxo_name : qsTr("None")
                            width: parent.width - unit_options.width - Theme.paddingLarge
                            onClicked: openTaxoDialog()
                        }

                        IconButton {
                            id: unit_options
                            anchors.left: species_button.right
                            anchors.verticalCenter: species_button.verticalCenter
                            icon.source: "image://theme/icon-m-right"
                            onClicked: {
                                openUnitDialog()
                            }

                            function openUnitDialog() {
                                var dialog = pageStack.push("../components/UnitPage.qml", {
                                                unit_model: model
                                             })

                                dialog.accepted.connect(function() {
                                    model = dialog.unit_model
                                })
                            }
                        }
                    }

                    TextField {
                        id: amount_field
                        width: parent.width
                        text: amount
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        label: qsTr("Amount ")
                        placeholderText: label //"Amount e.g. '5m2f' or '7'"
                        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                        EnterKey.onClicked: {amount = text}
                        onFocusChanged: {amount = text}
                    }
                }
            }

            Row {
                width: childrenRect.width
                height: childrenRect.height + 2 * Theme.paddingLarge
                anchors.left: parent.left
                spacing: Theme.paddingLarge

                IconButton {
                    id: unit_adder
                    icon.source: "image://theme/icon-l-add"
                    onClicked: {
                        unit_model.append({taxo_name: "", taxo_id: "", amount: "", notes: "", taxon_confidence: "Sure", record_basis: "Seen"})
                    }
                }

                IconButton {
                    id: unit_remover
                    icon.source: "image://theme/icon-l-clear"
                    onClicked: {
                        unit_model.remove(unit_model.count - 1)
                    }
                }
            }
        }
    }
}
