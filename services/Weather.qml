pragma Singleton

import qs.config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real latitude: Env.latitude
    property real longitude: Env.longitude

    // adjustable values -- will add a controller soon
    property string temperatureUnit: Env.temperatureUnit
    property string windSpeedUnit: Env.windSpeedUnit
    property string precipitationUnit: Env.precipitationUnit

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

    readonly property var hourlyFields: ["temperature_2m", "weather_code", "precipitation_probability", "is_day"]
    readonly property var dailyFields: [
        "weather_code", "temperature_2m_max", "temperature_2m_min",
        "precipitation_probability_max", "sunrise", "sunset"
    ]
    readonly property int forecastDays: 7
    property int hourlyCount: 8

    // formatting is as such 
    property var hourly: []// [{ time: Date, temp, code, pop, isDay, icon }]
    property var daily: [] // [{ date: Date, code, high, low, pop, sunrise: Date, sunset: Date, icon, description }]
    readonly property real weekLow: daily.length ? Math.min(...daily.map(d => d.low)) : 0
    readonly property real weekHigh: daily.length ? Math.max(...daily.map(d => d.high)) : 0

    readonly property string requestKey: [latitude.toFixed(3), longitude.toFixed(3),
        temperatureUnit, windSpeedUnit, precipitationUnit, fields.join(","),
        hourlyFields.join(","), dailyFields.join(","), forecastDays].join("|")

    property bool cacheChecked: false
    property int retryDelay: 60 * 1000

    function refresh() {
        if (!hasLocation || fetchProc.running) return
        fetchProc.command = ["curl", "-sS", "--max-time", "15",
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=" + fields.join(",")
            + "&hourly=" + hourlyFields.join(",")
            + "&daily=" + dailyFields.join(",")
            + "&forecast_days=" + forecastDays
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

        const offset = data.utc_offset_seconds ?? 0
        observedAt = parseLocal(c.time, offset)

        const h = data.hourly
        const hourStart = new Date().setMinutes(0, 0, 0)
        const hours = []
        for (let i = 0; i < h.time.length && hours.length < hourlyCount; i++) {
            const time = parseLocal(h.time[i], offset)
            if (time < hourStart) continue
            const isDayHour = h.is_day[i] === 1
            hours.push({
                time: time,
                temp: h.temperature_2m[i],
                code: h.weather_code[i],
                pop: h.precipitation_probability[i] ?? 0,
                isDay: isDayHour,
                icon: iconFor(h.weather_code[i], isDayHour)
            })
        }
        hourly = hours

        const d = data.daily
        daily = d.time.map((t, i) => ({
            date: parseLocal(t + "T12:00", offset),
            code: d.weather_code[i],
            high: d.temperature_2m_max[i],
            low: d.temperature_2m_min[i],
            pop: d.precipitation_probability_max[i] ?? 0,
            sunrise: parseLocal(d.sunrise[i], offset),
            sunset: parseLocal(d.sunset[i], offset),
            icon: iconFor(d.weather_code[i], true),
            description: describe(d.weather_code[i])
        }))

        ready = true
    }

    function parseLocal(str, offsetSeconds) {
        return new Date(Date.parse(str + "Z") - offsetSeconds * 1000)
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
            if (cache.key === requestKey && cache.data?.current && cache.data?.hourly && cache.data?.daily) {
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

                if (data.error || !data.current || !data.hourly || !data.daily) {
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
