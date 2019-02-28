import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    property string fullImage: ""

    Image {
        id: image_item
        source: fullImage
    }

}
