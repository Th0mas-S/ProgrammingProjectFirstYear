class Slider{
    int x, y, xS, sWidth, sHeight, textX, sliderLength;
    float yS, number;
    boolean mouseDown, hover;
    
    Slider(int xIn, int yIn){
      x=xIn;
      y=yIn;
      xS=x-10;
      yS=y+10;
      sWidth=10;
      sHeight=30;
      sliderLength=430;
      mouseDown=false;
      hover=false;
    }
    
    boolean mouseOver(){
      if(mouseX>xS && mouseX<xS+sHeight && mouseY>yS && mouseY<yS+sWidth){
        return true;
      }
      else return false;
    }
    
    void pressed(){
      if(mouseOver()) mouseDown=true;
    }
  
    void SliderMouseReleased(){
      mouseDown=false;
    }
    
    void move(){
      if(mouseDown) yS=mouseY-5;
      if(yS<y+10) yS=y+10;
      if(yS>y+sliderLength-20) yS=y+sliderLength-20;
    }
    
    float getPercent(){
      float percent = number*0.01/4;
      if(percent>0.9999) return(0.9999);
      return(percent);
    }
    
    void scroll(float direction){
      if(flData.size()<2500) yS+=direction;    //for small test file
      else yS+=direction/100;
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
      rect(xS, yS, 30, 10);
      number=(yS-10-y);
    }
  }
