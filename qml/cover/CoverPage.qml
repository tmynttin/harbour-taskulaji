import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: cover_label
        anchors.centerIn: parent
        text: qsTr("Taskulaji")
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: openObservationPage()
        }

    }

    function openObservationPage() {
        var item = pageStack.find(function(item, index) { return item.objectName === "ObservationPage" })

        if (item) {
            appWindow.activate()
        }
        else {
            appWindow.activate()
            pageStack.clear()
            pageStack.push(Qt.resolvedUrl("../pages/FirstPage.qml"), {}, PageStackAction.Immediate)
            pageStack.push(Qt.resolvedUrl("../pages/ObservationPage.qml"), {}, PageStackAction.Immediate)
        }
    }
}

