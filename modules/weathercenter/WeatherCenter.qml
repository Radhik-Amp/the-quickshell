import qs.config
import qs.components
import qs.services
import QtQuick
import QtQuick.Layouts

DropdownPanel {
    id: root

    readonly property var compass: ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    readonly property string windDir: compass[Math.round(Weather.windDirection / 45) % 8]

    name: "weather"
    anchorX: Panels.positions.weather ?? NaN
    implicitWidth: 460
    spacing: Theme.padding

    StyledText {
        Layout.fillWidth: true
        visible: !Weather.ready
        horizontalAlignment: Text.AlignHCenter
        text: Weather.error || "Loading…"
        color: Theme.textMuted
    }

    RowLayout {
        Layout.fillWidth: true
        visible: Weather.ready
        spacing: Theme.padding

        GlyphText {
            text: Weather.icon
            font.pixelSize: 48
        }

        StyledText {
            text: Math.round(Weather.temperature) + "°"
            font.pixelSize: 40
            font.bold: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: Weather.description
                elide: Text.ElideRight
            }
            StyledText {
                Layout.fillWidth: true
                text: "Feels like " + Math.round(Weather.apparentTemperature) + "°"
                color: Theme.textMuted
                font.pixelSize: 14
            }
            StyledText {
                Layout.fillWidth: true
                text: "Updated " + Qt.formatDateTime(Weather.lastUpdated, "h:mm AP")
                color: Theme.textMuted
                font.pixelSize: 14
            }
        }

        IconButton {
            Layout.alignment: Qt.AlignTop
            implicitWidth: 32
            implicitHeight: 32
            enabled: !Weather.loading
            text: Theme.iconRefresh
            font.pixelSize: 18
            onClicked: Weather.refresh()
        }
    }

    GridLayout {
        Layout.fillWidth: true
        visible: Weather.ready
        columns: 3
        uniformCellWidths: true
        rowSpacing: Theme.spaceSm
        columnSpacing: Theme.spaceSm

        DetailCard {
            Layout.fillWidth: true
            icon: Theme.iconHumidity
            label: "Humidity"
            value: Weather.humidity + "%"
        }
        DetailCard {
            Layout.fillWidth: true
            icon: Theme.iconWind
            label: "Wind"
            value: Math.round(Weather.windSpeed) + " " + Weather.windSpeedUnitLabel + " " + root.windDir
        }
        DetailCard {
            Layout.fillWidth: true
            icon: Theme.iconWind
            label: "Gusts"
            value: Math.round(Weather.windGusts) + " " + Weather.windSpeedUnitLabel
        }
        DetailCard {
            Layout.fillWidth: true
            icon: Theme.iconGauge
            label: "Pressure"
            value: Math.round(Weather.pressure) + " " + (Weather.units.pressure_msl ?? "")
        }
        DetailCard {
            Layout.fillWidth: true
            icon: Theme.iconCloud
            label: "Clouds"
            value: Weather.cloudCover + "%"
        }
        DetailCard {
            Layout.fillWidth: true
            icon: Theme.iconUmbrella
            label: "Precip"
            value: Weather.precipitation + " " + (Weather.units.precipitation ?? "")
        }
    }

    Rectangle {
        Layout.fillWidth: true
        visible: Weather.ready
        implicitHeight: 1
        color: Qt.rgba(1, 1, 1, 0.5)
    }

    WeatherHourly {
        Layout.fillWidth: true
        visible: Weather.ready
    }

    Rectangle {
        Layout.fillWidth: true
        visible: Weather.ready
        implicitHeight: 1
        color: Qt.rgba(1, 1, 1, 0.5)
    }

    WeatherDaily {
        Layout.fillWidth: true
        visible: Weather.ready
    }
}
