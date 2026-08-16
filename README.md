# dots

Config files to recreate this CachyOS / [niri](https://github.com/YaLTeR/niri)
environment on another machine.

## What's tracked

| Dir | Tool | Installs to |
|-----|------|-------------|
| `niri/` | niri compositor (`config.kdl` + `dms/` includes) | `~/.config/niri/` |
| `mango/` | MangoWM compositor (`config.conf` + `dms/` includes) | `~/.config/mango/` |
| `alacritty/` | Alacritty terminal | `~/.config/alacritty/` |
| `kitty/` | kitty terminal | `~/.config/kitty/` |
| `fish/` | fish shell (`config.fish` + functions) | `~/.config/fish/` |
| `cava/` | cava visualizer (config, themes, shaders) | `~/.config/cava/` |
| `micro/` | micro editor | `~/.config/micro/` |
| `DankMaterialShell/` | DankMaterialShell (the niri bar/shell) | `~/.config/DankMaterialShell/` |
| `environment.d/` | systemd user environment | `~/.config/environment.d/` |
| `git/` | global git ignore | `~/.config/git/` |
| `home/` | `.bashrc`, `.zshrc` | `~/` |

## Install

```sh
./install.sh --dry-run   # preview
./install.sh             # apply
./install.sh --force     # apply even if a package isn't detected
```

For each tool the script checks the binary is on `PATH`; if missing, that tool
is skipped. Any existing config it would overwrite is first moved aside to
`<name>.bak-<timestamp>`.

## Notes

- **Displays are machine-specific.** `niri/dms/outputs.kdl` and the `eDP-2`
  block in `niri/config.kdl` describe *this* laptop's screen. Adjust them on new
  hardware — run `niri msg outputs` to find the right output names.
  `mango/dms/outputs.conf` is the same story for mango — re-run `dms setup`
  or hand-edit the `monitorrule=` lines on new hardware.
- **`niri/dms/*` and `mango/dms/*` are managed by DankMaterialShell.** They're
  tracked here for an exact restore, but DMS may rewrite these files;
  re-commit after intentional changes. `mango/dms/binds.conf` is the
  exception — DMS ships it empty for mango right now, so its content here is
  hand-written (mango's restored native keybinds + DMS IPC calls + niri-parity
  binds), not DMS-generated.
- Runtime dependencies referenced by configs but not installed here:
  `fcitx5` (spawned by niri), `rbenv` and `eza` (used in `config.fish`).
- Excluded on purpose: editor backups (`*~`, `*.backup.*`) and fish runtime
  state (`fish_variables`).
