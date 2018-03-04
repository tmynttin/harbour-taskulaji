import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Page {
    id: error_page
    property string message: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: error_column.height
        contentWidth: parent.width

        Column {
            id: error_column
            width: parent.width

            PageHeader {
                title: "Error message"
            }

            Label {
                id: error_field
                text: message
                width: parent.width
                wrapMode: Text.Wrap
            }
        }
    }
}
