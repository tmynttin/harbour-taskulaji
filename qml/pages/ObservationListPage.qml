import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic


Page {
    id: my_obs_page

    property bool run_timer: false
    property real page: 0
    property var gathering_list_model

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: run_timer
    }

    SilicaListView {
        id: obs_column
        spacing: Theme.paddingMedium
        anchors.fill: parent

        header: PageHeader {
            id: page_header
            title: qsTr("Gathering list")
        }

        model: gathering_list_model

        VerticalScrollDecorator {}

        delegate: BackgroundItem {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*Theme.horizontalPageMargin
            height: gathering_column.height

            Column {
                id: gathering_column
                width: parent.width

                Label {
                    id: obs_location
                    text: municipality + (locality ? ", " + locality : "")
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                    anchors.topMargin: Theme.paddingMedium
                    color: Theme.highlightColor
                }

                Label {
                    id: obs_time
                    text: date
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.italic: true
                    color: Theme.secondaryHighlightColor
                    anchors {
                        topMargin: Theme.paddingSmall
                    }
                }

                Label {
                    id: obs_taxon
                    text: observer
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            onClicked: {
                pageStack.push('DocumentInfoPage.qml',
                               {documentId: documentId,
                                   gatheringId: gatheringId})
            }
        }

    }
}
