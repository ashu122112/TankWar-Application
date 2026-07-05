// HackChallenge.pde — Unified Cyber Design
// Logic: identical to original. Only drawHackChallenge() visual is redesigned.

Tank hackingTank = null;
String hackReward = "";
int hackStartTime = 0;
int hackTimeLimit = 15000;
String hackInput = "";
String hackFeedback = "";
int feedbackTimer = 0;

String[][] challenges = {
  {
    "SQL LOGIN BYPASS",
    "Query: SELECT * FROM users\n  WHERE name='{input}' AND pass='x'",
    "Hint: Comment out the password check with  --",
    "admin'--",
    "missile_burst"
  },
  {
    "BASE64 DECODE",
    "Decode this string:  U0hJRUxE",
    "Hint: Standard Base64 encoding",
    "SHIELD",
    "shield"
  },
  {
    "XSS INJECTION",
    "Inject into:  <input value='{input}'>",
    "Hint: Break out of the attribute with a closing quote",
    "'><script>alert(1)</script>",
    "rapid_fire"
  },
  {
    "CAESAR CIPHER",
    "Decode (shift 3):  VSRBS",
    "Hint: Shift each letter back by 3 in the alphabet",
    "SPEED",
    "speed"
  },
  {
    "COMMAND INJECTION",
    "Ping tool runs:  ping {input}",
    "Hint: Chain a second shell command with a semicolon",
    "127.0.0.1; ls",
    "triple_shot"
  }
};

int currentChallengeIndex = 0;

// ── Start challenge ───────────────────────────────────────────
void startHackChallenge(Tank tank) {
  hackingTank = tank;
  hackInput   = "";
  hackFeedback = "";
  hackStartTime = millis();
  currentChallengeIndex = (int) random(challenges.length);
  hackReward = challenges[currentChallengeIndex][4];
  gameState = "hacking";
}

// ── Draw challenge panel  ★ REDESIGNED ───────────────────────
void drawHackChallenge() {
  // Dark vignette over the battlefield
  fill(0, 0, 0, 175);
  noStroke();
  rect(0, 0, width, height);

  // Timer calculation
  int elapsed  = millis() - hackStartTime;
  float timePct = constrain(1.0 - (float)elapsed / hackTimeLimit, 0, 1);

  // Panel dimensions
  float pw = 540, ph = 370;
  float px = (width - UI_PANEL_WIDTH)/2 - pw/2; // centered over battlefield
  float py = height/2 - ph/2;

  // Panel shadow
  fill(0, 80); noStroke(); rect(px+6, py+6, pw, ph, 8);

  // Panel body
  fill(red(C_PANEL), green(C_PANEL), blue(C_PANEL), 248);
  noStroke(); rect(px, py, pw, ph, 8);

  // Top accent stripe (green)
  fill(C_GREEN); rect(px, py, pw, 4, 8,8,0,0);

  // Panel border
  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 90);
  strokeWeight(1); noFill(); rect(px, py, pw, ph, 8); noStroke();

  // Corner brackets for effect
  drawBracket(px+8, py+8, 36, 36, C_GREEN, 120);
  drawBracket(px+pw-44, py+8, 36, 36, C_GREEN, 120);

  // ── Timer bar ─────────────────────────────────────────────
  float barX = px+16, barY = py+14, barW = pw-32, barH = 8;
  fill(C_BORDER); noStroke(); rect(barX, barY, barW, barH, 4);
  color timerCol = timePct > 0.5 ? C_GREEN : (timePct > 0.25 ? C_ORANGE : C_RED);
  fill(timerCol); rect(barX, barY, barW*timePct, barH, 4);

  // Timer seconds label
  fill(C_DIM); textSize(10); textAlign(RIGHT, TOP);
  text(nf(max(0, hackTimeLimit-elapsed)/1000.0, 1, 1) + "s", px+pw-16, py+14);

  // ── Header ────────────────────────────────────────────────
  fill(C_GREEN); textSize(12); textAlign(CENTER, TOP);
  text("[  HACK TERMINAL INTERCEPTED  ]", px+pw/2, py+32);

  // Challenge category
  fill(C_YELLOW); textSize(15);
  text(challenges[currentChallengeIndex][0], px+pw/2, py+56);

  // ── Challenge body ────────────────────────────────────────
  fill(C_CARD); noStroke(); rect(px+16, py+82, pw-32, 78, 4);
  stroke(C_BORDER); strokeWeight(1); noFill(); rect(px+16, py+82, pw-32, 78, 4); noStroke();

  fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 200);
  textSize(12); textAlign(LEFT, TOP);
  String body = challenges[currentChallengeIndex][1];
  String[] bodyLines = body.split("\n");
  for (int i = 0; i < bodyLines.length; i++)
    text(bodyLines[i], px+28, py+92 + i*20);

  // ── Hint ──────────────────────────────────────────────────
  fill(C_DIM); textSize(11);
  text(challenges[currentChallengeIndex][2], px+28, py+172);

  // ── Reward ────────────────────────────────────────────────
  fill(C_CARD); noStroke(); rect(px+16, py+194, pw-32, 26, 4);
  fill(C_YELLOW); textSize(11); textAlign(LEFT, CENTER);
  text("Reward:", px+28, py+207);
  fill(C_TEXT);
  text(rewardLabel(hackReward), px+80, py+207);

  // ── Input area ────────────────────────────────────────────
  fill(C_DIM); textSize(11); textAlign(LEFT, TOP);
  text("Your Answer:", px+16, py+232);

  // Input box
  fill(red(C_BG), green(C_BG), blue(C_BG), 220);
  noStroke(); rect(px+16, py+250, pw-32, 34, 4);
  stroke(hackFeedback.length() > 0 ?
    (hackFeedback.equals("CORRECT!") ? C_GREEN : C_RED) :
    color(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 120));
  strokeWeight(1.5); noFill(); rect(px+16, py+250, pw-32, 34, 4); noStroke();

  // Typed text + cursor blink
  fill(C_GREEN); textSize(13); textAlign(LEFT, CENTER);
  String cursor = (frameCount % 30 < 15) ? "|" : "";
  text(hackInput + cursor, px+28, py+267);

  // ── Feedback ──────────────────────────────────────────────
  if (hackFeedback.length() > 0) {
    boolean correct = hackFeedback.equals("CORRECT!");
    fill(correct ? C_GREEN : C_RED);
    textSize(20); textAlign(CENTER, TOP);
    text(hackFeedback, px+pw/2, py+298);
  } else {
    fill(C_DIM); textSize(10); textAlign(CENTER, TOP);
    text("ENTER  to submit   ·   ESC  to abandon", px+pw/2, py+302);
  }

  // ── Footer: attacker label ─────────────────────────────────
  fill(C_DIM); textSize(10); textAlign(LEFT, TOP);
  boolean isP1 = (hackingTank == tank1);
  fill(isP1 ? C_P1 : C_P2);
  text((isP1 ? "PLAYER 1" : "PLAYER 2") + " is hacking...", px+16, py+ph-22);

  // ── Timeout logic ─────────────────────────────────────────
  if (elapsed > hackTimeLimit && hackFeedback.length() == 0) {
    hackFeedback = "TIME'S UP!";
    feedbackTimer = millis();
  }
  if (hackFeedback.length() > 0 && millis() - feedbackTimer > 1800) {
    endHackChallenge();
  }

  textAlign(CENTER, CENTER); // reset
}

// ── Answer check ─────────────────────────────────────────────
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
    Tank opponent = (hackingTank == tank1) ? tank2 : tank1;
    opponent.health = min(opponent.health + 5, 100);
  }
}

// ── Apply reward ──────────────────────────────────────────────
void applyHackReward(Tank t, String reward) {
  hackChallengeUsed = true;
  powerupSound.trigger();
  switch(reward) {
    case "missile_burst":
      t.hackMissileBurst = true;
      timers.add(new Timer(5000, () -> t.hackMissileBurst = false));
      break;
    case "shield":
      t.hasShield = true;
      break;
    case "rapid_fire":
      t.rapidFire = 3.0;
      timers.add(new Timer(12000, () -> t.rapidFire = 1.0));
      break;
    case "speed":
      t.speedBoost = 2.0;
      timers.add(new Timer(12000, () -> t.speedBoost = 1.0));
      break;
    case "triple_shot":
      t.hackTripleShot = true;
      timers.add(new Timer(8000, () -> t.hackTripleShot = false));
      break;
  }
}

void endHackChallenge() {
  hackingTank = null;
  hackInput = "";
  hackFeedback = "";
  gameState = "playing";
}

String rewardLabel(String r) {
  switch(r) {
    case "missile_burst": return "MISSILE BURST — 3x homing missiles";
    case "shield":        return "FULL SHIELD — absorb next hit";
    case "rapid_fire":    return "RAPID FIRE x3 — 12 seconds";
    case "speed":         return "SPEED BOOST x2 — 12 seconds";
    case "triple_shot":   return "TRIPLE SHOT — 8 seconds";
    default:              return r;
  }
}
