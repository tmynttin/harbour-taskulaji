import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic


Page {
    id: my_obs_page

    property bool run_timer: false

    BusyIndicator {
         size: BusyIndicatorSize.Large
         anchors.centerIn: parent
         running: run_timer
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    obs_column.get_obs()
                }
            }
        }

        SilicaListView {
            id: obs_column
            spacing: Theme.paddingMedium
            anchors.fill: parent

            header: PageHeader {
                id: page_header
                title: qsTr("My Observations")
            }

            model: ListModel {
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
                    id: obs_location
                    text: location
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                    anchors.topMargin: Theme.paddingMedium
                    color: Theme.highlightColor
                }

                Label {
                    function timestamp() {
                        var txt = Format.formatDate(time, Formatter.Timepoint)
                        var elapsed = Format.formatDate(time, Formatter.DurationElapsed)
                        return txt + (elapsed ? ' (' + elapsed + ')' : '')
                    }
                    id: obs_time
                    text: timestamp()
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.italic: true
                    color: Theme.secondaryHighlightColor
                    anchors {
                        top: obs_location.bottom
                        topMargin: Theme.paddingSmall
                    }
                }

                Label {
                    id: obs_taxon
                    text: taxon
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                    anchors.top: obs_time.bottom
                }
            }

            Component.onCompleted: {
                get_obs()

            }

            function get_obs() {
                Logic.api_qet(print_obs, "documents")
                run_timer = true
            }

            function print_obs(response) {
                var response_obs = response.results

                for (var i in response_obs) {
                    var single_obs = response_obs[i]
                    var o_date = single_obs.gatheringEvent.dateBegin
                    var time = parse_date_time(o_date)
                    var taxons = ""
                    var units = single_obs.gatherings[0].units
                    for (var j in units) {
                        taxons += units[j].identifications[0].taxon + ", " + units[j].count + "\n"
                    }

                    model.append({ 'location': single_obs.gatherings[0].municipality,
                                     'taxon': taxons,
                                     'time': time,
                                     'section': Format.formatDate(time, Formatter.TimepointSectionRelative)})
                }
                run_timer = false
            }

            function parse_date_time(p_date) {
                var parsed_value = Date.fromLocaleString(Qt.locale(), p_date, "yyyy-MM-dd'T'hh:mm")
                if (parsed_value.toString() === "Invalid Date") {
                    parsed_value = Date.fromLocaleString(Qt.locale(), p_date, "yyyy-MM-dd")
                }
                return parsed_value
            }
        }
    }
}
