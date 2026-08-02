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

    // Session data
    private var _startTime as Time.Moment?;
    private var _elapsedTime as Float = 0.0;
    private var _currentSpeed as Float = 0.0;
    private var _maxSpeed as Float = 0.0;
    private var _distance as Float = 0.0;
    private var _lastPosition as Position.Location?;

    // UI elements
    private var _statusLabel as WatchUi.Text?;
    private var _speedLabel as WatchUi.Text?;
    private var _maxSpeedLabel as WatchUi.Text?;
    private var _distanceLabel as WatchUi.Text?;
    private var _timeLabel as WatchUi.Text?;

    // Timer for periodic updates
    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        _statusLabel = View.findDrawableById("id_status") as WatchUi.Text;
        _speedLabel = View.findDrawableById("id_speed") as WatchUi.Text;
        _maxSpeedLabel = View.findDrawableById("id_max_speed") as WatchUi.Text;
        _distanceLabel = View.findDrawableById("id_distance") as WatchUi.Text;
        _timeLabel = View.findDrawableById("id_time") as WatchUi.Text;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        // Enable position updates
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));

        // Start a timer to update the display every second
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    // Position callback - called when GPS position updates
    function onPosition(info as Position.Info) as Void {
        if (!_sessionActive) {
            return;
        }

        var loc = info.position;
        if (loc == null) {
            return;
        }

        // Update current speed (in m/s, convert to km/h)
        var speed = info.speed;
        if (speed != null) {
            _currentSpeed = speed.toFloat() * 3.6;
            if (_currentSpeed > _maxSpeed) {
                _maxSpeed = _currentSpeed;
            }
        }

        // Calculate distance from last position using haversine formula
        if (_lastPosition != null) {
            _distance += calculateDistance(_lastPosition, loc);
        }
        _lastPosition = loc;

        // Update elapsed time
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

        if (_statusLabel != null) {
            _statusLabel.setText(Rez.Strings.status_active);
        }
        updateDisplay();
    }

    // Stop the current session
    function stopSession() as Void {
        _sessionActive = false;
        if (_statusLabel != null) {
            _statusLabel.setText(Rez.Strings.status_stopped);
        }
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

        if (_statusLabel != null) {
            _statusLabel.setText(Rez.Strings.status_ready);
        }
        updateDisplay();
    }

    // Update the display with current session data
    private function updateDisplay() as Void {
        if (_speedLabel != null) {
            _speedLabel.setText(formatSpeed(_currentSpeed));
        }
        if (_maxSpeedLabel != null) {
            _maxSpeedLabel.setText(formatSpeed(_maxSpeed));
        }
        if (_distanceLabel != null) {
            _distanceLabel.setText(formatDistance(_distance));
        }
        if (_timeLabel != null) {
            _timeLabel.setText(formatTime(_elapsedTime));
        }
        WatchUi.requestUpdate();
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