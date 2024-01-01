import Toybox.Lang;
import Toybox.Time;

class TracksReport {
  // the time the report was generated
  public var timestamp as Time.Moment;

  // aircraft tracks
  public var tracks as Array<AircraftTrack>;

  public function initialize(
    timestamp as Time.Moment,
    tracks as Array<AircraftTrack>
  ) {
    self.timestamp = timestamp;
    self.tracks = tracks;
  }
}
