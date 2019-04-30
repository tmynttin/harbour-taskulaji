import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic
import "../js/database.js" as Db

Dialog {
    id: confirmation_page
    property var observation
    property bool operation_completed: false

    canAccept: operation_completed
    acceptDestination: pageStack.find(function(item, index) { return item.objectName === "MainPage" })
    acceptDestinationAction: PageStackAction.Pop

    onOpened: {
        send_data()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: confirmation_column.height
        contentWidth: parent.width

        Column {
            id: confirmation_column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Observation Confirmation")
            }

            Label {
                id: confirmation_status
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor
                text: qsTr("Sending...")
                wrapMode: Text.Wrap
            }

            Button {
                id: abort_button
                visible: !operation_completed
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Save document")

                onClicked: {
                    Db.saveDocument(observation)
                    confirmation_status.text = qsTr("Document saved to pending documents")
                    operation_completed = true
                }
            }
        }
    }

    function send_data() {
        Logic.api_post(confirmation, "documents", observation)
    }

    function confirmation(status, response) {
        if (status === 200) {
            operation_completed = true
            confirmation_status.text = qsTr("Send successful")
            Remorse.popupAction(confirmation_page, qsTr("Returning to main menu"), function() { accept()})
        }
        else {
            Db.saveDocument(observation)
            confirmation_status.text = qsTr("Sending failed. Status code: ") + str(status) + qsTr(". Document saved to pending documents")
            operation_completed = true
        }
    }
}
