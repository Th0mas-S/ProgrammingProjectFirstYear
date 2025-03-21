class Flight{
  String date;                          //list of all data points stored for each flight
  String airlineCode;
  String flightNumber;
  String origin;
  String destination;
  String scheduledDeparture;
  String actualDeparture;
  int departureDelay;
  int taxiOut;
  String wheelsOff;
  int scheduledFlightTime;
  int elapsedTime;
  int airTime;
  float flightDistance;
  String wheelsOn;
  int taxiIn;
  String scheduledArrival;
  String actualArrival;
  int arrivalDelay;
  boolean diverted;
  boolean cancelled;
  
  Flight(String date, String airlineCode, String flightNumber, String origin, String destination, String scheduledDeparture, String actualDeparture, int departureDelay, int taxiOut, String wheelsOff, int scheduledFlightTime, int elapsedTime, int airTime, float flightDistance, String wheelsOn, int taxiIn, String scheduledArrival, String actualArrival, int arrivalDelay, boolean diverted, boolean cancelled) {
    this.date = date;
    this.airlineCode = airlineCode;                            //setup...
    this.flightNumber = flightNumber;
    this.origin = origin;
    this.destination = destination;
    this.scheduledDeparture = scheduledDeparture;
    this.actualDeparture = actualDeparture;
    this.departureDelay = departureDelay;
    this.taxiOut = taxiOut;
    this.wheelsOff = wheelsOff;
    this.scheduledFlightTime = scheduledFlightTime;
    this.elapsedTime = elapsedTime;
    this.airTime = airTime;
    this.flightDistance = flightDistance;
    this.wheelsOn = wheelsOn;
    this.taxiIn = taxiIn;
    this.scheduledArrival = scheduledArrival;
    this.actualArrival = actualArrival;
    this.arrivalDelay = arrivalDelay;
    this.diverted = diverted;
    this.cancelled = cancelled;
  }

  public String toString() {
    return date + " | " + airlineCode + flightNumber + " | " + origin + " -> " + destination + 
           " | Scheduled: " + scheduledDeparture + " - " + scheduledArrival + 
           " | Actual: " + actualDeparture + " - " + actualArrival + 
           " | Delay: " + departureDelay + " min | Flight time: " + elapsedTime + " min | Diverted: " + diverted + " | Cancelled: " + cancelled + " | Distance: " + flightDistance + " km";
  }

}
