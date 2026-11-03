import qs.config
import qs.services
import QtQuick

StatItem {
    visible: Weather.ready
    icon: Weather.icon
    iconWidest: [Theme.iconWeatherClear, Theme.iconWeatherClearNight, Theme.iconWeatherPartlyCloudy,
                 Theme.iconWeatherPartlyCloudyNight, Theme.iconWeatherCloudy, Theme.iconWeatherFog,
                 Theme.iconWeatherRain, Theme.iconWeatherPouring, Theme.iconWeatherSleet,
                 Theme.iconWeatherSnow, Theme.iconWeatherThunder]
    value: Math.round(Weather.temperature) + "°"
    widest: "-99°"
    valueAlignment: Text.AlignLeft
}
