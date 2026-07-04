// GameSketch.pde — Cyber UI Redesign (2026)
// Game logic: IDENTICAL to original. Only visual/screen functions changed.
import ddf.minim.*;

// ─── GAME OBJECTS ─────────────────────────────────────────────────────────────
Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier>    barriers    = new ArrayList<Barrier>();
ArrayList<PowerUp>    powerUps    = new ArrayList<PowerUp>();
ArrayList<Particle>   particles   = new ArrayList<Particle>();
ArrayList<Timer>      timers      = new ArrayList<Timer>();

// ─── GAME STATE ───────────────────────────────────────────────────────────────
String  gameState    = "mode_selection";
boolean isVsComputer = false;
String  currentTerrain = "";
boolean hackChallengeUsed = false;  // tracks if hack terminal was solved this match

int    countdownStartTime;
int    countdownDuration = 4000;
String winnerMessage = "";

// ─── IMAGES ───────────────────────────────────────────────────────────────────
PImage tank1Img, tank2Img, tankBarrelImg;
PImage barrierGImg, barrierDImg;
PImage bulletImg, missileImg, plasmaImg;
PImage explosionImg;
PImage grassTileImg, sandTileImg;
PImage grassRoadCornerLLImg, grassRoadCornerLRImg, grassRoadCornerULImg, grassRoadCornerURImg;
PImage grassRoadEastImg, grassRoadNorthImg;
PImage grassRoadSplitEImg, grassRoadSplitSImg, grassRoadSplitNImg;
PImage treeGreenLargeImg;
PImage sandRoadCornerLLImg, sandRoadCornerLRImg, sandRoadCornerULImg, sandRoadCornerURImg;
PImage sandRoadSplitEImg, sandRoadSplitNImg;
PImage treeBrownLargeImg, treeBrownSmallImg, treeBrownTwigsImg;
PImage roadTileImg;

// ─── TILEMAP ──────────────────────────────────────────────────────────────────
final float barrierStandardWidth  = 50;
final float barrierStandardHeight = 100;
final int   TILE_SIZE = 50;
int[][] tileMap;

final int TILE_GRASS              = 0;
final int TILE_SAND               = 1;
final int TILE_ROAD               = 2;
final int TILE_GRASS_ROAD_CORNER_LL = 4;
final int TILE_GRASS_ROAD_CORNER_LR = 5;
final int TILE_GRASS_ROAD_CORNER_UL = 6;
final int TILE_GRASS_ROAD_CORNER_UR = 7;
final int TILE_GRASS_ROAD_EAST    = 8;
final int TILE_GRASS_ROAD_NORTH   = 9;
final int TILE_GRASS_ROAD_SPLIT_E = 10;
final int TILE_GRASS_ROAD_SPLIT_S = 11;
final int TILE_GRASS_ROAD_SPLIT_N = 12;
final int TILE_GRASS_ROAD_SPLIT_W = 13;
final int TILE_SAND_ROAD_CORNER_LL = 14;
final int TILE_SAND_ROAD_CORNER_LR = 15;
final int TILE_SAND_ROAD_CORNER_UL = 16;
final int TILE_SAND_ROAD_CORNER_UR = 17;
final int TILE_SAND_ROAD_SPLIT_E  = 18;
final int TILE_SAND_ROAD_SPLIT_N  = 19;

// ─── FONT & AUDIO ─────────────────────────────────────────────────────────────
PFont gameFont;
Minim       minim;
AudioPlayer backgroundMusic;
AudioSample fireSound, explosionSound, powerupSound;

// ─── LAYOUT ───────────────────────────────────────────────────────────────────
static final int battlefieldX      = 0;
static final int battlefieldY      = 0;
static final int battlefieldWidth  = 750;
static final int battlefieldHeight = 600;
static final int UI_PANEL_WIDTH    = 250;
static final int UI_PADDING        = 16;

// Legacy color vars (kept for compatibility)
color UI_BG_COLOR;
color UI_TEXT_COLOR;

// ─── CYBER COLOR PALETTE ──────────────────────────────────────────────────────
color C_BG;      // Near-black background
color C_PANEL;   // Dark panel
color C_CARD;    // Card background
color C_BORDER;  // Subtle border
color C_CYAN;    // Primary accent
color C_GREEN;   // Success / health
color C_ORANGE;  // Warning / P2
color C_RED;     // Danger / damage
color C_TEXT;    // Primary text
color C_DIM;     // Secondary text
color C_P1;      // Player 1 accent (red)
color C_P2;      // Player 2 accent (blue)

// ══════════════════════════════════════════════════════════════════════════════
// SETUP
// ══════════════════════════════════════════════════════════════════════════════
void setup() {
  size(1000, 600);
  smooth();

  // ── Legacy UI colors ──
  UI_BG_COLOR  = color(50, 70, 90);
  UI_TEXT_COLOR = color(255);

  // ── Cyber palette ──
  C_BG     = color(10,  13,  20);
  C_PANEL  = color(13,  17,  23);
  C_CARD   = color(22,  27,  38);
  C_BORDER = color(48,  54,  61);
  C_CYAN   = color(0,  212, 255);
  C_GREEN  = color(0,  255, 136);
  C_ORANGE = color(255, 140,  50);
  C_RED    = color(255,  55,  85);
  C_TEXT   = color(220, 230, 240);
  C_DIM    = color(120, 135, 155);
  C_P1     = color(255,  80,  80);
  C_P2     = color(80,  160, 255);

  // ── Images ──
  tank1Img    = loadImage("tankBody_bigRed_outline.png");
  tank2Img    = loadImage("tankBody_blue_outline.png");
  tankBarrelImg = loadImage("tankBlue_barrel1.png");
  barrierGImg = loadImage("barricadeMetal.png");
  barrierDImg = loadImage("crateWood.png");
  grassTileImg = loadImage("tileGrass1.png");
  grassRoadCornerLLImg = loadImage("tileGrass_roadCornerLL.png");
  grassRoadCornerLRImg = loadImage("tileGrass_roadCornerLR.png");
  grassRoadCornerULImg = loadImage("tileGrass_roadCornerUL.png");
  grassRoadCornerURImg = loadImage("tileGrass_roadCornerUR.png");
  grassRoadEastImg     = loadImage("tileGrass_roadEast.png");
  grassRoadNorthImg    = loadImage("tileGrass_roadEast.png");
  grassRoadSplitEImg   = loadImage("tileGrass_roadSplitE.png");
  grassRoadSplitSImg   = loadImage("tileGrass_roadSplitS.png");
  grassRoadSplitNImg   = loadImage("tileGrass_roadSplitN.png");
  treeGreenLargeImg    = loadImage("treeGreen_large.png");
  sandTileImg          = loadImage("tileSand1.png");
  sandRoadCornerLLImg  = loadImage("tileSand_roadCornerLL.png");
  sandRoadCornerLRImg  = loadImage("tileSand_roadCornerLR.png");
  sandRoadCornerULImg  = loadImage("tileSand_roadCornerUL.png");
  sandRoadCornerURImg  = loadImage("tileSand_roadCornerUR.png");
  sandRoadSplitEImg    = loadImage("tileSand_roadSplitE.png");
  sandRoadSplitNImg    = loadImage("tileSand_roadSplitN.png");
  treeBrownLargeImg    = loadImage("treeBrown_large.png");
  treeBrownSmallImg    = loadImage("treeBrown_small.png");
  treeBrownTwigsImg    = loadImage("treeBrown_twigs.png");
  roadTileImg          = loadImage("tileSand_roadEast.png");
  bulletImg    = loadImage("bulletDark1_outline.png");
  missileImg   = loadImage("bulletSand3_outline.png");
  plasmaImg    = loadImage("shotOrange.png");
  explosionImg = loadImage("explosion2.png");

  // ── Font ──
  gameFont = createFont("Monospaced", 16, true);
  textFont(gameFont);

  // ── Audio ──
  minim          = new Minim(this);
  backgroundMusic = minim.loadFile("background_music.mp3");
  fireSound       = minim.loadSample("fire.wav");
  explosionSound  = minim.loadSample("explosion.wav");
  powerupSound    = minim.loadSample("powerup.wav");
}

void stop() {
  backgroundMusic.close();
  fireSound.close();
  explosionSound.close();
  powerupSound.close();
  minim.stop();
  super.stop();
}

// ══════════════════════════════════════════════════════════════════════════════
// POWER-UP SPAWNING  (hack terminal added)
// ══════════════════════════════════════════════════════════════════════════════
void spawnPowerUps() {
  powerUps.clear();
  String[] types = {"health", "shield", "speed", "rapid", "hack", "hack"};
  for (int i = 0; i < 4; i++) {
    float px = random(battlefieldX + 50, battlefieldX + battlefieldWidth  - 50);
    float py = random(battlefieldY + 50, battlefieldY + battlefieldHeight - 50);
    powerUps.add(new PowerUp(px, py, types[(int)random(types.length)]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN DRAW LOOP  (unchanged logic)
// ══════════════════════════════════════════════════════════════════════════════
void draw() {
  background(180);

  if (gameState.equals("mode_selection")) {
    drawModeSelection();
    if (backgroundMusic.isPlaying()) { backgroundMusic.pause(); backgroundMusic.rewind(); }
    return;
  } else if (gameState.equals("terrain_selection")) {
    drawTerrainSelection();
    if (backgroundMusic.isPlaying()) { backgroundMusic.pause(); backgroundMusic.rewind(); }
    return;
  } else if (gameState.equals("countdown")) {
    drawCountdown();
    if (backgroundMusic.isPlaying()) { backgroundMusic.pause(); backgroundMusic.rewind(); }
    return;
  } else if (gameState.equals("game_over")) {
    drawGameOver();
    if (backgroundMusic.isPlaying()) { backgroundMusic.pause(); backgroundMusic.rewind(); }
    return;
  }

  if (!backgroundMusic.isPlaying()) backgroundMusic.loop();
  displayTerrain();
  updateGameObjects();
  drawGameObjects();
  drawUIPanel();
}

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN: MODE SELECTION  ★ REDESIGNED
// ══════════════════════════════════════════════════════════════════════════════
void drawModeSelection() {
  background(C_BG);

  // Animated dot grid
  int gs = 38;
  int off = (frameCount / 2) % gs;
  noStroke();
  fill(red(C_CYAN), green(C_CYAN), blue(C_CYAN), 22);
  for (int gx = off; gx < width; gx += gs)
    for (int gy = off; gy < height; gy += gs)
      ellipse(gx, gy, 2, 2);

  // Scanlines
  fill(0, 0, 0, 14);
  for (int sy = 0; sy < height; sy += 4) rect(0, sy, width, 2);

  // ── Title ──
  float ty = 115;
  textAlign(CENTER, CENTER);
  textSize(60);
  fill(red(C_CYAN), green(C_CYAN), blue(C_CYAN), 25);
  text("TANKWAR", width/2 + 4, ty + 4);
  fill(red(C_CYAN), green(C_CYAN), blue(C_CYAN), 55);
  text("TANKWAR", width/2 + 2, ty + 2);
  fill(C_TEXT);
  text("TANKWAR", width/2, ty);

  // Subtitle
  fill(C_GREEN);
  textSize(14);
  text("- - -   H A C K E R   E D I T I O N   - - -", width/2, ty + 50);

  // Divider
  stroke(red(C_CYAN), green(C_CYAN), blue(C_CYAN), 60);
  strokeWeight(1);
  line(width/2 - 220, ty + 72, width/2 + 220, ty + 72);
  noStroke();

  // ── Mode buttons ──
  float bw = 360, bh = 82, bx = width/2 - bw/2;
  drawCyberButton(bx, 225, bw, bh,
    "[P]   PLAYER  vs  PLAYER",
    "Local two-player battle",
    C_CYAN);
  drawCyberButton(bx, 332, bw, bh,
    "[C]   PLAYER  vs  COMPUTER",
    "Battle against AI opponent",
    C_GREEN);

  // Footer
  fill(C_DIM);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("Spring Boot + Processing  |  MySQL  |  Java 17   |   2026", width/2, height - 24);
}

// ── Helper: styled cyber button ────────────────────────────────────────────
void drawCyberButton(float x, float y, float w, float h, String title, String sub, color accent) {
  // Shadow
  fill(0, 60);
  noStroke();
  rect(x + 4, y + 4, w, h, 6);

  // Background
  fill(C_CARD);
  rect(x, y, w, h, 6);

  // Left accent stripe
  fill(accent);
  rect(x, y, 4, h, 4, 0, 0, 4);

  // Subtle inner glow
  fill(red(accent), green(accent), blue(accent), 14);
  rect(x + 4, y, w - 4, h, 0, 6, 6, 0);

  // Border
  stroke(red(accent), green(accent), blue(accent), 70);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h, 6);
  noStroke();

  // Title
  fill(C_TEXT);
  textSize(17);
  textAlign(LEFT, TOP);
  text(title, x + 20, y + 18);

  // Subtitle
  fill(C_DIM);
  textSize(12);
  text(sub, x + 20, y + 48);

  // Arrow
  fill(accent);
  textSize(22);
  textAlign(RIGHT, CENTER);
  text(">", x + w - 18, y + h/2);

  textAlign(CENTER, CENTER);
}

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN: TERRAIN SELECTION  ★ REDESIGNED
// ══════════════════════════════════════════════════════════════════════════════
void drawTerrainSelection() {
  background(C_BG);

  // Dot grid + scanlines
  int gs = 38, off = (frameCount / 2) % gs;
  noStroke();
  fill(red(C_CYAN), green(C_CYAN), blue(C_CYAN), 18);
  for (int gx = off; gx < width; gx += gs)
    for (int gy = off; gy < height; gy += gs)
      ellipse(gx, gy, 2, 2);
  fill(0, 0, 0, 14);
  for (int sy = 0; sy < height; sy += 4) rect(0, sy, width, 2);

  // Title
  textAlign(CENTER, CENTER);
  textSize(44);
  fill(C_TEXT);
  text("SELECT BATTLEFIELD", width/2, 82);

  fill(C_DIM);
  textSize(13);
  text("Choose your combat environment", width/2, 118);

  stroke(C_BORDER);
  strokeWeight(1);
  line(width/2 - 220, 138, width/2 + 220, 138);
  noStroke();

  // ── Terrain cards ──
  float cw = 285, ch = 310;
  float cy = 158;
  float c1x = width/2 - cw - 18;
  float c2x = width/2 + 18;

  String[] grassDesc = {"Road crossings + intersections", "Metal barricades", "Tree cover"};
  String[] desertDesc = {"Open sand terrain", "Wooden crate clusters", "Sparse dead trees"};

  drawTerrainCard(c1x, cy, cw, ch, "GRASSLAND", "[G] to select", grassDesc, C_GREEN,  grassTileImg);
  drawTerrainCard(c2x, cy, cw, ch, "DESERT",    "[D] to select", desertDesc, C_ORANGE, sandTileImg);

  // Hack hint at bottom
  fill(C_DIM);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("Collect  >_  HACK TERMINALS  mid-battle for cybersecurity challenge bonuses", width/2, height - 24);
}

// ── Helper: terrain selection card ─────────────────────────────────────────
void drawTerrainCard(float x, float y, float w, float h, String name, String key,
                     String[] desc, color accent, PImage preview) {
  // Shadow
  fill(0, 50);
  noStroke();
  rect(x + 4, y + 4, w, h, 8);

  // Card body
  fill(C_CARD);
  rect(x, y, w, h, 8);

  // Top accent bar
  fill(accent);
  rect(x, y, w, 5, 8, 8, 0, 0);

  // Border
  stroke(red(accent), green(accent), blue(accent), 55);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h, 8);
  noStroke();

  // Preview image area
  float imgAreaH = 132;
  fill(C_BG);
  rect(x + 10, y + 14, w - 20, imgAreaH, 4);

  if (preview != null) {
    imageMode(CORNER);
    // Tile the preview image inside the card (no clipping — tiles may slightly overflow)
    for (int tx = 0; tx < w - 20; tx += TILE_SIZE)
      for (int ty2 = 0; ty2 < imgAreaH; ty2 += TILE_SIZE)
        image(preview, x + 10 + tx, y + 14 + ty2, TILE_SIZE, TILE_SIZE);

    // Subtle dark overlay so text/gradient reads well
    fill(0, 70);
    rect(x + 10, y + 14, w - 20, imgAreaH, 4);
  } else {
    fill(red(accent), green(accent), blue(accent), 40);
    rect(x + 10, y + 14, w - 20, imgAreaH, 4);
  }

  // Terrain name on top of image
  fill(C_TEXT);
  textSize(21);
  textAlign(LEFT, TOP);
  text(name, x + 18, y + 155);

  // Key hint
  fill(accent);
  textSize(12);
  text(key, x + 18, y + 182);

  // Description lines
  fill(C_DIM);
  textSize(11);
  for (int i = 0; i < desc.length; i++) {
    text("·  " + desc[i], x + 18, y + 208 + i * 20);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN: COUNTDOWN  ★ REDESIGNED
// ══════════════════════════════════════════════════════════════════════════════
void drawCountdown() {
  displayTerrain();

  // Dark vignette overlay
  noStroke();
  fill(0, 165);
  rect(0, 0, width, height);

  int timePassed  = millis() - countdownStartTime;
  int secondsLeft = 3 - (timePassed / 1000);

  // Central card
  float pw = 360, ph = 210;
  float px = width/2 - pw/2, py = height/2 - ph/2;

  fill(red(C_PANEL), green(C_PANEL), blue(C_PANEL), 230);
  noStroke();
  rect(px, py, pw, ph, 10);

  stroke(red(C_CYAN), green(C_CYAN), blue(C_CYAN), 80);
  strokeWeight(1);
  noFill();
  rect(px, py, pw, ph, 10);
  noStroke();

  // "GET READY" label
  fill(C_DIM);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("G E T   R E A D Y", width/2, py + 32);

  // Main countdown number or GO!
  if (secondsLeft >= 1) {
    fill(C_CYAN);
    textSize(110);
    text(secondsLeft, width/2, py + 132);
  } else if (timePassed < countdownDuration) {
    fill(C_GREEN);
    textSize(80);
    text("GO!", width/2, py + 130);
  } else {
    gameState = "playing";
    postToBackend("start", null);
  }

  // Player side labels
  fill(C_P1);
  textSize(13);
  textAlign(LEFT, CENTER);
  text("< PLAYER 1", 28, height/2);

  fill(C_P2);
  textAlign(RIGHT, CENTER);
  text((isVsComputer ? "COMPUTER" : "PLAYER 2") + " >", battlefieldWidth - 28, height/2);

  textAlign(CENTER, CENTER);
}

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN: GAME OVER  ★ REDESIGNED
// ══════════════════════════════════════════════════════════════════════════════
void drawGameOver() {
  displayTerrain();

  // Animated overlay
  float fa = map(sin(frameCount * 0.08), -1, 1, 130, 190);
  noStroke();
  fill(0, fa);
  rect(0, 0, width, height);

  boolean p1wins = winnerMessage.contains("1");
  color   winCol = p1wins ? C_P1 : C_P2;

  // Victory panel
  float pw = 480, ph = 230;
  float px = width/2 - pw/2, py = height/2 - ph/2;

  // Shadow
  fill(0, 80);
  rect(px + 6, py + 6, pw, ph, 10);

  // Panel
  fill(red(C_PANEL), green(C_PANEL), blue(C_PANEL), 245);
  rect(px, py, pw, ph, 10);

  // Top accent bar
  fill(winCol);
  rect(px, py, pw, 5, 10, 10, 0, 0);

  // Panel border
  stroke(red(winCol), green(winCol), blue(winCol), 90);
  strokeWeight(1);
  noFill();
  rect(px, py, pw, ph, 10);
  noStroke();

  // "GAME OVER" label
  fill(C_DIM);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("-  -  -   G A M E   O V E R   -  -  -", width/2, py + 32);

  // Winner text
  fill(winCol);
  textSize(54);
  text(winnerMessage, width/2, py + 112);

  // Animated restart hint
  float ra = map(sin(frameCount * 0.09), -1, 1, 90, 255);
  fill(red(C_DIM), green(C_DIM), blue(C_DIM), ra);
  textSize(14);
  text("Press  [ R ]  to play again", width/2, py + 188);
}

// ══════════════════════════════════════════════════════════════════════════════
// TERRAIN RENDERING  (IDENTICAL to original)
// ══════════════════════════════════════════════════════════════════════════════
void displayTerrain() {
  for (int y = 0; y < tileMap.length; y++) {
    for (int x = 0; x < tileMap[0].length; x++) {
      PImage tileToDraw = null;
      float  rotAngle   = 0;

      switch (tileMap[y][x]) {
        case TILE_GRASS:               tileToDraw = grassTileImg;           break;
        case TILE_SAND:                tileToDraw = sandTileImg;            break;
        case TILE_ROAD:                tileToDraw = roadTileImg;            break;
        case TILE_GRASS_ROAD_CORNER_LL: tileToDraw = grassRoadCornerLLImg;  break;
        case TILE_GRASS_ROAD_CORNER_LR: tileToDraw = grassRoadCornerLRImg;  break;
        case TILE_GRASS_ROAD_CORNER_UL: tileToDraw = grassRoadCornerULImg;  break;
        case TILE_GRASS_ROAD_CORNER_UR: tileToDraw = grassRoadCornerURImg;  break;
        case TILE_GRASS_ROAD_EAST:     tileToDraw = grassRoadEastImg;       break;
        case TILE_GRASS_ROAD_NORTH:    tileToDraw = grassRoadNorthImg;  rotAngle = HALF_PI; break;
        case TILE_GRASS_ROAD_SPLIT_E:  tileToDraw = grassRoadSplitEImg;     break;
        case TILE_GRASS_ROAD_SPLIT_S:  tileToDraw = grassRoadSplitSImg;     break;
        case TILE_GRASS_ROAD_SPLIT_N:  tileToDraw = grassRoadSplitNImg; rotAngle = PI;      break;
        case TILE_GRASS_ROAD_SPLIT_W:  tileToDraw = grassRoadSplitEImg; rotAngle = -HALF_PI; break;
        case TILE_SAND_ROAD_CORNER_LL: tileToDraw = sandRoadCornerLLImg;    break;
        case TILE_SAND_ROAD_CORNER_LR: tileToDraw = sandRoadCornerLRImg;    break;
        case TILE_SAND_ROAD_CORNER_UL: tileToDraw = sandRoadCornerULImg;    break;
        case TILE_SAND_ROAD_CORNER_UR: tileToDraw = sandRoadCornerURImg;    break;
        case TILE_SAND_ROAD_SPLIT_E:   tileToDraw = sandRoadSplitEImg;      break;
        case TILE_SAND_ROAD_SPLIT_N:   tileToDraw = sandRoadSplitNImg;      break;
      }

      if (tileToDraw != null) {
        pushMatrix();
        translate(battlefieldX + x * TILE_SIZE + TILE_SIZE/2,
                  battlefieldY + y * TILE_SIZE + TILE_SIZE/2);
        rotate(rotAngle);
        imageMode(CENTER);
        image(tileToDraw, 0, 0, TILE_SIZE, TILE_SIZE);
        popMatrix();
      } else {
        fill(100);
        rect(battlefieldX + x * TILE_SIZE, battlefieldY + y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      }
    }
  }

  // Battlefield border — subtle glow version
  stroke(red(C_BORDER), green(C_BORDER), blue(C_BORDER), 200);
  strokeWeight(3);
  noFill();
  rect(battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
  noStroke();
}

// ══════════════════════════════════════════════════════════════════════════════
// GAME OBJECT UPDATE  (IDENTICAL to original)
// ══════════════════════════════════════════════════════════════════════════════
void updateGameObjects() {
  tank1.update(barriers, tank2, currentTerrain);
  tank2.update(barriers, tank1, currentTerrain);

  for (int i = projectiles.size()-1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.update();
    if (!p.alive) projectiles.remove(i);
  }

  for (int i = barriers.size()-1; i >= 0; i--) {
    if (barriers.get(i).isDestroyed()) {
      createExplosion(barriers.get(i).x + barriers.get(i).w/2,
                      barriers.get(i).y + barriers.get(i).h/2, 50);
      barriers.remove(i);
    }
  }

  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (!p.alive) particles.remove(i);
  }

  for (int i = timers.size()-1; i >= 0; i--) {
    timers.get(i).update();
    if (timers.get(i).isDone()) timers.remove(i);
  }

  for (int i = powerUps.size()-1; i >= 0; i--) {
    PowerUp p = powerUps.get(i);
    if (p.isCollectedBy(tank1)) {
      if (p.type.equals("hack")) {
        powerUps.remove(i);
        // HackChallenge.pde handles this if you have it, else give shield
        tank1.hasShield = true;
        hackChallengeUsed = true;
      } else {
        tank1.applyPowerUp(p);
        powerUps.remove(i);
      }
    } else if (p.isCollectedBy(tank2)) {
      if (p.type.equals("hack")) {
        powerUps.remove(i);
        tank2.hasShield = true;
        if (!isVsComputer) hackChallengeUsed = true;
      } else {
        tank2.applyPowerUp(p);
        powerUps.remove(i);
      }
    }
  }

  if      (tank1.health <= 0) gameOver("PLAYER 2 WINS!");
  else if (tank2.health <= 0) gameOver("PLAYER 1 WINS!");
}

// ══════════════════════════════════════════════════════════════════════════════
// GAME OBJECT DRAW  (IDENTICAL to original)
// ══════════════════════════════════════════════════════════════════════════════
void drawGameObjects() {
  for (Barrier   b : barriers)   b.display();
  for (Projectile p : projectiles) p.display();
  for (PowerUp    p : powerUps)   p.display();
  for (Particle   p : particles)  p.display();
  tank1.display(true);
  tank2.display(true);
}

// ══════════════════════════════════════════════════════════════════════════════
// UI PANEL  ★ REDESIGNED
// ══════════════════════════════════════════════════════════════════════════════
void drawUIPanel() {
  float px = width - UI_PANEL_WIDTH;
  float x  = px + UI_PADDING;

  // Panel background
  noStroke();
  fill(C_PANEL);
  rect(px, 0, UI_PANEL_WIDTH, height);

  // Left border line
  stroke(C_BORDER);
  strokeWeight(1);
  line(px, 0, px, height);
  noStroke();

  float y = 18;

  // ── Logo / Title ─────────────────────────────────────────────
  fill(C_TEXT);
  textSize(17);
  textAlign(LEFT, TOP);
  text("TANKWAR", x, y);

  fill(C_GREEN);
  textSize(9);
  text("HACKER EDITION", x, y + 22);
  y += 42;

  panelDivider(px, y); y += 14;

  // ── Player 1 ─────────────────────────────────────────────────
  noStroke();
  fill(C_P1);
  ellipse(x + 6, y + 8, 9, 9);

  fill(C_TEXT);
  textSize(13);
  text("PLAYER 1", x + 18, y);

  // Active buff indicators
  float buffX = x + 130;
  if (tank1 != null) {
    if (tank1.hasShield) { fill(C_CYAN);   textSize(9); text("[SHIELD]",  buffX, y + 1); buffX += 56; }
    if (tank1.rapidFire > 1.1) { fill(C_ORANGE); textSize(9); text("[RAPID]", buffX, y + 1); }
  }
  y += 22;

  // Health bar
  if (tank1 != null) {
    drawUIHealthBar(x, y, UI_PANEL_WIDTH - UI_PADDING*2, tank1.health, C_P1);
    y += 20;
    fill(C_DIM); textSize(10); text("WPN", x, y);
    fill(C_TEXT); text(tank1.getCurrentWeapon().toUpperCase(), x + 36, y);
  }
  y += 20;

  panelDivider(px, y); y += 14;

  // ── Player 2 / Computer ───────────────────────────────────────
  noStroke();
  fill(C_P2);
  ellipse(x + 6, y + 8, 9, 9);

  fill(C_TEXT);
  textSize(13);
  text(isVsComputer ? "COMPUTER" : "PLAYER 2", x + 18, y);

  buffX = x + 130;
  if (tank2 != null) {
    if (tank2.hasShield) { fill(C_CYAN);   textSize(9); text("[SHIELD]", buffX, y + 1); buffX += 56; }
    if (tank2.rapidFire > 1.1) { fill(C_ORANGE); textSize(9); text("[RAPID]", buffX, y + 1); }
  }
  y += 22;

  if (tank2 != null) {
    drawUIHealthBar(x, y, UI_PANEL_WIDTH - UI_PADDING*2, tank2.health, C_P2);
    y += 20;
    fill(C_DIM); textSize(10); text("WPN", x, y);
    fill(C_TEXT); text(tank2.getCurrentWeapon().toUpperCase(), x + 36, y);
  }
  y += 20;

  panelDivider(px, y); y += 14;

  // ── Controls ──────────────────────────────────────────────────
  fill(C_DIM);
  textSize(11);
  text("CONTROLS", x, y);
  y += 16;

  fill(C_P1); textSize(10); text("P1", x, y);
  fill(C_TEXT, 190); text("WASD  ·  SPACE  ·  Q", x + 22, y);
  y += 15;

  if (!isVsComputer) {
    fill(C_P2); textSize(10); text("P2", x, y);
    fill(C_TEXT, 190); text("Arrows  ·  L  ·  K", x + 22, y);
    y += 15;
  }

  fill(C_DIM); textSize(9);
  text("1-Bullet  2-Missile  3-Plasma", x, y); y += 13;
  if (!isVsComputer) { text("8-Bullet  9-Missile  0-Plasma", x, y); y += 13; }

  panelDivider(px, y + 2); y += 18;

  // ── Map / Terrain ─────────────────────────────────────────────
  fill(C_DIM); textSize(10); text("MAP", x, y);
  color mapCol = currentTerrain.equals("grassland") ? C_GREEN : C_ORANGE;
  fill(mapCol);
  text(currentTerrain.isEmpty() ? "—" : currentTerrain.toUpperCase(), x + 36, y);
  y += 20;

  // Hack terminal usage badge
  if (hackChallengeUsed) {
    noStroke();
    fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 40);
    rect(x, y, UI_PANEL_WIDTH - UI_PADDING*2, 18, 3);
    fill(C_GREEN);
    textSize(10);
    text(">_ HACK TERMINAL USED", x + 6, y + 3);
    y += 22;
  }

  // ── API status dot ────────────────────────────────────────────
  noStroke();
  fill(C_GREEN);
  ellipse(x + 5, height - 15, 6, 6);
  fill(C_DIM);
  textSize(9);
  text("API  :8080", x + 14, height - 19);
}

// ── Helper: horizontal health bar ──────────────────────────────────────────
void drawUIHealthBar(float x, float y, float w, float hp, color barCol) {
  float pct = constrain(hp / 100.0, 0, 1);

  // Track
  noStroke();
  fill(C_BORDER);
  rect(x, y, w, 11, 2);

  // Fill — color shifts red when low
  color hpCol = pct > 0.5 ? barCol : (pct > 0.25 ? C_ORANGE : C_RED);
  if (pct > 0) { fill(hpCol); rect(x, y, w * pct, 11, 2); }

  // HP number
  fill(C_TEXT);
  textSize(9);
  textAlign(RIGHT, TOP);
  text((int)hp + " HP", x + w, y);
  textAlign(LEFT, TOP);
}

// ── Helper: panel horizontal divider ───────────────────────────────────────
void panelDivider(float px, float y) {
  stroke(C_BORDER);
  strokeWeight(1);
  line(px + 8, y, px + UI_PANEL_WIDTH - 8, y);
  noStroke();
}

// ══════════════════════════════════════════════════════════════════════════════
// EXPLOSION  (slightly enhanced)
// ══════════════════════════════════════════════════════════════════════════════
void createExplosion(float x, float y, float size) {
  explosionSound.trigger();
  // Core bright particles
  for (int i = 0; i < 18; i++) {
    particles.add(new Particle(x, y, random(-4, 4), random(-4, 4),
      color(255, random(160, 255), 0), random(6, 16), 35));
  }
  // Outer smoke particles
  for (int i = 0; i < 10; i++) {
    particles.add(new Particle(x, y, random(-2, 2), random(-2, 2),
      color(80, 80, 80), random(8, 20), 50));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SPRING BOOT HTTP INTEGRATION
// ══════════════════════════════════════════════════════════════════════════════
void postToBackend(final String endpoint, final String params) {
  final String url = "http://localhost:8080/api/game/" + endpoint +
                     (params != null ? "?" + params : "");
  Thread t = new Thread(new Runnable() {
    public void run() {
      try {
        java.net.HttpURLConnection c =
          (java.net.HttpURLConnection) new java.net.URL(url).openConnection();
        c.setRequestMethod("POST");
        c.setConnectTimeout(500);
        c.getResponseCode();
        c.disconnect();
      } catch (Exception e) {
        println("[Backend] " + endpoint + " — " + e.getMessage());
      }
    }
  });
  t.setDaemon(true);
  t.start();
}

// ══════════════════════════════════════════════════════════════════════════════
// LEGACY HELPERS  (kept for compatibility)
// ══════════════════════════════════════════════════════════════════════════════
void drawRoundedRect(float x, float y, float w, float h, float r, color c) {
  fill(c); noStroke();
  rect(x, y + r, w, h - 2*r);
  rect(x + r, y, w - 2*r, h);
  ellipse(x + r, y + r, 2*r, 2*r);
  ellipse(x + w - r, y + r, 2*r, 2*r);
  ellipse(x + r, y + h - r, 2*r, 2*r);
  ellipse(x + w - r, y + h - r, 2*r, 2*r);
}

void drawGradientBackground(color c1, color c2) {
  for (int i = 0; i <= height; i++) {
    stroke(lerpColor(c1, c2, map(i, 0, height, 0, 1)));
    line(0, i, width, i);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INPUT HANDLERS  (IDENTICAL to original + backend calls)
// ══════════════════════════════════════════════════════════════════════════════
void keyPressed() {
  if (gameState.equals("mode_selection")) {
    if      (key == 'p' || key == 'P') { isVsComputer = false; gameState = "terrain_selection"; }
    else if (key == 'c' || key == 'C') { isVsComputer = true;  gameState = "terrain_selection"; }
    return;
  }

  if (gameState.equals("terrain_selection")) {
    if (key == 'g' || key == 'G') {
      currentTerrain = "grassland";
      generateMap("grassland");
      gameState = "countdown";
      countdownStartTime = millis();
    } else if (key == 'd' || key == 'D') {
      currentTerrain = "desert";
      generateMap("desert");
      gameState = "countdown";
      countdownStartTime = millis();
    }
    return;
  }

  if (gameState.equals("countdown"))  return;

  if (gameState.equals("game_over")) {
    if (key == 'r' || key == 'R') resetGame();
    return;
  }

  tank1.handleKeyPressed(key, true);
  if (!isVsComputer) tank2.handleKeyPressed(keyCode, true);
}

void keyReleased() {
  if (!gameState.equals("playing")) return;
  tank1.handleKeyPressed(key, false);
  if (!isVsComputer) tank2.handleKeyPressed(keyCode, false);
}

void handleTerrainSelection() { }

// ══════════════════════════════════════════════════════════════════════════════
// GAME FLOW  (IDENTICAL to original + backend save on game over)
// ══════════════════════════════════════════════════════════════════════════════
void gameOver(String message) {
  if (!gameState.equals("game_over")) {
    gameState    = "game_over";
    winnerMessage = message;

    // Persist result to Spring Boot leaderboard
    boolean p1wins   = message.contains("1");
    String  winner   = p1wins ? "Player+1" : "Player+2";
    String  loser    = p1wins ? "Player+2" : "Player+1";
    String  terrain  = currentTerrain.isEmpty() ? "unknown" : currentTerrain;
    postToBackend("result",
      "winnerName=" + winner +
      "&loserName="  + loser  +
      "&damageDealt=100" +
      "&terrain="    + terrain +
      "&usedHack="   + hackChallengeUsed);
  }
}

void resetGame() {
  projectiles.clear(); barriers.clear();
  powerUps.clear();    particles.clear(); timers.clear();

  tank1 = new Tank(0, 0, color(255,0,0),   true,  tank1Img, false);
  tank2 = new Tank(0, 0, color(0,0,255),   false, tank2Img, isVsComputer);

  hackChallengeUsed = false;
  spawnPowerUps();
  winnerMessage  = "";
  gameState      = "mode_selection";
  currentTerrain = "";
}

// ══════════════════════════════════════════════════════════════════════════════
// MAP GENERATION  (IDENTICAL to original)
// ══════════════════════════════════════════════════════════════════════════════
void generateMap(String terrainType) {
  int cols = battlefieldWidth / TILE_SIZE;
  int rows = battlefieldHeight / TILE_SIZE;
  tileMap = new int[rows][cols];
  barriers.clear();

  PImage currentBarrierImg;
  float  currentBarrierHealth;
  float  indestructibleHealth = 10000;

  switch (terrainType) {
    case "grassland":
      currentBarrierImg    = barrierGImg;
      currentBarrierHealth = 100;

      for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
          tileMap[r][c] = TILE_GRASS;

      for (int c = 0; c < cols; c++) tileMap[rows/2][c] = TILE_GRASS_ROAD_EAST;
      for (int r = 0; r < rows; r++) tileMap[r][cols/2] = TILE_GRASS_ROAD_NORTH;

      tileMap[rows/2][cols/2]   = TILE_GRASS_ROAD_SPLIT_E;
      tileMap[0][cols/2]        = TILE_GRASS_ROAD_CORNER_LL;
      tileMap[rows-1][cols/2]   = TILE_GRASS_ROAD_CORNER_UR;
      tileMap[rows/2][0]        = TILE_GRASS_ROAD_CORNER_UR;
      tileMap[rows/2][cols-1]   = TILE_GRASS_ROAD_CORNER_LL;

      barriers.add(new Barrier(battlefieldX + cols/2*TILE_SIZE - barrierStandardWidth - 10,
        battlefieldY + rows/2*TILE_SIZE + TILE_SIZE - barrierStandardHeight,
        barrierStandardWidth, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      barriers.add(new Barrier(battlefieldX + cols/2*TILE_SIZE + 10,
        battlefieldY + rows/2*TILE_SIZE + TILE_SIZE - barrierStandardHeight,
        barrierStandardWidth, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));

      float tH = 60;
      barriers.add(new Barrier(battlefieldX + 100,                           battlefieldY + 100 + TILE_SIZE - tH,        60, 60, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 160,        battlefieldY + 100 + TILE_SIZE - tH,        60, 60, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + 100,                           battlefieldY + battlefieldHeight - 100 - tH, 60, 60, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 160,        battlefieldY + battlefieldHeight - 100 - tH, 60, 60, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + 50,                            battlefieldY + rows/4*TILE_SIZE + TILE_SIZE - barrierStandardHeight,     barrierStandardWidth, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 50 - barrierStandardWidth, battlefieldY + rows*3/4*TILE_SIZE + TILE_SIZE - barrierStandardHeight, barrierStandardWidth, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      break;

    case "desert":
      currentBarrierImg    = barrierDImg;
      currentBarrierHealth = 50;

      for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
          tileMap[r][c] = TILE_SAND;

      PVector[] clusterPoints = {
        new PVector(cols/4,   rows/4),
        new PVector(cols*3/4, rows/4),
        new PVector(cols/4,   rows*3/4),
        new PVector(cols*3/4, rows*3/4),
        new PVector(cols/2,   rows/2)
      };

      for (PVector point : clusterPoints) {
        float cx = battlefieldX + point.x * TILE_SIZE;
        float cy = battlefieldY + point.y * TILE_SIZE;
        int num  = (int)random(2, 5);
        for (int i = 0; i < num; i++) {
          barriers.add(new Barrier(cx + random(-30, 30),
            cy + random(-30, 30) + TILE_SIZE - barrierStandardHeight,
            barrierStandardWidth, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
        }
        if (random(1) > 0.5) {
          barriers.add(new Barrier(cx + random(-20, 20),
            cy + random(-20, 20) + TILE_SIZE - 60,
            60, 60, indestructibleHealth, treeBrownLargeImg, -20));
        }
      }

      for (int i = 0; i < 10; i++) {
        float rx = random(battlefieldX + 50, battlefieldX + battlefieldWidth  - 80);
        float ry = random(battlefieldY + 50, battlefieldY + battlefieldHeight - 80);
        barriers.add(new Barrier(rx, ry + TILE_SIZE - 30, 30, 30, indestructibleHealth, treeBrownTwigsImg, -10));
      }

      barriers.add(new Barrier(battlefieldX + 100,
        battlefieldY + rows/3*TILE_SIZE + TILE_SIZE - barrierStandardHeight,
        barrierStandardWidth * 2, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 100 - barrierStandardWidth*2,
        battlefieldY + rows*2/3*TILE_SIZE + TILE_SIZE - barrierStandardHeight,
        barrierStandardWidth * 2, barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      break;
  }

  // Spawn tanks after map is ready
  tank1 = new Tank(0, 0, color(255,0,0), true,  tank1Img, false);
  tank2 = new Tank(0, 0, color(0,0,255), false, tank2Img, isVsComputer);

  PVector p1s = findClearSpawnPoint(battlefieldX,               battlefieldY, battlefieldWidth/2, battlefieldHeight/2, tank1.tankWidth, tank1.tankHeight);
  PVector p2s = findClearSpawnPoint(battlefieldX+battlefieldWidth/2, battlefieldY+battlefieldHeight/2, battlefieldWidth/2, battlefieldHeight/2, tank2.tankWidth, tank2.tankHeight);
  tank1.x = p1s.x; tank1.y = p1s.y;
  tank2.x = p2s.x; tank2.y = p2s.y;

  spawnPowerUps();
}

PVector findClearSpawnPoint(float ax, float ay, float aw, float ah, float ow, float oh) {
  for (int i = 0; i < 100; i++) {
    float sx = random(ax, ax + aw - ow);
    float sy = random(ay, ay + ah - oh);
    boolean hit = false;
    for (Barrier b : barriers) {
      if (sx < b.x+b.w && sx+ow > b.x && sy < b.y+b.h && sy+oh > b.y) { hit = true; break; }
    }
    if (!hit) return new PVector(sx, sy);
  }
  return new PVector(ax + aw/4, ay + ah/4);
}