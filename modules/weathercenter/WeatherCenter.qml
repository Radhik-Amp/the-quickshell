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
        text: Weather.error || "loading…"
        color: Theme.textMuted
    }

    RowLayout {
        Layout.fillWidth: true
        visible: Weather.ready
        spacing: Theme.padding

        StyledText {
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
                text: Weather.description.toLowerCase()
                elide: Text.ElideRight
            }
            StyledText {
                Layout.fillWidth: true
                text: "feels like " + Math.round(Weather.apparentTemperature) + "°"
                color: Theme.textMuted
                font.pixelSize: 14
            }
            StyledText {
                Layout.fillWidth: true
                text: "updated " + Qt.formatDateTime(Weather.lastUpdated, "h:mm AP").toLowerCase()
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

        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconHumidity
            label: "humidity"
            value: Weather.humidity + "%"
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconWind
            label: "wind"
            value: Math.round(Weather.windSpeed) + " " + Weather.windSpeedUnitLabel + " " + root.windDir
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconWind
            label: "gusts"
            value: Math.round(Weather.windGusts) + " " + Weather.windSpeedUnitLabel
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconGauge
            label: "pressure"
            value: Math.round(Weather.pressure) + " " + (Weather.units.pressure_msl ?? "")
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconCloud
            label: "clouds"
            value: Weather.cloudCover + "%"
        }
        WeatherDetail {
            Layout.fillWidth: true
            icon: Theme.iconUmbrella
            label: "precip"
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
