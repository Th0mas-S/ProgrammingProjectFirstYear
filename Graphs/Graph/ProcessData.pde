//-------------------------------------------------
// ProcessData class
//-------------------------------------------------
class ProcessData {
  Table table;
  int totalFlights, departedOnTime, delayedFlights, cancelledFlights, divertedFlights;

  ProcessData(String csvFile) {
    try {
      table = loadTable(csvFile, "header,csv");
      if (table == null) {
        println("Error: loadTable returned null for " + csvFile + ". Check file path and format.");
        exit();
      } else if (table.getRowCount() == 0) {
         println("Warning: " + csvFile + " loaded but contains 0 rows.");
      }
      else {
        println("Loaded " + table.getRowCount() + " rows from " + csvFile);
      }
    } catch (Exception e) {
      println("Fatal Error loading CSV '" + csvFile + "': " + e.getMessage());
      e.printStackTrace();
      exit();
    }
  }

  void process(String airport) {
    if (table == null) {
      println("Cannot process data, flight table not loaded.");
      return;
    }
    totalFlights = 0;
    departedOnTime = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    divertedFlights = 0;

    println("Processing overall data for airport: " + airport + "...");
    for (TableRow row : table.rows()) {
      String origin = row.getString("origin");
      if (origin == null || !origin.equalsIgnoreCase(airport)) continue;

      totalFlights++;

      String cancelledStr = row.getString("cancelled");
      String divertedStr = row.getString("diverted");
      boolean isCancelled = (cancelledStr != null && (cancelledStr.trim().equalsIgnoreCase("true") || cancelledStr.trim().equals("1")));
      boolean isDiverted = (divertedStr != null && (divertedStr.trim().equalsIgnoreCase("true") || divertedStr.trim().equals("1")));

      if (isCancelled) {
        cancelledFlights++;
      } else if (isDiverted) {
        divertedFlights++;
      } else {
        int minutesLate = 0;
        try {
           minutesLate = row.getInt("minutes_late");
        } catch(Exception e) { minutesLate = 0; }

        if (minutesLate > 5) { // Define delay threshold
          delayedFlights++;
        } else {
          departedOnTime++;
        }
      }
    }
    println("--- Overall Stats for " + airport + " ---");
    println("Total Flights: " + totalFlights);
    println("Completed (<=5 min late): " + departedOnTime);
    println("Delayed (>5 min late): " + delayedFlights);
    println("Cancelled: " + cancelledFlights);
    println("Diverted: " + divertedFlights);
    println("---------------------------------");
  }


  String[] getUniqueAirports() {
    if (table == null) {
        println("Error: Cannot get unique airports, flight table not loaded.");
        return new String[0];
    }
    ArrayList<String> airportList = new ArrayList<String>();
    println("Extracting unique origin airports...");
    for (TableRow row : table.rows()) {
      String origin = row.getString("origin");
      if (origin != null) {
          origin = origin.trim();
          if (!origin.isEmpty() && !airportList.contains(origin)) {
             airportList.add(origin);
          }
       }
    }

    if (airportList.isEmpty()) {
        println("Warning: No unique origin airports found in the data.");
        return new String[0];
    }

    Collections.sort(airportList);
    println("Found " + airportList.size() + " unique origin airports.");
    return airportList.toArray(new String[0]);
  }
} // End of ProcessData class
