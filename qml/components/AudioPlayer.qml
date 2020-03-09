import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import "../js/logic.js" as Logic

Column {
    id: player
    property string scientific_name
    property string synonym_name
    property string audio_source
    property string gen
    property string sp
    property string type
    property string rec
    property string cnt
    property string loc
    property int audio_index: 0
    property int number_of_recordings: 0
    property var recordings: []
    property int queries_completed: 0

    width: parent.width
    visible: false

    onScientific_nameChanged: {
        audio_index = 0
        number_of_recordings = 0
        recordings = []
        queries_completed = 0
        get_audio(scientific_name)
    }

    onQueries_completedChanged: {
        if (queries_completed == 1) {
            if (synonym_name !== "") {
                get_audio(synonym_name)
            }
            else {
                finalize_player()
            }
        }
        else if (queries_completed == 2) {
            finalize_player()
        }
    }

    Timer {
        id: play_timer
        interval: 500
        onTriggered: audio.play()
    }

    MediaPlayer {
        id: audio
        source: audio_source

        onStatusChanged: {
            if (status == MediaPlayer.EndOfMedia && audio_index < (number_of_recordings - 1)) {
                audio_index++
                set_audio_url(audio_index)
                play_timer.start()
            }
        }
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
        text: gen + (sp ? " " + sp : "") + ": " + type
    }

    Label {
        x: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.highlightColor
        width: parent.width
        text: rec
    }

    Label {
        x: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.highlightColor
        width: parent.width
        text: cnt + ", " + loc
    }

    Row {

        IconButton {
            id: previous_button
            icon.source: "image://theme/icon-m-previous"
            enabled: audio_index > 0
            onClicked: {
                audio_index--
                set_audio_url(audio_index)
            }
        }

        IconButton {
            id: play_stop_button
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
            id: next_button
            icon.source: "image://theme/icon-m-next"
            enabled: audio_index < (number_of_recordings - 1)
            onClicked: {
                audio_index++
                set_audio_url(audio_index)
            }
        }
    }

    function get_audio(name) {
        Logic.get_xeno_canto_audio(set_audio, name)
    }

    function set_audio(status, response) {
        console.log("Adding recordings: " + response.recordings.length)
        recordings = recordings.concat(response.recordings)
        number_of_recordings = parseInt(recordings.length)
        queries_completed++
    }

    function finalize_player() {
        arrange_recordings()
        if (number_of_recordings > 0) {
            set_audio_url(audio_index)
            player.visible = true
        }
    }

    function arrange_recordings() {
        var finnish_recordings = recordings.filter(function(record) {return (record.cnt === "Finland")});
        var other_recordings = recordings.filter(function(record) {return (record.cnt !== "Finland")});
        recordings = finnish_recordings.concat(other_recordings)
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
        console.log("Audio url: " + audio_source)
    }
}
