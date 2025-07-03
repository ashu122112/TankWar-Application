// GameSketch.pde - Final Version
Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier> barriers = new ArrayList<Barrier>();
ArrayList<PowerUp> powerUps = new ArrayList<PowerUp>();
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Timer> timers = new ArrayList<Timer>(); // Declare globally

String currentTerrain = "";
boolean terrainSelected = false;
boolean countdownStarted = false;
int countdownStartTime;
int countdownDuration = 4000;
boolean countdownOver = false;
boolean gameOver = false;
String winnerMessage = "";

// Images
PImage tank1Img, tank2Img, barrierGImg, barrierDImg, barrierIImg;
PImage grasslandBg, desertBg, iceBg;
PImage bulletImg, missileImg, plasmaImg;
PImage explosionImg;

// Font
PFont gameFont;

// Battlefield layout
final int battlefieldX = 0; // Changed to start from 0 for full-width battlefield (before UI panel)
final int battlefieldY = 0; // Changed to start from 0
final int battlefieldWidth = 750; // Adjust for UI_PANEL_WIDTH
final int battlefieldHeight = 600; // Full height

final int UI_PANEL_WIDTH = 250;
final color UI_BG_COLOR = color(50, 70, 90);
final color UI_TEXT_COLOR = color(255);
final int UI_PADDING = 20;

void setup() {
  size(1000, 600);
  smooth();

  // Load images
  tank1Img = loadImage("tankBody_bigRed_outline.png");
  tank2Img = loadImage("tankBody_blue_outline.png");
  barrierGImg = loadImage("barricadeMetal.png");
  barrierDImg = loadImage("crateWood.png");
  barrierIImg = loadImage("barricadeWood.png");
  grasslandBg = loadImage("tileGrass1.png");
  desertBg = loadImage("tileSand_roadEast.png");
  iceBg = loadImage("tileSand1.png");
  bulletImg = loadImage("bulletDark1_outline.png");
  missileImg = loadImage("bulletSand3_outline.png");
  plasmaImg = loadImage("shotOrange.png");
  explosionImg = loadImage("explosion2.png");

  // Load font
  gameFont = createFont("Arial", 16, true);
  textFont(gameFont);

  // Initialize tanks (initial positions adjusted to battlefield)
  tank1 = new Tank(battlefieldX + 100, battlefieldY + battlefieldHeight/2 - 20, color(255,0,0), true, tank1Img);
  tank2 = new Tank(battlefieldX + battlefieldWidth - 100 - 60, battlefieldY + battlefieldHeight/2 - 20, color(0,0,255), false, tank2Img);
  // Initialize powerups
  spawnPowerUps();
}

void spawnPowerUps() {
  powerUps.clear();
  // Adjust power-up positions to be within the battlefield area
  powerUps.add(new PowerUp(battlefieldX + 200, battlefieldY + 200, "health"));
  powerUps.add(new PowerUp(battlefieldX + 500, battlefieldY + 300, "speed"));
  powerUps.add(new PowerUp(battlefieldX + 350, battlefieldY + 250, "rapid"));
  powerUps.add(new PowerUp(battlefieldX + 250, battlefieldY + 350, "shield"));
}

void draw() {
  background(180);

  if (!terrainSelected) {
    drawTerrainSelection();
    return;
  }

  if (countdownStarted && !countdownOver) {
    drawCountdown();
    return;
  }

  if (gameOver) {
    drawGameOver();
    return;
  }

  // Main game loop
  displayTerrain(); // Draw the battlefield background
  updateGameObjects();
  drawGameObjects(); // Draw tanks, projectiles, barriers, powerups, particles
  drawUIPanel(); // Draw the UI panel on the right
}

void drawTerrainSelection() {
  // Gradient background
  drawGradientBackground(color(50, 70, 90), color(30, 40, 60));

  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("SELECT BATTLEFIELD", width/2, height/2 - 80);

  textSize(24);
  text("Press G for Grassland", width/2, height/2 - 20);
  text("Press D for Desert", width/2, height/2 + 20);
  text("Press I for Ice", width/2, height/2 + 60);

  // Preview images (adjusted positions for better layout)
  float previewSize = 120;
  image(grasslandBg, width/2 - previewSize - 100, height/2 + 100, previewSize, previewSize * (grasslandBg.height / (float)grasslandBg.width));
  image(desertBg, width/2 - previewSize/2, height/2 + 100, previewSize, previewSize * (desertBg.height / (float)desertBg.width));
  image(iceBg, width/2 + 100, height/2 + 100, previewSize, previewSize * (iceBg.height / (float)iceBg.width));
}

void drawCountdown() {
  displayTerrain(); // Show terrain during countdown

  // Dark overlay
  fill(0, 180);
  rect(0, 0, width, height);

  int timePassed = millis() - countdownStartTime;
  int secondsLeft = 3 - (timePassed / 1000);

  fill(255);
  textSize(80);
  textAlign(CENTER, CENTER);

  if (secondsLeft >= 1) {
    text(secondsLeft, width/2, height/2);
  } else if (timePassed < countdownDuration) {
    text("GO!", width/2, height/2);
  } else {
    countdownOver = true;
  }
}

void drawGameOver() {
  displayTerrain(); // Show terrain behind game over screen

  // Dark overlay
  fill(0, 180);
  rect(0, 0, width, height);

  fill(255);
  textSize(50);
  textAlign(CENTER, CENTER);
  text(winnerMessage, width/2, height/2);

  textSize(24);
  text("Press R to Restart", width/2, height/2 + 60);
}

void displayTerrain() {
  // Draw battlefield background. Use battlefieldWidth and battlefieldHeight for sizing.
  PImage bgImage = null;
  if (currentTerrain.equals("grassland")) {
    bgImage = grasslandBg;
  } else if (currentTerrain.equals("desert")) {
    bgImage = desertBg;
  } else if (currentTerrain.equals("ice")) {
    bgImage = iceBg;
  }

  if (bgImage != null) {
    // Tile the background image if it's small
    for (int x = battlefieldX; x < battlefieldX + battlefieldWidth; x += bgImage.width) {
      for (int y = battlefieldY; y < battlefieldY + battlefieldHeight; y += bgImage.height) {
        image(bgImage, x, y, min(bgImage.width, battlefieldX + battlefieldWidth - x), min(bgImage.height, battlefieldY + battlefieldHeight - y));
      }
    }
  }

  // Battlefield border
  stroke(0);
  strokeWeight(4);
  noFill();
  rect(battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
  noStroke();
}

void updateGameObjects() {
  // Update tanks
  tank1.update(barriers, tank2);
  tank2.update(barriers, tank1);

  // Update projectiles
  for (int i = projectiles.size()-1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.update(); // Projectile's update now handles barrier/tank collisions and creates explosions
    if (!p.alive) {
      projectiles.remove(i);
    }
  }

  // Update barriers (remove destroyed ones)
  for (int i = barriers.size() - 1; i >= 0; i--) {
    if (barriers.get(i).isDestroyed()) {
      createExplosion(barriers.get(i).x + barriers.get(i).w/2, barriers.get(i).y + barriers.get(i).h/2, 50);
      barriers.remove(i);
    }
  }

  // Update particles
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (!p.alive) {
      particles.remove(i);
    }
  }

  // Update timers for power-up effects
  for (int i = timers.size() - 1; i >= 0; i--) {
    timers.get(i).update();
    if (timers.get(i).isDone()) {
      timers.remove(i);
    }
  }

  // Check for PowerUp collection
  for (int i = powerUps.size() - 1; i >= 0; i--) {
    PowerUp p = powerUps.get(i);
    if (p.isCollectedBy(tank1)) {
      tank1.applyPowerUp(p);
      powerUps.remove(i);
    } else if (p.isCollectedBy(tank2)) {
      tank2.applyPowerUp(p);
      powerUps.remove(i);
    }
  }

  // Game over check
  if (tank1.health <= 0) {
    gameOver("PLAYER 2 WINS!");
  } else if (tank2.health <= 0) {
    gameOver("PLAYER 1 WINS!");
  }
}

void drawGameObjects() {
  // Draw game objects on top of terrain
  for (Barrier b : barriers) b.display();
  for (Projectile p : projectiles) p.display();
  for (PowerUp p : powerUps) p.display();
  for (Particle p : particles) p.display();

  tank1.display(true);  // true to show health bars
  tank2.display(true);
}


void drawUIPanel() {
  // Panel background
  fill(UI_BG_COLOR);
  noStroke();
  rect(width - UI_PANEL_WIDTH, 0, UI_PANEL_WIDTH, height);

  fill(UI_TEXT_COLOR);
  textSize(16);
  textAlign(LEFT, TOP);

  float yPos = UI_PADDING;

  // Player 1 Info
  fill(255, 0, 0); // Red for Player 1
  text("PLAYER 1", width - UI_PANEL_WIDTH + UI_PADDING, yPos);
  fill(UI_TEXT_COLOR);
  text("HP: " + (int)tank1.health + "%", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 25);
  text("Weapon: " + tank1.getCurrentWeapon().toUpperCase(), width - UI_PANEL_WIDTH + UI_PADDING, yPos + 50);

  // Player 2 Info
  fill(0, 0, 255); // Blue for Player 2
  text("PLAYER 2", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 100);
  fill(UI_TEXT_COLOR);
  text("HP: " + (int)tank2.health + "%", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 125);
  text("Weapon: " + tank2.getCurrentWeapon().toUpperCase(), width - UI_PANEL_WIDTH + UI_PADDING, yPos + 150);

  // Controls
  fill(200);
  text("CONTROLS", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 200);

  textSize(14);
  text("PLAYER 1:", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 230);
  text("Move: W A S D", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 255);
  text("Fire: SPACE", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 280);
  text("Switch: Q", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 305);
  text("Weapons:", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 330);
  text("1-Bullet 2-Missile", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 355);
  text("3-Plasma", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 380);

  text("PLAYER 2:", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 420);
  text("Move: ARROWS", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 445);
  text("Fire: L", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 470);
  text("Switch: K", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 495);
  text("Weapons:", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 520);
  text("8-Bullet 9-Missile", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 545);
  text("0-Plasma", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 570);
}


void createExplosion(float x, float y, float size) {
  // Using explosionImg instead of just particles
  // For a simple explosion image display:
  // image(explosionImg, x - size/2, y - size/2, size, size); // Centered

  // Or keep particles for a more dynamic effect, or combine them
  for (int i = 0; i < 20; i++) {
    particles.add(new Particle(x, y, random(-3, 3), random(-3, 3),
                               color(255, random(150, 255), 0), random(5, 15), 30));
  }
}

// Helper function to draw rounded rectangles (not currently used but provided)
void drawRoundedRect(float x, float y, float w, float h, float r, color c) {
  fill(c);
  noStroke();
  rect(x, y + r, w, h - 2*r);
  rect(x + r, y, w - 2*r, h);
  ellipse(x + r, y + r, 2*r, 2*r);
  ellipse(x + w - r, y + r, 2*r, 2*r);
  ellipse(x + r, y + h - r, 2*r, 2*r);
  ellipse(x + w - r, y + h - r, 2*r, 2*r);
}

void drawGradientBackground(color c1, color c2) {
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(0, i, width, i);
  }
}

void keyPressed() {
  if (!terrainSelected) {
    handleTerrainSelection();
    if (terrainSelected && !countdownStarted) { // Start countdown after terrain selection
      countdownStarted = true;
      countdownStartTime = millis();
    }
    return;
  }

  if (!countdownOver && countdownStarted) return; // Don't allow movement/firing during countdown

  if (gameOver) {
    if (key == 'r' || key == 'R') {
      resetGame();
    }
    return;
  }

  // Player 1 controls
  tank1.handleKeyPressed(key, true);
  // Player 2 controls
  tank2.handleKeyPressed(keyCode, true); // Use keyCode for arrow keys
}

void keyReleased() {
  if (!countdownOver || gameOver) return; // Prevent actions when not in game state

  // Player 1 controls
  tank1.handleKeyPressed(key, false);
  // Player 2 controls
  tank2.handleKeyPressed(keyCode, false);
}

void handleTerrainSelection() {
  // Common barrier setup
  float barrierX = battlefieldX + battlefieldWidth / 2 - 25; // Center the barrier horizontally
  float barrierY = battlefieldY + battlefieldHeight / 2 - 75; // Center the barrier vertically
  float barrierW = 50;
  float barrierH = 150;

  if (key == 'g' || key == 'G') {
    currentTerrain = "grassland";
    terrainSelected = true;
    // barriers.add(new Barrier(300, height - 150, 50, 150, barrierGImg)); // Old hardcoded position
    barriers.add(new Barrier(barrierX, barrierY, barrierW, barrierH, barrierGImg));
  } else if (key == 'd' || key == 'D') {
    currentTerrain = "desert";
    terrainSelected = true;
    // barriers.add(new Barrier(300, height - 150, 50, 150, barrierDImg)); // Old hardcoded position
    barriers.add(new Barrier(barrierX, barrierY, barrierW, barrierH, barrierDImg));
  } else if (key == 'i' || key == 'I') {
    currentTerrain = "ice";
    terrainSelected = true;
    // barriers.add(new Barrier(300, height - 150, 50, 150, barrierIImg)); // Old hardcoded position
    barriers.add(new Barrier(barrierX, barrierY, barrierW, barrierH, barrierIImg));
  }
}

void resetGame() {
  // Reset tank positions relative to battlefield
  tank1 = new Tank(battlefieldX + 100, battlefieldY + battlefieldHeight/2 - tank1.tankHeight/2, color(255, 0, 0), true, tank1Img);
  tank2 = new Tank(battlefieldX + battlefieldWidth - 100 - tank2.tankWidth, battlefieldY + battlefieldHeight/2 - tank2.tankHeight/2, color(0, 0, 255), false, tank2Img);

  projectiles.clear();
  barriers.clear();
  powerUps.clear();
  particles.clear();
  timers.clear(); // Clear all active timers

  spawnPowerUps();

  // Re-add barrier based on selected terrain
  float barrierX = battlefieldX + battlefieldWidth / 2 - 25; // Center the barrier horizontally
  float barrierY = battlefieldY + battlefieldHeight / 2 - 75; // Center the barrier vertically
  float barrierW = 50;
  float barrierH = 150;

  if (currentTerrain.equals("grassland")) {
    barriers.add(new Barrier(barrierX, barrierY, barrierW, barrierH, barrierGImg));
  } else if (currentTerrain.equals("desert")) {
    barriers.add(new Barrier(barrierX, barrierY, barrierW, barrierH, barrierDImg));
  } else if (currentTerrain.equals("ice")) {
    barriers.add(new Barrier(barrierX, barrierY, barrierW, barrierH, barrierIImg));
  }

  gameOver = false;
  // When resetting, restart the countdown flow
  countdownStarted = true;
  countdownOver = false;
  countdownStartTime = millis();
}

void gameOver(String message) {
  // Only set game over once
  if (!gameOver) {
    gameOver = true;
    winnerMessage = message;
  }
}
