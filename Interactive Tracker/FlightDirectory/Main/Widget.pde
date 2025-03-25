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
        screen1.searchbar.search=false;
        clearInput();
        clearIndex();
      }
      else if(mode==2){
        currentScreen=1;
      }
      if(mode==3){
        currentScreen=1;
      }
      if(mode==4){
        currentScreen=3;
      }
      if(mode==5){
        exit();
      }
      if(mode==6){
        screen1.sortQuery=true;
      }
      if(mode==7){
        screen1.sortByLateness();
        screen1.sortQuery=false;
      }
      if(mode==8){
        screen1.sortByDistance();
        screen1.sortQuery=false;
      }
      if(mode==9){
        screen1.sortQuery=false;
        screen1.dateQuery=true;
      }if(mode==10){
        screen1.sortByDate(screen1.dateMenu.selector.date1, screen1.dateMenu.selector.date2);
        screen1.dateQuery=false;
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
      text("Lateness", x+30, y+60);
    }
    else if(mode==8){
      fill(240);
      textSize(40);
      text("Distance", x+30, y+60);
    }
    else if(mode==9){
      fill(240);
      textSize(40);
      text("Date", x+60, y+60);
    }
    else if(mode==10){
      fill(240);
      text("Done", x+27, y+33);
    }
  }

}
