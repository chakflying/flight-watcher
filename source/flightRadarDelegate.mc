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

  function onMenu() as Boolean {
    var menu = new Rez.Menus.ApiProviderMenu();
    WatchUi.pushView(menu, new FlightRadarMenuDelegate(menu), WatchUi.SLIDE_UP);
    return true;
  }

  function getAircrafts() as Void {
    var apiProvider = Application.Properties.getValue("apiProvider") as Number;
    switch (apiProvider) {
      case 0:
        getADSBExAPI();
        break;
      case 1:
        getFlightAwareApi();
        break;
      case 2:
        getOpenSkyAPI();
        break;
    }
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
      var adsbexApiKey =
        Application.Properties.getValue("adsbexApiKey") as String?;

      if (adsbexApiKey == null || adsbexApiKey.length() == 0) {
        showError("Error", "Please set ADSB-Exchange API key in Settings");
        return;
      }

      var url = Lang.format(
        "https://adsbexchange-com1.p.rapidapi.com/v2/lat/$1$/lon/$2$/dist/$3$/",
        [
          position.toDegrees()[0],
          position.toDegrees()[1],
          _viewRadius * 0.00053996,
        ]
      );

      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "X-RapidAPI-Key" => adsbexApiKey,
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
      } else if (responseCode == -402) {
        showError(responseCode.toString(), "Too many aircrafts");
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

  private function getFlightAwareApi() as Void {
    var position = _lastPosition.position;
    if (position != null) {
      var posMin = position.getProjectedLocation(3.926991, _viewRadius);
      var posMax = position.getProjectedLocation(0.7853982, _viewRadius);

      var apiKey =
        Application.Properties.getValue("flightAwareApiKey") as String?;

      if (apiKey == null || apiKey.length() == 0) {
        showError("Error", "Please set FlightAware API key in Settings");
        return;
      }

      var query = Lang.format("-latlong \"$1$ $2$ $3$ $4$%22\"", [
        posMin.toDegrees()[0],
        posMin.toDegrees()[1],
        posMax.toDegrees()[0],
        posMax.toDegrees()[1],
      ]);

      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "x-apikey" => apiKey,
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      };

      Communications.makeWebRequest(
        "https://aeroapi.flightaware.com/aeroapi/flights/search",
        {
          "query" => query,
        },
        options,
        method(:onGetFlightAwareApi)
      );
    }
  }

  function onGetFlightAwareApi(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Void {
    if (responseCode == 200) {
      if (data instanceof Dictionary) {
        var aircraftTracks = new Array<AircraftTrack>[data["flights"].size()];

        for (var i = 0; i < data["flights"].size(); i++) {
          var ac = data["flights"][i];

          var track = parseFlightAwareAircraft(ac);

          aircraftTracks[i] = track;
        }

        var tracksReport = new TracksReport(Time.now(), aircraftTracks);

        sendTracksReport(tracksReport);
      }
    } else {
      showError(responseCode.toString(), data);
    }
  }

  function parseFlightAwareAircraft(ac as Dictionary) as AircraftTrack {
    var track = new AircraftTrack();
    track.fromFlightAware(ac);
    return track;
  }

  private function getOpenSkyAPI() as Void {
    var position = _lastPosition.position;
    if (position != null) {
      var posMin = position.getProjectedLocation(3.926991, _viewRadius);
      var posMax = position.getProjectedLocation(0.7853982, _viewRadius);

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
        var aircraftTracks = new Array<AircraftTrack>[data["states"].size()];

        // System.println("Found " + data["states"].size() + " flights");
        // System.println(data);

        for (var i = 0; i < data["states"].size(); i++) {
          var ac = data["states"][i];

          var track = parseOpenskyAircraft(ac, data["time"]);

          aircraftTracks[i] = track;
        }

        var tracksReport = new TracksReport(
          new Time.Moment(data["time"]),
          aircraftTracks
        );

        sendTracksReport(tracksReport);
      }
    } else {
      showError(responseCode.toString(), data);
    }
  }

  function parseOpenskyAircraft(ac as Array, now as Number) as AircraftTrack {
    var track = new AircraftTrack();
    track.fromOpensky(ac, now);
    return track;
  }

  function showError(errCode as String, message as String) as Void {
    var errorView = new $.ErrorView(errCode, message);
    var errorViewDelegate = new $.ErrorViewDelegate();

    var currentView = WatchUi.getCurrentView();
    if (currentView[0] instanceof $.FlightRadarView) {
      WatchUi.pushView(errorView, errorViewDelegate, WatchUi.SLIDE_UP);
    }
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
