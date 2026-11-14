<div align="center">

# Voyager Shell

**A lightweight, config-driven desktop shell for [MangoWM](https://github.com/DreamMaoMao/mangowc), built with [Quickshell](https://quickshell.org)**

[Requirements](#requirements) • [Installation](#installation) • [Configuration](#configuration) • [Keybinds](#keybinds)

</div>

---

## Requirements

| Dependency | Used for |
| --- | --- |
| [MangoWM](https://github.com/DreamMaoMao/mangowc) | The compositor; `mmsg` (bundled with it) provides tags, layouts and monitor detection |
| [Quickshell](https://quickshell.org) | The shell runtime |
| [awww](https://codeberg.org/LGFae/awww) | Wallpapers |
| [cava](https://github.com/karlstav/cava) | Media center audio visualizer |
| [ddcutil-service](https://github.com/digitaltrails/ddcutil-service) | External monitor brightness over D-Bus (uses [ddcutil](https://www.ddcutil.com)) |
| [NetworkManager](https://networkmanager.dev) | Ethernet status (`nmcli`) |
| PipeWire or PulseAudio | Volume control |
| [tuned-ppd](https://github.com/redhat-performance/tuned) or [power-profiles-daemon](https://gitlab.freedesktop.org/upower/power-profiles-daemon) | Power profile switching |
| A [Nerd Font](https://www.nerdfonts.com) | Icons (defaults to `BlexMono Nerd Font`) |

## Installation

### 1. Install dependencies

These commands assume Mango is already installed; see [its README](https://github.com/DreamMaoMao/mangowc) if not.

**Fedora** (awww is in [Terra](https://terra.fyralabs.com), ddcutil-service is in a COPR)

```sh
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf copr enable hopsayer/ddcutil-service
sudo dnf install quickshell awww cava ddcutil-service NetworkManager tuned-ppd
```

**Arch** (Quickshell, awww and ddcutil-service are in the AUR)

```sh
yay -S quickshell awww ddcutil-service
sudo pacman -S cava ddcutil networkmanager power-profiles-daemon
```

> [!NOTE]
> On other distros, package names vary and Quickshell, awww or ddcutil-service may not be packaged at all. Install Quickshell with its [install guide](https://quickshell.org/docs/guide/install-setup), and build awww and ddcutil-service from the sources linked in [Requirements](#requirements).

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

To launch both on login, add them to Mango's autostart (`~/.config/mango/config.conf`):

```ini
exec_once=awww-daemon
exec_once=qs
```

## Configuration

### Settings file

Machine-specific settings live in `~/.config/voyager/env` (or `$XDG_CONFIG_HOME/voyager/env`), outside the repo, so pulling updates or re-cloning never touches them. The shell reads it once at startup, so restart `qs` after editing. The file is optional; anything you leave out uses the default.

```sh
mkdir -p ~/.config/voyager
$EDITOR ~/.config/voyager/env
```

Write one `NAME=value` per line. `#` comments and quoted values are fine:

```sh
# ~/.config/voyager/env
VOYAGER_LATITUDE=40.71
VOYAGER_LONGITUDE=-74.01
VOYAGER_TEMPERATURE_UNIT=celsius
VOYAGER_WALLPAPER_DIR="~/Pictures/Wallpapers"
```

| Setting | Default | Description |
| --- | --- | --- |
| `VOYAGER_MONITOR` | auto-detected | Output the bar and its tags go on, e.g. `HDMI-A-1`. Only needed to pick a different monitor than the detected one |
| `VOYAGER_WALLPAPER_DIR` | `~/wallpapers` | Folder the wallpaper picker opens |
| `VOYAGER_CPU_TEMP_SENSOR` | auto-detected | CPU temperature file, only needed if detection picks the wrong sensor or none |
| `VOYAGER_FONT` | `BlexMono Nerd Font` | Font family (must be a Nerd Font for icons) |
| `VOYAGER_TETHER_STYLE` | `line` | How panels connect to the bar or screen edge: `line`, `thick`, `dashed`, `bridge` (the panel joins the bar or edge along its whole side, with curved corners) or `none` |
| `VOYAGER_TETHER_REVEAL` | `auto` | `auto` slides a panel in sideways when it's pushed against a screen edge and drops it down from the bar otherwise; `vertical` always drops down; `horizontal` always tethers to the nearer side edge |
| `VOYAGER_TETHER_CONTENT` | `fixed` | Bridge style only, where the outline slides out from under the bar or edge: `fixed` uncovers the content in place, `slide` moves it with the outline |
| `VOYAGER_LATITUDE` | `51.48` | Weather location, `-90` to `90` (default is Greenwich, London) |
| `VOYAGER_LONGITUDE` | `0.00` | Weather location, `-180` to `180` |
| `VOYAGER_TEMPERATURE_UNIT` | `fahrenheit` | `celsius` or `fahrenheit` |
| `VOYAGER_WIND_SPEED_UNIT` | `kmh` | `kmh`, `ms`, `mph` or `kn` |
| `VOYAGER_PRECIPITATION_UNIT` | `mm` | `mm` or `inch` |
| `VOYAGER_LOCK_TIMEOUT` | `600` | Seconds idle before locking |
| `VOYAGER_SUSPEND_TIMEOUT` | `900` | Seconds idle before suspending |

Invalid values, unknown names and malformed lines are reported in the `qs` log, and the setting falls back to its default.

The tether settings are defaults; a single panel can override them in its QML file, e.g. `tetherStyle: "bridge"`, `reveal: "vertical"` or `contentMotion: "slide"` in `modules/systemcenter/SystemCenter.qml`.

Each setting can also be passed as an environment variable of the same name, which wins over the file. That's handy for a one-off test, e.g. `VOYAGER_MONITOR=eDP-1 qs`.

The shell detects the monitor by asking Mango (`mmsg get all-monitors`) and using the first active output. Run that command to see your output names.

The CPU sensor is found by driver name (`k10temp`/`zenpower` on AMD, `coretemp` on Intel, `cpu_thermal` on ARM). To pick one by hand, list them with `grep . /sys/class/hwmon/*/name` and set `VOYAGER_CPU_TEMP_SENSOR` to that folder's `temp1_input`.

### Theme and visualizer

| Setting | File |
| --- | --- |
| Colors, spacing, icons | `config/Theme.qml` |
| Visualizer | `config/cava.conf` |

## Keybinds

The shell exposes IPC commands you can bind to keys in Mango.

| Command | Action |
| --- | --- |
| `qs ipc call lockscreen lock` | Lock the screen |
| `qs ipc call lockscreen lockAndSuspend` | Lock and suspend |
| `qs ipc call wallpaper toggle` | Open/close the wallpaper panel |
| `qs ipc call wallpaper preview` | Open/close the fullscreen wallpaper preview |
| `qs ipc call wallpaper set <path>` | Set a wallpaper |
| `qs ipc call notifications toggle` | Open/close notifications |
| `qs ipc call panels toggle <name>` | Toggle a panel: `control`, `media`, `weather`, `system` or `wallpaper` |
| `qs ipc call panels close` | Close any open panel |

Example binds for `~/.config/mango/config.conf`:

```ini
bind=SUPER,l,spawn,qs ipc call lockscreen lock
bind=SUPER,w,spawn,qs ipc call wallpaper toggle
bind=SUPER,n,spawn,qs ipc call notifications toggle
```

## TODO

- [ ] **Laptop brightness.** `ddcutil-service` only reaches external monitors over DDC/CI, so built-in (`eDP`) panels get no brightness control. Route those through logind's `Session.SetBrightness("backlight", …)` and read `/sys/class/backlight/<dev>/` instead.
- [ ] **Per-monitor brightness.** The slider always targets ddcutil display 1. Match each screen to its display by EDID (model/serial) and control the one the panel is open on.
