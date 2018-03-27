import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Dialog {
    id: taxo_page
    property string searchString
    property bool keepSearchFieldFocus
    property string activeView: "list"
    property var selected_taxo

    onSearchStringChanged: result_list.get_taxons()

    Column {
        id: headerContainer
        width: taxo_page.width

        PageHeader {
            title: "Taxo Search"
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
                accept()
            }
        }

        VerticalScrollDecorator {}

        Component.onCompleted: {searchField.forceActiveFocus()}

        function get_taxons() {
            model.clear();
            if (searchString.length > 2) {
                Logic.api_qet(update_list, "autocomplete/taxon", {'q':searchString, 'matchType':'partial,exact'});
            }
        }

        function update_list(response) {
            for (var i in response) {
                model.append({ 'id': String(response[i].key),
                                 'name': String(response[i].value)});
            }
        }
    }
}
