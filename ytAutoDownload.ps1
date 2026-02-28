. $PSScriptRoot\ytdl_constants.ps1
. $PSScriptRoot\ytAutoDownload_constants.ps1

foreach ($monitoredHash in $monitoredHashArray) {
    . $PSScriptRoot\ytdl_globalvars.ps1

    #clear vars
    $archiveTxtPath = ""
    $cookies = ""
    $cookiesFromBrowser = ""
    $downloadDirectory = ""
    $downloadSubtitles = ""
    $embedSubtitles = ""
    $fileNameConvention = ""
    $formatSort = $FORMAT_SORT_1080p
    $formatSortParameter = $FORMAT_SORT_PARAMETER
    $matchTitle = ""
    $rejectTitle = ""

    if ($monitoredHash.ContainsKey($DIRECTORY_KEY)) {
        $downloadDirectory = $monitoredHash.$DIRECTORY_KEY
    }
    else {
        Write-Output "<ERROR> NO DOWNLOAD DIRECTORY SPECIFIED IN CONFIG FOR: $monitoredHash.$LABEL_KEY"
        return
    }

    if ($monitoredHash.ContainsKey($ARCHIVE_TXT_KEY)) {
        $archiveTxtPath = $monitoredHash.$ARCHIVE_TXT_KEY
    }
    else {
        $archiveTxtPath = "$downloadDirectory\archive.txt"
    }

    if ($monitoredHash.ContainsKey($AUDIO_ONLY_KEY) -OR $monitoredHash.ContainsKey($MUSIC_KEY)) {
        $audioFormat = $AUDIO_FORMAT_MP3
        $audioFormatParameter = $AUDIO_FORMAT_PARAMETER
        $audioQuality = $AUDIO_QUALITY_BEST
        $audioQualityParameter = $AUDIO_QUALITY_PARAMETER
        $extractAudioParameter = $EXTRACT_AUDIO_PARAMETER
        $formatSortParameter = $EMPTY_STRING
        $formatSort = $EMPTY_STRING
    }

    if ($monitoredHash.ContainsKey($FILENAME_CONVENTION_KEY)) {
        $fileNameConvention = $monitoredHash.$FILENAME_CONVENTION_KEY
    }
    else {
        $fileNameConvention = $FILENAME_CONVENTION_DEFAULT
    }

    if ($monitoredHash.ContainsKey($COOKIES_BROWSER_KEY)) {
        $cookiesFromBrowser = $monitoredHash.$COOKIES_BROWSER_KEY
        $cookiesFromBrowserParameter = $COOKIES_FROM_BROWSER_PARAMETER
    }
    elseif ($COOKIES_BROWSER_DEFAULT -ne "") {
        $cookiesFromBrowser = $COOKIES_BROWSER_DEFAULT
        $cookiesFromBrowserParameter = $COOKIES_FROM_BROWSER_PARAMETER
    }

    if ($monitoredHash.ContainsKey($COOKIES_FILE_KEY)) {
        $cookies = $monitoredHash.$COOKIES_FILE_KEY
        $cookiesParameter = $COOKIES_PARAMETER
    }
    elseif ($COOKIES_FILE_YOUTUBE -ne "") {
        $cookies = $COOKIES_FILE_YOUTUBE
        $cookiesParameter = $COOKIES_PARAMETER
    }

    if ($monitoredHash.ContainsKey($MATCH_TITLE_KEY)) {
        $matchTitle = $monitoredHash.$MATCH_TITLE_KEY
        $matchTitleParameter = $MATCH_TITLE_PARAMETER
    }

    if ($monitoredHash.ContainsKey($MUSIC_KEY)) {
        $fileNameConvention = $FILENAME_CONVENTION_MUSIC_PREFIX + $fileNameConvention
    }

    if ($monitoredHash.ContainsKey($REJECT_TITLE_KEY)) {
        $rejectTitle = $monitoredHash.$REJECT_TITLE_KEY
        $rejectTitleParameter = $REJECT_TITLE_PARAMETER
    }

    if ($monitoredHash.ContainsKey($SUBTITLES_KEY)) {
        if ($monitoredHash.$SUBTITLES_KEY -eq $SUBTITLES_DOWNLOAD) {
            $writeSubsParameter = $WRITE_SUBS_PARAMETER
        }

        if ($monitoredHash.$SUBTITLES_KEY -eq $SUBTITLES_EMBED) {
            $embedSubsParameter = $EMBED_SUBS_PARAMETER
        }

        if ($monitoredHash.$SUBTITLES_KEY -eq $SUBTITLES_BOTH) {
            $embedSubsParameter = $EMBED_SUBS_PARAMETER
            $writeSubsParameter = $WRITE_SUBS_PARAMETER
        }

        $convertSubsFormat = $CONVERT_SUBS_FORMAT_SRT
        $convertSubsParameter = $CONVERT_SUBS_PARAMETER
        $subLang = $SUB_LANG_EN
        $subLangParameter = $SUB_LANG_PARAMETER
    }

    #Checks for subtitles per ID if required
    if ($monitoredHash.ContainsKey($SUBTITLES_REQUIRED_KEY)) {
        $IDs = yt-dlp $cookiesParameter $cookies $GET_ID_PARAMETER $matchTitleParameter $matchTitle $rejectTitleParameter $rejectTitle $DOWNLOAD_ARCHIVE_PARAMETER $archiveTxtPath $monitoredHash.$URL_KEY

        foreach ($ID in $IDs) {
            $foundSub = $False
            $subLanguages = $subLang.Split(",")
            $subs = yt-dlp $LIST_SUBS_PARAMETER $YOUTUBE_ID_BASE_URL$ID

            for ($i = 0; $i -lt $subs.Length; $i++) {
                if ($subs[$i].Contains("Available subtitles")) {
                    $i++

                    while ($i -lt $subs.Length) {
                        foreach ($subLanguage in $subLanguages) {
                            if (!$subLanguage.Contains("-")) {
                                $subLanguage = "$subLanguage "
                            }

                            if ($subs[$i].StartsWith($subLanguage)) {
                                $foundSub = $True
                            }
                        }

                        $i++
                    }
                }
            }

            if ($foundSub) {
                yt-dlp $cookiesFromBrowserParameter $cookiesFromBrowser $cookiesParameter $cookies $formatSortParameter $formatSort $OUTPUT_PARAMETER $downloadDirectory\$fileNameConvention $matchTitleParameter $matchTitle $rejectTitleParameter $rejectTitle $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $NO_OVERWRITES_PARAMETER $DOWNLOAD_ARCHIVE_PARAMETER $archiveTxtPath $MERGE_OUTPUT_FORMAT_PARAMETER $MERGE_OUTPUT_FORMAT_MP4 $YOUTUBE_ID_BASE_URL$ID
            }
        }
    }
    else {
        yt-dlp $cookiesFromBrowserParameter $cookiesFromBrowser $cookiesParameter $cookies $formatSortParameter $formatSort $OUTPUT_PARAMETER $downloadDirectory\$fileNameConvention $matchTitleParameter $matchTitle $rejectTitleParameter $rejectTitle $NO_OVERWRITES_PARAMETER $extractAudioParameter $audioFormatParameter $audioFormat $audioQualityParameter $audioQuality $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $DOWNLOAD_ARCHIVE_PARAMETER $archiveTxtPath $MERGE_OUTPUT_FORMAT_PARAMETER $MERGE_OUTPUT_FORMAT_MP4 $monitoredHash.$URL_KEY
    }
}