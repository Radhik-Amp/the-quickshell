import qs
import qs.services
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
        spacing: Theme.vitalsSpacing
        RowLayout {
            spacing: Theme.iconToValueSpacing
            BarText { text: root.volumeIcon }
            TapHandler { onTapped: Audio.toggleMute() }
        }        

        RowLayout {
            spacing: Theme.iconToValueSpacing
            BarText { text: Audio.volume + "%"; opacity: Audio.muted ? 0.75 : 1}
        }
    }

}
