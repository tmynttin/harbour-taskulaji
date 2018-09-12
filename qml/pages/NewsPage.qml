import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/logic.js" as Logic


Page {
    id: newsPage
    property bool run_timer: false

    BusyIndicator {
         size: BusyIndicatorSize.Large
         anchors.centerIn: parent
         running: run_timer
    }

    SilicaListView {
        id: news_column
        spacing: Theme.paddingMedium
        anchors.fill: parent

        pullDownMenu: PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    news_column.get_news()
                }
            }
        }

        header: PageHeader {
            id: page_header
            title: qsTr("News")
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

            BackgroundItem {

                onClicked: {
                    if(externalURL) {
                        pageStack.push("../components/WebPage.qml", {go_to_url: externalURL})
                    }
                }

                Column {

                    Label {
                        id: news_title
                        text: title
                        font.pixelSize: Theme.fontSizeMedium
                        //wrapMode: Text.WordWrap
                        elide: "ElideRight"
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
                    }
                }
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
                var single_news = response_news[i]
                var time = new Date(parseInt(single_news.posted))
                var url = single_news.externalURL
                model.append({ 'title': String(single_news.title),
                               'time': time,
                               'section': Format.formatDate(time, Formatter.TimepointSectionRelative),
                               'externalURL': url})
            }
            run_timer = false
        }
    }
}
