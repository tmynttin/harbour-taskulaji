import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as Db
import "../js/logic.js" as Logic


Page {
    id: mainPage

    Component.onCompleted: {
        Db.dbInit();
        Logic.page_stack = pageStack
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width

        PullDownMenu {
            id: pull_down
            visible: true
            spacing: Theme.paddingLarge

            MenuItem {
                text: qsTr("New Observation")
                onClicked: pageStack.push(Qt.resolvedUrl("ObservationPage.qml"))
            }
        }

        ListModel {
            id: pagesModel

            ListElement {
                page: "ObservationPage.qml"
                title: qsTr("New Observation")
                iconSource: "image://theme/icon-m-right"
            }

            ListElement {
                page: "MyObservationsPage.qml"
                title: qsTr("My Observations")
                iconSource: "image://theme/icon-m-right"
            }

            ListElement {
                page: "NewsPage.qml"
                title: qsTr("News")
                iconSource: "image://theme/icon-m-right"
            }

            ListElement {
                page: "UserPage.qml"
                title: qsTr("User Info")
                iconSource: "image://theme/icon-m-right"
            }
        }

        SilicaListView {
            id: listView
            anchors.fill: parent
            model: pagesModel
            header: PageHeader { title: "Laji.fi" }
            spacing: Theme.paddingLarge

            delegate: BackgroundItem {
                width: listView.width

                Label {
                    id: list_label
                    text: model.title
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: list_image.left
                    x: Theme.horizontalPageMargin
                }

                Image {
                    id: list_image
                    source: model.iconSource
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl(page))
            }
            VerticalScrollDecorator {}
        }
    }
}

