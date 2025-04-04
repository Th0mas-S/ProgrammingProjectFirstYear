
// RANDOM GLOBAL VARIABLES
import java.util.HashMap;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.Comparator;

String currentDataset = "flight_data_2017.csv";

ArrayList<Flight> flights;                                                      //array of Flight classes - final once initialized
ArrayList<Integer> arrayIndex;                                                  //array of indexes for flights array - changes throughout program
ArrayList<String> airportCode, airportName, airlineCode, airlineName, airportAddress;           //code dictionaries
boolean loaded, initialized;                                                  //for loading screen
String inputText;
boolean entered;
int currentScreen;                                                              //determines the screen to display
Return menu;


void clearIndex(){                          //sets index array to all ints 0-(max number of flights)
  arrayIndex=new ArrayList<Integer>();      //essentially resets the index to hold all Flight classes
  for(int i=0; i<flights.size(); i++){      //!does not actually clear the index to an empty array!
    arrayIndex.add(i);
  }
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

void initializeDictionary(String[] readIn){                                //call once on startup
  airportCode = new ArrayList<String>();                    //initializes dictionarys for airport and airline codes
  airportName = new ArrayList<String>();
  airportAddress = new ArrayList<String>();
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

void clearInput(){                                      //clears user input line
  inputText="";
}


void initGlobalVariables() {
    flights = new ArrayList<Flight>();
    arrayIndex = new ArrayList<Integer>();
    currentScreen=0;                                                  //default to start screen
    menu = new Return();
    //initializeFlights();
    //initializeDictionary();
}


//  ----------------------------------
//  | Main Airplane Directory Screen |
//  ----------------------------------


class DirectoryScreen extends Screen {
  
  ArrayList<Header> headers;
  int textSize, sliderLength;
  float scrollPercent;
  Query sortMenu, dateMenu, airportMenu;
  Slider slider;
  Search searchbar;
  Widget clear, sort;
  PImage logo, backdrop;
  
  boolean sortQuery, dateQuery, airportQuery;
  
  DirectoryScreen() {
      textSize=int((width-110)*0.014);
      scrollPercent = 0;
      sliderLength=height-335-55-40;
      slider = new Slider(width-28, height-55-(sliderLength/2)-(height-335)/2, sliderLength);
      searchbar = new Search(width-340, 160, textSize, 1);
      clear = new Widget(width-480, 160, 1, 100, 50, #EA5F5F);
      sort = new Widget(width-610, 160, 6, 100, 50, #028391);                        //current widget = 9
      sortMenu = new Query(#93D3AE, 1);
      dateMenu = new Query(#9DCDDE, 2);
      airportMenu = new Query(#9DCDDE, 3);
      
      logo = loadImage("Flighthub Logo.png");
      logo.resize(int(360*1.9), int(240*1.9));
      backdrop = loadImage("ds_backdrop.png");
      
      headers = new ArrayList<Header>();
      headers.add( new Header(int(85+(textSize*2.5)), 305, "Date", int(textSize/1.1), 1) );
      headers.add( new Header(int(85+(textSize*8.7)), 305, "Flight", int(textSize/1.1), 2) );
      headers.add( new Header(int(85+(textSize*15)), 305, "Route", int(textSize/1.1), 3) );
      headers.add( new Header(int(85+(textSize*22)), 305, "Scheduled", int(textSize/1.1), 4) );
      headers.add( new Header(int(85+(textSize*31)), 305, "Actual", int(textSize/1.1), 5) );
      headers.add( new Header(int(85+(textSize*40)), 305, "Delay", int(textSize/1.1), 6) );
      headers.add( new Header(int(85+(textSize*47)), 305, "Diverted", int(textSize/1.1), 7) );
      headers.add( new Header(int(85+(textSize*55)), 305, "Cancelled", int(textSize/1.1), 8) );
      headers.add( new Header(int(85+(textSize*65)), 305, "Distance", int(textSize/1.1), 9) );
  }
  
  void drawHeaders(){
    for(int i=0; i<headers.size(); i++){
      headers.get(i).draw();
    }
  }
  
  void clearHeaders(){
    for(int i=0; i<headers.size(); i++){
      headers.get(i).clicked=false;
    }
  }
  
  void headersPressed(){
    for(int i=0; i<headers.size(); i++){
      headers.get(i).headerPressed();
    }
  }
  
  void draw() {
      backdrop.resize(width, height);
      background(backdrop);
      
      stroke(100);
      strokeWeight(5);
      fill(160, 160, 160, 220);      
      rect(55, 280, width-110, height-335, 15);
      
      imageMode(CORNER);
      rect(58, 63-15, 531+23, 131+30, 13);        //logo border
      image(logo, 20, -100);
      imageMode(CORNER);
      
      strokeWeight(1);
      stroke(0);
      textSize(textSize);
      fill(#3E1607);
      textAlign(LEFT);
      printArray();
      
      stroke(100);
      strokeWeight(5);
      
      line(90+(textSize*5.6), 280, 90+(textSize*5.6), height-55);
      line(90+(textSize*11.1), 280, 90+(textSize*11.1), height-55);
      line(90+(textSize*18), 280, 90+(textSize*18), height-55);
      line(90+(textSize*26.25), 280, 90+(textSize*26.25), height-55);
      line(90+(textSize*35.833), 280, 90+(textSize*35.833), height-55);
      line(90+(textSize*43.333), 280, 90+(textSize*43.333), height-55);
      line(90+(textSize*50.833), 280, 90+(textSize*50.833), height-55);
      line(90+(textSize*58.75), 280, 90+(textSize*58.75), height-55);
      
      drawHeaders();
      strokeWeight(4);
      slider.draw();
      searchbar.draw();
      clear.draw();
      sort.draw();
      
      hint(DISABLE_DEPTH_TEST);
      if(sortQuery) sortMenu.draw();
      if(dateQuery) dateMenu.draw();
      if(airportQuery) airportMenu.draw();
      hint(ENABLE_DEPTH_TEST);
      
      menu.draw();
      strokeWeight(1);
  }
  
  void mousePressed() {
     //println("x: "+mouseX+"  y: "+mouseY);
     if(!sortQuery && !dateQuery && !airportQuery){
      slider.sliderPressed();
      searchbar.searchPressed();
      clear.widgetPressed();
      checkFlights();
      menu.returnPressed();
      sort.widgetPressed();
      headersPressed();
    }
    else{
      sortMenu.lateness.widgetPressed();
      sortMenu.distance.widgetPressed();
      sortMenu.date.widgetPressed();
      sortMenu.cancel.widgetPressed();
      sortMenu.airport.widgetPressed();
      sortMenu.cancelled.widgetPressed();
      sortMenu.diverted.widgetPressed();
      
      dateMenu.cancel.widgetPressed();
      dateMenu.selector.search1.searchPressed();
      dateMenu.selector.search2.searchPressed();
      dateMenu.selector.done.widgetPressed();     
      
      airportMenu.airportSelector.origin.widgetPressed();
      airportMenu.airportSelector.destination.widgetPressed();
      airportMenu.cancel.widgetPressed();
      airportMenu.airportSelector.search.searchPressed();
    }
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
    else if(keyCode != SHIFT && key != BACKSPACE && keyCode != 20 && keyCode != CONTROL && keyCode != ALT && keyCode != TAB){
      inputText += key;                                      // code is now aman and darragh proof thank god
    }
  }
  
  void mouseWheel(MouseEvent event) {                                    
    float e = event.getCount();
    slider.scroll(e);                               //scrolls list               
  }
  
  
  void mouseReleased(){
    slider.sliderReleased();
  }
  
  void mouseMoved() { 
    if(slider.mouseOver()) slider.hover=true;
    else if(!slider.mouseOver()) slider.hover=false;
  }
  
    
  void filterCancelled(){
    arrayIndex = new ArrayList<Integer>();          
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).cancelled){ 
        arrayIndex.add(i);
      }
    }  
  }
  
  void filterDiverted(){
    arrayIndex = new ArrayList<Integer>();          
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).diverted){ 
        arrayIndex.add(i);
      }
    }  
  }
  
  
  void printArray(){                                //prints all the Flight data from each Flight in flights array that is selected by index array
    int counter=0;
    for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
      flights.get(arrayIndex.get(i)).drawData(85, 310+((textSize+3)*counter)+int(height*0.02), textSize);
      counter++;
    }
  } 
  
  void search(String query){                        //once called it sets index array to all Flight locations whose airline/flight number/origin or destination
    arrayIndex = new ArrayList<Integer>();          //match the query (search parameter) passed into the function
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).airlineCode.equalsIgnoreCase(query) || flights.get(i).flightNumber.equalsIgnoreCase(query) || flights.get(i).origin.equalsIgnoreCase(query) 
      || flights.get(i).destination.equalsIgnoreCase(query) || query.equalsIgnoreCase(flights.get(i).airlineCode+flights.get(i).flightNumber)){ 
        arrayIndex.add(i);
      }
    }                                               //needs support for location names/airline names and not be case sensitive
    println("sorted: "+query);                              //e.g. can only take "LAX" not "los angeles" or "lax"
  }
  
  void sortByDate(String date1In, String date2In) {
    arrayIndex = new ArrayList<>();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    LocalDate startDate = LocalDate.parse(date1In, formatter);
    LocalDate endDate = LocalDate.parse(date2In, formatter);
    for (int i = 0; i < flights.size(); i++) {
        LocalDate flightDate = LocalDate.parse(flights.get(i).date, formatter);
        if (!flightDate.isBefore(startDate) && !flightDate.isAfter(endDate)) {
            arrayIndex.add(i);
        }
    }
  }
  
  void sortByLateness(){
    clearIndex();
    arrayIndex.sort((i, j) -> Integer.compare(flights.get(j).departureDelay, flights.get(i).departureDelay));
  }
  
  void sortByDistance(){
    clearIndex();
    arrayIndex.sort((i, j) -> Integer.compare(int(flights.get(j).flightDistance), int(flights.get(i).flightDistance)));
  }
  
  void checkFlights(){                              //checks if a user has clicked on a specific line of flight data and takes them to that data page
    if(mouseX>55 && mouseY>280){
      int counter=0;
      for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
        if(flights.get(arrayIndex.get(i)).mouseOver) {
          Flight f = flights.get(arrayIndex.get(i));
          screenManager.switchScreen(new DirectoryFlightInfoScreen(f, this));
        }
        
        counter++;
      }
    }
  }
  
  //void showData(Flight currentFlight){
  //  flight = currentFlight;
  //}
 
}
