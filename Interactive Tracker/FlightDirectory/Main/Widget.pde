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
  }

}
