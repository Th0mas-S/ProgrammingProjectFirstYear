
class ButtonSettings {
  int x = 0;
  int y = 0;
  int w = 200;
  int h = 200;
  color col = color(255);
  String text = "test";
  color textColor = color(0);
  Runnable onClick;
  
  ButtonSettings() {
  }
  
  ButtonSettings setX(int x) {
    this.x = x;
    return this;
  }
  
  ButtonSettings setY(int y) {
    this.y = y;
    return this;
  }
  
  ButtonSettings setWidth(int w) {
    this.w = w;
    return this;
  }
  
  ButtonSettings setHeight(int h) {
    this.h = h;
    return this;
  }
  
  ButtonSettings setColor(color c) {
    col = col;
    return this;
  }
  
  ButtonSettings setTextColor(color textColor) {
    this.textColor = textColor;
    return this;
  }
  
  ButtonSettings setOnClick(Runnable onClick) {
    this.onClick = onClick;
    return this;
  }
  
  Button build() {
    return new Button(this);
  }
  
}

class Button {
  
  ButtonSettings s;
  
  Button(ButtonSettings settings) {
    this.s = settings;
  }
  
  void draw() {
    fill(s.col);
    rect(s.x, s.y, s.w, s.h);
    
    fill(s.textColor);
    textAlign(CENTER);
    text(s.text, s.x + s.w / 2, s.y + s.h / 2);
  }
  
   boolean isMouseOverRect(float x, float y, float w, float h) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  void handleOnClick() {
    if(isMouseOverRect(s.x, s.y, s.w, s.h)) {
      s.onClick.run();
    }
  }
   
}
