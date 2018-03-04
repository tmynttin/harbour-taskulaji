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
    property bool run_timer: false
    property var selectedTaxo: {"name": "", "id": ""}
    property var obs
    property var user_data

    onAccepted: {
        build_document()
        send_data()
    }

    function get_municipality(geometry) {
        Logic.api_post("coordinates/location", geometry)
        run_timer = true
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

        // Fill unit information
        for (var j = 0; j < unit_model.count; j++) {
            var unit_doc = new Doc.Unit()
            var unit = unit_model.get(j)
            console.log("Index: " + j + ", Unit: " + unit.taxo_name)

            unit_doc.count = unit.amount
            var identification = new Doc.Identification()
            identification.taxonID = unit.taxo_id
            identification.taxon = unit.taxo_name
            unit_doc.identifications.push(identification)
            unit_doc.notes = unit.notes

            obs.gatherings[0].units.push(unit_doc)
        }
    }

    function send_data() {
        Logic.api_post("documents", obs)
    }

    PositionSource {
        // Added to speed up positioning on MapPage
        id: positionSource
        updateInterval: 1000
        active: Qt.application.active
    }

    Timer {
        interval: 500
        running: run_timer
        repeat: true
        onTriggered: location_label.update_location_label()
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

            DialogHeader { title: "Observation" }

            SectionHeader { text: "Observer"}

            TextSwitch {
                id: hide_user
                text: "Hide observer"
                checked: false
            }

            SectionHeader { text: "Observation Time" }

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

                label: "Date"
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

                label: "Time"
                value: selectedTime.toTimeString()
                width: parent.width
                onClicked: openTimeDialog()
            }

            SectionHeader {
                text: "Location"
            }

            ComboBox {
                property string sec_lev: "none"

                id: secure_level
                width: parent.width
                label: "Secure level: "
                currentIndex: 1

                menu: ContextMenu {
                    Repeater {

                        function build_model() {
                            var ret = []
                            for (var key in Doc.secureLevel) {
                                ret.push(key)
                            }
                            return ret
                        }

                        model: build_model()
                        MenuItem {
                            id: itemi
                            text: modelData
                            onClicked: {
                                secure_level.sec_lev = itemi.text
                            }
                        }
                    }
                }
            }

            ComboBox {
                id: position_combo_box
                width: parent.width
                label: selectedCoordinate ? String(selectedCoordinate) : "Position"
                currentIndex: 0

                menu: ContextMenu {
                    MenuItem {
                        function openMapDialog() {
                            var dialog = pageStack.push("../components/MapPage.qml", {})

                        }
                        text: "From Map"
                        onClicked: {
                            openMapDialog()

                        }
                    }
                    MenuItem { text: "From Favorites" }
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

                    function update_location_label() {
                        console.log("Updating label")
                        if (Logic.response_ready) {
                            console.log("Response is ready")
                            var response = Logic.response;
                            console.log(JSON.stringify(response))
                            var response_locations = response.results;

                            for (var i in response_locations) {
                                var location = response_locations[i];
                                console.log("Location type: " + location.types[0])
                                if (location.types[0] === "municipality") {
                                    console.log(location.formatted_address)
                                    location_label.text = location.formatted_address
                                    run_timer = false;
                                    return
                                }
                            }
                            run_timer = false;
                        }
                    }
                }
            }

            TextArea {
                id: place_description
                width: parent.width
                label: "Place description"
                placeholderText: label
            }

            SectionHeader {
                text: "Observations"
            }

            ListModel {
                id: unit_model
                ListElement {
                    taxo_name: ""
                    taxo_id: ""
                    amount: ""
                    notes: ""
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

                        label: "Species"
                        value: taxo_name
                        width: parent.width
                        onClicked: openTaxoDialog()
                    }

                    TextField {
                        id: amount_field
                        width: parent.width
                        text: amount
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        label: "Amount "
                        placeholderText: label //"Amount e.g. '5m2f' or '7'"
                        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                        EnterKey.onClicked: {amount = text}
                        onFocusChanged: {amount = text}
                    }

                    TextField {
                        id: unit_notes
                        width: parent.width
                        label: "Notes"
                        placeholderText: label
                        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                        EnterKey.onClicked: {
                            notes = text
                            focus = false
                        }
                        onFocusChanged: {notes = text}
                    }

                    Separator {

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
                        unit_model.append({taxo_name: "", taxo_id: "", amount: "", notes: ""})
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
