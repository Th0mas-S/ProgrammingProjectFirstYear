//download flights.csv and place in folder
//link -> https://figshare.com/articles/dataset/flights_csv/9820139?file=17614757

Screen screen1;
ArrayList<Flight> flights;                //array of Flight classes - final once initialized
ArrayList<Integer> arrayIndex;            //array of indexes for flights array - changes throughout program
boolean loaded, initialized;              //for loading screen

void setup(){
  size(1920, 1080);
  fullScreen();
  background(0);
  fill(0, 200, 0);
  textSize(60);
  textAlign(CENTER);
  text("loading...", width/2, height/2);                          //shows loading screen until arrays are initialized
  screen1 = new Screen(1);                                        //screen1 is the main directory screen
  flights = new ArrayList<Flight>();
  arrayIndex = new ArrayList<Integer>();
}

void initializeFlights(){                                          //initializes an array of fight objects which each
  String[] rows = loadStrings("flights.csv");                      //contain all the data for an individual flight
  
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
  initialized=true;                    //stop loading screen when done and print screen1
}

String convertToDate(String day, String month, String year){          //used to format dd/mm/yyyy for all flights
  if(day.length()==1) day="0"+day;                                    //not used outside of initializeFlights()
  if(month.length()==1) month="0"+month;
  return(day+"/"+month+"/"+year);
}

void mouseWheel(MouseEvent event) {                                    
  float e = event.getCount();
  screen1.slider.scroll(e);                               //scrolls list               
}

void keyPressed(){                          //!for testing!
  if(key=='c') clearIndex();
  else if(key=='v'){
    screen1.search("LAX");
  }
}

void mousePressed(){     
  screen1.slider.sliderPressed();
  println("x: "+mouseX+"  y: "+mouseY);     //!for testing!
}

void mouseReleased(){
  screen1.slider.sliderReleased();
}

void mouseMoved(){
  if(screen1.slider.mouseOver()) screen1.slider.hover=true;
  else if(!screen1.slider.mouseOver()) screen1.slider.hover=false;
}

void clearIndex(){                          //sets index array to all ints 0-(max number of flights)
  arrayIndex=new ArrayList<Integer>();      //essentially resets the index to hold all Flight classes
  for(int i=0; i<flights.size(); i++){      //!does not actually clear the index to an empty array!
    arrayIndex.add(i);
  }
}

void draw(){
  if(!loaded){                     //runs once on startup to initialize all arrays
      initializeFlights();
      clearIndex();
      loaded=true;
  }
  if(initialized){                 //main draw area...
    textAlign(LEFT);
    screen1.draw();
  }
}
