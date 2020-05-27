import QtQuick 2.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtMultimedia 5.6
import "../components"
import "../js/logic.js" as Logic

Page {
    id: taxo_info_page

    property string taxo_id: ""
    property string description: ""
    property var taxo_information
    property var taxo_description
    property var parents_data
    property var children_data
    property bool run_timer: false

    onTaxo_idChanged: {
        load_page()
    }

    onTaxo_informationChanged: {
        audio.scientific_name = taxo_information.scientificName
        audio.synonym_name = taxo_information.synonymNames ? taxo_information.synonymNames : ""
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

            MenuItem {
                text: qsTr("Occurrence")
                onClicked: pageStack.push("OccurrencePage.qml", {
                                              taxo_id: taxo_id
                                          })
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
                title: taxo_information.scientificName ? taxo_information.scientificName : ""
                description: taxo_information.vernacularName ? taxo_information.vernacularName : ""
            }

            Item {
                width: parent.width
                height: width

                StaticMapWidget {
                    id: map_widget
                    taxo_id: taxo_info_page.taxo_id
                    width: parent.width / 2
                    height: parent.height
                    anchors.top: parent.top
                }

                SilicaGridView {
                    id: image_grid
                    anchors.left: map_widget.right
                    anchors.top: parent.top
                    width: parent.width / 2
                    height: parent.height
                    cellWidth: width/3
                    cellHeight: width/3
                    clip: true

                    model: ListModel {
                        id: image_grid_model

                    }

                    delegate: BackgroundItem {

                        id: image_delegate

                        Image {
                            id: taxo_image
                            fillMode: Image.PreserveAspectCrop
                            antialiasing: true
                            source: thumbURL
                            cache: false
                            width: image_grid.cellWidth
                            height: image_grid.cellHeight
                        }

                        MouseArea {
                            anchors.fill: taxo_image

                        onClicked: {
                            openImagePage()
                        }
                        }

                        function openImagePage() {
                            pageStack.push("ImagePage.qml", {image_model: model})
                        }
                   }

                }
            }

            AudioPlayer {
                id: audio
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
                        textFormat: Text.RichText
                        font.pixelSize: Theme.fontSizeExtraSmall
                        wrapMode: Text.WordWrap
                        width: parent.width
                        anchors.top: taxo_description_title.bottom
                    }
                }
            }

            SectionHeader {
                text: qsTr("Parents")
            }

            SilicaListView {
                id: parent_list
                width: parent.width
                height: childrenRect.height

                model: ListModel {
                    id: parent_list_model
                }

                delegate: BackgroundItem{

                    TaxoListDelegate {}

                    onClicked: {
                        taxo_id = parent_taxo_id
                    }
                }
            }

            SectionHeader {
                text: qsTr("Children")
            }

            SilicaListView {
                id: children_list
                width: parent.width
                height: childrenRect.height

                model: ListModel {
                    id: children_list_model
                }

                delegate: BackgroundItem{

                    TaxoListDelegate{}

                    onClicked: {
                        taxo_id = child_taxo_id
                    }
                }
            }
        }
    }

    function load_page() {
        get_taxo_information()
        get_taxo_description()
        get_parents()
        get_children()
        get_images()
        get_warehouse_images()
        map_widget.taxo_id = taxo_id
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
            pageStack.push("ErrorPage.qml", {message: response})
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
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

    function get_parents() {
        Logic.api_qet(set_parents, "taxa/" + taxo_id + "/parents", {"lang":"fi"})
        run_timer = true
    }

    function set_parents(status, response) {
        if (status === 200) {
            parent_list.model.clear()
            parents_data = response

            if (response.length > 0) {

                for (var i in response) {
                    var parent_data = response[i]
                    var parent_vernacularName = parent_data.vernacularName
                    var parent_scientificName = parent_data.scientificName
                    var parent_taxo_id = parent_data.id

                    parent_list.model.append({ 'vernacularName': parent_vernacularName,
                                                 'scientificName': parent_scientificName,
                                                 'parent_taxo_id': parent_taxo_id
                                             })
                }
            }

            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

    function get_children() {
        Logic.api_qet(set_children, "taxa/" + taxo_id + "/children", {"lang":"fi"})
        run_timer = true
    }

    function set_children(status, response) {
        if (status === 200) {
            children_list.model.clear()
            children_data = response

            if (response.length > 0) {

                for (var i in response) {
                    var child = response[i]
                    var child_vernacularName = child.vernacularName
                    var child_scientificName = child.scientificName
                    var child_taxo_id = child.id

                    children_list.model.append({ 'vernacularName': child_vernacularName,
                                                   'scientificName': child_scientificName,
                                                   'child_taxo_id': child_taxo_id
                                               })
                }
            }

            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

    function get_images() {
        Logic.api_qet(set_images, "taxa/" + taxo_id + "/media", {"lang":"fi"})
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
                    var author = media_data.author
                    var vernacularName = media_data.taxon.vernacularName
                    var scientificName = media_data.taxon.scientificName

                    image_grid.model.append({ 'thumbURL': thumb,
                                                'fullURL': full,
                                                'author': author,
                                                'vernacularName': vernacularName,
                                                'scientificName': scientificName
                                            })
                }
            }

            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }

    function get_warehouse_images() {
        Logic.api_qet(set_warehouse_images, "warehouse/query/unitMedia/list", {"taxonId":taxo_id, "reliable":true})
        run_timer = true
    }

    function set_warehouse_images(status, response) {
        if (status === 200) {

            if (response.results.length > 0) {

                console.log(JSON.stringify(response.results))

                for (var i in response.results) {
                    var media_data = response.results[i]
                    var thumb = media_data.media.thumbnailURL
                    var full = media_data.media.fullURL
                    var author = media_data.media.author
                    var vernacularName = ""
                    var scientificName = ""
                    if (media_data.unit.linkings) {
                        vernacularName = media_data.unit.linkings.taxon.vernacularName.fi
                        scientificName = media_data.unit.linkings.taxon.scientificName
                    }

                    image_grid.model.append({ 'thumbURL': thumb,
                                                'fullURL': full,
                                                'author': author,
                                                'vernacularName': vernacularName,
                                                'scientificName': scientificName
                                            })
                }
            }

            run_timer = false
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }
}
