
class Calendar
{
  boolean visible = false;
  
  int month;
  int year;
  int selectedDay = 1;
  float x, y;
  float w, h;
  float arrowSize = 30;

  Calendar(float x, float y, float w, float h) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    month = 0; 
    year = 2017;
  }
  
  void toggle()
  {
    visible = !visible;
  }
  
  void display()
  {
    if (!visible) return;
    
    pushStyle();
    fill(50,50,50,200);
    noStroke();
    rect(x, y, w, h, 5);
    popStyle();
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    
    String mName = getMonthName(month);
    float headerY = y + 20;
    float headerHeight = 40;
    float headerCenterY = headerY + headerHeight / 2;
    text(mName + " " + year, x + w / 2, headerCenterY);
    
    if (month > 0) 
    {
      float arrowY = headerCenterY;
      boolean leftHover = (mouseX >= x+10 && mouseX <= x+10+arrowSize &&
                           mouseY >= arrowY - arrowSize/2 && mouseY <= arrowY + arrowSize/2);
      if (leftHover)
      {
        fill(100,150,255);
        stroke(255);
        strokeWeight(2);
      }
      else 
      {
        fill(200);
        noStroke();
      }
      triangle(x+10, arrowY, x+10+arrowSize, arrowY-arrowSize/2, x+10+arrowSize, arrowY+arrowSize/2);
      noStroke();
      fill(255);
    }
    
    if (month < 11)
    {
      float arrowY = headerCenterY;
      boolean rightHover = (mouseX >= x+w-10-arrowSize && mouseX <= x+w-10 &&
                            mouseY >= arrowY - arrowSize/2 && mouseY <= arrowY + arrowSize/2);
      if (rightHover)
      {
        fill(100,150,255);
        stroke(255);
        strokeWeight(2);
      }
      else 
      {
        fill(200);
        noStroke();
      }
      triangle(x+w-10, arrowY, x+w-10-arrowSize, arrowY-arrowSize/2, x+w-10-arrowSize, arrowY+arrowSize/2);
      noStroke();
      fill(255);
    }
    
    textSize(16);
    String[] dayNames = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
    float cellW = (w - 20) / 7.0;
    float dayNamesY = headerY + headerHeight + 20;
    
    for (int i = 0; i < 7; i++)
    {
      text(dayNames[i], x+10 + cellW*i + cellW/2, dayNamesY);
    }
    
    int daysInMonth = getDaysInMonth(month, year);
    int startDay = getStartDay(month, year);
    float cellH = 25;
    float gridStartY = dayNamesY + 20;
    
    for (int i = 1; i <= daysInMonth; i++) 
    {
      int cellIndex = startDay + (i - 1);
      int row = cellIndex / 7;
      int col = cellIndex % 7;
      float cellX = x + 10 + col * cellW;
      float cellY = gridStartY + row * cellH;
      
      boolean isHovered = (mouseX >= cellX && mouseX < cellX + cellW &&
                           mouseY >= cellY && mouseY < cellY + cellH);
      boolean isSelected = (i == selectedDay);
      
      if (isHovered || isSelected) 
      {
        fill(isHovered ? color(100,150,255) : color(150));
        stroke(255);
        strokeWeight(2);
        rect(cellX, cellY, cellW, cellH);
        noStroke();
        fill(255);
      }
      else 
      {
        fill(255);
        noStroke();
      }
      text(i, cellX + cellW/2, cellY + cellH/2);
    }
  }
  
  String getMonthName(int m) 
  {
    String[] months = {"January","February","March","April","May","June",
                       "July","August","September","October","November","December"};
    return months[m % 12];
  }
  
  int getStartDay(int m, int y)
  {
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.set(y, m, 1);
    return cal.get(java.util.Calendar.DAY_OF_WEEK) - 1;
  }
  
  int getDaysInMonth(int m, int y) 
  {
    if (m == 1) 
    {
      if ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0))
        return 29;
      return 28;
    }
    int[] days = {31,28,31,30,31,30,31,31,30,31,30,31};
    return days[m];
  }
  
  boolean handleMousePressed(int mx, int my)
  {
    if (mx >= x && mx <= x+w && my >= y && my <= y+h)
    {
      float headerY = y + 20;
      float headerHeight = 40;
      float headerCenterY = headerY + headerHeight / 2;
      
      if (month > 0 &&
          mx >= x+10 && mx <= x+10+arrowSize &&
          my >= headerCenterY-arrowSize/2 && my <= headerCenterY+arrowSize/2) 
          {
            previousMonth();
            return false;
          }
      if (month < 11 &&
          mx >= x+w-10-arrowSize && mx <= x+w-10 &&
          my >= headerCenterY-arrowSize/2 && my <= headerCenterY+arrowSize/2)
          {
            nextMonth();
            return false;
          }
      
      int daysInMonth = getDaysInMonth(month, year);
      int startDay = getStartDay(month, year);
      float cellW = (w - 20) / 7.0;
      float cellH = 25;
      float dayNamesY = headerY + headerHeight + 20;
      float gridStartY = dayNamesY + 20;
      
      for (int i = 1; i <= daysInMonth; i++) 
      {
        int cellIndex = startDay + (i - 1);
        int row = cellIndex / 7;
        int col = cellIndex % 7;
        float cellX = x + 10 + col * cellW;
        float cellY = gridStartY + row * cellH;
        
        if (mx >= cellX && mx < cellX + cellW &&
            my >= cellY && my < cellY + cellH) 
            {
              selectedDay = i;
              println("Selected day: " + getSelectedDate());
              return true;
            }
      }
    }
    return false;
  }
  
  void previousMonth()
  {
    if (month > 0)
    {
      month--;
      selectedDay = 1;
    }
  }
  
  void nextMonth() 
  {
    if (month < 11)
    {
      month++;
      selectedDay = 1;
    }
  }
  
  String getSelectedDate()
  {
    return nf(year, 4) + "-" + nf(month+1, 2) + "-" + nf(selectedDay, 2);
  }
}
