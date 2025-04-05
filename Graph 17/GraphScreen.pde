// GraphScreen.pde
import java.util.Map;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

// These icons are generated in this file.
PImage iconPie, iconLine, iconBar, iconGrouped;

class GraphScreen {
  String airport;
  ProcessData data;
  
  // When inMenu is true, show the 4 big graph options.
  boolean inMenu = true;
  // Selected graph: 0=Pie, 1=Line, 2=Bar, 3=Grouped
  int selectedGraph = 0;
  
  // Button dimensions for the menu.
  float btnWidth = 500;
  float btnHeight = 240;
  float btnGap = 80;
  
  int graphStartTime = 0;
  float animationProgress = 0;
  float animationDuration = 1000;
  
  // Calendar integration.
  CalendarDisplay calendar;
  boolean calendarVisible = false;
  // Selected date (format "YYYY-MM-DD")
  String currentFilterDate = "";
  
  // Toggle buttons positions.
  float calendarBtnX, calendarBtnY, calendarBtnW, calendarBtnH;
  float annualBtnX, annualBtnY, annualBtnW, annualBtnH;
  boolean useAnnualData = true;
  
  GraphScreen(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
    generateIcons();
    
    // Initialize calendar.
    calendar = new CalendarDisplay();
    calendar.x = width - 370;
    calendar.y = 70;
    
    // Calendar toggle button.
    calendarBtnW = 120;
    calendarBtnH = 30;
    calendarBtnX = width - calendarBtnW - 20;
    calendarBtnY = 10;
    
    // Annual toggle button.
    annualBtnW = 120;
    annualBtnH = 30;
    annualBtnX = calendarBtnX - annualBtnW - 10;
    annualBtnY = calendarBtnY;
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
  
  // Main display function.
  void display() {
    background(255);
    drawBackButton();
    
    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin != null) fullOrigin += " / " + airport;
    else fullOrigin = airport;
    
    if (inMenu) {
      drawMenu();
    } else {
      // Process data based on toggle.
      if (useAnnualData) {
        data.process(airport);
      } else if (currentFilterDate != null && currentFilterDate.length() > 0) {
        data.processDaily(airport, currentFilterDate);
      } else {
        data.process(airport);
      }
      
      int elapsed = millis() - graphStartTime;
      animationProgress = constrain(elapsed / animationDuration, 0, 1);
      
      String title;
      if (useAnnualData) {
        title = "Full Annual Flight Data for " + fullOrigin;
      } else if (currentFilterDate != null && currentFilterDate.length() > 0) {
        title = "Daily Flight Data for " + fullOrigin + " on " + currentFilterDate;
      } else {
        title = "Flight Data for " + fullOrigin;
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
      
      drawAnnualButton();
      drawCalendarButton();
      
      if (calendarVisible) {
        hint(DISABLE_DEPTH_TEST);
        calendar.display();
        hint(ENABLE_DEPTH_TEST);
      }
    }
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
  
  void drawCalendarButton() {
    boolean hovering = (mouseX >= calendarBtnX && mouseX <= calendarBtnX + calendarBtnW &&
                          mouseY >= calendarBtnY && mouseY <= calendarBtnY + calendarBtnH);
    stroke(0);
    strokeWeight(1);
    fill(hovering ? 150 : 180);
    rect(calendarBtnX, calendarBtnY, calendarBtnW, calendarBtnH, 5);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Calendar", calendarBtnX + calendarBtnW/2, calendarBtnY + calendarBtnH/2);
  }
  
  void drawAnnualButton() {
    boolean hovering = (mouseX >= annualBtnX && mouseX <= annualBtnX + annualBtnW &&
                          mouseY >= annualBtnY && mouseY <= annualBtnY + annualBtnH);
    stroke(0);
    strokeWeight(1);
    if (useAnnualData) {
      fill(hovering ? color(50,150,255) : color(0,0,255));
    } else {
      fill(hovering ? 150 : 180);
    }
    rect(annualBtnX, annualBtnY, annualBtnW, annualBtnH, 5);
    fill(useAnnualData ? 255 : 0);
    textSize(16);
    textAlign(CENTER, CENTER);
    String label = useAnnualData ? "Annual: On" : "Annual: Off";
    text(label, annualBtnX + annualBtnW/2, annualBtnY + annualBtnH/2);
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
      "Bar Chart\n(Top 5 Destinations)",
      "Grouped Bar Chart\n(Airline Performance)"
    };
    
    PImage[] icons = { iconPie, iconLine, iconBar, iconGrouped };
    
    for (int i = 0; i < 4; i++) {
      int col = i % 2;
      int row = i / 2;
      float bx = startX + col * (btnWidth + btnGap);
      float by = startY + row * (btnHeight + btnGap);
      fill((mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) ? 120 : 100, 
           (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) ? 170 : 150, 255);
      rect(bx, by, btnWidth, btnHeight, 12);
      if (icons[i] != null) {
        imageMode(CENTER);
        image(icons[i], bx + btnWidth/2, by + 65, 64, 64);
      }
      fill(255);
      textAlign(CENTER, TOP);
      textSize(26);
      text(labels[i], bx + btnWidth/2, by + 140);
    }
  }
  
  void mousePressedMenu(float mx, float my) {
    if (mx >= 10 && mx <= 90 && my >= 10 && my <= 40) {
      calendarVisible = false;
      if (inMenu) {
        screenMode = SCREEN_SELECTION;
      } else {
        inMenu = true;
      }
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
          useAnnualData = true;
          currentFilterDate = "";
          graphStartTime = millis();
          animationProgress = 0;
          return;
        }
      }
    } else {
      if (mx >= annualBtnX && mx <= annualBtnX + annualBtnW &&
          my >= annualBtnY && my <= annualBtnY + annualBtnH) {
        useAnnualData = !useAnnualData;
        if (useAnnualData) {
          calendarVisible = false;
          data.process(airport);
        } else {
          if (currentFilterDate != null && currentFilterDate.length() > 0) {
            data.processDaily(airport, currentFilterDate);
          } else {
            data.process(airport);
          }
        }
        return;
      }
      
      if (mx >= calendarBtnX && mx <= calendarBtnX + calendarBtnW &&
          my >= calendarBtnY && my <= calendarBtnY + calendarBtnH) {
        calendarVisible = !calendarVisible;
        if (calendarVisible) {
          calendar.month = 0;
          calendar.selectedDay = 1;
        }
        return;
      }
    }
  }
  
  // ------------- Graph Drawing Methods -------------
  
  void drawPieChart(float x, float y, float w, float h) {
    float cx = x + w/2, cy = y + h/2, dia = min(w, h) * 0.7;
    int onTime = data.onTimeFlights, delayed = data.delayedFlights, cancelled = data.cancelledFlights;
    int total = max(1, onTime + delayed + cancelled);
    
    float angleOnTime = TWO_PI * onTime / total;
    float angleDelayed = TWO_PI * delayed / total;
    float angleCancelled = TWO_PI * cancelled / total;
    
    float anim = animationProgress;
    float startAngle = -HALF_PI;
    stroke(255);
    strokeWeight(2);
    
    fill(0,200,0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleOnTime * anim);
    startAngle += angleOnTime * anim;
    
    fill(0,0,255);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleDelayed * anim);
    startAngle += angleDelayed * anim;
    
    fill(255,0,0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleCancelled * anim);
    
    // Legend.
    float legendX = x + 30, legendY = y + 30, boxSize = 25;
    textAlign(LEFT, CENTER);
    textSize(18);
    noStroke();
    fill(0,200,0); rect(legendX, legendY, boxSize, boxSize);
    fill(0); text("On Time: " + onTime, legendX + boxSize + 10, legendY + boxSize/2);
    fill(0,0,255); rect(legendX, legendY + 35, boxSize, boxSize);
    fill(0); text("Delayed: " + delayed, legendX + boxSize + 10, legendY + 35 + boxSize/2);
    fill(255,0,0); rect(legendX, legendY + 70, boxSize, boxSize);
    fill(0); text("Cancelled: " + cancelled, legendX + boxSize + 10, legendY + 70 + boxSize/2);
  }
  
  void drawLineGraph(float x, float y, float w, float h) {
    float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 50;
    int[] hourCounts = new int[24];
    int maxCount = 1;
    
    // Loop over filtered rows.
    for (TableRow row : data.currentRows) {
      String sched = row.getString("scheduled_departure");
      if (sched != null && sched.length() >= 16) {
        // If needed, uncomment to debug the scheduled_departure values:
        // println("sched =", sched, "substring =", sched.substring(11,13));
        int hr = parseInt(sched.substring(11, 13));
        hr = constrain(hr, 0, 23);
        hourCounts[hr]++;
        maxCount = max(maxCount, hourCounts[hr]);
      }
    }
    
    // Uncomment to see the hourCounts array for debugging.
    // for (int i = 0; i < 24; i++) { println("Hour " + i + ": " + hourCounts[i]); }
    
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    stroke(0);
    line(plotX, plotY+plotH, plotX+plotW, plotY+plotH);
    line(plotX, plotY, plotX, plotY+plotH);
    
    textAlign(RIGHT, CENTER);
    textSize(16);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      text(nf(round(val), 0), plotX - 8, ypos);
    }
    
    textAlign(CENTER, TOP);
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, plotX, plotX+plotW);
      text(nf(hr,2), xpos, plotY+plotH+10);
    }
    
    textAlign(CENTER, BOTTOM);
    textSize(20);
    text("Hour of Day", plotX+plotW/2, y+h);
    
    pushMatrix();
    translate(x-20, plotY+plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, TOP);
    text("Flight Count", 0, 0);
    popMatrix();
    
    int visiblePoints = 24;
    float[] xpos = new float[visiblePoints];
    float[] ypos = new float[visiblePoints];
    
    for (int i = 0; i < visiblePoints; i++) {
      xpos[i] = map(i, 0, 23, plotX, plotX+plotW);
      ypos[i] = map(hourCounts[i], 0, maxCount, plotY+plotH, plotY);
    }
    
    noStroke();
    for (int i = 0; i < visiblePoints - 1; i++) {
      fill(100,150,255);
      beginShape();
      vertex(xpos[i], ypos[i]);
      vertex(xpos[i+1], ypos[i+1]);
      vertex(xpos[i+1], plotY+plotH);
      vertex(xpos[i], plotY+plotH);
      endShape(CLOSE);
    }
    
    noFill();
    stroke(0,0,255);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < visiblePoints; i++) {
      vertex(xpos[i], ypos[i]);
    }
    endShape();
    
    textSize(14);
    textAlign(CENTER, BOTTOM);
    for (int i = 0; i < visiblePoints; i++) {
      fill(0,0,255);
      noStroke();
      ellipse(xpos[i], ypos[i], 6, 6);
      fill(0);
      text(hourCounts[i], xpos[i], ypos[i]-8);
    }
  }
  
  void drawBarChart(float x, float y, float w, float h) {
    float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 150;
    HashMap<String, Integer> destCounts = new HashMap<>();
    
    for (TableRow row : data.currentRows) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
      String dest = row.getString("destination").trim();
      if (!dest.equals("")) {
        destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
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
    line(plotX, plotY+plotH, plotX+plotW, plotY+plotH);
    line(plotX, plotY, plotX, plotY+plotH);
    
    for (int i = 0; i < itemsToShow; i++) {
      Map.Entry<String, Integer> entry = destList.get(i);
      String code = entry.getKey();
      String fullLabel = airportLookup.get(code);
      if (fullLabel == null) fullLabel = code;
      
      int count = entry.getValue();
      float barHeight = map(count, 0, maxCount, 0, plotH) * animationProgress;
      
      float bx = plotX + gap + i * (barWidth + gap);
      float by = plotY + plotH - barHeight;
      
      fill(100,150,255);
      noStroke();
      rect(bx, by, barWidth, barHeight);
      
      fill(0);
      textSize(18);
      textAlign(CENTER, BOTTOM);
      text(count, bx + barWidth/2, by - 6);
      
      String line1 = fullLabel.contains("(") ? fullLabel.substring(0, fullLabel.indexOf("(")).trim() : fullLabel;
      String line2 = fullLabel.contains("(") ? fullLabel.substring(fullLabel.indexOf("("), fullLabel.indexOf(")") + 1).trim() : "";
      String[] labelLines = { line1, line2, code };
      float fitted = getFittedTextSize(labelLines, barWidth + 20, 20);
      
      textSize(fitted);
      textAlign(CENTER, TOP);
      for (int j = 0; j < labelLines.length; j++) {
        text(labelLines[j], bx + barWidth/2, plotY + plotH + 6 + j * (fitted + 2));
      }
    }
    
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      text(nf(round(val), 0), plotX - 8, ypos);
    }
    
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
  
  void drawGroupedBarChart(float x, float y, float w, float h) {
    float marginLeft = 120, marginRight = 120, marginTop = 60, marginBottom = 140;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    HashMap<String, float[]> airlineStats = new HashMap<>();
    
    for (TableRow row : data.currentRows) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
      String airline = row.getString("airline_name").trim();
      if (airline.equals("")) airline = "Unknown";
      float[] st = airlineStats.getOrDefault(airline, new float[]{0,0,0});
      if (row.getString("cancelled").equalsIgnoreCase("true")) st[2]++;
      try {
        int delay = row.getInt("minutes_late");
        if (delay < 0) delay = 0;
        st[0] += delay;
        st[1]++;
      } catch(Exception e) {}
      airlineStats.put(airline, st);
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
    
    float legendX = plotX + 10, legendY = plotY - 80, boxSize = 20;
    fill(0,0,200);
    noStroke();
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("Avg Delay (min)", legendX + boxSize + 8, legendY + boxSize/2);
    
    fill(200,0,0);
    rect(legendX, legendY+25, boxSize, boxSize);
    fill(0);
    text("Cancellation Rate (%)", legendX + boxSize + 8, legendY+25+boxSize/2);
    
    stroke(0);
    line(plotX, plotY, plotX, plotY+plotH);
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxAvgDelay);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      line(plotX - 5, ypos, plotX, ypos);
      text(nf(val, 0, 1), plotX - 10, ypos);
    }
    pushMatrix();
    translate(plotX - 70, plotY+plotH/2);
    rotate(-HALF_PI);
    text("Avg Delay (min)", 0, 0);
    popMatrix();
    
    float rightX = plotX+plotW;
    stroke(0);
    line(rightX, plotY, rightX, plotY+plotH);
    textAlign(LEFT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCancelRate);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      line(rightX, ypos, rightX+5, ypos);
      text(nf(val*100, 0, 1)+"%", rightX+10, ypos);
    }
    pushMatrix();
    translate(rightX+70, plotY+plotH/2);
    rotate(HALF_PI);
    text("Cancellation Rate (%)", 0, 0);
    popMatrix();
    
    stroke(0);
    line(plotX, plotY+plotH, plotX+plotW, plotY+plotH);
    
    float groupWidth = plotW / itemsToShow;
    float barWidth = groupWidth / 3;
    
    for (int i = 0; i < itemsToShow; i++) {
      float groupX = plotX + i * groupWidth;
      float delayH = map(avgDelays.get(i), 0, maxAvgDelay, 0, plotH) * animationProgress;
      float cancelH = map(cancelRates.get(i), 0, maxCancelRate, 0, plotH) * animationProgress;
      
      float bx1 = groupX + groupWidth/2 - barWidth - 4;
      float by1 = plotY + plotH - delayH;
      fill(0,0,200);
      rect(bx1, by1, barWidth, delayH);
      fill(0);
      textAlign(CENTER, BOTTOM);
      textSize(14);
      text(nf(avgDelays.get(i),0,1), bx1+barWidth/2, by1-2);
      
      float bx2 = groupX + groupWidth/2 + 4;
      float by2 = plotY + plotH - cancelH;
      fill(200,0,0);
      rect(bx2, by2, barWidth, cancelH);
      fill(0);
      textAlign(CENTER, BOTTOM);
      textSize(14);
      text(nf(cancelRates.get(i)*100,0,1)+"%", bx2+barWidth/2, by2-2);
    }
    
    textAlign(CENTER, TOP);
    textSize(16);
    String[] monthLabels = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
    float barGap = 10;
    float availableW = plotW - 13 * barGap;
    float monthBarWidth = availableW / 12;
    for (int m = 0; m < 12; m++) {
      float bx = map(m, 0, 11, plotX, plotX+plotW) + barGap;
      text(monthLabels[m], bx+monthBarWidth/2, plotY+plotH+5);
    }
  }
}

// Helper: Adjust text size to fit within maxWidth.
float getFittedTextSize(String[] lines, float maxWidth, int startingSize) {
  float sizeCandidate = startingSize;
  boolean fits = false;
  while (!fits && sizeCandidate > 5) {
    fits = true;
    textSize(sizeCandidate);
    for (int i = 0; i < lines.length; i++) {
      if (textWidth(lines[i]) > maxWidth) {
        fits = false;
        break;
      }
    }
    if (!fits) {
      sizeCandidate--;
    }
  }
  return sizeCandidate;
}
