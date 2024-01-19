import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;

class FlightRadarApp extends Application.AppBase {
  private var _radarView as FlightRadarView;
  private var _radarDelegate as FlightRadarDelegate;

  private var _viewRadius as Float;

  function initialize() {
    AppBase.initialize();

    _viewRadius = 18520.0;

    _radarView = new FlightRadarView(_viewRadius);
    _radarDelegate = new FlightRadarDelegate(
      _viewRadius,
      _radarView.method(:updateTracksReport),
      _radarView.method(:onTap)
    );
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    var options = {
      :acquisitionType => Position.LOCATION_CONTINUOUS,
    };

    if (Position has :POSITIONING_MODE_AVIATION) {
      options[:mode] = Position.POSITIONING_MODE_AVIATION;
    }

    if (Position has :hasConfigurationSupport) {
      if (
        Position has :CONFIGURATION_SAT_IQ &&
        Position.hasConfigurationSupport(Position.CONFIGURATION_SAT_IQ)
      ) {
        options[:configuration] = Position.CONFIGURATION_SAT_IQ;
      } else if (
        Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5 &&
        Position.hasConfigurationSupport(
          Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5
        )
      ) {
        options[:configuration] =
          Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
      } else if (
        Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1 &&
        Position.hasConfigurationSupport(
          Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1
        )
      ) {
        options[:configuration] =
          Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1;
      } else if (
        Position has :CONFIGURATION_GPS &&
        Position.hasConfigurationSupport(Position.CONFIGURATION_GPS)
      ) {
        options[:configuration] = Position.CONFIGURATION_GPS;
      }
    } else {
      options = Position.LOCATION_CONTINUOUS;
    }

    Position.enableLocationEvents(options, method(:onPosition));

    // setTestLocation();
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    Position.enableLocationEvents(
      Position.LOCATION_DISABLE,
      method(:onPosition)
    );
  }

  function setTestLocation() as Void {
    //  Set testing location
    var info = new Position.Info();
    info.heading = 0.0;
    info.position = new Position.Location({
      // :latitude => 25.96,
      // :longitude => -80.15,
      :latitude => 22.318,
      :longitude => 113.939,
      :format => :degrees,
    });

    _radarView.setPosition(info);
    _radarDelegate.setPosition(info);
  }

  //! Update the current position
  //! @param info Position information
  public function onPosition(info as Info) as Void {
    // System.println("Got position update");
    _radarView.setPosition(info);
    _radarDelegate.setPosition(info);
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    return [_radarView, _radarDelegate] as Array<Views or InputDelegates>;
  }
}

function getApp() as FlightRadarApp {
  return Application.getApp() as FlightRadarApp;
}
