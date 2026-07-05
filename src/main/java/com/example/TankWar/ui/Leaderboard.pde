// Leaderboard.pde — Local Season Records
// Saves match history to disk so it persists between sessions.
// File: data/leaderboard.txt inside your Processing sketch folder.

int lb_p1Wins = 0;
int lb_p2Wins = 0;
int lb_total  = 0;
ArrayList<String[]> lb_history = new ArrayList<String[]>();

// ── Load from disk ────────────────────────────────────────────
void loadLeaderboard() {
  try {
    String[] lines = loadStrings("leaderboard.txt");
    if (lines == null) return;
    for (String line : lines) {
      if (line.startsWith("RECORD|")) {
        String[] parts = line.split("\\|");
        if (parts.length >= 5) {
          lb_history.add(new String[]{parts[1], parts[2], parts[3], parts[4]});
          lb_total++;
          if (parts[1].contains("1")) lb_p1Wins++;
          else                        lb_p2Wins++;
        }
      }
    }
  } catch (Exception e) {
    println("[Leaderboard] No existing file, starting fresh.");
  }
}

// ── Save a match result ───────────────────────────────────────
void saveMatchResult(String winner, String loser, String terrain, boolean hackUsed) {
  lb_total++;
  if (winner.contains("1")) lb_p1Wins++;
  else                      lb_p2Wins++;

  String[] rec = {winner, loser, terrain, str(hackUsed)};
  lb_history.add(rec);

  // Keep only last 20 records in memory
  if (lb_history.size() > 20) lb_history.remove(0);

  persistLeaderboard();
}

// ── Write all records to disk ─────────────────────────────────
void persistLeaderboard() {
  ArrayList<String> lines = new ArrayList<String>();
  for (String[] rec : lb_history) {
    lines.add("RECORD|" + rec[0] + "|" + rec[1] + "|" + rec[2] + "|" + rec[3]);
  }
  String[] arr = new String[lines.size()];
  lines.toArray(arr);
  saveStrings("leaderboard.txt", arr);
}

// ── Clear all records ─────────────────────────────────────────
void clearLeaderboard() {
  lb_p1Wins = 0;
  lb_p2Wins = 0;
  lb_total  = 0;
  lb_history.clear();
  saveStrings("leaderboard.txt", new String[]{});
  println("[Leaderboard] Cleared.");
}
