// HackChallenge.pde — NEW FILE

// Tracks which tank triggered the hack terminal
Tank hackingTank = null;
String hackReward = "";           // what reward to give on correct answer
int hackStartTime = 0;
int hackTimeLimit = 15000;        // 15 seconds to answer
String hackInput = "";            // player's typed answer
String hackFeedback = "";         // "CORRECT!", "WRONG!", or ""
int feedbackTimer = 0;

// ── CHALLENGE BANK ──────────────────────────────────────────────────────────
// Each entry: { challenge text (shown to player), correct answer, reward }
// Add or remove challenges freely here — no DB needed
String[][] challenges = {
  {
    "SQL LOGIN BYPASS",
    "Query: SELECT * FROM users\n  WHERE name='{input}' AND pass='x'",
    "Hint: Comment out the password check",
    "admin'--",
    "missile_burst"
  },
  {
    "BASE64 DECODE",
    "Decode this: U0hJRUxE",
    "Hint: Standard Base64 encoding",
    "SHIELD",
    "shield"
  },
  {
    "XSS INJECTION",
    "Inject into: <input value='{input}'>",
    "Hint: Break out of the attribute",
    "'><script>alert(1)</script>",
    "rapid_fire"
  },
  {
    "CAESAR CIPHER",
    "Decode (shift 3): VSRBS",
    "Hint: Each letter shifted back by 3",
    "SPEED",
    "speed"
  },
  {
    "COMMAND INJECTION",
    "Input field runs: ping {input}",
    "Hint: Chain a second command",
    "127.0.0.1; ls",
    "triple_shot"
  }
};

// Currently active challenge index
int currentChallengeIndex = 0;

// ── CALLED WHEN HACK TERMINAL IS COLLECTED ──────────────────────────────────
void startHackChallenge(Tank tank) {
  hackingTank = tank;
  hackInput = "";
  hackFeedback = "";
  hackStartTime = millis();
  // Pick a random challenge
  currentChallengeIndex = (int) random(challenges.length);
  hackReward = challenges[currentChallengeIndex][4]; // reward string
  gameState = "hacking";    // pause normal game loop
}

// ── DRAW THE CHALLENGE PANEL ─────────────────────────────────────────────────
void drawHackChallenge() {
  // Dim the game behind the panel
  fill(0, 0, 0, 170);
  rect(0, 0, width, height);

  // Panel background
  float pw = 500, ph = 340;
  float px = (width - pw) / 2;
  float py = (height - ph) / 2;
  fill(10, 20, 10);
  stroke(0, 255, 100);
  strokeWeight(2);
  rect(px, py, pw, ph, 8);
  noStroke();

  // Timer bar at top of panel
  int elapsed = millis() - hackStartTime;
  float timeLeft = constrain(1.0 - (float)elapsed / hackTimeLimit, 0, 1);
  fill(50);
  rect(px + 10, py + 10, pw - 20, 8);
  fill(timeLeft > 0.4 ? color(0, 255, 100) : color(255, 80, 0));
  rect(px + 10, py + 10, (pw - 20) * timeLeft, 8);

  // Title
  fill(0, 255, 100);
  textSize(14);
  textAlign(CENTER, TOP);
  text("[ HACK TERMINAL INTERCEPTED ]", width / 2, py + 28);

  // Challenge name
  fill(255, 220, 0);
  textSize(13);
  text(challenges[currentChallengeIndex][0], width / 2, py + 50);

  // Challenge body
  fill(200, 255, 200);
  textSize(12);
  textAlign(LEFT, TOP);
  text(challenges[currentChallengeIndex][1], px + 20, py + 75);

  // Hint
  fill(150, 150, 150);
  textSize(11);
  text(challenges[currentChallengeIndex][2], px + 20, py + 155);

  // Reward label
  fill(255, 200, 0);
  textSize(12);
  textAlign(CENTER, TOP);
  text("Reward: " + rewardLabel(hackReward), width / 2, py + 185);

  // Input box label
  fill(0, 255, 100);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Your Answer:", px + 20, py + 215);

  // Input box
  fill(0, 30, 0);
  stroke(0, 255, 100);
  strokeWeight(1);
  rect(px + 20, py + 235, pw - 40, 30, 4);
  noStroke();

  fill(0, 255, 100);
  textSize(13);
  textAlign(LEFT, CENTER);
  text(hackInput + "|", px + 28, py + 250);

  // Feedback message
  if (hackFeedback.length() > 0) {
    fill(hackFeedback.equals("CORRECT!") ? color(0, 255, 100) : color(255, 80, 0));
    textSize(18);
    textAlign(CENTER, TOP);
    text(hackFeedback, width / 2, py + 285);
  } else {
    fill(120);
    textSize(11);
    textAlign(CENTER, TOP);
    text("Press ENTER to submit  |  ESC to abandon", width / 2, py + 290);
  }

  // Auto-end if time runs out
  if (elapsed > hackTimeLimit && hackFeedback.length() == 0) {
    hackFeedback = "TIME'S UP!";
    feedbackTimer = millis();
  }
  if (hackFeedback.length() > 0 && millis() - feedbackTimer > 1500) {
    endHackChallenge();
  }
}

// ── CALLED WHEN ENTER IS PRESSED DURING HACKING STATE ───────────────────────
void checkHackAnswer() {
  String correct = challenges[currentChallengeIndex][3].trim().toLowerCase();
  String given   = hackInput.trim().toLowerCase();

  if (given.equals(correct)) {
    hackFeedback = "CORRECT!";
    feedbackTimer = millis();
    applyHackReward(hackingTank, hackReward);
  } else {
    hackFeedback = "WRONG! -10 HP";
    feedbackTimer = millis();
    hackingTank.takeDamage(10);
    // Opponent gets a small consolation buff
    Tank opponent = (hackingTank == tank1) ? tank2 : tank1;
    opponent.health = min(opponent.health + 5, 100);
  }
}

// ── APPLY THE REWARD TO THE WINNING TANK ────────────────────────────────────
void applyHackReward(Tank t, String reward) {
  hackChallengeUsed = true;
  powerupSound.trigger();
  switch(reward) {
    case "missile_burst":
      // Fire 3 missiles in quick succession — handled by flag on Tank
      t.hackMissileBurst = true;
      timers.add(new Timer(5000, () -> t.hackMissileBurst = false));
      break;
    case "shield":
      t.hasShield = true;
      break;
    case "rapid_fire":
      t.rapidFire = 3.0;              // stronger than normal rapid (2.0)
      timers.add(new Timer(12000, () -> t.rapidFire = 1.0));
      break;
    case "speed":
      t.speedBoost = 2.0;             // stronger than normal speed (1.5)
      timers.add(new Timer(12000, () -> t.speedBoost = 1.0));
      break;
    case "triple_shot":
      t.hackTripleShot = true;
      timers.add(new Timer(8000, () -> t.hackTripleShot = false));
      break;
  }
}

// ── RESUME GAME ──────────────────────────────────────────────────────────────
void endHackChallenge() {
  hackingTank = null;
  hackInput = "";
  hackFeedback = "";
  gameState = "playing";
}

// ── READABLE REWARD NAME FOR UI ──────────────────────────────────────────────
String rewardLabel(String r) {
  switch(r) {
    case "missile_burst": return "MISSILE BURST (3x homing missiles)";
    case "shield":        return "FULL SHIELD";
    case "rapid_fire":    return "RAPID FIRE x3 (12 sec)";
    case "speed":         return "SPEED BOOST x2 (12 sec)";
    case "triple_shot":   return "TRIPLE SHOT (8 sec)";
    default:              return r;
  }
}
