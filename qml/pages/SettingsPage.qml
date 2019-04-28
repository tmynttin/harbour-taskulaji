import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db


Page {
    id: settings_page

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

//    function saveSetting(setting, value) {
//        Db.
//    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {

            MenuItem {
                text: qsTr("Reset settings")
                onClicked: {

                    Db.setDefaultSettings()
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
                //text: qsTr("Maximum number of observations shown")
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
