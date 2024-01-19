import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class FlightDetailsView extends WatchUi.View {
  private var _lastTracksReport as TracksReport?;
  private var _id as Number;

  private var _screenCenterPoint as Array<Number>;
  private var _systemSettings as System.DeviceSettings;

  private var _track as AircraftTrack?;

  private var _aircraftDiagram as BitmapReference?;

  public function initialize(lastTracksReport as TracksReport, id as Number) {
    View.initialize();

    _lastTracksReport = lastTracksReport;
    _id = id;
    _track = _lastTracksReport.tracks[_id];

    _systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [_systemSettings.screenWidth / 2, _systemSettings.screenHeight / 2] as
      Array<Number>;
  }

  function onLayout(dc as Dc) as Void {
    // setLayout(Rez.Layouts.MainLayout(dc));
    if (_track.type == null) {
      return;
    }

    switch (_track.type) {
      case "B772":
      case "B773":
      case "B778":
      case "B779":
      case "B77L":
      case "B77W":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_777) as BitmapReference;
        break;
      case "B741":
      case "B742":
      case "B743":
      case "B744":
      case "B748":
      case "B74R":
      case "B74S":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_747) as BitmapReference;
        break;
      case "A318":
      case "A319":
      case "A320":
      case "A321":
      case "A19N":
      case "A20N":
      case "A21N":
      case "B731":
      case "B732":
      case "B733":
      case "B734":
      case "B735":
      case "B736":
      case "B737":
      case "B738":
      case "B739":
      case "B37M":
      case "B38M":
      case "B39M":
      case "B3XM":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_737) as BitmapReference;
        break;
      case "B762":
      case "B763":
      case "B764":
      case "B788":
      case "B789":
      case "B78X":
      case "A332":
      case "A333":
      case "A337":
      case "A338":
      case "A339":
      case "A359":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_787_a330) as BitmapReference;
        break;
      case "A342":
      case "A343":
      case "A345":
      case "A346":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_a340) as BitmapReference;
        break;
      case "A388":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_a380) as BitmapReference;
        break;
      case "AS32":
      case "AS50":
      case "B06":
      case "B06T":
      case "B105":
      case "B212":
      case "B412":
      case "B429":
      case "EC20":
      case "EC25":
      case "EC30":
      case "EC35":
      case "EC45":
      case "EC55":
      case "EC75":
      case "S61":
      case "S65C":
      case "R44":
      case "R22":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_heli) as BitmapReference;
        break;
      case "F900":
      case "FA50":
      case "FA7X":
      case "ASTR":
      case "G150":
      case "G250":
      case "G280":
      case "GA5C":
      case "GA6C":
      case "GALX":
      case "GL5T":
      case "GLEX":
      case "GLF4":
      case "GLF5":
      case "GLF6":
      case "H25B":
      case "H25C":
      case "LJ35":
      case "LJ60":
      case "S601":
      case "C550":
      case "C560":
      case "C56X":
      case "C650":
      case "C680":
      case "C68A":
      case "C700":
      case "C750":
      case "CL30":
      case "CL35":
      case "CL60":
      case "CRJ2":
      case "CRJ7":
      case "CRJ9":
      case "E50P":
      case "E55P":
      case "E545":
      case "E550":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_biz_jet) as BitmapReference;
        break;
      case "E135":
      case "E145":
      case "E170":
      case "E190":
      case "E195":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_embraer) as BitmapReference;
        break;
      case "PA31":
      case "PA34":
      case "PA44":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_piper) as BitmapReference;
        break;
      case "P28A":
      case "SR20":
      case "SR22":
        _aircraftDiagram =
          WatchUi.loadResource($.Rez.Drawables.a_light) as BitmapReference;
        break;
    }

    if (_aircraftDiagram == null) {
      // Fallback using the emitter category
      switch (_track.category) {
        case "A1":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_light) as BitmapReference;
          break;
        case "A2":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_piper) as BitmapReference;
          break;
        case "A3":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_737) as BitmapReference;
          break;
        case "A4":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_a340) as BitmapReference;
          break;
        case "A5":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_a380) as BitmapReference;
          break;
        case "A6":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_fighter) as BitmapReference;
          break;
        case "A7":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_heli) as BitmapReference;
          break;
        case "B1":
          _aircraftDiagram =
            WatchUi.loadResource($.Rez.Drawables.a_light) as BitmapReference;
          break;
      }
    }
  }

  function onShow() as Void {}

  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    // View.onUpdate(dc);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    drawBorders(dc);
    drawType(dc);
    drawFlight(dc);
    drawAlt(dc);
    drawSpeed(dc);

    drawTrack(dc);
    drawCategory(dc);
    drawSquawk(dc);

    drawAircraft(dc);
  }

  function drawType(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var type = _track.type;
    if (type != null) {
      dc.drawText(
        _screenCenterPoint[0] + _systemSettings.screenHeight * 0.04,
        _systemSettings.screenHeight * 0.635,
        Graphics.FONT_SMALL,
        type,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawFlight(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var flight = _track.flight;
    if (flight != null) {
      flight = trim(flight);
      dc.drawText(
        _screenCenterPoint[0] - _systemSettings.screenHeight * 0.04,
        _systemSettings.screenHeight * 0.635,
        Graphics.FONT_SMALL,
        flight,
        Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawAlt(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var alt = _track.altitude.toNumber().toString();

    dc.drawText(
      _screenCenterPoint[0] - _systemSettings.screenHeight * 0.04,
      _systemSettings.screenHeight * 0.82,
      Graphics.FONT_TINY,
      alt + " ft",
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.drawText(
      _screenCenterPoint[0] - _systemSettings.screenHeight * 0.04,
      _systemSettings.screenHeight * 0.9,
      Graphics.FONT_XTINY,
      "ALT",
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawSpeed(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    if (_track.groundSpeed != null) {
      var speed = "";
      if (
        _track.groundSpeed instanceof Float ||
        _track.groundSpeed instanceof Double
      ) {
        speed = _track.groundSpeed.toNumber().toString();
      } else if (_track.groundSpeed instanceof Number) {
        speed = _track.groundSpeed.toString();
      }
      dc.drawText(
        _screenCenterPoint[0] + _systemSettings.screenHeight * 0.04,
        _systemSettings.screenHeight * 0.82,
        Graphics.FONT_TINY,
        speed + " kt",
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );

      dc.drawText(
        _screenCenterPoint[0] + _systemSettings.screenHeight * 0.04,
        _systemSettings.screenHeight * 0.9,
        Graphics.FONT_XTINY,
        "GS",
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawTrack(dc as Dc) as Void {
    if (_track.track != null) {
      var track = _track.track.toNumber().toString();

      dc.drawText(
        _systemSettings.screenWidth - 15,
        _screenCenterPoint[1] - _systemSettings.screenHeight * 0.04,
        Graphics.FONT_XTINY,
        "trk: " + track + "°",
        Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawCategory(dc as Dc) as Void {
    if (_track.category != null && _track.category.length() > 0) {
      dc.drawText(
        15,
        _screenCenterPoint[1] - _systemSettings.screenHeight * 0.04,
        Graphics.FONT_XTINY,
        "cat: " + _track.category,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawSquawk(dc as Dc) as Void {
    if (_track.squawk != null && _track.squawk.length() > 0) {
      dc.drawText(
        _screenCenterPoint[0],
        _screenCenterPoint[1] - _systemSettings.screenHeight * 0.04,
        Graphics.FONT_XTINY,
        "sqwk: " + _track.squawk,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawAircraft(dc as Dc) as Void {
    if (_aircraftDiagram != null) {
      var dispScale =
        (_systemSettings.screenWidth.toFloat() / 2 - 60) /
        _aircraftDiagram.getWidth().toFloat();
      var xform = new Graphics.AffineTransform();
      xform.scale(dispScale, dispScale);
      xform.rotate((90 * Math.PI) / 180);
      xform.translate(
        (_aircraftDiagram.getWidth().toFloat() / 2) * -1,
        (_aircraftDiagram.getHeight().toFloat() / 2) * -1
      );
      dc.drawBitmap2(
        _screenCenterPoint[0],
        _screenCenterPoint[1] - _systemSettings.screenHeight / 4 - 5,
        _aircraftDiagram,
        {
          :transform => xform,
          :filterMode => Graphics.FILTER_MODE_BILINEAR,
        }
      );
    }
  }

  function trim(string as String) as String {
    var loc = string.find(" ");
    if (loc != null) {
      return string.substring(0, loc);
    } else {
      return string;
    }
  }

  function drawBorders(dc as Dc) as Void {
    dc.setAntiAlias(true);
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);

    var y = _systemSettings.screenHeight * 0.54;
    dc.drawLine(
      _screenCenterPoint[0],
      y,
      _screenCenterPoint[0],
      _systemSettings.screenWidth - 16
    );
    var width = (_systemSettings.screenWidth * 4) / 5;
    dc.drawLine(
      _screenCenterPoint[0] - width,
      y,
      _screenCenterPoint[0] + width,
      y
    );

    y = _systemSettings.screenHeight * 0.73;
    width = _systemSettings.screenWidth / 2;
    dc.drawLine(
      _screenCenterPoint[0] - width,
      y,
      _screenCenterPoint[0] + width,
      y
    );
  }

  function onHide() as Void {}
}
