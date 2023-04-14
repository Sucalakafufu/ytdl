[CmdletBinding(DefaultParameterSetName="DefaultParameterSet")]

param (
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$Alias = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$AudioOnly,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$Cookies = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$CD,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$DownloadArchive = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$DownloadDirectory = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$DownloadSubtitles,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$EmbedSubtitles,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$FileNameConvention = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$GetId,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$GetTitle,
    [Parameter(ParameterSetName="HelpParameterSet")][switch]$Help,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$ListSubs,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$MatchTitle = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$Music,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$NoOverwrites,
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$Playlist,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$RejectTitle = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][ValidateSet("4k","2k","1080p","720p")][String]$Resolution = "",
    [Parameter(ParameterSetName="DefaultParameterSet")][switch]$SkipDownload,
    [Parameter(ParameterSetName="DefaultParameterSet")][String]$SubDirectory = "",
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
    $format = $FORMAT_AUDIO_ONLY
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

if ($DownloadArchive -ne "") {
    $downloadArchiveParameter = $DOWNLOAD_ARCHIVE_PARAMETER
    $downloadArchiveTextFile = "$DownloadArchive"
}

if ($DownloadDirectory -eq "") {
    if ($DOWNLOAD_DIRECTORY_DEFAULT -eq "") {
        Write-Output "<ERROR> NO DOWNLOAD DIRECTORY SPECIFIED IN CONFIG OR FROM COMMANDLINE"
    }
    else {
        $DownloadDirectory = $DOWNLOAD_DIRECTORY_DEFAULT
    }
}

if ($DownloadSubtitles) {    
    $writeSubsParameter = "--write-subs"
}

if ($DownloadSubtitles -OR $EmbedSubtitles) {
    $convertSubsFormat = $CONVERT_SUBS_FORMAT_SRT
    $convertSubsParameter = $CONVERT_SUBS_PARAMETER
    $subLang = $SUB_LANG_EN
    $subLangParameter = $SUB_LANG_PARAMETER
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
        In Progress
"@
    return
}

if ($ListSubs) {
    $listSubsParameter = $LIST_SUBS_PARAMETER
}

if ($MatchTitle -ne "") {
    $matchTitleParameter = $MATCH_TITLE_PARAMETER
}

if ($Music) {
    $FileNameConvention = "%(album)s\" + $FileNameConvention
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
        $format = $FORMAT_1080p
    }
    elseif ($Resolution -eq $RESOLUTION_2k) {
        $format = $FORMAT_2K
    }
    elseif ($Resolution -eq $RESOLUTION_4k) {
        $format = $FORMAT_4K
    }
    elseif ($Resolution -eq $RESOLUTION_720p) {
        $format = $FORMAT_720p
    }
}

if ($SkipDownload) {
    $skipDownloadParameter = $SKIP_DOWNLOAD_PARAMETER
}

if ($SubDirectory -ne "") {
    $FileNameConvention = "$SubDirectory\$FileNameConvention"
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
    yt-dlp $skipDownloadParameter $cookiesParameter $Cookies $getIdParameter $getTitleParameter $listSubsParameter $FORMAT_PARAMETER $format $OUTPUT_PARAMETER $DownloadDirectory\$FileNameConvention $matchTitleParameter $MatchTitle $rejectTitleParameter $RejectTitle $noOverwritesParameter $extractAudioParameter $audioFormatParameter $audioFormat $audioQualityParameter $audioQuality $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $downloadArchiveParameter $downloadArchiveTextFile $URL
}