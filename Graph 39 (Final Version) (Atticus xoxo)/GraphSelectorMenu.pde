import java.util.HashMap; //<>//
import java.util.Map; // Needed for Map.Entry
import java.util.ArrayList;
import java.util.Collections;

// GraphSelectorMenu.pde

class GraphSelectorMenu {
  String airport;
  ProcessData data;
  Calendar calendar;
  
  boolean inMenu = true;
  int selectedGraph = 0;
  
  // We'll store icons for 8 graphs:
  PImage iconPie, iconLine, iconBar, iconGrouped, iconRadar, iconScatter, iconHistogram, iconBubble;

  int graphStartTime = 0;
  float animationProgress = 0;
  float animationDuration = 1000;
  
  boolean annualData = true; // Default ON
  String lastSelectedDate = null;
  
  GraphSelectorMenu(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
    generateIcons();
    calendar = new Calendar(width - 420, 80, 400, 280);

    // Reset calendar to default
    calendar.month = 0;
    calendar.year = 2017;
    calendar.selectedDay = 1;
    data.filterDate = null;
  }
  
  void generateIcons() {
    iconPie        = createPieIcon();
    iconLine       = createLineIcon();
    iconBar        = createBarIcon();
    iconGrouped    = createGroupedIcon();
    iconRadar      = createRadarIcon();
    iconScatter    = createScatterIcon();
    iconHistogram  = createHistogramIcon();
    iconBubble     = createBubbleIcon();
  }
  
  // --------------------------------------------------------------------------
  // Icon creation
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

  // If you want a transparent background:
  pg.background(0, 0); 
  // Or if you want black:
  // pg.background(0);

  // Move origin to center
  pg.translate(32, 32);

  // 1) Draw concentric rings in a bright green
  pg.noFill();
  pg.stroke(0, 255, 0, 100);  // green-ish, semi-transparent
  pg.strokeWeight(1);
  for (int r = 8; r <= 28; r += 8) {
    pg.ellipse(0, 0, r*2, r*2);
  }
  
  //    We'll do about a 30° wedge, and fill it with transparent green
  pg.noStroke();
  pg.fill(0, 255, 0, 50);  // green with some transparency
  float wedgeStart  = -HALF_PI;  // pointing up (12 o'clock)
  float wedgeExtent = radians(30);
  pg.arc(0, 0, 56, 56, wedgeStart, wedgeStart + wedgeExtent, PIE);

  // 3) Place a few random "blips" (bright green dots) around the radar
  pg.fill(0, 255, 0, 180); 
  int blips = 5;
  float maxR = 28; // largest radius in pixels
  for (int i = 0; i < blips; i++) {
    float angle = random(TWO_PI);
    float rr = random(maxR);
    float bx = rr*cos(angle);
    float by = rr*sin(angle);
    pg.ellipse(bx, by, 3, 3);
  }

  pg.endDraw();
  return pg.get();
}

  PImage createScatterIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0); // transparent
    // axes
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54); // x-axis
    pg.line(10, 54, 10, 10); // y-axis

    // some random dots
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

  // NEW icons:
  PImage createHistogramIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    // X-axis
    pg.line(10, 54, 54, 54);
    // Y-axis
    pg.line(10, 54, 10, 10);
    // Some bars
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
    // X-axis
    pg.line(10, 54, 54, 54);
    // Y-axis
    pg.line(10, 54, 10, 10);
    // Some "bubbles"
    pg.strokeWeight(1);
    pg.fill(0, 0, 255, 150);
    pg.ellipse(20, 40, 6, 6);
    pg.ellipse(30, 30, 12, 12);
    pg.ellipse(45, 25, 18, 18);
    pg.endDraw();
    return pg.get();
  }

  // --------------------------------------------------------------------------
  // UI drawing
  // --------------------------------------------------------------------------

  void display() {
    background(255);
    drawBackButton();
    
    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin == null) fullOrigin = airport;
    
    String airportName = extractAirportName(fullOrigin);
    String location    = extractLocation(fullOrigin);
    
    if (inMenu) {
      calendar.visible = false;
      drawMenu();
    } else {
      int elapsed = millis() - graphStartTime;
      animationProgress = constrain(elapsed / animationDuration, 0, 1);
      
      // Build heading lines
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
      
      String line2 = (location.length() > 0) ? "Located in " + location : "";
      String line3 = (data.filterDate == null) ? "Full Annual Data for 2017"
                                               : "Daily Data for " + formatDate(data.filterDate);
      
      float rightMargin = 250;
      float availableWidth = width - rightMargin;
      float baseY = 15;
      float gap = 5;
      
      // Draw line 1
      float fs1 = getFittedTextSize(line1, availableWidth, 24);
      textSize(fs1);
      textAlign(CENTER, TOP);
      text(line1, width/2, baseY);
      baseY += fs1 + gap;
      
      // Draw line 2
      if (line2.length() > 0) {
        float fs2 = getFittedTextSize(line2, availableWidth, 20);
        textSize(fs2);
        text(line2, width/2, baseY);
        baseY += fs2 + gap;
      }
      
      // Draw line 3
      float fs3 = getFittedTextSize(line3, availableWidth, 20);
      textSize(fs3);
      text(line3, width/2, baseY);
      
      // Graph area
      float gx = 150, gy = 150, gw = width - 300, gh = height - 300;
      if (data.totalFlights == 0) {
        fill(0);
        textSize(30);
        textAlign(CENTER, CENTER);
        text("No data available for this date", width/2, height/2);
      } else {
        switch (selectedGraph) {
          case 0: drawPieChart(gx, gy, gw, gh);        break;
          case 1: drawLineGraph(gx, gy, gw, gh);       break;
          case 2: drawBarChart(gx, gy, gw, gh);        break;
          case 3: drawGroupedBarChart(gx, gy, gw, gh); break;
          case 4: drawRadarChart(gx, gy, gw, gh);      break;
          case 5: drawScatterPlot(gx, gy, gw, gh);     break;
          case 6: drawHistogram(gx, gy, gw, gh);       break;
          case 7: drawBubbleChart(gx, gy, gw, gh);     break;
        }
      }
      
      drawDateSelector();
      drawAnnualToggle();
    }
    
    calendar.x = width - calendar.w - 20;
    calendar.y = 80;
    hint(DISABLE_DEPTH_TEST);
    calendar.display();
    hint(ENABLE_DEPTH_TEST);
  }

void drawMenu() {
  // 8 items in a 4×2 grid
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

    // Hover effect
    if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) {
      fill(120, 170, 255);
    } else {
      fill(100, 150, 255);
    }
    rect(bx, by, btnWidth, btnHeight, 16);

    // Icon
    if (icons[i] != null) {
      imageMode(CENTER);
      image(icons[i], bx + btnWidth / 2, by + 100, 72, 72);
    }

    // Label
    fill(255);
    textAlign(CENTER, TOP);
    textSize(20);
    text(labels[i], bx + btnWidth / 2, by + 160);
  }
}

  void mousePressedMenu(float mx, float my) {
    // back button
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
      // annual toggle
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
      // calendar toggle
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
  // 8 items in a 4×2 grid
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

  // Draw a "Back" button at top-left
  void drawBackButton() {
    int bx = 10, by = 10, bw = 80, bh = 30;
    stroke(0);
    strokeWeight(1);
    if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
      fill(150);
    } else {
      fill(180);
    }
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Back", bx + bw/2, by + bh/2);
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
    text(label, bx + bw/2, by + bh/2);
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
    text("Calendar", bx + bw/2, by + bh/2);
  }

  // --------------------------------------------------------------------------
  // 0) Pie Chart
  // --------------------------------------------------------------------------
  void drawPieChart(float x, float y, float w, float h) {
    float cx = x + w/2;
    float cy = y + h/2;
    float dia = min(w, h) * 0.7;
    
    int onTime    = data.onTimeFlights;
    int delayed   = data.delayedFlights;
    int cancelled = data.cancelledFlights;
    int total     = max(1, onTime + delayed + cancelled);
    
    float angleOnTime    = TWO_PI * onTime / total;
    float angleDelayed   = TWO_PI * delayed / total;
    float angleCancelled = TWO_PI * cancelled / total;
    
    float anim = animationProgress;
    float startAngle = -HALF_PI;
    stroke(255);
    strokeWeight(2);
    
    fill(0, 200, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleOnTime*anim);
    startAngle += angleOnTime*anim;
    
    fill(0, 0, 255);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleDelayed*anim);
    startAngle += angleDelayed*anim;
    
    fill(255, 0, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleCancelled*anim);
    
    // Legend
    float legendX = x + 30;
    float legendY = y + 30;
    float boxSize = 25;
    textAlign(LEFT, CENTER);
    textSize(18);
    noStroke();
    
    fill(0, 200, 0);
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    text("On Time: " + onTime, legendX + boxSize + 10, legendY + boxSize/2);
    
    fill(0, 0, 255);
    rect(legendX, legendY + 35, boxSize, boxSize);
    fill(0);
    text("Delayed: " + delayed, legendX + boxSize + 10, legendY + 35 + boxSize/2);
    
    fill(255, 0, 0);
    rect(legendX, legendY + 70, boxSize, boxSize);
    fill(0);
    text("Cancelled: " + cancelled, legendX + boxSize + 10, legendY + 70 + boxSize/2);
  }

  // --------------------------------------------------------------------------
  // 1) Line Graph
  // --------------------------------------------------------------------------
  void drawLineGraph(float x, float y, float w, float h) {
    float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 50;
    int[] hourCounts = new int[24];
    int maxCount = 1;
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 16) {
          String[] parts = split(sched, ' ');
          if (parts.length == 2) {
            int hr = constrain(parseInt(parts[1].substring(0, 2)), 0, 23);
            hourCounts[hr]++;
            if (hourCounts[hr] > maxCount) maxCount = hourCounts[hr];
          }
        }
      }
    }
    
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    // Y ticks
    textAlign(RIGHT, CENTER);
    textSize(16);
    int yTicks = maxCount <= 5 ? maxCount : 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      text(int(val), plotX - 8, ypos);
    }
    // X ticks
    textAlign(CENTER, TOP);
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, plotX, plotX + plotW);
      line(xpos, plotY + plotH, xpos, plotY + plotH + 5);
      text(nf(hr, 2), xpos, plotY + plotH + 8);
    }
    
    textAlign(CENTER, BOTTOM);
    textSize(20);
    text("Hour of Day", plotX + plotW/2, y + h);
    
    pushMatrix();
    translate(x - 20, plotY + plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, TOP);
    text("Flight Count", 0, 0);
    popMatrix();
    
    int visiblePoints = int(24 * animationProgress);
    float[] xpos = new float[visiblePoints];
    float[] ypos = new float[visiblePoints];
    
    for (int hr = 0; hr < visiblePoints; hr++) {
      xpos[hr] = map(hr, 0, 23, plotX, plotX + plotW);
      ypos[hr] = map(hourCounts[hr], 0, maxCount, plotY + plotH, plotY);
    }
    
    // fill under line
    noStroke();
    for (int i = 0; i < visiblePoints - 1; i++) {
      fill(i % 2 == 0 ? color(160, 190, 255) : color(100, 150, 255));
      beginShape();
      vertex(xpos[i], ypos[i]);
      vertex(xpos[i+1], ypos[i+1]);
      vertex(xpos[i+1], plotY + plotH);
      vertex(xpos[i],   plotY + plotH);
      endShape(CLOSE);
    }
    
    // line
    noFill();
    stroke(0, 0, 255);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < visiblePoints; i++) {
      vertex(xpos[i], ypos[i]);
    }
    endShape();
    
    // points
    textSize(14);
    textAlign(CENTER, BOTTOM);
    for (int i = 0; i < visiblePoints; i++) {
      fill(0, 0, 255);
      noStroke();
      ellipse(xpos[i], ypos[i], 6, 6);
      fill(0);
      float labelX = xpos[i];
      if (i == 0) labelX += 15;
      text(hourCounts[i], labelX, ypos[i] - 8);
    }
  }

  // --------------------------------------------------------------------------
  // 2) Bar Chart (Top Destinations)
  // --------------------------------------------------------------------------
  void drawBarChart(float x, float y, float w, float h) {
    float marginLeft = 60, marginRight = 30, marginTop = 80, marginBottom = 200;
    HashMap<String, Integer> destCounts = new HashMap<>();
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String dest = row.getString("destination").trim();
        if (!dest.equals("")) {
          destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
        }
      }
    }
    ArrayList<Map.Entry<String, Integer>> destList = new ArrayList<>(destCounts.entrySet());
    Collections.sort(destList, (a, b) -> b.getValue().compareTo(a.getValue()));
    int itemsAvailable = destList.size();
    int itemsToShow = min(5, itemsAvailable);
    destList = new ArrayList<>(destList.subList(0, itemsToShow));
    Collections.sort(destList, (a, b) -> {
      String nameA = airportLookup.getOrDefault(a.getKey(), a.getKey());
      String nameB = airportLookup.getOrDefault(b.getKey(), b.getKey());
      return nameA.compareToIgnoreCase(nameB);
    });
    
    float gap = 10;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    float barWidth = (plotW - gap*6) / 5.0;
    
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);

    if (itemsAvailable < 5) {
      fill(255, 0, 0);
      textAlign(CENTER);
      textSize(18);
      text("Not enough destinations for a full top 5 list.", x + w / 2, y + 20);
    }

    int maxCount = 1;
    for (int i = 0; i < itemsToShow; i++) {
      maxCount = max(maxCount, destList.get(i).getValue());
    }
    
    float totalBarWidth = itemsToShow*barWidth + (itemsToShow-1)*gap;
    float offsetX = (plotW - totalBarWidth)/2;
    
    for (int i = 0; i < itemsToShow; i++) {
      Map.Entry<String, Integer> entry = destList.get(i);
      String code = entry.getKey();
      String fullLabel = airportLookup.get(code);
      if (fullLabel == null) fullLabel = code;
      int count = entry.getValue();
      
      float barHeight = map(count, 0, maxCount, 0, plotH) * animationProgress;
      float bx = plotX + offsetX + i*(barWidth + gap);
      float by = plotY + plotH - barHeight;
      
      fill(100, 150, 255);
      noStroke();
      rect(bx, by, barWidth, barHeight);
      
      fill(0);
      textSize(18);
      textAlign(CENTER, BOTTOM);
      text(count, bx + barWidth/2, by - 6);
      
      String line1 = fullLabel.contains("(")
        ? fullLabel.substring(0, fullLabel.indexOf("(")).trim()
        : fullLabel;
      String line2 = fullLabel.contains("(")
        ? fullLabel.substring(fullLabel.indexOf("("), fullLabel.indexOf(")") + 1).trim()
        : "";
      String[] labelLines = {line1, line2, code};
      float maxLabelWidth = barWidth + gap*2;
      float fitted = getFittedTextSize(labelLines, maxLabelWidth, 26);
      fitted = min(fitted, 24);
      textSize(fitted);
      
      textAlign(CENTER, TOP);
      for (int j = 0; j < labelLines.length; j++) {
        text(labelLines[j], bx + barWidth/2, plotY + plotH + 6 + j*(fitted + 2));
      }
    }

    // Y-axis ticks
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      text(nf(round(val), 0), plotX - 8, ypos);
    }

    // Axis labels
    textAlign(CENTER, BOTTOM);
    textSize(22);
    text("Destination Airports", plotX + plotW/2, y + h - 10);

    pushMatrix();
    translate(x + 5, plotY + plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, TOP);
    text("Flight Count", 0, 0);
    popMatrix();

    textAlign(CENTER, TOP);
    textSize(22);
    text("Top 5 Destination Airports", x + w/2, y - 20);
  }

  // --------------------------------------------------------------------------
  // 3) Grouped Bar Chart (Airline Performance)
  // --------------------------------------------------------------------------
  void drawGroupedBarChart(float x, float y, float w, float h) {
    float marginLeft = 120, marginRight = 120, marginTop = 60, marginBottom = 140;
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    
    HashMap<String, float[]> airlineStats = new HashMap<>();
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String airline = row.getString("airline_name").trim();
        if (airline.equals("")) airline = "Unknown";
        float[] st = airlineStats.getOrDefault(airline, new float[]{0, 0, 0});
        if (row.getString("cancelled").equalsIgnoreCase("true")) {
          st[2]++;
        }
        try {
          int delay = row.getInt("minutes_late");
          if (delay < 0) delay = 0;
          st[0] += delay; // total delay
          st[1]++;        // flight count
        } catch(Exception e) {}
        airlineStats.put(airline, st);
      }
    }
    
    ArrayList<Map.Entry<String, float[]>> list = new ArrayList<>(airlineStats.entrySet());
    Collections.sort(list, (a, b) -> Float.compare(b.getValue()[1], a.getValue()[1]));
    int itemsToShow = min(10, list.size());
    list = new ArrayList<>(list.subList(0, itemsToShow));
    Collections.sort(list, (a, b) -> a.getKey().compareToIgnoreCase(b.getKey()));
    
    ArrayList<String> airlines = new ArrayList<>();
    ArrayList<Float> avgDelays = new ArrayList<>();
    ArrayList<Float> cancelRates = new ArrayList<>();
    
    float maxAvgDelay = 1, maxCancelRate = 1;
    
    for (Map.Entry<String, float[]> e : list) {
      String airline = e.getKey();
      float[] st = e.getValue();
      float avgDelay = (st[1] > 0) ? st[0]/st[1] : 0;
      float cancelRate = (st[1] > 0) ? st[2]/st[1] : 0;
      airlines.add(airline);
      avgDelays.add(avgDelay);
      cancelRates.add(cancelRate);
      if (avgDelay > maxAvgDelay) maxAvgDelay = avgDelay;
      if (cancelRate > maxCancelRate) maxCancelRate = cancelRate;
    }

    // Legend
    float legendX = plotX + 10;
    float legendY = plotY - 80;
    float boxSize = 20;
    
    fill(0, 0, 200);
    noStroke();
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("Avg Delay (min)", legendX + boxSize + 8, legendY + boxSize/2);
    
    fill(200, 0, 0);
    rect(legendX, legendY + 25, boxSize, boxSize);
    fill(0);
    text("Cancellation Rate (%)", legendX + boxSize + 8, legendY + 25 + boxSize/2);
    
    stroke(0);
    line(plotX, plotY, plotX, plotY + plotH);
    
    // Y-axis for avg delay
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxAvgDelay);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, ypos, plotX, ypos);
      text(nf(val, 0, 1), plotX - 10, ypos);
    }
    pushMatrix();
    translate(plotX - 70, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Avg Delay (min)", 0, 0);
    popMatrix();
    
    float rightX = plotX + plotW;
    stroke(0);
    line(rightX, plotY, rightX, plotY + plotH);
    textAlign(LEFT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCancelRate);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      line(rightX, ypos, rightX + 5, ypos);
      text(nf(val*100, 0, 1) + "%", rightX + 10, ypos);
    }
    pushMatrix();
    translate(rightX + 70, plotY + plotH/2);
    rotate(HALF_PI);
    text("Cancellation Rate (%)", 0, 0);
    popMatrix();
    
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);

    float groupWidth = plotW / itemsToShow;
    float barWidth = groupWidth / 3;
    
    for (int i = 0; i < itemsToShow; i++) {
      float groupX = plotX + i*groupWidth;
      float d = avgDelays.get(i);
      float c = cancelRates.get(i);
      float delayH = map(d, 0, maxAvgDelay, 0, plotH) * animationProgress;
      float cancelH = map(c, 0, maxCancelRate, 0, plotH) * animationProgress;

      float bx1 = groupX + groupWidth/2 - barWidth - 4;
      float by1 = plotY + plotH - delayH;
      fill(0, 0, 200);
      rect(bx1, by1, barWidth, delayH);
      fill(0);
      textAlign(CENTER, BOTTOM);
      textSize(14);
      text(nf(d, 0, 1), bx1 + barWidth/2, by1 - 2);

      float bx2 = groupX + groupWidth/2 + 4;
      float by2 = plotY + plotH - cancelH;
      fill(200, 0, 0);
      rect(bx2, by2, barWidth, cancelH);
      fill(0);
      text(nf(c*100, 0, 1)+"%", bx2 + barWidth/2, by2 - 2);

      String label = airlines.get(i);
      String[] parts = splitTokens(label, " ");
      if (parts.length > 2) {
        int half = parts.length / 2;
        parts = new String[]{
          join(subset(parts, 0, half), " "),
          join(subset(parts, half), " ")
        };
      }
      float ts = getFittedTextSize(parts, groupWidth, 16);
      textSize(ts);
      textAlign(CENTER, TOP);
      for (int j = 0; j < parts.length; j++) {
        text(parts[j], groupX + groupWidth/2, plotY + plotH + 5 + j*(ts + 2));
      }
    }
    
    textAlign(CENTER, BOTTOM);
    textSize(20);
    text("Airlines", plotX + plotW/2, y + h - 8);

    textAlign(CENTER, TOP);
    textSize(24);
    text("Airline Performance", x + w/2, y - 20);
  }

  // --------------------------------------------------------------------------
  // 4) Radar Chart (Monthly flight counts)
  // --------------------------------------------------------------------------
void drawRadarChart(float x, float y, float w, float h) {
  float cx = x + w / 2;
  float cy = y + h / 2;
  float radius = min(w, h) * 0.35;

  boolean showMonthly = (annualData || data.filterDate == null);
  int spokes = showMonthly ? 12 : 24;
  int[] counts = new int[spokes];
  int maxCount = 1;

  // 1. Collect data
  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!data.rowMatchesFilter(row, airport)) continue;
      String sched = row.getString("scheduled_departure");

      if (showMonthly && sched != null && sched.length() >= 7) {
        int m = parseInt(sched.substring(5, 7)) - 1;
        if (m >= 0 && m < 12) {
          counts[m]++;
          maxCount = max(maxCount, counts[m]);
        }
      } else if (!showMonthly && sched != null && sched.length() >= 13) {
        int hr = parseInt(sched.substring(11, 13));
        if (hr >= 0 && hr < 24) {
          counts[hr]++;
          maxCount = max(maxCount, counts[hr]);
        }
      }
    }
  }

  // 2. Determine evenly spaced ring labels
  int rings = 5;
  int displayMax = max(1, ceil(maxCount / 5.0) * 5); // Round up to next multiple of 5
  int[] ringVals = new int[rings];
  for (int i = 0; i < rings; i++) {
    ringVals[i] = round((i + 1) * (displayMax / (float) rings));
  }

  // 3. Draw rings
  stroke(0);
  noFill();
  textSize(14);
  textAlign(LEFT, CENTER);
  for (int i = 0; i < rings; i++) {
    float rr = (i + 1) / (float) rings * radius;
    ellipse(cx, cy, rr * 2, rr * 2);
    fill(0);
    text(ringVals[i], cx + 5, cy - rr);
    noFill();
    stroke(0);
  }

  // 4. Draw spokes
  for (int i = 0; i < spokes; i++) {
    float angle = -HALF_PI + i * (TWO_PI / spokes);
    float x2 = cx + radius * cos(angle);
    float y2 = cy + radius * sin(angle);
    stroke(0);
    line(cx, cy, x2, y2);
  }

  // 5. Draw radar polygon
  stroke(0, 0, 255);
  strokeWeight(2);
  fill(0, 0, 255, 40);
  beginShape();
  for (int i = 0; i < spokes; i++) {
    float angle = -HALF_PI + i * (TWO_PI / spokes);
    float value = map(counts[i], 0, displayMax, 0, radius) * animationProgress;
    float px = cx + value * cos(angle);
    float py = cy + value * sin(angle);
    vertex(px, py);
  }
  endShape(CLOSE);

  // 6. Dots and value labels
  textAlign(CENTER, BOTTOM);
  textSize(14);
  for (int i = 0; i < spokes; i++) {
    int val = counts[i];
    float angle = -HALF_PI + i * (TWO_PI / spokes);
    float r = map(val, 0, displayMax, 0, radius) * animationProgress;
    float px = cx + r * cos(angle);
    float py = cy + r * sin(angle);

    fill(0, 0, 255);
    noStroke();
    ellipse(px, py, 6, 6);

    if (val > 0) {
      fill(0, 0, 255);
      text(val, px, py - 8);
    }
  }

  // 7. Axis labels (Month or Hour)
  fill(0);
  textSize(14);
  textAlign(CENTER, CENTER);
  if (showMonthly) {
    String[] months = {
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    };
    for (int i = 0; i < 12; i++) {
      float angle = -HALF_PI + i * (TWO_PI / 12);
      float lx = cx + (radius + 30) * cos(angle);
      float ly = cy + (radius + 30) * sin(angle);
      text(months[i], lx, ly);
    }
  } else {
    for (int i = 0; i < 24; i++) {
      float angle = -HALF_PI + i * (TWO_PI / 24);
      float lx = cx + (radius + 25) * cos(angle);
      float ly = cy + (radius + 25) * sin(angle);
      String hh = nf(i, 2) + ":00";
      text(hh, lx, ly);
    }
  }
}

  // --------------------------------------------------------------------------
  // 5) Scatter Plot (Hour vs. Delay)
  // --------------------------------------------------------------------------
  void drawScatterPlot(float x, float y, float w, float h) {
    ArrayList<Float[]> points = new ArrayList<Float[]>();
    float maxDelay = 0;

    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;

        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 16) {
          String timePart = sched.substring(11, 16); // "HH:MM"
          String[] hhmm = split(timePart, ":");
          if (hhmm.length == 2) {
            int hr = parseInt(hhmm[0]);
            int mn = parseInt(hhmm[1]);
            float xVal = hr + mn/60.0;
            int d = row.getInt("minutes_late");
            if (d < 0) d = 0;
            if (d > maxDelay) maxDelay = d;
            points.add(new Float[]{ xVal, float(d) });
          }
        }
      }
    }

    if (points.size() == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(30);
      text("No flight data for scatter plot", width/2, height/2);
      return;
    }

    float marginLeft = 60, marginRight = 30, marginTop = 50, marginBottom = 60;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;

    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY,         plotX,         plotY + plotH);

    textSize(16);
    textAlign(CENTER, TOP);
    for (int hr = 0; hr <= 23; hr++) {
      float xx = map(hr, 0, 24, plotX, plotX + plotW);
      line(xx, plotY + plotH, xx, plotY + plotH + 5);
      text(hr, xx, plotY + plotH + 8);
    }

    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxDelay);
      float yy = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, yy, plotX, yy);
      text(int(val), plotX - 8, yy);
    }

    textAlign(CENTER, TOP);
    textSize(22);
    text("Scatter: Departure Time vs. Delay", x + w/2, y);

    textAlign(CENTER, BOTTOM);
    textSize(18);
    text("Scheduled Departure (Hours)", plotX + plotW/2, y + h - 5);

    pushMatrix();
    translate(x + 15, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Minutes Late", 0, 0);
    popMatrix();

    noStroke();
    fill(0, 0, 255, 100);
    int totalPoints = points.size();
    int visiblePoints = int(totalPoints * animationProgress);

    for (int i = 0; i < visiblePoints; i++) {
      float xVal = points.get(i)[0];
      float dlay = points.get(i)[1];
      float xx = map(xVal, 0, 24, plotX, plotX + plotW);
      float yy = map(dlay, 0, maxDelay, plotY + plotH, plotY);
      ellipse(xx, yy, 5, 5);
    }
  }

  // --------------------------------------------------------------------------
  // 6) Histogram (Delay Distribution)
  // --------------------------------------------------------------------------
  void drawHistogram(float x, float y, float w, float h) {
    // gather delays
    ArrayList<Integer> delays = new ArrayList<Integer>();
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        int d = row.getInt("minutes_late");
        if (d < 0) d = 0;
        delays.add(d);
      }
    }
    if (delays.size() == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(30);
      text("No delay data for histogram", width/2, height/2);
      return;
    }
    
    int maxDelay = 0;
    for (int d : delays) if (d > maxDelay) maxDelay = d;
    
    // bin size
    int binSize = 10; 
    int numBins = ceil(maxDelay / float(binSize)) + 1;
    int[] bins = new int[numBins];
    for (int d : delays) {
      int binIndex = d/binSize;
      if (binIndex >= numBins) binIndex = numBins-1;
      bins[binIndex]++;
    }
    
    int maxCount = 0;
    for (int c : bins) if (c > maxCount) maxCount = c;
    
    float marginLeft = 60;
    float marginRight = 30;
    float marginTop = 40;
    float marginBottom = 60;
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;

    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY,         plotX,         plotY + plotH);
    
    float barWidth = plotW / numBins;

    textAlign(CENTER, BOTTOM);
    textSize(14);
    for (int i = 0; i < numBins; i++) {
      float barHeight = map(bins[i], 0, maxCount, 0, plotH) * animationProgress;
      float bx = plotX + i*barWidth;
      float by = plotY + plotH - barHeight;
      fill(100, 150, 255);
      noStroke();
      rect(bx, by, barWidth - 1, barHeight);
      fill(0);
      text(bins[i], bx + barWidth/2, by - 2);
    }

    // X-axis tick labels
    textAlign(CENTER, TOP);
    for (int i = 0; i <= numBins; i++) {
      float bx = plotX + i*barWidth;
      line(bx, plotY + plotH, bx, plotY + plotH + 5);
      int rangeStart = i*binSize;
      text(rangeStart, bx, plotY + plotH + 8);
    }

    // Y-axis ticks
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ty = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, ty, plotX, ty);
      text(int(val), plotX - 8, ty);
    }

    textAlign(CENTER, TOP);
    textSize(22);
    text("Delay Distribution Histogram", x + w/2, y);

    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Minutes Late (binned)", plotX + plotW/2, y + h - 5);

    pushMatrix();
    translate(x + 15, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Flight Count", 0, 0);
    popMatrix();
  }

  // --------------------------------------------------------------------------
  // 7) Bubble Chart (Hour vs. Avg Delay vs. Flight Count)
  // --------------------------------------------------------------------------
  void drawBubbleChart(float x, float y, float w, float h) {
    
    
    int[] counts = new int[24];
    int[] sumDelays = new int[24];
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 13) {
          int hr = parseInt(sched.substring(11, 13));
          hr = constrain(hr, 0, 23);
          int d = row.getInt("minutes_late");
          if (d < 0) d = 0;
          counts[hr]++;
          sumDelays[hr] += d;
        }
      }
    }
    float[] avgDelay = new float[24];
    float maxDelay = 1;
    int maxCount = 0;
    for (int hr = 0; hr < 24; hr++) {
      if (counts[hr] > 0) {
        avgDelay[hr] = sumDelays[hr] / (float)counts[hr];
        if (avgDelay[hr] > maxDelay) maxDelay = avgDelay[hr];
      }
      if (counts[hr] > maxCount) maxCount = counts[hr];
    }

    float marginLeft = 60;
    float marginRight = 50;
    float marginTop = 100;
    float marginBottom = 70;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;

    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY,         plotX,         plotY + plotH);

    textSize(14);
    textAlign(CENTER, TOP);
    for (int hr = 0; hr <= 23; hr++) {
      float xx = map(hr, 0, 23, plotX, plotX + plotW);
      line(xx, plotY + plotH, xx, plotY + plotH + 5);
      text(hr, xx, plotY + plotH + 8);
    }
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxDelay);
      float yy = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, yy, plotX, yy);
      text(int(val), plotX - 8, yy);
    }

    textAlign(CENTER, TOP);
    textSize(22);
    text("Bubble Chart: Hour vs. Avg Delay vs. Flight Count", x + w/2, y);

    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Scheduled Departure Hour", plotX + plotW/2, y + h - 5);

    pushMatrix();
    translate(x + 20, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Avg Delay (minutes)", 0, 0);
    popMatrix();

    noStroke();
    fill(100, 150, 255, 180);
    float maxBubbleRadius = 40;

    for (int hr = 0; hr < 24; hr++) {
      if (counts[hr] == 0) continue;
      float xx = map(hr, 0, 23, plotX, plotX + plotW);
      float yy = map(avgDelay[hr], 0, maxDelay, plotY + plotH, plotY);
      float bubbleR = map(counts[hr], 0, maxCount, 0, maxBubbleRadius)*animationProgress;
      ellipse(xx, yy, bubbleR*2, bubbleR*2);

      // label bubble with flight count
      fill(0);
      textAlign(CENTER, CENTER);
      text(counts[hr], xx, yy);
      fill(100, 150, 255, 180);
    }
  }

  // --------------------------------------------------------------------------
  // Utility methods
  // --------------------------------------------------------------------------

  float getFittedTextSize(String text, float maxWidth, float defaultSize) {
    float ts = defaultSize;
    textSize(ts);
    while (ts > 5 && textWidth(text) > maxWidth) {
      ts -= 1;
      textSize(ts);
    }
    return ts;
  }

  float getFittedTextSize(String[] lines, float maxWidth, float defaultSize) {
    String joined = join(lines, " ");
    return getFittedTextSize(joined, maxWidth, defaultSize);
  }

  String formatDate(String date) {
    String[] parts = split(date, "-");
    if (parts.length != 3) return date;
    int year  = int(parts[0]);
    int month = int(parts[1]);
    int day   = int(parts[2]);
    return getOrdinal(day) + " of " + getMonthNameFull(month) + " " + year;
  }

  String getOrdinal(int day) {
    if (day >= 11 && day <= 13) return nf(day, 0) + "th";
    int lastDigit = day % 10;
    if (lastDigit == 1) return nf(day, 0) + "st";
    if (lastDigit == 2) return nf(day, 0) + "nd";
    if (lastDigit == 3) return nf(day, 0) + "rd";
    return nf(day, 0) + "th";
  }

  String getMonthNameFull(int m) {
    String[] months = {"January","February","March","April","May","June",
                       "July","August","September","October","November","December"};
    if (m < 1 || m > 12) return "";
    return months[m-1];
  }

  String extractAirportName(String fullOrigin) {
    int openParen = fullOrigin.indexOf("(");
    if (openParen != -1) {
      return fullOrigin.substring(0, openParen).trim();
    }
    return fullOrigin;
  }

  String extractLocation(String fullOrigin) {
    int openParen  = fullOrigin.indexOf("(");
    int closeParen = fullOrigin.indexOf(")");
    if (openParen != -1 && closeParen != -1 && closeParen > openParen) {
      return fullOrigin.substring(openParen+1, closeParen).trim();
    }
    return "";
  }
}
