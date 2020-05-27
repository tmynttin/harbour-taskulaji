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
    property bool run_timer: false

    onTaxo_idChanged: {
        load_page()
    }

    onTaxo_informationChanged: {
        chart.taxo_id = taxo_id
        chart.class_id = taxo_information.parent["class"].id
        chart.getData()
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

        Column {
            id: taxo_column
            width: taxo_info_page.width
            height: childrenRect.height
            spacing: Theme.paddingMedium

            VerticalScrollDecorator {}

            PageHeader {
                id: page_header
                title: taxo_information.scientificName ? taxo_information.scientificName : ""
                description: taxo_information.vernacularName ? taxo_information.vernacularName : ""
            }

            SectionHeader {
                text: qsTr("Static occurrence map")
            }

            StaticMapWidget {
                id: static_map
                taxo_id: taxo_info_page.taxo_id
                zoom_level: 4.2
                width: parent.width
                height: width * 2
            }

            SectionHeader {
                text: qsTr("Monthly occurrence map")
            }

            DynamicMapWidget {
                id: dynamic_map
                taxo_id: taxo_info_page.taxo_id
                zoom_level: 4.2
                width: parent.width
                height: width * 2 + Theme.paddingMedium + Theme.itemSizeExtraLarge
            }

            SectionHeader {
                text: qsTr("Occurrence trend, 1960-2020")
            }

            LineChart {
                width: parent.width
                id: chart
            }

            Label {
                    width: parent.width
                    text: ""
                }
        }
    }

    function load_page() {
        get_taxo_information()
        get_taxo_description()
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
}
