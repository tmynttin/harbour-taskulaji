import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Page {
    id: document_info_page
    property var documentId
    property var gatheringId
    property bool run_timer
    property string observer: ""
    property var date
    property string municipality: ""

    onGatheringIdChanged: {
        console.log(documentId)
        console.log(gatheringId)
        get_document()
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: run_timer

    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: document_column.height

        Column {
            id: document_column
            height: childrenRect.height
            width: document_info_page.width

            PageHeader {
                title: qsTr("Document")
            }

            SectionHeader {
                text: qsTr("Gathering")
            }

            Item {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                height: childrenRect.height

                Label {
                    id: date_label
                    text: date.toDateString()
                    color: Theme.highlightColor
                }
            }

            Item {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                height: childrenRect.height
                Label {
                    id: municipality_label
                    text: municipality
                    color: Theme.highlightColor
                }
            }

            Item {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                height: childrenRect.height
                Label {
                    id: observer_label
                    text: observer
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            SectionHeader {
                text: qsTr("Units")
            }

            SilicaListView {
                id: unit_list
                width: parent.width
                height: childrenRect.height
                spacing: Theme.paddingLarge

                model: ListModel {
                    id: document_model
                }

                delegate: Column {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2*Theme.horizontalPageMargin
                    height: childrenRect.height

                    Label {
                        text: scientificName
                        font.pixelSize: Theme.fontSizeMedium
                        wrapMode: Text.WordWrap
                        width: parent.width
                        color: Theme.highlightColor

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push("TaxoInfoPage.qml", {taxo_id: taxo_id})
                            }
                        }
                    }

                    Label {
                        text: vernacularName
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Label {
                        text: notes
                        font.pixelSize: Theme.fontSizeExtraSmall
                        wrapMode: Text.WordWrap
                        width: parent.width
                        color: Theme.secondaryHighlightColor
                    }

                    SilicaGridView {
                        id: image_grid
                        width: parent.width
                        height: childrenRect.height
                        cellWidth: width/5
                        cellHeight: width/5

                        model: images

                        delegate: BackgroundItem {

                            id: image_delegate

                            Image {
                                id: observation_image
                                fillMode: Image.PreserveAspectCrop
                                antialiasing: true
                                source: thumbURL
                                cache: false
                                width: image_grid.cellWidth
                                height: image_grid.cellHeight
                            }

                            onClicked: {
                                openImagePage()
                            }

                            function openImagePage() {
                                pageStack.push("ImagePage.qml", {image_model: model})
                            }
                        }

                    }
                }
            }
        }
    }

    function get_document()
    {
        run_timer = true

        Logic.api_qet(write_document, "warehouse/query/single",
                      {"documentId":documentId})
        run_timer = true
    }

    function write_document(status, response) {
        if (status === 200) {

            var gathering_index = 0

            for (var gathering in response.document.gatherings) {
                if (response.document.gatherings[gathering].gatheringId.split("/").pop() === gatheringId) {
                    gathering_index = gathering
                }
            }

            if (response.document.gatherings[gathering_index].team) {
                observer = response.document.gatherings[gathering_index].team[0]
            }
            date = new Date(response.document.gatherings[gathering_index].eventDate.begin)
            municipality = response.document.gatherings[gathering_index].interpretations.municipalityDisplayname ? response.document.gatherings[gathering_index].interpretations.municipalityDisplayname : ""
            var units = response.document.gatherings[gathering_index].units


            for (var i in units) {
                var unit = units[i]
                var taxo_id = (unit.linkings.taxon.id).split("/").pop()
                var scientificName = unit.linkings.taxon.scientificName

                var vernacularName = unit.linkings.taxon.vernacularName ? unit.linkings.taxon.vernacularName.fi : ""
                var notes = unit.notes ? unit.notes : ""
                var images = []

                for (var j in unit.media) {
                    images.push({'fullURL': unit.media[j].fullURL,
                                  'thumbURL': unit.media[j].thumbnailURL})
                }

                document_model.append({ 'taxo_id': taxo_id,
                                          'scientificName': scientificName,
                                          'vernacularName': vernacularName,
                                          'notes': notes,
                                          'images': images
                                      })
            }
            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

}





