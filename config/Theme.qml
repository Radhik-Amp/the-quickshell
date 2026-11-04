pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color background: Qt.rgba(0, 0, 0, 0.85)
    readonly property color borderColor: Qt.rgba(1, 1, 1, 0.85)
    readonly property color borderColorMuted: Qt.rgba(1, 1, 1, 0.25)
    readonly property color buttonColorHovered: Qt.rgba(1, 1, 1, 0.15)
    readonly property color text: "white"

    readonly property string fontFamily: "BlexMono Nerd Font"
    readonly property int fontSize: 16

    readonly property int barHeight: 40
    readonly property int padding: 10
    readonly property int radius: 5
    readonly property int borderWidth: 1

    readonly property int spaceXs: 4
    readonly property int spaceSm: 8
    readonly property int spaceStat: 12
    readonly property int spaceMd: 16
    readonly property int barInset: (barHeight - tagHeight) / 2

    readonly property color tagActive: Qt.rgba(1, 1, 1, 0.20)
    readonly property color tagHover: Qt.rgba(1, 1, 1, 0.08)
    readonly property color tagBorder: Qt.rgba(1, 1, 1, 0.25)
    readonly property color tagBorderActive: Qt.rgba(1, 1, 1, 0.38)
    readonly property color tagBorderEmpty: Qt.rgba(1, 1, 1, 0.00)
    readonly property color tagUrgent: Qt.rgba(1, 1, 1, 0.35)
    readonly property int tagWidth: 28
    readonly property int tagHeight: 24

    readonly property var layoutRects: ({
        "T":  [[0,0,.5,1], [.5,0,.5,.5], [.5,.5,.5,.5]],
        "RT": [[.5,0,.5,1], [0,0,.5,.5], [0,.5,.5,.5]],
        "VT": [[0,0,1,.5], [0,.5,.5,.5], [.5,.5,.5,.5]],
        "CT": [[.25,0,.5,1], [0,0,.25,1], [.75,0,.25,1]],
        "M":  [[0,0,1,1]],
        "K":  [[0,0,.5,1], [.58,.14,.42,.86], [.5,0,.42,.86]],
        "VK": [[0,0,1,.5], [.1,.6,.9,.4], [0,.5,.9,.4]],
        "G":  [[0,0,.5,.5], [.5,0,.5,.5], [0,.5,.5,.5], [.5,.5,.5,.5]],
        "VG": [[0,0,.5,.333], [.5,0,.5,.333], [0,.333,.5,.333], [.5,.333,.5,.333], [0,.667,.5,.333], [.5,.667,.5,.333]],
        "S":  [[0,0,.2,1,.5], [.2,0,.6,1], [.8,0,.2,1,.5]],
        "VS": [[0,0,1,.25,.5], [0,.25,1,.5], [0,.75,1,.25,.5]],
        "DW": [[0,0,.5,1], [.5,0,.5,.5], [.5,.5,.25,.5], [.75,.5,.25,.25], [.75,.75,.25,.25]],
        "F":  [[0,0,.333,1], [.333,0,.333,1], [.667,0,.333,1]],
        "VF": [[0,0,1,.333], [0,.333,1,.333], [0,.667,1,.333]]
    })
    
    readonly property string iconCpu: "\u{F035B}"
    readonly property string iconMemory: "\u{EFC5}"
    readonly property string iconTemp: "\u{F050F}"
    readonly property string iconVolumeHigh: "\u{F057E}"
    readonly property string iconVolumeMedium: "\u{F0580}"
    readonly property string iconVolumeLow: "\u{F057F}"
    readonly property string iconVolumeZero: "\u{F075F}"
    readonly property string iconVolumeMuted: "\u{F0581}"
    readonly property string iconPlay: "\u{F040A}"
    readonly property string iconPause: "\u{F03E4}"
    readonly property string iconNext: "\u{F04AD}"
    readonly property string iconPrevious: "\u{F04AE}"
    readonly property string iconShuffle: "\u{F049D}"
    readonly property string iconShuffleOff: "\u{F049E}"
    readonly property string iconRepeat: "\u{F0456}"
    readonly property string iconRepeatOnce: "\u{F0458}"
    readonly property string iconRepeatOff: "\u{F0457}"
    readonly property string iconMusic: "\u{F0387}"
    readonly property color textMuted: Qt.rgba(1, 1, 1, 0.6)
    readonly property string iconWeatherClear: "\u{F0599}"
    readonly property string iconWeatherClearNight: "\u{F0594}"
    readonly property string iconWeatherPartlyCloudy: "\u{F0595}"
    readonly property string iconWeatherPartlyCloudyNight: "\u{F0F31}"
    readonly property string iconWeatherCloudy: "\u{F0590}"
    readonly property string iconWeatherFog: "\u{F0591}"
    readonly property string iconWeatherRain: "\u{F0597}"
    readonly property string iconWeatherPouring: "\u{F0596}"
    readonly property string iconWeatherSleet: "\u{F067F}"
    readonly property string iconWeatherSnow: "\u{F0598}"
    readonly property string iconWeatherThunder: "\u{F0593}"
    readonly property string iconHumidity: "\u{F058E}"
    readonly property string iconWind: "\u{F059D}"
    readonly property string iconGauge: "\u{F029A}"
    readonly property string iconCloud: "\u{F015F}"
    readonly property string iconUmbrella: "\u{F054A}"
    readonly property string iconRefresh: "\u{F0450}"
}

