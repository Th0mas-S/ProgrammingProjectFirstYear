class Flight{
  String date;                          //list of all data points stored for each flight
  String airlineCode;
  String flightNumber;
  String origin;
  String destination;
  String scheduledDeparture;
  String actualDeparture;
  int departureDelay;
  float flightDistance;
  String scheduledArrival;
  String actualArrival;
  boolean diverted;
  boolean cancelled;
  boolean mouseOver;
  
  
  Flight(String date, String airlineCode, String flightNumber, String origin, String destination, String scheduledDeparture, String actualDeparture, int departureDelay, float flightDistance, String scheduledArrival, String actualArrival, boolean diverted, boolean cancelled) {
    this.date = date;
    this.airlineCode = airlineCode;                            //setup...
    this.flightNumber = flightNumber;
    this.origin = origin;
    this.destination = destination;
    this.scheduledDeparture = scheduledDeparture;
    this.actualDeparture = actualDeparture;
    this.departureDelay = departureDelay;
    this.flightDistance = flightDistance;
    this.scheduledArrival = scheduledArrival;
    this.actualArrival = actualArrival;
    this.diverted = diverted;
    this.cancelled = cancelled;
  }
  

  void drawData(int x, int y, int textSize){
      text(date, x-5, y);
      text("   " + airlineCode + flightNumber, x+(textSize*4.791), y);
      text("    " + origin + " -> " + destination, x+(textSize*8.958), y);
      text("    Scheduled: " + scheduledDeparture + " - " + scheduledArrival, x+(textSize*15), y);
      text("    Actual: " + actualDeparture + " - " + actualArrival, x+(textSize*26.25), y);
      text("    Delay: " + departureDelay + " min ", x+(textSize*35.833), y);
      text("    Diverted: " + diverted, x+(textSize*43.333), y);
      text("    Cancelled: " + cancelled, x+(textSize*50.833), y);
      text("    Distance: " + flightDistance + " km", x+(textSize*58.75), y);
    
    
      if(mouseX>x && mouseX<x+width-150 && mouseY>y-textSize && mouseY<y){
        mouseOver = true;
      }
      else mouseOver = false;
  }


}
