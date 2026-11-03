import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

RowLayout {
    id: root
    readonly property var player: MediaCenterState.player

    spacing: Theme.spaceSm

    readonly property real centerX: {
        x; width; parent.x; parent.width;
        return mapToItem(null, width / 2, 0).x + Theme.padding 
    }
    onCenterXChanged: MediaCenterState.anchorX = centerX
    Component.onCompleted: MediaCenterState.anchorX = centerX



    RowLayout {
        spacing: 0

        IconButton {
            text: Theme.iconPrevious
            onClicked: root.player?.previous()
        }

        IconButton {
            text: root.player?.isPlaying ? Theme.iconPause : Theme.iconPlay
            onClicked: root.player?.togglePlaying()
        }

        IconButton {
            text: Theme.iconNext
            onClicked: root.player?.next()
        }
    }

    Item {
        id: ticker
        clip: true
        implicitWidth: 200
        implicitHeight: tickerText.implicitHeight
        readonly property bool overflowing: tickerText.implicitWidth > width
        property string text: root.player ? `${root.player.trackArtist} — ${root.player.trackTitle}` : "Nothing playing"
        property int speed: 40
        property int gap: 30
        property int fade: Theme.spaceMd
        property real rowOffset: 0

        layer.enabled: overflowing
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: tickerMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: MediaCenterState.shown = !MediaCenterState.shown
        }

        HoverHandler { cursorShape: Qt.PointingHandCursor }

        Rectangle {
            id: tickerMask
            anchors.fill: parent
            visible: false
            layer.enabled: true
            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop { position: 0; color: animation.running ? "transparent" : "white" }
                GradientStop { position: ticker.fade / ticker.width; color: "white" }
                GradientStop { position: 1 - ticker.fade / ticker.width; color: "white" }
                GradientStop { position: 1; color: "transparent" }
            }
        }

        RowLayout {
            id: row
            spacing: ticker.gap
            anchors.verticalCenter: parent.verticalCenter
            x: ticker.overflowing ? ticker.rowOffset : (ticker.width - tickerText.implicitWidth) / 2

            StyledText {
                id: tickerText
                text: ticker.text
            }
            StyledText {
                text: ticker.text
                visible: ticker.overflowing
            }
        }
        NumberAnimation {
            id: animation
            running: ticker.overflowing && root.player?.isPlaying
            target: ticker
            property: "rowOffset"
            from: 0
            to: -(tickerText.implicitWidth + ticker.gap)
            duration: (tickerText.implicitWidth + ticker.gap) / ticker.speed * 1000
            loops: Animation.Infinite
            onRunningChanged: if (!running) ticker.rowOffset = 0

        }
        onTextChanged: { rowOffset = 0; if (animation.running) animation.restart() }

    }
}
