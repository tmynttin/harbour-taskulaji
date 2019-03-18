import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Page {
    id: document_info_page
    property var documentId
    property bool run_timer
    property string observer: ""
    property var date
    property string municipality: ""

    onDocumentIdChanged: {
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


                VerticalScrollDecorator {}

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

            if (response.document.gatherings[0].team) {
                observer = response.document.gatherings[0].team[0]
            }
            date = new Date(response.document.gatherings[0].eventDate.begin)
            municipality = response.document.gatherings[0].interpretations.municipalityDisplayname
            var units = response.document.gatherings[0].units

            console.log(JSON.stringify(units))


            for (var i in units) {
                var unit = units[i]
                var taxo_id = (unit.linkings.taxon.id).split("/").pop()
                var scientificName = unit.linkings.taxon.scientificName

                var vernacularName = unit.linkings.taxon.vernacularName ? unit.linkings.taxon.vernacularName.fi : ""
                var notes = unit.notes
                console.log(scientificName)

                document_model.append({ 'taxo_id': taxo_id,
                                          'scientificName': scientificName,
                                          'vernacularName': vernacularName,
                                          'notes': notes
                                      })
            }
            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

}





