import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class windsurfMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof windsurfView) {
            var windsurfViewObj = view[0] as windsurfView;
            if (item == :item_start) {
                windsurfViewObj.startSession();
            } else if (item == :item_stop) {
                windsurfViewObj.stopSession();
            } else if (item == :item_reset) {
                windsurfViewObj.resetSession();
            }
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}