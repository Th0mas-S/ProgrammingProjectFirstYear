//==================================================
// ProccessData class: handles CSV loading and basic processing.
// (Consider adding methods here to pre-calculate graph data)
class ProccessData {
  Table table;
  // Overall stats (optional use)
  int totalFlights, departedOnTime, delayedFlights, cancelledFlights, divertedFlights;

  ProccessData(String csvFile) {
    try {
      // Ensure your CSV file is in the sketch's "data" folder.
      table = loadTable(csvFile, "header,csv");
      println("Loaded " + table.getRowCount() + " rows from " + csvFile);
    } catch (Exception e) {
        println("Error loading CSV: " + e.getMessage());
        // Optionally: create an empty table to prevent null pointer errors later
        // table = new Table();
        // table.addColumn("origin"); // Add expected columns if needed
        // ...
    }
  }

  // Process the overall data for the given airport (currently just prints)
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
      // Use equalsIgnoreCase for robust comparison
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;

      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      String divertedStr = row.getString("diverted").trim().toLowerCase();

      if (cancelledStr.equals("true") || cancelledStr.equals("1")) {
        cancelledFlights++;
      } else if (divertedStr.equals("true") || divertedStr.equals("1")) {
        divertedFlights++; // Count diversions separately
      } else {
          // Only check delay if not cancelled or diverted
          int minutesLate = 0;
          try {
              minutesLate = row.getInt("minutes_late");
              if (minutesLate > 0) {
                 delayedFlights++;
              } else {
                 departedOnTime++;
              }
          } catch (NumberFormatException e) {
              // Handle cases where minutes_late might be missing or non-numeric for completed flights
              // Maybe count as 'unknown' or default to on-time? For now, we skip counting delay status.
              println("Warning: Non-numeric minutes_late for non-cancelled/diverted flight");
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

  // --- Potential Future Methods for Pre-calculation ---
  // void calculateHourlyTraffic(String airport) { /* ... store results ... */ }
  // void calculateDestinations(String airport) { /* ... store results ... */ }
  // void calculateAirlineDelays(String airport) { /* ... store results ... */ }
  // void calculateStatusCounts(String airport) { /* ... store results ... */ }

}
