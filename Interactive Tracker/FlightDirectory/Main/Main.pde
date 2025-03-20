Screen screen1;
ArrayList<Flight> flights;
Table flightsTable;
boolean loaded;

void setup(){
  size(1920, 1080);
  screen1 = new Screen(1);
  flights = new ArrayList<Flight>();
}

void initializeFlights(){
  String[] rows = loadStrings("flights.csv");
  
  for(int i=1; i<rows.length; i++){
    String[] data = split(rows[i], ',');
    
    String date = data[3] +"/"+ data[1] +"/"+ data[0];
    String airlineCode = data[4];
    String flightNumber = data[5];
    String origin = data[7];
    String destination = data[8];
    String scheduledDeparture = data[9];
    String actualDeparture = data[10];
    int departureDelay = int(data[11]);
    int taxiOut = int(data[12]);
    String wheelsOff = data[13];
    int scheduledFlightTime = int(data[14]);
    int elapsedTime = int(data[15]);
    int airTime = int(data[16]);
    float flightDistance = float(data[17]);
    String wheelsOn = data[18];
    int taxiIn = int(data[19]);
    String scheduledArrival = data[20];
    String actualArrival = data[21];
    int arrivalDelay = int(data[22]);
    boolean diverted = (int(data[23])==1);
    boolean cancelled = (int(data[24])==1);

    flights.add( new Flight(date, airlineCode, flightNumber, origin, destination, scheduledDeparture, actualDeparture, departureDelay, taxiOut, wheelsOff, scheduledFlightTime, elapsedTime, airTime, flightDistance, wheelsOn, taxiIn, scheduledArrival, actualArrival, arrivalDelay, diverted, cancelled));
  }
  println("flights loaded");
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  screen1.scrollPercent+=(e/1000);
  
}

void draw(){
  if(!loaded){
      background(0);
      textSize(50);
      fill(0, 230, 0);
      text("loading...", 200, 200);
      initializeFlights();
      loaded=true;
  }
  screen1.draw();
}
