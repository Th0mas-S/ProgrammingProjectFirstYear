
class Screen {
  void draw() {}
  void mousePressed() {}
  void mouseDragged() {}
  void mouseReleased() {}
  void mouseMoved() {}
  void mouseWheel(MouseEvent event) {}
  void keyPressed() {}
}

class ScreenManager {
  Screen currentScreen;
  Screen previousScreen;

  ScreenManager() {
  }
  
  void switchScreen(Screen screen) {
    previousScreen = currentScreen;
    currentScreen = screen;
  }
  
  void drawScreen() {
   currentScreen.draw();
  }
  
  void handleMousePressed() {
    if(key == BACKSPACE) {
      currentScreen = previousScreen;
      previousScreen = null;
    } else {
      currentScreen.mousePressed();
    }
  }
  
  void handleMouseReleased() {
    currentScreen.mouseReleased();
  }
  
  void handleMouseDragged() {
    currentScreen.mouseDragged();
  }
  
  void handleMouseWheel(MouseEvent event) {
    currentScreen.mouseWheel(event);
  }
  
  void handleKeyPressed() {
    currentScreen.keyPressed();
  }
  
  void handleMouseMoved() {
    currentScreen.mouseMoved();
  }
}
