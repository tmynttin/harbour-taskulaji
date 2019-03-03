import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    property string fullImage: ""

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: image_item.status != Image.Ready
    }

    Image {
        id: image_item
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: fullImage
    }
}
