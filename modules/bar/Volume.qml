import qs.config
import qs.services
import QtQuick

BarStat {
    icon: Audio.muted ? Theme.iconVolumeMuted
        : Audio.volume > 66 ? Theme.iconVolumeHigh
        : Audio.volume > 33 ? Theme.iconVolumeMedium
        : Audio.volume > 0 ? Theme.iconVolumeLow
        : Theme.iconVolumeZero
    iconWidest: [Theme.iconVolumeMuted, Theme.iconVolumeHigh, Theme.iconVolumeMedium,
                 Theme.iconVolumeLow, Theme.iconVolumeZero]
    value: Audio.volume + "%"
    widest: "100%"
    dimmed: Audio.muted

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: Audio.toggleMute() }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => { Audio.changeVolume(event.angleDelta.y / 24) }
    }
}
