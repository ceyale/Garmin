import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Sensor;
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
        // Enable position and sensor updates
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        Sensor.setEnabledSensors(Sensor.SENSOR_ACCELEROMETER);
        Sensor.enableSensorEvents(method(:onSensor));

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
        Position.enableLocationEvents(Position.LOCATION_OFF, method(:onPosition));
        Sensor.setEnabledSensors(Sensor.SENSOR_OFF);
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

        // Calculate distance from last position
        if (_lastPosition != null) {
            var distance = _lastPosition.distanceTo(loc);
            if (distance != null) {
                _distance += distance.toFloat() / 1000.0; // meters to km
            }
        }
        _lastPosition = loc;

        // Update elapsed time
        var now = Time.now();
        if (_startTime != null) {
            _elapsedTime = now.subtract(_startTime).value().toFloat();
        }

        updateDisplay();
    }

    // Sensor callback - for future use (e.g., accelerometer data)
    function onSensor(sensorInfo as Sensor.Info) as Void {
        // Reserved for future sensor features
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