import qs.config
import qs.services
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: Theme.iconToValueSpacing

    readonly property string volumeIcon: Audio.muted ? Theme.iconVolumeMuted 
                                       : Audio.volume > 66 ? Theme.iconVolumeHigh
                                       : Audio.volume > 33 ? Theme.iconVolumeMedium
                                       : Audio.volume > 0 ? Theme.iconVolumeLow
                                       : Theme.iconVolumeZero
    IconButton {
        id: icon
        text: root.volumeIcon
        onClicked: Audio.toggleMute()
    }

    BarText {
        id: volume
        text: Audio.volume + "%"
        opacity: Audio.muted ? 0.75 : 1
    }

    WheelHandler {
        property real acc: 0
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => { Audio.changeVolume(event.angleDelta.y / 24) }
    }
}
