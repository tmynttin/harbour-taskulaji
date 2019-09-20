import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: text_page
    property string page_title: ""
    property string page_content: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: text_column.height
        contentWidth: parent.width

        Column {
            id: text_column
            width: parent.width

            PageHeader {
                title: page_title
                wrapMode: Text.Wrap
            }

            Label {
                id: content_field
                x: Theme.horizontalPageMargin
                text: page_content
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.RichText
            }
        }
    }
}
