import Toybox.Lang;
import Toybox.WatchUi;

class windsurfDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new windsurfMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Start button on the watch
    function onSelect() as Boolean {
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof windsurfView) {
            var windsurfViewObj = view[0] as windsurfView;
            windsurfViewObj.startSession();
        }
        return true;
    }

    // Back button to stop the session
    function onBack() as Boolean {
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof windsurfView) {
            var windsurfViewObj = view[0] as windsurfView;
            windsurfViewObj.stopSession();
        }
        return true;
    }

}