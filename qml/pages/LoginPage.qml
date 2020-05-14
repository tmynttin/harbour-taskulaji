import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Dialog {
    id: login_page
    property string person_token: ""
    property string tmp_token: ""
    property string login_url: ""

    onAccepted: {
        person_token = token_field.text
    }

    Timer {
        id: login_timer
        repeat: true
        running: false
        interval: 5000
        onTriggered: {
            login_check()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: login_column.height
        contentWidth: parent.width

        Column {
            id: login_column
            width: parent.width

            DialogHeader {
                title: qsTr("Login")
            }

            TextField {
                id: token_field
                text: ""
                label: qsTr("Person Token")
                placeholderText: label
                width: parent.width
            }

            Button {
                text: "App login"
                onClicked: {
                    get_temp_token()
                }
            }
        }
    }

    function get_temp_token() {

        Logic.api_qet(go_to_auth_page, "login", {});
    }

    function go_to_auth_page(status, response) {
        if (status === 200) {
            tmp_token = response.tmpToken
            login_url = response.loginURL
            login_timer.start()

            pageStack.push("WebPage.qml", {go_to_url: login_url})
        }
    }

    function login_check() {
        Logic.api_post(set_person_token, "login/check", {}, {tmpToken: tmp_token})
    }

    function set_person_token(status, response) {
        if (status === 200) {
            token_field.text = response.token
            pageStack.pop()
            login_timer.stop()
        }
    }
}
