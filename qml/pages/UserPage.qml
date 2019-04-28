import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db


Page {
    id: user_page
    property var user_data
    property string person_token: ""

    Component.onCompleted: {
        user_data = Db.dbGetUser()
        person_token = user_data.person_token ? user_data.person_token : ""
        checkPersonToken()
    }

    function checkPersonToken() {
        user_data = Db.dbGetUser()
        person_token = user_data.person_token
        if (person_token != "") {
            Logic.api_qet(handlePersonResponse, "person/" + person_token)
        }
    }

    function handlePersonResponse(status, response) {
        console.log(JSON.stringify(response))
        if (status === 400) {
            console.log("Invalid token detected")
            clearUserData()
            pageStack.push("ErrorPage.qml", {message: "Invalid token. Ensure your person token is valid."})
        }
    }

    function clearUserData() {
        Db.dbDeleteUser();
        user_data = {"person_token": "", "person_id": "", "name": ""};
        Logic.get_person_token();
        person_token = ""
    }

    function saveUserData(status, response) {
        if (status === 200) {
            var pId = response.id
            var pName = response.fullName
            console.log("Name: " + pName + ", ID: " + pId)
            Db.dbCreateUser(person_token, pId, pName)
            Logic.get_person_token()
            user_data = Db.dbGetUser()
            person_token = user_data.person_token
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    user_data = Db.dbGetUser();
                }
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: {

                    pageStack.push("SettingsPage.qml", {})
                }
            }

            MenuItem {
                text: qsTr("Logout")
                onClicked: {
                    clearUserData()
                }
                visible: (person_token !== "")
            }

            MenuItem {
                text: qsTr("Login")
                onClicked: {
                    openLoginDialog();
                }
                visible: (person_token === "")

                function openLoginDialog() {
                    var dialog = pageStack.push("LoginPage.qml", {})
                    dialog.accepted.connect(function() {
                        person_token = dialog.person_token
                        Logic.api_qet(saveUserData, "person/" + person_token);
                    })
                }
            }
        }

        Column {
            id: user_column
            width: parent.width

            TextField {
                width: parent.width
                readOnly: true
                label: qsTr("User name")
                text: user_data.name ? user_data.name : ""
            }

            TextField {
                width: parent.width
                readOnly: true
                label: qsTr("User ID")
                text: user_data.person_id ? user_data.person_id : ""
            }

            TextArea {
                width: parent.width
                readOnly: false
                label: qsTr("Person Token")
                text: user_data.person_token ? user_data.person_token : ""
                selectionMode: TextInput.SelectWords
            }
        }
    }
}
