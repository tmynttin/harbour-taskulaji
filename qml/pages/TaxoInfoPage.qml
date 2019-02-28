import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Page {
    id: taxo_info_page

    property string taxo_id: ""
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
        page_header.title = taxo_information.vernacularName.toCa
        page_header.description = taxo_information.scientificName
        description_timer.start()
    }

    onTaxo_descriptionChanged: {
        image_timer.start()
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
        id: image_timer
        interval: 10
        running: false
        repeat: false
        onTriggered: get_images()
    }

    Timer {
        id: search_push_timer
        interval: 1000
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
        anchors.fill: parent
        contentHeight: taxo_column.height

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
            id: taxo_column
            width: taxo_info_page.width
            height: childrenRect.height
            spacing: Theme.paddingLarge

            VerticalScrollDecorator {}

            PageHeader {
                id: page_header
                title: ""
                description: ""
            }

            SilicaGridView {
                id: image_grid
                width: parent.width
                height: childrenRect.height
                cellWidth: width/5
                cellHeight: width/5

                model: ListModel {
                    id: image_grid_model
                }

                delegate: BackgroundItem {

                    Image {
                        id: taxo_image
                        fillMode: Image.TileVertically
                        antialiasing: true
                        source: thumbImage
                        cache: false
                    }

                    onClicked: {
                        openImagePage()
                    }

                    function openImagePage() {
                        pageStack.push("ImagePage.qml", {fullImage: fullImage})
                    }
                }
            }

            SilicaListView {
                id: taxo_content
                width: parent.width
                height: childrenRect.height

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
    }

    function get_taxo_information() {
        Logic.api_qet(set_taxo_information, "taxa/" + taxo_id, {"lang":"fi"})
        run_timer = true
    }

    function set_taxo_information(status, response){
        if (status === 200) {
            taxo_information = response
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

    function get_images() {
        Logic.api_qet(set_images, "taxa/" + taxo_id + "/media", {})
        run_timer = true
    }

    function set_images(status, response) {
        if (status === 200) {
            image_grid.model.clear()

            if (response.length > 0) {

                for (var i in response) {
                    var media_data = response[i]
                    var thumb = media_data.thumbnailURL
                    var full = media_data.fullURL

                    image_grid.model.append({ 'thumbImage': thumb,
                                                'fullImage': full,
                                            })
                }
            }

            run_timer = false
        }
        else {
            pageStack.push(Qt.resolvedUrl("../components/ErrorPage.qml"), {message: response})
        }
    }
}
