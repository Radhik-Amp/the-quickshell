import QtQuick
import QtQuick.Layouts
MouseArea {
    id:root
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth
    
    readonly property string volumeIcon: Audio.muted ? Theme.iconVolumeMuted 
                                       : Audio.volume > 66 ? Theme.iconVolumeHigh
                                       : Audio.volume > 33 ? Theme.iconVolumeMedium
                                       : Audio.volume > 0 ? Theme.iconVolumeLow
                                       : Theme.iconVolumeZero

    onWheel: wheel => Audio.changeVolume(wheel.angleDelta.y > 0 ? 5 : -5)

    RowLayout {
        id: row
        spacing: -1
        RowLayout {
            spacing: 4
            BarText { text: root.volumeIcon }
            BarText { text: Theme.bracketLeft }
            TapHandler { onTapped: Audio.toggleMute() }
        }        

        RowLayout {
            spacing: 0
            Repeater {
                model : 20
                BarText {
                    required property int index
                    readonly property bool countFilled: index < Math.round(Audio.volume / 5) 
                    readonly property color barColor: Audio.muted ? "transparent" : "white"
                    property string filled: "⣿"
                    readonly property string empty: "⣉"
                    text: countFilled ? filled : empty
                    color: barColor
                    }
                }
            }

        RowLayout {
            spacing: 2
            BarText { text: Theme.bracketRight}
            StableText { text: Audio.volume + "%"; widest: "100%" }
        }
    }

}
