import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    x: Theme.horizontalPageMargin
    width: parent.width - 2*Theme.horizontalPageMargin
    height: childrenRect.height

    Label {
        id: scientific_name
        text: scientificName
        font.pixelSize: Theme.fontSizeMedium
        wrapMode: Text.WordWrap
        width: parent.width
        color: Theme.highlightColor
    }

    Label {
        id: vernacular_name
        text: vernacularName
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.WordWrap
        width: parent.width
        //anchors.topMargin: Theme.paddingMedium

        anchors.top: scientific_name.bottom
    }
}
