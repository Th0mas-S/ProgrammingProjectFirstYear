class Graphs {
  int buttonX = 20;
  int buttonY = 20;
  int buttonWidth = 100;
  int buttonHeight = 70;
  
  // Back button properties
  int backButtonX = 320;
  int backButtonY = 20;
  int backButtonWidth = 100;
  int backButtonHeight = 70;
  
  boolean screen1 = true;
  boolean screen2 = false;
  
  // Sample data for the graph
  int[] data = {10, 20, 30, 20, 40, 60, 50, 70, 80};

  Graphs() {
  }
  
  // This method is called only when the mouse is clicked
  void checkButtonPressed(int mx, int my) {
    // Check if test button is clicked (on screen1)
    if (screen1 && mx > buttonX && mx < buttonX + buttonWidth &&
        my > buttonY && my < buttonY + buttonHeight) {
      screen1 = false;
      screen2 = true;
    }
    // Check if back button is clicked (on screen2)
    else if (screen2 && mx > backButtonX && mx < backButtonX + backButtonWidth &&
             my > backButtonY && my < backButtonY + backButtonHeight) {
      screen2 = false;
      screen1 = true;
    }
  }
  
  // Graph display code for screen2
  void graphScreen() {
    background(255);
    
    // Draw axes (imagine the vertical Y and horizontal X axes)
    stroke(0);
    line(50, 50, 50, 300);  // Y-axis
    line(50, 300, 300, 300); // X-axis
    
    // Plot data points and connect them with lines
    for (int i = 0; i < data.length - 1; i++) {
      float x1 = 50 + i * 30;
      float y1 = 300 - data[i] * 3;  // scale data for better view
      float x2 = 50 + (i + 1) * 30;
      float y2 = 300 - data[i + 1] * 3;
      
      // Connect the points with a blue line
      stroke(0, 0, 255);
      line(x1, y1, x2, y2);
      
      // Draw a small red circle at the data point
      fill(255, 0, 0);
      ellipse(x1, y1, 5, 5);
    }
    // Plot the final data point
    ellipse(50 + (data.length - 1) * 30, 300 - data[data.length - 1] * 3, 5, 5);
    
    // Add a title to the graph screen
    fill(0);
    text("Graph Screen", 150, 30);
    
    // Draw the back button
    drawBackButton();
  }

  // Draws the test button on screen1
  void drawButton() {
    fill(200); 
    rect(buttonX, buttonY, buttonWidth, buttonHeight); 
    fill(0); 
    text("test button", buttonX + buttonWidth / 4, buttonY + buttonHeight / 2);
  }
  
  // Draws the back button on screen2
  void drawBackButton() {
    fill(200);
    rect(backButtonX, backButtonY, backButtonWidth, backButtonHeight);
    fill(0);
    text("back", backButtonX + backButtonWidth / 4, backButtonY + backButtonHeight / 2);
  }
  
  // This should be called from Processing's mousePressed() event
  void mousePressed() {
    checkButtonPressed(mouseX, mouseY);
  }
  
  // Call this from Processing's draw() loop
  void draw() {
    if (screen1) {
      background(255);
      drawButton();
    } else if (screen2) {
      graphScreen();
    }
  }
}
