import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! ViewLoop Factory which manages the main primate view/delegate paires
class FlightDetailsFactory extends WatchUi.ViewLoopFactory {
  private var _lastTracksReport as TracksReport?;
  private var _showDetailsIDs as Array<Number>?;

  function initialize(
    lastTracksReport as TracksReport,
    showDetailsIDs as Array<Number>
  ) {
    ViewLoopFactory.initialize();

    self._lastTracksReport = lastTracksReport;
    self._showDetailsIDs = showDetailsIDs;
  }

  //! Retrieve a view/delegate pair for the page at the given index
  function getView(page as Number) as Array<View or BehaviorDelegate>? {
    var id = _showDetailsIDs[page];
    return (
      [
        new $.FlightDetailsView(_lastTracksReport, id),
        new $.FlightDetailsDelegate(),
      ] as Array<Views or InputDelegates>
    );
  }

  //! Return the number of view/delegate pairs that are managed by this factory
  function getSize() {
    return _showDetailsIDs.size();
  }
}
