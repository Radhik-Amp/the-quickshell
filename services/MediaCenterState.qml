pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var selectedPlayer: null

    readonly property var autoPlayer: players.find(p => p.isPlaying && p.identity.toLowerCase().includes("spotify"))
        ?? players.find(p => p.isPlaying)
        ?? players.find(p => p.identity.toLowerCase().includes("spotify"))
        ?? players[0]
        ?? null

    readonly property var player: selectedPlayer && players.includes(selectedPlayer) ? selectedPlayer : autoPlayer
}
