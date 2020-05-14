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
    property string locality: ""

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

            Label {
                id: date_label
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                text: date.toDateString()
                color: Theme.highlightColor
            }

            Label {
                id: municipality_label
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                text: municipality + (locality ? ", " + locality : "")
                color: Theme.highlightColor
            }

            Label {
                id: observer_label
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                text: observer
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
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

                delegate: Item {
                    width: parent.width
                    height: childrenRect.height

                    MouseArea {
                        anchors.fill: unit_column
                        onClicked: {
                            if (taxo_id) {
                                pageStack.push("TaxoInfoPage.qml", {taxo_id: taxo_id})
                            }
                        }
                    }

                    Column {
                        id: unit_column
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*Theme.horizontalPageMargin
                        height: childrenRect.height

                        Label {
                            visible: scientificName
                            text: scientificName
                            font.pixelSize: Theme.fontSizeMedium
                            wrapMode: Text.WordWrap
                            width: parent.width
                            color: Theme.highlightColor


                        }

                        Label {
                            visible: vernacularName
                            text: vernacularName
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Label {
                            visible: abundance ? true : false
                            text: abundance ? abundance : ""
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Label {
                            visible: notes
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
    }

    function get_document()
    {
        run_timer = true

        Logic.api_qet(write_document, "warehouse/query/document",
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

            var this_gathering = response.document.gatherings[gathering_index]

            //console.log(JSON.stringify(response.document.gatherings[gathering_index]))

            if (this_gathering.team) {
                observer = this_gathering.team[0]
            }
            date = new Date(this_gathering.eventDate.begin)
            municipality = this_gathering.interpretations.municipalityDisplayname ? this_gathering.interpretations.municipalityDisplayname : ""
            locality = this_gathering.locality ? this_gathering.locality : ""

            var units = response.document.gatherings[gathering_index].units


            for (var i in units) {
                var taxo_id = ""
                var scientificName = ""
                var vernacularName = ""
                var abundanceString = ""
                var notes = ""

                var unit = units[i]
                if (unit.linkings) {
                    taxo_id = (unit.linkings.taxon.id).split("/").pop()
                    scientificName = unit.linkings.taxon.scientificName

                    vernacularName = unit.linkings.taxon.vernacularName ? unit.linkings.taxon.vernacularName.fi : ""
                }
                else {
                    vernacularName = unit.taxonVerbatim
                }
                abundanceString = unit.abundanceString

                notes = unit.notes ? unit.notes : ""
                var images = []

                for (var j in unit.media) {
                    images.push({'fullURL': unit.media[j].fullURL,
                                    'thumbURL': unit.media[j].thumbnailURL})
                }

                document_model.append({ 'taxo_id': taxo_id,
                                          'scientificName': scientificName,
                                          'vernacularName': vernacularName,
                                          'abundance': abundanceString,
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





