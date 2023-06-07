# Core

This is the core pathfinding code that workshop developers can copy into their gamemode.

`core.ow` is automatically generated when `core.ostw` is modified. `core.opy` needs to be created by hand.

`core.ostw`, `core.ow`, and `core.opy` will be saved into the editor workshop mode itself so that it can be seamlessly exported. This feature presents some unique restrictions to these 3 files.

- All string and comment literals must be kept under 128 bytes.
- No block comments; these can unexpectedly terminate the generated block comment symbols.
