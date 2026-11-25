# Limbo

A Z-City fork for Garry's Mod, made for Sandbox.

Limbo keeps Z-City as it is and adds a few things on top: some of Remorse's features (hands, melee, sounds, gore),
its own ESC menu, achievements, and a cleaner that keeps your latest body and its gear. Most additions can be
switched off in Settings.

## Based on

- **Z-City** by uzelezz123 and contributors: https://github.com/uzelezz123/Z-City (Workshop 3657285193).
  Base version: 1.4.2, commit `1cbec7e4e8b978a4152c0983d55b58c42bba4953`. Original readme kept as `README_ZCITY.md`.
- **Remorse** (a Z-City fork): https://github.com/kazoo43/remorseism. Features brought over are credited in the
  commits that add them.

## Licence

Limbo is licensed under the GNU Affero General Public License v3.0, the same as Z-City. See `LICENSE`.
Models, sounds and textures from other authors keep their own terms and are credited in Limbo Content.

## Server modules

`lua/bin/gmsv_eightbit_*.dll` is Z-City's 8bit module. The Steam Workshop does not allow DLL files,
so server owners copy these into `garrysmod/lua/bin/` by hand.
