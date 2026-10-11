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
        spacing: 0
        RowLayout {
            spacing: 4
            BarText { text: root.volumeIcon }
            BarText { text: Theme.bracketLeft; color: Audio.muted ? "#4e4e4e" : "white" }
            TapHandler { onTapped: Audio.toggleMute() }
        }        

        RowLayout {
            spacing: 0
            Repeater {
                id: volumeBar
                model : 20
                BarText {
                    required property int index
                    readonly property bool countFilled: index < Math.round(Audio.volume / 5) 
                    property string filled: "⣿"
                    readonly property string empty: "⣉"
                    text: countFilled ? filled : empty
                    color: Audio.muted ? "#4e4e4e" : "white"
                    }
                }
            }

        RowLayout {
            spacing: 2
            BarText { text: Theme.bracketRight; color: Audio.muted ? "#4e4e4e" : "white"}
            StableText { text: Audio.volume + "%"; widest: "100%" }
        }
    }

}
