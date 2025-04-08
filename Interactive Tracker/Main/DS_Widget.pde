class Widget {
  int x, y, mode, w, h;
  int colour;
  
  Widget(int x, int y, int mode, int w, int h, int colour) {
    this.x = x;
    this.y = y;
    this.mode = mode;
    this.w = w;
    this.h = h;
    this.colour = colour;
  }
  
  boolean mouseOver() {
    return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
  }
  
  void widgetPressed() {
    if (mouseOver()) {
      if (mode == 1) {
        entered = false;
        directoryScreen.searchbar.search = false;
        clearInput();
        clearIndex();
      } else if (mode == 2) {
        screenManager.switchScreen(directoryScreen);
      }
      if (mode == 3) {
        screenManager.switchScreen(directoryScreen);
      }
      if (mode == 4) {
        currentScreen = 3;
      }
      if (mode == 5) {
        exit();
      }
      if (mode == 6) {
        directoryScreen.sortQuery = true;
      }
      if (mode == 7) {
        directoryScreen.sortByLateness();
        directoryScreen.sortQuery = false;
      }
      if (mode == 8) {
        directoryScreen.sortByDistance();
        directoryScreen.sortQuery = false;
      }
      if (mode == 9) {
        directoryScreen.sortQuery = false;
        directoryScreen.dateQuery = true;
      }
      if (mode == 10) {
        directoryScreen.sortByDate(directoryScreen.dateMenu.selector.date1, directoryScreen.dateMenu.selector.date2);
        directoryScreen.dateQuery = false;
      }
      if (mode == 11) {
        directoryScreen.filterCancelled();
        directoryScreen.sortQuery = false;
      }
      if (mode == 12) {
        directoryScreen.filterDiverted();
        directoryScreen.sortQuery = false;
      }
      if (mode == 13) {
        directoryScreen.dateQuery = false;
        directoryScreen.sortQuery = false;
        directoryScreen.airportQuery = false;
      }
      if (mode == 14) {
        directoryScreen.airportQuery = true;
        directoryScreen.sortQuery = false;
      }
      if (mode == 15) {
        directoryScreen.airportMenu.airportSelector.sortOrigin();
        directoryScreen.airportQuery = false;
      }
      if (mode == 16) {
        directoryScreen.airportMenu.airportSelector.sortDestination();
        directoryScreen.airportQuery = false;
      }
      if (mode == 17) {
        // handled in flightInfo screen
      }
    }
  }
  
  void draw() {
    // Set stroke based on mouse over state.
    if (mouseOver()) {
      stroke(255);
    } else {     
      stroke(0);
      if (mode == 17) stroke(80);
    }
    
    // Define blue color (same as used for stroke elsewhere).
    int blueColor = color(135, 206, 235, 150);
    // Use blue background for all buttons except the sort button (mode 6 retains its original colour).
    if (mode != 6) {
      fill(blueColor);
    } else {
      fill(colour);
    }
    
    // Set stroke weight.
    if (mode == 3 || mode == 4 || mode == 5) strokeWeight(5);
    else strokeWeight(3);
    
    // Draw the button background.
    rect(x, y, w, h, 8);
    
    textSize(24);
    fill(255);  // White text for all buttons
    
    // For "Clear" (mode 1) and "Back" (mode 2) use CORNER alignment.
    if (mode == 1) {
      textAlign(CORNER, CORNER);
      text("Clear", x + 22, y + 33);
    }
    else if (mode == 2) {
      textAlign(CORNER, CORNER);
      text("Back", x + 26, y + 33);
    }
    // For large buttons use CENTER alignment.
    else if (mode == 3) {
      textSize(100);
      textAlign(CENTER, CENTER);
      text("Directory", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
      strokeWeight(1);
    }
    else if (mode == 4) {
      textSize(100);
      textAlign(CENTER, CENTER);
      text("Graphs", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
      strokeWeight(1);
    }
    else if (mode == 5) {
      textSize(100);
      textAlign(CENTER, CENTER);
      text("Exit", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
      strokeWeight(1);
    }
    // Sort button (mode 6) uses CORNER alignment.
    else if (mode == 6) {
      textAlign(CORNER, CORNER);
      text("Sort", x + 28, y + 33);
    }
    // For query buttons and cancel button (modes 7–17), use CENTER alignment without extra offset.
    else if (mode == 7) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Lateness", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 8) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Distance", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 9) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Date", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 10) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Enter", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 11) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Cancelled", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 12) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Diverted", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 13) {
      textSize(20);
      textAlign(CENTER, CENTER);
      text("Cancel", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 14) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Airports", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 15) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Origin", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 16) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Destination", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
    else if (mode == 17) {
      textSize(40);
      textAlign(CENTER, CENTER);
      text("Visualize flight... ", x + (w / 2), y + (h / 2));
      textAlign(CORNER, CORNER);
    }
  }
}

class Return {
  int x, y, w, h;
  Return() {
    x = width - 160;
    y = 15;
    w = 100;
    h = 40;
  }
  
  boolean mouseOver() {
    return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
  }
  
  void returnPressed() {
    if (mouseOver()) {
      screenManager.switchScreen(mainMenuScreen);
    }
  }
  
  void draw() {
    if (mouseOver()) stroke(255);
    else {
      stroke(0);
    }
    // Use blue background for the menu button.
    fill(color(135, 206, 235, 150));
    rect(x, y, w, h, 4);
    stroke(0);
    fill(230);
    textSize(26);
    textAlign(CORNER, CORNER);
    text("Menu", x + 20, y + 28);
  }
}

class BackButton {
  int x, y, w, h;
  
  BackButton() {
    x = width - 275;
    y = 15;
    w = 100;
    h = 40;
  }
  
  boolean mouseOver() {
    return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
  }
  
  void backPressed() {
    if (mouseOver()) {
      screenManager.switchScreen(screenBetweenScreens);
    }
  }
  
  void draw() {
    if (mouseOver()) {
      stroke(255);
    } else {
      stroke(0);
    }
    // Use the same blue background as the Menu button.
    fill(color(135, 206, 235, 150));
    rect(x, y, w, h, 4);
    stroke(0);
    fill(230);
    textSize(26);
    textAlign(CORNER, CORNER);
    text("Back", x + 24, y + 28);
  }
}
