<div align="center">
    <img src="docs/appicon.png" width="200" height="200">
    <h1>Yabai Indicator</h1>
    <p>
        <b>Clickable spaces switcher powered by Yabai</b>
    </p>

<img src="docs/simple.png" alt="screenshot">
<p>Shows a row clickable buttons for all workspaces including fullscreen applications(fullscreen apps not clickable atm)</p>

<img src="docs/window-mode.png" alt="screenshot">
<p>Alternatively show miniature windows.</p>


<img src="docs/screenshot-dark.png" alt="screenshot2">
<p>Also supports multiple displays (with separate spaces).</p>

<img src="docs/fullscreen.png" alt="screenshot3">
<p>Fullscreen applications.</p>

<img src="docs/compact.png" alt="screenshot4">
<p>Show only active space(s)</p>
</div>

## Requirements

[Yabai](https://github.com/koekeishiya/yabai) is required to be running for the space switching and keeping spaces information in sync and showing individual windows. In order for switching spaces by clicking to work correctly, you will need to disable SIP.


## Installation

Requires macOS 12+
If you don't have yabai, install yabai (version 4.0.2 required) first: [Official installation guide](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release))

I haven't setup builds or builds uploading, so just open the project in Xcode, set your signing team, and make a new bundle identifier and build. Make sure to revolke and regrant accessibility permissions if build is updated.

In order to allow for showing windows and keeping the spaces in sync, when spaces are removed in mission control the following signals need to be added to your `.yabairc`:

```
yabai -m signal --add event=mission_control_exit action='echo "refresh" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=display_added action='echo "refresh" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=display_removed action='echo "refresh" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_created action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_destroyed action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_focused action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_moved action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_resized action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_minimized action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
yabai -m signal --add event=window_deminimized action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
```

If certain keybinds modify the spaces arrangement the following commands needs to be added to keep the indicator in sync:

```
echo "refresh" | nc -U /tmp/yabai-indicator.socket
```

This sends a refresh command to Yabai Indicator via a unix-domain socket.

## Comparison to similar applications

[YabaiInidicator (Original)](https://github.com/xiamaz/YabaiIndicator) Requires SIP to be disabled to switch spaces, and has a slightly more outdated codebase (according to me). Opening settings from menu bar doesn't work on macOS 14+. Had a blurry text issue on retina displays.

[SpaceId](https://github.com/dshnkao/SpaceId) has some additonal configurability for presentation and also allows showing all active spaces on all displays. Switching between spaces is not implemented. As of 12/2021 it does not utilize Acessibility API for catching MissionControl invocation. It does not have a dependency on Yabai.

[WhichSpace](https://github.com/gechr/WhichSpace) shows the current active Space in a single indicator. Does not allow for showing all spaces or all visible spaces on multiple displays.
