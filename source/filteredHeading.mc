import Toybox.Lang;

class FilteredHeading {
  public var currentHeading as Numeric;

  public function initialize(heading as Numeric) {
    currentHeading = heading;
  }

  public function update(heading as Numeric) {
    var delta = heading - currentHeading;
    if (delta > 3.141 / 2 || delta < -3.141 / 2) {
      currentHeading = heading;
    } else {
      currentHeading = currentHeading + delta * 0.2;
    }
  }
}
