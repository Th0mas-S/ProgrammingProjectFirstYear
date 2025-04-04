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
