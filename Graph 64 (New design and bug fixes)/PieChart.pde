// PieChartScreen.pde
// A class for drawing the Pie Chart graph screen.

class PieChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  PieChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float cx = x + w/2;
    float cy = y + h/2;
    float dia = min(w, h) * 0.7;
    
    int onTime    = data.onTimeFlights;
    int delayed   = data.delayedFlights;
    int cancelled = data.cancelledFlights;
    int total     = max(1, onTime + delayed + cancelled);
    
    float angleOnTime    = TWO_PI * onTime / total;
    float angleDelayed   = TWO_PI * delayed / total;
    // Calculate angle for cancelled flights.
    float angleCancelled = TWO_PI - angleOnTime - angleDelayed;
    
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
    
    // Draw legend.
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
}
