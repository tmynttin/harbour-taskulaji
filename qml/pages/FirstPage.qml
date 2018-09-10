import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as Db
import "../js/logic.js" as Logic


Page {
    id: mainPage
    property var logged_in

    Component.onCompleted: {
        Db.dbInit();
        Logic.page_stack = pageStack
    }

    onStatusChanged: {
        logged_in = (Logic.person_token !== "")
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

        Column {
            id: menu
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Taskulaji")
            }

            BackgroundItem {
                width: parent.width
                id: new_observation
                visible: logged_in

                Label {
                    text: qsTr("New Observation")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: new_observation_image.left
                    x: Theme.horizontalPageMargin
                }

                Image {
                    id: new_observation_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("ObservationPage.qml"))
            }

            BackgroundItem {
                width: parent.width
                id: my_observations
                visible: logged_in

                Label {
                    text: qsTr("My Observations")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: my_observations_image.left
                    x: Theme.horizontalPageMargin
                }

                Image {
                    id: my_observations_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("MyObservationsPage.qml"))
            }

            BackgroundItem {
                width: parent.width
                id: news

                Label {
                    text: qsTr("News")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: news_image.left
                    x: Theme.horizontalPageMargin
                }

                Image {
                    id: news_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("NewsPage.qml"))
            }

            BackgroundItem {
                width: parent.width
                id: user_page

                Label {
                    text: qsTr("User Info")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: user_page_image.left
                    x: Theme.horizontalPageMargin
                }

                Image {
                    id: user_page_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"))
            }
        }
    }
}

