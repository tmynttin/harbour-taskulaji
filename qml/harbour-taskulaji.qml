import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "js/database.js" as Db


ApplicationWindow
{
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations


}
