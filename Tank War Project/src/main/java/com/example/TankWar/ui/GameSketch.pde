// GameSketch.pde - Final Version
Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier> barriers = new ArrayList<Barrier>();
ArrayList<PowerUp> powerUps = new ArrayList<PowerUp>();
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Timer> timers = new ArrayList<Timer>();

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
final int battlefieldX = 150;
final int battlefieldY = 100;
final int battlefieldWidth = 700;
final int battlefieldHeight = 450;

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
  
  // Initialize tanks
  tank1 = new Tank(200, height/2, color(255,0,0), true, tank1Img);
  tank2 = new Tank(width-UI_PANEL_WIDTH-200, height/2, color(0,0,255), false, tank2Img);
  // Initialize powerups
  spawnPowerUps();
}

void spawnPowerUps() {
  powerUps.clear();
  powerUps.add(new PowerUp(300, 200, "health"));
  powerUps.add(new PowerUp(600, 300, "speed"));
  powerUps.add(new PowerUp(450, 250, "rapid"));
  powerUps.add(new PowerUp(350, 350, "shield"));
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
  displayTerrain();
  updateGameObjects();
  drawUI();
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
  
  // Preview images
  float previewSize = 120;
  image(grasslandBg, width/2 - previewSize - 150, height/2 + 100, previewSize, previewSize/2);
  image(desertBg, width/2 - previewSize/2, height/2 + 100, previewSize, previewSize/2);
  image(iceBg, width/2 + 150, height/2 + 100, previewSize, previewSize/2);
}

void drawCountdown() {
  displayTerrain();
  
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
  displayTerrain();
  
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
  // Draw battlefield background
  if (currentTerrain.equals("grassland")) {
    image(grasslandBg, battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
  } else if (currentTerrain.equals("desert")) {
    image(desertBg, battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
  } else if (currentTerrain.equals("ice")) {
    image(iceBg, battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
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
    p.update();
    
    if (!p.alive) {
      projectiles.remove(i);
    }
  }
  
  for (int i = timers.size() - 1; i >= 0; i--) {
  timers.get(i).update();
  if (timers.get(i).isDone()) {
    timers.remove(i);
  }
}
  
  // Game over check
  if (tank1.health <= 0) {
    gameOver("PLAYER 2 WINS!");
  } 
  else if (tank2.health <= 0) {
    gameOver("PLAYER 1 WINS!");
  }
}

void drawUI() {
  drawBattlefield();
  drawUIPanel();
  
  // Draw game objects on top
  for (Barrier b : barriers) b.display();
  for (Projectile p : projectiles) p.display();
  for (PowerUp p : powerUps) p.display();
  for (Particle p : particles) p.display();
  
  tank1.display(true);  // true to show health bars
tank2.display(true);
}

void drawBattlefield() {
  // Draw battlefield background
  if (currentTerrain.equals("grassland")) {
    image(grasslandBg, 0, 0, width-UI_PANEL_WIDTH, height);
  } else if (currentTerrain.equals("desert")) {
    image(desertBg, 0, 0, width-UI_PANEL_WIDTH, height);
  } else if (currentTerrain.equals("ice")) {
    image(iceBg, 0, 0, width-UI_PANEL_WIDTH, height);
  }
  
  // Battlefield border
  stroke(0);
  strokeWeight(4);
  noFill();
  rect(0, 0, width-UI_PANEL_WIDTH, height);
}

void drawUIPanel() {
  // Panel background
  fill(50, 70, 90);
  noStroke();
  rect(width - UI_PANEL_WIDTH, 0, UI_PANEL_WIDTH, height);
  
  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  
  float yPos = 20;
  
  // Player 1 Info
  fill(255, 0, 0);
  text("PLAYER 1", width - UI_PANEL_WIDTH + 20, yPos);
  fill(255);
  text("HP: " + (int)tank1.health + "%", width - UI_PANEL_WIDTH + 20, yPos + 25);
  text("Weapon: " + tank1.getCurrentWeapon().toUpperCase(), width - UI_PANEL_WIDTH + 20, yPos + 50);
  
  // Player 2 Info
  fill(0, 0, 255);
  text("PLAYER 2", width - UI_PANEL_WIDTH + 20, yPos + 100);
  fill(255);
  text("HP: " + (int)tank2.health + "%", width - UI_PANEL_WIDTH + 20, yPos + 125);
  text("Weapon: " + tank2.getCurrentWeapon().toUpperCase(), width - UI_PANEL_WIDTH + 20, yPos + 150);
  
  // Controls
  fill(200);
  text("CONTROLS", width - UI_PANEL_WIDTH + 20, yPos + 200);
  
  textSize(14);
  text("PLAYER 1:", width - UI_PANEL_WIDTH + 20, yPos + 230);
  text("Move: W A S D", width - UI_PANEL_WIDTH + 20, yPos + 255);
  text("Fire: SPACE", width - UI_PANEL_WIDTH + 20, yPos + 280);
  text("Switch: Q", width - UI_PANEL_WIDTH + 20, yPos + 305);
  text("Weapons:", width - UI_PANEL_WIDTH + 20, yPos + 330);
  text("1-Bullet 2-Missile", width - UI_PANEL_WIDTH + 20, yPos + 355);
  text("3-Plasma", width - UI_PANEL_WIDTH + 20, yPos + 380);
  
  text("PLAYER 2:", width - UI_PANEL_WIDTH + 20, yPos + 420);
  text("Move: ARROWS", width - UI_PANEL_WIDTH + 20, yPos + 445);
  text("Fire: L", width - UI_PANEL_WIDTH + 20, yPos + 470);
  text("Switch: K", width - UI_PANEL_WIDTH + 20, yPos + 495);
  text("Weapons:", width - UI_PANEL_WIDTH + 20, yPos + 520);
  text("8-Bullet 9-Missile", width - UI_PANEL_WIDTH + 20, yPos + 545);
  text("0-Plasma", width - UI_PANEL_WIDTH + 20, yPos + 570);
}

void drawControlsPanel(float yPos) {
  float xPos = width - UI_PANEL_WIDTH + UI_PADDING;
  
  fill(UI_TEXT_COLOR);
  textSize(18);
  text("CONTROLS", xPos, yPos);
  yPos += 30;
  
  textSize(14);
  text("PLAYER 1:", xPos, yPos);
  yPos += 20;
  text("Move: W A S D", xPos, yPos);
  yPos += 20;
  text("Fire: SPACE", xPos, yPos);
  yPos += 20;
  text("Switch: Q", xPos, yPos);
  yPos += 20;
  text("Weapons: 1-Bullet", xPos, yPos);
  yPos += 20;
  text("2-Missile 3-Plasma", xPos, yPos);
  yPos += 30;
  
  text("PLAYER 2:", xPos, yPos);
  yPos += 20;
  text("Move: ARROWS", xPos, yPos);
  yPos += 20;
  text("Fire: L", xPos, yPos);
  yPos += 20;
  text("Switch: K", xPos, yPos);
  yPos += 20;
  text("Weapons: 8-Bullet", xPos, yPos);
  yPos += 20;
  text("9-Missile 0-Plasma", xPos, yPos);
}

void drawWeaponInfo() {
  // Player 1 weapon
  fill(tank1.tankColor);
  textAlign(LEFT);
  text("Current: " + tank1.weapons[tank1.selectedWeapon].toUpperCase(), 20, 50);
  
  // Player 2 weapon
  fill(tank2.tankColor);
  textAlign(RIGHT);
  text("Current: " + tank2.weapons[tank2.selectedWeapon].toUpperCase(), width - 20, 50);
}

void createExplosion(float x, float y, float size) {
  for (int i = 0; i < 20; i++) {
    particles.add(new Particle(x, y, random(-3, 3), random(-3, 3), 
              color(255, random(150, 255), 0), random(5, 15), 30));
  }
}

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
    return;
  }

  if (!countdownOver) return;

  // Player 1 controls
  if (key == 'w' || key == 'W') tank1.movingUp = true;
  if (key == 's' || key == 'S') tank1.movingDown = true;
  if (key == 'a' || key == 'A') tank1.movingLeft = true;
  if (key == 'd' || key == 'D') tank1.movingRight = true;
  if (key == ' ') tank1.fire();
  if (key == 'q' || key == 'Q') tank1.selectedWeapon = (tank1.selectedWeapon + 1) % 3;
  
  // Player 2 controls
  if (keyCode == UP) tank2.movingUp = true;
  if (keyCode == DOWN) tank2.movingDown = true;
  if (keyCode == LEFT) tank2.movingLeft = true;
  if (keyCode == RIGHT) tank2.movingRight = true;
  if (key == 'l' || key == 'L') tank2.fire();
  if (key == 'k' || key == 'K') tank2.selectedWeapon = (tank2.selectedWeapon + 1) % 3;
  
  // Direct weapon selection
  if (key == '1') tank1.selectedWeapon = 0;
  if (key == '2') tank1.selectedWeapon = 1;
  if (key == '3') tank1.selectedWeapon = 2;
  if (key == '8') tank2.selectedWeapon = 0;
  if (key == '9') tank2.selectedWeapon = 1;
  if (key == '0') tank2.selectedWeapon = 2;
}

void keyReleased() {
  // Player 1 controls
  if (key == 'w' || key == 'W') tank1.movingUp = false;
  if (key == 's' || key == 'S') tank1.movingDown = false;
  if (key == 'a' || key == 'A') tank1.movingLeft = false;
  if (key == 'd' || key == 'D') tank1.movingRight = false;
  
  // Player 2 controls
  if (keyCode == UP) tank2.movingUp = false;
  if (keyCode == DOWN) tank2.movingDown = false;
  if (keyCode == LEFT) tank2.movingLeft = false;
  if (keyCode == RIGHT) tank2.movingRight = false;
}

void handleTerrainSelection() {
  if (key == 'g' || key == 'G') {
    currentTerrain = "grassland";
    terrainSelected = true;
    barriers.add(new Barrier(300, height - 150, 50, 150, barrierGImg));
  } else if (key == 'd' || key == 'D') {
    currentTerrain = "desert";
    terrainSelected = true;
    barriers.add(new Barrier(300, height - 150, 50, 150, barrierDImg));
  } else if (key == 'i' || key == 'I') {
    currentTerrain = "ice";
    terrainSelected = true;
    barriers.add(new Barrier(300, height - 150, 50, 150, barrierIImg));
  }
}

void resetGame() {
  tank1 = new Tank(200, height - 100, color(255, 0, 0), true, tank1Img);
  tank2 = new Tank(800, height - 100, color(0, 0, 255), false, tank2Img);
  
  projectiles.clear();
  barriers.clear();
  powerUps.clear();
  particles.clear();
  
  spawnPowerUps();
  
  if (currentTerrain.equals("grassland")) {
    barriers.add(new Barrier(300, height - 150, 50, 150, barrierGImg));
  } else if (currentTerrain.equals("desert")) {
    barriers.add(new Barrier(300, height - 150, 50, 150, barrierDImg));
  } else if (currentTerrain.equals("ice")) {
    barriers.add(new Barrier(300, height - 150, 50, 150, barrierIImg));
  }
  
  gameOver = false;
  countdownStarted = false;
  countdownOver = false;
  countdownStartTime = millis();
}

void gameOver(String message) {
  gameOver = true;
  winnerMessage = message;
  
  // Display game over screen
  fill(0, 180);
  rect(0, 0, width, height);
  fill(255);
  textSize(50);
  textAlign(CENTER, CENTER);
  text(message, width/2, height/2);
  
  textSize(24);
  text("Press R to Restart", width/2, height/2 + 60);
}
