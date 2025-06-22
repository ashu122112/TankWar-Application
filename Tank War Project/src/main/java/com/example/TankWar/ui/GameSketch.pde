Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier> barriers = new ArrayList<Barrier>();
ArrayList<PowerUp> powerUps = new ArrayList<PowerUp>();

String currentTerrain = "";  // Terrain not selected initially
boolean terrainSelected = false;
boolean countdownStarted = false;
int countdownStartTime;
int countdownDuration = 4000; // 4 seconds (3, 2, 1, GO!)
boolean countdownOver = false;
PImage tank1Img, tank2Img, barrierGImg, barrierDImg, barrierIImg ,grasslandBg, desertBg, iceBg, bulletImg, missileImg, plasmaImg;

// Battlefield layout constants
final int battlefieldX = 150;
final int battlefieldY = 100;
final int battlefieldWidth = 700;
final int battlefieldHeight = 450;

void setup() {
  size(1000, 600);

  // Load images
  tank1Img = loadImage("tank_red.png");
  tank2Img = loadImage("tank_blue.png");
  barrierGImg = loadImage("barriergrass.png");
  barrierDImg = loadImage("dessertbarrier.png");
  barrierIImg = loadImage("icebarrier.png");
  grasslandBg = loadImage("terrain_grass.png");
  desertBg = loadImage("dessert.png");
  iceBg = loadImage("ice.png");
  bulletImg = loadImage("bullet.png");
  missileImg = loadImage("missile.png");
  plasmaImg = loadImage("plasma.png");

  tank1 = new Tank(100, height - 60, color(255, 0, 0), true, tank1Img);
  tank2 = new Tank(900, height - 60, color(0, 0, 255), false, tank2Img);

  powerUps.add(new PowerUp(300, 200, "health"));
  powerUps.add(new PowerUp(600, 300, "speed"));
  powerUps.add(new PowerUp(450, 250, "rapid"));
}

void drawControls() {
  textAlign(LEFT);
  textSize(12);

  float baseX = 10;
  float baseY = 120;
  float lineHeight = 16;

  text("Player 1 (Red):", baseX, baseY);
  text("Move: W A S D", baseX, baseY + lineHeight);
  text("Fire: SPACE", baseX, baseY + 2 * lineHeight);
  text("Switch Weapon: Q", baseX, baseY + 3 * lineHeight);
  text("Change Type:", baseX, baseY + 4 * lineHeight);
  text("1 - Bullet", baseX, baseY + 5 * lineHeight);
  text("2 - Missile", baseX, baseY + 6 * lineHeight);
  text("3 - Plasma", baseX, baseY + 7 * lineHeight);

  textAlign(RIGHT);
  float rightX = width - 10;

  text("Player 2 (Blue):", rightX, baseY);
  text("Move: Arrow Keys", rightX, baseY + lineHeight);
  text("Fire: L", rightX, baseY + 2 * lineHeight);
  text("Switch Weapon: K", rightX, baseY + 3 * lineHeight);
  text("Change Type:", rightX, baseY + 4 * lineHeight);
  text("8 - Bullet", rightX, baseY + 5 * lineHeight);
  text("9 - Missile", rightX, baseY + 6 * lineHeight);
  text("0 - Plasma", rightX, baseY + 7 * lineHeight);
}

void drawHealthBars() {
  float barWidth = 200;
  float barHeight = 15;

  fill(100);
  rect(10, 10, barWidth, barHeight);
  fill(0, 255, 0);
  float healthWidth1 = map(tank1.health, 0, 100, 0, barWidth);
  rect(10, 10, healthWidth1, barHeight);
  fill(0);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("P1 Health", 15, 10 + barHeight / 2);

  fill(100);
  rect(width - 10 - barWidth, 10, barWidth, barHeight);
  fill(0, 255, 0);
  float healthWidth2 = map(tank2.health, 0, 100, 0, barWidth);
  rect(width - 10 - barWidth, 10, healthWidth2, barHeight);
  fill(0);
  textAlign(RIGHT, CENTER);
  text("P2 Health", width - 15, 10 + barHeight / 2);
}

void displayTerrain() {
  background(180); // outer color

  if (currentTerrain.equals("grassland")) {
    image(grasslandBg, battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
    if (barriers.isEmpty()) {
      barriers.add(new Barrier(500, height - 100, 50, 150, barrierGImg));  // ✅ Grass barrier
    }
  } else if (currentTerrain.equals("desert")) {
    image(desertBg, battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
    if (barriers.isEmpty()) {
      barriers.add(new Barrier(500, height - 100, 50, 150, barrierDImg));  // ✅ Desert barrier
    }
  } else if (currentTerrain.equals("ice")) {
    image(iceBg, battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
    if (barriers.isEmpty()) {
      barriers.add(new Barrier(500, height - 100, 50, 150, barrierIImg));  // ✅ Ice barrier
    }
  }

  stroke(0);
  strokeWeight(4);
  rect(battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
  noStroke();
}



void draw() {
  background(180);

  if (!terrainSelected) {
    fill(0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Select Terrain to Start:", width / 2, height / 2 - 40);
    textSize(20);
    text("Press G for Grassland", width / 2, height / 2);
    text("Press D for Desert", width / 2, height / 2 + 30);
    text("Press I for Ice", width / 2, height / 2 + 60);
    return;
  }

  if (terrainSelected && !countdownStarted) {
    countdownStarted = true;
    countdownStartTime = millis();
  }

  if (countdownStarted && !countdownOver) {
    int timePassed = millis() - countdownStartTime;
    int secondsLeft = 3 - (timePassed / 1000);
    displayTerrain();
    fill(0, 180);
    rect(0, 0, width, height);
    fill(255);
    textSize(80);
    textAlign(CENTER, CENTER);

    if (secondsLeft >= 1) {
      text(secondsLeft, width / 2, height / 2);
    } else if (secondsLeft == 0) {
      text("GO!", width / 2, height / 2);
    } else {
      countdownOver = true;
    }
    return;
  }

  displayTerrain();

  for (Barrier b : barriers) b.display();

  tank1.update(barriers, tank2);
  tank2.update(barriers, tank1);

  tank1.display(false);
  tank2.display(false);

  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.update();
    p.display();
    if (!p.alive) {
      projectiles.remove(i);
    }
  }

  for (int i = barriers.size() - 1; i >= 0; i--) {
    if (barriers.get(i).isDestroyed()) {
      barriers.remove(i);
    }
  }

  if (tank1.health <= 0) {
    gameOver("Player 2 Wins!");
  } else if (tank2.health <= 0) {
    gameOver("Player 1 Wins!");
  }

  drawHealthBars();
  drawControls();

  for (PowerUp p : powerUps) {
    p.display();
    if (p.isCollectedBy(tank1)) applyPowerUp(tank1, p);
    if (p.isCollectedBy(tank2)) applyPowerUp(tank2, p);
  }
}

void applyPowerUp(Tank t, PowerUp p) {
  if (!p.active) return;

  if (p.type.equals("health")) {
    t.health = min(100, t.health + 30);
  } else if (p.type.equals("speed")) {
    t.speed = 4;
    t.tempSpeedTimer = millis();
  } else if (p.type.equals("rapid")) {
    t.tempRapidFire = true;
    t.tempRapidFireTimer = millis();
  }

  p.active = false;
}

void gameOver(String message) {
  fill(0);
  textSize(50);
  textAlign(CENTER, CENTER);
  text(message, width / 2, height / 2);
  noLoop();
}

void keyPressed() {
  if (!terrainSelected) {
    if (key == 'g') {
      currentTerrain = "grassland";
      terrainSelected = true;
    } else if (key == 'd') {
      currentTerrain = "desert";
      terrainSelected = true;
    } else if (key == 'i') {
      currentTerrain = "ice";
      terrainSelected = true;
    }
    return;
  }

  if (!countdownOver) return;

  tank1.handleKeyPressed(key, true);
  tank2.handleKeyPressed(key, true);
}

void keyReleased() {
  if (countdownOver) {
    tank1.handleKeyPressed(key, false);
    tank2.handleKeyPressed(key, false);
  }
}
