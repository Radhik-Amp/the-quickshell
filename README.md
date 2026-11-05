<div align="center">

# Voyager Shell

**A lightweight, config-driven desktop shell for Wayland, built with [Quickshell](https://quickshell.org)**

[Requirements](#requirements) • [Installation](#installation) • [Configuration](#configuration) • [Keybinds](#keybinds)

</div>

---

## Requirements

| Dependency | Used for |
| --- | --- |
| [Quickshell](https://quickshell.org) | The shell runtime |
| Wayland compositor | Tags only support [MangoWM](https://github.com/DreamMaoMao/mangowc) for now |
| [awww](https://codeberg.org/LGFae/awww) | Wallpapers |
| [cava](https://github.com/karlstav/cava) | Media center audio visualizer |
| [ddcutil-service](https://github.com/digitaltrails/ddcutil-service) | External monitor brightness over D-Bus (uses [ddcutil](https://www.ddcutil.com)) |
| [NetworkManager](https://networkmanager.dev) | Ethernet status (`nmcli`) |
| PipeWire or PulseAudio | Volume control |
| [tuned-ppd](https://github.com/redhat-performance/tuned) or [power-profiles-daemon](https://gitlab.freedesktop.org/upower/power-profiles-daemon) | Power profile switching |
| A [Nerd Font](https://www.nerdfonts.com) | Icons (defaults to `BlexMono Nerd Font`) |

## Installation

### 1. Install dependencies

**Fedora**

```sh
sudo dnf copr enable hopsayer/ddcutil-service
sudo dnf install quickshell awww cava ddcutil-service NetworkManager tuned-ppd
```

**Arch** (Quickshell, awww and ddcutil-service are in the AUR)

```sh
yay -S quickshell awww ddcutil-service
sudo pacman -S cava ddcutil networkmanager power-profiles-daemon
```

> [!NOTE]
> Package names vary by distro. If yours doesn't package Quickshell, follow the [Quickshell install guide](https://quickshell.org/docs/guide/install-setup).

### 2. Allow brightness control

The shell asks `ddcutil-service` for brightness over the session bus; it starts on demand, so there's nothing to enable. The service needs the `i2c-dev` module and membership in the `i2c` group to reach the monitor:

```sh
echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf
sudo usermod -aG i2c $USER
```

Log out and back in for the group change to take effect.

### 3. Clone the config

Quickshell reads its config from `~/.config/quickshell`. This backs up any existing config first:

```sh
[ -d ~/.config/quickshell ] && mv ~/.config/quickshell ~/.config/quickshell.bak
git clone https://github.com/Radhik-Amp/the-quickshell.git ~/.config/quickshell
```

### 4. Add wallpapers

The wallpaper picker reads from `~/wallpapers` by default:

```sh
mkdir -p ~/wallpapers
```

### 5. Start the shell

Start the `awww` daemon, then the shell:

```sh
awww-daemon &
qs
```

To launch both on login, add them to your MangoWM autostart (`~/.config/mango/config.conf`):

```ini
exec-once=awww-daemon
exec-once=qs
```

## Configuration

Settings live in plain QML files. Restart `qs` after editing them.

| Setting | File | Property |
| --- | --- | --- |
| Colors, font, spacing, icons | `config/Theme.qml` | — |
| Weather location | `services/Weather.qml` | `latitude`, `longitude` |
| Weather units | `services/Weather.qml` | `temperatureUnit`, `windSpeedUnit`, `precipitationUnit` |
| Idle lock / suspend (seconds) | `services/Idle.qml` | `lockTimeout`, `screenOffTimeout` |
| Wallpaper directory | `services/Wallpaper.qml` | `currentDirectory` |
| Monitor watched for tags | `services/Mango.qml` | `DP-1` in the `mmsg` command |
| CPU temperature sensor | `services/SystemMonitor.qml` | `/sys/class/hwmon/hwmon3/temp1_input` |
| Visualizer | `config/cava.conf` | — |

## Keybinds

The shell exposes IPC commands you can bind to keys in your compositor.

| Command | Action |
| --- | --- |
| `qs ipc call lockscreen lock` | Lock the screen |
| `qs ipc call lockscreen lockAndSuspend` | Lock and suspend |
| `qs ipc call wallpaper toggle` | Open/close the wallpaper picker |
| `qs ipc call wallpaper set <path>` | Set a wallpaper |
| `qs ipc call notifications toggle` | Open/close notifications |
| `qs ipc call panels toggle <name>` | Toggle a panel: `control`, `media` or `weather` |
| `qs ipc call panels close` | Close any open panel |

Example MangoWM binds:

```ini
bind=SUPER,l,spawn,qs ipc call lockscreen lock
bind=SUPER,w,spawn,qs ipc call wallpaper toggle
bind=SUPER,n,spawn,qs ipc call notifications toggle
```

## TODO

- [ ] **Laptop brightness.** `ddcutil-service` only reaches external monitors over DDC/CI, so built-in (`eDP`) panels get no brightness control. Route those through logind's `Session.SetBrightness("backlight", …)` and read `/sys/class/backlight/<dev>/` instead.
- [ ] **Per-monitor brightness.** The slider always targets ddcutil display 1. Match each screen to its display by EDID (model/serial) and control the one the panel is open on.
- [ ] **Environment variables.** Move machine-specific settings (monitor, wallpaper dir, weather location/units, idle timeouts, CPU temp sensor, font) to `VOYAGER_*` env vars with defaults.
