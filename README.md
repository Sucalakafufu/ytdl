# ytdl
PowerShell wrapper for yt-dlp, with support for scheduled/batch downloading via ytAutoDownload.

## Requirements
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/) — required for merging and encoding

### Optional (recommended)
- [Python](https://www.python.org/) — recommended for easy installation and updates via pip
- [Chocolatey](https://chocolatey.org/) — recommended Windows package manager for installing ffmpeg
- [curl_cffi](https://github.com/yifeikong/curl_cffi) — browser impersonation for sites that require it
- [yt-dlp-ejs](https://github.com/yt-dlp/yt-dlp-ejs) — enhanced JavaScript support
- [deno](https://deno.com/) — required by yt-dlp-ejs

## Setup

### Recommended
1. Install [Python](https://www.python.org/) and [Chocolatey](https://chocolatey.org/)
2. Copy all files to a folder of your choice
3. Right-click `install_update.bat` and run as administrator — this installs ffmpeg, yt-dlp, and all recommended dependencies. Run it again any time you want to update.
4. Optionally edit `ytdl_user_constants.ps1` to set defaults for download directory, cookies, and archive file — ytdl will work without this, but you will need to pass these via command line each time
5. If you plan to use `ytAutoDownload.bat` or run `ytAutoDownload.ps1` via Task Scheduler or other automation, edit `ytAutoDownload_user_constants.ps1` to configure your monitored sources
6. Optionally add `ytdl.ps1` to your PATH or create a PowerShell alias for it

### Manual
yt-dlp, ffmpeg, and the other dependencies can each be downloaded and installed separately without Python or Chocolatey. Refer to their respective documentation for installation instructions.

---

## ytdl

Command-line downloader. Pass one or more URLs and any combination of options.

```powershell
ytdl [OPTIONS] <URL> [URL...]
```

### Example

```powershell
# Download a video to the default directory with embedded subtitles
ytdl -EmbedSubtitles https://www.youtube.com/watch?v=dQw4w9WgXcQ

# Download a playlist as MP3s into a subdirectory
ytdl -Music -SubDirectory "My Artist" https://www.youtube.com/playlist?list=...

# Check what formats are available before downloading
ytdl -ListFormats https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

### Options

**Basic**
| Parameter | Description |
|---|---|
| `-Resolution <4k\|2k\|1080p\|720p>` | Set video resolution (default: 1080p). 4k uses MKV output with x265 re-encode |
| `-AudioOnly` | Extract audio as MP3 |
| `-Music` | Extract audio as MP3, prefix path with `artist\album\` |
| `-NoOverwrites` | Skip files that already exist |

**Download Location**
| Parameter | Description |
|---|---|
| `-DownloadDirectory <path>` | Directory to download into |
| `-SubDirectory <name>` | Append a subdirectory to the download path |
| `-CD` | Use the current directory as the download directory |

**Subtitles**
| Parameter | Description |
|---|---|
| `-DownloadSubtitles` | Write subtitles to a separate file |
| `-EmbedSubtitles` | Embed subtitles into the video file |
| `-SubLangs <langs>` | Subtitle language(s), comma-separated (default: all) |

**Filtering**
| Parameter | Description |
|---|---|
| `-MatchTitle <regex>` | Only download videos whose title matches the regex |
| `-RejectTitle <regex>` | Skip videos whose title matches the regex |
| `-Playlist` | Download as playlist, prefix path with playlist name |

**Authentication**
| Parameter | Description |
|---|---|
| `-Cookies <path>` | Path to a cookies file |
| `-CookiesFromBrowser <browser>` | Pull cookies from a browser (e.g. `chrome`, `firefox`) |

**Archive**
| Parameter | Description |
|---|---|
| `-DownloadArchive <path>` | Path to archive file to skip already-downloaded videos. Falls back to `DOWNLOAD_ARCHIVE_TXT_DEFAULT` if configured |

**Output**
| Parameter | Description |
|---|---|
| `-FileNameConvention <template>` | yt-dlp output template for file naming |
| `-UniqueFileNames` | Append video ID to filenames to avoid conflicts |

**Inspection**
| Parameter | Description |
|---|---|
| `-GetId` | Print video ID(s) without downloading |
| `-GetTitle` | Print video title(s) without downloading |
| `-ListFormats` | List available formats for the URL |
| `-ListSubs` | List available subtitles for the URL |
| `-SkipDownload` | Run without downloading (useful combined with subtitle flags) |

**Other**
| Parameter | Description |
|---|---|
| `-Alias <name>` | Run a predefined download profile from `ytdl_aliases.ps1` |
| `-Echo` | Print the yt-dlp command instead of executing it |
| `-Version` | Print version number |
| `-Help` | Show help message |

---

## ytAutoDownload

Batch downloader for scheduled or recurring downloads. Define a list of sources in `ytAutoDownload_user_constants.ps1` and run via `ytAutoDownload.bat` or Task Scheduler.

```powershell
ytAutoDownload.ps1 [-Echo]
```

Each entry in `$monitoredHashArray` is a hashtable with the following keys:

| Key | Description |
|---|---|
| `$LABEL_KEY` | Human-readable label for logging |
| `$URL_KEY` | URL to download from (playlist or channel) |
| `$DIRECTORY_KEY` | Directory to download into **(required)** |
| `$ARCHIVE_TXT_KEY` | Path to archive file (defaults to `archive.txt` in the download directory) |
| `$SUBTITLES_KEY` | Subtitle mode: `$SUBTITLES_EMBED`, `$SUBTITLES_DOWNLOAD`, or `$SUBTITLES_BOTH` |
| `$SUBTITLES_REQUIRED_KEY` | If set, only download videos that have real subtitles available |
| `$SUB_LANG_KEY` | Subtitle language(s) to download (defaults to all) |
| `$AUDIO_ONLY_KEY` | If set, extract audio as MP3 |
| `$MUSIC_KEY` | If set, extract audio as MP3 with `artist\album\` prefix |
| `$COOKIES_FILE_KEY` | Path to a cookies file for this entry |
| `$COOKIES_BROWSER_KEY` | Browser to pull cookies from for this entry |
| `$FILENAME_CONVENTION_KEY` | yt-dlp output template for this entry |
| `$MATCH_TITLE_KEY` | Only download videos whose title matches this regex |
| `$REJECT_TITLE_KEY` | Skip videos whose title matches this regex |

### Example entry

```powershell
$monitoredHashArray = @(
    @{
        $LABEL_KEY      = "My Channel"
        $DIRECTORY_KEY  = "D:\Videos\MyChannel"
        $SUBTITLES_KEY  = $SUBTITLES_EMBED
        $URL_KEY        = "https://www.youtube.com/@MyChannel/videos"
    }
)
```

### Error logging
Failed downloads are logged to `ytAutoDownload_errors.txt` in the same folder as the script, with timestamp, exit code, label, and URL.
