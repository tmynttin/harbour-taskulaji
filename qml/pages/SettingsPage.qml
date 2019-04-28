import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db


Page {
    id: settings_page
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
        contentHeight: settings_column.height

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Reset settings")
                onClicked: {
                    Remorse.popupAction(settings_page, qsTr("Restoring default settings"), function () {Db.setDefaultSettings(); pageStack.pop()})
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
            id: settings_column
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("User Settings")
                visible: user_data.person_token
            }

            TextField {
                visible: user_data.person_token
                width: parent.width
                readOnly: true
                label: qsTr("User name")
                text: user_data.name ? user_data.name : ""
            }

            TextField {
                visible: user_data.person_token
                width: parent.width
                readOnly: true
                label: qsTr("User ID")
                text: user_data.person_id ? user_data.person_id : ""
            }

            TextArea {
                visible: user_data.person_token
                width: parent.width
                readOnly: false
                label: qsTr("Person Token")
                text: user_data.person_token ? user_data.person_token : ""
                selectionMode: TextInput.SelectWords
            }

            SectionHeader {
                text: qsTr("New Observation Settings")
            }

            TextSwitch {
                id: hide_user
                text: qsTr("Hide observer")
                description: qsTr("When making a new observation, the observer name is hidden by default")
                checked: get_hide_observer()
                onCheckedChanged: set_hide_observer()

                function set_hide_observer() {
                    var hide_observer = checked ? 1 : 0
                    Db.saveSetting("hide_observer", hide_observer)
                }

                function get_hide_observer() {
                    return Db.getSetting("hide_observer")
                }
            }

            TextSwitch {
                id: coarse_location
                text: qsTr("Coarse loaction")
                description: qsTr("When making a new observation, the location is coarsed to 10x10 km square by default")
                checked: get_coarse()
                onCheckedChanged: set_coarse()

                function set_coarse() {
                    var coarse = checked ? 1 : 0
                    Db.saveSetting("coarse_location", coarse)
                }

                function get_coarse() {
                    return Db.getSetting("coarse_location")
                }
            }

            SectionHeader {
                text: qsTr("Borwse Observations Settings")
            }

            TextField {
                id: max_observations
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Maximum number of observations shown")
                text: get_max_observations()
                onTextChanged: {
                    set_max_observations()
                }

                function set_max_observations() {
                    Db.saveSetting("max_observations", text)
                }

                function get_max_observations() {
                    return Db.getSetting("max_observations")
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.lightSecondaryColor
                text: qsTr("This is the maxumum number of observations shown when browsing observations. Default is 200. If larger amount is used, yuor device may become unresponsive.")
            }
        }
    }
}
