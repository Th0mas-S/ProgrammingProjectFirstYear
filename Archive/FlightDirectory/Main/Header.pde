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
      screen1.clearHeaders();
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
