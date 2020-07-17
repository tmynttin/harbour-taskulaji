import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db

Page {
    id: unit_list_page
    property string taxo_id: ""
    property string taxo_name: ""
    property string area: "Suomi"
    property var start_date: new Date()
    property var end_date: new Date()
    property bool own_observations: false
    property int current_page: 1
    property int last_page: 1
    property bool run_timer

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: run_timer
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: unit_list_column.height

        VerticalScrollDecorator {}

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    unit_list_model.clear()
                    current_page = 1
                    get_units()
                }
            }

            MenuItem {
                text: qsTr("Map view")
                onClicked: {
                    var observation_map = pageStack.push("ObservationMapPage.qml", {
                                       taxo_id: taxo_id,
                                       taxo_name: taxo_name,
                                       start_date: start_date,
                                       end_date: end_date,
                                       own_observations: own_observations,
                                       area: area})

                    observation_map.page_closed.connect(function() {
                        start_date = observation_map.start_date
                        end_date = observation_map.end_date
                        taxo_id = observation_map.taxo_id
                        taxo_name = observation_map.taxo_name
                        area = observation_map.area
                        own_observations = observation_map.own_observations
                        unit_list_model.clear()
                        current_page = 1
                        get_units()
                    })
                }

            }

            MenuItem {
                text: qsTr("Staistics view")
                onClicked: {
                    var staistics_page = pageStack.push("StatisticsPage.qml", {
                                       taxo_id: taxo_id,
                                       taxo_name: taxo_name,
                                       start_date: start_date,
                                       end_date: end_date,
                                       own_observations: own_observations,
                                       area: area})

                    staistics_page.settings_changed.connect(function() {
                        start_date = staistics_page.start_date
                        end_date = staistics_page.end_date
                        taxo_id = staistics_page.taxo_id
                        taxo_name = staistics_page.taxo_name
                        area = staistics_page.area
                        own_observations = staistics_page.own_observations
                        unit_list_model.clear()
                        current_page = 1
                        get_units()
                    })
                }
            }

            MenuItem {
                text: qsTr("Search settings")
                onClicked: openSettingsDialog()

                function openSettingsDialog() {
                    var dialog = pageStack.push("ObservationMapSettingPage.qml", {start_date:start_date,
                                                    end_date: end_date,
                                                    taxo_id: taxo_id,
                                                    taxo_name: taxo_name,
                                                    area: area,
                                                    own_observations: own_observations})
                    dialog.accepted.connect(function() {
                        start_date = dialog.start_date
                        end_date = dialog.end_date
                        taxo_id = dialog.taxo_id
                        taxo_name = dialog.taxo_name
                        area = dialog.area
                        own_observations = dialog.own_observations
                        current_page = 1
                        unit_list_model.clear()
                        get_units()
                    })
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("More")
                onClicked: {
                    get_units()
                }
            }
        }

        Column {
            id: unit_list_column
            height: childrenRect.height
            width: unit_list_page.width

            PageHeader {
                title: qsTr("Units")
            }

            SilicaListView {
                id: unit_list
                width: parent.width
                height: childrenRect.height
                spacing: Theme.paddingLarge

                model: ListModel {
                    id: unit_list_model
                }

                section {
                    property: 'section'

                    delegate: SectionHeader {
                        text: section
                        height: Theme.itemSizeExtraSmall
                    }
                }

                delegate: Item {
                    width: parent.width
                    height: childrenRect.height

                    MouseArea {
                        anchors.fill: unit_column
                        onClicked: {pageStack.push('DocumentInfoPage.qml',
                                                   {documentId: documentId,
                                                       gatheringId: gatheringId})
                        }

                        onPressAndHold: {
                            pageStack.push('TaxoInfoPage.qml', {taxo_id : taxo_id})
                        }
                    }

                    Column {
                        id: unit_column
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*Theme.horizontalPageMargin
                        height: childrenRect.height

                        Label {
                            visible: scientificName
                            text: scientificName
                            font.pixelSize: Theme.fontSizeMedium
                            wrapMode: Text.WordWrap
                            width: parent.width
                            color: Theme.highlightColor
                        }

                        Label {
                            visible: vernacularName
                            text: vernacularName
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Label {
                            visible: abundance ? true : false
                            text: abundance ? abundance : ""
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Label {
                            visible: notes
                            text: notes
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
                            color: Theme.secondaryHighlightColor
                        }

                        Label {
                            id: gathering_time
                            text: Format.formatDate(time, Formatter.DateLong) + ", " + municipality
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.italic: true
                            color: Theme.secondaryHighlightColor
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        taxo_id = Db.getSetting("taxo_id")
        taxo_name = Db.getSetting("taxo_name")
        area = Db.getSetting("area")
        own_observations = Db.getSetting("own_observations")
        get_units()
    }

    function get_units()
    {
        run_timer = true

        var formatted_start_date = Qt.formatDate(start_date, "yyyy-MM-dd")
        var formatted_end_date = Qt.formatDate(end_date, "yyyy-MM-dd")

        var parameters = {"taxonId":taxo_id,
            "pageSize":"1000",
            "page":current_page,
            "area":area,
            "time":formatted_start_date + "/" + formatted_end_date}//,
            //"coordinates":coordinate}
        if (own_observations) {
            parameters.editorOrObserverPersonToken = Logic.get_person_token()
        }

        Logic.api_qet(write_units, "warehouse/query/unit/list", parameters)

    }

    function write_units(status, response) {
        if (status === 200) {
            //console.log(JSON.stringify(response.document.gatherings[gathering_index]))

            last_page = response.lastPage

            for (var i in response.results) {
                var result = response.results[i]
                var taxo_id = ""
                var scientificName = ""
                var vernacularName = ""
                var abundanceString = ""
                var municipality = ""
                var notes = ""

                var unit = result.unit
                if (unit.linkings) {
                    taxo_id = (unit.linkings.taxon.id).split("/").pop()
                    scientificName = unit.linkings.taxon.scientificName

                    vernacularName = unit.linkings.taxon.vernacularName ? unit.linkings.taxon.vernacularName.fi : ""
                }
                else {
                    vernacularName = unit.taxonVerbatim
                }
                abundanceString = unit.abundanceString

                if (result.gathering.interpretations) {
                    municipality = result.gathering.interpretations.municipalityDisplayname
                }
                else {
                    municipality = ""
                }

                notes = unit.notes ? unit.notes : ""

                var date_string = result.gathering.displayDateTime.slice(0,10)
                var time = new Date(date_string)

                var gatheringId = result.gathering.gatheringId.split("/").pop()
                var documentId = result.document.documentId

                unit_list_model.append({ 'taxo_id': taxo_id,
                                          'scientificName': scientificName,
                                          'vernacularName': vernacularName,
                                          'abundance': abundanceString,
                                          'municipality': municipality,
                                          'time': time,
                                          'notes': notes,
                                          'gatheringId': gatheringId,
                                          'documentId': documentId,
                                          'section': Format.formatDate(time, Formatter.TimepointSectionRelative),
                                      })
            }
            current_page++

            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

}





