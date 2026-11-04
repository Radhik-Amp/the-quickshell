import qs.config
import qs.services
import QtQuick

StatItem {
    id: root

    visible: Weather.ready
    icon: Weather.icon
    iconWidest: [Theme.iconWeatherClear, Theme.iconWeatherClearNight, Theme.iconWeatherPartlyCloudy,
                 Theme.iconWeatherPartlyCloudyNight, Theme.iconWeatherCloudy, Theme.iconWeatherFog,
                 Theme.iconWeatherRain, Theme.iconWeatherPouring, Theme.iconWeatherSleet,
                 Theme.iconWeatherSnow, Theme.iconWeatherThunder]
    value: Math.round(Weather.temperature) + "°"
    widest: "-99°"
    valueAlignment: Text.AlignLeft

    readonly property real centerX: {
        x; width; parent.x; parent.width;
        return mapToItem(null, width / 2, 0).x + Theme.padding
    }
    onCenterXChanged: Panels.setPosition("weather", centerX)
    Component.onCompleted: Panels.setPosition("weather", centerX)

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: Panels.toggle("weather")
    }
}
