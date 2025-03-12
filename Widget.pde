class Widget{
  int x, xe, y, mode, widthx, heighty;
  String name;
  boolean hover, pressed;
  
  Widget(int xIn, int yIn, String nameIn, int modeIn){
    x=xIn;
    y=yIn;
    name=nameIn;
    mode=modeIn;
    widthx=100;
    heighty=50;
  }
  
  boolean mouseOver(){
    if(mouseX>xe && mouseX<xe+widthx && mouseY>y && mouseY<y+heighty){
      return true;
    }
    else return false;
  }
  
  void moved(){
    if(mouseOver()){
      hover=true;
    }
    else hover=false;
  }
  
  void pressed(){
    if(currentScreen==1 && mouseOver()){
      if(mode==1){
        screen1.clear();
        println("pressed");
        screen1.searchAirport();
        pressed=true;
      }
      if(mode==2){
        println("pressed");
        screen1.clear();
      }
      if(mode==3){
        screen1.sortOrigin=true;
      }
      if(mode==4){
        screen1.sortOrigin=false;
      }
      if(mode==5){
        screen1.clear();
        screen1.lateSort();
        screen1.sortButton=true;
      }
      if(mode==6){
        lowHigh=true;
        resort();
      }
      if(mode==7){
        lowHigh=false;
        resort();
      }
      if(mode==9){
        screen1.phase=0;
        screen1.clear();
        pressed=true;
        screen1.dateFilter=true;
        inputText="";
        screen1.input1="";
        screen1.input2="";
      }
    }
    else if(mouseOver() && currentScreen==2){
      if(mode==8){
        currentScreen=1;
      }
      
    }
  }
  
  void draw(){
    if(currentScreen==1){
      stroke(0);
      if(hover || pressed) fill(180);
      else if(mode==3 && screen1.sortOrigin) fill(200);
      else if(mode==4 && !screen1.sortOrigin) fill(200);
      else if(mode==5 && screen1.sortButton) fill(180);
      else if(mode==6 && lowHigh) fill(200);
      else if(mode==7 && !lowHigh) fill(200);
      else fill(230);
      if(mode==5 && screen1.arrayMode==2) xe=x+300;
      else if(mode==9 && (screen1.arrayMode==2 || screen1.arrayMode==3)) xe=x+300;
      else xe=x;
      rect(xe, y, widthx, heighty);
      fill(0);
      textSize(15);
      text(name, xe+(170/name.length()), y+30);
    }
    else if(currentScreen==2){
      stroke(0, 240, 0);
      if(hover) fill(140);
      else fill(90);
      xe=x;
      rect(xe, y, widthx, heighty);
      fill(0, 240, 0);
      textSize(15);
      text(name, xe+(170/name.length()), y+30);
    }
  }

}
