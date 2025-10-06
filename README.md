# Aesthetic Pick

Unicode text “styler” for Wayland/X11 that lets you pick a lettering style in a **Rofi** menu and instantly paste the transformed text back into the focused app. No Electron, no Python—just Bash + small CLI tools.

Second thing to check: **Video walkthrough** → https://www.youtube.com/watch?v=7h0ecbkMhj4

---

## What it does

1. Shows a Rofi menu with preview labels for multiple styles (Fraktur, Script, Mono, Small-caps, Bold, Mini/superscripts, Black/Circle boxed, Inverse, Witched).
2. Reads the **PRIMARY selection** (not the clipboard) via `wl-paste` (Wayland) or `xclip` (X11).
3. Maps characters using prebuilt Unicode alphabets (A–Z, a–z, 0–9 where applicable).
4. Pastes the result automatically:
   - Wayland: via `ydotool` key injection (or middle-click if using PRIMARY).
   - X11: via `xdotool` or middle-click.

If nothing is selected, the script exits without changing anything.

---

## Styles available

Key → visual intent:

- `mini` → ᵐᶦⁿᶦ (superscripts)
- `oldenglish` → 𝔉𝔯𝔞𝔨𝔱𝔲𝔯
- `oldenglishbold` → 𝕭𝖑𝖆𝖈𝖑𝖊𝖙𝖙𝖊𝖗
- `handwriting` → 𝓢𝓬𝓻𝓲𝓹𝓽
- `handwritingbold` → 𝐒𝐜𝐫𝐢𝐩𝐭 𝐁𝐨𝐥𝐝
- `chanfrado` → 𝔻𝕠𝕦𝕓𝕝𝕖-𝕤𝕥𝕣𝕦𝕔𝕜
- `evensized` → ꜱᴍᴀʟʟ ᴄᴀᴘꜱ
- `inverse` → uʍop ǝpᴉsdn
- `blackboxed` → 🅱🅻🅰🅲🅺 🅱🅾🆇🅴🅳
- `circleboxed` → ⓒⓘⓡⓒⓛⓔ ⓑⓞⓧⓔⓓ
- `serifbold` → 𝐒𝐞𝐫𝐢𝐟 𝐁𝐨𝐥𝐝
- `italic` → 𝘐𝘵𝘢𝘭𝘪𝘤
- `bold` → 𝘽𝙤𝙡𝙙 (sans)
- `mono` → 𝙼𝚘𝚗𝚘
- `witched` → W҉i҉t҉c҉h҉e҉d҉ (combining marks)

The preview labels you see in Rofi are generated in the script itself.

---

## Requirements

**Mandatory**
- `rofi`

**Wayland path (primary)**
- `wl-clipboard` (`wl-paste`, `wl-copy`)
- `ydotool` (key injection) and a writable `/dev/uinput`  
  - Kernel module: `uinput` loaded and persistent
  - udev rule for `/dev/uinput`: `GROUP="input", MODE="0660"`
  - Your user in group `input` (relog required)
  - User service: `systemctl --user enable --now ydotool.service`
  - Expected socket: `/run/user/<UID>/.ydotool_socket`

**X11 fallback**
- `xclip`
- `xdotool`

Arch Linux example:
```bash
sudo pacman -S rofi wl-clipboard ydotool xclip xdotool
````

---

## Install

Place the files as the script expects:

```
~/.local/bin/aesthetic-pick.sh
~/.local/bin/aesthetic-black.rasi
```

Make executable:

```bash
chmod +x ~/.local/bin/aesthetic-pick.sh
```

Optional desktop entry / keybinding: bind a shortcut to run:

```bash
~/.local/bin/aesthetic-pick.sh
```

---

## Usage

1. Select text in any app so it lives in the **PRIMARY selection**.
2. Run `aesthetic-pick.sh` (launcher, shortcut, or terminal).
3. Pick a style in Rofi.
4. Script pastes the transformed text back into the focused app.

Nothing selected → script exits quietly.

---

## Configuration

Environment variables (override at runtime or in your shell profile):

* `AESTHETIC_DELAY` (default `0.70`) — wait for focus to return from Rofi (Wayland).
* `PASTE_DELAY` (default `0.06`) — small sync delay before paste.
* `AESTHETIC_PASTE_SEQ` — `auto` | `ctrlv` | `ctrlshiftv` | `shiftinsert`.
  `auto` picks `ctrl+shift+v` for terminals; `ctrl+v` elsewhere.
* `AESTHETIC_FALLBACK_CLIP` — `1` uses clipboard with key paste; `0` uses PRIMARY + middle-click.

Examples:

```bash
AESTHETIC_DELAY=0.5 AESTHETIC_PASTE_SEQ=ctrlv ~/.local/bin/aesthetic-pick.sh
AESTHETIC_FALLBACK_CLIP=0 ~/.local/bin/aesthetic-pick.sh
```

Theme:

* `~/.local/bin/aesthetic-black.rasi` is referenced by the script (`-theme "$HOME/.local/bin/aesthetic-black.rasi"`). Tweak as you like.

---

## How it works (brief)

* Reads `$XDG_SESSION_TYPE` to branch Wayland/X11.
* Captures PRIMARY via `wl-paste --primary` or `xclip -selection primary`.
* Converts characters with mapping tables for each alphabet; unrecognized codepoints pass through unchanged.
* Pastes with `ydotool` (Wayland) or `xdotool` (X11), optionally using middle-click if PRIMARY mode.
* Restores the previous clipboard when clipboard mode is used (to avoid clobbering user data).

---

## Troubleshooting

* “Nothing happens”: ensure something is selected; PRIMARY is not the clipboard. Try `AESTHETIC_FALLBACK_CLIP=1`.
* Wayland paste fails: check `ydotool.service` is active and `/dev/uinput` permissions.
* Rofi theme path wrong: update the `-theme` arg or place the `.rasi` in the expected location.
* Terminal paste wrong combo: set `AESTHETIC_PASTE_SEQ=ctrlshiftv`.

---

## Security notes

`ydotool` injects keys via `uinput`. Keep udev rules tight. Only add your user to `input` if you accept the risk.

---

## Credits

* Rofi color theme basis by **Rasmus Steinke (Rasi)**. The included `aesthetic-black.rasi` draws on Rasi’s style work; see original Rofi themes for inspiration and licenses.
* Script and mappings by project authors.

License: MIT (for this repo’s original code). Check upstream licenses for any third-party theme fragments you use.
EOF

git add README.md
git commit -m "docs: rewrite README with usage, dependencies, and video"
git push

```
```
