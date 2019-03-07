import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.3
import "../js/logic.js" as Logic


Page {
    id: distribution_map_page

    property string taxo_id
    property bool run_timer: false
    property int max_count
    property int current_page: 1
    property int last_page: 1

    Component.onCompleted: {
        kartta.zoomLevel = 6.0
    }

    Timer {
        id: distribution_timer
        running: true
        repeat: false
        interval: 10
        onTriggered: get_distribution(current_page)
    }

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        Map {
            id: kartta
            width: parent.width
            height: distribution_map_page.height * 0.75
            plugin: mapPlugin
            center {
                latitude: 65
                longitude: 26
            }

            MapItemView {

                model: ListModel {
                    id: map_model
                }

                delegate: MapRectangle {
                    id: distribution_delegate
                    color: 'green'
                    opacity: get_opacity()
                    visible: kuu == month_slider.sliderValue
                    border.width: 1
                    topLeft {
                        latitude: latti+0.5
                        longitude: lontti
                    }
                    bottomRight {
                        latitude: latti
                        longitude: lontti+0.5
                    }

                    function get_opacity() {
                        var op = 0
                        if (countti > 0) {op = 0.4}
                        if (countti > 10) {op = 0.6}
                        if (countti > 100) {op = 0.8}
                        return op
                    }
                }
            }
        }

        Slider {
            id: month_slider
            width: parent.width
            minimumValue: 1
            maximumValue: 12
            value: 1
            stepSize: 1
            valueText: value
            label: qsTr("Month")

            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.centerIn: month_slider
                running: run_timer
            }
        }
    }

    function get_distribution(page)
    {
        Logic.api_qet(draw_distribution, "warehouse/query/aggregate",
                      {"aggregateBy": "gathering.conversions.wgs84Grid05.lat,gathering.conversions.wgs84Grid05.lon,gathering.conversions.month",
                       "taxonId":taxo_id,
                       "pageSize":"1000",
                       "page":current_page,
                       "time":"-7300/0",
                       "area":"finland"})
        run_timer = true
    }

    function draw_distribution(status, response) {
        if (status === 200) {
            console.log(JSON.stringify(response.total))

            max_count = 0
            last_page = response.lastPage

            for (var i in response.results) {
                var result = response.results[i]
                var lat = parseFloat(result.aggregateBy['gathering.conversions.wgs84Grid05.lat'])
                var lon = parseFloat(result.aggregateBy['gathering.conversions.wgs84Grid05.lon'])
                var count = result.count
                var mon = result.aggregateBy['gathering.conversions.month']
                max_count = Math.max(max_count, count)

                map_model.append({ 'latti': lat,
                                     'lontti': lon,
                                     'countti': count,
                                     'kuu': mon
                                 })
            }
            current_page++

            if (current_page <= last_page) {
                distribution_timer.start()
            }
            else {
                run_timer = false
            }
        }
        else {
            pageStack.push("ErrorPage.qml", {message: response})
        }
    }
}
