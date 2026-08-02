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

}