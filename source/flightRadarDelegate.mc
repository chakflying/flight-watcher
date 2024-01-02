import Toybox.Attention;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Communications;
import Toybox.Timer;
import Toybox.Application;
import Toybox.WatchUi;

class FlightRadarDelegate extends WatchUi.BehaviorDelegate {
  private var _lastPosition as Position.Info;
  private var _updateTracksReport as
  (Method(tracksReport as TracksReport) as Void);
  private var _onTap as (Method(x as Number, y as Number) as Void);
  private var _viewRadius as Float;
  private var _getTracksTimer as Timer.Timer?;

  function initialize(
    viewRadius as Float,
    updateTracksReport as (Method(tracksReport as TracksReport) as Void),
    onTap as (Method(x as Number, y as Number) as Void)
  ) {
    BehaviorDelegate.initialize();
    _lastPosition = new Position.Info();
    _updateTracksReport = updateTracksReport;
    _onTap = onTap;
    _viewRadius = viewRadius;

    getAircrafts();

    _getTracksTimer = new Timer.Timer();
    _getTracksTimer.start(method(:getAircrafts), 10000, true);
  }

  // function onMenu() as Boolean {
  //   WatchUi.pushView(
  //     new Rez.Menus.MainMenu(),
  //     new FlightRadarMenuDelegate(),
  //     WatchUi.SLIDE_UP
  //   );
  //   return true;
  // }

  function getAircrafts() as Void {
    getADSBExAPI();
    // getOpenSkyAPI();
    // getAircraftsTest();
  }

  // function onSelect() as Boolean {
  //   getAircraftsTest();
  //   return true;
  // }

  function onTap(clickEvent as ClickEvent) as Boolean {
    if (clickEvent.getType() == WatchUi.CLICK_TYPE_TAP) {
      var coordinates = clickEvent.getCoordinates();
      _onTap.invoke(coordinates[0], coordinates[1]);
    }
    return true;
  }

  function getAircraftsTest() as Void {
    var data = Application.loadResource($.Rez.JsonData.testResponse);

    var aircraftTracks = new Array<AircraftTrack>[data["ac"].size()];

    for (var i = 0; i < data["ac"].size(); i++) {
      var ac = data["ac"][i];

      var track = parseADSBExAircraft(ac);

      aircraftTracks[i] = track;
    }

    var tracksReport = new TracksReport(
      new Time.Moment(data["now"]),
      aircraftTracks
    );

    sendTracksReport(tracksReport);
  }

  private function getADSBExAPI() as Void {
    var position = _lastPosition.position;
    if (position != null) {
      var url = Lang.format(
        "https://adsbexchange-com1.p.rapidapi.com/v2/lat/$1$/lon/$2$/dist/$3$/",
        [position.toDegrees()[0], position.toDegrees()[1], _viewRadius / 1000]
      );

      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "X-RapidAPI-Key" => Application.Properties.getValue("adsbexApiKey") as
          String,
          "X-RapidAPI-Host" => "adsbexchange-com1.p.rapidapi.com",
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      };
      Communications.makeWebRequest(url, {}, options, method(:onGetADSBExAPI));
    }
  }

  function onGetADSBExAPI(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Void {
    if (responseCode == 200) {
      if (data instanceof Dictionary) {
        // System.println(data);

        var aircraftTracks = new Array<AircraftTrack>[data["ac"].size()];

        for (var i = 0; i < data["ac"].size(); i++) {
          var ac = data["ac"][i];

          var track = parseADSBExAircraft(ac);

          aircraftTracks[i] = track;
        }

        var tracksReport = new TracksReport(
          new Time.Moment(data["now"] / 1000),
          aircraftTracks
        );

        sendTracksReport(tracksReport);
      }
    } else {
      if (data instanceof Dictionary && data["message"] != null) {
        showError(responseCode.toString(), data["message"]);
      } else {
        showError(responseCode.toString(), data);
      }
    }
  }

  function parseADSBExAircraft(ac as Dictionary) as AircraftTrack {
    var track = new AircraftTrack();
    track.fromADSBx(ac);
    return track;
  }

  private function getOpenSkyAPI() as Void {
    var position = _lastPosition.position;
    if (position != null) {
      var posMin = position.getProjectedLocation(3.926991, 5000);
      var posMax = position.getProjectedLocation(0.7853982, 5000);

      Communications.makeWebRequest(
        "https://opensky-network.org/api/states/all",
        {
          "extended" => 1,
          "lamin" => posMin.toDegrees()[0],
          "lomin" => posMin.toDegrees()[1],
          "lamax" => posMax.toDegrees()[0],
          "lomax" => posMax.toDegrees()[1],
        },
        {
          :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        },
        method(:onGetOpenSkyAPI)
      );
    }
  }

  function onGetOpenSkyAPI(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Void {
    if (responseCode == 200) {
      if (data instanceof Dictionary) {
        // System.println(data);
      }
    } else {
      showError(responseCode.toString(), data);
    }
  }

  function showError(errCode as String, message as String) as Void {
    var errorView = new $.ErrorView(errCode, message);
    var errorViewDelegate = new $.ErrorViewDelegate();

    var currentView = WatchUi.getCurrentView();
    if (currentView[0] instanceof $.ErrorView) {
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    WatchUi.pushView(errorView, errorViewDelegate, WatchUi.SLIDE_UP);
  }

  private function sendTracksReport(tracksReport as TracksReport) as Void {
    _updateTracksReport.invoke(tracksReport);
  }

  public function setPosition(info as Info) as Void {
    if (_lastPosition.position == null && info.position != null) {
      if (Attention has :vibrate) {
        var vibeData = [new Attention.VibeProfile(50, 500)];
        Attention.vibrate(vibeData);
      }
    }
    _lastPosition = info;
  }
}
