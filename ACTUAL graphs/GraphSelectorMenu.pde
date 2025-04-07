// GraphSelectorMenu.pde
// Displays a menu of four graphs and includes the Calendar widget
// and the Annual Data toggle button (only visible in graph view).

import java.util.HashMap;
import java.util.Map; // Needed for Map.Entry
import java.util.ArrayList;
import java.util.Collections;

PImage iconPie, iconLine, iconBar, iconGrouped;

// Returns the maximum font size that will allow the text to fit within maxWidth.
// Version for a single String.
float getFittedTextSize(String text, float maxWidth, float defaultSize) {
  float ts = defaultSize;
  textSize(ts);
  while (ts > 5 && textWidth(text) > maxWidth) {
    ts -= 1;
    textSize(ts);
  }
  return ts;
}

// Overloaded version for a String array: joins the array using a space.
float getFittedTextSize(String[] lines, float maxWidth, float defaultSize) {
  String joined = join(lines, " ");
  return getFittedTextSize(joined, maxWidth, defaultSize);
}

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

class GraphSelectorMenu {
  String airport;  // IATA code e.g., "IAA"
  ProcessData data;
  Calendar calendar;
  
  boolean inMenu = true;
  int selectedGraph = 0;
  
  float btnWidth = 500;
  float btnHeight = 240;
  float btnGap = 80;
  
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
    // Reset calendar to default: January 2017, day 1.
    calendar.month = 0;
    calendar.year = 2017;
    calendar.selectedDay = 1;
    data.filterDate = null;
  }
  
  void generateIcons() {
    iconPie = createPieIcon();
    iconLine = createLineIcon();
    iconBar = createBarIcon();
    iconGrouped = createGroupedIcon();
  }
  
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
  
  // Format a date string ("YYYY-MM-DD") to "28th of August 2017".
  String formatDate(String date) {
    String[] parts = split(date, "-");
    if (parts.length != 3) return date;
    int year = int(parts[0]);
    int month = int(parts[1]); // 1-indexed
    int day = int(parts[2]);
    return getOrdinal(day) + " of " + getMonthNameFull(month) + " " + year;
  }
  
  String getOrdinal(int day) {
    if (day >= 11 && day <= 13) return nf(day, 0) + "th";
    int lastDigit = day % 10;
    if (lastDigit == 1) return nf(day, 0) + "st";
    else if (lastDigit == 2) return nf(day, 0) + "nd";
    else if (lastDigit == 3) return nf(day, 0) + "rd";
    else return nf(day, 0) + "th";
  }
  
  String getMonthNameFull(int m) {
    String[] months = {"January", "February", "March", "April", "May", "June", 
                       "July", "August", "September", "October", "November", "December"};
    if (m < 1 || m > 12) return "";
    return months[m - 1];
  }
  
  // Extract the airport's main name (everything before "(").
  String extractAirportName(String fullOrigin) {
    int openParen = fullOrigin.indexOf("(");
    if (openParen != -1) return fullOrigin.substring(0, openParen).trim();
    return fullOrigin;
  }
  
  // Extract the location details from within the parentheses.
  String extractLocation(String fullOrigin) {
    int openParen = fullOrigin.indexOf("(");
    int closeParen = fullOrigin.indexOf(")");
    if (openParen != -1 && closeParen != -1 && closeParen > openParen) {
      return fullOrigin.substring(openParen + 1, closeParen).trim();
    }
    return "";
  }
  
  void drawMenu() {
    float totalWidth = 2 * btnWidth + btnGap;
    float totalHeight = 2 * btnHeight + btnGap;
    float startX = width / 2 - totalWidth / 2;
    float startY = height / 2 - totalHeight / 2;
    
    String[] labels = {
      "Pie Chart\n(Flight Status)",
      "Line Graph\n(Hourly Counts)",
      "Bar Chart\n(Top Destinations)",
      "Grouped Bar Chart\n(Airline Performance)"
    };
    PImage[] icons = { iconPie, iconLine, iconBar, iconGrouped };
    
    for (int i = 0; i < 4; i++) {
      int col = i % 2;
      int row = i / 2;
      float bx = startX + col * (btnWidth + btnGap);
      float by = startY + row * (btnHeight + btnGap);
      
      if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) {
        fill(120, 170, 255);
      } else {
        fill(100, 150, 255);
      }
      rect(bx, by, btnWidth, btnHeight, 12);
      
      if (icons[i] != null) {
        imageMode(CENTER);
        image(icons[i], bx + btnWidth / 2, by + 65, 64, 64);
      }
      
      fill(255);
      textAlign(CENTER, TOP);
      textSize(26);
      text(labels[i], bx + btnWidth / 2, by + 140);
    }
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
  
  void display() {
    background(255);
    drawBackButton();
    
    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin == null) fullOrigin = airport;
    
    // Extract parts from the full origin string.
    String airportName = extractAirportName(fullOrigin);
    String location = extractLocation(fullOrigin);  // e.g., "City, Country"
    
    if (inMenu) {
      calendar.visible = false;
      drawMenu();
    } else {
      int elapsed = millis() - graphStartTime;
      animationProgress = constrain(elapsed / animationDuration, 0, 1);
      
      // Build heading lines:
      // Line 1: Graph title with airport name and code.
      String line1 = "";
      switch (selectedGraph) {
        case 0: line1 = "Flight Status Breakdown for " + airportName + " (" + airport + ")"; break;
        case 1: line1 = "Hourly Flight Counts for " + airportName + " (" + airport + ")"; break;
        case 2: line1 = "Top 5 Destinations from " + airportName + " (" + airport + ")"; break;
        case 3: line1 = "Airline Performance for " + airportName + " (" + airport + ")"; break;
      }
      
      // Line 2: Location (if available) in more detail.
      String line2 = (location.length() > 0) ? "Located in " + location : "";
      
      // Line 3: Data type.
      String line3 = (data.filterDate == null) ? "Full Annual Data for 2017" : "Daily Data for " + formatDate(data.filterDate);
      
      // Reserve a right margin.
      float rightMargin = 250;
      float availableWidth = width - rightMargin;
      float baseY = 15;
      float gap = 5;
      
      // Draw line 1.
      float fs1 = getFittedTextSize(line1, availableWidth, 24);
      textSize(fs1);
      textAlign(CENTER, TOP);
      text(line1, width/2, baseY);
      baseY += fs1 + gap;
      
      // Draw line 2, if available.
      if (line2.length() > 0) {
        float fs2 = getFittedTextSize(line2, availableWidth, 20);
        textSize(fs2);
        text(line2, width/2, baseY);
        baseY += fs2 + gap;
      }
      
      // Draw line 3.
      float fs3 = getFittedTextSize(line3, availableWidth, 20);
      textSize(fs3);
      text(line3, width/2, baseY);
      
      // Draw the graph area.
      float gx = 150, gy = 150, gw = width - 300, gh = height - 300;
      if (data.totalFlights == 0) {
        // If no data is available, display a message.
        fill(0);
        textSize(30);
        textAlign(CENTER, CENTER);
        text("No data available for this date", width/2, height/2);
      } else {
        switch (selectedGraph) {
          case 0: drawPieChart(gx, gy, gw, gh); break;
          case 1: drawLineGraph(gx, gy, gw, gh); break;
          case 2: drawBarChart(gx, gy, gw, gh); break;
          case 3: drawGroupedBarChart(gx, gy, gw, gh); break;
        }
      }
      
      drawDateSelector();
      drawAnnualToggle();
    }
    
    // Update calendar position.
    calendar.x = width - calendar.w - 20;
    calendar.y = 80;
    hint(DISABLE_DEPTH_TEST);
    calendar.display();
    hint(ENABLE_DEPTH_TEST);

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
    
    if (!inMenu && mx >= width - 220 && mx <= width - 20 && my >= 10 && my <= 50) {
      calendar.toggle();
      return;
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
      float totalWidth = 2 * btnWidth + btnGap;
      float totalHeight = 2 * btnHeight + btnGap;
      float startX = width / 2 - totalWidth / 2;
      float startY = height / 2 - totalHeight / 2;
      for (int i = 0; i < 4; i++) {
        int col = i % 2;
        int row = i / 2;
        float bx = startX + col * (btnWidth + btnGap);
        float by = startY + row * (btnHeight + btnGap);
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
  
  // ---------------------------
  // Graph Drawing Methods
  
  void drawPieChart(float x, float y, float w, float h) {
    float cx = x + w / 2;
    float cy = y + h / 2;
    float dia = min(w, h) * 0.7;
    
    int onTime = data.onTimeFlights;
    int delayed = data.delayedFlights;
    int cancelled = data.cancelledFlights;
    int total = max(1, onTime + delayed + cancelled);
    
    float angleOnTime = TWO_PI * onTime / total;
    float angleDelayed = TWO_PI * delayed / total;
    float angleCancelled = TWO_PI * cancelled / total;
    
    float anim = animationProgress;
    
    float startAngle = -HALF_PI;
    stroke(255);
    strokeWeight(2);
    
    fill(0, 200, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleOnTime * anim);
    startAngle += angleOnTime * anim;
    
    fill(0, 0, 255);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleDelayed * anim);
    startAngle += angleDelayed * anim;
    
    fill(255, 0, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleCancelled * anim);
    
    // Legend.
    float legendX = x + 30;
    float legendY = y + 30;
    float boxSize = 25;
    
    textAlign(LEFT, CENTER);
    textSize(18);
    noStroke();
    
    fill(0, 200, 0);
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    text("On Time: " + onTime, legendX + boxSize + 10, legendY + boxSize / 2);
    
    fill(0, 0, 255);
    rect(legendX, legendY + 35, boxSize, boxSize);
    fill(0);
    text("Delayed: " + delayed, legendX + boxSize + 10, legendY + 35 + boxSize / 2);
    
    fill(255, 0, 0);
    rect(legendX, legendY + 70, boxSize, boxSize);
    fill(0);
    text("Cancelled: " + cancelled, legendX + boxSize + 10, legendY + 70 + boxSize / 2);
  }
  
void drawLineGraph(float x, float y, float w, float h) {
  float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 50;
  int[] hourCounts = new int[24];
  int maxCount = 1;

  // Calculate hourly counts and determine maxCount
  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!data.rowMatchesFilter(row, airport)) continue;
      String sched = row.getString("scheduled_departure");
      if (sched != null && sched.length() >= 16) {
        String[] parts = split(sched, ' ');
        if (parts.length == 2) {
          int hr = constrain(parseInt(parts[1].substring(0, 2)), 0, 23);
          hourCounts[hr]++;
          maxCount = max(maxCount, hourCounts[hr]);
        }
      }
    }
  }

  // Ensure we don't divide by 0
  maxCount = max(1, maxCount);

  float plotX = x + marginLeft, plotY = y + marginTop;
  float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;

  // Axes
  stroke(0);
  line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);  // X-axis
  line(plotX, plotY, plotX, plotY + plotH);                  // Y-axis

  // Y-axis ticks
  textAlign(RIGHT, CENTER);
  textSize(16);
  int yTicks = maxCount <= 5 ? maxCount : 5;
  for (int i = 0; i <= yTicks; i++) {
    float val = map(i, 0, yTicks, 0, maxCount);
    float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
    text(int(val), plotX - 8, ypos);
  }

  // X-axis ticks
  textAlign(CENTER, TOP);
  for (int hr = 0; hr < 24; hr++) {
    float xpos = map(hr, 0, 23, plotX, plotX + plotW);
    text(nf(hr, 2), xpos, plotY + plotH + 10);
  }

  // Axis labels
  textAlign(CENTER, BOTTOM);
  textSize(20);
  text("Hour of Day", plotX + plotW / 2, y + h);

  pushMatrix();
  translate(x - 20, plotY + plotH / 2);
  rotate(-HALF_PI);
  textAlign(CENTER, TOP);
  text("Flight Count", 0, 0);
  popMatrix();

  // Animation
  int visiblePoints = int(24 * animationProgress);
  float[] xpos = new float[visiblePoints];
  float[] ypos = new float[visiblePoints];

  for (int hr = 0; hr < visiblePoints; hr++) {
    xpos[hr] = map(hr, 0, 23, plotX, plotX + plotW);
    ypos[hr] = map(hourCounts[hr], 0, maxCount, plotY + plotH, plotY);
  }

  // Fill under line
  noStroke();
  for (int i = 0; i < visiblePoints - 1; i++) {
    float x1 = xpos[i];
    float y1 = ypos[i];
    float x2 = xpos[i + 1];
    float y2 = ypos[i + 1];

    fill(i % 2 == 0 ? color(160, 190, 255) : color(100, 150, 255));
    beginShape();
    vertex(x1, y1);
    vertex(x2, y2);
    vertex(x2, plotY + plotH);
    vertex(x1, plotY + plotH);
    endShape(CLOSE);
  }

  // Line graph
  noFill();
  stroke(0, 0, 255);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i < visiblePoints; i++) {
    vertex(xpos[i], ypos[i]);
  }
  endShape();

  // Points and flight count labels (with label nudge for hour 00)
  textSize(14);
  textAlign(CENTER, BOTTOM);
  for (int i = 0; i < visiblePoints; i++) {
    fill(0, 0, 255);
    noStroke();
    ellipse(xpos[i], ypos[i], 6, 6);

    fill(0);
    float labelX = xpos[i];
    if (i == 0) labelX += 15;  // Nudge label right for hour 00 only
    text(hourCounts[i], labelX, ypos[i] - 8);
  }
}

  
void drawBarChart(float x, float y, float w, float h) {
  float marginLeft = 60, marginRight = 30, marginTop = 80, marginBottom = 200; // Increased bottom margin
  HashMap<String, Integer> destCounts = new HashMap<>();

  // Count flights per destination
  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!data.rowMatchesFilter(row, airport)) continue;
      String dest = row.getString("destination").trim();
      if (!dest.equals("")) {
        destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
      }
    }
  }

  // Convert to list and sort by count (descending)
  ArrayList<Map.Entry<String, Integer>> destList = new ArrayList<>(destCounts.entrySet());
  Collections.sort(destList, (a, b) -> b.getValue().compareTo(a.getValue()));

  int itemsAvailable = destList.size();
  int itemsToShow = min(5, itemsAvailable);

  // Get top N, then sort those alphabetically by full airport name
  destList = new ArrayList<>(destList.subList(0, itemsToShow));
  Collections.sort(destList, (a, b) -> {
    String nameA = airportLookup.getOrDefault(a.getKey(), a.getKey());
    String nameB = airportLookup.getOrDefault(b.getKey(), b.getKey());
    return nameA.compareToIgnoreCase(nameB);
  });

  float gap = 10;
  float plotW = w - marginLeft - marginRight;
  float barWidth = (plotW - gap * 6) / 5.0;
  float totalBarWidth = itemsToShow * barWidth + (itemsToShow - 1) * gap;
  float offsetX = (plotW - totalBarWidth) / 2;

  int maxCount = 1;
  for (int i = 0; i < itemsToShow; i++) {
    maxCount = max(maxCount, destList.get(i).getValue());
  }

  float plotX = x + marginLeft, plotY = y + marginTop;
  float plotH = h - marginTop - marginBottom;

  stroke(0);
  line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
  line(plotX, plotY, plotX, plotY + plotH);

  // Warning if fewer than 5
  if (itemsAvailable < 5) {
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(18);
    text("Not enough destinations available to show a full top 5 list.", x + w / 2, y + 20);
  }

  for (int i = 0; i < itemsToShow; i++) {
    Map.Entry<String, Integer> entry = destList.get(i);
    String code = entry.getKey();
    String fullLabel = airportLookup.get(code);
    if (fullLabel == null) fullLabel = code;

    int count = entry.getValue();
    float barHeight = map(count, 0, maxCount, 0, plotH) * animationProgress;

    float bx = plotX + offsetX + i * (barWidth + gap);
    float by = plotY + plotH - barHeight;

    fill(100, 150, 255);
    noStroke();
    rect(bx, by, barWidth, barHeight);

    fill(0);
    textSize(18);
    textAlign(CENTER, BOTTOM);
    text(count, bx + barWidth / 2, by - 6);

    // Label splitting and layout
    String line1 = fullLabel.contains("(") ? fullLabel.substring(0, fullLabel.indexOf("(")).trim() : fullLabel;
    String line2 = fullLabel.contains("(") ? fullLabel.substring(fullLabel.indexOf("("), fullLabel.indexOf(")") + 1).trim() : "";
    String[] labelLines = { line1, line2, code };

    float maxLabelWidth = barWidth + gap * 2;
    float fitted = getFittedTextSize(labelLines, maxLabelWidth, 26);
    fitted = min(fitted, 24);
    textSize(fitted);

    textAlign(CENTER, TOP);
    for (int j = 0; j < labelLines.length; j++) {
      text(labelLines[j], bx + barWidth / 2, plotY + plotH + 6 + j * (fitted + 2));
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
  text("Destination Airports", plotX + plotW / 2, y + h - 10);

  pushMatrix();
  translate(x + 5, plotY + plotH / 2);
  rotate(-HALF_PI);
  textAlign(CENTER, TOP);
  text("Flight Count", 0, 0);
  popMatrix();

  textAlign(CENTER, TOP);
  textSize(22);
  text("Top 5 Destination Airports", x + w / 2, y - 20);
}

void drawGroupedBarChart(float x, float y, float w, float h) {
  float marginLeft = 120, marginRight = 120, marginTop = 60, marginBottom = 140;
  float plotX = x + marginLeft, plotY = y + marginTop;
  float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;

  HashMap<String, float[]> airlineStats = new HashMap<>();

  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!data.rowMatchesFilter(row, airport)) continue;
      String airline = row.getString("airline_name").trim();
      if (airline.equals("")) airline = "Unknown";
      float[] st = airlineStats.getOrDefault(airline, new float[]{0, 0, 0});
      if (row.getString("cancelled").equalsIgnoreCase("true")) st[2]++;
      try {
        int delay = row.getInt("minutes_late");
        if (delay < 0) delay = 0;
        st[0] += delay;
        st[1]++;
      } catch(Exception e) {}
      airlineStats.put(airline, st);
    }
  }

  // First: sort by flight count (index 1), then take top 10
  ArrayList<Map.Entry<String, float[]>> list = new ArrayList<>(airlineStats.entrySet());
  Collections.sort(list, (a, b) -> Float.compare(b.getValue()[1], a.getValue()[1]));
  int itemsToShow = min(10, list.size());
  list = new ArrayList<>(list.subList(0, itemsToShow));

  // Then: sort alphabetically by airline name
  Collections.sort(list, (a, b) -> a.getKey().compareToIgnoreCase(b.getKey()));

  // Prepare data lists
  ArrayList<String> airlines = new ArrayList<>();
  ArrayList<Float> avgDelays = new ArrayList<>();
  ArrayList<Float> cancelRates = new ArrayList<>();
  float maxAvgDelay = 0, maxCancelRate = 0;

  for (Map.Entry<String, float[]> e : list) {
    String airline = e.getKey();
    float[] st = e.getValue();
    float avgDelay = (st[1] > 0) ? st[0] / st[1] : 0;
    float cancelRate = (st[1] > 0) ? st[2] / st[1] : 0;
    airlines.add(airline);
    avgDelays.add(avgDelay);
    cancelRates.add(cancelRate);
    maxAvgDelay = max(maxAvgDelay, avgDelay);
    maxCancelRate = max(maxCancelRate, cancelRate);
  }

  maxAvgDelay = max(maxAvgDelay, 1);
  maxCancelRate = max(maxCancelRate, 1);

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
  text("Avg Delay (min)", legendX + boxSize + 8, legendY + boxSize / 2);

  fill(200, 0, 0);
  rect(legendX, legendY + 25, boxSize, boxSize);
  fill(0);
  text("Cancellation Rate (%)", legendX + boxSize + 8, legendY + 25 + boxSize / 2);

  // Y-axis for Avg Delay (left)
  stroke(0);
  line(plotX, plotY, plotX, plotY + plotH);
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
  translate(plotX - 70, plotY + plotH / 2);
  rotate(-HALF_PI);
  text("Avg Delay (min)", 0, 0);
  popMatrix();

  // Y-axis for Cancellation Rate (right)
  float rightX = plotX + plotW;
  stroke(0);
  line(rightX, plotY, rightX, plotY + plotH);
  textAlign(LEFT, CENTER);
  for (int i = 0; i <= yTicks; i++) {
    float val = map(i, 0, yTicks, 0, maxCancelRate);
    float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
    line(rightX, ypos, rightX + 5, ypos);
    text(nf(val * 100, 0, 1) + "%", rightX + 10, ypos);
  }
  pushMatrix();
  translate(rightX + 70, plotY + plotH / 2);
  rotate(HALF_PI);
  text("Cancellation Rate (%)", 0, 0);
  popMatrix();

  stroke(0);
  line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);

  // Draw bars
  float groupWidth = plotW / itemsToShow;
  float barWidth = groupWidth / 3;

  for (int i = 0; i < itemsToShow; i++) {
    float groupX = plotX + i * groupWidth;

    float delayH = map(avgDelays.get(i), 0, maxAvgDelay, 0, plotH) * animationProgress;
    float cancelH = map(cancelRates.get(i), 0, maxCancelRate, 0, plotH) * animationProgress;

    float bx1 = groupX + groupWidth / 2 - barWidth - 4;
    float by1 = plotY + plotH - delayH;
    fill(0, 0, 200);
    rect(bx1, by1, barWidth, delayH);
    fill(0);
    textAlign(CENTER, BOTTOM);
    textSize(14);
    text(nf(avgDelays.get(i), 0, 1), bx1 + barWidth / 2, by1 - 2);

    float bx2 = groupX + groupWidth / 2 + 4;
    float by2 = plotY + plotH - cancelH;
    fill(200, 0, 0);
    rect(bx2, by2, barWidth, cancelH);
    fill(0);
    text(nf(cancelRates.get(i) * 100, 0, 1) + "%", bx2 + barWidth / 2, by2 - 2);

    // Airline label wrapping
    String label = airlines.get(i);
    String[] parts = splitTokens(label, " ");
    if (parts.length > 2) {
      int half = parts.length / 2;
      parts = new String[] {
        join(subset(parts, 0, half), " "),
        join(subset(parts, half), " ")
      };
    }
    float ts = getFittedTextSize(parts, groupWidth, 16);
    textSize(ts);
    textAlign(CENTER, TOP);
    for (int j = 0; j < parts.length; j++) {
      text(parts[j], groupX + groupWidth / 2, plotY + plotH + 5 + j * (ts + 2));
    }
  }

  // Final labels
  textAlign(CENTER, BOTTOM);
  textSize(20);
  text("Airlines", plotX + plotW / 2, y + h - 8);

  textAlign(CENTER, TOP);
  textSize(24);
  text("Airline Performance", x + w / 2, y - 20);
 }
}
