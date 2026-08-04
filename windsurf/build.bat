@echo off
set "JAVA_BIN=C "PATH=%JAVA_BIN%;%PATH%"
call "C:\Users\franc\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin\monkeyc.bat" -d fr745 -y "c:\Users\franc\Documents\Etienne\Garmin\developer_key" -o windsurf.prg -f monkey.jungle %*