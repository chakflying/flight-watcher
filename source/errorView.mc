import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ErrorView extends WatchUi.View {
  private var _errCode as String;
  private var _message as String?;

  private var _screenCenterPoint as Array<Number>;
  private var _systemSettings as System.DeviceSettings;

  function initialize(errCode as String, message as String?) {
    View.initialize();

    _errCode = errCode;
    _message = message;

    showBuiltinErrorMessage();

    _systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [_systemSettings.screenWidth / 2, _systemSettings.screenHeight / 2] as
      Array<Number>;
  }

  function onLayout(dc as Dc) as Void {}

  function onShow() as Void {}

  function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
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
      :justification => Graphics.TEXT_JUSTIFY_CENTER |
      Graphics.TEXT_JUSTIFY_VCENTER,
      :width => _systemSettings.screenWidth * 0.8,
      :height => _systemSettings.screenWidth * 0.5,
    });

    textArea.draw(dc);
  }

  function showBuiltinErrorMessage() as Void {
    if (
      _message == null ||
      (_message instanceof String && (_message == "" || _message.length == 0))
    ) {
      switch (_errCode) {
        case "-1":
          _message = WatchUi.loadResource($.Rez.Strings.error_1) as String;
          break;
        case "-2":
          _message = WatchUi.loadResource($.Rez.Strings.error_2) as String;
          break;
        case "-3":
          _message = WatchUi.loadResource($.Rez.Strings.error_3) as String;
          break;
        case "-4":
          _message = WatchUi.loadResource($.Rez.Strings.error_4) as String;
          break;
        case "-5":
          _message = WatchUi.loadResource($.Rez.Strings.error_5) as String;
          break;
        case "-101":
          _message = WatchUi.loadResource($.Rez.Strings.error_101) as String;
          break;
        case "-102":
          _message = WatchUi.loadResource($.Rez.Strings.error_102) as String;
          break;
        case "-103":
          _message = WatchUi.loadResource($.Rez.Strings.error_103) as String;
          break;
        case "-104":
          _message = WatchUi.loadResource($.Rez.Strings.error_104) as String;
          break;
        case "-200":
          _message = WatchUi.loadResource($.Rez.Strings.error_200) as String;
          break;
        case "-201":
          _message = WatchUi.loadResource($.Rez.Strings.error_201) as String;
          break;
        case "-202":
          _message = WatchUi.loadResource($.Rez.Strings.error_202) as String;
          break;
        case "-300":
          _message = WatchUi.loadResource($.Rez.Strings.error_300) as String;
          break;
        case "-400":
          _message = WatchUi.loadResource($.Rez.Strings.error_400) as String;
          break;
        case "-401":
          _message = WatchUi.loadResource($.Rez.Strings.error_401) as String;
          break;
        case "-402":
          _message = WatchUi.loadResource($.Rez.Strings.error_402) as String;
          break;
        case "-403":
          _message = WatchUi.loadResource($.Rez.Strings.error_403) as String;
          break;
        case "-1000":
          _message = WatchUi.loadResource($.Rez.Strings.error_1000) as String;
          break;
        case "-1001":
          _message = WatchUi.loadResource($.Rez.Strings.error_1001) as String;
          break;
        case "-1002":
          _message = WatchUi.loadResource($.Rez.Strings.error_1002) as String;
          break;
        case "-1003":
          _message = WatchUi.loadResource($.Rez.Strings.error_1003) as String;
          break;
        case "-1004":
          _message = WatchUi.loadResource($.Rez.Strings.error_1004) as String;
          break;
        case "-1005":
          _message = WatchUi.loadResource($.Rez.Strings.error_1005) as String;
          break;
        case "-1006":
          _message = WatchUi.loadResource($.Rez.Strings.error_1006) as String;
          break;
        case "-1007":
          _message = WatchUi.loadResource($.Rez.Strings.error_1007) as String;
          break;
        default:
          _message = WatchUi.loadResource($.Rez.Strings.error_unk) as String;
          break;
      }
    }
  }
}
