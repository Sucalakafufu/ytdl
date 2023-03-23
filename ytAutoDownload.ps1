. $PSScriptRoot\ytdl_constants.ps1
. $PSScriptRoot\ytAutoDownload_constants.ps1

foreach ($monitoredHash in $monitoredHashArray) {
    . $PSScriptRoot\ytdl_globalvars.ps1

    #clear vars
    $archiveTxtPath = ""
    $cookies = ""
    $downloadDirectory = ""
    $downloadSubtitles = ""
    $embedSubtitles = ""
    $fileNameConvention = ""
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

    if ($monitoredHash.ContainsKey($FILENAME_CONVENTION_KEY)) {
        $fileNameConvention = $monitoredHash.$FILENAME_CONVENTION_KEY
    }
    else {
        $fileNameConvention = $FILENAME_CONVENTION_DEFAULT
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
                yt-dlp $cookiesParameter $cookies $FORMAT_PARAMETER $format $OUTPUT_PARAMETER $downloadDirectory\$fileNameConvention $matchTitleParameter $matchTitle $rejectTitleParameter $rejectTitle $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $DOWNLOAD_ARCHIVE_PARAMETER $archiveTxtPath $YOUTUBE_ID_BASE_URL$ID
            }
        }
    }
    else {
        yt-dlp $cookiesParameter $cookies $FORMAT_PARAMETER $format $OUTPUT_PARAMETER $downloadDirectory\$fileNameConvention $matchTitleParameter $matchTitle $rejectTitleParameter $rejectTitle $NO_OVERWRITES_PARAMETER $writeSubsParameter $subLangParameter $subLang $convertSubsParameter $convertSubsFormat $embedSubsParameter $DOWNLOAD_ARCHIVE_PARAMETER $archiveTxtPath $monitoredHash.$URL_KEY
    }
}