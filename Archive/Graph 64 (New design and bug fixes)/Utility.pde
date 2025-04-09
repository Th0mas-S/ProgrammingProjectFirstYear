// Utility.pde
// Contains helper methods used throughout the sketch.

class Utility {

  // Returns a fitted text size for a single line of text.
  float getFittedTextSize(String text, float maxWidth, float defaultSize) {
    float ts = defaultSize;
    textSize(ts);
    while (ts > 5 && textWidth(text) > maxWidth) {
      ts -= 1;
      textSize(ts);
    }
    return ts;
  }
  
  // Returns a fitted text size for multiple lines by joining them.
  float getFittedTextSize(String[] lines, float maxWidth, float defaultSize) {
    String joined = join(lines, " ");
    return getFittedTextSize(joined, maxWidth, defaultSize);
  }
  
  // Formats a date string ("YYYY-MM-DD") into a more descriptive form.
  String formatDate(String date) {
    String[] parts = split(date, "-");
    if (parts.length != 3) return date;
    int year  = int(parts[0]);
    int month = int(parts[1]);
    int day   = int(parts[2]);
    return getOrdinal(day) + " of " + getMonthNameFull(month) + " " + year;
  }
  
  // Returns the ordinal (st, nd, rd, th) for a day.
  String getOrdinal(int day) {
    if (day >= 11 && day <= 13) return nf(day, 0) + "th";
    int lastDigit = day % 10;
    if (lastDigit == 1) return nf(day, 0) + "st";
    if (lastDigit == 2) return nf(day, 0) + "nd";
    if (lastDigit == 3) return nf(day, 0) + "rd";
    return nf(day, 0) + "th";
  }
  
  // Returns the full month name given a month number (1-12).
  String getMonthNameFull(int m) {
    String[] months = {"January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"};
    if (m < 1 || m > 12) return "";
    return months[m-1];
  }
  
  // Extracts the airport name from a full origin string.
  String extractAirportName(String fullOrigin) {
    int openParen = fullOrigin.indexOf("(");
    if (openParen != -1) {
      return fullOrigin.substring(0, openParen).trim();
    }
    return fullOrigin;
  }
  
  // Extracts the location (inside the parenthesis) from a full origin string.
  String extractLocation(String fullOrigin) {
    int openParen  = fullOrigin.indexOf("(");
    int closeParen = fullOrigin.indexOf(")");
    if (openParen != -1 && closeParen != -1 && closeParen > openParen) {
      return fullOrigin.substring(openParen + 1, closeParen).trim();
    }
    return "";
  }
}
