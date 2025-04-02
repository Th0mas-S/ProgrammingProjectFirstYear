// Global settings for terrain and clouds
float[][] terrain;
int cols, rows;
int scl = 20;
int w, h;

float flying = 0;
PImage cockpit;

Cloud[] clouds;
int numClouds = 10;

// Global cloud color (light pink)
color globalCloudColor = color(255, 182, 193);

void setup() {
  fullScreen(P3D);
  w = width;
  h = height;
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];

  cockpit = loadImage("cockpit.png");

  clouds = new Cloud[numClouds];
  for (int i = 0; i < numClouds; i++) {
    float x = random(width);
    float y = random(height / 4);
    float size = random(80, 150);
    clouds[i] = new Cloud(x, y, size, globalCloudColor);
  }
}

void draw() {
  background(135, 206, 235);  // Sky blue

  // Gradient sky
  pushMatrix();
  resetMatrix();
  hint(DISABLE_DEPTH_TEST);
  color topColor = color(135, 206, 235);    // SkyBlue
  color bottomColor = color(70, 130, 180);  // SteelBlue
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    stroke(lerpColor(topColor, bottomColor, inter));
    line(0, y, width, y);
  }
  hint(ENABLE_DEPTH_TEST);
  popMatrix();

  // Draw clouds
  pushMatrix();
  resetMatrix();
  for (int i = 0; i < clouds.length; i++) {
    clouds[i].update();
    clouds[i].display();
  }
  popMatrix();

  // Update terrain
  flying -= 0.1;
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -100, 100);
      xoff += 0.2;
    }
    yoff += 0.2;
  }

  // Loading text
  textSize(50);
  fill(255);
  text("Loading...", 850, 300);
  
  // Draw 3D terrain
  pushMatrix();
  translate(width/2, height/2 );
  rotateX(PI/2.3);
  scale(2, 1, 2);
  translate(-width/2, -height/2);
  fill(200, 200, 200, 150);
  for (int y = 0; y < rows - 1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x * scl, y * scl * 1.5, terrain[x][y]);
      vertex(x * scl, (y + 1) * scl * 1.5, terrain[x][y + 1]);
    }
    endShape();
  }
  popMatrix();

  // Draw cockpit (full brightness)
  hint(DISABLE_DEPTH_TEST);
  imageMode(CORNER);
  image(cockpit, 0, 0, width, height+300);
  hint(ENABLE_DEPTH_TEST);
}

// Change cloud color with 'c' key
void keyPressed() {
  if (key == 'c' || key == 'C') {
    globalCloudColor = color(random(255), random(255), random(255));
    for (int i = 0; i < numClouds; i++) {
      clouds[i].setColor(globalCloudColor);
    }
  }
}

// Cloud class with smoother shape and fully opaque shadows
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
