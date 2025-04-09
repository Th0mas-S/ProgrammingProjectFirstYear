// ---------------- ProcessData Class ----------------
class ProcessData {
  Table table;
  // Holds the filtered rows for the current view.
  ArrayList<TableRow> currentRows = new ArrayList<TableRow>();

  int totalFlights, onTimeFlights, delayedFlights, cancelledFlights;

  ProcessData(String csvFile) {
    try {
      table = loadTable(csvFile, "header,csv");
      println("Loaded " + table.getRowCount() + " rows from " + csvFile);
    }
    catch(Exception e) {
      println("Error loading CSV: " + e.getMessage());
    }
  }

  // Process overall data (full year)
  void process(String airport) {
    currentRows.clear();
    totalFlights = 0;
    onTimeFlights = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    for (TableRow row : table.rows()) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
      currentRows.add(row);
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      if (cancelledStr.equals("true")) {
        cancelledFlights++;
      } else {
        int delay = row.getInt("minutes_late");
        if (delay > 0) {
          delayedFlights++;
        } else {
          onTimeFlights++;
        }
      }
    }
  }
  
  // Process daily data: only include rows where scheduled_departure begins with the given date ("YYYY-MM-DD")
  void processDaily(String airport, String date) {
    currentRows.clear();
    totalFlights = 0;
    onTimeFlights = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    for (TableRow row : table.rows()) {
      if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
      String sched = row.getString("scheduled_departure");
      if (sched == null || !sched.startsWith(date)) continue;
      currentRows.add(row);
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      if (cancelledStr.equals("true")) {
        cancelledFlights++;
      } else {
        int delay = row.getInt("minutes_late");
        if (delay > 0) {
          delayedFlights++;
        } else {
          onTimeFlights++;
        }
      }
    }
  }

  String[] getUniqueAirports() {
    if (table == null) return new String[0];
    ArrayList<String> unique = new ArrayList<String>();
    for (TableRow row : table.rows()) {
      String orig = row.getString("origin").trim();
      if (!unique.contains(orig)) {
        unique.add(orig);
      }
    }
    Collections.sort(unique);
    return unique.toArray(new String[unique.size()]);
  }
}
