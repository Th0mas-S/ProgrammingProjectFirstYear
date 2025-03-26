import java.util.HashSet;

CalendarDisplay calendar;
TimeSlider timeSlider;

ScreenManager  screenManager;
//EarthScreenDirectory  earthScreenDirectory;
EarthScreenTracker  earthScreenTracker; 

Earth earth;
Airport airportOrigin;
Airport airportDest;
Airplane airplane;
FlightInfo flightInfo;


Location origin = new Location(-25.5, 9.6); // departure latitude and longitude (loaded from file)        Relative Latitude = -(Actual Latitude) + 0.2617
Location destination = new Location(-51.2, 90.2); // arrival latitude and longitude (loaded from file)    Relative Longitude = 1.0071(Actual Longitude) + 90.35

boolean showFlightInfo = false;

float sphereRadius = 650;

ArrayList<Airport> airports = new ArrayList<Airport>();
HashMap<String, Airport> airportMap = new HashMap<String, Airport>();
ArrayList<FlightData> allFlights = new ArrayList<FlightData>();
ArrayList<FlightData> todaysFlights = new ArrayList<FlightData>();
ArrayList<Airplane> activePlanes = new ArrayList<Airplane>();
PImage airplaneImg;
PShape airplaneModel;
HashSet<String> spawnedFlights = new HashSet<String>();

String lastCheckedDate = "";

                                                                                                                                                                      
void setup() {
  size(1920, 1080, P3D);
  
  // Initialize near stars (300 - 500 units away)
    // Initialize stars (300 - 500 units away)
  for (int i = 0; i < numStars; i++) {
    stars[i] = new Star(1000, 2500);
  }
  
  //// Initialize moreStars (500 - 800 units away)
  for (int i = 0; i < numMoreStars; i++) {
    moreStars[i] = new Star(1500, 3000);
  }
  
  // Initialize evenMoreStars (800 - 1200 units away)
  for (int i = 0; i < numEvenMoreStars; i++) {
    evenMoreStars[i] = new Star(2000, 3500);
  }

   
  earth = new Earth("Earth.obj", "Surface2k.png"); //Change to "Surface16k.png" or "Surface2k.png" Download "Surface16k.png" from https://drive.google.com/drive/folders/1csCDLNxFFXlvlKpspokz1EXBzWIePThU?usp=sharing
  airportOrigin = new Airport(origin, sphereRadius, 5);
  airportDest = new Airport(destination, sphereRadius, 5);
  //airplane = new Airplane(airportOrigin, airportDest, sphereRadius, "Airplane.obj", "AirplaneTexture.png");
  //airplane = new Airplane(airportOrigin, airportDest, sphereRadius, "Airplane.png");
  loadAirportsFromCSV();
  loadFlightsFromCSV(); 
  
  calendar = new CalendarDisplay();
  airplaneImg = loadImage("Airplane.png");
  airplaneModel = loadShape("Airplane.obj");
  timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
  timeSlider.value = 0;
  
  screenManager = new ScreenManager();
  //earthScreenDirectory = new EarthScreenDirectory(earth, airportOrigin, airportDest, airplane);
  earthScreenTracker = new EarthScreenTracker(earth);
  //screenManager.switchScreen(earthScreenDirectory);
  screenManager.switchScreen(new HeatMapScreen());
  noStroke();
  
   flightInfo = new FlightInfo(
    "Miami",       // departure location (loaded from file)
    "London",      // arrival location (loaded from file)
    "23:05",    // departure time (loaded from file)
    "11:30",    // arrival time (loaded from file)
    "British Airways",  // airline (loaded from file)
    "BA0208"        // flight number (loaded from file)
  );
}

void draw() {
  screenManager.drawScreen();
}
void mousePressed() {
  screenManager.handleMousePressed();
}

void mouseDragged() {
  screenManager.handleMouseDragged();
}

void mouseReleased() {
   screenManager.handleMouseReleased();
}

void mouseWheel(MouseEvent event) {
  screenManager.handleMouseWheel(event);
}

void keyPressed() {
  screenManager.handleKeyPressed();
}

//Helper Functions
PMatrix3D getRotationMatrix(float angle, PVector axis) {
  float c = cos(angle);
  float s = sin(angle);
  float t = 1 - c;
  float x = axis.x, y = axis.y, z = axis.z;
  return new PMatrix3D(
    t * x * x + c,      t * x * y - s * z,  t * x * z + s * y, 0,
    t * x * y + s * z,   t * y * y + c,      t * y * z - s * x, 0,
    t * x * z - s * y,   t * y * z + s * x,  t * z * z + c,     0,
    0,                  0,                  0,                 1
  );
}

PVector getArcballVector(float x, float y) {
  float radius = min(width, height) / 2;
  float dx = (x - width/2) / radius;
  float dy = (y - height/2) / radius;
  PVector v = new PVector(dx, dy, 0);
  float mag = v.mag();
  if (mag > 1.0) {
    v.normalize();
  } else {
    v.z = sqrt(1.0 - mag * mag);
  }
  return v;
}

void multiplyP3DMatrixScalar(PMatrix3D mat, float s) {
  mat.m00 *= s;  mat.m01 *= s;  mat.m02 *= s;  mat.m03 *= s;
  mat.m10 *= s;  mat.m11 *= s;  mat.m12 *= s;  mat.m13 *= s;
  mat.m20 *= s;  mat.m21 *= s;  mat.m22 *= s;  mat.m23 *= s;
  mat.m30 *= s;  mat.m31 *= s;  mat.m32 *= s;  mat.m33 *= s;
  
}

void loadAirportsFromCSV() {
  // Step 1: Collect all relevant IATA codes from flights
  HashSet<String> usedCodes = new HashSet<String>();
  Table flightTable = loadTable("flight_2024.csv", "header");

  for (TableRow row : flightTable.rows()) {
    String origin = row.getString("Origin");
    String dest = row.getString("Destination");
    if (origin != null) usedCodes.add(origin.trim());
    if (dest != null) usedCodes.add(dest.trim());
  }

  // Step 2: Load only matching airports from coordinate.csv
  Table coordTable = loadTable("coordinate.csv", "header");

  for (TableRow row : coordTable.rows()) {
    String code = row.getString("iata").trim();
    if (!usedCodes.contains(code)) continue;

    float lat = row.getFloat("latitude");
    float lon = row.getFloat("longitude");
    float relLat = -lat + 0.2617;
    float relLon = 1.0071 * lon + 90.35;
    Location loc = new Location(relLat, relLon);
    Airport airport = new Airport(loc, sphereRadius, 5);
    airports.add(airport);
    airportMap.put(code, airport);
  }
}

void loadFlightsFromCSV() {
  Table table = loadTable("flight_2024.csv", "header");

  for (TableRow row : table.rows()) {
    String origin = row.getString("Origin");
    String dest = row.getString("Destination");
    String dateStr = row.getString("Date");

    String depStr = row.getString("Actual Departure");
    String arrStr = row.getString("Actual Arrival");

    if (depStr == null || arrStr == null) continue;

    String[] depParts = split(depStr, " ");
    String[] arrParts = split(arrStr, " ");

    if (depParts.length < 2 || arrParts.length < 2) continue;

    String[] depTime = split(depParts[1], ":");
    String[] arrTime = split(arrParts[1], ":");
    if (depTime.length < 2 || arrTime.length < 2) continue;

    int depMin = int(depTime[0]) * 60 + int(depTime[1]);
    int arrMin = int(arrTime[0]) * 60 + int(arrTime[1]);

    allFlights.add(new FlightData(origin, dest, dateStr, depMin, arrMin));
  }
}
