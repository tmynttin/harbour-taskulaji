import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic


Page {
    id: my_obs_page
    property bool run_timer: false


    Timer {
        interval: 500
        running: run_timer
        repeat: true
        onTriggered: obs_column.print_obs()
    }

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
                text: "Refresh"
                onClicked: {
                    Logic.api_qet("documents")
                    run_timer = true
                }
            }
        }

        SilicaListView {
            id: obs_column
            spacing: Theme.paddingMedium
            anchors.fill: parent

            header: PageHeader {
                id: page_header
                title: "My Observations"
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
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                    anchors.top: obs_time.bottom
                }
            }

            Component.onCompleted: {
                get_obs()

            }

            function get_obs() {
                Logic.api_qet("documents");
                run_timer = true;
            }

            function print_obs() {
                if (Logic.response_ready) {
                    var response = Logic.response;
                    var response_obs = response.results;

                    for (var i in response_obs) {
                        var single_obs = response_obs[i];
                        var o_time = single_obs.gatheringEvent.timeStart;
                        var o_date = single_obs.gatheringEvent.dateBegin;
                        var time_string = o_date + " " + o_time;
                        var time = Date.fromLocaleString(Qt.locale(), time_string, "yyyy-MM-dd hh:mm:ss");
                        model.append({ 'location': single_obs.gatherings[0].municipality,
                                       'taxon': String(single_obs.gatherings[0].units[0].identifications[0].taxon),
                                       'time': time,
                                       'section': Format.formatDate(time, Formatter.TimepointSectionRelative)});
                    }
                    run_timer = false;
                }
            }
        }
    }
}
