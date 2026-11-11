pragma ComponentBehavior: Bound

import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: Theme.spaceXs

    readonly property real span: Math.max(1, Weather.weekHigh - Weather.weekLow)

    readonly property int iconWidth: {
        iconMetrics.font
        return Math.max(0, ...Weather.daily.map(d => Math.ceil(iconMetrics.boundingRect(d.icon).width)))
    }

    FontMetrics {
        id: iconMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 2
    }

    Repeater {
        model: Weather.daily

        RowLayout {
            id: day
            required property var modelData
            required property int index

            Layout.fillWidth: true
            spacing: Theme.spaceSm

            FixedWidthText {
                text: day.index === 0 ? "Today" : Qt.formatDateTime(day.modelData.date, "ddd")
                widest: "Today"
            }
            GlyphText {
                Layout.minimumWidth: root.iconWidth
                text: day.modelData.icon
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSize + 2
            }
            FixedWidthText {
                text: day.modelData.pop > 0 ? day.modelData.pop + "%" : ""
                widest: "100%"
                horizontalAlignment: Text.AlignRight
                color: Theme.textMuted
                font.pixelSize: Theme.fontSize - 3
            }
            FixedWidthText {
                text: Math.round(day.modelData.low) + "°"
                widest: "-99°"
                horizontalAlignment: Text.AlignRight
                color: Theme.textMuted
            }

            Rectangle {
                id: track
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: 6
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.15)

                Rectangle {
                    x: (day.modelData.low - Weather.weekLow) / root.span * track.width
                    width: Math.max(height, (day.modelData.high - day.modelData.low) / root.span * track.width)
                    height: parent.height
                    radius: parent.radius
                    color: Theme.text
                }
            }

            FixedWidthText {
                text: Math.round(day.modelData.high) + "°"
                widest: "-99°"
            }
        }
    }
}
