Screen screen1;
ArrayList<Flight> flights;
Table flightsTable;
boolean loaded, initialized;

void setup(){
  size(1920, 1080);
  background(0);
  fill(0, 200, 0);
  textSize(150);
  textAlign(CENTER);
  text("loading...", width/2, height/2);
  screen1 = new Screen(1);
  flights = new ArrayList<Flight>();
}

void initializeFlights(){                                          //initializes an array of fight objects which each
  String[] rows = loadStrings("flights.csv");                      //contain all the data for the corresponding flight
  
  for(int i=1; i<rows.length; i++){
    String[] data = split(rows[i], ',');
    
    String date = convertToDate(data[3], data[1], data[0]);
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
  initialized=true;
}

String convertToDate(String day, String month, String year){
  if(day.length()==1) day="0"+day;
  if(month.length()==1) month="0"+month;
  return(day+"/"+month+"/"+year);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  screen1.scrollPercent+=(e/100);
  if(screen1.scrollPercent<0) screen1.scrollPercent=0;
}

void drawLoading(){
  background(0);
  textSize(80);
  fill(0, 230, 0);
  text("loading...", 200, 200);
}

void mousePressed(){
  println("x: "+mouseX+"  y: "+mouseY);
}

void draw(){
  if(!loaded){ 
      initializeFlights();
      loaded=true;
  }
  if(initialized){
    textAlign(LEFT);
    screen1.draw();
  }
}
