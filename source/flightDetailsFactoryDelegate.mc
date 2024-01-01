import Toybox.Lang;
import Toybox.WatchUi;

class FlightDetailsFactoryDelegate extends WatchUi.ViewLoopDelegate {
  private var _viewLoop as WatchUi.ViewLoop;

  function initialize(viewLoop) {
    ViewLoopDelegate.initialize(viewLoop);

    _viewLoop = viewLoop;
  }

  //! Handle going to the next view
  //! @return true if handled, false otherwise
  function onNextView() {
    _viewLoop.changeView(WatchUi.ViewLoop.DIRECTION_NEXT);
    return true;
  }

  //! Handle going to the previous view
  //! @return true if handled, false otherwise
  function onPreviousView() {
    _viewLoop.changeView(WatchUi.ViewLoop.DIRECTION_PREVIOUS);
    return true;
  }
}
