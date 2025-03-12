class Query{
  int x, y, mode, widthx, heighty;
  Widget originW, destinationW, lowToHigh, highToLow;
  
  Query(int xIn, int yIn, int modeIn){
    x=xIn;
    y=yIn;
    mode=modeIn;
    widthx=260;
    heighty=100;
    if(mode==1){
      originW = new Widget(x+20, y+25, "Origin", 3); 
      destinationW = new Widget(x+140, y+25, "Destination", 4);
    }
    else if(mode==2){
      lowToHigh = new Widget(x+20, y+30, "Low-High", 6);
      highToLow = new Widget(x+140, y+30, "High-Low", 7);
    }
  }
  
  void pressed(){
    if(mode==1){
      originW.pressed();
      destinationW.pressed();
    }
    if(mode==2){
      lowToHigh.pressed();
      highToLow.pressed();
    }
  }
  
  void moved(){
    if(mode==1){
      originW.moved();
      destinationW.moved();
    }
    if(mode==2){
      lowToHigh.moved();
      highToLow.moved();
    }
  }
  
  void draw(){
    stroke(0);
    fill(#FCED9E);
    rect(x, y, widthx, heighty);
    if(mode==1){
      originW.draw();
      destinationW.draw();
    }
    else if(mode==2){
      fill(0);
      textSize(15);
      text("Lateness", x+103, y+20);
      lowToHigh.draw();
      highToLow.draw();
    }
  }

}
