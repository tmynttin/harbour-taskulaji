import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property string go_to_url
    allowedOrientations: Orientation.All

     SilicaWebView {
         id: webView

         anchors {
             top: parent.top
             left: parent.left
             right: parent.right
             bottom: urlField.top
         }
         url: go_to_url         
     }

     TextField {
         id: urlField
         anchors {
             left: parent.left
             right: parent.right
             bottom: parent.bottom
         }
         inputMethodHints: Qt.ImhUrlCharactersOnly
         text: go_to_url
         label: webView.title
         EnterKey.onClicked: {
             webView.url = text
             parent.focus = true
         }
     }
 }
