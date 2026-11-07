pragma Singleton

import Quickshell
import QtQuick

// Machine-specific settings, read from VOYAGER_* environment variables when
// the shell starts. Unset values use the defaults below; invalid values log a
// warning and fall back to the default too.
Singleton {
    id: root

    readonly property string monitor: envString("VOYAGER_MONITOR", "DP-1")
    readonly property string wallpaperDir: envPath("VOYAGER_WALLPAPER_DIR", "~/wallpapers")
    readonly property string cpuTempSensor: envPath("VOYAGER_CPU_TEMP_SENSOR", "") // empty means auto-detect (see SystemMonitor)
    readonly property string font: envString("VOYAGER_FONT", "BlexMono Nerd Font")

    readonly property real latitude: envNumber("VOYAGER_LATITUDE", 51.48, -90, 90)
    readonly property real longitude: envNumber("VOYAGER_LONGITUDE", 0.00, -180, 180)
    readonly property string temperatureUnit: envChoice("VOYAGER_TEMPERATURE_UNIT", "fahrenheit", ["celsius", "fahrenheit"])
    readonly property string windSpeedUnit: envChoice("VOYAGER_WIND_SPEED_UNIT", "kmh", ["kmh", "ms", "mph", "kn"])
    readonly property string precipitationUnit: envChoice("VOYAGER_PRECIPITATION_UNIT", "mm", ["mm", "inch"])

    // seconds
    readonly property int lockTimeout: envNumber("VOYAGER_LOCK_TIMEOUT", 600, 1, Infinity, true)
    readonly property int suspendTimeout: envNumber("VOYAGER_SUSPEND_TIMEOUT", 900, 1, Infinity, true)

    function raw(name) {
        const value = Quickshell.env(name)
        return value === undefined || value === null ? "" : String(value).trim()
    }

    function invalid(name, value, fallback, expected) {
        console.warn(`env: ${name}="${value}" is not ${expected}, using ${fallback}`)
        return fallback
    }

    function envString(name, fallback) {
        return raw(name) || fallback
    }

    function envPath(name, fallback) {
        const home = Quickshell.env("HOME")
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

    function envChoice(name, fallback, choices) {
        const value = raw(name).toLowerCase()
        if (!value) return fallback
        if (!choices.includes(value))
            return invalid(name, value, fallback, `one of ${choices.join(", ")}`)
        return value
    }
}
