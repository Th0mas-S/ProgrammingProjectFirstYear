//==================================================
// ProcessData class: handles CSV loading and processing.
class ProcessData {
  Table table;
  int totalFlights, departedOnTime, delayedFlights, cancelledFlights, divertedFlights;

  ProcessData(String csvFile) {
    try {
      table = loadTable(csvFile, "header,csv");
      println("Loaded " + table.getRowCount() + " rows from " + csvFile);
    } catch (Exception e) {
      println("Error loading CSV: " + e.getMessage());
    }
  }

  void process(String airport) {
    if (table == null) {
        println("Cannot process data, table not loaded.");
        return;
    }
    totalFlights = 0;
    departedOnTime = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    divertedFlights = 0;

    for (TableRow row : table.rows()) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      String divertedStr = row.getString("diverted").trim().toLowerCase();
      if (cancelledStr.equals("true") || cancelledStr.equals("1")) {
        cancelledFlights++;
      } else if (divertedStr.equals("true") || divertedStr.equals("1")) {
        divertedFlights++;
      } else {
          int minutesLate = 0;
          try {
              minutesLate = row.getInt("minutes_late");
              if (minutesLate > 0) {
                 delayedFlights++;
              } else {
                 departedOnTime++;
              }
          } catch (NumberFormatException e) {
              println("Warning: Non-numeric minutes_late encountered");
          }
      }
    }
    println("--- Processed overall data for " + airport + " ---");
    println("Total Flights: " + totalFlights);
    println("Completed On Time: " + departedOnTime);
    println("Completed Delayed: " + delayedFlights);
    println("Cancelled: " + cancelledFlights);
    println("Diverted: " + divertedFlights);
    println("-------------------------------------");
  }
  
  // This method extracts a unique, sorted list of airports from the CSV file.
  String[] getUniqueAirports() {
    ArrayList<String> airportList = new ArrayList<String>();
    if (table != null) {
      for (TableRow row : table.rows()) {
        String origin = row.getString("origin").trim();
        if (!airportList.contains(origin)) {
          airportList.add(origin);
        }
      }
    }
    Collections.sort(airportList);
    return airportList.toArray(new String[airportList.size()]);
  }
}
