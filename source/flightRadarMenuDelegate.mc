import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Unused
class FlightRadarMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize(menu as Menu2) {
    Menu2InputDelegate.initialize();

    menu.setFocus(Application.Properties.getValue("apiProvider") as Number);
  }

  function onSelect(item as MenuItem) as Void {
    var id = item.getId();
    if (id == :adsbex) {
      Application.Properties.setValue("apiProvider", 0);
    } else if (id == :flightAware) {
      Application.Properties.setValue("apiProvider", 1);
    } else if (id == :opensky) {
      Application.Properties.setValue("apiProvider", 2);
    }

    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
