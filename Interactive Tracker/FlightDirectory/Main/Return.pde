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
      currentScreen=0;
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
