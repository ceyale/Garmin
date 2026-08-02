# Garmin Windsurf App

A GPS session tracker for windsurfing on Garmin Connect IQ devices.

## Features

- **GPS Session Tracking** - Tracks your windsurfing session using GPS
- **Current Speed** - Real-time speed in km/h
- **Max Speed** - Highest speed reached during the session
- **Distance** - Total distance covered in km
- **Elapsed Time** - Session duration in MM:SS format

## Controls

- **Menu button** - Opens the session menu (Start / Stop / Reset)
- **Start button** - Starts a new session
- **Back button** - Stops the current session

## Build

```bat
build.bat
```

This compiles the app for the Forerunner 745 (fr745) and outputs `windsurf.prg`.

## Requirements

- Garmin Connect IQ SDK
- Java (JRE 21+)
- Garmin developer key (generated via `gen_key.bat` if missing)