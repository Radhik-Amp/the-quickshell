pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 0

    readonly property int popThreshold: 10
    readonly property bool anyPrecip: Weather.hourly.some(h => h.pop >= popThreshold)

    Repeater {
        model: Weather.hourly

        ColumnLayout {
            id: hour

            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.preferredWidth: 1
            spacing: Theme.spaceXs

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: hour.index === 0 ? "Now" : Qt.formatDateTime(hour.modelData.time, "hAP")
                color: Theme.textMuted
                font.pixelSize: Theme.fontSize - 3
            }
            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: hour.modelData.icon
                font.pixelSize: Theme.fontSize + 6
            }
            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Math.round(hour.modelData.temp) + "°"
            }
            StyledText {
                readonly property bool wet: hour.modelData.pop >= root.popThreshold

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: wet ? hour.modelData.pop + "%" : "–"
                color: Theme.textMuted
                font.pixelSize: Theme.fontSize - 3
                visible: root.anyPrecip
                opacity: wet ? 1 : 0.4
            }
        }
    }
}
