import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.3
import "../js/logic.js" as Logic


Page {
    id: map_page
    backNavigation: false

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

    Item {
        id: pos_item
        anchors.centerIn: parent.Center

        Image {
            id: person
            source: "image://theme/icon-m-people"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: person
            source: person
            color: 'red'
        }
    }

    Item {
        id: marker_item
        anchors.centerIn: parent.Center

        Image {
            id: target
            source: "image://theme/icon-m-location"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColorOverlay {
            anchors.fill: target
            source: target
            color: 'blue'
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        Map {
            id: kartta
            width: parent.width
            height: map_page.height * 0.8
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

        Row {
            id: buttons
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter

            IconButton {
                id: back_button
                icon.source: "image://theme/icon-m-back"
                onClicked: pageStack.pop()
            }

            IconButton {
                id: center_button
                icon.source: "image://theme/icon-m-location"
                onClicked: {
                    kartta.center = positionSource.position.coordinate
                }
            }
            IconButton {
                id: accept_button
                icon.source: "image://theme/icon-m-acknowledge"
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

