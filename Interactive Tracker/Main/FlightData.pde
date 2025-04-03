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

void initializeFlights(){                                          //initializes an array of fight objects which each
  String[] rows = loadStrings(currentDataset);          //contain all the data for an individual flight
  
  int skippedBadDuration = 0;
  int skippedMalformedTime = 0;
  
  for(int i=1; i<rows.length; i++){
    String[] data = split(rows[i], ',');
   
    String date = convertDate(data[0]);
    String airlineName = data[1];
    String airlineCode = data[2];
    String flightNumber = data[3];
    String origin = data[4];
    String destination = data[5];
    String scheduledDeparture = cropData(data[6]);
    String actualDeparture = data[8];
    int departureDelay = int(data[10]);
    float flightDistance = float(data[11]);
    String scheduledArrival = cropData(data[7]);
    String actualArrival = data[9];
    
    //println(data[13]+" "+(data[13].equals("True") ? "T":"F")+" : "+data[12]+" "+(data[12].equals("True") ? "T":"F"));
    boolean diverted = (data[13].equals("True"));
    boolean cancelled = (data[12].equals("True"));
    
    
    String[] depParts = split(data[8], " ");
    String[] arrParts = split(data[9], " ");
    if (depParts.length != 2 || arrParts.length != 2) {
      skippedMalformedTime++;
      continue;
    }
   
    
    actualArrival = convertDate(arrParts[0]) + " " + arrParts[1];
    actualDeparture = convertDate(depParts[0]) + " " + depParts[1];
    
    String dateStr = depParts[0];
    String depTimeStr = depParts[1];
    String arrTimeStr = arrParts[1];
    String[] depHM = split(depTimeStr, ":");
    String[] arrHM = split(arrTimeStr, ":");
    if (depHM.length < 2 || arrHM.length < 2) {
      skippedMalformedTime++;
      continue;
    }
    int depMin = int(depHM[0]) * 60 + int(depHM[1]);
    int arrMin = int(arrHM[0]) * 60 + int(arrHM[1]);
    if (arrMin < depMin) {
      arrMin += 1440;
    }
    int duration = arrMin - depMin;
    if (duration <= 0) {
      skippedBadDuration++;
      continue;
    }

    flights.add(new Flight(date, airlineCode, airlineName, flightNumber, origin, destination, scheduledDeparture, actualDeparture, departureDelay, flightDistance, scheduledArrival, actualArrival, diverted, cancelled, duration, depMin));
  }
  println("flights loaded ("+flights.size()+")");
  println("skipped due to malformed time (" + skippedMalformedTime + ")");
  println("skipped due to bad duration (" + skippedBadDuration + ")");

  initialized=true;                    //stop loading screen when done and print screen0
}

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
    this.actualDeparture = cropData(actualDeparture);
    this.departureDelay = departureDelay;
    this.flightDistance = flightDistance;
    this.scheduledArrival = scheduledArrival;
    this.actualArrival = cropData(actualArrival);
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
