pragma Singleton

import qs.config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real latitude: 42.36
    property real longitude: -71.06

    // adjustable values -- will add a controller soon
    property string temperatureUnit: "fahrenheit" // you can use either celsius or fahrenheit
    property string windSpeedUnit: "kmh" // kmh, ms, mph, kn
    property string precipitationUnit: "mm" // mm, inch

    property int refreshInterval: 15 * 60 * 1000

    readonly property bool hasLocation: !isNaN(latitude) && !isNaN(longitude)

    property bool ready: false
    property bool loading: fetchProc.running
    property string error: ""
    property date lastUpdated
    property date observedAt
    property string timezone: ""

    property real temperature: 0
    property real apparentTemperature: 0
    property int humidity: 0
    property bool isDay: true
    property real precipitation: 0
    property real rain: 0
    property real showers: 0
    property real snowfall: 0
    property int weatherCode: -1
    property int cloudCover: 0
    property real pressure: 0
    property real windSpeed: 0
    property int windDirection: 0
    property real windGusts: 0

    property var units: ({})
    readonly property string temperatureUnitLabel: units.temperature_2m ?? ""
    readonly property string windSpeedUnitLabel: units.wind_speed_10m ?? ""

    readonly property string description: describe(weatherCode)
    readonly property string icon: iconFor(weatherCode, isDay)

    readonly property var fields: [
        "temperature_2m", "apparent_temperature", "relative_humidity_2m", "is_day",
        "precipitation", "rain", "showers", "snowfall", "weather_code", "cloud_cover",
        "pressure_msl", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m"
    ]

    readonly property string requestKey: [latitude.toFixed(3), longitude.toFixed(3),
        temperatureUnit, windSpeedUnit, precipitationUnit, fields.join(",")].join("|")

    property bool cacheChecked: false
    property int retryDelay: 60 * 1000

    function refresh() {
        if (!hasLocation || fetchProc.running) return
        fetchProc.command = ["curl", "-sS", "--max-time", "15",
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=" + fields.join(",")
            + "&temperature_unit=" + temperatureUnit
            + "&wind_speed_unit=" + windSpeedUnit
            + "&precipitation_unit=" + precipitationUnit
            + "&timezone=auto"]
        fetchProc.running = true
    }

    function apply(data) {
        const c = data.current
        temperature = c.temperature_2m
        apparentTemperature = c.apparent_temperature
        humidity = c.relative_humidity_2m
        isDay = c.is_day === 1
        precipitation = c.precipitation
        rain = c.rain
        showers = c.showers
        snowfall = c.snowfall
        weatherCode = c.weather_code
        cloudCover = c.cloud_cover
        pressure = c.pressure_msl
        windSpeed = c.wind_speed_10m
        windDirection = c.wind_direction_10m
        windGusts = c.wind_gusts_10m
        units = data.current_units ?? {}
        timezone = data.timezone ?? ""

        observedAt = new Date(Date.parse(c.time + "Z") - (data.utc_offset_seconds ?? 0) * 1000)
        ready = true
    }

    function schedule(fetchedAt) {
        const remaining = refreshInterval - (Date.now() - fetchedAt)
        if (remaining <= 0) {
            refresh()
        } else {
            refreshTimer.interval = remaining
            refreshTimer.restart()
        }
    }

    function loadCache() {
        cacheChecked = true
        if (!hasLocation) {
            console.warn("weather: latitude/longitude not set, skipping fetch")
            return
        }
        try {
            const cache = JSON.parse(cacheFile.text())
            if (cache.key === requestKey && cache.data?.current) {
                apply(cache.data)
                lastUpdated = new Date(cache.fetchedAt)
                schedule(cache.fetchedAt)
                return
            }
        } catch (e) {}
        refresh()
    }

    onRequestKeyChanged: {
        if (!cacheChecked) return
        ready = false
        refreshTimer.stop()
        Qt.callLater(refresh)
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: {
                let data
                try {
                    data = JSON.parse(text)
                } catch (e) {
                    data = { error: true, reason: text.trim() ? "invalid response" : "no response" }
                }

                if (data.error || !data.current) {
                    root.error = data.reason ?? "unexpected response"
                    console.warn("weather: fetch failed:", root.error)
                    refreshTimer.interval = root.retryDelay
                    refreshTimer.restart()
                    root.retryDelay = Math.min(root.retryDelay * 2, root.refreshInterval)
                    return
                }

                const now = Date.now()
                root.error = ""
                root.retryDelay = 60 * 1000
                root.apply(data)
                root.lastUpdated = new Date(now)
                cacheFile.setText(JSON.stringify({ key: root.requestKey, fetchedAt: now, data: data }))
                root.schedule(now)
            }
        }
    }

    FileView {
        id: cacheFile
        path: Quickshell.cachePath("weather.json")
        printErrors: false
        onLoaded: root.loadCache()
        onLoadFailed: root.loadCache()
    }

    Timer {
        id: refreshTimer
        onTriggered: root.refresh()
    }

    function describe(code) {
        switch (code) {
        case 0: return "Clear"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Fog"
        case 48: return "Rime fog"
        case 51: return "Light drizzle"
        case 53: return "Drizzle"
        case 55: return "Heavy drizzle"
        case 56: case 57: return "Freezing drizzle"
        case 61: return "Light rain"
        case 63: return "Rain"
        case 65: return "Heavy rain"
        case 66: case 67: return "Freezing rain"
        case 71: return "Light snow"
        case 73: return "Snow"
        case 75: return "Heavy snow"
        case 77: return "Snow grains"
        case 80: return "Light showers"
        case 81: return "Showers"
        case 82: return "Heavy showers"
        case 85: case 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96: case 99: return "Thunderstorm with hail"
        default: return ""
        }
    }

    function iconFor(code, day) {
        if (code < 0) return ""
        if (code === 0 || code === 1) return day ? Theme.iconWeatherClear : Theme.iconWeatherClearNight
        if (code === 2) return day ? Theme.iconWeatherPartlyCloudy : Theme.iconWeatherPartlyCloudyNight
        if (code === 3) return Theme.iconWeatherCloudy
        if (code === 45 || code === 48) return Theme.iconWeatherFog
        if (code === 65 || code === 82) return Theme.iconWeatherPouring
        if (code === 56 || code === 57 || code === 66 || code === 67) return Theme.iconWeatherSleet
        if ((code >= 71 && code <= 77) || code === 85 || code === 86) return Theme.iconWeatherSnow
        if (code >= 51 && code <= 82) return Theme.iconWeatherRain
        if (code >= 95) return Theme.iconWeatherThunder
        return ""
    }
}
