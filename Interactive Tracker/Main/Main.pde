import java.util.HashSet;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

CalendarDisplay calendar;
TimeSlider timeSlider;

ScreenManager  screenManager;
//EarthScreenDirectory  earthScreenDirectory;
EarthScreenTracker  earthScreenTracker;
MainMenuScreen mainMenuScreen;

HeatMapScreen heatMapScreen;
DirectoryScreen directoryScreen;

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
HashMap<String, String> airportLocations = new HashMap<String, String>();


String lastCheckedDate = "";
Airplane selectedPlane = null;

SoundFile audio; 

                                                                                                                                                                      
void setup() {
  size(1920, 1061, P3D); // ben added this >:( (i know you can't hide from me);
  
  //fullScreen(P3D);
  
  flightHubLogo = loadImage("Flighthub Logo.png");

  
  audio = new SoundFile(this, "audio3.mp3");

  
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
    loadAirportMetadata();
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
  
  initGlobalVariables();
          clearIndex();
  
  mainMenuScreen = new MainMenuScreen();
  directoryScreen = new DirectoryScreen();
  //heatMapScreen = new HeatMapScreen();
  
  screenManager.switchScreen(mainMenuScreen);
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

void mouseMoved() {
  screenManager.handleMouseMoved();
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

PVector slerp(float t, PVector v0, PVector v1) {
  float dot = constrain(v0.dot(v1), -1, 1);
  float theta = acos(dot);
  if (theta < 0.001) return v0.copy();
  float sinTheta = sin(theta);
  float w1 = sin((1 - t) * theta) / sinTheta;
  float w2 = sin(t * theta) / sinTheta;
  return PVector.add(v0.copy().mult(w1), v1.copy().mult(w2));
}

void loadAirportsFromCSV() {
  // Step 1: Collect all relevant IATA codes from flights
  HashSet<String> usedCodes = new HashSet<String>();
  Table flightTable = loadTable("flight_data_2017.csv", "header");

  for (TableRow row : flightTable.rows()) {
    String origin = row.getString("origin");
    String dest = row.getString("destination");
    if (origin != null) usedCodes.add(origin.trim());
    if (dest != null) usedCodes.add(dest.trim());
  }

  // Step 2: Load only matching airports from coordinate.csv
  Table coordTable = loadTable("airport_data.csv", "header");

  for (TableRow row : coordTable.rows()) {
    String code = row.getString("IATA Code").trim();
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
  Table table = loadTable("flight_data_2017.csv", "header");

  if (table == null) {
    println("⚠️ Could not load flight_data_2017.csv");
    return;
  }

  int skippedMalformedTime = 0;
  int skippedBadDuration = 0;
  int loaded = 0;

  for (TableRow row : table.rows()) {
    String origin = row.getString("origin");
    String destination = row.getString("destination");
    String actualDeparture = row.getString("actual_departure");
    String actualArrival = row.getString("actual_arrival");

    if (origin == null || destination == null || actualDeparture == null || actualArrival == null) {
      continue; // Required fields missing
    }

    String[] depParts = split(actualDeparture, " ");
    String[] arrParts = split(actualArrival, " ");

    if (depParts.length != 2 || arrParts.length != 2) {
      skippedMalformedTime++;
      continue;
    }

    String dateStr = depParts[0];
    String depTimeStr = depParts[1];
    String arrTimeStr = arrParts[1];

    String[] depHM = split(depTimeStr, ":");
    String[] arrHM = split(arrTimeStr, ":");

    if (depHM.length < 2 || arrHM.length < 2) {
      skippedMalformedTime++;
      continue;
    }

    int depMin = int(depHM[0]) * 60 + int(depHM[1]);
    int arrMin = int(arrHM[0]) * 60 + int(arrHM[1]);

    // Handle flights that arrive after midnight
    if (arrMin < depMin) {
      arrMin += 1440; // Add 24h in minutes
    }

    int duration = arrMin - depMin;
    if (duration <= 0) {
      skippedBadDuration++;
      continue;
    }

    // City + Country from airport metadata
    String originCityCountry = airportLocations.get(origin);
    String destCityCountry = airportLocations.get(destination);

    if (originCityCountry == null) originCityCountry = origin;
    if (destCityCountry == null) destCityCountry = destination;

    String airlineName = row.getString("airline_name");
    String airlineCode = row.getString("airline_code");
    String flightNumber = row.getString("flight_number");

    FlightData flight = new FlightData(
      origin, destination, dateStr, depMin, duration,
      originCityCountry, destCityCountry,
      depTimeStr, arrTimeStr,
      airlineName, airlineCode, flightNumber
    );

    allFlights.add(flight);
    loaded++;
  }

  println("✅ Loaded flights: " + loaded);
  println("❌ Skipped (malformed time): " + skippedMalformedTime);
  println("❌ Skipped (zero/negative duration): " + skippedBadDuration);
}

void loadAirportMetadata() {
  
  Table table = loadTable("airport_data.csv", "header");
  for (TableRow row : table.rows()) {
    String iata = row.getString("IATA Code");
    String city = row.getString("City");
    String country = row.getString("Country");

    if (iata != null && city != null && country != null) {
      String location = city + ", " + country;
      airportLocations.put(iata.trim(), location);
    }
  }
}
