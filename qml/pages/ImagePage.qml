import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: image_page
    property var image_model
    property var visible_item: image_item.status == Image.Ready ? image_item : placeholder

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: childrenRect.height

        Column {
            width: parent.width

            Item {
                width: parent.width
                height: visible_item.height

                ProgressCircle {
                    width: parent.width
                    value: image_item.progress
                    anchors.verticalCenter: parent.verticalCenter
                    visible: image_item.status !== Image.Ready
                }

                Rectangle {
                    id: placeholder
                    width: parent.width
                    height: width
                    opacity: 0
                    visible: image_item.status !== Image.Ready

                }

                Image {
                    id: image_item
                    width: parent.width
                    fillMode: Image.PreserveAspectFit
                    source: image_model.fullURL
                }
            }

            Label {
                x: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: image_model.scientificName
            }

            Label {
                x: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
                text: image_model.vernacularName
            }

            Label {
                x: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryHighlightColor
                text: qsTr("Author: ") + image_model.author
            }
        }
    }
}





