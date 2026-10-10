import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    readonly property string volumeIcon: Audio.muted ? Theme.iconVolumeMuted 
                                       : Audio.volume > 66 ? Theme.iconVolumeHigh
                                       : Audio.volume > 33 ? Theme.iconVolumeMedium
                                       : Audio.volume > 0 ? Theme.iconVolumeLow
                                       : Theme.iconVolumeZero

    RowLayout {
        spacing: 1
        RowLayout {
            spacing: 2
            BarText { text: root.volumeIcon }
            BarText { text: Theme.bracketLeft }
            TapHandler { onTapped: Audio.toggleMute() }
        }        

        RowLayout {
            spacing: -5
            Repeater {
                model : 20
                BarText {
                    required property int index
                    readonly property bool countFilled: index < Math.round(Audio.volume / 5) 
                    readonly property string filled: "\u25C6"
                    readonly property string empty: "\u25C7"
                    text: countFilled ? filled : empty
                }

            }
        }
        RowLayout {
            spacing: 2
            BarText { text: Theme.bracketRight}
            StableText { text: Audio.volume + "%"; widest: "100%" }
        }
    }

    WheelHandler { onWheel: event => Audio.changeVolume(event.angleDelta.y > 0 ? 5 : -5) }
}
