import qs.components
import qs.config
import qs.services
import qs.modules.controlcenter
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

TetheredPanel {
    id: root

    readonly property var player: MediaCenterState.player

    name: "media"
    anchorX: Panels.positions.media ?? NaN
    panelWidth: 460
    spacing: Theme.padding

    Timer {
        interval: 1000
        repeat: true
        running: root.shown && (root.player?.isPlaying ?? false)
        onTriggered: root.player?.positionChanged()
    }

    MediaPlayerSwitcher {
        Layout.fillWidth: true
        visible: MediaCenterState.players.length > 1
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.padding

        MediaArt {
            source: root.player?.trackArtUrl ?? ""
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.spaceXs

            StyledText {
                Layout.fillWidth: true
                text: root.player?.trackTitle || "Nothing playing"
                font.pixelSize: 20
                font.bold: true
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: [root.player?.trackArtist, root.player?.trackAlbum].filter(s => s).join(" — ")
                color: Theme.textMuted
                font.pixelSize: 14
                elide: Text.ElideRight
                visible: text.length > 0
            }

            RowLayout {
                Layout.topMargin: Theme.spaceXs
                spacing: Theme.spaceXs

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    visible: root.player?.shuffleSupported ?? false
                    text: root.player?.shuffle ? Theme.iconShuffle : Theme.iconShuffleOff
                    textColor: root.player?.shuffle ? Theme.text : Theme.textMuted
                    font.pixelSize: 18
                    onClicked: root.player.shuffle = !root.player.shuffle
                }

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    enabled: root.player?.canGoPrevious ?? false
                    text: Theme.iconPrevious
                    font.pixelSize: 22
                    onClicked: root.player.previous()
                }

                IconButton {
                    implicitWidth: 40
                    implicitHeight: 40
                    enabled: root.player?.canTogglePlaying ?? false
                    text: root.player?.isPlaying ? Theme.iconPause : Theme.iconPlay
                    font.pixelSize: 30
                    onClicked: root.player.togglePlaying()
                }

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    enabled: root.player?.canGoNext ?? false
                    text: Theme.iconNext
                    font.pixelSize: 22
                    onClicked: root.player.next()
                }

                IconButton {
                    readonly property int loop: root.player?.loopState ?? MprisLoopState.None

                    implicitWidth: 32
                    implicitHeight: 32
                    visible: root.player?.loopSupported ?? false
                    text: loop === MprisLoopState.Track ? Theme.iconRepeatOnce
                        : loop === MprisLoopState.Playlist ? Theme.iconRepeat
                        : Theme.iconRepeatOff
                    textColor: loop === MprisLoopState.None ? Theme.textMuted : Theme.text
                    font.pixelSize: 18
                    onClicked: root.player.loopState = loop === MprisLoopState.None ? MprisLoopState.Playlist
                                                     : loop === MprisLoopState.Playlist ? MprisLoopState.Track
                                                     : MprisLoopState.None
                }
            }
        }
    }

    MediaSeek {
        Layout.fillWidth: true
        player: root.player
    }

    MediaVisualizer {
        Layout.fillWidth: true
    }

    ControlSlider {
        Layout.fillWidth: true
        visible: root.player?.volumeSupported ?? false
        label: "volume"
        value: (root.player?.volume ?? 0) * 100
        onMoved: v => root.player.volume = v / 100
    }
}
