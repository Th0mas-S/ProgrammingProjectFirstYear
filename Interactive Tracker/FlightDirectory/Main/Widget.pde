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
    }
  }
  
  void draw(){
    if(mouseOver()) stroke(255);
    else stroke(0);
    fill(colour);
    if(mode==3 || mode==4) strokeWeight(5);
    else strokeWeight(1);
    rect(x, y, w, h, 8);
    textSize(24);
    if(mode==1){
      fill(0);
      text("Clear", x+22, y+33);
    }
    else if(mode==2){
      fill(0);
      text("Back", x+22, y+33);
    }
    else if(mode==3){
      fill(0);
      textSize(100);
      text("Directory", x+100, y+130);
      strokeWeight(1);
    }
    
     else if(mode==4){
      fill(0);
      textSize(100);
      text("Graphs", x+100, y+130);
      strokeWeight(1);
    }
  }

}
