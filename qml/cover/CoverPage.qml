import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: cover_label
        //anchors.centerIn: parent
        anchors {
            top: cover_image.bottom
            horizontalCenter: parent.horizontalCenter
        }

        text: qsTr("Taskulaji")
    }

    Image {
        id: cover_image

        anchors {
            //bottom : parent.bottom
            left: parent.left
            right: parent.right
            top: parent.top
        }
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        fillMode: Image.PreserveAspectFit

        source: "../images/korppi.svg"
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: openObservationPage()
        }

    }

    function openObservationPage() {
        var item = pageStack.find(function(item, index) { return item.objectName === "NewObservationPage" })

        if (item) {
            appWindow.activate()
        }
        else {
            appWindow.activate()
            pageStack.clear()
            pageStack.push(Qt.resolvedUrl("../pages/FirstPage.qml"), {}, PageStackAction.Immediate)
            pageStack.push(Qt.resolvedUrl("../pages/NewObservationPage.qml"), {}, PageStackAction.Immediate)
        }
    }
}

