import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as Db
import "../js/logic.js" as Logic


Page {
    id: mainPage
    objectName: "MainPage"
    property var logged_in
    property bool is_pending_documents

    Component.onCompleted: {
        Db.dbInit();
        Logic.page_stack = pageStack
    }

    onStatusChanged: {
        logged_in = (Logic.person_token !== "")
        is_pending_documents = (Db.getDocuments().rows.length !== 0)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width

        PullDownMenu {
            id: pull_down
            visible: logged_in
            spacing: Theme.paddingLarge

            MenuItem {
                text: qsTr("New Observation")
                onClicked: pageStack.push("NewObservationPage.qml")
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
                    anchors.rightMargin: Theme.paddingLarge
                }

                Image {
                    id: new_observation_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push("NewObservationPage.qml")
            }

            BackgroundItem {
                width: parent.width
                id: my_observations

                Label {
                    text: qsTr("Observations")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: my_observations_image.left
                    anchors.rightMargin: Theme.paddingLarge
                }

                Image {
                    id: my_observations_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push("ObservationMapPage.qml")
            }

            BackgroundItem {
                width: parent.width
                id: taxo_info_page

                Label {
                    text: qsTr("Encyclopedia")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: taxo_image.left
                    anchors.rightMargin: Theme.paddingLarge
                }

                Image {
                    id: taxo_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push("TaxoSearchPage.qml", {info_search : true})
            }

            BackgroundItem {
                width: parent.width
                id: news

                Label {
                    text: qsTr("News")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: news_image.left
                    anchors.rightMargin: Theme.paddingLarge
                }

                Image {
                    id: news_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push("NewsPage.qml")
            }

            BackgroundItem {
                width: parent.width
                id: user_page

                Label {
                    text: qsTr("Profile")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: user_page_image.left
                    anchors.rightMargin: Theme.paddingLarge
                }

                Image {
                    id: user_page_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push("UserPage.qml")
            }

            BackgroundItem {
                width: parent.width
                id: resend_page
                visible: is_pending_documents

                Image {
                    id: warning_image
                    source: "image://theme/icon-m-cloud-upload?" + Theme.rgba('yellow', 1)
                    anchors.right: resend_text.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Theme.paddingLarge
                }

                Label {
                    id: resend_text
                    text: qsTr("Pending Documents")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: resend_page_image.left
                    anchors.rightMargin: Theme.paddingLarge
                }

                Image {
                    id: resend_page_image
                    source: "image://theme/icon-m-right"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: pageStack.push("ResendPage.qml")
            }

        }
    }
}

