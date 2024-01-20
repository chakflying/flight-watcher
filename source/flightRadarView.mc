import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Timer;

class FlightRadarView extends WatchUi.View {
  private var _screenCenterPoint as Array<Number>;
  private var _systemSettings as System.DeviceSettings;
  private var _lastPosition as Info?;
  private var _lastTracksReport as TracksReport?;
  private var _refreshTimer as Timer.Timer?;
  private var _sensorTimer as Timer.Timer?;

  private var _filteredHeading as FilteredHeading;

  private var _spinnerState as Float;
  private var _loadingSpinnerState as Float;
  private var _drawnTracks as Array<Array<Numeric> >?;

  private var _viewRadius as Float;

  // Drawables
  private var _compassBgReference as BitmapReference?;
  private var _locationIconReference as BitmapReference?;

  function initialize(viewRadius as Float) {
    View.initialize();
    _systemSettings = System.getDeviceSettings();
    _screenCenterPoint =
      [_systemSettings.screenWidth / 2, _systemSettings.screenHeight / 2] as
      Array<Number>;

    // Init filtered heading
    var initHeading = 0.0;
    var info = Sensor.getInfo();
    if (info has :heading && info.heading != null) {
      initHeading = info.heading;
    }
    _filteredHeading = new FilteredHeading(initHeading);

    _spinnerState = 0.0;
    _loadingSpinnerState = 0.0;

    _viewRadius = viewRadius;
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    // setLayout(Rez.Layouts.MainLayout(dc));
    _compassBgReference =
      WatchUi.loadResource($.Rez.Drawables.compassBg) as BitmapReference;
    _locationIconReference =
      WatchUi.loadResource($.Rez.Drawables.locationIcon) as BitmapReference;
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    if (_refreshTimer == null) {
      _refreshTimer = new Timer.Timer();
    }
    _refreshTimer.start(method(:requestUpdate), 100, true);

    if (_sensorTimer == null) {
      _sensorTimer = new Timer.Timer();
    }
    _sensorTimer.start(method(:readSensor), 50, true);
  }

  function requestUpdate() as Void {
    WatchUi.requestUpdate();
  }

  function readSensor() as Void {
    var info = Sensor.getInfo();

    if (info has :heading && info.heading != null) {
      _filteredHeading.update(info.heading);
    }
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    // View.onUpdate(dc);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    drawLoadingSpinner(dc);

    drawRadarBorders(dc, _systemSettings.screenWidth);
    drawTracks(dc);

    drawUnit(dc);

    drawRadarSpinner(dc);

    drawCompass(dc);
  }

  function drawCompass(dc as Dc) {
    if (_compassBgReference != null) {
      var radius = _systemSettings.screenWidth.toFloat() / 2;
      var xform = new Graphics.AffineTransform();
      xform.translate(radius, radius);
      xform.rotate(-_filteredHeading.currentHeading);
      xform.translate(-radius, -radius);
      xform.scale(
        _systemSettings.screenWidth.toFloat() / 400.0,
        _systemSettings.screenWidth.toFloat() / 400.0
      );

      dc.drawBitmap2(0, 0, _compassBgReference, {
        :transform => xform,
      });
    }
  }

  function drawUnit(dc as Dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    dc.drawText(
      _screenCenterPoint[0],
      _systemSettings.screenHeight * 0.9,
      Graphics.FONT_XTINY,
      "10 nmi",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawRadarBorders(dc as Dc, width as Number) {
    dc.setAntiAlias(true);
    dc.setPenWidth(2);
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);

    dc.drawCircle(_screenCenterPoint[0], _screenCenterPoint[1], width / 2 - 2);
    dc.drawCircle(
      _screenCenterPoint[0],
      _screenCenterPoint[1],
      (width / 2 - 2) / 2
    );
    // dc.drawLine(2, _screenCenterPoint[1], width - 2, _screenCenterPoint[1]);
    // dc.drawLine(_screenCenterPoint[0], 2, _screenCenterPoint[1], width - 2);
  }

  function drawTracks(dc as Dc) as Void {
    if (_lastTracksReport != null && _lastPosition.position != null) {
      var now = Time.now();
      _drawnTracks = [];

      for (var i = 0; i < _lastTracksReport.tracks.size(); i++) {
        var track = _lastTracksReport.tracks[i];

        if (track.grounded) {
          continue;
        }

        var trackPosition = new Position.Location({
          :latitude => track.lat,
          :longitude => track.lon,
          :format => :degrees,
        });

        // Predict current position if ground speed is present
        if (track.groundSpeed != null && track.groundSpeed > 0) {
          var timeSinceReport = now.subtract(_lastTracksReport.timestamp);

          var projectedTravelDistance =
            track.groundSpeed *
            0.51444 *
            (timeSinceReport.value() + track.lastUpdate);

          var extrapolatedPosition = trackPosition.getProjectedLocation(
            (track.track * Math.PI) / 180.0,
            projectedTravelDistance
          );

          trackPosition = extrapolatedPosition;
        }

        var point = getAEPCoordinates(_lastPosition.position, trackPosition);

        // Point distance normalized to 0 - 1 by a fixed maximum range
        var pointNormalized =
          [point[0] / _viewRadius, (point[1] / _viewRadius) * -1.0] as
          Array<Numeric>;

        var distanceFromCenter = Math.sqrt(
          pointNormalized[0] * pointNormalized[0] +
            pointNormalized[1] * pointNormalized[1]
        );

        if (distanceFromCenter > 0.95) {
          continue;
        }

        var pointNormRotated = rotatePoint(
          pointNormalized,
          -_filteredHeading.currentHeading
        );

        var pointScreenCoord =
          [
            _screenCenterPoint[0] +
              (pointNormRotated[0] * _systemSettings.screenWidth.toFloat()) /
                2.0,
            _screenCenterPoint[1] +
              (pointNormRotated[1] * _systemSettings.screenWidth.toFloat()) /
                2.0,
          ] as Array<Numeric>;

        _drawnTracks.add([pointScreenCoord[0], pointScreenCoord[1], i]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(pointScreenCoord[0], pointScreenCoord[1], _systemSettings.screenWidth.toFloat() * 0.023);

        if (track.altitude != null) {
          dc.drawText(
            pointScreenCoord[0],
            pointScreenCoord[1] + _systemSettings.screenHeight.toFloat() * 0.08,
            Graphics.FONT_XTINY,
            (track.altitude / 100).toNumber().toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
          );
        }

        if (track.track != null) {
          drawTrackFromPoint(
            dc,
            pointScreenCoord,
            track.track,
            _filteredHeading.currentHeading
          );
        }
      }
    }
  }

  function drawLoadingSpinner(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.setPenWidth(6);

    if (_lastPosition == null || _lastPosition.position == null) {
      var xform = new Graphics.AffineTransform();
      xform.translate(
        (_locationIconReference.getWidth().toFloat() * -1) / 2,
        (_locationIconReference.getHeight().toFloat() * -1) / 2
      );
      dc.drawBitmap2(
        _screenCenterPoint[0],
        _screenCenterPoint[1],
        _locationIconReference,
        {
          :transform => xform,
        }
      );
    }

    if (_lastTracksReport == null) {
      var startPos = (_loadingSpinnerState * 180.0) / Math.PI;
      var endPos =
        (_loadingSpinnerState * 180.0) / Math.PI +
        180.0 +
        Math.sin(_loadingSpinnerState / 2.0) * 90.0;

      if (startPos > 360.0) {
        startPos = startPos - 360.0;
      }
      if (endPos > 360.0) {
        endPos = endPos - 360.0;
      }

      dc.drawArc(
        _screenCenterPoint[0],
        _screenCenterPoint[1],
        35,
        Graphics.ARC_CLOCKWISE,
        startPos,
        endPos
      );

      _loadingSpinnerState = _loadingSpinnerState + (Math.PI * 2.0) / 10.0;
    }
  }

  function drawRadarSpinner(dc as Dc) as Void {
    if (_lastTracksReport == null) {
      return;
    }

    var radius = _systemSettings.screenWidth / 2 - 6;

    dc.setPenWidth(4);
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);

    var endPoint = rotatePoint(
      [0.0, -1.0],
      _spinnerState - 0.06 - _filteredHeading.currentHeading
    );

    dc.drawLine(
      _screenCenterPoint[0],
      _screenCenterPoint[1],
      _screenCenterPoint[0] + endPoint[0] * radius,
      _screenCenterPoint[1] + endPoint[1] * radius
    );

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);

    endPoint = rotatePoint(
      [0.0, -1.0],
      _spinnerState - 0.03 - _filteredHeading.currentHeading
    );

    dc.drawLine(
      _screenCenterPoint[0],
      _screenCenterPoint[1],
      _screenCenterPoint[0] + endPoint[0] * radius,
      _screenCenterPoint[1] + endPoint[1] * radius
    );

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    endPoint = rotatePoint(
      [0.0, -1.0],
      _spinnerState - _filteredHeading.currentHeading
    );

    dc.drawLine(
      _screenCenterPoint[0],
      _screenCenterPoint[1],
      _screenCenterPoint[0] + endPoint[0] * radius,
      _screenCenterPoint[1] + endPoint[1] * radius
    );

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.fillCircle(_screenCenterPoint[0], _screenCenterPoint[1], 4);

    _spinnerState = _spinnerState + (Math.PI * 2.0) / 100.0;
    if (_spinnerState > 2.0 * Math.PI) {
      _spinnerState = _spinnerState - 2.0 * Math.PI;
    }
  }

  function drawTrackFromPoint(
    dc as Dc,
    point as Array<Numeric>,
    track as Numeric,
    heading as Numeric
  ) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.setPenWidth(2);

    var trackRad = (track * Math.PI) / 180.0;
    var trackRadRotated = trackRad - heading;

    var cos = Math.cos(trackRadRotated + Math.PI);
    var sin = Math.sin(trackRadRotated);

    var x = sin;
    var y = cos;

    var lineLength = _systemSettings.screenWidth.toFloat() * 0.07;

    dc.drawLine(
      point[0],
      point[1],
      point[0] + x * lineLength,
      point[1] + y * lineLength
    );
    // dc.drawText(
    //       point[0] + x * 12,
    //       point[1] + y * 12,
    //       Graphics.FONT_XTINY,
    //       track.toString(),
    //       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    //     );
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
    if (_refreshTimer != null) {
      _refreshTimer.stop();
    }
    if (_sensorTimer != null) {
      _sensorTimer.stop();
    }
  }

  function getAEPCoordinates(
    center as Position.Location,
    target as Position.Location
  ) as Array<Numeric> {
    var radius_earth = 6371000.0;
    var centerRads = center.toRadians();
    var targetRads = target.toRadians();

    var cos_c =
      Math.sin(centerRads[0]) * Math.sin(targetRads[0]) +
      Math.cos(centerRads[0]) *
        Math.cos(targetRads[0]) *
        Math.cos(targetRads[1] - centerRads[1]);
    var c = Math.acos(cos_c);
    var k = c / Math.sin(c);

    var x =
      radius_earth *
      k *
      Math.cos(targetRads[0]) *
      Math.sin(targetRads[1] - centerRads[1]);
    var y =
      radius_earth *
      k *
      (Math.cos(centerRads[0]) * Math.sin(targetRads[0]) -
        Math.sin(centerRads[0]) *
          Math.cos(targetRads[0]) *
          Math.cos(targetRads[1] - centerRads[1]));

    return [x, y];
  }

  public function setPosition(info as Position.Info) as Void {
    _lastPosition = info;
  }

  public function updateTracksReport(tracksReport as TracksReport) as Void {
    _lastTracksReport = tracksReport;
  }

  public function onTap(x as Number, y as Number) as Void {
    // System.println("Tapped: " + x + ", " + y);
    // System.println("Drawn tracks: " + _drawnTracks.size());

    var showDetailsIDs = [];

    for (var i = 0; i < _drawnTracks.size(); i++) {
      var distance =
        (x - _drawnTracks[i][0]) * (x - _drawnTracks[i][0]) +
        (y - _drawnTracks[i][1]) * (y - _drawnTracks[i][1]);
      if (distance < 800) {
        // System.println("Tapped on drawn track " + _drawnTracks[i][2]);
        showDetailsIDs.add(_drawnTracks[i][2]);
      }
    }

    if (showDetailsIDs.size() > 0) {
      launchDetailsViews(showDetailsIDs);
    }
  }

  function launchDetailsViews(showDetailsIDs as Array<Number>) as Void {
    var factory = new $.FlightDetailsFactory(_lastTracksReport, showDetailsIDs);
    var viewLoop = new WatchUi.ViewLoop(factory, {
      :page => 0,
      :wrap => true,
      :color => Graphics.COLOR_BLACK,
    });
    WatchUi.pushView(
      viewLoop,
      new $.FlightDetailsFactoryDelegate(viewLoop),
      WatchUi.SLIDE_UP
    );
  }

  private function rotatePoint(
    point as Array<Numeric>,
    angle as Float
  ) as Array<Float> {
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);

    // Transform the coordinates
    var x = point[0] * cos - point[1] * sin;
    var y = point[0] * sin + point[1] * cos;

    var result = [x, y] as Array<Float>;

    return result;
  }
}
