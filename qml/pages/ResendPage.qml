import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db

Page {
    id: resend_page

    Component.onCompleted: {
        get_documents()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: document_column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Delete all")
                onClicked: {
                    Remorse.popupAction(resend_page, "Deleting all", function () {Db.deleteAllDocuments(); pageStack.pop()}, 10000)
                }
            }
        }

        Column {
            id: document_column
            width: resend_page.width

            PageHeader {
                title: qsTr("Pending documents")
            }

            SilicaListView {
                id: document_list
                width: parent.width
                height: childrenRect.height
                spacing: Theme.paddingLarge

                model: ListModel {
                    id: document_model
                }

                delegate: ListItem {
                    width: ListView.view.width
                    contentHeight: Theme.itemSizeExtraLarge

                    menu: ContextMenu {

                        MenuItem {
                            text: qsTr("Resend")
                            onClicked: {
                                console.log("Sending: " + JSON.stringify(document))
                                Db.deleteDocument(string_document)
                                pageStack.replace("ObservationConfirmationPage.qml", {observation: document})

                            }
                        }

                        MenuItem {
                            text: qsTr("Delete")
                            onClicked: {

                                console.log("Deleting: " + string_document)
                                Db.deleteDocument(string_document)
                                document_model.remove(index, 1)
                            }
                        }
                    }

                    Column {
                        id: document_delegate_column
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*Theme.horizontalPageMargin

                        Label {
                            text: date
                            font.pixelSize: Theme.fontSizeMedium
                            width: parent.width
                            color: Theme.highlightColor


                        }

                        Label {
                            text: municipality
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width
                        }

                        Label {
                            visible: locality
                            text: locality
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width
                        }

                        Label {
                            text: units
                            font.pixelSize: Theme.fontSizeExtraSmall
                            width: parent.width
                            color: Theme.secondaryHighlightColor
                        }
                    }
                }
            }
        }
    }

    function get_documents()
    {

        var documents = Db.getDocuments()

        for (var i = 0; i < documents.rows.length; i++) {
            console.log("Got document: " + documents.rows.item(i).document)
            var string_document = documents.rows.item(i).document
            var document = JSON.parse(documents.rows.item(i).document)
            var units = ""
            for (var j in document.gatherings[0].units) {
                units += document.gatherings[0].units[j].identifications[0].taxon + ", "
            }

            document_model.append({
                                      date: document.gatherings[0].dateBegin,
                                      municipality: document.gatherings[0].municipality,
                                      locality: document.gatherings[0].locality,
                                      units: units,
                                      string_document: string_document,
                                      document: document
                                  })
        }
    }
}





