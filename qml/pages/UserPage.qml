import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db


Page {
    id: newsPage
    property var user_data

    Component.onCompleted: {user_data = Db.dbGetUser();}

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
                text: qsTr("Logout")
                onClicked: {
                    Db.dbDeleteUser();
                    user_data = {"person_token": "", "person_id": "", "name": ""};
                    Logic.get_person_token();
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
                text: user_data.name
            }

            TextField {
                width: parent.width
                readOnly: true
                label: qsTr("User ID")
                text: user_data.person_id
            }

            TextArea {
                width: parent.width
                readOnly: false
                label: qsTr("Person Token")
                text: user_data.person_token
                selectionMode: TextInput.SelectWords
            }
        }
    }
}