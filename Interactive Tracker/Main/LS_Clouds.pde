class Cloud {
  float x, y, size;
  color cloudColor;
  color shadowColor;

  Cloud(float x, float y, float size, color c) {
    this.x = x;
    this.y = y;
    this.size = size;
    setColor(c);
  }

  void update() {
    x += 0.5;
    if (x - size > width) {
      x = -size;
    }
  }

  void display() {
    noStroke();
    float shadowOffsetX = size * 0.05;
    float shadowOffsetY = size * 0.05;

    // Shadow
    fill(shadowColor);
    ellipse(x + shadowOffsetX, y + shadowOffsetY, size * 0.9, size * 0.55);
    ellipse(x - size * 0.25 + shadowOffsetX, y + size * 0.1 + shadowOffsetY, size * 0.7, size * 0.45);
    ellipse(x + size * 0.25 + shadowOffsetX, y + size * 0.1 + shadowOffsetY, size * 0.7, size * 0.45);
    ellipse(x - size * 0.15 + shadowOffsetX, y - size * 0.15 + shadowOffsetY, size * 0.8, size * 0.55);
    ellipse(x + size * 0.15 + shadowOffsetX, y - size * 0.15 + shadowOffsetY, size * 0.8, size * 0.55);
    ellipse(x + shadowOffsetX, y - size * 0.1 + shadowOffsetY, size * 0.85, size * 0.5);

    // Cloud body
    fill(cloudColor);
    ellipse(x, y, size * 0.9, size * 0.55);
    ellipse(x - size * 0.25, y + size * 0.1, size * 0.7, size * 0.45);
    ellipse(x + size * 0.25, y + size * 0.1, size * 0.7, size * 0.45);
    ellipse(x - size * 0.15, y - size * 0.15, size * 0.8, size * 0.55);
    ellipse(x + size * 0.15, y - size * 0.15, size * 0.8, size * 0.55);
    ellipse(x, y - size * 0.1, size * 0.85, size * 0.5);
  }

  void setColor(color c) {
    cloudColor = c;
    shadowColor = color(red(c) * 0.5, green(c) * 0.5, blue(c) * 0.5); // Opaque shadows
  }
}
