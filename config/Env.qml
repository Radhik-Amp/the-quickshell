pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Machine-specific settings, read once when the shell starts. Each VOYAGER_*
// value comes from, in order: the environment, the settings file
// (~/.config/voyager/env), then the defaults below. Invalid values log a
// warning and fall back to the default.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string settingsPath: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/voyager/env"
    readonly property var fileValues: parse(settingsFile.text())
    property var seen: ({})

    FileView {
        id: settingsFile
        path: root.settingsPath
        blockLoading: true
        printErrors: false
    }

    readonly property string monitor: envString("VOYAGER_MONITOR", "") // empty means auto-detect (see Mango)
    readonly property string wallpaperDir: envPath("VOYAGER_WALLPAPER_DIR", "~/wallpapers")
    // awww transition used when setting a wallpaper (see `awww img --help`)
    readonly property string wallpaperTransition: envChoice("VOYAGER_WALLPAPER_TRANSITION", "center",
        ["none", "simple", "fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "any", "outer", "random"])
    readonly property real wallpaperDuration: envNumber("VOYAGER_WALLPAPER_DURATION", 0.6, 0, 60)
    readonly property int wallpaperFps: envNumber("VOYAGER_WALLPAPER_FPS", 144, 1, 1000, true)
    readonly property string wallpaperBezier: envPattern("VOYAGER_WALLPAPER_BEZIER", "0.22,1,0.36,1",
        /^-?\d*\.?\d+(,-?\d*\.?\d+){3}$/, "four comma-separated numbers like 0.22,1,0.36,1")
    readonly property real wallpaperAngle: envNumber("VOYAGER_WALLPAPER_ANGLE", 45, 0, 360)
    readonly property string wallpaperPosition: envString("VOYAGER_WALLPAPER_POSITION", "center")
    readonly property string cpuTempSensor: envPath("VOYAGER_CPU_TEMP_SENSOR", "") // empty means auto-detect (see SystemMonitor)
    readonly property string font: envString("VOYAGER_FONT", "BlexMono Nerd Font")
    readonly property string tetherStyle: envChoice("VOYAGER_TETHER_STYLE", "line", ["line", "thick", "dashed", "bridge", "none"])
    readonly property string tetherReveal: envChoice("VOYAGER_TETHER_REVEAL", "auto", ["auto", "vertical", "horizontal"])
    readonly property string tetherContent: envChoice("VOYAGER_TETHER_CONTENT", "fixed", ["fixed", "slide"])

    readonly property real latitude: envNumber("VOYAGER_LATITUDE", 51.48, -90, 90)
    readonly property real longitude: envNumber("VOYAGER_LONGITUDE", 0.00, -180, 180)
    readonly property string temperatureUnit: envChoice("VOYAGER_TEMPERATURE_UNIT", "fahrenheit", ["celsius", "fahrenheit"])
    readonly property string windSpeedUnit: envChoice("VOYAGER_WIND_SPEED_UNIT", "kmh", ["kmh", "ms", "mph", "kn"])
    readonly property string precipitationUnit: envChoice("VOYAGER_PRECIPITATION_UNIT", "mm", ["mm", "inch"])

    // seconds
    readonly property int lockTimeout: envNumber("VOYAGER_LOCK_TIMEOUT", 600, 1, Infinity, true)
    readonly property int suspendTimeout: envNumber("VOYAGER_SUSPEND_TIMEOUT", 900, 1, Infinity, true)

    function fromEnv(name) {
        const value = Quickshell.env(name)
        return value === undefined || value === null ? "" : String(value).trim()
    }

    function raw(name) {
        seen[name] = true
        return fromEnv(name) || (fileValues[name] ?? "")
    }

    function invalid(name, value, fallback, expected) {
        const source = fromEnv(name) ? "environment" : settingsPath
        console.warn(`settings: ${name}="${value}" (from ${source}) is not ${expected}, using ${fallback}`)
        return fallback
    }

    // NAME=value per line, like a shell env file: blank lines, # comments,
    // "quoted" or 'quoted' values and a leading `export` are all fine.
    function parse(text) {
        const values = {}
        const lines = (text ?? "").split("\n")
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim()
            if (!line || line.startsWith("#")) continue

            const m = line.match(/^(?:export\s+)?([A-Za-z_]\w*)\s*=\s*(.*)$/)
            if (!m) {
                console.warn(`settings: ${settingsPath}:${i + 1}: expected NAME=value, got "${line}"`)
                continue
            }
            const quoted = m[2].match(/^(["'])(.*?)\1\s*(?:#.*)?$/)
            values[m[1]] = quoted ? quoted[2] : m[2].replace(/\s+#.*$/, "").trim()
        }
        return values
    }

    Component.onCompleted: {
        for (const name in fileValues)
            if (!seen[name])
                console.warn(`settings: unknown setting ${name} in ${settingsPath}`)
    }

    function envString(name, fallback) {
        return raw(name) || fallback
    }

    function envPath(name, fallback) {
        return envString(name, fallback).replace(/^~(?=\/|$)/, home).replace(/(.)\/+$/, "$1")
    }

    function envNumber(name, fallback, min, max, integer = false) {
        const value = raw(name)
        if (!value) return fallback

        const n = Number(value)
        if (isNaN(n) || n < min || n > max || (integer && !Number.isInteger(n)))
            return invalid(name, value, fallback, integer ? `a whole number >= ${min}` : `a number from ${min} to ${max}`)
        return n
    }

    function envPattern(name, fallback, pattern, expected) {
        const value = raw(name).replace(/\s+/g, "")
        if (!value) return fallback
        if (!pattern.test(value)) return invalid(name, value, fallback, expected)
        return value
    }

    function envChoice(name, fallback, choices) {
        const value = raw(name).toLowerCase()
        if (!value) return fallback
        if (!choices.includes(value))
            return invalid(name, value, fallback, `one of ${choices.join(", ")}`)
        return value
    }
}
