import QtQuick 2.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.3
import "../js/logic.js" as Logic


Page {
    id: map_page
    backNavigation: false

    property bool run_timer: false

    Timer {
        interval: 500
        running: run_timer
        repeat: true
        onTriggered: result_list.update_list()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (positionSource.valid) {
                kartta.center = positionSource.position.coordinate
                kartta.zoomLevel = 14
                repeat = false
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: Qt.application.active
    }

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Rectangle {
        id: pos_item
        width: 30
        height: 30
        color: 'red'
        anchors.centerIn: parent.Center
    }

    Rectangle {
        id: marker_item
        width: 30
        height: 30
        color: 'blue'
        anchors.centerIn: parent.Center
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        Map {
            id: kartta
            width: parent.width
            height: map_page.height * 0.6
            plugin: mapPlugin
            center: positionSource.position.coordinate
            zoomLevel: 14

            MapQuickItem {
                id: current_position
                coordinate: positionSource.position.coordinate
                sourceItem: pos_item
            }

            MapQuickItem {
                id: marker
                sourceItem: marker_item
                coordinate: current_position.coordinate
            }

            MouseArea {
                anchors.fill: parent
                onPressAndHold: {
                    marker.coordinate = kartta.toCoordinate(Qt.point(mouse.x,mouse.y))

                }
            }
        }

        Label {
            id: coordinate_label
            text: String(marker.coordinate)
        }

        ButtonLayout {

            Button {
                id: center_button
                text: "Center"
                opacity: 1.0
                onClicked: {
                    kartta.center = positionSource.position.coordinate
                }
            }

            Button {
                id: back_button
                text: "Back"
                opacity: 1.0
                onClicked: pageStack.pop()
            }

            Button {
                id: accept_button
                text: "Accept"
                onClicked: {
                    var geometry = {
                                    "type": "Point",
                                    "coordinates": []
                                  };

                    geometry.coordinates = [marker.coordinate.longitude, marker.coordinate.latitude];

                    var prev_page = pageStack.previousPage();
                    prev_page.selectedCoordinate = geometry.coordinates;
                    prev_page.get_municipality(geometry);
                    pageStack.pop();
                }
            }

        }
    }
}

