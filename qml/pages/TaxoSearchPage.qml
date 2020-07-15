import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Dialog {
    id: taxo_page
    backNavigation: sent_counter === received_counter
    canNavigateForward: sent_counter === received_counter
    canAccept: sent_counter === received_counter
    property string searchString
    property bool keepSearchFieldFocus
    property string activeView: "list"
    property var selected_taxo
    property bool info_search: false
    property int sent_counter: 0
    property int received_counter: 0

    onSearchStringChanged: result_list.get_taxons()

    BusyIndicator {
        id: response_wait_indicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: sent_counter > received_counter
    }

    Column {
        id: headerContainer
        width: taxo_page.width

        PageHeader {
            title: qsTr("Taxo Search")
        }

        SearchField {
            id: searchField
            width: parent.width

            Binding {
                target: taxo_page
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }

    SilicaListView {
        id: result_list
        anchors.fill: parent
        currentIndex: -1 // otherwise currentItem will steal focus
        header:  Item {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }

        model: ListModel {

        }

        delegate: BackgroundItem {
            id: backgroundItem

            ListView.onAdd: AddAnimation {
                target: backgroundItem
            }

            ListView.onRemove: RemoveAnimation {
                target: backgroundItem
            }

            Label {
                x: searchField.textLeftMargin
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.StyledText
                text: model.name
            }

            onClicked: {
                selected_taxo = {"name": model.name, "id": model.id}
                if(info_search) {
                    pageStack.push("../pages/TaxoInfoPage.qml", {taxo_id : selected_taxo.id})
                }
                else{
                    accept()
                }
            }

            onPressAndHold: {
                selected_taxo = {"name": model.name, "id": model.id}
                pageStack.push("../pages/TaxoInfoPage.qml", {taxo_id : selected_taxo.id})

            }
        }

        VerticalScrollDecorator {}

        Component.onCompleted: {searchField.forceActiveFocus()}

        function get_taxons() {
            if (searchString.length > 2) {
                sent_counter++
                Logic.api_qet(update_list, "autocomplete/taxon", {'q':searchString, 'matchType':'partial,exact'});
            }
        }

        function update_list(status, response) {
            received_counter++
            if (status === 200) {
                if (String(response[0].value).toLowerCase().search(searchString) > -1)
                {
                    model.clear()
                    for (var i in response) {
                        model.append({ 'id': String(response[i].key),
                                         'name': String(response[i].value)});
                    }
                }

            }
            else {
                pageStack.push("ErrorPage.qml", {message: response})
            }
        }
    }
}
