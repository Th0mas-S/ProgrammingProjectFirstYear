
// RANDOM GLOBAL VARIABLES
import java.util.HashMap;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

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


void initializeFlights(){                                          //initializes an array of fight objects which each
  String[] rows = loadStrings(currentDataset);          //contain all the data for an individual flight
  
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

void initializeDictionary(){                                //call once on startup
  airportCode = new ArrayList<String>();                    //initializes dictionarys for airport and airline codes
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

void clearInput(){                                      //clears user input line
  inputText="";
}


void initGlobalVariables() {
    flights = new ArrayList<Flight>();
    arrayIndex = new ArrayList<Integer>();
    currentScreen=0;                                                  //default to start screen
    menu = new Return();
    initializeFlights();
    initializeDictionary();
}



class DirectoryMenuScreen extends Screen {
  
  Widget directory, graphs, exitButton;

  
  DirectoryMenuScreen() {
     directory = new Widget((width/2)-(width/8), height/3, 3, width/4, 200, #028391);
     graphs = new Widget((width/2)-(width/8), int((height/3)*1.6), 4, width/4, 200, #F9A822);
     exitButton = new Widget((width/2)-(width/8), int((height/3)*2.2), 5, width/4, 200, #F57F5B);
  }
}

// THIS IS USELESS NOW
//void showFlight(Flight currentFlight){        //tells screen2 what sppecific flight to display
//  println(currentFlight.date);
//  screen2.showData(currentFlight);
//  currentScreen=2;                            //sets currentScreen to 2 to show screen2
//}

class DirectoryFlightInfoScreen extends Screen {
  
  Flight flight;
  Widget back;
  int textSize;

  DirectoryFlightInfoScreen(Flight currentFlight) {
    //textSize=int((width-110)*0.014);
    println(currentFlight.date);
    showData(currentFlight);
    back = new Widget(width-160, 160, 2, 100, 50, #DD5341);
    textSize=int((width-110)*0.014);

  }
  
  void showData(Flight currentFlight){
    flight = currentFlight;
  }

  void draw() {
      background(#FAA968);
      image(flightHubLogo, 60, 60);
      stroke(0);
      fill(#2BBAA5);      
      rect(55, 280, width-110, height-335, 15);
      textSize(textSize);
      fill(0);
      int i = 140;
      int j = 430+((textSize*3+3));
      
      text("Origin:                "+getAirport(flight.origin)+" / "+flight.origin, i, j+textSize*9);
      text("From:      "+getAirportAddress(flight.origin), i, j-textSize*5);
      text("Destination:     "+getAirport(flight.destination)+" / "+flight.destination, i, j+textSize*10+10);
      text("To:            "+getAirportAddress(flight.destination), i, j-textSize*4+10);
      
      text("Scheduled Departure:    "+flight.scheduledDeparture, i+width/2, j-textSize*5);
      text("Scheduled Arrival:            "+flight.scheduledArrival, i+width/2, j-textSize*4+10);
      text("Actual Departure:             "+flight.actualDeparture, i+width/2, j-textSize*2+30);
      text("Actual Arrival:                     "+flight.actualArrival, i+width/2, j-textSize+40);
      text("Delayed:    "+flight.departureDelay+"mins", i+width/2, j+textSize*4+20);
      text("Flight Distance:  "+flight.flightDistance+"km", i, j+textSize*4+30);
      
      text("Flight Number:  "+flight.airlineCode+" "+flight.flightNumber, i, j);
      text("Carrier:  "+getCarrier(flight.airlineCode), i, j+textSize*2+20);
      text("Date:  "+flight.date, i, j+textSize+10);     
      text("Cancelled:  "+(flight.cancelled ? "Yes":"No"), i+width/2, j+textSize*9);
      text("Diverted:  "+(flight.diverted ? "Yes":"No"), i+width/2, j+textSize*10+20);
      
      back.draw();
  }
  
  void mousePressed() {
    back.widgetPressed();
  }

}

class DirectoryScreen extends Screen {
  
  ArrayList<Header> headers;
  int textSize, sliderLength;
  float scrollPercent;
  Query sortMenu, dateMenu;
  Slider slider;
  Search searchbar;
  Widget clear, sort;
  
  boolean sortQuery, dateQuery;
  
  DirectoryScreen() {
      textSize=int((width-110)*0.014);
      scrollPercent = 0;
      sliderLength=height-335-55-40;
      slider = new Slider(width-28, height-55-(sliderLength/2)-(height-335)/2, sliderLength);
      searchbar = new Search(width-340, 160, textSize, 1);
      clear = new Widget(width-480, 160, 1, 100, 50, #F96635);
      sort = new Widget(width-610, 160, 6, 100, 50, #028391);                        //current widget = 9
      sortMenu = new Query(#93D3AE, 1);
      dateMenu = new Query(#FAECB6, 2);
      
      headers = new ArrayList<Header>();
      headers.add( new Header(int(85+(textSize*2.5)), 307, "Date", int(textSize/1.1), 1) );
      headers.add( new Header(int(85+(textSize*8.7)), 307, "Flight", int(textSize/1.1), 2) );
      headers.add( new Header(int(85+(textSize*15)), 307, "Route", int(textSize/1.1), 3) );
      headers.add( new Header(int(85+(textSize*22)), 307, "Scheduled", int(textSize/1.1), 4) );
      headers.add( new Header(int(85+(textSize*31)), 307, "Actual", int(textSize/1.1), 5) );
      headers.add( new Header(int(85+(textSize*40)), 307, "Delay", int(textSize/1.1), 6) );
      headers.add( new Header(int(85+(textSize*47)), 307, "Diverted", int(textSize/1.1), 7) );
      headers.add( new Header(int(85+(textSize*55)), 307, "Cancelled", int(textSize/1.1), 8) );
      headers.add( new Header(int(85+(textSize*65)), 307, "Distance", int(textSize/1.1), 9) );
      
  }
  
  void draw() {
      background(#FACA78);
      //image(flightHubLogo, 60, 60);
      stroke(100);
      strokeWeight(5);
      fill(160);      
      rect(55, 280, width-110, height-335, 15);
      
      strokeWeight(1);
      stroke(0);
      textSize(textSize);
      fill(#3E1607);
      textAlign(LEFT);
      printArray();
      
      stroke(100);
      strokeWeight(5);
      
      line(90+(textSize*4.791), 280, 90+(textSize*4.791), height-55);
      line(90+(textSize*8.958), 280, 90+(textSize*8.958), height-55);
      line(90+(textSize*15), 280, 90+(textSize*15), height-55);
      line(90+(textSize*26.25), 280, 90+(textSize*26.25), height-55);
      line(90+(textSize*35.833), 280, 90+(textSize*35.833), height-55);
      line(90+(textSize*43.333), 280, 90+(textSize*43.333), height-55);
      line(90+(textSize*50.833), 280, 90+(textSize*50.833), height-55);
      line(90+(textSize*58.75), 280, 90+(textSize*58.75), height-55);
      
      drawHeaders();
      slider.draw();
      searchbar.draw();
      clear.draw();
      sort.draw();
      if(sortQuery) sortMenu.draw();
      if(dateQuery) dateMenu.draw();
      
      menu.draw();

  }
  
  void mousePressed() {
     if(!sortQuery && !dateQuery){
      slider.sliderPressed();
      searchbar.searchPressed();
      clear.widgetPressed();
      checkFlights();
      menu.returnPressed();
      sort.widgetPressed();
    }
    else{
      sortMenu.lateness.widgetPressed();
      sortMenu.distance.widgetPressed();
      sortMenu.date.widgetPressed();
      dateMenu.selector.search1.searchPressed();
      dateMenu.selector.search2.searchPressed();
      dateMenu.selector.done.widgetPressed();
      sortMenu.cancelled.widgetPressed();
      sortMenu.diverted.widgetPressed();
      dateMenu.cancel.widgetPressed();
      sortMenu.cancel.widgetPressed();
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
    else if(keyCode != SHIFT && key != BACKSPACE){
      inputText += key;
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
    println(arrayIndex.size());
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
          screenManager.switchScreen(new DirectoryFlightInfoScreen(f));
        }
        
        counter++;
      }
    }
  }
  
  //void showData(Flight currentFlight){
  //  flight = currentFlight;
  //}
 
}

class Widget{
  int x, y, mode, w, h;
  int colour;
  
  Widget(int x, int y, int mode, int w, int h, int colour){
    this.x=x;
    this.y=y;
    this.mode=mode;
    this.w=w;
    this.h=h;
    this.colour=colour;
    println(colour+"");
  }
  
  boolean mouseOver(){
    if(mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h){
      return true;
    }
    else return false;
  }
  
  void widgetPressed(){
    if(mouseOver()){
      if(mode==1){
        entered=false;
        directoryScreen.searchbar.search=false;
        clearInput();
        clearIndex();
      }
      else if(mode==2){
        screenManager.switchScreen(directoryScreen);
      }
      if(mode==3){
        screenManager.switchScreen(directoryScreen);
      }
      if(mode==4){
        currentScreen=3;
      }
      if(mode==5){
        exit();
      }
      if(mode==6){
        directoryScreen.sortQuery=true;
      }
      if(mode==7){
        directoryScreen.sortByLateness();
        directoryScreen.sortQuery=false;
      }
      if(mode==8){
        directoryScreen.sortByDistance();
        directoryScreen.sortQuery=false;
      }
      if(mode==9){
        directoryScreen.sortQuery=false;
        directoryScreen.dateQuery=true;
      }
      if(mode==10){
        directoryScreen.sortByDate(directoryScreen.dateMenu.selector.date1, directoryScreen.dateMenu.selector.date2);
        directoryScreen.dateQuery=false;
      }
      if(mode==11){
        directoryScreen.filterCancelled();
        directoryScreen.sortQuery=false;
      }
      if(mode==12){
        directoryScreen.filterDiverted();
        directoryScreen.sortQuery=false;
      }
      if(mode==13){
        directoryScreen.dateQuery=false;
        directoryScreen.sortQuery=false;
      }
    }
  }
  
  void draw(){
    if(mouseOver()) stroke(255);
    else stroke(0);
    fill(colour);
    if(mode==3 || mode==4 || mode==5) strokeWeight(5);
    else strokeWeight(2);
    rect(x, y, w, h, 8);
    textSize(24);
    if(mode==1){
      fill(240);
      text("Clear", x+22, y+33);
    }
    else if(mode==2){
      fill(240);
      text("Back", x+26, y+33);
    }
    else if(mode==3){
      fill(0);
      textSize(100);
      textAlign(CENTER);
      text("Directory", x+(w/2), y+(h/2)+(100/3));
      textAlign(LEFT);
      strokeWeight(1);
    }
     else if(mode==4){
      fill(0);
      textSize(100);
      textAlign(CENTER);
      text("Graphs", x+(w/2), y+(h/2)+(100/3));
      textAlign(LEFT);
      strokeWeight(1);
    }
    else if(mode==5){
      fill(0);
      textSize(100);
      textAlign(CENTER);
      text("Exit", x+(w/2), y+(h/2)+(100/3));
      textAlign(LEFT);
      strokeWeight(1);
    }
    else if(mode==6){
      fill(240);
      text("Sort", x+28, y+33);
    }
    else if(mode==7){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Lateness", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==8){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Distance", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==9){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Date", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==10){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Enter", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==11){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Cancelled", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==12){
      fill(20);
      textSize(40);
      textAlign(CENTER);
      text("Diverted", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==13){
      fill(20);
      textSize(20);
      textAlign(CENTER);
      text("Cancel", x+(w/2), y+(h/2)+(20/3));
      textAlign(LEFT);
    }
  }

}

class Return{
  int x, y, w, h;
  Return(){
    x=width-160;
    y=15;
    w=100;
    h=40;
  }
  
  boolean mouseOver(){
    if(mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h){
      return true;
    }
    else return false;
  }
  
  void returnPressed(){
    if(mouseOver()){
      screenManager.switchScreen(mainMenuScreen);
    }
  }
  
  void draw(){
    if(mouseOver()) stroke(255);
    else stroke(0);
    fill(#764838);
    rect(x, y, w, h, 4);
    stroke(0);
    fill(230);
    textSize(26);
    text("Menu", x+20, y+28);
  }
}

class Slider{
    int x, y, xS, sWidth, sHeight, textX, sliderLength;
    float yS, number;
    boolean mouseDown, hover;
    
    Slider(int xIn, int yIn, int length){
      x=xIn;
      y=yIn;
      xS=x-10;
      yS=y+10;
      sWidth=10;
      sHeight=30;
      sliderLength=length;
      mouseDown=false;
      hover=false;
    }
    
    boolean mouseOver(){
      if(mouseX>xS && mouseX<xS+sHeight && mouseY>yS && mouseY<yS+sWidth){
        return true;
      }
      else return false;
    }
    
    void sliderPressed(){
      if(mouseOver()) mouseDown=true;
    }
  
    void sliderReleased(){
      mouseDown=false;
    }
    
    void move(){
      if(mouseDown) yS=mouseY-5;
      if(yS<y+10) yS=y+10;
      if(yS>y+sliderLength-20) yS=y+sliderLength-20;
    }
    
    float getPercent(){
      float percent = (number/(sliderLength-30));
      if(percent>0.9999) return(0.9999);
      //println(percent);
      return(percent);
    }
    
    void scroll(float direction){
      yS+=direction/arrayIndex.size()*1000;
      if(yS<y+10) yS=y+10;
      if(yS>y+sliderLength-20) yS=y+sliderLength-20;
    }
    
    void draw(){
      move();
      strokeWeight(2);
      fill(190);
      stroke(30);
      rect(x, y, 10, sliderLength);
      fill(120);
      if(hover) stroke(255);
      else stroke(0);
      rect(xS, yS, 30, 10);
      number=(yS-10-y);
      //println("number("+number+") : sliderLength("+sliderLength+") : yS("+yS+") : yS-y("+(yS-y)+")");
    }
}


class DateSelector{
  int x, y;
  String date1, date2;
  Widget done;
  Search search1, search2;

  DateSelector(){
    x=450;
    y=500;
    date1="01/01/2017";
    date2="31/12/2017";
    
    search1 = new Search(width/2-280-50, y+height/10, 24, 2);
    search2 = new Search(width/2+50, y+height/10, 24, 3);
    done = new Widget(width/2-100, y+height/4, 10, 200, 100, #01204E);
  }


  void draw(){
    textSize(40);
    stroke(0);
    fill(0);
    text(":", width/2-3, y+height/10+(33));
    search1.draw();
    search2.draw();
    done.draw();
  }


}

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

class Query{
  int x, y, colour, mode;
  Widget lateness, distance, date, cancelled, diverted, cancel;
  DateSelector selector;
  
  
  Query(int colour, int mode){
    x=500;
    y=400;
    this.colour=colour;
    this.mode=mode;
    if(mode==1){
      lateness = new Widget(width/2-(width/10)*2, y+160, 7, width/10, height/16, #F57F5B);
      distance = new Widget(width/2-width/20, y+160, 8, width/10, height/16, #764838);
      date = new Widget(width/2+width/10, y+160, 9, width/10, height/16, #FAA968);
      
      cancelled = new Widget(width/2-(width/10)*2, (y+160)+height/8, 11, width/10, height/16, #028391);
      diverted = new Widget(width/2-width/20, (y+160)+height/8, 12, width/10, height/16, #FAECB6);
    }
    else if(mode==2){
      selector = new DateSelector();
    }
    cancel = new Widget(width/2-width/40, (y+160)+height/3, 13, width/20, height/32, #99AAAA);
  }


  void draw(){
    strokeWeight(4);
    stroke(0);
    fill(colour);
    rect(x, y, width-2*x, height-y-100, 6);
    
    strokeWeight(2);
    if(mode==1){
      lateness.draw();
      distance.draw();
      date.draw();
      cancelled.draw();
      diverted.draw();
    }
    else if(mode==2){
      selector.draw();
    }
    cancel.draw();
  }

}

class Search{
  int x, y, textSize, sHeight, sWidth;
  int animation, mode;
  boolean search;
  
  Search(int x, int y, int textSize, int mode){
    this.x=x;
    this.y=y;
    this.textSize=textSize;
    this.mode=mode;
    sHeight=50;
    sWidth=280;
    animation=0;
    clearInput();
  }

  boolean mouseOver(){
    if(mouseX>x && mouseX<x+sWidth && mouseY>y && mouseY<y+sHeight){
      return true;
    }
    else return false;
  }
  
  void searchPressed(){                                  //determines if the user clicked on the search bar
    if(mouseOver()){
      clearInput();
      search=true;
    }
    else search=false;
  }

  void draw(){
    if(mouseOver()) stroke(255);
    else stroke(0);
    fill(200);
    rect(x, y, sWidth, sHeight, 8);
    fill(0);
    textSize(25);
    if(mode==1){
      if(!search){                                          //code for showing either "search" or the users currently typed in characters
        text("Search", x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("Search_", x+20, y+33);
            animation++;
          }
          else{
            text("Search", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }
    }
    else if(mode==2){
      if(!search){                                          
        text(directoryScreen.dateMenu.selector.date1, x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("_", x+20, y+33);
            animation++;
          }
          else{
            text("", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }
    }
    else if(mode==3){
      if(!search){                                          
        text(directoryScreen.dateMenu.selector.date2, x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("_", x+20, y+33);
            animation++;
          }
          else{
            text("", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }
    }
    
    
    
    if(entered && mode==1 && search){                                      //when the user enters (from keyPressed() in main) it calls the search method
      directoryScreen.search(inputText);                      //with the user input and resets the search bar
      entered=false;
      search=false;
    }
    if(entered && mode==2 && search){
      directoryScreen.dateMenu.selector.date1=inputText;
      entered=false;
      search=false;
    }
    if(entered && mode==3 && search){
      directoryScreen.dateMenu.selector.date2=inputText;
      entered=false;
      search=false;
    }
  }
    
}

class Header{
  int mode, x, y, w, h, textSize, opacity;
  String name, title;
  boolean clicked, direction;                                            //direction=true  -> sort high to low

  Header(int x, int y, String name, int textSize, int mode){
    this.mode=mode;
    this.x=x;
    this.y=y;
    this.name=name;
    this.textSize=textSize;
    this.title=name;
    w=120;
    h=textSize;
  }
  
  boolean mouseOver(){
    if(mouseX>x-(w/2) && mouseX<x+(w/2) && mouseY>y-(textSize*1/3)-(h/2) && mouseY<y-(textSize*1/3)+(h/2)){
      return true;
    }
    else return false;
  } 
  
  void headerPressed(){
    if(mouseOver()){
      //DirectoryScreen.clearHeaders();
      clicked=true;
      direction=!direction;
      if(mode==1) sortByDate();
    }
  }

  void draw(){
    rectMode(CENTER);
    textAlign(CENTER);
    if(clicked || mouseOver()) opacity=225;
    else opacity=0;
    if(clicked && direction) title=name+"↑";
    else if(clicked && !direction) title=name+"↓";
    else title=name;
    
    textSize(textSize);
    noStroke();
    fill(160, 160, 160, opacity);
    rect(x, y-(textSize*1/3), w, h, 5);
    fill(20);
    text(title, x, y);
    
    textAlign(LEFT);
    rectMode(CORNER);
  }
  
  
  
  void sortByDate(){
    arrayIndex.sort(Integer::compareTo);                              //ascending order
    if(!direction) arrayIndex.sort(Collections.reverseOrder());        //descending order
  }

  void sortByFlight(){
    ArrayList<Flight> inUseFlights = new ArrayList<>();
    for (int index : arrayIndex) {
      inUseFlights.add(flights.get(index));
    }

    //inUseFlights.sort(Comparator.comparingStr(Flight::getFlightCode));

       
    for (int i = 0; i < arrayIndex.size(); i++) {
      flights.set(arrayIndex.get(i), inUseFlights.get(i));
    }

  }

}
