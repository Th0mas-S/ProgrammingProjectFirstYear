// -------------------------------------------------------------------------- //<>//
// GraphSelectorMenu Class
// --------------------------------------------------------------------------

class GraphSelectorMenu {
  String airport;
  ProcessData data;
  Calendar calendar;
  
  // inMenu == true means the graph selection menu is visible;
  // inMenu == false means a graph is being displayed.
  boolean inMenu = true;
  int selectedGraph = 0;
  
  PImage iconPie, iconLine, iconBar, iconGrouped, iconRadar, iconScatter, iconHistogram, iconBubble;
  
  int graphStartTime = 0;
  float animationProgress = 0;
  float animationDuration = 1000; // Animation lasts 1 second
  
  boolean annualData = true; 
  String lastSelectedDate = null;
  
  GraphSelectorMenu(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
    generateIcons();
    calendar = new Calendar(width - 420, 80, 400, 280);
    calendar.month = 0;
    calendar.year = 2017;
    calendar.selectedDay = 1;
    data.filterDate = null;
  }
  
  void generateIcons() {
    iconPie     = createPieIcon();
    iconLine    = createLineIcon();
    iconBar     = createBarIcon();
    iconGrouped = createGroupedIcon();
    iconRadar   = createRadarIcon();
    iconScatter = createScatterIcon();
    iconHistogram = createHistogramIcon();
    iconBubble  = createBubbleIcon();
  }
  
  // --------------------------------------------------------------------------
  // Icon creation methods
  // --------------------------------------------------------------------------
  
  PImage createPieIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.noStroke();
    float totalAngle = TWO_PI;
    float start = -HALF_PI;
    float angleOnTime = totalAngle * 0.10;
    pg.fill(0, 200, 0);
    pg.arc(32, 32, 50, 50, start, start + angleOnTime);
    start += angleOnTime;
    float angleDelayed = totalAngle * 0.65;
    pg.fill(0, 0, 255);
    pg.arc(32, 32, 50, 50, start, start + angleDelayed);
    start += angleDelayed;
    float angleCancelled = totalAngle - angleOnTime - angleDelayed;
    pg.fill(255, 0, 0);
    pg.arc(32, 32, 50, 50, start, start + angleCancelled);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createLineIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0, 0, 255);
    pg.strokeWeight(3);
    pg.noFill();
    pg.beginShape();
    pg.vertex(8, 50);
    pg.vertex(20, 30);
    pg.vertex(32, 35);
    pg.vertex(44, 20);
    pg.vertex(56, 25);
    pg.endShape();
    pg.endDraw();
    return pg.get();
  }
  
  PImage createBarIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.fill(255, 140, 0);
    pg.noStroke();
    pg.rect(12, 30, 10, 22);
    pg.rect(26, 20, 10, 32);
    pg.rect(40, 10, 10, 42);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createGroupedIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.noStroke();
    pg.fill(0, 0, 200);
    pg.rect(10, 30, 6, 24);
    pg.fill(200, 0, 0);
    pg.rect(18, 35, 6, 19);
    pg.fill(0, 0, 200);
    pg.rect(30, 20, 6, 34);
    pg.fill(200, 0, 0);
    pg.rect(38, 25, 6, 29);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createRadarIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.translate(32, 32);
    pg.noFill();
    pg.stroke(0, 255, 0, 100);
    pg.strokeWeight(1);
    for (int r = 8; r <= 28; r += 8) {
      pg.ellipse(0, 0, r * 2, r * 2);
    }
    pg.noStroke();
    pg.fill(0, 255, 0, 50);
    float wedgeStart = -HALF_PI;
    float wedgeExtent = radians(30);
    pg.arc(0, 0, 56, 56, wedgeStart, wedgeStart + wedgeExtent, PIE);
    pg.fill(0, 255, 0, 180);
    int blips = 5;
    float maxR = 28;
    for (int i = 0; i < blips; i++) {
      float angle = random(TWO_PI);
      float rr = random(maxR);
      float bx = rr * cos(angle);
      float by = rr * sin(angle);
      pg.ellipse(bx, by, 3, 3);
    }
    pg.endDraw();
    return pg.get();
  }
  
  PImage createScatterIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54);
    pg.line(10, 54, 10, 10);
    pg.strokeWeight(1);
    pg.fill(0, 0, 255);
    for (int i = 0; i < 6; i++) {
      float px = random(15, 50);
      float py = random(15, 50);
      pg.ellipse(px, py, 5, 5);
    }
    pg.endDraw();
    return pg.get();
  }
  
  PImage createHistogramIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54);
    pg.line(10, 54, 10, 10);
    pg.strokeWeight(0);
    pg.fill(0, 0, 255);
    pg.rect(12, 34, 5, 20);
    pg.rect(20, 20, 5, 34);
    pg.rect(28, 25, 5, 29);
    pg.rect(36, 40, 5, 14);
    pg.rect(44, 15, 5, 39);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createBubbleIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54);
    pg.line(10, 54, 10, 10);
    pg.strokeWeight(1);
    pg.fill(0, 0, 255, 150);
    pg.ellipse(20, 40, 6, 6);
    pg.ellipse(30, 30, 12, 12);
    pg.ellipse(45, 25, 18, 18);
    pg.endDraw();
    return pg.get();
  }
  
  // --------------------------------------------------------------------------
  // UI Drawing Methods
  // --------------------------------------------------------------------------
  
  void display() {
    if (inMenu) {
      background(0);
    } 
    else {
      background(255);
    }
    
    drawBackButton();
    
    // Retrieve airport info.
    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin == null) fullOrigin = airport;
    String airportName = util.extractAirportName(fullOrigin);
    String location    = util.extractLocation(fullOrigin);
    
    if (inMenu) {
      float btnWidth = 380, btnHeight = 260, btnGapX = 25, btnGapY = 40;
      int cols = 4, rows = 2;
      float totalWidth  = cols * btnWidth + (cols - 1) * btnGapX;
      float totalHeight = rows * btnHeight + (rows - 1) * btnGapY;
      
      float startX = width / 2 - totalWidth / 2;
      float startY = height / 2 - totalHeight / 2;
      
      float headingBaseY = startY - 80;
      
      String mainHeading = "Graph Selection Menu";
      String subHeader = "Select a Graph for " + airportName + " (" + airport + ")";
      
      fill(255);
      
      textSize(28);
      textAlign(CENTER, TOP);
      text(mainHeading, width / 2, headingBaseY);
      headingBaseY += 35;
      
      float availableWidth = width - 250;
      float fs = util.getFittedTextSize(subHeader, availableWidth, 24);
      textSize(fs);
      text(subHeader, width / 2, headingBaseY);
      
      drawMenu();
    } else {
      int elapsed = millis() - graphStartTime;
      animationProgress = constrain(elapsed / animationDuration, 0, 1);
      
      String line1 = "";
      switch (selectedGraph) {
        case 0: line1 = "Flight Status Breakdown for " + airportName + " (" + airport + ")"; break;
        case 1: line1 = "Hourly Flight Counts for " + airportName + " (" + airport + ")"; break;
        case 2: line1 = "Top 5 Destinations from " + airportName + " (" + airport + ")"; break;
        case 3: line1 = "Airline Performance for " + airportName + " (" + airport + ")"; break;
        case 4: line1 = "Flight Counts (Radar) for " + airportName + " (" + airport + ")"; break;
        case 5: line1 = "Scatter: Hour vs. Delay for " + airportName + " (" + airport + ")"; break;
        case 6: line1 = "Histogram: Delay Distribution for " + airportName + " (" + airport + ")"; break;
        case 7: line1 = "Bubble: Hour vs. Avg Delay vs. Flight Count"; break;
      }
      String line2 = location.length() > 0 ? "Located in " + location : "";
      String line3 = data.filterDate == null ? "Full Annual Data for 2017" : "Daily Data for " + util.formatDate(data.filterDate);
      
      float rightMargin = 250;
      float availableWidth = width - rightMargin;
      float baseY = 15;
      float gap = 5;
      
      float fs1 = util.getFittedTextSize(line1, availableWidth, 24);
      textSize(fs1);
      textAlign(CENTER, TOP);
      text(line1, width / 2, baseY);
      baseY += fs1 + gap;
      
      if (line2.length() > 0) {
        float fs2 = util.getFittedTextSize(line2, availableWidth, 20);
        textSize(fs2);
        text(line2, width / 2, baseY);
        baseY += fs2 + gap;
      }
      
      float fs3 = util.getFittedTextSize(line3, availableWidth, 20);
      textSize(fs3);
      text(line3, width / 2, baseY);
      
      float gx = 150, gy = 150, gw = width - 300, gh = height - 300;
      if (data.totalFlights == 0) {
        fill(0);
        textSize(30);
        textAlign(CENTER, CENTER);
        text("No data available for this date", width / 2, height / 2);
      } else {
        switch (selectedGraph) {
          case 0: new PieChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 1: new LineGraphScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 2: new BarChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 3: new GroupedBarChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 4:
            boolean showMonthlyView = (data.filterDate == null);
            RadarChartScreen radar = new RadarChartScreen(airport, data, animationProgress, showMonthlyView);
            if (!showMonthlyView) {
              radar.setSelectedDate(data.filterDate);
            }
            radar.display(gx, gy, gw, gh);
            break;         
          case 5: new ScatterPlotScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 6: new HistogramScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 7: new BubbleChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
        }
      }
    }
    
    drawDateSelector();
    drawAnnualToggle();
    
    calendar.x = width - calendar.w - 20;
    calendar.y = 80;
    hint(DISABLE_DEPTH_TEST);
    calendar.display();
    hint(ENABLE_DEPTH_TEST);
  }
  
  void drawMenu() {
    float btnWidth = 380;
    float btnHeight = 260;
    float btnGapX = 25;
    float btnGapY = 40;
    
    String[] labels = {
      "Pie Chart\n(Flight Status)",
      "Line Graph\n(Hourly Counts)",
      "Bar Chart\n(Top Destinations)",
      "Grouped Bar\n(Airline Performance)",
      "Radar Chart\n(Monthly Flights)",
      "Scatter Plot\n(Hour vs. Delay)",
      "Histogram\n(Delay Distribution)",
      "Bubble Chart\n(Hour & Count)"
    };
    
    PImage[] icons = {
      iconPie, iconLine, iconBar, iconGrouped,
      iconRadar, iconScatter, iconHistogram, iconBubble
    };
    
    int cols = 4;
    int rows = 2;
    float totalWidth  = cols * btnWidth + (cols - 1) * btnGapX;
    float totalHeight = rows * btnHeight + (rows - 1) * btnGapY;
    float startX = width / 2 - totalWidth / 2;
    float startY = height / 2 - totalHeight / 2;
    
    for (int i = 0; i < labels.length; i++) {
      int col = i % cols;
      int row = i / cols;
      float bx = startX + col * (btnWidth + btnGapX);
      float by = startY + row * (btnHeight + btnGapY);
      
      if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) {
        fill(120, 170, 255);
      } else {
        fill(100, 150, 255);
      }
      rect(bx, by, btnWidth, btnHeight, 16);
      
      if (icons[i] != null) {
        imageMode(CENTER);
        image(icons[i], bx + btnWidth / 2, by + 100, 72, 72);
      }
      
      fill(255);
      textAlign(CENTER, TOP);
      textSize(20);
      text(labels[i], bx + btnWidth / 2, by + 160);
    }
  }
  
  void mousePressedMenu(float mx, float my) {
    if (mx >= 10 && mx <= 90 && my >= 10 && my <= 40) {
      if (inMenu) {
        screenMode = SCREEN_SELECTION;
      } else {
        data.filterDate = null;
        lastSelectedDate = null;
        calendar.month = 0;
        calendar.year = 2017;
        calendar.selectedDay = 1;
        inMenu = true;
        calendar.visible = false;
      }
      return;
    }
    
    if (!inMenu) {
      int annualBx = width - 430, annualBy = 10, annualBw = 200, annualBh = 40;
      if (mx >= annualBx && mx <= annualBx + annualBw && my >= annualBy && my <= annualBy + annualBh) {
        annualData = !annualData;
        if (annualData) {
          data.filterDate = null;
        } else {
          if (lastSelectedDate != null) {
            data.filterDate = lastSelectedDate;
          }
        }
        data.process(airport);
        return;
      }
    }
    
    if (!inMenu) {
      int bx = width - 220, by = 10, bw = 200, bh = 40;
      if (mx >= bx && mx <= bx + bw && my >= by && my <= by + bh) {
        calendar.toggle();
        return;
      }
    }
    
    if (calendar.visible) {
      if (calendar.handleMousePressed(int(mx), int(my))) {
        lastSelectedDate = calendar.getSelectedDate();
        annualData = false;
        data.filterDate = lastSelectedDate;
        data.process(airport);
        calendar.visible = false;
      }
      return;
    }
    
    if (inMenu) {
      int cols = 4, rows = 2;
      float btnWidth = 380;
      float btnHeight = 260;
      float btnGapX = 25;
      float btnGapY = 40;
      float totalWidth  = cols * btnWidth + (cols - 1) * btnGapX;
      float totalHeight = rows * btnHeight + (rows - 1) * btnGapY;
      float startX = width / 2 - totalWidth / 2;
      float startY = height / 2 - totalHeight / 2;
      
      for (int i = 0; i < 8; i++) {
        int col = i % cols;
        int row = i / cols;
        float bx = startX + col * (btnWidth + btnGapX);
        float by = startY + row * (btnHeight + btnGapY);
        
        if (mx > bx && mx < bx + btnWidth && my > by && my < by + btnHeight) {
          selectedGraph = i;
          inMenu = false;
          graphStartTime = millis();
          animationProgress = 0;
          data.filterDate = null;
          lastSelectedDate = null;
          data.process(airport);
          break;
        }
      }
    }
  }
  
  void drawBackButton() {
    int bx = 10, by = 10, bw = 80, bh = 30;
    stroke(0);
    strokeWeight(1);
    if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) fill(150);
    else fill(180);
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Back", bx + bw / 2, by + bh / 2);
  }
  
  void drawAnnualToggle() {
    if (inMenu) return;
    int bx = width - 430, by = 10, bw = 200, bh = 40;
    boolean hovered = (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh);
    if (annualData) {
      if (hovered) fill(120, 170, 255);
      else fill(100, 150, 255);
    } else {
      if (hovered) fill(180);
      else fill(150);
    }
    stroke(0);
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    String label = annualData ? "Annual: On" : "Annual: Off";
    text(label, bx + bw / 2, by + bh / 2);
  }
  
  void drawDateSelector() {
    if (inMenu) return;
    int bx = width - 220, by = 10, bw = 200, bh = 40;
    boolean hovered = (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh);
    if (hovered) fill(150);
    else fill(180);
    stroke(0);
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("Calendar", bx + bw / 2, by + bh / 2);
  }
}
