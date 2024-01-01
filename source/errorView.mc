import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ErrorView extends WatchUi.View {
  private var _errCode as String;
  private var _message as String;

  private var _screenCenterPoint as Array<Number>;
  private var _systemSettings as System.DeviceSettings;

  function initialize(errCode as String, message as String) {
    View.initialize();

    _errCode = errCode;
    _message = message;

    _systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [_systemSettings.screenWidth / 2, _systemSettings.screenHeight / 2] as
      Array<Number>;
  }

  function onLayout(dc as Dc) as Void {}

  function onShow() as Void {}

  function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    dc.drawText(
      _screenCenterPoint[0],
      _systemSettings.screenWidth * 0.2,
      Graphics.FONT_SMALL,
      _errCode,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    var textArea = new WatchUi.TextArea({
      :text => _message,
      :color => Graphics.COLOR_WHITE,
      :font => [Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY],
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => _systemSettings.screenWidth * 0.3,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
      :width => _systemSettings.screenWidth * 0.8,
      :height => _systemSettings.screenWidth * 0.6,
    });

    textArea.draw(dc);
  }
}
