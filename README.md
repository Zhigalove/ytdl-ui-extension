# ytdl-ui-extension

[Русская версия](README.ru.md)

Fork of ytdl7000 by NyashniyVladya. This version includes fixes/improvements made by me with assistance from Codex.

`ytdl-ui-extension` is a Chromium extension fork of [`NyashniyVladya/ytdl7000`](https://github.com/NyashniyVladya/ytdl7000), a small `yt-dlp` based tool for downloading videos from YouTube and other video hosting sites.

This fork keeps the original `ytdl7000` package name, command name, and `ytdl7000:` browser protocol for compatibility with the upstream installer.

## What changed

- The extension opens the downloader from the current tab context instead of creating a minimized background Chrome window.
- The popup UI was redesigned with a compact dark theme.
- The language is detected automatically from Chrome/system settings, with a small EN/RU switch in the popup.
- The maximum resolution can be entered manually and selected from quick presets.
- The extension icon was replaced with a clearer download icon.
- Popup labels and tooltips were adjusted for readability.

## Requirements

- Python 3.11 or newer
- `ffmpeg`
- A Chromium-based browser
- `yt-dlp`

For better YouTube support, Node.js or Deno is also recommended.

## Installation

Open a terminal and run:

```cmd
python -m pip install -U "yt-dlp[default]" yt-dlp-ejs
```

```cmd
python -m pip cache purge
```

Install this fork from GitHub:

```cmd
python -m pip install -U https://github.com/Zhigalove/ytdl-ui-extension/archive/refs/heads/main.zip
```

After installation, the extension folder should appear at:

```cmd
%userprofile%\ytdl7000_ext
```

Load it as an unpacked extension in your Chromium browser.

## Load The Extension

1. Open `chrome://extensions` in Chrome or `browser://extensions` in Yandex Browser.
2. Enable Developer mode.
3. Click "Load unpacked".
4. Select `%userprofile%\ytdl7000_ext`.

## Usage

1. Open a page with a video, channel, or playlist.
2. Click the extension icon.
3. Choose download options.
4. Click "Start download".

## License

This project keeps the original MIT license and copyright notice.

Original project: [`NyashniyVladya/ytdl7000`](https://github.com/NyashniyVladya/ytdl7000)
