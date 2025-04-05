
void initializeFlights(){
  String[] rows = loadStrings(currentDataset);
  int skippedBadDuration = 0;
  int skippedMalformedTime = 0;
  float startLoadingPercent = loadingScreen.loadingDone;
  
  for (int i = 1; i < rows.length; i++){
    String[] data = split(rows[i], ',');
    
    String scheduledDate = convertDate(data[0]); // Scheduled flight date.
    // Initially use the scheduled date.
    String date = scheduledDate;
    
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
    
    boolean diverted = (data[13].equals("True"));
    boolean cancelled = (data[12].equals("True"));
    
    String[] depParts = split(data[8], " ");
    String[] arrParts = split(data[9], " ");
    if (depParts.length != 2 || arrParts.length != 2) {
      skippedMalformedTime++;
      // Optionally continue here.
    }
    
    int duration = 0;
    int minutes = 0;
    if (!cancelled) {
      // Build proper actual departure/arrival strings.
      actualDeparture = convertDate(depParts[0]) + " " + depParts[1];
      actualArrival = convertDate(arrParts[0]) + " " + arrParts[1];
      
      // Use the actual departure date if it differs from the scheduled date.
      String actualDepDate = convertDate(depParts[0]);
      if (!actualDepDate.equals(scheduledDate)) {
        date = actualDepDate;
      }
      
      String depTimeStr = depParts[1];
      String arrTimeStr = arrParts[1];
      String[] depHM = split(depTimeStr, ":");
      String[] arrHM = split(arrTimeStr, ":");
      if (depHM.length < 2 || arrHM.length < 2) {
        skippedMalformedTime++;
        continue;
      }
      // Use the actual departure time (in minutes from midnight).
      int depMin = int(depHM[0]) * 60 + int(depHM[1]);
      minutes = depMin;
      
      // Calculate arrival minutes. If arrival time is before departure, assume it’s on the next day.
      int arrMin = int(arrHM[0]) * 60 + int(arrHM[1]);
      if (arrMin < depMin) {
        arrMin += 1440;
      }
      duration = arrMin - depMin;
      if (duration <= 0) {
        skippedBadDuration++;
        continue;
      }
    }
    
    flights.add(new Flight(date, airlineCode, airlineName, flightNumber, origin, destination,
                           scheduledDeparture, actualDeparture, departureDelay, flightDistance,
                           scheduledArrival, actualArrival, diverted, cancelled, duration, minutes));
    if (i % 100 == 0)
      loadingScreen.setLoadingProgress(startLoadingPercent + (((float)i / (float)rows.length) / 2));
  }
  println("flights loaded (" + flights.size() + ")");
  println("skipped due to malformed time (" + skippedMalformedTime + ")");
  println("skipped due to bad duration (" + skippedBadDuration + ")");
  
  initialized = true;
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
  
  String identifier;
  
  
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
    
    identifier=airlineCode+flightNumber;

  }
  
  // Pretty much only used in Flight Directory
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
    text(cancelled ? "N/A" : cropData(actualDeparture) + " - " + cropData(actualArrival), x+(textSize*31), y);
    text(cancelled ? "N/A" : departureDelay + " min ", x+(textSize*40), y);
    text(cancelled ? "N/A" : "" + diverted, x+(textSize*47), y);
    text("" + cancelled, x+(textSize*55), y);
    text(flightDistance + " km", x+(textSize*65), y);
    
    
      if(mouseX>x && mouseX<x+width-150 && mouseY>y-textSize && mouseY<y){
        mouseOver = true;
      }
      else mouseOver = false;
  }



}
