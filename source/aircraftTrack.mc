import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.Time;

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

  public function fromFlightAware(ac as Dictionary) as Void {
    self.grounded = false;
    self.flight = ac["ident"];
    self.type = ac["aircraft_type"];

    if (ac["last_position"] instanceof Dictionary) {
      var position = ac["last_position"];
      self.lat = position["latitude"];
      self.lon = position["longitude"];
      self.altitude = position["altitude"] * 100;
      self.groundSpeed = position["groundspeed"];
      self.track = position["heading"];

      if (position["timestamp"] instanceof String) {
        var timestamp = parseISODate(position["timestamp"]);
        self.lastUpdate = Time.now().compare(timestamp);
      }
    }
  }

  public function fromOpensky(ac as Array, now as Number) as Void {
    self.flight = ac[1];
    self.lat = ac[6];
    self.lon = ac[5];
    if (ac[7] != null) {
      self.altitude = ac[7] * 3.28;
    }
    if (ac[13] != null) {
      self.altitude = ac[13] * 3.28;
    }
    self.grounded = ac[8];
    self.groundSpeed = ac[9];
    self.track = ac[10];
    self.squawk = ac[14];

    if (ac[3] != null) {
      self.lastUpdate = now - ac[3];
    }

    if (ac[17] != null) {
      switch (ac[17]) {
        case 2:
          self.category = "A1";
          break;

        case 3:
          self.category = "A2";
          break;

        case 4:
          self.category = "A3";
          break;

        case 5:
          self.category = "A4";
          break;

        case 6:
          self.category = "A5";
          break;

        case 7:
          self.category = "A6";
          break;

        case 8:
          self.category = "A7";
          break;

        case 9:
          self.category = "B1";
          break;

        case 10:
          self.category = "B2";
          break;

        case 11:
          self.category = "B3";
          break;

        case 12:
          self.category = "B4";
          break;

        case 13:
          self.category = "B5";
          break;

        case 14:
          self.category = "B6";
          break;

        case 15:
          self.category = "B7";
          break;

        case 16:
          self.category = "C1";
          break;

        case 17:
          self.category = "C2";
          break;

        case 18:
          self.category = "C3";
          break;

        case 19:
          self.category = "C4";
          break;

        case 20:
          self.category = "C5";
          break;
      }
    }
  }

  // Code from @trisiak
  // converts rfc3339 formatted timestamp to Time::Moment (null on error)
  function parseISODate(date as String) as Moment? {
    // assert(date instanceOf String)

    // 0123456789012345678901234
    // 2011-10-17T13:00:00-07:00
    // 2011-10-17T16:30:55.000Z
    // 2011-10-17T16:30:55Z
    if (date.length() < 20) {
      return null;
    }

    var moment = Gregorian.moment({
      :year => date.substring(0, 4).toNumber(),
      :month => date.substring(5, 7).toNumber(),
      :day => date.substring(8, 10).toNumber(),
      :hour => date.substring(11, 13).toNumber(),
      :minute => date.substring(14, 16).toNumber(),
      :second => date.substring(17, 19).toNumber(),
    });
    var suffix = date.substring(19, date.length());

    // skip over to time zone
    var tz = 0;
    if (suffix.substring(tz, tz + 1).equals(".")) {
      while (tz < suffix.length()) {
        var first = suffix.substring(tz, tz + 1);
        if ("-+Z".find(first) != null) {
          break;
        }
        tz++;
      }
    }

    if (tz >= suffix.length()) {
      // no timezone given
      return null;
    }
    var tzOffset = 0;
    if (!suffix.substring(tz, tz + 1).equals("Z")) {
      // +HH:MM
      if (suffix.length() - tz < 6) {
        return null;
      }
      tzOffset =
        suffix.substring(tz + 1, tz + 3).toNumber() *
        Gregorian.SECONDS_PER_HOUR;
      tzOffset +=
        suffix.substring(tz + 4, tz + 6).toNumber() *
        Gregorian.SECONDS_PER_MINUTE;

      var sign = suffix.substring(tz, tz + 1);
      if (sign.equals("+")) {
        tzOffset = -tzOffset;
      } else if (sign.equals("-") && tzOffset == 0) {
        // -00:00 denotes unknown timezone
        return null;
      }
    }
    return moment.add(new Time.Duration(tzOffset));
  }
}
