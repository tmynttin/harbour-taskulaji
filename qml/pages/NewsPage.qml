import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic


Page {
    id: newsPage
    property bool run_timer: false

//    Timer {
//        interval: 500
//        running: run_timer
//        repeat: true
//        onTriggered: news_column.print_news()
//    }

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
                    news_column.get_news()
//                    Logic.api_qet("news")
//                    run_timer = true
                }
            }
        }

        SilicaListView {
            id: news_column
            spacing: Theme.paddingMedium
            anchors.fill: parent

            header: PageHeader {
                id: page_header
                title: "News"
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
                    id: news_title
                    text: title
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

                    id: news_time
                    text: timestamp()
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.italic: true
                    color: Theme.secondaryHighlightColor
                    anchors {
                        top: news_title.bottom
                        topMargin: Theme.paddingSmall
                    }
                }

                Label {
                    id: news_content
                    text: content
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                    anchors.top: news_time.bottom
                }
            }

            Component.onCompleted: {
                get_news()

            }

            function get_news() {
                Logic.api_qet(print_news, "news");
                run_timer = true;
            }

            function print_news(response) {
                var response_news = response.results;

                for (var i in response_news) {
                    var single_news = response_news[i];
                    var time = new Date(parseInt(single_news.posted));
                    model.append({ 'title': String(single_news.title),
                                   'content': String(single_news.content),
                                   'time': time,
                                   'section': Format.formatDate(time, Formatter.TimepointSectionRelative)});
                }
                run_timer = false;
            }

//            function print_news() {
//                if (Logic.response_ready) {
//                    var response = Logic.response;
//                    var response_news = response.results;

//                    for (var i in response_news) {
//                        var single_news = response_news[i];
//                        var time = new Date(parseInt(single_news.posted));
//                        model.append({ 'title': String(single_news.title),
//                                         'content': String(single_news.content),
//                                         'time': time,
//                                         'section': Format.formatDate(time, Formatter.TimepointSectionRelative)});
//                    }
//                    run_timer = false;
//                }
//            }
        }
    }
}
