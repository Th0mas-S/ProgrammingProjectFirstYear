import java.util.HashMap;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
Screen screen1, screen2, screen3, startScreen;
ArrayList<Flight> flights;                                                      //array of Flight classes - final once initialized
ArrayList<Integer> arrayIndex;                                                  //array of indexes for flights array - changes throughout program
ArrayList<String> airportCode, airportName, airlineCode, airlineName, airportAddress;           //code dictionaries
boolean loaded, initialized;                                                  //for loading screen
String inputText;
boolean entered;
int currentScreen;                                                              //determines the screen to display
Return menu;

void setup(){
  size(1920, 1080);
  fullScreen();
  background(0);
  fill(0, 200, 0);
  textSize(60);
  textAlign(CENTER);
  text("loading...", width/2, height/2);                          //shows loading screen until arrays are initialized
  startScreen = new Screen(3);
  screen1 = new Screen(1);                                        //screen1 is the main directory screen
  screen2 = new Screen(2);
  screen3 = new Screen(4);
  flights = new ArrayList<Flight>();
  arrayIndex = new ArrayList<Integer>();
  currentScreen=0;                                                  //default to start screen
  menu = new Return();
}

void initializeFlights(){                                          //initializes an array of fight objects which each
  String[] rows = loadStrings("flight_data_2017.csv");          //contain all the data for an individual flight
  
  for(int i=1; i<rows.length; i++){
    String[] data = split(rows[i], ',');
   
    String date = convertDate(data[0]);
    String airlineCode = data[2];
    String flightNumber = data[3];
    String origin = data[4];
    String destination = data[5];
    String scheduledDeparture = cropData(data[6]);
    String actualDeparture = cropData(data[8]);
    int departureDelay = int(data[10]);
    float flightDistance = float(data[11]);
    String scheduledArrival = cropData(data[7]);
    String actualArrival = cropData(data[9]);
    //println(data[13]+" "+(data[13].equals("True") ? "T":"F")+" : "+data[12]+" "+(data[12].equals("True") ? "T":"F"));
    boolean diverted = (data[13].equals("True"));
    boolean cancelled = (data[12].equals("True"));

    flights.add( new Flight(date, airlineCode, flightNumber, origin, destination, scheduledDeparture, actualDeparture, departureDelay, flightDistance, scheduledArrival, actualArrival, diverted, cancelled));
  }
  println("flights loaded ("+flights.size()+")");
  initialized=true;                    //stop loading screen when done and print screen0
}

String convertDate(String dateIn){              //used for initializing flights
  String[] mess = split(dateIn, '-');
  return(mess[2]+"/"+mess[1]+"/"+mess[0]);
}

String cropData(String dataIn){                 //used for initializing flights
  if(dataIn.equals("")) return "00:00";
  String[] mess = split(dataIn, ' ');
  return(mess[1]);
}

void initializeDictionary(){
  airportCode = new ArrayList<String>();
  airportName = new ArrayList<String>();
  airportAddress = new ArrayList<String>();
  String[] readIn = loadStrings("airport_data.csv");
  for(int i=1; i<readIn.length; i++){
    String[] row = split(readIn[i], ",");
    airportCode.add(row[2]);
    airportName.add(row[1]);
    airportAddress.add(row[3]+", "+row[4]);
  }
  
  airlineCode = new ArrayList<String>();
  airlineName = new ArrayList<String>();
  readIn = loadStrings("airline_codes.csv");
  for(int i=1; i<readIn.length; i++){
    String[] row = split(readIn[i], ",");
    airlineCode.add(row[0]);
    airlineName.add(row[1]);
  }
  println("dictionaries loaded");
}

String removeFirstLast(String str) {
  return (str.length() > 1) ? str.substring(1, str.length() - 1) : "";
}

String removeFirst(String str) {
  return (str.length() > 1) ? str.substring(1, str.length()) : "";
}

String getAirport(String airport){
  for(int i=0; i<airportCode.size(); i++){
    if(airportCode.get(i).equals(airport)) return airportName.get(i);
  }
  return("error");
}

String getAirportAddress(String airport){
  for(int i=0; i<airportCode.size(); i++){
    if(airportCode.get(i).equals(airport)) return airportAddress.get(i);
  }
  return("error");
}
  
String getCarrier(String carrier){
  for(int i=0; i<airlineCode.size(); i++){
    if(airlineCode.get(i).equals(carrier)) return airlineName.get(i);
  }
  return("error");
}

void mouseWheel(MouseEvent event) {                                    
  float e = event.getCount();
  screen1.slider.scroll(e);                               //scrolls list               
}

void clearInput(){                                      //clears user input line
  inputText="";
}

void keyPressed() {                                      //addes user inputted text to variable inputText
  entered=false;                                         //must be manually cleared with clearInput()
  if(key == ENTER || key == RETURN) {
    println("Final input: " + inputText);
    entered=true;
  } 
  else if(key == BACKSPACE && inputText.length() > 0) {
    inputText = inputText.substring(0, inputText.length()-1);
  } 
  else if(keyCode != SHIFT && key != BACKSPACE){
    inputText += key;
  }
}

void mousePressed(){ 
  if(currentScreen==0){
    startScreen.directory.widgetPressed();
    startScreen.graphs.widgetPressed();
    startScreen.exitButton.widgetPressed();
  }
  else if(currentScreen==1){
    if(!screen1.sortQuery && !screen1.dateQuery){
      screen1.slider.sliderPressed();
      screen1.searchbar.searchPressed();
      screen1.clear.widgetPressed();
      screen1.checkFlights();
      menu.returnPressed();
      screen1.sort.widgetPressed();
    }
    else{
      screen1.sortMenu.lateness.widgetPressed();
      screen1.sortMenu.distance.widgetPressed();
      screen1.sortMenu.date.widgetPressed();
      screen1.dateMenu.selector.search1.searchPressed();
      screen1.dateMenu.selector.search2.searchPressed();
      screen1.dateMenu.selector.done.widgetPressed();
      screen1.sortMenu.cancelled.widgetPressed();
      screen1.sortMenu.diverted.widgetPressed();
      screen1.dateMenu.cancel.widgetPressed();
      screen1.sortMenu.cancel.widgetPressed();
    }
  }
  else if(currentScreen==2){
    screen2.back.widgetPressed();
  }
   else if(currentScreen==3){
    screen3.newGraph.graphPressed();
    menu.returnPressed();
  }
  println("x: "+mouseX+"  y: "+mouseY);     //!for testing!
}

void mouseReleased(){
  screen1.slider.sliderReleased();
}

void mouseMoved(){
  if(currentScreen==1){
    if(screen1.slider.mouseOver()) screen1.slider.hover=true;
    else if(!screen1.slider.mouseOver()) screen1.slider.hover=false;
  }
}

void clearIndex(){                          //sets index array to all ints 0-(max number of flights)
  arrayIndex=new ArrayList<Integer>();      //essentially resets the index to hold all Flight classes
  for(int i=0; i<flights.size(); i++){      //!does not actually clear the index to an empty array!
    arrayIndex.add(i);
  }
}

void showFlight(Flight currentFlight){        //tells screen2 what sppecific flight to display
  println(currentFlight.date);
  screen2.showData(currentFlight);
  currentScreen=2;                            //sets currentScreen to 2 to show screen2
}

void draw(){
  if(!loaded){                     //runs once on startup to initialize all arrays
      initializeFlights();
      initializeDictionary();
      clearIndex();
      loaded=true;
  }
  if(initialized){                 //main draw area...
    if(currentScreen==0){
      startScreen.draw();
    }
    else if(currentScreen==1){
      textAlign(LEFT);
      screen1.draw();
      menu.draw();
    }
    else if(currentScreen==2){
      screen2.draw();
    }
    else if(currentScreen==3){
      screen3.draw();
      textAlign(LEFT);
      menu.draw();
    }
  }
}
