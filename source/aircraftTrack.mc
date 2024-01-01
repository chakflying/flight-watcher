import Toybox.Lang;

class AircraftTrack {
  // position in latitude
  public var lat as Numeric;

  // position in longitude
  public var lon as Numeric;

  // altitude in feet
  public var altitude as Numeric;

  // ground speed in knots
  public var groundSpeed as Numeric;

  // true air speed in knots
  public var tas as Numeric;

  // true track over ground in degrees
  public var track as Numeric?;

  // aircraft type pulled from database
  public var type as String?;

  // flight number
  public var flight as String?;

  // aircraft registration
  public var registration as String?;

  //  true if the aircraft is on the ground
  public var grounded as Boolean = false;

  public var squawk as String?;

  // Emitter Category
  public var category as String?;

  //  how long ago (in seconds before “now”) the position was last updated
  public var lastUpdate as Numeric;

  public function initialize() {
    self.lat = 0.0;
    self.lon = 0.0;
    self.altitude = 0;
    self.groundSpeed = 0;
    self.tas = 0;
    self.track = 0;
    self.type = "";
    self.grounded = true;
    self.lastUpdate = 0.0;
    self.flight = "";
    self.squawk = "";
    self.category = "";
    self.registration = "";
  }

  public function fromADSBx(ac as Dictionary) as Void {
    var altitude = ac["alt_geom"];
    // if (ac["alt_baro"] instanceof Number) {
    //   altitude = ac["alt_baro"];
    // }

    var grounded = false;
    if (ac["alt_baro"] instanceof String) {
      grounded = true;
    }

    if (ac["category"] instanceof String) {
      self.category = ac["category"];
    }

    if (ac["squawk"] instanceof String) {
      self.squawk = ac["squawk"];
    }

    var heading = ac["track"];

    self.lat = ac["lat"];
    self.lon = ac["lon"];
    self.altitude = altitude;
    self.groundSpeed = ac["gs"];
    self.tas = ac["tas"];
    self.track = heading;
    self.type = ac["t"];
    self.grounded = grounded;
    self.lastUpdate = ac["seen_pos"];
    self.flight = ac["flight"];
    self.registration = ac["r"];
  }
}
