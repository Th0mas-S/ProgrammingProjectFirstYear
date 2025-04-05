// GraphScreen.pde
// Displays a menu of four traditional graphs:
//   0: Pie Chart – Overall Flight Status Breakdown
//   1: Line Graph – Hourly Flight Counts
//   2: Bar Chart – Top 5 Destination Airports with three-line labels
//   3: Grouped Bar Chart – Airline Performance
// A dynamic "Back" button is drawn at the top left.

import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;  // Needed for Map.Entry

PImage iconPie, iconLine, iconBar, iconGrouped;

// Helper: Adjust text size so that all lines fit within maxAllowedWidth.
float getFittedTextSize(String[] lines, float maxAllowedWidth, float desiredSize) {
  float ts = desiredSize;
  textSize(ts);
  while(ts > 10) {
    float maxLineWidth = 0;
    for (String line : lines) {
      float w = textWidth(line);
      if (w > maxLineWidth) {
        maxLineWidth = w;
      }
    }
    if (maxLineWidth <= maxAllowedWidth) {
      break;
    } else {
      ts -= 1;
      textSize(ts);
    }
  }
  return ts;
}

// Dynamic Back button with hover effect.
// Here we reset the stroke to black with a 1-pixel weight.
void drawBackButton() {
  int bx = 10, by = 10, bw = 80, bh = 30;
  // Reset stroke for consistent borders.
  stroke(0);
  strokeWeight(1);
  
  if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
    fill(150);  // darker on hover
  } else {
    fill(180);
  }
  rect(bx, by, bw, bh, 5);
  
  fill(0);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("Back", bx + bw/2, by + bh/2);
}

class GraphScreen {
  String airport;
  ProcessData data;

  boolean inMenu = true;
  int selectedGraph = 0;

  float btnWidth = 500;
  float btnHeight = 240;
  float btnGap = 80;

  int graphStartTime = 0;
  float animationProgress = 0;
  float animationDuration = 1000;

  GraphScreen(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
    generateIcons();
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

    // On Time – small slice
    float angleOnTime = totalAngle * 0.10;
    pg.fill(0, 200, 0);
    pg.arc(32, 32, 50, 50, start, start + angleOnTime);
    start += angleOnTime;

    // Delayed – dominant slice
    float angleDelayed = totalAngle * 0.65;
    pg.fill(0, 0, 255);
    pg.arc(32, 32, 50, 50, start, start + angleDelayed);
    start += angleDelayed;

    // Cancelled – remainder
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
    pg.fill(255, 140, 0);  // ORANGE bars
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
  
 void display() {
    background(255);
    drawBackButton();

    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin != null) fullOrigin += " / " + airport;
    else fullOrigin = airport;

    if (inMenu) {
      drawMenu();
    } else {
      int elapsed = millis() - graphStartTime;
      animationProgress = constrain(elapsed / animationDuration, 0, 1);

      String title = "";
      switch(selectedGraph) {
        case 0: title = "Flight Status Breakdown for " + fullOrigin; break;
        case 1: title = "Hourly Flight Counts for " + fullOrigin; break;
        case 2: title = "Top 5 Destinations from " + fullOrigin; break;
        case 3: title = "Airline Performance for " + fullOrigin; break;
      }

      fill(0);
      textSize(24);
      textAlign(CENTER, TOP);
      text(title, width/2, 15);

      float gx = 150, gy = 150, gw = width - 300, gh = height - 300;
      switch(selectedGraph) {
        case 0: drawPieChart(gx, gy, gw, gh); break;
        case 1: drawLineGraph(gx, gy, gw, gh); break;
        case 2: drawBarChart(gx, gy, gw, gh); break;
        case 3: drawGroupedBarChart(gx, gy, gw, gh); break;
      }
    }
  }
  
  // Called from Main.pde's mousePressed() event.
 void mousePressedMenu(float mx, float my) {
    if (mouseX >= 10 && mouseX <= 90 && mouseY >= 10 && mouseY <= 40) {
      if (inMenu) screenMode = SCREEN_SELECTION;
      else inMenu = true;
      return;
    }

    if (inMenu) {
      float totalWidth = 2 * btnWidth + btnGap;
      float totalHeight = 2 * btnHeight + btnGap;
      float startX = width/2 - totalWidth/2;
      float startY = height/2 - totalHeight/2;

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
          break;
        }
      }
    }
  }
  
   void drawMenu() {
    stroke(0);
    strokeWeight(1);
    float totalWidth = 2 * btnWidth + btnGap;
    float totalHeight = 2 * btnHeight + btnGap;
    float startX = width/2 - totalWidth/2;
    float startY = height/2 - totalHeight/2;

    String[] labels = {
      "Pie Chart\n(Flight Status)",
      "Line Graph\n(Hourly Counts)",
      "Bar Chart\n(Top Destinations)",
      "Grouped Bar Chart\n(Airline Performance)"
    };

    PImage[] icons = {
      iconPie,
      iconLine,
      iconBar,
      iconGrouped
    };

    for (int i = 0; i < 4; i++) {
      int col = i % 2;
      int row = i / 2;
      float bx = startX + col * (btnWidth + btnGap);
      float by = startY + row * (btnHeight + btnGap);

      if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight)
        fill(120, 170, 255);
      else
        fill(100, 150, 255);

      rect(bx, by, btnWidth, btnHeight, 12);

      if (icons[i] != null) {
        imageMode(CENTER);
        image(icons[i], bx + btnWidth / 2, by + 65, 64, 64);
      }

      fill(255);
      textAlign(CENTER, TOP);
      textSize(26);
      text(labels[i], bx + btnWidth/2, by + 140);
    }
  }
  
  // ---------------------------
  // Graph 0: Pie Chart – On Time (green), Delayed (blue), Cancelled (red)
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

  // Draw Legend
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
  
  // ---------------------------
  // Graph 1: Line Graph – Hourly Flight Counts with labeled axes
void drawLineGraph(float x, float y, float w, float h) {
  float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 50;

  int[] hourCounts = new int[24];
  int maxCount = 1;

  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
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

  float plotX = x + marginLeft, plotY = y + marginTop;
  float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;

  // Axes
  stroke(0);
  line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
  line(plotX, plotY, plotX, plotY + plotH);

  // Y-axis ticks
  textAlign(RIGHT, CENTER);
  textSize(16);
  int yTicks = 5;
  for (int i = 0; i <= yTicks; i++) {
    float val = map(i, 0, yTicks, 0, maxCount);
    float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
    text(nf(round(val), 0), plotX - 8, ypos);
  }

  // X-axis hour labels
  textAlign(CENTER, TOP);
  textSize(16);
  for (int hr = 0; hr < 24; hr++) {
    float xpos = map(hr, 0, 23, plotX, plotX + plotW);
    text(nf(hr, 2), xpos, plotY + plotH + 10);
  }

  // Axis Titles (adjusted spacing)
  textAlign(CENTER, BOTTOM);
  textSize(20);
  text("Hour of Day", plotX + plotW / 2, y + h); // ⬅️ pushed lower

  pushMatrix();
  translate(x - 20, plotY + plotH / 2); // ⬅️ pushed further left
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

  // Alternating fill columns
  noStroke();
  for (int i = 0; i < visiblePoints - 1; i++) {
    float x1 = xpos[i];
    float y1 = ypos[i];
    float x2 = xpos[i + 1];
    float y2 = ypos[i + 1];

    if (i % 2 == 0) fill(160, 190, 255);
    else            fill(100, 150, 255);

    beginShape();
    vertex(x1, y1);
    vertex(x2, y2);
    vertex(x2, plotY + plotH);
    vertex(x1, plotY + plotH);
    endShape(CLOSE);
  }

  // Line
  noFill();
  stroke(0, 0, 255);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i < visiblePoints; i++) {
    vertex(xpos[i], ypos[i]);
  }
  endShape();

  // Dots and labels
  textSize(14);
  textAlign(CENTER, BOTTOM);
  for (int i = 0; i < visiblePoints; i++) {
    fill(0, 0, 255);
    noStroke();
    ellipse(xpos[i], ypos[i], 6, 6);

    fill(0);
    text(hourCounts[i], xpos[i], ypos[i] - 8);
  }
}
  
  // ---------------------------
  // Graph 2: Bar Chart – Top 5 Destination Airports with straight, three-line labels
void drawBarChart(float x, float y, float w, float h) {
  float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 150;

  HashMap<String, Integer> destCounts = new HashMap<>();
  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
      String dest = row.getString("destination").trim();
      if (!dest.equals("")) {
        destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
      }
    }
  }

  ArrayList<Map.Entry<String, Integer>> destList = new ArrayList<>(destCounts.entrySet());
  Collections.sort(destList, (a, b) -> b.getValue().compareTo(a.getValue()));
  int itemsToShow = min(5, destList.size());

  float gap = 10, totalGap = gap * (itemsToShow + 1);
  float plotW = w - marginLeft - marginRight;
  float barWidth = (plotW - totalGap) / itemsToShow;

  int maxCount = 1;
  for (int i = 0; i < itemsToShow; i++) {
    maxCount = max(maxCount, destList.get(i).getValue());
  }

  float plotX = x + marginLeft, plotY = y + marginTop;
  float plotH = h - marginTop - marginBottom;

  stroke(0);
  line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
  line(plotX, plotY, plotX, plotY + plotH);

  // Draw bars
  for (int i = 0; i < itemsToShow; i++) {
    Map.Entry<String, Integer> entry = destList.get(i);
    String code = entry.getKey();
    String fullLabel = airportLookup.get(code);
    if (fullLabel == null) fullLabel = code;

    int count = entry.getValue();
    float barHeight = map(count, 0, maxCount, 0, plotH) * animationProgress;

    float bx = plotX + gap + i * (barWidth + gap);
    float by = plotY + plotH - barHeight;

    fill(100, 150, 255);
    noStroke();
    rect(bx, by, barWidth, barHeight);

    // Value above bar
    fill(0);
    textSize(18);
    textAlign(CENTER, BOTTOM);
    text(count, bx + barWidth / 2, by - 6);

    // 3-line label
    String line1 = fullLabel.contains("(") ? fullLabel.substring(0, fullLabel.indexOf("(")).trim() : fullLabel;
    String line2 = fullLabel.contains("(") ? fullLabel.substring(fullLabel.indexOf("("), fullLabel.indexOf(")") + 1).trim() : "";
    String[] labelLines = { line1, line2, code };
    float fitted = getFittedTextSize(labelLines, barWidth + 20, 20);

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
  
  // ---------------------------
  // Graph 3: Grouped Bar Chart – Airline Performance with values above bars and color legend.
  // Cancellation Rate is shown as percentage.
 void drawGroupedBarChart(float x, float y, float w, float h) {
  float marginLeft = 120, marginRight = 120, marginTop = 60, marginBottom = 140;
  float plotX = x + marginLeft, plotY = y + marginTop;
  float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;

  HashMap<String, float[]> airlineStats = new HashMap<>();

  if (data.table != null) {
    for (TableRow row : data.table.rows()) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
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

  ArrayList<Map.Entry<String, float[]>> list = new ArrayList<>(airlineStats.entrySet());
  Collections.sort(list, (a, b) -> Float.compare(b.getValue()[1], a.getValue()[1]));

  int itemsToShow = min(10, list.size());

  ArrayList<String> airlines = new ArrayList<>();
  ArrayList<Float> avgDelays = new ArrayList<>();
  ArrayList<Float> cancelRates = new ArrayList<>();
  float maxAvgDelay = 0, maxCancelRate = 0;

  for (int i = 0; i < itemsToShow; i++) {
    Map.Entry<String, float[]> e = list.get(i);
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

  // --- Draw legend
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

  // --- Y-axis Left (Avg Delay)
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

  // --- Y-axis Right (Cancellation Rate)
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

  // --- x-axis
  stroke(0);
  line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);

  float groupWidth = plotW / itemsToShow;
  float barWidth = groupWidth / 3;

  for (int i = 0; i < itemsToShow; i++) {
    float groupX = plotX + i * groupWidth;

    float delayH = map(avgDelays.get(i), 0, maxAvgDelay, 0, plotH) * animationProgress;
    float cancelH = map(cancelRates.get(i), 0, maxCancelRate, 0, plotH) * animationProgress;

    // Avg delay (blue)
    float bx1 = groupX + groupWidth / 2 - barWidth - 4;
    float by1 = plotY + plotH - delayH;
    fill(0, 0, 200);
    rect(bx1, by1, barWidth, delayH);
    fill(0);
    textAlign(CENTER, BOTTOM);
    textSize(14);
    text(nf(avgDelays.get(i), 0, 1), bx1 + barWidth / 2, by1 - 2);

    // Cancel rate (red)
    float bx2 = groupX + groupWidth / 2 + 4;
    float by2 = plotY + plotH - cancelH;
    fill(200, 0, 0);
    rect(bx2, by2, barWidth, cancelH);
    fill(0);
    textAlign(CENTER, BOTTOM);
    text(nf(cancelRates.get(i) * 100, 0, 1) + "%", bx2 + barWidth / 2, by2 - 2);

    // Airline label (1–2 lines)
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

  // Bottom and top titles
  textAlign(CENTER, BOTTOM);
  textSize(20);
  text("Airlines", plotX + plotW / 2, y + h - 8);

  textAlign(CENTER, TOP);
  textSize(24);
  text("Airline Performance", x + w / 2, y - 20);
 }

}
