import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db
import "../js/areas.js" as Areas


Page {
    id: settings_page
    property bool logged_in
    property var user_data
    property string person_token: ""
    property string tmp_token: ""
    property string login_url: ""

    Component.onCompleted: {
        user_data = Db.dbGetUser()
        person_token = Logic.get_person_token()
        logged_in = (person_token !== "")
        checkPersonToken()
    }

    onPerson_tokenChanged: {
        console.log("Person token changed: " + person_token + ", " + Logic.get_person_token())
        logged_in = (person_token !== "")
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
        person_token = ""
    }

    function saveUserData(status, response) {
        if (status === 200) {
            var pId = response.id
            var pName = response.fullName
            console.log("Name: " + pName + ", ID: " + pId)
            Db.dbCreateUser(person_token, pId, pName)
            user_data = Db.dbGetUser()
            person_token = user_data.person_token
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
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
            person_token = response.token
            Logic.api_qet(saveUserData, "person/" + person_token)
            pageStack.pop()
            login_timer.stop()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: settings_column.height

        BusyIndicator {
            id: login_timer_indicator
            anchors.fill: parent
            running: login_timer.running
        }

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Restore default settings")
                onClicked: {
                    Remorse.popupAction(settings_page, qsTr("Restoring default settings"), function () {Db.setDefaultSettings(); pageStack.pop()})
                }
            }

            MenuItem {
                text: qsTr("Logout")
                onClicked: {
                    clearUserData()
                }
                visible: logged_in
            }

            MenuItem {
                text: qsTr("Login")
                onClicked: {
                    get_temp_token()
                }
                visible: !logged_in
            }
        }

        Column {
            id: settings_column
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                id: user_header
                text: qsTr("User Settings")
                visible: logged_in
            }

            TextField {
                id: user_name
                visible: logged_in
                width: parent.width
                readOnly: true
                label: qsTr("User name")
                text: user_data.name ? user_data.name : ""
            }

            TextField {
                id: user_id
                visible: logged_in
                width: parent.width
                readOnly: true
                label: qsTr("User ID")
                text: user_data.person_id ? user_data.person_id : ""
            }

            TextArea {
                id: user_token
                visible: logged_in
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
                text: qsTr("Browse Observations Settings")
            }

            ValueButton {
                id: species_button

                function openTaxoDialog() {
                    var dialog = pageStack.push("TaxoSearchPage.qml", {})
                    dialog.accepted.connect(function() {
                        Db.saveSetting("taxo_name", "\"" + dialog.selected_taxo.name + "\"")
                        Db.saveSetting("taxo_id", "\"" + dialog.selected_taxo.id + "\"")
                        value = dialog.selected_taxo.name
                        species_button.forceActiveFocus()
                    })
                }

                label: qsTr("Species: ")
                value: Db.getSetting("taxo_name") ? Db.getSetting("taxo_name") : qsTr("None")
                width: parent.width - Theme.paddingLarge
                onClicked: openTaxoDialog()
            }

            ComboBox {

                Component.onCompleted: {
                    var area = Db.getSetting("area")
                    for (var i in area_list.model) {
                        if (area_list.model[i].name === area) {
                            currentIndex = i
                        }
                    }
                }

                id: area_combobox
                width: parent.width
                label: qsTr("Area")
                menu: ContextMenu {
                    Repeater {
                        id: area_list
                        model: Areas.areas
                        MenuItem {
                            id: area_item
                            text: modelData.name
                            onClicked: {
                                var area = "\"" + modelData.name + "\""
                                Db.saveSetting("area", area)
                            }
                        }
                    }
                }
            }

            TextSwitch {
                 id: own_observations_switch
                 text: qsTr("Only own observations")
                 checked: get_own_observations()
                 onCheckedChanged: set_own_observations()

                 function set_own_observations() {
                     var own_observations_setting = checked ? 1 : 0
                     Db.saveSetting("own_observations", own_observations_setting)
                 }

                 function get_own_observations() {
                     return Db.getSetting("own_observations")
                 }
             }


            TextField {
                id: max_observations
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Maximum number of observations shown")
                text: get_max_observations()
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: this.focus = false
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
                text: qsTr("This is the maximum number of observations shown when browsing observations. Default is 200. WARNING: If larger number is used, yuor device may become unresponsive.")
            }
        }
    }
}
