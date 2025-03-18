class Screen{
  int screenNum, arrayMode, phase;
  Slider slider;
  ArrayList<Widget> widgets;
  Search search, search1;
  String input, orAirport, destAirport, currentCarrier, input1, input2;
  boolean sortOrigin, sortButton, dateFilter;
  ArrayList<Query> querys;

  Screen(int ScreenNumber){
    widgets = new ArrayList<Widget>();
    querys = new ArrayList<Query>();
    dateFilter=false;
    screenNum=ScreenNumber;
    if(screenNum==1){
      slider = new Slider(1735, 350);
      widgets.add(new Widget(320, 50, "Search", 1));
      widgets.add(new Widget(200, 50, "Clear", 2));
      widgets.add(new Widget(440, 50, "Sort", 5));
      widgets.add(new Widget(560, 50, "Dates", 9));
      search = new Search(1);
      search1 = new Search(2);
      arrayMode=1;
      querys.add(new Query(450, 25, 1));
      querys.add(new Query(570, 25, 2));
      sortOrigin=true;
    }
    if(screenNum==2){
      widgets.add(new Widget(120, 60, "Return", 8));
    }
  }
  
  void display(Flight flight){
    currentFlight=flight;
    screen2.orAirport = getAirport(currentFlight.origin);
    screen2.destAirport = getAirport(currentFlight.destination);
    screen2.currentCarrier = getCarrier(currentFlight.carrier);
    currentScreen=2;
  }
  
  String getAirport(String airport){
    for(int i=0; i<airportCode.size(); i++){
      if(airportCode.get(i).equals(airport)) return airportName.get(i);
    }
    return("error");
  }
  
  String getCarrier(String carrier){
    for(int i=0; i<airlineCode.size(); i++){
      if(airlineCode.get(i).equals(carrier)) return airlineName.get(i);
    }
    return("error");
  }
  
  void screenMousePressed(){
    if(currentScreen==1){
      slider.pressed();
      for(int i=0; i<widgets.size(); i++){
        widgets.get(i).pressed();
      }
      if(arrayMode==1){
        int counter=0;
        for(float i=(flData.size()*slider.getPercent()); (i<flData.size() && counter<25); i++){
          if(flData.get(int(i)).clicked()) display(flData.get(int(i)));
          counter++;
        } 
      }
      if(arrayMode==2){
        querys.get(0).pressed();
        int counter=0;
        for(float i=(flData.size()*slider.getPercent()); (i<flData.size() && counter<25); i++){
          if(sortOrigin){
            if(flData.get(int(i)).origin.equalsIgnoreCase(input)){
              if(flData.get(int(i)).clicked()) display(flData.get(int(i)));
              counter++;
            }
          }
        }
      }
      
      if(arrayMode==3){
        querys.get(1).pressed();
        int counter=0;
         for(float i=(currentSortOrder.size()*slider.getPercent()); (i<currentSortOrder.size() && counter<25); i++){
          int j = int(currentSortOrder.get(int(i)));
          if(flData.get(j).clicked()) display(flData.get(j));
          counter++;
        }
      }
      
      if(arrayMode==4){
        //querys.get(1).pressed();
        int counter=0;
         for(float i=(dateRange.size()*slider.getPercent()); (i<dateRange.size() && counter<25); i++){
          int j = int(dateRange.get(int(i)));
          if(flData.get(j).clicked()) display(flData.get(j));
          counter++;
        }
      }
    }
    else if(currentScreen==2){
      for(int i=0; i<widgets.size(); i++){
        widgets.get(i).pressed();
      }
    }
  }
  
  void screenMouseMoved(){
    if(currentScreen==1){
      if(slider.mouseOver()) slider.hover=true;
      else slider.hover=false;
      for(int i=0; i<widgets.size(); i++){
        widgets.get(i).moved();
      }
      if(arrayMode==2) querys.get(0).moved();
      if(arrayMode==3) querys.get(1).moved();
    }
    else if(currentScreen==2){
      for(int i=0; i<widgets.size(); i++){
        widgets.get(i).moved();
      }
    }
  }
  
  void drawWidgets(){
    for(int i=0; i<widgets.size(); i++){
      widgets.get(i).draw();
    }
  }
  
  void printArray(ArrayList<Flight> flData, Slider slider){
    int counter=0;
    for(float i=(flData.size()*slider.getPercent()); (i<flData.size() && counter<25); i++){
      flData.get(int(i)).dataLocation(120, 230+(27*int(counter)));
      counter++;
      flData.get(int(i)).draw();
    }
  }  
  
  void clear(){
    arrayMode=1;
    dateFilter=false;
    search.searchB=false;
    sortButton=false;
    lowHigh=true;
    resort();
    input="";
    for(int i=0; i<widgets.size(); i++){
      widgets.get(i).pressed=false;
    }
  }
  
  void searchAirport(){
    sortOrigin=true;
    input="";
    arrayMode=2;
    search.searchB=true;
    inputText="";
  }
  
  void filterAirport(){
    input=getInput();
    inputText="";
    //print(flData.get(1).origin+""+input);
  }
  
  void lateSort(){
    arrayMode=3;  
  }
  
  void sortByDate(){
    if(phase==0 && entered){
      input1=getInput();
      entered=false;
      phase++;
      inputText="";
    }
    else if(phase==1 && entered){
      input2=getInput();
      entered=false;
      phase++;
      inputText="";
    }
    else if(phase==2){
      dateSort(input1, input2);
      arrayMode=4;
      phase=0;
      entered=false;
    }
  }
  
  void printArraySearch2(ArrayList<Flight> flData, Slider slider){
    querys.get(0).draw();
    int counter=0;
    for(float i=(flData.size()*slider.getPercent()); (i<flData.size() && counter<25); i++){
      if(sortOrigin){
        if(flData.get(int(i)).origin.equalsIgnoreCase(input)){
          flData.get(int(i)).dataLocation(120, 230+(27*int(counter)));
          counter++;
          flData.get(int(i)).draw();
        }
      }
      else{
        if(flData.get(int(i)).destination.equalsIgnoreCase(input)){
          flData.get(int(i)).dataLocation(120, 230+(27*int(counter)));
          counter++;
          flData.get(int(i)).draw();
        }
      }
    }
  }  
  
  void printArraySorted(ArrayList<Flight> flData, Slider slider, ArrayList<Integer> sortOrder){
    int counter=0;
    //println(sortOrder.get(1));
    for(float i=(sortOrder.size()*slider.getPercent()); (i<sortOrder.size() && counter<25); i++){
      int j = int(sortOrder.get(int(i)));
      flData.get(j).dataLocation(120, 230+(27*counter));
      counter++;
      flData.get(j).draw();
    }
  }
  
  

  void draw(){
    //println(arrayMode);
    if(currentScreen==1){
      background(#F3FA9C);
      drawGrid();
      if(dateFilter){
        search1.draw();
        sortByDate();
      }
    
      if(arrayMode==1) printArray(flData, slider);
      else if(arrayMode==2) printArraySearch2(flData, slider);
      else if(arrayMode==3){
       printArraySorted(flData, slider, currentSortOrder);
       querys.get(1).draw();
      }
      else if(arrayMode==4){
       printArraySorted(flData, slider, dateRange);
      }
      slider.draw();
      search.draw();
      drawWidgets();
    
      if(entered){
        filterAirport();
        entered=false;
      }
    }
    else if(currentScreen==2){
      background(0);
      fill(20);
      strokeWeight(6);
      stroke(0, 140, 0);
      rect(100, 200, 1700, 700);
      drawWidgets();
      //currentFlight.draw();
      drawData(orAirport, destAirport);
    }
  }
  
  void drawData(String orPort, String destPort){
    textSize(25);
    text("Origin:                "+currentFlight.orCity, 900, 250);
    text("From:      "+currentFlight.origin+" / "+orPort, 1360, 250);
    text("Destination:     "+currentFlight.destCity, 900, 300);
    text("To:            "+currentFlight.destination+" / "+destPort, 1360, 300);
    text("Scheduled Departure:    "+currentFlight.depTimeE, 140, 400+100);
    text("Scheduled Arrival:            "+currentFlight.arrTimeE, 140, 450+100);
    text("Actual Departure:             "+currentFlight.depTime, 140, 520+100);
    text("Actual Arrival:                     "+currentFlight.arrTime, 140, 570+100);
    text("Delayed:    "+currentFlight.minsLate+"mins", 140, 640+100);
    text("Flight Number:  "+currentFlight.carrier+" "+currentFlight.flNumber, 140, 250);
    text("Carrier:  "+currentCarrier, 140, 300);
    text("Date:  "+currentFlight.date, 550, 250);
    text("Flight Distance:  "+currentFlight.flDistance+"mi", 900, 500);
  }
  
  void drawGrid(){
    fill(0);
    textSize(20);
  
    text("Date", 140, 190);
    text("Carrier", 228, 190);
    text("Origin", 438, 190);
    text("WAC", 605, 190);
    text("Destination", 770, 190);
    text("Est Dep", 1010, 190);
    text("Dep", 1110, 190);
    text("Est Arr", 1183, 190);
    text("Arr", 1280, 190);
    text("Cannceled", 1350, 190);
    text("Diverted", 1480, 190);
    text("Distance", 1590, 190);
  
    fill(210);
    strokeWeight(6);
    stroke(0);
    rect(100, 200, 1700, 700);
  
    strokeWeight(1);
    rect(100, 200, 165, 700);  //date
    rect(215, 200, 90, 700);   //airport
    rect(295, 200, 50, 700);   //Carrier
    rect(345, 200, 260, 700);  //Origin
    rect(605, 200, 40, 700);   //WAC
    rect(645, 200, 58, 700);   //airport
    rect(703, 200, 260, 700);  //Destiation
    rect(963, 200, 40, 700);   //WAC
    rect(1003, 200, 83, 700);  //times
    rect(1086, 200, 83, 700);
    rect(1169, 200, 83, 700);
    rect(1252, 200, 83, 700);
    rect(1335, 200, 120, 700); //Cancelled
    rect(1455, 200, 120, 700); //Delayed
    rect(1575, 200, 100, 700);  //Distance
    rect(1675, 200, 125, 700);  //Slider
  
  }



}
