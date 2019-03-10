import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.3
import "../js/logic.js" as Logic


Item {
    id: distribution_map_page

    property string taxo_id
    property bool run_timer: false
    property int max_count
    property int current_page: 1
    property int last_page: 1
    property real zoom_level: 5.5

    Component.onCompleted: {
        var ratio_comp = Math.sqrt(1920^2 + 1080^2)
        var ratio = Math.sqrt(Screen.height^2 + Screen.width^2)
        kartta.zoomLevel = zoom_level * Math.sqrt(ratio_comp / ratio)
        get_distribution(current_page)
    }

    onTaxo_idChanged: {
        current_page = 1
        get_distribution(current_page)
    }

    Rectangle {
        width: parent.width
        height: parent.height

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map {
        id: kartta
        width: parent.width
        height: parent.height
        plugin: mapPlugin
        center {
            latitude: 65.5
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
    }
    function get_distribution(page)
    {
        Logic.api_qet(draw_distribution, "warehouse/query/aggregate",
                      {"aggregateBy": "gathering.conversions.wgs84Grid05.lat,gathering.conversions.wgs84Grid05.lon",
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
            map_model.clear()

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






