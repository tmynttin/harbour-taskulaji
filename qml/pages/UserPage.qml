import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db


Page {
    id: newsPage
    property bool run_timer: false
    property var user_data

    Component.onCompleted: {user_data = Db.dbGetUser();}

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: "Refresh"
                onClicked: {
                    user_data = Db.dbGetUser();
                }
            }

            MenuItem {
                text: "Logout"
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
                label: "User name"
                text: user_data.name
            }

            TextField {
                width: parent.width
                readOnly: true
                label: "User ID"
                text: user_data.person_id
            }

            TextArea {
                width: parent.width
                readOnly: false
                label: "Person Token"
                text: user_data.person_token
                selectionMode: TextInput.SelectWords
            }
        }
    }
}
