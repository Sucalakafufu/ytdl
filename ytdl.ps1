[CmdletBinding(DefaultParameterSetName="DefaultParameterSet")]

param (
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$Alias = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$AudioOnly,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$Cookies = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$CookiesFromBrowser = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$CD,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$DownloadArchive = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$DownloadDirectory = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$DownloadSubtitles,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$Echo,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$EmbedSubtitles,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$FileNameConvention = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$GetId,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$GetTitle,
    [Parameter(ParameterSetName="HelpParameterSet")][switch]$Help,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$ListFormats,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$ListSubs,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$MatchTitle = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$Music,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$NoOverwrites,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$Playlist,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$RejectTitle = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][ValidateSet("4k","2k","1080p","720p")][String]$Resolution = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$SkipDownload,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$SubDirectory = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$SubLangs = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$UniqueFileNames,
    [Parameter(Mandatory=$True,ParameterSetName="DefaultParameterSet",Position=0,ValueFromRemainingArguments=$True)]$URLs = "",
    [Parameter(ParameterSetName="VersionParameterSet")][switch]$Version
)

. $PSScriptRoot\ytdl_constants.ps1
. $PSScriptRoot\ytdl_globalvars.ps1

if ($FileNameConvention -eq "") {
    $FileNameConvention = $FILENAME_CONVENTION_DEFAULT
}

if ($AudioOnly -OR $Music) {
    $audioFormat = $AUDIO_FORMAT_MP3
    $audioFormatParameter = $AUDIO_FORMAT_PARAMETER
    $audioQuality = $AUDIO_QUALITY_BEST
    $audioQualityParameter = $AUDIO_QUALITY_PARAMETER
    $extractAudioParameter = $EXTRACT_AUDIO_PARAMETER
    $formatSort = $EMPTY_STRING
    $formatSortParameter = $EMPTY_STRING
}

if ($CD) {
    $DownloadDirectory = Get-Location
}

if ($Cookies -ne "") {
    $cookiesParameter = $COOKIES_PARAMETER
}
elseif ($COOKIES_FILE_YOUTUBE -ne "") {
    $Cookies = $COOKIES_FILE_YOUTUBE
    $cookiesParameter = $COOKIES_PARAMETER
}

if ($CookiesFromBrowser -ne "") {
    $cookiesFromBrowserParameter = $COOKIES_FROM_BROWSER_PARAMETER
}
elseif ($COOKIES_BROWSER_DEFAULT -ne "") {
    $CookiesFromBrowser = $COOKIES_BROWSER_DEFAULT
    $cookiesFromBrowserParameter = $COOKIES_FROM_BROWSER_PARAMETER
}

if ($DownloadDirectory -eq "") {
    if ($DOWNLOAD_DIRECTORY_DEFAULT -eq "") {
        Write-Output "<ERROR> NO DOWNLOAD DIRECTORY SPECIFIED IN CONFIG OR FROM COMMANDLINE"
        return
    }
    else {
        $DownloadDirectory = $DOWNLOAD_DIRECTORY_DEFAULT
    }
}

if ($DownloadArchive -ne "") {
    $downloadArchiveParameter = $DOWNLOAD_ARCHIVE_PARAMETER
    $downloadArchiveTextFile = "$DownloadArchive"
}
elseif ($DOWNLOAD_ARCHIVE_TXT_DEFAULT -ne "") {
    $downloadArchiveParameter = $DOWNLOAD_ARCHIVE_PARAMETER
    $downloadArchiveTextFile = $DOWNLOAD_ARCHIVE_TXT_DEFAULT
}

if ($DownloadSubtitles) {
    $writeSubsParameter = "--write-subs"
}

if ($DownloadSubtitles -OR $EmbedSubtitles) {
    $convertSubsFormat = $CONVERT_SUBS_FORMAT_SRT
    $convertSubsParameter = $CONVERT_SUBS_PARAMETER
    $subLangParameter = $SUB_LANG_PARAMETER

    if ($SubLangs -ne "") {
        $subLang = $SubLangs
    }
    else {
        $subLang = $SUB_LANG_ALL
    }
}

if ($EmbedSubtitles) {
    $embedSubsParameter = $EMBED_SUBS_PARAMETER
}

if ($GetId) {
    $getIdParameter = $GET_ID_PARAMETER
}

if ($GetTitle) {
    $getTitleParameter = $GET_TITLE_PARAMETER
}

if ($Help) {
    Write-Output @"
ytdl $VERSION_NUMBER - A yt-dlp wrapper

USAGE
    ytdl [OPTIONS] <URL> [URL...]

BASIC
    -Resolution <4k|2k|1080p|720p>    Set video resolution (default: 1080p)
                                       4k uses MKV output with x265 re-encode
    -AudioOnly                         Extract audio as MP3
    -Music                             Extract audio as MP3, prefix path with artist\album\
    -NoOverwrites                      Skip files that already exist

DOWNLOAD LOCATION
    -DownloadDirectory <path>          Directory to download into
    -SubDirectory <name>               Append a subdirectory to the download path
    -CD                                Use the current directory as the download directory

SUBTITLES
    -DownloadSubtitles                 Write subtitles to a separate file
    -EmbedSubtitles                    Embed subtitles into the video file
    -SubLangs <langs>                  Subtitle language(s), comma-separated (default: all)

FILTERING
    -MatchTitle <regex>                Only download videos whose title matches the regex
    -RejectTitle <regex>               Skip videos whose title matches the regex
    -Playlist                          Download as playlist, prefix path with playlist name

AUTHENTICATION
    -Cookies <path>                    Path to a cookies file
    -CookiesFromBrowser <browser>      Pull cookies from a browser (e.g. chrome, firefox)

ARCHIVE
    -DownloadArchive <path>            Path to archive file to skip already-downloaded videos
                                       Falls back to DOWNLOAD_ARCHIVE_TXT_DEFAULT if configured

OUTPUT
    -FileNameConvention <template>     yt-dlp output template for file naming
    -UniqueFileNames                   Append video ID to filenames to avoid conflicts

INSPECTION
    -GetId                             Print video ID(s) without downloading
    -GetTitle                          Print video title(s) without downloading
    -ListFormats                       List available formats for the URL
    -ListSubs                          List available subtitles for the URL
    -SkipDownload                      Run without downloading (combine with subtitle flags)

ALIASES
    -Alias <name>                      Run a predefined download profile from ytdl_aliases.ps1

DEBUG
    -Echo                              Print the yt-dlp command instead of executing it

OTHER
    -Version                           Print version number
    -Help                              Show this help message
"@
    return
}

if ($ListFormats) {
    $formatSort = $EMPTY_STRING
    $formatSortParameter = $EMPTY_STRING
    $listFormatsParameter = $LIST_FORMATS_PARAMETER
}

if ($ListSubs) {
    $listSubsParameter = $LIST_SUBS_PARAMETER
}

if ($MatchTitle -ne "") {
    $matchTitleParameter = $MATCH_TITLE_PARAMETER
}

if ($Music) {
    $FileNameConvention = $FILENAME_CONVENTION_MUSIC_PREFIX + $FileNameConvention
}

if ($NoOverwrites) {
    $noOverwritesParameter = $NO_OVERWRITES_PARAMETER
}

if ($RejectTitle) {
    $rejectTitleParameter = $REJECT_TITLE_PARAMETER
}

if ($Playlist) {
     $FileNameConvention = "%(playlist)s\" + $FileNameConvention
}

if ($Resolution -ne "") {
    if ($Resolution -eq $RESOLUTION_1080p) {
        $formatSort = $FORMAT_SORT_1080p
    }
    elseif ($Resolution -eq $RESOLUTION_2k) {
        $formatSort = $FORMAT_SORT_2k
    }
    elseif ($Resolution -eq $RESOLUTION_4k) {
        $formatSort = $FORMAT_SORT_4k
        $mergeOutputFormat = $MERGE_OUTPUT_FORMAT_MKV
        $postprocessorArgs = $POSTPROCESSOR_ARGS_X265
        $postprocessorArgsParameter = $POSTPROCESSOR_ARGS_PARAMETER
        $postprocessorName = $POSTPROCESSOR_VIDEO_RECODE
        $postprocessorParameter = $POSTPROCESSOR_PARAMETER
    }
    elseif ($Resolution -eq $RESOLUTION_720p) {
        $formatSort = $FORMAT_SORT_720p
    }
}

if ($SkipDownload) {
    $skipDownloadParameter = $SKIP_DOWNLOAD_PARAMETER
}

if ($SubDirectory -ne "") {
    $DownloadDirectory = "$DownloadDirectory\$SubDirectory"
}

if ($UniqueFileNames) {
    $FileNameConvention = $FILENAME_CONVENTION_UNIQUE
}

if ($Version) {
    Write-Output "ytdl $VERSION_NUMBER"
    return
}

. $PSScriptRoot\ytdl_aliases.ps1

foreach ($URL in $URLs) {
    if ($Echo) {
        echo "yt-dlp $skipDownloadParameter $cookiesFromBrowserParameter $CookiesFromBrowser $cookiesParameter $Cookies $getIdParameter $getTitleParameter $listFormatsParameter $listSubsParameter $formatSortParameter $formatSort $OUTPUT_PARAMETER $DownloadDirectory\$FileNameConvention $matchTitleParameter $MatchTitle $rejectTitleParameter $RejectTitle $noOverwritesParameter $extractAudioParameter $audioFormatParameter $audioFormat $audioQualityParameter $audioQuality $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $downloadArchiveParameter $downloadArchiveTextFile $MERGE_OUTPUT_FORMAT_PARAMETER $mergeOutputFormat $postprocessorParameter $postprocessorName $postprocessorArgsParameter `"$postprocessorArgs`" $URL"
    }
    else {
        yt-dlp $skipDownloadParameter $cookiesFromBrowserParameter $CookiesFromBrowser $cookiesParameter $Cookies $getIdParameter $getTitleParameter $listFormatsParameter $listSubsParameter $formatSortParameter $formatSort $OUTPUT_PARAMETER $DownloadDirectory\$FileNameConvention $matchTitleParameter $MatchTitle $rejectTitleParameter $RejectTitle $noOverwritesParameter $extractAudioParameter $audioFormatParameter $audioFormat $audioQualityParameter $audioQuality $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $downloadArchiveParameter $downloadArchiveTextFile $MERGE_OUTPUT_FORMAT_PARAMETER $mergeOutputFormat $postprocessorParameter $postprocessorName $postprocessorArgsParameter "$postprocessorArgs" $URL
    }
}