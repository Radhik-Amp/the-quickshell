import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property var player: Mpris.players.values[0]
    spacing: Theme.padding

    BarText {
        text: Theme.iconPlay
    }
    BarText {
        text: Theme.iconPrevious
    }
    Item {
        id: ticker
        clip: true
        implicitWidth: 200
        implicitHeight: tickerText.implicitHeight
        readonly property bool overflowing: tickerText.implicitWidth > width
        property string text: player ? `${root.player.trackArtist} — ${root.player.trackTitle}` : "Nothing playing"
        property int speed: 40
        property int gap: 30
        property real rowOffset: 0
        RowLayout {
            id: row
            spacing: 30
            anchors.verticalCenter: parent.verticalCenter
            x: ticker.overflowing ? ticker.scrollOffset : (ticker.width - tickerText.implicitWidth) / 2

            BarText {
                id: tickerText
                text: ticker.text
            }
            BarText {
                text: ticker.text
                visible: ticker.overflowing
            }
        }
        NumberAnimation {
            id: animation
            running: ticker.overflowing && root.player?.isPlaying
            target: row
            property: "rowOffset"
            from: 0
            to: -(tickerText.width + ticker.gap)
            duration: (tickerText.implicitWidth + ticker.gap) / ticker.speed * 1000
            loops: Animation.Infinite
            onRunningChanged: if (!running) ticker.rowOffset = 0

        }
        onTextChanged: {rowOffset = 0; if (animation.running) animation.restart() }

    }
    BarText {
        text: Theme.iconNext
    }


}
