import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.*;

class HeatMapScreen extends Screen {

  PImage earthImage;
  final float SCALE = 1; // square size
  final int heatMapOpacity = 115;
  int heatMapWidth = (int)(width / SCALE);
  int heatMapHeight = (int)(height / SCALE);

  PGraphics heatMapLayer;
  int[][] heatMap;
  int medianIntensity = 0;
  
  float scaleFactor = 1.0;
  float offsetX = 0;
  float offsetY = 0;
  float startX, startY;
  boolean isDragging = false;
  
  CalendarDisplay calendar;
  CustomButton menuButton;          // Formerly "backButton", top-right
  CustomButton confirmButton;       // Below the calendar
  CustomButton toggleUIButton;      // "HIDE UI" – also below calendar
  CustomButton showUIButton;        // "SHOW UI" – top-left, only when UI is hidden
  
  boolean hideUI = false;
  boolean isLoading = false; // Flag to indicate loading state
  
  HeatMapScreen() {
    earthImage = loadImage("worldmap.png");
    heatMap = new int[heatMapWidth][heatMapHeight];
    heatMapLayer = createGraphics(width, height);
    
    calendar = new CalendarDisplay();
    generateHeatMap();
    
    int buttonsY = (int)(calendar.y + calendar.h + 10);
    
    // Confirm Button
    CustomButtonSettings bsConfirm = new CustomButtonSettings();
    bsConfirm.x = (int)(calendar.x);
    bsConfirm.y = buttonsY;
    bsConfirm.w = 160;
    bsConfirm.h = 40;
    bsConfirm.col = color(50, 50, 50, 200);
    bsConfirm.textColor = color(255);
    bsConfirm.text = "Confirm";
    bsConfirm.onClick = () -> {
      isLoading = true;
      new Thread(() -> {
         generateHeatMap();
         generateHeatMapLayer();
         isLoading = false;
      }).start();
    };
    confirmButton = bsConfirm.build();
    
    // MENU Button at top right
    CustomButtonSettings bsMenu = new CustomButtonSettings();
    bsMenu.x = width - 165;
    bsMenu.y = 15;
    bsMenu.w = 160;
    bsMenu.h = 40;
    bsMenu.col = color(50, 50, 50, 200);
    bsMenu.textColor = color(255);
    bsMenu.text = "Menu";
    bsMenu.onClick = () -> {
      screenManager.switchScreen(mainMenuScreen);
    };
    menuButton = bsMenu.build();
    
    // Toggle UI Button ("HIDE UI") at original back-button location
    CustomButtonSettings bsToggle = new CustomButtonSettings();
    bsToggle.x = (int)(calendar.x + calendar.w - 160);
    bsToggle.y = buttonsY;
    bsToggle.w = 160;
    bsToggle.h = 40;
    bsToggle.col = color(50, 50, 50, 200);
    bsToggle.textColor = color(255);
    bsToggle.text = "Hide UI";
    // Toggles hideUI but DOES NOT change the button's text
    bsToggle.onClick = () -> {
      hideUI = true;  // Turn UI off
    };
    toggleUIButton = bsToggle.build();
    
    // "SHOW UI" button – only drawn when UI is hidden, top-left corner
    CustomButtonSettings bsShowUI = new CustomButtonSettings();
    bsShowUI.x = 20;
    bsShowUI.y = 20;
    bsShowUI.w = 160;
    bsShowUI.h = 40;
    bsShowUI.col = color(50, 50, 50, 200);
    bsShowUI.textColor = color(255);
    bsShowUI.text = "Show UI";
    bsShowUI.onClick = () -> {
      hideUI = false;  // Turn UI back on
    };
    showUIButton = bsShowUI.build();
    calendar.visible = true;
  }
  
  void draw() {
    background(0);
    
    // Draw the map and heat layer with panning/zooming
    pushMatrix();
      translate(offsetX, offsetY);
      scale(scaleFactor);
      image(earthImage, 0, 0, width, height);
      image(heatMapLayer, 0, 0);
    popMatrix();
    
    drawLegend();
    
    if (!hideUI) {
      // Draw normal UI
      calendar.displayHeatmap();
      menuButton.draw();
      confirmButton.draw();
      toggleUIButton.draw();
    } else {
      // If UI is hidden, show the "SHOW UI" button
      showUIButton.draw();
    }
    
    drawIntensityTab();
    
    float zoomedWidth = width * scaleFactor;
    float zoomedHeight = height * scaleFactor;
    offsetX = constrain(offsetX, width - zoomedWidth, 0);
    offsetY = constrain(offsetY, height - zoomedHeight, 0);
    
    // If loading, overlay a transparent black box with cycling loading text.
    if (isLoading) {
      fill(0, 150);
      noStroke();
      rect(0, 0, width, height);
      
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(32);
      int cycle = (int)((millis() / 1000) % 3); // cycle: 0, 1, or 2
      String loadingText = "";
      if (cycle == 0) {
        loadingText = "Loading.";
      } else if (cycle == 1) {
        loadingText = "Loading..";
      } else {
        loadingText = "Loading...";
      }
      text(loadingText, width / 2, height / 2);
      textAlign(LEFT);
    }
  }
  
  void drawIntensityTab() {
    int zoomedMouseX = (int)(((mouseX - offsetX) / scaleFactor) / SCALE);
    int zoomedMouseY = (int)(((mouseY - offsetY) / scaleFactor) / SCALE);
    
    int[][] offsets = {
      {0, 0}, {1, 0}, {1, -1}, {0, -1},
      {-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}
    };
    
    int intensity = 0;
    for (int[] coordinate : offsets) {
      int idx = zoomedMouseX + coordinate[0];
      int idy = zoomedMouseY + coordinate[1];
      if (idx >= 0 && idx < heatMapWidth && idy >= 0 && idy < heatMapHeight) {
        intensity += heatMap[idx][idy];
      }
    }
    
    int x, y;
    if (!hideUI) {
      // Original position when UI is visible.
      x = (int)calendar.x + 10;
      y = (int)(calendar.y + calendar.h + 50) + 40;
    } else {
      // Moved to top left when UI is hidden.
      x = 20;
      y = 80; 
      // Shift down a bit so it doesn't overlap with the "SHOW UI" button (which is at y=20).
    }
    
    stroke(135, 206, 235, 150);
    strokeWeight(2);
    fill(50, 50, 50, 200);
    rect(10, height - 220, 200, 50, 8);
    noStroke();
    
    fill(255);
    textAlign(CORNER);
    textSize(20);
    text("Flights This Area: " + intensity, 20, height - 190);
  }
  
  void drawLegend() {
    int legendXpos = 10;
    int legendYpos = height - 160;
    stroke(135, 206, 235, 150);
    strokeWeight(2);
    fill(50, 50, 50, 200);
    rect(legendXpos, legendYpos, 250, 100, 8);
    textSize(20);
    noStroke();
    fill(0, 0, 255);
    rect(legendXpos + 10, legendYpos + 10, 20, 20, 8);
    fill(255);
    text("Low intensity: " + ceil((float)medianIntensity / 4.0 * 9.0), legendXpos + 50, legendYpos + 25);
    fill(255, 255, 0);
    rect(legendXpos + 10, legendYpos + 40, 20, 20, 8);
    fill(255);
    text("Median intensity: " + medianIntensity * 9, legendXpos + 50, legendYpos + 55); 
    fill(255, 0, 0);
    rect(legendXpos + 10, legendYpos + 70, 20, 20, 8);
    fill(255);
    text("High intensity: " + medianIntensity * 7 * 9, legendXpos + 50, legendYpos + 85); 
  }
  
  void generateHeatMap() {
    heatMap = new int[heatMapWidth][heatMapHeight];
    int numThreads = Runtime.getRuntime().availableProcessors();
    ExecutorService executor = Executors.newFixedThreadPool(numThreads);
    List<Future<Void>> futures = new ArrayList<>();
    
    ArrayList<Flight> filteredFlights = new ArrayList<Flight>();
    for (Flight f : flights) {
      if (f.date.equals(calendar.getSelectedDate2())) {
        filteredFlights.add(f);    
      }
    }
    
    for (Flight f : filteredFlights) {
      futures.add(executor.submit(() -> {
        processFlight(f);
        return null;
      }));
    }
    
    float futuresDone = 0;
    float startLoadingDone = loadingScreen.loadingDone;
    for (Future<Void> future : futures) {
      try {
        future.get();
        loadingScreen.setLoadingProgress(startLoadingDone + (futuresDone++ / (float)futures.size()) * 0.37);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    executor.shutdown();
    medianIntensity = 0;
    ArrayList<Integer> tempList = new ArrayList<Integer>();
    for (int x = 0; x < heatMapWidth; x++) {
      for (int y = 0; y < heatMapHeight; y++) {
        if (heatMap[x][y] != 0) {
          tempList.add(heatMap[x][y]);
        }
      }
    }
    Collections.sort(tempList);
    if (tempList.size() != 0) {
      if (tempList.size() % 2 == 0)
        medianIntensity = tempList.get(tempList.size() / 2);
      else
        medianIntensity = tempList.get((tempList.size() + 1) / 2);
    }
  }
  
  void processFlight(Flight f) {
    Location src = airportCoordinates.get(f.origin);
    Location des = airportCoordinates.get(f.destination);
    if (src != null && des != null) {
      PVector pointA = LocationTo3D(src.toRadians());
      PVector pointB = LocationTo3D(des.toRadians());
      float angle = acos(pointA.dot(pointB));
      for (float t = 0; t <= 1; t += 0.001) {
        PVector intermediate = PVector.add(
          PVector.mult(pointA, sin((1 - t) * angle)),
          PVector.mult(pointB, sin(t * angle))
        ).div(sin(angle));
        float lon = atan2(intermediate.y, intermediate.x);
        float lat = asin(intermediate.z);
        if (!Float.isNaN(degrees(lon)) && !Float.isNaN(degrees(lat))) {
          int x = (int)(mapX(degrees(lon)) / SCALE);
          int y = (int)(mapY(degrees(lat)) / SCALE);
          if (x >= 0 && x < heatMapWidth && y >= 0 && y < heatMapHeight) {
            synchronized (heatMap) {
              heatMap[x][y]++;
            }
          }
        }
      }
    }
  }
  
  void generateHeatMapLayer() {
    heatMapLayer = createGraphics(width, height);
    heatMapLayer.beginDraw();
    heatMapLayer.noStroke();
    for (int x = 0; x < heatMapWidth; x++) {
      for (int y = 0; y < heatMapHeight; y++) {
        int intensity = heatMap[x][y];
        if (intensity > 0) {
          color intensityColor = getIntensityColor(intensity);
          heatMapLayer.fill(intensityColor);
          heatMapLayer.rect(x * SCALE, y * SCALE, SCALE, SCALE);
        }
      }
    }
    heatMapLayer.endDraw();
  }
  
  PVector LocationTo3D(Location loc) {
    return new PVector(
      cos(loc.lat) * cos(loc.lon),
      cos(loc.lat) * sin(loc.lon),
      sin(loc.lat)
    );
  }
  
  color getIntensityColor(float intensity) {
    if (intensity < medianIntensity / 4)
      return lerpColor(color(0, 0, 0, 0), color(0, 0, 255, heatMapOpacity), map(intensity, 0, medianIntensity / 4, 0, 1));
    else if (intensity < medianIntensity)
      return lerpColor(color(0, 0, 255, heatMapOpacity), color(255, 255, 0, heatMapOpacity), map(intensity, medianIntensity / 4, medianIntensity, 0, 1));
    else if (intensity < medianIntensity * 2)
      return lerpColor(color(255, 255, 0, heatMapOpacity), color(255, 110, 0, heatMapOpacity), map(intensity, medianIntensity, medianIntensity * 2, 0, 1));
    else
      return lerpColor(color(255, 110, 0, heatMapOpacity), color(255, 0, 0, heatMapOpacity), map(intensity, medianIntensity * 2, medianIntensity * 7, 0, 1));
  }
  
  float mapX(float lon) {
    return map(lon, -180, 180, 0, width);
  }
  
  float mapY(float lat) {
    return map(lat, 90, -90, 0, height);
  }
  
  void mouseWheel(MouseEvent event) {
    float zoomFactor = 1.25;
    float e = event.getCount();
    float newScale = (e < 0) ? scaleFactor * zoomFactor : scaleFactor / zoomFactor;
    if (newScale >= 1) {
      float dx = mouseX - offsetX;
      float dy = mouseY - offsetY;
      offsetX -= (newScale - scaleFactor) * dx / scaleFactor;
      offsetY -= (newScale - scaleFactor) * dy / scaleFactor;
      scaleFactor = newScale;
    }
  }
  
  void mousePressed() {
    startX = mouseX - offsetX;
    startY = mouseY - offsetY;
    isDragging = true;
    if (!hideUI) {
      menuButton.handleOnClick();
      boolean dateChanged = calendar.mousePressed();
      confirmButton.handleOnClick();
      toggleUIButton.handleOnClick();
    } else {
      // If UI is hidden, let the user press the "SHOW UI" button if hovered.
      showUIButton.handleOnClick();
    }
  }
  
  void mouseDragged() {
    if (isDragging) {
      float newoffsetX = mouseX - startX;
      float newoffsetY = mouseY - startY;
      float zoomedWidth = width * scaleFactor;
      float zoomedHeight = height * scaleFactor;
      offsetX = constrain(newoffsetX, width - zoomedWidth, 0);
      offsetY = constrain(newoffsetY, height - zoomedHeight, 0);
    }
  }
  
  void mouseReleased() {
    isDragging = false;
  }
}

class CustomButton {
  int x, y, w, h;
  int col;
  int textColor;
  String text;
  Runnable onClick;
  
  CustomButton(int x, int y, int w, int h, int col, int textColor, String text, Runnable onClick) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.col = col;
    this.textColor = textColor;
    this.text = text;
    this.onClick = onClick;
  }
  
  boolean isMouseOver() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
  
  void draw() {
    if (isMouseOver()) {
      stroke(255);
      strokeWeight(2);
    } else {
      stroke(color(135, 206, 235, 150));
      strokeWeight(2);
    }
    fill(col);
    rect(x, y, w, h, 8);
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(24); 
    text(text, x + w / 2, y + h / 2);
  }
  
  void handleOnClick() {
    if (isMouseOver() && onClick != null) {
      onClick.run();
    }
  }
}

class CustomButtonSettings {
  int x, y, w, h;
  int col;
  int textColor;
  String text;
  Runnable onClick;
  
  CustomButton build() {
    return new CustomButton(x, y, w, h, col, textColor, text, onClick);
  }
}
