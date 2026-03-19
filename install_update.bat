@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script must be run as Administrator.
    pause
    exit /b 1
)
choco upgrade ffmpeg -y
pip install -U yt-dlp[default,curl_cffi]
pip install -U yt-dlp-ejs
pip install -U deno
pause
