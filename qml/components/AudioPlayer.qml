import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import "../js/logic.js" as Logic

Column {
    id: player
    property string scientific_name
    property string audio_source
    property string gen
    property string sp
    property string type
    property string rec
    property string cnt
    property string loc
    property int audio_index: 0
    property int number_of_recordings: 0
    property var recordings

    width: parent.width
    visible: number_of_recordings > 0

    onScientific_nameChanged: {
        get_audio()
    }

    MediaPlayer {
        id: audio
        source: audio_source
    }

    ProgressBar {
        id: audio_bar
        width: parent.width
        minimumValue: 0
        maximumValue: audio.duration
        value: audio.position
        valueText: get_time()

        function get_time() {
            var milliseconds = audio.position
            var minutes = Math.floor(milliseconds/60000)
            var seconds = Math.round((milliseconds/1000)%60)
            var delimiter = seconds < 10 ? ":0" : ":"
            var time = minutes + delimiter + seconds
            return time
        }
    }

    Label {
        x: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.highlightColor
        width: parent.width
        wrapMode: Text.WordWrap
        text: gen + (sp ? " " + sp : "") + ": " + type
    }

    Label {
        x: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.highlightColor
        width: parent.width
        wrapMode: Text.WordWrap
        text: rec
    }

    Label {
        x: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.highlightColor
        width: parent.width
        wrapMode: Text.WordWrap
        text: cnt + ", " + loc
    }

    Item {
        x: Theme.horizontalPageMargin
        height: Theme.itemSizeLarge
        width: parent.width - 2*x

        IconButton {
            id: unit_remover_1
            anchors.left: parent.left
            icon.source: "image://theme/icon-m-previous"
            visible: audio_index > 0
            onClicked: {
                audio_index--
                set_audio_url(audio_index)

            }
        }

        IconButton {
            id: play_stop_button
            anchors.horizontalCenter: parent.horizontalCenter
            icon.source: audio.playbackState == MediaPlayer.PlayingState ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
            onClicked: {
                console.log("playing: " + audio.source)
                if (audio.playbackState == MediaPlayer.PlayingState) {
                    audio.stop()
                }
                else {
                    audio.play()
                }
            }
        }

        IconButton {
            id: unit_remover
            anchors.right: parent.right
            icon.source: "image://theme/icon-m-next"
            visible: audio_index < (number_of_recordings - 1)
            onClicked: {
                audio_index++
                set_audio_url(audio_index)

            }
        }
    }

    function get_audio() {
        Logic.get_xeno_canto_audio(set_audio, scientific_name)
        run_timer = true
    }

    function set_audio(status, response) {
        recordings = response.recordings
        number_of_recordings = response.numRecordings
        if (number_of_recordings > 0) {
            set_audio_url(audio_index)
        }
    }

    function set_audio_url(index) {
        var sono_path = recordings[index].sono.small
        var file_name = recordings[index]["file-name"]
        gen = recordings[index].gen
        sp = recordings[index].sp
        type = recordings[index].type
        rec = recordings[index].rec
        cnt = recordings[index].cnt
        loc = recordings[index].loc
        var url_base_end_location = sono_path.indexOf("/", 40)
        var url_base = sono_path.substring(0, url_base_end_location)
        audio_source = "https:" + url_base + "/" + file_name
        console.log("Audio file location: " + audio_source)
    }
}
