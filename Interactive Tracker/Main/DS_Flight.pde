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
  
  String identifier;
  
  
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
    identifier=airlineCode+flightNumber;
  }
  

  void drawData(int x, int y, int textSize){
    if((mouseX>x && mouseX<x+width-150 && mouseY>=y-textSize && mouseY<=y+2) && (!directoryScreen.sortQuery && !directoryScreen.dateQuery && !directoryScreen.airportQuery)){
        mouseOver = true; 
        noStroke();
        fill(170);
        rect(55+4, y-textSize+2, width-110-8, textSize+8, 15);
    }
    else mouseOver = false;
    
    fill(#3E1607);
    strokeWeight(1);
    stroke(0);
    textAlign(CENTER);
    text(date, x+(textSize*2.5), y);
    text(airlineCode + flightNumber, x+(textSize*8.7), y);
    text(origin + " -> " + destination, x+(textSize*15), y);
    text(scheduledDeparture + " - " + scheduledArrival, x+(textSize*22), y);
    text(actualDeparture + " - " + actualArrival, x+(textSize*31), y);
    text(departureDelay + " min ", x+(textSize*40), y);
    text("" + diverted, x+(textSize*47), y);
    text("" + cancelled, x+(textSize*55), y);
    text(flightDistance + " km", x+(textSize*65), y);
    
    
      if(mouseX>x && mouseX<x+width-150 && mouseY>y-textSize && mouseY<y){
        mouseOver = true;
      }
      else mouseOver = false;
  }


}
