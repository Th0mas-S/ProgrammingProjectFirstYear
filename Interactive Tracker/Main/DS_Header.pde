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
      directoryScreen.clearHeaders();
      clicked=true;
      direction=!direction;
      if(mode==1) sortByDate();
      if(mode==2) sortFlightsInUse(flights, arrayIndex);
      if(mode==3) sortFlightsByOrigin(flights, arrayIndex);
      if(mode==4) sortFlightsBySDeparture(flights, arrayIndex);
      if(mode==5) sortFlightsByADeparture(flights, arrayIndex);
      if(mode==6) sortFlightsByDelay(flights, arrayIndex);
      if(mode==7) sortFlightsByDiverted(flights, arrayIndex);
      if(mode==8) sortFlightsByCancelled(flights, arrayIndex);
      if(mode==9) sortFlightsByDistance(flights, arrayIndex);
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
    fill(255);
    text(title, x, y);
    
    textAlign(LEFT);
    rectMode(CORNER);
  }
  
  
  
  void sortByDate(){
    arrayIndex.sort(Integer::compareTo);                              //ascending order
    if(!direction) arrayIndex.sort(Collections.reverseOrder());        //descending order
  }

  void sortFlightsInUse(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        // Sort arrayIndex based on the identifier of corresponding flights
        
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).identifier));
        if(!direction) Collections.reverse(arrayIndex); 
  }

  void sortFlightsByOrigin(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        // Sort arrayIndex based on the 'origin' field of corresponding flights
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).origin));
        if(!direction) Collections.reverse(arrayIndex);
  }
  
  void sortFlightsBySDeparture(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).scheduledDeparture));
        if(!direction) Collections.reverse(arrayIndex);
  }
  
  void sortFlightsByADeparture(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).actualDeparture));
        if(!direction) Collections.reverse(arrayIndex);
  }
  
  void sortFlightsByDelay(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).departureDelay));
        if(!direction) Collections.reverse(arrayIndex);
  }
  
  void sortFlightsByDiverted(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).diverted));
        if(!direction) Collections.reverse(arrayIndex);
  }
  
  void sortFlightsByCancelled(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).cancelled));
        if(!direction) Collections.reverse(arrayIndex);
  }
  
  void sortFlightsByDistance(ArrayList<Flight> flights, ArrayList<Integer> arrayIndex) {
        arrayIndex.sort(Comparator.comparing(index -> flights.get(index).flightDistance));
        if(!direction) Collections.reverse(arrayIndex);
  }









}
