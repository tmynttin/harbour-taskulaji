import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Dialog {
    id: login_page
    property string person_token: ""

    onAccepted: {
        person_token = token_field.text
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
        }
    }
}
