import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

class windsurfView extends WatchUi.View {

    // Session state
    private var _sessionActive as Boolean = false;
    private var _sessionStarted as Boolean = false;
    private var _gpsLocked as Boolean = false;

    // Session data
    private var _startTime as Time.Moment?;
    private var _elapsedTime as Float = 0.0;
    private var _currentSpeed as Float = 0.0;
    private var _maxSpeed as Float = 0.0;
    private var _distance as Float = 0.0;
    private var _lastPosition as Position.Location?;

    // Timer for periodic updates
    private var _timer as Timer.Timer?;

    // GUI layout constants
    private const _SPEED_BAR_MAX = 60.0;
    private const _BAR_WIDTH = 180;
    private const _BAR_HEIGHT = 8;

    function initialize() {
        View.initialize();
    }

    // Custom-drawn GUI - no layout resource needed
    function onLayout(dc as Dc) as Void {
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, true);
    }

    // Custom-drawn update
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var centerX = width / 2;

        drawHeader(dc, centerX);
        drawSpeed(dc, centerX);
        drawSpeedBar(dc, centerX);
        drawStats(dc, centerX, width);
    }

    // Called when this View is removed from the screen
    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    // Position callback - called when GPS position updates
    function onPosition(info as Position.Info) as Void {
        var loc = info.position;
        if (loc != null) {
            _gpsLocked = true;
        }

        if (!_sessionActive) {
            return;
        }
        if (loc == null) {
            return;
        }

        var speed = info.speed;
        if (speed != null) {
            _currentSpeed = speed.toFloat() * 3.6;
            if (_currentSpeed > _maxSpeed) {
                _maxSpeed = _currentSpeed;
            }
        }

        if (_lastPosition != null) {
            _distance += calculateDistance(_lastPosition, loc);
        }
        _lastPosition = loc;

        var now = Time.now();
        if (_startTime != null) {
            _elapsedTime = now.subtract(_startTime).value().toFloat();
        }

        updateDisplay();
    }

    // Timer callback - update display every second
    function onTimer() as Void {
        if (_sessionActive) {
            var now = Time.now();
            if (_startTime != null) {
                _elapsedTime = now.subtract(_startTime).value().toFloat();
            }
            updateDisplay();
        }
    }

    // Calculate distance between two locations in km using haversine formula
    private function calculateDistance(loc1 as Position.Location, loc2 as Position.Location) as Float {
        var lat1 = loc1.toRadians()[0].toFloat();
        var lon1 = loc1.toRadians()[1].toFloat();
        var lat2 = loc2.toRadians()[0].toFloat();
        var lon2 = loc2.toRadians()[1].toFloat();

        var earthRadiusKm = 6371.0;
        var dLat = (lat2 - lat1).toDouble();
        var dLon = (lon2 - lon1).toDouble();

        var a = (Math.sin(dLat / 2.0) * Math.sin(dLat / 2.0)) +
                (Math.cos(lat1.toDouble()) * Math.cos(lat2.toDouble()) *
                 Math.sin(dLon / 2.0) * Math.sin(dLon / 2.0));
        var c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
        return (earthRadiusKm * c).toFloat();
    }

    // Start a new session
    function startSession() as Void {
        _sessionActive = true;
        _sessionStarted = true;
        _startTime = Time.now();
        _lastPosition = null;
        _elapsedTime = 0.0;
        _currentSpeed = 0.0;
        _maxSpeed = 0.0;
        _distance = 0.0;
        updateDisplay();
    }

    // Stop the current session
    function stopSession() as Void {
        _sessionActive = false;
        updateDisplay();
    }

    // Reset the session data
    function resetSession() as Void {
        _sessionActive = false;
        _sessionStarted = false;
        _startTime = null;
        _lastPosition = null;
        _elapsedTime = 0.0;
        _currentSpeed = 0.0;
        _maxSpeed = 0.0;
        _distance = 0.0;
        updateDisplay();
    }

    // Update the display
    private function updateDisplay() as Void {
        WatchUi.requestUpdate();
    }

    // ===== GUI Drawing =====

    // Draw title, GPS indicator and status
    private function drawHeader(dc as Dc, centerX as Number) as Void {
        // Title
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 10, Graphics.FONT_XTINY, LoadString(Rez.Strings.AppName), Graphics.TEXT_JUSTIFY_CENTER);

        // GPS indicator (top right)
        var gpsColor = _gpsLocked ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_GRAY;
        dc.setColor(gpsColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX + 56, 16, 4);
        dc.drawText(centerX + 34, 12, Graphics.FONT_XTINY, "GPS", Graphics.TEXT_JUSTIFY_CENTER);

        // Status with colored dot (center)
        var statusText = getStatusText();
        var statusColor = getStatusColor();
        var textWidth = dc.getTextWidthInPixels(statusText, Graphics.FONT_XTINY);
        var groupWidth = textWidth + 16;
        var groupX = centerX - groupWidth / 2;

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(groupX + 4, 28, 4);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(groupX + 12 + textWidth / 2, 22, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Draw the big current speed and unit
    private function drawSpeed(dc as Dc, centerX as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 55, Graphics.FONT_NUMBER_LARGE, formatSpeed(_currentSpeed), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 110, Graphics.FONT_XTINY, "km/h", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Draw the speed progress bar
    private function drawSpeedBar(dc as Dc, centerX as Number) as Void {
        var barX = centerX - _BAR_WIDTH / 2;
        var barY = 132;

        // Background
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, _BAR_WIDTH, _BAR_HEIGHT);

        // Fill proportional to current speed (color-coded)
        var ratio = _currentSpeed / _SPEED_BAR_MAX;
        if (ratio > 1.0) {
            ratio = 1.0;
        } else if (ratio < 0.0) {
            ratio = 0.0;
        }
        var fillWidth = (ratio * _BAR_WIDTH).toNumber();
        if (fillWidth > 0) {
            dc.setColor(speedColor(_currentSpeed), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX, barY, fillWidth, _BAR_HEIGHT);
        }

        // Border
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(barX, barY, _BAR_WIDTH, _BAR_HEIGHT);
    }

    // Draw the bottom stats: MAX, DIST, TIME
    private function drawStats(dc as Dc, centerX as Number, width as Number) as Void {
        // Divider
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX - 95, 158, centerX + 95, 158);

        var col1 = width * 0.25;
        var col2 = width * 0.5;
        var col3 = width * 0.75;

        // Labels
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(col1, 170, Graphics.FONT_XTINY, "MAX", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(col2, 170, Graphics.FONT_XTINY, "DIST", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(col3, 170, Graphics.FONT_XTINY, "TIME", Graphics.TEXT_JUSTIFY_CENTER);

        // Values
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(col1, 190, Graphics.FONT_SMALL, formatSpeed(_maxSpeed), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(col2, 190, Graphics.FONT_SMALL, formatDistance(_distance), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(col3, 190, Graphics.FONT_SMALL, formatTime(_elapsedTime), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Status helpers
    private function getStatusText() as String {
        if (_sessionActive) {
            return LoadString(Rez.Strings.status_active);
        }
        if (_sessionStarted) {
            return LoadString(Rez.Strings.status_stopped);
        }
        return LoadString(Rez.Strings.status_ready);
    }

    private function getStatusColor() as Number {
        if (_sessionActive) {
            return Graphics.COLOR_GREEN;
        }
        if (_sessionStarted) {
            return Graphics.COLOR_YELLOW;
        }
        return Graphics.COLOR_DK_GRAY;
    }

    // Speed-dependent color for the bar
    private function speedColor(speed as Float) as Number {
        if (speed < 20.0) {
            return Graphics.COLOR_GREEN;
        }
        if (speed < 35.0) {
            return Graphics.COLOR_YELLOW;
        }
        return Graphics.COLOR_RED;
    }

    // Format speed in km/h
    private function formatSpeed(speed as Float) as String {
        return speed.format("%.1f");
    }

    // Format distance in km
    private function formatDistance(distance as Float) as String {
        return distance.format("%.2f");
    }

    // Format elapsed time as MM:SS
    private function formatTime(seconds as Float) as String {
        var totalSeconds = seconds.toNumber();
        var minutes = totalSeconds / 60;
        var secs = totalSeconds % 60;
        return minutes.format("%d") + ":" + secs.format("%02d");
    }

}