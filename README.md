# ytdl-ui-extension

[Русская версия](README.ru.md)

`ytdl-ui-extension` is an unofficial Chromium extension fork of [`NyashniyVladya/ytdl7000`](https://github.com/NyashniyVladya/ytdl7000), a small `yt-dlp` based tool for downloading videos from YouTube and other video hosting sites.

This fork is not affiliated with the original ytdl7000 author.

This fork keeps the original `ytdl7000` package name, command name, and `ytdl7000:` browser protocol for compatibility with the upstream installer.

## Features of this fork

- The extension opens the downloader from the current tab context instead of creating a minimized background Chrome window.
- The popup UI was redesigned with a compact dark theme.
- The language is detected automatically from Chrome/system settings, with a small EN/RU switch in the popup.
- The maximum resolution can be entered manually or selected from quick presets.
- A custom save folder can be entered directly in the popup.
- The extension icon was replaced with a clearer download icon.
- Popup labels and tooltips were adjusted for readability.

## Requirements

- Python 3.11 or newer
- `ffmpeg`
- A Chromium-based browser
- `yt-dlp`

The one-command installer checks these automatically. If Python is missing, it opens the Python Manager download page. If `ffmpeg` is missing, it installs the latest package with `winget`. For better YouTube support, the installer can also install Node.js.

## Installation

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/Zhigalove/ytdl-ui-extension/main/setup.ps1 | iex
```

The installer will:

- detect Russian or English from the terminal/system language;
- check Python 3.11 or newer;
- install `ffmpeg` with `winget` if needed;
- offer to install Node.js for better YouTube support;
- install/update `yt-dlp`, `yt-dlp-ejs`, and this extension fork;
- print the folder that should be loaded in Chrome.

If `winget` is missing, install App Installer from Microsoft Store:

https://www.microsoft.com/store/productId/9NBLGGH4NNS1

winget documentation:

https://learn.microsoft.com/windows/package-manager/winget

After installation, the extension folder should appear at:

```cmd
%userprofile%\ytdl7000_ext
```

Load it as an unpacked extension in your Chromium browser.

## Manual installation

If you prefer to install manually, run:

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

## Load the extension

1. Open `chrome://extensions` in Chrome or `browser://extensions` in Yandex Browser.
2. Enable Developer mode.
3. Click "Load unpacked".
4. Select `%userprofile%\ytdl7000_ext`.

## Usage

1. Open a page with a video, channel, or playlist.
2. Click the extension icon.
3. Choose download options.
4. Click "Start download".

## Credits

- Original project: [`NyashniyVladya/ytdl7000`](https://github.com/NyashniyVladya/ytdl7000)
- Fork of ytdl7000 by NyashniyVladya. This version includes fixes/improvements made by me.
- Some changes were made with assistance from Codex and manually reviewed.

## License

This project keeps the original MIT license and copyright notice.
