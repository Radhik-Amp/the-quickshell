import qs.components
import qs.config
import qs.services
import qs.modules.controlcenter
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    readonly property bool shown: Panels.active === "media"
    readonly property var player: MediaCenterState.player
    readonly property int tether: Theme.padding
    readonly property int panelHeight: column.implicitHeight + Theme.padding * 2

    implicitWidth: 460
    implicitHeight: tether + panelHeight
    visible: shown || clipper.height > 0
    anchors.top: true
    anchors.left: true
    margins.top: Theme.padding + Theme.barHeight
    margins.left: Math.round(MediaCenterState.anchorX - implicitWidth / 2)
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    mask: Region { item: clipper }

    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Timer {
        interval: 1000
        repeat: true
        running: root.shown && (root.player?.isPlaying ?? false)
        onTriggered: root.player?.positionChanged()
    }

    Item {
        id: clipper
        clip: true
        width: root.implicitWidth
        height: root.shown ? root.implicitHeight : 0
        focus: true
        Keys.onEscapePressed: Panels.close()

        Behavior on height {
            NumberAnimation {
                duration: 650
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
            }
        }

        Rectangle {
            x: Math.round(parent.width / 2)
            width: Theme.borderWidth
            height: root.tether
            color: Theme.borderColor
        }

        Rectangle {
            y: root.tether
            implicitWidth: root.implicitWidth
            implicitHeight: root.panelHeight
            color: Theme.background
            radius: Theme.radius

            ColumnLayout {
                id: column
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.padding
                }
                spacing: Theme.padding

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
                                // None → Playlist → Track → None
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
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.tether
            color: "transparent"
            border.color: Theme.borderColor
            border.width: Theme.borderWidth
            radius: Theme.radius
        }
    }
}
