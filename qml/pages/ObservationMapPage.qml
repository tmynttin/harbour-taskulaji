import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.3
import "../js/logic.js" as Logic
import "../js/database.js" as Db


Page {
    id: distribution_map_page

    signal page_closed()

    property string taxo_id: ""
    property string taxo_name: ""
    property string area: ""
    property var start_date: new Date()
    property var end_date: new Date()
    property bool run_timer: false
    property int max_count
    property int current_page: 1
    property int last_page: 1
    property real zoom_level: 4.2
    property bool own_observations: false

    backNavigation: false

    Component.onCompleted: {
        max_count = Db.getSetting("max_observations")
        kartta.zoomLevel = zoom_level + Screen.height / 960
        get_observations(current_page)
    }

    onStatusChanged: {
        if (distribution_map_page.status == PageStatus.Active) {
            hit_gatherings.clear()
        }
    }

    Timer {
        id: hit_timer
        running: false
        repeat: false
        interval: 100
        onTriggered: {
            if (hit_gatherings.count > 1) {
                pageStack.push("ObservationListPage.qml",
                               {gathering_list_model:hit_gatherings})
            }
            else {
                var document_model = hit_gatherings.get(0)
                pageStack.push('DocumentInfoPage.qml',
                               {documentId: document_model.documentId,
                                   gatheringId: document_model.gatheringId})
            }
            //hit_gatherings.clear()
        }


    }

    ListModel {
        id: hit_gatherings
    }

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        Map {
            id: kartta
            width: parent.width
            height: Screen.height * 0.85
            plugin: mapPlugin
            center {
                latitude: 65.5
                longitude: 26
            }

            MapItemView {

                model: ListModel {
                    id: map_model
                }


                delegate: MapQuickItem {
                    id: marker
                    anchorPoint.x: marker_image.width/2
                    anchorPoint.y: marker_image.height



                    sourceItem: Image {
                        id: marker_image
                        source: "image://theme/icon-m-location"

                        ColorOverlay {
                            anchors.fill: marker_image
                            source: marker_image
                            color: 'blue'
                        }

                        MouseArea {
                            anchors.fill: marker_image
                            onClicked: {
                                mouse.accepted = false
                                hit_gatherings.append(model)
                                hit_timer.restart()
//                                pageStack.push('DocumentInfoPage.qml',
//                                               {documentId: documentId,
//                                                   gatheringId: gatheringId})
                                console.log("Clicked: " + gatheringId)
                            }
                            propagateComposedEvents: true
                        }
                    }



                    coordinate {
                        latitude: latti
                        longitude: lontti
                    }


                }
            }
        }

        Row {
            id: buttons
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter

            IconButton {
                id: back_button
                icon.source: "image://theme/icon-m-back"
                onClicked: {
                    distribution_map_page.page_closed()
                    pageStack.pop()
                }
            }

            IconButton {
                id: refresh_button
                icon.source: "image://theme/icon-m-refresh"
                onClicked: {
                    current_page = 1
                    map_model.clear()
                    get_observations(current_page)
                }
            }

            IconButton {
                id: list_button
                icon.source: "image://theme/icon-m-note"
                onClicked: pageStack.push("ObservationListPage.qml", {gathering_list_model:map_model})
            }

            IconButton {
                id: settings_button
                icon.source: "image://theme/icon-m-developer-mode"
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
                        map_model.clear()
                        get_observations(current_page)
                    })
                }
            }
        }
    }

    function get_observations(page)
    {
        var topLeftCoordinate = kartta.toCoordinate(Qt.point(0,0))
        var bottomRightCoordinate = kartta.toCoordinate(Qt.point(kartta.width,kartta.height))
        var latMin = bottomRightCoordinate.latitude
        var latMax = topLeftCoordinate.latitude
        var lonMin = topLeftCoordinate.longitude
        var lonMax = bottomRightCoordinate.longitude
        var system = 'WGS84'
        var coordinate = latMin + ":" + latMax + ":" + lonMin + ":" +lonMax + ":" + system

        var formatted_start_date = Qt.formatDate(start_date, "yyyy-MM-dd")
        var formatted_end_date = Qt.formatDate(end_date, "yyyy-MM-dd")

        var parameters = {"taxonId":taxo_id,
            "pageSize":"100",
            "page":current_page,
            "area":area,
            "time":formatted_start_date + "/" + formatted_end_date,
            "coordinates":coordinate}
        if (own_observations) {
            parameters.editorOrObserverPersonToken = Logic.person_token
        }

        Logic.api_qet(draw_observations, "warehouse/query/unit/list", parameters)
        run_timer = true
    }

    function draw_observations(status, response) {
        if (status === 200) {
            console.log(JSON.stringify(response.total))

            last_page = response.lastPage

            for (var i in response.results) {
                var gathering_exists = false
                var result = response.results[i]
                var gatheringId = result.gathering.gatheringId.split("/").pop()

                for (var j=0; j < map_model.count; j++) {
                    if (map_model.count > 0 && map_model.get(j).gatheringId === gatheringId) {
                        gathering_exists = true
                    }
                }

                if (!gathering_exists) {

                    var centerLatitude = parseFloat(result.gathering.conversions.wgs84CenterPoint.lat)
                    var centerLongitude = parseFloat(result.gathering.conversions.wgs84CenterPoint.lon)


                    var documentId = result.document.documentId
                    var date = result.gathering.displayDateTime
                    var municipality = result.gathering.interpretations.municipalityDisplayname
                    var locality = result.gathering.locality
                    var observer = result.gathering.team ? result.gathering.team[0] : ""

                    if (map_model.count <= max_count) {

                    map_model.append({ 'latti': centerLatitude,
                                         'lontti': centerLongitude,
                                         'documentId': documentId,
                                         'gatheringId': gatheringId,
                                         'date': date,
                                         'municipality': municipality,
                                         'locality': locality,
                                         'observer': observer
                                     })
                    }
                }
            }
            current_page++

            if ((current_page <= last_page) && (map_model.count < max_count)) {
                get_observations(current_page)
            }
            else {
                console.log("Items: " + map_model.count)
                run_timer = false

                if (map_model.count >= max_count) {
                    Remorse.popupAction(distribution_map_page, qsTr("Too many observations to show"), function() {})
                }
            }
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }
}



