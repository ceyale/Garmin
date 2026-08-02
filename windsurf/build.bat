@echo off
set "JAVA_BIN=C:\Users\franc\AppData\Roaming\ModrinthApp\meta\java_versions\zulu21.44.17-ca-jre21.0.8-win_x64\bin"
set "PATH=%JAVA_BIN%;%PATH%"
call "C:\Users\franc\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin\monkeyc.bat" -d fr745 -o windsurf.prg -f monkey.jungle %*