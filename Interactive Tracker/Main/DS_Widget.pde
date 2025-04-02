//Widget and Slider class (at bottom)

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
      if(mode==14){
        directoryScreen.airportQuery=true;
        directoryScreen.sortQuery=false;
      }
      if(mode==15){
        directoryScreen.airportMenu.airportSelector.sortOrigin();
        directoryScreen.airportQuery=false;
      }
      if(mode==16){
        directoryScreen.airportMenu.airportSelector.sortDestination();
        directoryScreen.airportQuery=false;
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
    else if(mode==14){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Airports", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==15){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Origin", x+(w/2), y+(h/2)+(40/3));
      textAlign(LEFT);
    }
    else if(mode==16){
      fill(240);
      textSize(40);
      textAlign(CENTER);
      text("Destination", x+(w/2), y+(h/2)+(40/3));
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
      hint(DISABLE_DEPTH_TEST);
      rect(xS, yS, 30, 10);
      number=(yS-10-y);
      //println("number("+number+") : sliderLength("+sliderLength+") : yS("+yS+") : yS-y("+(yS-y)+")");
      hint(ENABLE_DEPTH_TEST);
    }
}
