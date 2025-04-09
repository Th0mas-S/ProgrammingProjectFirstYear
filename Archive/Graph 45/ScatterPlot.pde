// ScatterPlotScreen.pde
// A class for drawing the scatter plot (Hour vs. Delay) screen.

class ScatterPlotScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  ScatterPlotScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    ArrayList<Float[]> points = new ArrayList<Float[]>();
    float maxDelay = 0;
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 16) {
          String timePart = sched.substring(11, 16);
          String[] hhmm = split(timePart, ":");
          if (hhmm.length == 2) {
            int hr = parseInt(hhmm[0]);
            int mn = parseInt(hhmm[1]);
            float xVal = hr + mn/60.0;
            int d = row.getInt("minutes_late");
            if (d < 0) d = 0;
            maxDelay = max(maxDelay, d);
            points.add(new Float[]{ xVal, float(d) });
          }
        }
      }
    }
    
    if (points.size() == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(30);
      text("No flight data for scatter plot", x + w/2, y + h/2);
      return;
    }
    
    float marginLeft = 60, marginRight = 30, marginTop = 50, marginBottom = 60;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    // X-axis labels.
    textSize(16);
    textAlign(CENTER, TOP);
    for (int hr = 0; hr <= 23; hr++) {
      float xx = map(hr, 0, 24, plotX, plotX + plotW);
      line(xx, plotY + plotH, xx, plotY + plotH + 5);
      text(hr, xx, plotY + plotH + 8);
    }
    
    // Y-axis ticks.
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxDelay);
      float yy = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, yy, plotX, yy);
      text(int(val), plotX - 8, yy);
    }
    
    // Titles.
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
    
    // Draw data points.
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
}
