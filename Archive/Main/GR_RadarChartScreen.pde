
class RadarChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  boolean showMonthly;
  String selectedDate; // NEW: selected date in "YYYY-MM-DD" format

  RadarChartScreen(String airport, ProcessData data, float animationProgress, boolean showMonthly) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
    this.showMonthly = showMonthly;
    this.selectedDate = null;
  }

  // Call this when a date is selected on the calendar
  void setSelectedDate(String date) {
    this.selectedDate = date;
    this.showMonthly = false;
  }

  // Optional: Call this to reset to monthly view
  void clearSelectedDate() {
    this.selectedDate = null;
    this.showMonthly = true;
  }

  void display(float x, float y, float w, float h) {
    float cx = x + w / 2;
    float cy = y + h / 2;
    float radius = min(w, h) * 0.35;

    int spokes = showMonthly ? 12 : 24;
    int[] counts = new int[spokes];
    int maxCount = 1;

    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String sched = row.getString("scheduled_departure");
        if (sched == null || sched.length() < 13) continue;

        if (selectedDate != null && sched.startsWith(selectedDate)) {
          int hr = parseInt(sched.substring(11, 13));
          if (hr >= 0 && hr < 24) {
            counts[hr]++;
            maxCount = max(maxCount, counts[hr]);
          }
        } else if (selectedDate == null) {
          if (showMonthly && sched.length() >= 7) {
            int m = parseInt(sched.substring(5, 7)) - 1;
            if (m >= 0 && m < 12) {
              counts[m]++;
              maxCount = max(maxCount, counts[m]);
            }
          } else if (!showMonthly && sched.length() >= 13) {
            int hr = parseInt(sched.substring(11, 13));
            if (hr >= 0 && hr < 24) {
              counts[hr]++;
              maxCount = max(maxCount, counts[hr]);
            }
          }
        }
      }
    }

    int rings = 5;
    int displayMax = max(1, ceil(maxCount / 5.0) * 5);
    int[] ringVals = new int[rings];
    for (int i = 0; i < rings; i++) {
      ringVals[i] = round((i + 1) * (displayMax / (float) rings));
    }

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

    // Draw spokes
    for (int i = 0; i < spokes; i++) {
      float angle = -HALF_PI + i * (TWO_PI / spokes);
      float x2 = cx + radius * cos(angle);
      float y2 = cy + radius * sin(angle);
      stroke(0);
      line(cx, cy, x2, y2);
    }

    // Draw radar shape
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

    // Draw data points
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

    // Draw labels
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
}
