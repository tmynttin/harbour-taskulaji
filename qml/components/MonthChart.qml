import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic

Item {
    width: parent.width
    height: line_chart.height

    property string taxo_id: ""

    property var taxo_points: []
    property var points: []

    property int horizontalGridDensity: 12
    property int verticalGridDensity: 5

    property real minX: 0
    property real maxX: 0
    property real minY: 0
    property real maxY: 0

    property bool isData: false

    property bool run_timer: false

    onTaxo_pointsChanged: {
        if (taxo_points.length > 0) {
            setScaling()
            line_chart.requestPaint()
        }
    }

    function getData() {
        taxo_points = []
        points = []
        getPoints(taxo_id)
    }

    function setScaling() {
        console.log("Setting scaling")
        for (var i in taxo_points) {
            var factor = 2020 - 2000
             points.push({x:taxo_points[i].x, y:taxo_points[i].y / factor})
        }

        console.log(JSON.stringify(points))

        minX = 1
        minY = points[0].y
        maxX = 12
        maxY = points[0].y

        points.forEach(function(point) {
            if (point.y > maxY) {
                maxY = point.y
            }
            if (point.y < minY) {
                minY = point.y
            }
            minY = 0
        });
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: run_timer
    }

    Column {
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 4*Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
        Rectangle {
            width: parent.width
            height: line_chart.height
            color: "transparent"

            Repeater {
                id: vertical_axis
                model: verticalGridDensity

                delegate: Label {
                    anchors {
                        top: (index == verticalGridDensity-1) ? parent.top : undefined
                        bottom: (index == verticalGridDensity-1) ? undefined : parent.bottom
                        bottomMargin: (index) ? parent.height / (verticalGridDensity-1) * index - height/2 : 0
                        right: parent.left
                        rightMargin: Theme.paddingSmall
                    }
                    text: getText()
                    font.pixelSize: Theme.fontSizeTiny

                    function getText() {
                        var y = parseInt(minY + index * (maxY - minY) / (verticalGridDensity-1))
                        return y
                    }
                }
            }

            Repeater {
                id: horizontal_axis
                model: horizontalGridDensity

                delegate: Label {
                    anchors {
                        top: parent.bottom
                        right: (index == horizontalGridDensity-1) ? parent.right : undefined
                        left: (index == horizontalGridDensity-1) ? undefined : parent.left
                        leftMargin: index ? parent.width / (horizontalGridDensity-1) * index - width/2 : 0
                    }
                    text: getText()
                    font.pixelSize: Theme.fontSizeTiny

                    function getText() {
                        var y = parseInt(index + 1)
                        return y
                    }
                }
            }

            Canvas {
                id: line_chart
                width: parent.width - vertical_axis.width -  2*Theme.paddingLarge
                height: Theme.itemSizeExtraLarge * 2
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");

                    drawGrid(ctx)
                    if (isData) {
                        drawChart(ctx)
                    }
                }

                function drawGrid(ctx) {
                    ctx.strokeStyle = Theme.secondaryColor
                    ctx.lineWidth = 1

                    ctx.beginPath()
                    for (var i = 0; i < verticalGridDensity; i++) {
                        ctx.moveTo(0, i*height/(verticalGridDensity-1))
                        ctx.lineTo(width, i*height/(verticalGridDensity-1))
                    }

                    for (var j = 0; j < horizontalGridDensity; j++) {
                        ctx.moveTo(j*width/(horizontalGridDensity-1), 0)
                        ctx.lineTo(j*width/(horizontalGridDensity-1), height)
                    }
                    ctx.stroke()

                }

                function drawChart(ctx) {
                    ctx.strokeStyle = Theme.highlightColor
                    ctx.lineWidth = 5;

                    ctx.beginPath()
                    ctx.moveTo(mapX(points[0].x), mapY(points[0].y))
                    for (var i = 1; i < points.length; i++) {
                        ctx.lineTo(mapX(points[i].x), mapY(points[i].y))
                    }
                    ctx.stroke()
                }

                function mapX(x) {
                    return (x-minX)/(maxX-minX)*width
                }

                function mapY(y) {
                    return height * (1 - (y-minY)/(maxY-minY))
                }
            }
        }
    }

    function getPoints(taxon) {
        run_timer = true
        var parameters = {
            "taxonId":taxon,
            "pageSize":"100",
            "page":"1",
            "orderBy":"gathering.conversions.month",
            "aggregateBy":"gathering.conversions.month",
            "onlyCount":"false",
            "area":"finland",
            "yearMonth":"2000/2020"}

        Logic.api_qet(setPoints, "warehouse/query/unit/aggregate", parameters)

    }

    function setPoints(status, response) {
        //console.log(JSON.stringify(response))
        var temp_points = []


        for (var i in response.results) {
            var result = response.results[i]
            var month = result.aggregateBy["gathering.conversions.month"]
            var count = result.individualCountSum

            var point = {x: month, y: count}

            temp_points.push(point)
        }
        console.log(JSON.stringify(temp_points))

        taxo_points = temp_points
        run_timer = false
        isData = true
    }
}
