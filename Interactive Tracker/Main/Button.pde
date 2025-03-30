
class ButtonSettings {
  int x = 0;
  int y = 0;
  int w = 200;
  int h = 200;
  color col = color(255);
  String text = "test";
  color textColor = color(0);
  
  ButtonSettings() {
  }
}

class Button {
  
  ButtonSettings s;
  Runnable onClick;
  
  Button(ButtonSettings settings, Runnable onClick) {
    this.s = settings;
    this.onClick = onClick;
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
      this.onClick.run();
    }
  }
   
}
