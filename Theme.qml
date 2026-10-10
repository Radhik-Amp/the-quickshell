pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color background: Qt.rgba(0, 0, 0, 0.85)
    readonly property color borderColor: Qt.rgba(1, 1, 1, 0.85)
    readonly property color text: "white"
    readonly property color textDim: Qt.rgba(1, 1, 1, 0.45)

    readonly property string fontFamily: "BlexMono Nerd Font"
    readonly property int fontSize: 16

    readonly property int barHeight: 40
    readonly property int padding: 10
    readonly property int radius: 5
    readonly property int borderWidth: 2

    readonly property color tagActive: Qt.rgba(1, 1, 1, 0.20)
    readonly property color tagHover: Qt.rgba(1, 1, 1, 0.08)
    readonly property color tagBorder: Qt.rgba(1, 1, 1, 0.25)
    readonly property color tagBorderActive: Qt.rgba(1, 1, 1, 0.38)
    readonly property color tagBorderEmpty: Qt.rgba(1, 1, 1, 0.00)
    readonly property color tagUrgent: Qt.rgba(1, 1, 1, 0.35)
    readonly property int tagWidth: 28
    readonly property int tagHeight: 24
    
    readonly property int vitalsSpacing: 5
    readonly property int iconToValueSpacing: 8
    readonly property string bracketLeft: "\u{27E8}"
    readonly property string bracketRight: "\u{27E9}"
    readonly property string iconCpu: "\u{F4BC}"
    readonly property string iconMemory: "\u{EFC5}"
    readonly property string iconTemp: "\u{F050F}"
    readonly property string iconVolumeHigh: "\u{F057E}"
    readonly property string iconVolumeMedium: "\u{F0580}"
    readonly property string iconVolumeLow: "\u{F057F}"
    readonly property string iconVolumeZero: "\u{F075F}"
    readonly property string iconVolumeMuted: "\u{F0581}"
    readonly property string iconWifi: "\u{F05A9}"
    readonly property string iconEthernet: "\u{F0200}"
    readonly property string iconOffline: "\u{F05AA}"
}

