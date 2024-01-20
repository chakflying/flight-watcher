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
      :justification => Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
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
          _message = "BLE Error";
          break;
        case "-2":
          _message = "BLE Timeout from host";
          break;
        case "-3":
          _message = "BLE Timeout from server";
          break;
        case "-4":
          _message = "BLE No data in response";
          break;
        case "-5":
          _message = "BLE Request Cancelled";
          break;
        case "-101":
          _message = "BLE Too many requests";
          break;
        case "-102":
          _message = "BLE Response too large";
          break;
        case "-103":
          _message = "BLE Send Failed";
          break;
        case "-104":
          _message = "BLE No Connection";
          break;
        case "-200":
          _message = "Request invalid HTTP headers";
          break;
        case "-201":
          _message = "Request invalid HTTP body";
          break;
        case "-202":
          _message = "Request invalid HTTP method";
          break;
        case "-300":
          _message = "Request timeout";
          break;
        case "-400":
          _message = "Response invalid body";
          break;
        case "-401":
          _message = "Response invalid HTTP headers";
          break;
        case "-402":
          _message = "Response too large";
          break;
        case "-403":
          _message = "Response out of memory";
          break;
        case "-1000":
          _message = "Storage Full";
          break;
        case "-1001":
          _message = "HTTPS required";
          break;
        case "-1002":
          _message = "Unsupported content type";
          break;
        case "-1003":
          _message = "Request cancelled by system";
          break;
        case "-1004":
          _message = "Connection dropped";
          break;
        case "-1005":
          _message = "Unable to process media";
          break;
        case "-1006":
          _message = "Unable to process image";
          break;
        case "-1007":
          _message = "Unable to process HLS";
          break;
        default:
          _message = "Unknown Error";
          break;
      }
    }
  }
}
