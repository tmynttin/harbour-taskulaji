import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as Db
import "../js/logic.js" as Logic


Page {
    id: mainPage

    property bool run_login_timer: false
    property string person_token: ""

    Timer {
        id: login_timer
        interval: 500
        running: run_login_timer
        repeat: true
        onTriggered: {
            saveUserData();
        }
    }

    Component.onCompleted: {
        Db.dbInit();
        Logic.page_stack = pageStack
    }

    function saveUserData() {
        if (Logic.response_ready) {
            var response = Logic.response;
            var pId = response.id;
            var pName = response.fullName;
            console.log("Name: " + pName + ", ID: " + pId);
            Db.dbCreateUser(person_token, pId, pName);
            Logic.get_person_token();
            run_login_timer = false
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width

        PullDownMenu {
            id: pull_down
            visible: true
            spacing: Theme.paddingLarge

            MenuItem {
                text: "Login"
                onClicked: {
                    openLoginDialog();
                }

                function openLoginDialog() {
                    var dialog = pageStack.push("../components/LoginPage.qml", {})
                    dialog.accepted.connect(function() {
                        person_token = dialog.person_token
                        Logic.api_qet("person/" + person_token);
                        run_login_timer = true;
                    })
                }
            }
        }

        ListModel {
            id: pagesModel

            ListElement {
                page: "ObservationPage.qml"
                title: "Observation"
                iconSource: "image://theme/icon-m-right"
            }

            ListElement {
                page: "MyObservationsPage.qml"
                title: "My Observations"
                iconSource: "image://theme/icon-m-right"
            }

            ListElement {
                page: "NewsPage.qml"
                title: "News"
                iconSource: "image://theme/icon-m-right"
            }

            ListElement {
                page: "UserPage.qml"
                title: "User Info"
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

