import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Page {
    id: taxo_info_page

    property string taxo_id: ""
    property string page_title: ""
    property string description: ""
    property var taxo_information
    property var taxo_description
    property bool run_timer: false

    Component.onCompleted: {
        search_push_timer.start()
    }

    onTaxo_idChanged: {
        get_taxo_information()
    }

    onTaxo_informationChanged: {
        page_title = taxo_information.scientificName
        description_timer.start()
    }

    onTaxo_descriptionChanged: {
        description = taxo_description[0]? taxo_description[0].groups[0].variables[0].content : ""
    }

    //Timer to allow first http get to complete
    Timer {
        id: description_timer
        interval: 10
        running: false
        repeat: false
        onTriggered: get_taxo_description()
    }

    Timer {
        id: search_push_timer
        interval: 500
        running: true
        repeat: false
        onTriggered: search_menu_item.openTaxoDialog()
    }

    BusyIndicator {
         size: BusyIndicatorSize.Large
         anchors.centerIn: parent
         running: run_timer
    }

    SilicaFlickable {
        id: taxo_info_container

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                id: search_menu_item
                text: qsTr("Search")
                onClicked: openTaxoDialog()

                function openTaxoDialog() {
                    var dialog = pageStack.push("../components/TaxoPage.qml", {})
                    dialog.accepted.connect(function() {
                        taxo_id = dialog.selected_taxo.id
                    })
                }
            }
        }

        Column {
            SilicaListView {
                id: taxo_content
                anchors.fill: parent
                //contentHeight: parent.height
                contentWidth: parent.width



                header: PageHeader {
                    id: page_header
                    title: taxo_info_page.taxo_infomation ? taxo_info_page.taxo_information.vernacularName : ""
                    description: taxo_information ? taxo_information.scientificName : ""
                }



                model: ListModel {
                    id: description_list_model
                }

                section {
                    property: 'section'

                    delegate: SectionHeader {
                        text: section
                        height: Theme.itemSizeExtraSmall
                    }
                }

                VerticalScrollDecorator {}



                delegate: Item {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2*Theme.horizontalPageMargin
                    height: childrenRect.height

                    Label {
                        id: taxo_description_title
                        text: title
                        font.pixelSize: Theme.fontSizeMedium
                        wrapMode: Text.WordWrap
                        width: parent.width
                        anchors.topMargin: Theme.paddingMedium
                        color: Theme.highlightColor
                    }


                    Label {
                        id: taxo_description
                        text: content
                        font.pixelSize: Theme.fontSizeExtraSmall
                        wrapMode: Text.WordWrap
                        width: parent.width
                        anchors.top: taxo_description_title.bottom
                    }
                }
        }
    }



//        Image {
//            id: taxo_image
//            antialiasing: true
//            //anchors.top: taxo_content.bottom
//            source: "https://image.laji.fi/MM.248968/JR56644_thumb.jpg"
//            cache: false
//            fillMode: Image.PreserveAspectFit
//        }
    }



    function get_taxo_information() {
        Logic.api_qet(set_taxo_information, "taxa/" + taxo_id, {"lang":"fi"})
        run_timer = true
    }

    function set_taxo_information(status, response){
        if (status === 200) {
            taxo_information = response
            console.log("Got response: " + response.scientificName)
            run_timer = false
        }
        else {
            pageStack.push(Qt.resolvedUrl("../components/ErrorPage.qml"), {message: response})
        }
    }

    function get_taxo_description() {
        Logic.api_qet(set_taxo_description, "taxa/" + taxo_id + "/descriptions", {"lang":"fi", "langFallback":"true"})
        run_timer = true
    }

    function set_taxo_description(status, response){
        if (status === 200) {
            taxo_content.model.clear()
            taxo_description = response

            if (response.length > 0) {
                var groups = response[0].groups

                for (var i in groups) {
                    var group = groups[i]
                    var group_title = group.title
                    for (var j in group.variables) {
                        var variable = group.variables[j]
                        var variable_title = variable.title
                        var variable_content = variable.content

                        taxo_content.model.append({ 'title': variable_title,
                                         'content': variable_content,
                                         'section': group_title
                                     })
                    }
                }
            }

            run_timer = false
        }
        else {
            pageStack.push(Qt.resolvedUrl("../components/ErrorPage.qml"), {message: response})
        }
    }
}
