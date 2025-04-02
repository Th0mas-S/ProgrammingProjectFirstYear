//class FlightData {
//  String originCode;
//  String destCode;
//  String dateStr;
//  int minutes;
//  int duration;

//  String originCityCountry;
//  String destCityCountry;
//  String departureTimeStr;
//  String arrivalTimeStr;
//  String airlineName;
//  String airlineCode;
//  String flightNumber;

//  FlightData(String originCode, String destCode, String dateStr, int minutes, int duration,
//             String originCityCountry, String destCityCountry,
//             String departureTimeStr, String arrivalTimeStr,
//             String airlineName, String airlineCode, String flightNumber) {
//    this.originCode = originCode;
//    this.destCode = destCode;
//    this.dateStr = dateStr;
//    this.minutes = minutes;
//    this.duration = duration;

//    this.originCityCountry = originCityCountry;
//    this.destCityCountry = destCityCountry;
//    this.departureTimeStr = departureTimeStr;
//    this.arrivalTimeStr = arrivalTimeStr;
//    this.airlineName = airlineName;
//    this.airlineCode = airlineCode;
//    this.flightNumber = flightNumber;
//  }
//}

class Flight{
  String date;                          //list of all data points stored for each flight
  String airlineCode;
  String airlineName;
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
  int duration;
  int minutes;
  
  boolean mouseOver;
  
  
  Flight(String date, String airlineCode, String airlineName, String flightNumber, String origin, String destination, String scheduledDeparture, String actualDeparture,
  int departureDelay, float flightDistance, String scheduledArrival, String actualArrival, boolean diverted, boolean cancelled, int duration, int minutes) {
    this.date = date;
    this.airlineCode = airlineCode;  //setup...
    this.airlineName = airlineName;
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
    
    this.duration = duration;
    this.minutes = minutes;
    
    this.cancelled = cancelled;
  }
  
  // Pretty much only used in Flight Directory
  void drawData(int x, int y, int textSize){
    if(mouseX>x && mouseX<x+width-150 && mouseY>=y-textSize && mouseY<=y+2){
        mouseOver = true; 
        noStroke();
        fill(170);
        rect(55+4, y-textSize+2, width-110-8, textSize+8, 15);
    }
    else mouseOver = false;
    
    fill(#3E1607);
    strokeWeight(1);
    stroke(0);
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
