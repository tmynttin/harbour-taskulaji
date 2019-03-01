import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    property string fullImage: ""

    PinchArea {

    }

    Image {
        id: image_item
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: fullImage
    }
}
