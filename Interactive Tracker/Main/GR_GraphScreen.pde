// :)
// Standard repeat variables for letters:
boolean backspaceHeld = false;
int backspaceHoldStart = 0;
int backspaceLastDelete = 0;
int initialDelay = 300;
int repeatRate = 50;

// CTRL-BACKSPACE variables:
boolean ctrlBackspaceHeld = false;
int ctrlBackspaceHoldStart = 0;
int ctrlBackspaceLastRepeat = 0;
int ctrlBackspaceInitialDelay = 300; // ms before repeat starts
int ctrlBackspaceRepeatRate = 50;    // ms between repeats

// Other key (letters, etc.) repeat variables:
char heldKey = 0;
boolean keyBeingHeld = false;
int keyHoldStart = 0;
int keyLastRepeat = 0;

// Arrow key repeat variables:
boolean arrowLeftHeld = false;
boolean arrowRightHeld = false;
int arrowHoldStart = 0;
int arrowLastRepeat = 0;
int arrowInitialDelay = 300; // ms before arrow repeat starts
int arrowRepeatRate = 50;    // ms between arrow repeats

// Screen modes:
int SCREEN_SELECTION = 0;
int SCREEN_OVERVIEW = 1;
int screenMode = SCREEN_SELECTION;

// Other globals:
Utility util;
AirportSelectorMenu airportSelector;
GraphSelectorMenu graphScreen;
ProcessData processData;
String[] uniqueAirports;
PFont unicodeFont;
PImage flighthubLogo;
HashMap<String, String> airportLookup = new HashMap<String, String>();

void insertKeyChar(char c) {
  if (airportSelector.searchQuery.length() >= SEARCH_CHAR_LIMIT) return;
  
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    c +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart + 1;
    airportSelector.clearSelection();
  } else {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                    c +
                                    airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex++;
    airportSelector.clearSelection();
  }
  airportSelector.resetScroll();
}

void handleBackspace() {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  } 
  else if (airportSelector.caretIndex > 0) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex - 1) +
                                    airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex--;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  }
}

void handleCtrlBackspace() {
  // If searchQuery is empty, disable CTRL-backspace.
  if (airportSelector.searchQuery.length() == 0) {
    ctrlBackspaceHeld = false;
    return;
  }
  
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  
  // If a selection exists, delete it.
  if (selStart != selEnd) {
    airportSelector.searchQuery = 
      airportSelector.searchQuery.substring(0, selStart) +
      airportSelector.searchQuery.substring(selEnd);
    airportSelector.setCaretIndex(selStart);
    airportSelector.selectionStart = airportSelector.selectionEnd = airportSelector.caretIndex;
    airportSelector.resetScroll();
    return;
  }
  
  String text = airportSelector.searchQuery;
  int caret = airportSelector.caretIndex;
  if (caret == 0) return; // Nothing to delete if at beginning
  
  int left = caret;
  // Remove trailing spaces.
  while (left > 0 && text.charAt(left - 1) == ' ') {
    left--;
  }
  // Remove any special (non-alphanumeric) characters.
  while (left > 0 && isSpecialChar(text.charAt(left - 1))) {
    left--;
  }
  // Remove word characters (letters/digits).
  while (left > 0 && isWordChar(text.charAt(left - 1))) {
    left--;
  }
  // Remove any additional whitespace.
  while (left > 0 && text.charAt(left - 1) == ' ') {
    left--;
  }
  
  airportSelector.searchQuery = text.substring(0, left) + text.substring(caret);
  airportSelector.setCaretIndex(left);
  airportSelector.selectionStart = airportSelector.selectionEnd = airportSelector.caretIndex;
  airportSelector.resetScroll();
}

boolean isWordChar(char c) {
  return Character.isLetterOrDigit(c);
}

boolean isSpecialChar(char c) {
  return !Character.isLetterOrDigit(c) && c != ' ';
}

interface StringLookup {
  String get(String code);
}

void initGraphGlobVariables() {
   util = new Utility();
  
  //loadAirportDictionary();
  
  processData = new ProcessData();
  uniqueAirports = processData.getUniqueAirports();
  processData.filterDate = null;
  
  flighthubLogo = loadImage("Flighthub Logo.png");
  
  StringLookup airportNameLookup = new StringLookup() {
    public String get(String code) {
      if (airportLookup.containsKey(code)) return airportLookup.get(code);
      return code;
    }
  };

  airportSelector = new AirportSelectorMenu(uniqueAirports, airportNameLookup, flighthubLogo);
}

import java.text.Normalizer;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Collections;

import java.util.ArrayList;

class ProcessData {
  Table table;
  int totalFlights, onTimeFlights, delayedFlights, cancelledFlights;
  String filterDate = null;
  
  ProcessData() {
    try {
      table = loadTable(currentDataset, "header,csv");
      println("Loaded " + table.getRowCount() + " rows from " + currentDataset);
    } catch(Exception e) {
      println("Error loading CSV: " + e.getMessage());
    }
  }
  
  void process(String airport) {
    if (table == null) {
      println("No table loaded, cannot process data.");
      return;
    }
    totalFlights = 0;
    onTimeFlights = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    
    for (TableRow row : table.rows()) {
      if (!rowMatchesFilter(row, airport)) continue;
      
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      
      if (cancelledStr.equals("true")) {
        cancelledFlights++;
      } else {
        try {
          int delay = row.getInt("minutes_late");
          if (delay > 0) {
            delayedFlights++;
          } else {
            onTimeFlights++;
          }
        } catch(Exception e) { }
      }
    }
    println("Processed data for airport: " + airport + " on " + (filterDate != null ? filterDate : "all dates"));
    println("  Total Flights: " + totalFlights);
    println("  On Time: " + onTimeFlights);
    println("  Delayed: " + delayedFlights);
    println("  Cancelled: " + cancelledFlights);
    println("---------------------------------------");
  }
  
  boolean rowMatchesFilter(TableRow row, String airport) {
    if (!row.getString("origin").equalsIgnoreCase(airport)) return false;
    if (filterDate != null) {
      String sched = row.getString("scheduled_departure");
      if (sched == null || !sched.substring(0, 10).equals(filterDate)) return false;
    }
    return true;
  }
  
  String[] getUniqueAirports() {
    if (table == null) return new String[0];
    ArrayList<String> unique = new ArrayList<String>();
    for (TableRow row : table.rows()) {
      String orig = row.getString("origin").trim();
      if (!unique.contains(orig)) {
        unique.add(orig);
      }
    }
    Collections.sort(unique);
    return unique.toArray(new String[unique.size()]);
  }
}

// Utility.pde
class Utility {
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
    String[] months = {"January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"};
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
      return fullOrigin.substring(openParen + 1, closeParen).trim();
    }
    return "";
  }
}

// --------------------------------------------------------------------------
// GraphSelectorMenu Class
// --------------------------------------------------------------------------
class GraphSelectorMenu extends Screen {
  String airport;
  ProcessData data;
  CalendarDisplay calendar;
  
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
    calendar = new CalendarDisplay(width - 420, 80, 400, 280);
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
  
  void draw() {
    // Process held-key events (if in SCREEN_SELECTION and searchFocused).
    if (screenMode == SCREEN_SELECTION && airportSelector.searchFocused) {
      int now = millis();
      
      // BACKSPACE custom repeat:
      if (backspaceHeld && now - backspaceHoldStart > initialDelay && now - backspaceLastDelete > repeatRate) {
        handleBackspace();
        backspaceLastDelete = now;
      }
      
      // CTRL-BACKSPACE custom repeat:
      if (ctrlBackspaceHeld && now - ctrlBackspaceHoldStart > ctrlBackspaceInitialDelay &&
           now - ctrlBackspaceLastRepeat > ctrlBackspaceRepeatRate) {
        handleCtrlBackspace();
        ctrlBackspaceLastRepeat = now;
      }
      
      // Arrow key custom repeat:
      if (arrowLeftHeld && now - arrowHoldStart > arrowInitialDelay && now - arrowLastRepeat > arrowRepeatRate) {
        airportSelector.setCaretIndex(airportSelector.caretIndex - 1);
        arrowLastRepeat = now;
      }
      if (arrowRightHeld && now - arrowHoldStart > arrowInitialDelay && now - arrowLastRepeat > arrowRepeatRate) {
        airportSelector.setCaretIndex(airportSelector.caretIndex + 1);
        arrowLastRepeat = now;
      }
      
      // Other letter keys custom repeat:
      if (keyBeingHeld && heldKey != 0 && heldKey != BACKSPACE) {
        if (now - keyHoldStart > initialDelay && now - keyLastRepeat > repeatRate) {
          insertKeyChar(heldKey);
          keyLastRepeat = now;
        }
      }
    }
    
    // --- Rendering code (unchanged from your original draw()) ---
    if (inMenu) {
      background(0);
    } else {
      background(255);
    }
    
    Star[][] starArrays = { stars, moreStars, evenMoreStars };
    for (Star[] starArray : starArrays) {
      for (Star star : starArray) {
        star.update();
        star.display();
      }
    }
    
    drawBackButton();
    
    // Retrieve airport info.
    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin == null) fullOrigin = airport;
    String airportName = util.extractAirportName(fullOrigin);
    String location = util.extractLocation(fullOrigin);
    
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
  
  void mousePressed() {
    if (mouseX >= 10 && mouseX <= 110 && mouseY >= 10 && mouseY <= 50) {
      if (inMenu) {
        screenManager.switchScreen(airportSelector);
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
      if (mouseX >= annualBx && mouseX <= annualBx + annualBw && mouseY >= annualBy && mouseY <= annualBy + annualBh) {
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
      if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
        calendar.toggle();
        return;
      }
    }
    
    if (calendar.visible) {
      if (calendar.mousePressed()) {
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
        
        if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) {
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
    int bx = 10, by = 10, bw = 100, bh = 40;
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
  
  // --------------------------------------------------------------------------
  // Key event handling for searchbar input with key-hold functionality.
  // --------------------------------------------------------------------------
  
  void keyPressed() {
     if (key == BACKSPACE) {
      // If a graph is being displayed, go back to the graph selection menu.
      if (!graphScreen.inMenu) {
        graphScreen.inMenu = true;
        return;
      }
      // If already in graph selection, go back to airport search.
      else {
        screenManager.switchScreen(airportSelector);
        graphScreen = null;
        return;
      }
    }
    
    if (screenMode == SCREEN_SELECTION && airportSelector.searchFocused) {
      // Ignore repeated keyPressed events for the same key.
      if (keyBeingHeld && key == heldKey) return;
      
      int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
      int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
      
      if (key == BACKSPACE) {
        if (keyEvent.isControlDown() || keyEvent.isMetaDown()) {
          ctrlBackspaceHeld = true;
          ctrlBackspaceHoldStart = millis();
          ctrlBackspaceLastRepeat = millis();
          handleCtrlBackspace();
        } else {
          backspaceHeld = true;
          backspaceHoldStart = millis();
          backspaceLastDelete = millis();
          handleBackspace();
        }
      }
      else if (key == DELETE) {
        if (airportSelector.hasSelection()) {
          airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                          airportSelector.searchQuery.substring(selEnd);
          airportSelector.setCaretIndex(selStart);
          airportSelector.clearSelection();
          airportSelector.resetScroll();
        } else if (airportSelector.caretIndex < airportSelector.searchQuery.length()) {
          airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                          airportSelector.searchQuery.substring(airportSelector.caretIndex + 1);
          airportSelector.clearSelection();
          airportSelector.resetScroll();
        }
      }
      else if (key == CODED) {
        if (keyCode == LEFT) {
          arrowLeftHeld = true;
          arrowHoldStart = millis();
          arrowLastRepeat = millis();
          airportSelector.setCaretIndex(airportSelector.caretIndex - 1);
          airportSelector.clearSelection();
        } else if (keyCode == RIGHT) {
          arrowRightHeld = true;
          arrowHoldStart = millis();
          arrowLastRepeat = millis();
          airportSelector.setCaretIndex(airportSelector.caretIndex + 1);
          airportSelector.clearSelection();
        }
      }
      else if (key == ENTER || key == RETURN) {
        String[] filteredAirports = airportSelector.getFilteredAirports();
        if (filteredAirports.length == 1) {
          String selected = filteredAirports[0];
          processData.filterDate = null;
          if (graphScreen != null) graphScreen.lastSelectedDate = null;
          processData.process(selected);
          graphScreen = new GraphSelectorMenu(selected, processData);
          screenMode = SCREEN_OVERVIEW;
        }
      }
      else {
        // Insert the key and set the custom repeat flags.
        char c = key;
        insertKeyChar(c);
        heldKey = key;
        keyBeingHeld = true;
        keyHoldStart = millis();
        keyLastRepeat = millis();
      }
    }
  }
  
  void keyReleased() {
    // Reset all key-hold flags on release.
    backspaceHeld = false;
    ctrlBackspaceHeld = false;
    arrowLeftHeld = false;
    arrowRightHeld = false;
    keyBeingHeld = false;
    heldKey = 0;
  }
}

void loadAirportDictionary(String[] rows) {
  for (int i = 1; i < rows.length; i++) {
    String[] cols = split(rows[i], ',');
    if (cols.length >= 5) {
      String airportName = cols[1].trim();
      String iataCode = cols[2].trim();
      String city = cols[3].trim();
      String country = cols[4].trim();
      String label = airportName + " (" + city + ", " + country + ")";
      airportLookup.put(iataCode, label);
    }
  }
  println("Loaded airport_data.csv. Dictionary size = " + airportLookup.size());
}

enum SortField {
  CODE,
  NAME,
  COUNTRY
}

enum SortOrder {
  ASC,
  DESC
}
