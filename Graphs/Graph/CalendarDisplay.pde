//-------------------------------------------------
// CalendarDisplay class
//-------------------------------------------------
class CalendarDisplay {
  int month; // 0-11
  int year;
  int selectedDay = 1;
  float x, y, w, h, arrowSize;
  float cellW, cellH, gridStartX, gridStartY; // Cell dimensions
  float headerY, headerHeight, dayNamesY; // Layout positions

  CalendarDisplay() {
    java.util.Calendar cal = java.util.Calendar.getInstance();
    month = 0; // January
    year = 2017;
    selectedDay = 1;
    w = 260;
    h = 230;
    x = width - w - 20; // Position top-right (will be drawn based on screen mode)
    y = 20;
    arrowSize = w * 0.08;
    headerY = y + h * 0.05;
    headerHeight = h * 0.15;
    dayNamesY = headerY + headerHeight + 5;
    cellW = (w - 20) / 7.0;
    gridStartX = x + 10;
    gridStartY = dayNamesY + 15;
    cellH = (y + h - gridStartY - 10) / 6.0;
  }

  // Update position - call this before display if needed
  void setPosition(float newX, float newY) {
     x = newX;
     y = newY;
     // Recalculate positions based on new x, y
     headerY = y + h * 0.05;
     dayNamesY = headerY + headerHeight + 5;
     gridStartX = x + 10;
     gridStartY = dayNamesY + 15;
     // cellW and cellH depend only on w, h which are fixed
  }

  void display() {
    // Reposition dynamically just before drawing (in case width/height change, though fixed here)
    // setPosition(width - w - 20, 20); // Ensure top-right positioning

    pushStyle();

    fill(235, 235, 240, 230);
    stroke(180);
    strokeWeight(1);
    rect(x, y, w, h, 8);
    noStroke();

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(w * 0.08);
    String mName = getMonthName(month);
    float headerCenterY = headerY + headerHeight / 2;
    text(mName + " " + year, x + w/2, headerCenterY);

    // Navigation Arrows
    if (year == 2017 && month > 0) {
      float arrowX = x + w * 0.08;
      boolean leftHover = isMouseOverArrow(arrowX, headerCenterY, true);
       drawArrow(arrowX, headerCenterY, arrowSize, true, leftHover);
    }
    if (year == 2017 && month < 11) {
      float arrowX = x + w - w * 0.08 - arrowSize;
      boolean rightHover = isMouseOverArrow(arrowX, headerCenterY, false);
       drawArrow(arrowX, headerCenterY, arrowSize, false, rightHover);
    }

    // Day Names
    fill(80);
    textSize(w * 0.06);
    String[] dayNames = {"S","M","T","W","T","F","S"};
    for (int i = 0; i < 7; i++) {
      text(dayNames[i], gridStartX + cellW * i + cellW/2, dayNamesY);
    }

    // Day Numbers Grid
    int daysInMonth = getDaysInMonth(month, year);
    int startDay = getStartDay(month, year);
    textSize(w * 0.07);

    for (int i = 1; i <= daysInMonth; i++) {
      int cellIndex = startDay + (i-1);
      int row = cellIndex / 7;
      int col = cellIndex % 7;
      float cellX = gridStartX + col*cellW;
      float cellY = gridStartY + row*cellH;

      boolean isHovered = isMouseOverDay(cellX, cellY);
      boolean isSelected = (i == selectedDay);

      // Cell Background Styling
      if (isSelected) {
        fill(100,150,255);
        noStroke();
        rect(cellX + 1, cellY + 1, cellW - 2, cellH - 2, 3);
        fill(255);
      } else if (isHovered) {
        fill(200, 210, 220);
        noStroke();
        rect(cellX + 1, cellY + 1, cellW - 2, cellH - 2, 3);
        fill(0);
      } else {
        fill(0);
        noStroke();
      }
      textAlign(CENTER, CENTER);
      text(i, cellX+cellW/2, cellY+cellH/2);
    }

    popStyle();
  }

  void drawArrow(float ax, float ay, float aSize, boolean isLeft, boolean isHover) {
     pushStyle();
     if (isHover) {
        fill(100,150,255);
        stroke(255);
        strokeWeight(1);
     } else {
        fill(150);
        noStroke();
     }
     if (isLeft) {
        triangle(ax, ay, ax+aSize, ay-aSize/1.5, ax+aSize, ay+aSize/1.5);
     } else {
        triangle(ax+aSize, ay, ax, ay-aSize/1.5, ax, ay+aSize/1.5);
     }
     popStyle();
  }

 boolean mousePressed() {
    if (!isMouseOver(mouseX, mouseY)) return false;

    float headerCenterY = headerY + headerHeight/2;
    // Prev Arrow Click
     if (year == 2017 && month > 0) {
        float prevArrowX = x + w*0.08;
         if (isMouseOverArrow(prevArrowX, headerCenterY, true)) {
           previousMonth();
           return true;
        }
     }
    // Next Arrow Click
     if (year == 2017 && month < 11) {
        float nextArrowX = x + w - w*0.08 - arrowSize;
         if (isMouseOverArrow(nextArrowX, headerCenterY, false)) {
           nextMonth();
           return true;
        }
     }

    // Day Click
    int startDay = getStartDay(month, year);
    int daysInMonth = getDaysInMonth(month, year);
    for (int i = 1; i <= daysInMonth; i++) {
      int cellIndex = startDay + (i-1);
      int row = cellIndex/7;
      int col = cellIndex%7;
      float cellX = gridStartX + col*cellW;
      float cellY = gridStartY + row*cellH;
      if (isMouseOverDay(cellX, cellY)) {
          selectedDay = i;
          println("Calendar Day Clicked: " + getSelectedDate());
          return true;
      }
    }
    return false;
  }

  boolean isMouseOver(float mx, float my) {
     return (mx >= x && mx <= x+w && my >= y && my <= y+h);
  }

  boolean isMouseOverDay(float cX, float cY) {
     return (mouseX >= cX && mouseX < cX+cellW && mouseY >= cY && mouseY < cY+cellH);
  }

  boolean isMouseOverArrow(float aX, float aY, boolean isLeft) {
      float boundSize = arrowSize * 1.2; // Slightly larger bounding box for easier clicking
      float halfHeight = boundSize / 1.5 / 2;
      if (isLeft) {
         return (mouseX >= aX - boundSize*0.1 && mouseX <= aX + boundSize*0.9 && // Shift box slightly left too
                 mouseY >= aY - halfHeight && mouseY <= aY + halfHeight);
      } else {
         return (mouseX >= aX + boundSize*0.1 && mouseX <= aX + boundSize*1.1 && // Shift box slightly right
                 mouseY >= aY - halfHeight && mouseY <= aY + halfHeight);
      }
   }


  void previousMonth() {
    if (year == 2017 && month > 0) {
      month--;
      selectedDay = min(selectedDay, getDaysInMonth(month, year));
    }
  }

  void nextMonth() {
    if (year == 2017 && month < 11) {
      month++;
      selectedDay = min(selectedDay, getDaysInMonth(month, year));
    }
  }

  String getSelectedDate() {
    return nf(year,4) + "-" + nf(month+1,2) + "-" + nf(selectedDay,2);
  }

  String getMonthName(int m) {
    String[] months = {"January","February","March","April","May","June",
                       "July","August","September","October","November","December"};
    return months[m % 12];
  }

  int getStartDay(int m, int y) {
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.set(y, m, 1);
    return cal.get(java.util.Calendar.DAY_OF_WEEK) - 1; // Adjust to 0-6
  }

  int getDaysInMonth(int m, int y) {
     java.util.Calendar cal = java.util.Calendar.getInstance();
     cal.set(y, m, 1);
     return cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH);
  }
}
