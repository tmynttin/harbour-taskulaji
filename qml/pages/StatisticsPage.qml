import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db

Page {
    id: unit_list_page

    signal settings_changed()

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
                    statistics_model.clear()
                    current_page = 1
                    get_statistics()
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
                        statistics_model.clear()
                        current_page = 1
                        get_statistics()
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
                        statistics_model.clear()
                        settings_changed()
                        get_statistics()
                    })
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("More")
                onClicked: {
                    get_statistics()
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
                spacing: Theme.paddingSmall

                model: ListModel {
                    id: statistics_model
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
                        onClicked: {pageStack.push('ObservationMapPage.qml', {
                                                       taxo_id: id,
                                                       taxo_name: finnishName,
                                                       start_date: start_date,
                                                       end_date: end_date,
                                                       own_observations: own_observations,
                                                       area: area})
                        }
                        onPressAndHold: {
                            pageStack.push('TaxoInfoPage.qml', {taxo_id : id.split("/")[3]})
                        }
                    }

                    Column {
                        id: unit_column
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*Theme.horizontalPageMargin
                        height: childrenRect.height

                        Label {
                            text: scientificName
                            font.pixelSize: Theme.fontSizeMedium
                            wrapMode: Text.WordWrap
                            width: parent.width
                            color: Theme.highlightColor
                        }

                        Label {
                            visible: finnishName
                            text: finnishName
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Label {
                            visible: count ? true : false
                            text: count ? count : ""
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
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
        get_statistics()
    }

    function get_statistics()
    {
        run_timer = true

        var formatted_start_date = Qt.formatDate(start_date, "yyyy-MM-dd")
        var formatted_end_date = Qt.formatDate(end_date, "yyyy-MM-dd")

        var parameters = {"taxonId":taxo_id,
            "pageSize":"1000",
            "page":current_page,
            "area":area,
            "time":formatted_start_date + "/" + formatted_end_date,
            "aggregateBy":"unit.linkings.taxon.nameFinnish,unit.linkings.taxon.scientificName,unit.linkings.taxon.id",
            "orderBy":"individualCountSum DESC",
            "onlyCount":"false"}

        if (own_observations) {
            parameters.editorOrObserverPersonToken = Logic.get_person_token()
        }

        Logic.api_qet(write_statistics, "warehouse/query/unit/aggregate", parameters)

    }

    function write_statistics(status, response) {
        if (status === 200) {
            //console.log(JSON.stringify(response.document.gatherings[gathering_index]))

            last_page = response.lastPage

            for (var i in response.results) {
                var result = response.results[i]
                var finnishName = ""
                var scientificName = ""
                var id = ""
                var count = ""

                var names = result.aggregateBy
                id = names["unit.linkings.taxon.id"]
                if (names["unit.linkings.taxon.nameFinnish"]) {
                    finnishName = names["unit.linkings.taxon.nameFinnish"]
                }
                if (names["unit.linkings.taxon.scientificName"]) {
                    scientificName = names["unit.linkings.taxon.scientificName"]
                }

                count = result.individualCountSum

                statistics_model.append({ 'finnishName': finnishName,
                                          'scientificName': scientificName,
                                            'id': id,
                                          'count': count,
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





