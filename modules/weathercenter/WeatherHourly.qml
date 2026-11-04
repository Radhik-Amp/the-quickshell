pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 0

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
                text: hour.index === 0 ? "now" : Qt.formatDateTime(hour.modelData.time, "hAP").toLowerCase()
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
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: hour.modelData.pop + "%"
                color: Theme.textMuted
                font.pixelSize: Theme.fontSize - 3
                opacity: hour.modelData.pop > 0 ? 1 : 0
            }
        }
    }
}
