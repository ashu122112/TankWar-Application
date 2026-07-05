// ═══════════════════════════════════════════════════════════════
//  TANKWAR ARENA — HACKER EDITION
//  GameSketch.pde  |  Unified Cyber Design 2026
//  Game logic: identical to original
//  Visual: completely redesigned
// ═══════════════════════════════════════════════════════════════
import ddf.minim.*;
import java.net.HttpURLConnection;
import java.net.URL;

// ─── GAME OBJECTS ─────────────────────────────────────────────
Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier>    barriers    = new ArrayList<Barrier>();
ArrayList<PowerUp>    powerUps    = new ArrayList<PowerUp>();
ArrayList<Particle>   particles   = new ArrayList<Particle>();
ArrayList<Timer>      timers      = new ArrayList<Timer>();

// ─── GAME STATE ───────────────────────────────────────────────
// States: welcome | mode_selection | terrain_selection |
//         countdown | playing | hacking | game_over | leaderboard
String  gameState    = "welcome";
boolean isVsComputer = false;
String  currentTerrain = "";
boolean hackChallengeUsed = false;

int    countdownStartTime;
int    countdownDuration = 4000;
String winnerMessage = "";

// ─── IMAGES ───────────────────────────────────────────────────
PImage tank1Img, tank2Img, tankBarrelImg;
PImage barrierGImg, barrierDImg;
PImage bulletImg, missileImg, plasmaImg, explosionImg;
PImage grassTileImg, sandTileImg;
PImage grassRoadCornerLLImg, grassRoadCornerLRImg;
PImage grassRoadCornerULImg, grassRoadCornerURImg;
PImage grassRoadEastImg, grassRoadNorthImg;
PImage grassRoadSplitEImg, grassRoadSplitSImg, grassRoadSplitNImg;
PImage treeGreenLargeImg;
PImage sandRoadCornerLLImg, sandRoadCornerLRImg;
PImage sandRoadCornerULImg, sandRoadCornerURImg;
PImage sandRoadSplitEImg, sandRoadSplitNImg;
PImage treeBrownLargeImg, treeBrownSmallImg, treeBrownTwigsImg;
PImage roadTileImg;

// ─── TILE CONSTANTS ───────────────────────────────────────────
final float barrierStandardWidth  = 50;
final float barrierStandardHeight = 100;
final int   TILE_SIZE = 50;
int[][] tileMap;

final int TILE_GRASS = 0, TILE_SAND = 1, TILE_ROAD = 2;
final int TILE_GRASS_ROAD_CORNER_LL = 4, TILE_GRASS_ROAD_CORNER_LR = 5;
final int TILE_GRASS_ROAD_CORNER_UL = 6, TILE_GRASS_ROAD_CORNER_UR = 7;
final int TILE_GRASS_ROAD_EAST = 8,  TILE_GRASS_ROAD_NORTH = 9;
final int TILE_GRASS_ROAD_SPLIT_E = 10, TILE_GRASS_ROAD_SPLIT_S = 11;
final int TILE_GRASS_ROAD_SPLIT_N = 12, TILE_GRASS_ROAD_SPLIT_W = 13;
final int TILE_SAND_ROAD_CORNER_LL = 14, TILE_SAND_ROAD_CORNER_LR = 15;
final int TILE_SAND_ROAD_CORNER_UL = 16, TILE_SAND_ROAD_CORNER_UR = 17;
final int TILE_SAND_ROAD_SPLIT_E = 18, TILE_SAND_ROAD_SPLIT_N = 19;

// ─── AUDIO / FONT ─────────────────────────────────────────────
PFont   gameFont;
Minim   minim;
AudioPlayer backgroundMusic;
AudioSample fireSound, explosionSound, powerupSound;

// ─── LAYOUT ───────────────────────────────────────────────────
static final int battlefieldX = 0, battlefieldY = 0;
static final int battlefieldWidth = 750, battlefieldHeight = 600;
static final int UI_PANEL_WIDTH = 250, UI_PADDING = 16;

// Legacy vars kept for compatibility
color UI_BG_COLOR, UI_TEXT_COLOR;

// ─── CYBER COLOR PALETTE ──────────────────────────────────────
color C_BG, C_PANEL, C_CARD, C_BORDER;
color C_GREEN, C_CYAN, C_ORANGE, C_RED, C_YELLOW;
color C_TEXT, C_DIM, C_P1, C_P2;

// ═══════════════════════════════════════════════════════════════
//  SETUP
// ═══════════════════════════════════════════════════════════════
void setup() {
  size(1000, 600);
  smooth();

  // Legacy colors
  UI_BG_COLOR  = color(50, 70, 90);
  UI_TEXT_COLOR = color(255);

  // Cyber palette
  C_BG     = color(8,  11,  18);
  C_PANEL  = color(12, 16,  24);
  C_CARD   = color(18, 24,  35);
  C_BORDER = color(35, 48,  65);
  C_GREEN  = color(0,  255, 100);
  C_CYAN   = color(0,  200, 255);
  C_ORANGE = color(255,140,  40);
  C_RED    = color(255, 50,  80);
  C_YELLOW = color(255,220,   0);
  C_TEXT   = color(210,228, 245);
  C_DIM    = color(90, 110, 135);
  C_P1     = color(255, 70,  70);
  C_P2     = color(70, 150, 255);

  // Images
  tank1Img    = loadImage("tankBody_bigRed_outline.png");
  tank2Img    = loadImage("tankBody_blue_outline.png");
  tankBarrelImg = loadImage("tankBlue_barrel1.png");
  barrierGImg = loadImage("barricadeMetal.png");
  barrierDImg = loadImage("crateWood.png");
  grassTileImg         = loadImage("tileGrass1.png");
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

  gameFont = createFont("Monospaced", 16, true);
  textFont(gameFont);

  minim          = new Minim(this);
  backgroundMusic = minim.loadFile("background_music.mp3");
  fireSound       = minim.loadSample("fire.wav");
  explosionSound  = minim.loadSample("explosion.wav");
  powerupSound    = minim.loadSample("powerup.wav");

  // Load leaderboard from disk
  loadLeaderboard();
}

void stop() {
  backgroundMusic.close();
  fireSound.close();
  explosionSound.close();
  powerupSound.close();
  minim.stop();
  super.stop();
}

// ═══════════════════════════════════════════════════════════════
//  POWER-UP SPAWNING
// ═══════════════════════════════════════════════════════════════
void spawnPowerUps() {
  powerUps.clear();
  String[] types = {"health","shield","speed","rapid","hack","hack"};
  for (int i = 0; i < 4; i++) {
    float px = random(battlefieldX + 60, battlefieldX + battlefieldWidth  - 60);
    float py = random(battlefieldY + 60, battlefieldY + battlefieldHeight - 60);
    powerUps.add(new PowerUp(px, py, types[(int)random(types.length)]));
  }
}

// ═══════════════════════════════════════════════════════════════
//  MAIN DRAW LOOP
// ═══════════════════════════════════════════════════════════════
void draw() {
  background(C_BG);

  if (backgroundMusic.isPlaying() && !gameState.equals("playing")) {
    backgroundMusic.pause();
    backgroundMusic.rewind();
  }

  switch(gameState) {
    case "welcome":          drawWelcome();         return;
    case "mode_selection":   drawModeSelection();   return;
    case "terrain_selection":drawTerrainSelection();return;
    case "countdown":        drawCountdown();       return;
    case "game_over":        drawGameOver();        return;
    case "leaderboard":      drawLeaderboard();     return;
    case "hacking":
      displayTerrain();
      drawGameObjects();
      drawHackChallenge();
      drawUIPanel();
      return;
  }

  // playing
  if (!backgroundMusic.isPlaying()) backgroundMusic.loop();
  displayTerrain();
  updateGameObjects();
  drawGameObjects();
  drawUIPanel();
}

// ═══════════════════════════════════════════════════════════════
//  CIRCUIT BOARD BACKGROUND  (shared by all menu screens)
// ═══════════════════════════════════════════════════════════════
void drawCircuitBg() {
  // Grid
  int gs = 50;
  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 9);
  strokeWeight(1);
  for (int x = 0; x < width; x += gs)  line(x, 0, x, height);
  for (int y = 0; y < height; y += gs) line(0, y, width, y);

  // Grid nodes
  noStroke();
  fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 22);
  for (int x = 0; x < width; x += gs)
    for (int y = 0; y < height; y += gs)
      ellipse(x, y, 3, 3);

  // Animated horizontal scan line
  float scanY = (frameCount * 1.5) % height;
  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 18);
  strokeWeight(1);
  line(0, scanY, width, scanY);

  // Scanlines overlay
  noStroke();
  fill(0, 0, 0, 20);
  for (int y = 0; y < height; y += 3) rect(0, y, width, 1);

  // Corner brackets
  drawBracket(30,        30,        50, 50, C_GREEN, 70);
  drawBracket(width-80,  30,        50, 50, C_GREEN, 70);
  drawBracket(30,        height-80, 50, 50, C_GREEN, 70);
  drawBracket(width-80,  height-80, 50, 50, C_GREEN, 70);

  noStroke();
}

void drawBracket(float x, float y, float w, float h, color c, int a) {
  stroke(red(c), green(c), blue(c), a);
  strokeWeight(2);
  noFill();
  float l = min(w, h) * 0.35;
  // top-left
  line(x, y+l, x, y); line(x, y, x+l, y);
  // top-right
  line(x+w-l, y, x+w, y); line(x+w, y, x+w, y+l);
  // bottom-left
  line(x, y+h-l, x, y+h); line(x, y+h, x+l, y+h);
  // bottom-right
  line(x+w-l, y+h, x+w, y+h); line(x+w, y+h, x+w, y+h-l);
  noStroke();
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN: WELCOME  ★ NEW
// ═══════════════════════════════════════════════════════════════
void drawWelcome() {
  background(C_BG);
  drawCircuitBg();

  float cy = height * 0.38;
  textAlign(CENTER, CENTER);

  // Glow title
  String title = "TANKWAR ARENA";
  textSize(66);
  fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 15); text(title, width/2+6, cy+6);
  fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 30); text(title, width/2+3, cy+3);
  fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 55); text(title, width/2+1, cy+1);
  fill(C_TEXT);                                          text(title, width/2,   cy);

  // Flanking lines
  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 80);
  strokeWeight(1);
  line(60, cy+50, width/2-200, cy+50);
  line(width/2+200, cy+50, width-60, cy+50);
  noStroke();

  // Subtitle
  fill(C_GREEN);
  textSize(14);
  text("[ H A C K E R   E D I T I O N ]", width/2, cy+70);

  // Tagline
  fill(C_DIM);
  textSize(12);
  text("Cybersecurity meets Combat  —  Solve hacks, gain power, dominate the arena", width/2, cy+100);

  // Feature pills
  float pillY = cy + 148;
  drawPill(width/2 - 310, pillY, ">_  SQL INJECTION",  C_GREEN);
  drawPill(width/2 - 110, pillY, "XSS  ATTACKS",       C_CYAN);
  drawPill(width/2 +  70, pillY, "CIPHER  BREAKING",   C_ORANGE);
  drawPill(width/2 + 240, pillY, "BASE64  DECODE",     C_YELLOW);

  // Blinking any-key
  float blink = sin(frameCount * 0.07);
  if (blink > 0) {
    fill(red(C_TEXT), green(C_TEXT), blue(C_TEXT), map(blink, 0,1,80,255));
    textSize(15);
    text("PRESS  ANY  KEY  TO  ENTER  THE  ARENA", width/2, height*0.74);
  }

  // Bottom bar
  fill(C_PANEL);
  noStroke();
  rect(0, height-36, width, 36);
  stroke(C_BORDER);
  strokeWeight(1);
  line(0, height-36, width, height-36);
  noStroke();

  fill(C_DIM);
  textSize(10);
  textAlign(LEFT, CENTER);
  text("Spring Boot 3.3  ·  Processing 3  ·  MySQL 8  ·  Java 17", 24, height-18);

  textAlign(RIGHT, CENTER);
  fill(C_GREEN);
  text("API :8080  LIVE", width-24, height-18);

  textAlign(CENTER, CENTER);
}

void drawPill(float x, float y, String label, color c) {
  float pw = textWidth(label) + 24, ph = 26;
  fill(red(c), green(c), blue(c), 18);
  noStroke();
  rect(x, y - ph/2, pw, ph, ph/2);
  stroke(red(c), green(c), blue(c), 80);
  strokeWeight(1);
  noFill();
  rect(x, y - ph/2, pw, ph, ph/2);
  noStroke();
  fill(c);
  textSize(11);
  textAlign(LEFT, CENTER);
  text(label, x + 12, y);
  textAlign(CENTER, CENTER);
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN: MODE SELECTION  ★ REDESIGNED
// ═══════════════════════════════════════════════════════════════
void drawModeSelection() {
  background(C_BG);
  drawCircuitBg();

  textAlign(CENTER, CENTER);
  fill(C_GREEN);
  textSize(11);
  text("[ SELECT PROTOCOL ]", width/2, 52);

  fill(C_TEXT);
  textSize(34);
  text("CHOOSE YOUR OPPONENT", width/2, 92);

  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 55);
  strokeWeight(1);
  line(width/2-260, 116, width/2+260, 116);
  noStroke();

  // Mode cards  — side by side
  float cw = 350, ch = 105;
  float cy = 160;
  drawModeCard(width/2 - cw - 16, cy, cw, ch,
    "P", "PLAYER  vs  PLAYER",
    "Two human players — local co-op battle",
    C_CYAN);
  drawModeCard(width/2 + 16, cy, cw, ch,
    "C", "PLAYER  vs  COMPUTER",
    "Battle the AI — tactical state-machine enemy",
    C_GREEN);

  // Hack terminal info banner
  float bw = 720, bh = 88, bx = width/2 - bw/2, by = 300;
  fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 10);
  noStroke();
  rect(bx, by, bw, bh, 6);
  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 45);
  strokeWeight(1);
  noFill();
  rect(bx, by, bw, bh, 6);
  noStroke();

  fill(C_GREEN);
  textSize(12);
  textAlign(LEFT, TOP);
  text(">_  HACK TERMINAL SYSTEM", bx+18, by+14);

  fill(C_DIM);
  textSize(11);
  text("Collect glowing  >_  power-ups on the battlefield to trigger real cybersecurity challenges.", bx+18, by+36);
  text("Solve them correctly for powerful combat buffs — missiles, shields, rapid fire & more.", bx+18, by+54);

  // Bottom hints
  fill(C_DIM);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("[ B ]  View Leaderboard   ·   [ ESC ]  Quit", width/2, height - 28);
}

void drawModeCard(float x, float y, float w, float h, String key, String title, String sub, color accent) {
  // shadow
  fill(0, 50); noStroke(); rect(x+4, y+4, w, h, 6);
  // body
  fill(C_CARD); rect(x, y, w, h, 6);
  // left stripe
  fill(accent); rect(x, y, 4, h, 4,0,0,4);
  // inner glow
  fill(red(accent), green(accent), blue(accent), 12);
  rect(x+4, y, w-4, h, 0,6,6,0);
  // border
  stroke(red(accent), green(accent), blue(accent), 65);
  strokeWeight(1); noFill(); rect(x, y, w, h, 6); noStroke();

  // Key badge
  fill(accent);
  textSize(18); textAlign(LEFT, TOP);
  text("[" + key + "]", x+18, y+14);

  // Title
  fill(C_TEXT); textSize(16);
  text(title, x+18, y+42);

  // Subtitle
  fill(C_DIM); textSize(11);
  text(sub, x+18, y+68);

  // Arrow
  fill(accent); textSize(20); textAlign(RIGHT, CENTER);
  text(">", x+w-16, y+h/2);

  textAlign(CENTER, CENTER);
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN: TERRAIN SELECTION  ★ REDESIGNED
// ═══════════════════════════════════════════════════════════════
void drawTerrainSelection() {
  background(C_BG);
  drawCircuitBg();

  textAlign(CENTER, CENTER);
  fill(C_GREEN); textSize(11);
  text("[ SELECT BATTLEFIELD ]", width/2, 52);

  fill(C_TEXT); textSize(34);
  text("CHOOSE YOUR MAP", width/2, 92);

  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 55);
  strokeWeight(1);
  line(width/2-200, 116, width/2+200, 116);
  noStroke();

  float cw = 290, ch = 330, cy = 140;
  float c1x = width/2 - cw - 16, c2x = width/2 + 16;

  String[] gDesc = {"Central road crossings","Metal barricades","Tree cover & sightlines"};
  String[] dDesc = {"Open sand dunes","Wooden crate clusters","Sparse dead trees"};

  drawTerrainCard(c1x, cy, cw, ch, "GRASSLAND", "G", gDesc, C_GREEN,  grassTileImg);
  drawTerrainCard(c2x, cy, cw, ch, "DESERT",    "D", dDesc, C_ORANGE, sandTileImg);

  fill(C_DIM); textSize(10);
  textAlign(CENTER, CENTER);
  text("[ B ]  Back   ·   Hack terminals will spawn on both maps", width/2, height - 28);
}

void drawTerrainCard(float x, float y, float w, float h, String name, String key,
                     String[] desc, color accent, PImage preview) {
  fill(0, 50); noStroke(); rect(x+4, y+4, w, h, 8);
  fill(C_CARD); noStroke(); rect(x, y, w, h, 8);
  fill(accent); rect(x, y, w, 5, 8,8,0,0);
  stroke(red(accent), green(accent), blue(accent), 50);
  strokeWeight(1); noFill(); rect(x, y, w, h, 8); noStroke();

  // Preview area
  float imgH = 140;
  fill(C_BG); noStroke(); rect(x+10, y+14, w-20, imgH, 4);
  if (preview != null) {
    imageMode(CORNER);
    for (int tx = 0; tx < (int)(w-20); tx += TILE_SIZE)
      for (int ty = 0; ty < (int)imgH; ty += TILE_SIZE)
        image(preview, x+10+tx, y+14+ty, TILE_SIZE, TILE_SIZE);
    fill(0, 75); noStroke(); rect(x+10, y+14, w-20, imgH, 4);
  }

  // Name
  fill(C_TEXT); textSize(20); textAlign(LEFT, TOP);
  text(name, x+16, y+164);

  // Key hint
  fill(accent); textSize(13);
  text("Press  [ " + key + " ]  to select", x+16, y+192);

  // Description
  fill(C_DIM); textSize(11);
  for (int i = 0; i < desc.length; i++)
    text("·  " + desc[i], x+16, y+220 + i*22);
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN: COUNTDOWN  ★ REDESIGNED
// ═══════════════════════════════════════════════════════════════
void drawCountdown() {
  displayTerrain();

  // Overlay
  fill(0, 170); noStroke(); rect(0, 0, width, height);

  int timePassed  = millis() - countdownStartTime;
  int secondsLeft = 3 - (timePassed / 1000);

  // Central panel
  float pw = 360, ph = 220;
  float px = width/2 - pw/2, py = height/2 - ph/2;

  fill(red(C_PANEL), green(C_PANEL), blue(C_PANEL), 235);
  noStroke(); rect(px, py, pw, ph, 10);
  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 70);
  strokeWeight(1); noFill(); rect(px, py, pw, ph, 10); noStroke();

  // Top label
  fill(C_DIM); textSize(12); textAlign(CENTER, CENTER);
  text("G E T   R E A D Y", width/2, py + 30);

  // Number / GO
  if (secondsLeft >= 1) {
    fill(C_GREEN); textSize(115);
    text(secondsLeft, width/2, py + 138);
  } else if (timePassed < countdownDuration) {
    fill(C_YELLOW); textSize(80);
    text("GO!", width/2, py + 135);
  } else {
    gameState = "playing";
    postToBackend("start", null);
  }

  // Player labels
  fill(C_P1); textSize(13); textAlign(LEFT, CENTER);
  text("< PLAYER 1", 28, height/2);
  fill(C_P2); textAlign(RIGHT, CENTER);
  text((isVsComputer ? "COMPUTER" : "PLAYER 2") + " >", battlefieldWidth - 28, height/2);
  textAlign(CENTER, CENTER);
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN: GAME OVER  ★ REDESIGNED
// ═══════════════════════════════════════════════════════════════
void drawGameOver() {
  displayTerrain();

  float fa = map(sin(frameCount * 0.07), -1, 1, 140, 195);
  fill(0, fa); noStroke(); rect(0, 0, width, height);

  boolean p1wins = winnerMessage.contains("1");
  color winCol   = p1wins ? C_P1 : C_P2;

  float pw = 500, ph = 260, px = width/2 - pw/2, py = height/2 - ph/2;

  fill(0, 70); noStroke(); rect(px+6, py+6, pw, ph, 10);
  fill(red(C_PANEL), green(C_PANEL), blue(C_PANEL), 245);
  rect(px, py, pw, ph, 10);
  fill(winCol); rect(px, py, pw, 5, 10,10,0,0);
  stroke(red(winCol), green(winCol), blue(winCol), 85);
  strokeWeight(1); noFill(); rect(px, py, pw, ph, 10); noStroke();

  fill(C_DIM); textSize(12); textAlign(CENTER, CENTER);
  text("-  -  -   G A M E   O V E R   -  -  -", width/2, py + 30);

  fill(winCol); textSize(52);
  text(winnerMessage, width/2, py + 108);

  // Hack badge
  if (hackChallengeUsed) {
    fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 30);
    noStroke();
    rect(width/2 - 130, py + 148, 260, 24, 4);
    fill(C_GREEN); textSize(11);
    text(">_  HACK CHALLENGE USED THIS MATCH", width/2, py + 160);
  }

  // Options
  float ra = map(sin(frameCount * 0.09), -1, 1, 80, 255);
  fill(red(C_DIM), green(C_DIM), blue(C_DIM), ra);
  textSize(13);
  text("[ R ]  Play Again      [ L ]  View Leaderboard", width/2, py + 228);
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN: LEADERBOARD  ★ NEW
// ═══════════════════════════════════════════════════════════════
void drawLeaderboard() {
  background(C_BG);
  drawCircuitBg();

  textAlign(CENTER, CENTER);
  fill(C_GREEN); textSize(11);
  text("[ SEASON RECORDS ]", width/2, 48);

  fill(C_TEXT); textSize(34);
  text("LEADERBOARD", width/2, 86);

  stroke(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 55);
  strokeWeight(1);
  line(width/2-180, 110, width/2+180, 110);
  noStroke();

  // ── Score cards ──────────────────────────────────────────────
  float cardW = 200, cardH = 110, cardY = 130;
  float c1x = width/2 - cardW*1.5 - 16;
  float c2x = width/2 - cardW*0.5;
  float c3x = width/2 + cardW*0.5 + 16;

  drawStatCard(c1x, cardY, cardW, cardH, "PLAYER 1 WINS", str(lb_p1Wins), C_P1);
  drawStatCard(c2x, cardY, cardW, cardH, "MATCHES PLAYED", str(lb_total),  C_CYAN);
  drawStatCard(c3x, cardY, cardW, cardH, "PLAYER 2 WINS", str(lb_p2Wins), C_P2);

  // Win rate bar
  float barW = 640, barH = 18;
  float barX = width/2 - barW/2, barY = 268;

  noStroke(); fill(C_BORDER); rect(barX, barY, barW, barH, 4);
  if (lb_total > 0) {
    float p1pct = (float)lb_p1Wins / lb_total;
    if (p1pct > 0) { fill(C_P1); rect(barX, barY, barW * p1pct, barH, 4,0,0,4); }
    float p2pct = (float)lb_p2Wins / lb_total;
    if (p2pct > 0) { fill(C_P2); rect(barX + barW*(1-p2pct), barY, barW*p2pct, barH, 0,4,4,0); }
  }
  fill(C_P1); textSize(10); textAlign(LEFT, CENTER);
  text("P1 " + (lb_total>0 ? nf(100.0*lb_p1Wins/lb_total,1,0)+"%" : "0%"), barX, barY + barH + 14);
  fill(C_P2); textAlign(RIGHT, CENTER);
  text((lb_total>0 ? nf(100.0*lb_p2Wins/lb_total,1,0)+"%" : "0%") + " P2", barX + barW, barY + barH + 14);

  // ── Match history ─────────────────────────────────────────────
  float tableX = width/2 - 320, tableY = 320;
  float tableW = 640, rowH = 34;

  // Header row
  fill(C_CARD); noStroke(); rect(tableX, tableY, tableW, rowH, 4,4,0,0);
  stroke(C_BORDER); strokeWeight(1); noFill(); rect(tableX, tableY, tableW, rowH, 4,4,0,0); noStroke();
  fill(C_DIM); textSize(11); textAlign(LEFT, CENTER);
  text("  WINNER",        tableX + 10,  tableY + rowH/2);
  text("LOSER",           tableX + 200, tableY + rowH/2);
  text("MAP",             tableX + 360, tableY + rowH/2);
  text(">_ HACK",         tableX + 490, tableY + rowH/2);

  // Data rows
  int shown = min(lb_history.size(), 6);
  for (int i = 0; i < shown; i++) {
    String[] rec = lb_history.get(lb_history.size() - 1 - i); // newest first
    float ry = tableY + rowH * (i + 1);

    fill(i%2==0 ? C_PANEL : C_CARD);
    noStroke(); rect(tableX, ry, tableW, rowH);
    stroke(C_BORDER); strokeWeight(1); noFill(); rect(tableX, ry, tableW, rowH); noStroke();

    boolean winIsP1 = rec[0].contains("1");
    fill(winIsP1 ? C_P1 : C_P2); textSize(12); textAlign(LEFT, CENTER);
    text("  " + rec[0], tableX + 10,  ry + rowH/2);

    fill(C_DIM);
    text(rec[1],         tableX + 200, ry + rowH/2);
    text(rec[2],         tableX + 360, ry + rowH/2);

    if (rec[3].equals("true")) { fill(C_GREEN); text("YES", tableX + 490, ry + rowH/2); }
    else                       { fill(C_BORDER); text("—",  tableX + 490, ry + rowH/2); }
  }

  if (lb_history.isEmpty()) {
    fill(C_DIM); textSize(13); textAlign(CENTER, CENTER);
    text("No matches recorded yet. Play a game to start your season!", width/2, tableY + rowH * 2);
  }

  // Footer
  fill(C_DIM); textSize(10); textAlign(CENTER, CENTER);
  text("[ R ]  Back to Menu      [ C ]  Clear Season Records", width/2, height - 28);
}

void drawStatCard(float x, float y, float w, float h, String label, String val, color accent) {
  fill(0, 50); noStroke(); rect(x+3, y+3, w, h, 6);
  fill(C_CARD); noStroke(); rect(x, y, w, h, 6);
  fill(accent); rect(x, y, w, 4, 6,6,0,0);
  stroke(red(accent), green(accent), blue(accent), 50);
  strokeWeight(1); noFill(); rect(x, y, w, h, 6); noStroke();

  fill(accent); textSize(40); textAlign(CENTER, CENTER);
  text(val, x + w/2, y + h*0.55);

  fill(C_DIM); textSize(10);
  text(label, x + w/2, y + h*0.85);
}

// ═══════════════════════════════════════════════════════════════
//  UI PANEL  ★ REDESIGNED
// ═══════════════════════════════════════════════════════════════
void drawUIPanel() {
  float px = width - UI_PANEL_WIDTH;
  float x  = px + UI_PADDING;

  // Background + left border
  fill(C_PANEL); noStroke(); rect(px, 0, UI_PANEL_WIDTH, height);
  stroke(C_BORDER); strokeWeight(1); line(px, 0, px, height); noStroke();

  float y = 16;
  textAlign(LEFT, TOP);

  // Logo
  fill(C_TEXT); textSize(16); text("TANKWAR", x, y);
  fill(C_GREEN); textSize(9); text("HACKER EDITION", x, y+21); y += 40;
  hRule(px, y); y += 12;

  // ── Player 1 ──────────────────────────────────────────────
  fill(C_P1); noStroke(); ellipse(x+6, y+8, 9, 9);
  fill(C_TEXT); textSize(13); text("PLAYER 1", x+18, y);
  if (tank1 != null) {
    float bx2 = x+118;
    if (tank1.hasShield)     { fill(C_CYAN);   textSize(9); text("[SHLD]", bx2, y+1); bx2+=46; }
    if (tank1.rapidFire>1.1) { fill(C_ORANGE); textSize(9); text("[RPID]", bx2, y+1); }
  }
  y += 22;
  if (tank1 != null) {
    hpBar(x, y, UI_PANEL_WIDTH-UI_PADDING*2, tank1.health, C_P1); y += 18;
    fill(C_DIM); textSize(10); text("WPN", x, y);
    fill(C_TEXT); text(tank1.getCurrentWeapon().toUpperCase(), x+36, y);
  }
  y += 20;
  hRule(px, y); y += 12;

  // ── Player 2 / Computer ────────────────────────────────────
  fill(C_P2); noStroke(); ellipse(x+6, y+8, 9, 9);
  fill(C_TEXT); textSize(13);
  text(isVsComputer ? "COMPUTER" : "PLAYER 2", x+18, y);
  if (tank2 != null) {
    float bx2 = x+118;
    if (tank2.hasShield)     { fill(C_CYAN);   textSize(9); text("[SHLD]", bx2, y+1); bx2+=46; }
    if (tank2.rapidFire>1.1) { fill(C_ORANGE); textSize(9); text("[RPID]", bx2, y+1); }
  }
  y += 22;
  if (tank2 != null) {
    hpBar(x, y, UI_PANEL_WIDTH-UI_PADDING*2, tank2.health, C_P2); y += 18;
    fill(C_DIM); textSize(10); text("WPN", x, y);
    fill(C_TEXT); text(tank2.getCurrentWeapon().toUpperCase(), x+36, y);
  }
  y += 20;
  hRule(px, y); y += 12;

  // ── Controls ──────────────────────────────────────────────
  fill(C_DIM); textSize(11); text("CONTROLS", x, y); y += 16;
  fill(C_P1); textSize(10); text("P1", x, y);
  fill(C_TEXT, 180); text("WASD  ·  SPACE  ·  Q", x+22, y); y += 15;
  if (!isVsComputer) {
    fill(C_P2); textSize(10); text("P2", x, y);
    fill(C_TEXT, 180); text("ARROWS  ·  L  ·  K", x+22, y); y += 15;
  }
  fill(C_DIM); textSize(9);
  text("1-Bullet  2-Missile  3-Plasma", x, y); y += 13;
  if (!isVsComputer) { text("8-Bullet  9-Missile  0-Plasma", x, y); y += 13; }
  hRule(px, y+2); y += 14;

  // ── Map ───────────────────────────────────────────────────
  fill(C_DIM); textSize(10); text("MAP", x, y);
  fill(currentTerrain.equals("grassland") ? C_GREEN : C_ORANGE);
  text(currentTerrain.isEmpty() ? "--" : currentTerrain.toUpperCase(), x+36, y);
  y += 20;

  // Hack badge
  if (hackChallengeUsed) {
    fill(red(C_GREEN), green(C_GREEN), blue(C_GREEN), 35); noStroke();
    rect(x, y, UI_PANEL_WIDTH-UI_PADDING*2, 18, 3);
    fill(C_GREEN); textSize(9);
    text(">_ HACK USED THIS MATCH", x+5, y+3);
    y += 22;
  }

  // API dot
  fill(C_GREEN); noStroke(); ellipse(x+5, height-15, 6, 6);
  fill(C_DIM); textSize(9); text("API :8080", x+14, height-20);
}

void hpBar(float x, float y, float w, float hp, color col) {
  float pct = constrain(hp/100.0, 0, 1);
  fill(C_BORDER); noStroke(); rect(x, y, w, 10, 2);
  color hc = pct > 0.5 ? col : (pct > 0.25 ? C_ORANGE : C_RED);
  if (pct > 0) { fill(hc); rect(x, y, w*pct, 10, 2); }
  fill(C_TEXT); textSize(9); textAlign(RIGHT, TOP);
  text((int)hp + " HP", x+w, y);
  textAlign(LEFT, TOP);
}

void hRule(float px, float y) {
  stroke(C_BORDER); strokeWeight(1);
  line(px+6, y, px+UI_PANEL_WIDTH-6, y);
  noStroke();
}

// ═══════════════════════════════════════════════════════════════
//  DISPLAY TERRAIN  (identical to original)
// ═══════════════════════════════════════════════════════════════
void displayTerrain() {
  for (int y = 0; y < tileMap.length; y++) {
    for (int x = 0; x < tileMap[0].length; x++) {
      PImage t = null; float rot = 0;
      switch(tileMap[y][x]) {
        case TILE_GRASS: t = grassTileImg; break;
        case TILE_SAND:  t = sandTileImg; break;
        case TILE_ROAD:  t = roadTileImg; break;
        case TILE_GRASS_ROAD_CORNER_LL: t = grassRoadCornerLLImg; break;
        case TILE_GRASS_ROAD_CORNER_LR: t = grassRoadCornerLRImg; break;
        case TILE_GRASS_ROAD_CORNER_UL: t = grassRoadCornerULImg; break;
        case TILE_GRASS_ROAD_CORNER_UR: t = grassRoadCornerURImg; break;
        case TILE_GRASS_ROAD_EAST:   t = grassRoadEastImg; break;
        case TILE_GRASS_ROAD_NORTH:  t = grassRoadNorthImg; rot = HALF_PI; break;
        case TILE_GRASS_ROAD_SPLIT_E: t = grassRoadSplitEImg; break;
        case TILE_GRASS_ROAD_SPLIT_S: t = grassRoadSplitSImg; break;
        case TILE_GRASS_ROAD_SPLIT_N: t = grassRoadSplitNImg; rot = PI; break;
        case TILE_GRASS_ROAD_SPLIT_W: t = grassRoadSplitEImg; rot = -HALF_PI; break;
        case TILE_SAND_ROAD_CORNER_LL: t = sandRoadCornerLLImg; break;
        case TILE_SAND_ROAD_CORNER_LR: t = sandRoadCornerLRImg; break;
        case TILE_SAND_ROAD_CORNER_UL: t = sandRoadCornerULImg; break;
        case TILE_SAND_ROAD_CORNER_UR: t = sandRoadCornerURImg; break;
        case TILE_SAND_ROAD_SPLIT_E: t = sandRoadSplitEImg; break;
        case TILE_SAND_ROAD_SPLIT_N: t = sandRoadSplitNImg; break;
      }
      if (t != null) {
        pushMatrix();
        translate(battlefieldX + x*TILE_SIZE + TILE_SIZE/2, battlefieldY + y*TILE_SIZE + TILE_SIZE/2);
        rotate(rot); imageMode(CENTER); image(t, 0, 0, TILE_SIZE, TILE_SIZE);
        popMatrix();
      } else { fill(100); rect(battlefieldX+x*TILE_SIZE, battlefieldY+y*TILE_SIZE, TILE_SIZE, TILE_SIZE); }
    }
  }
  stroke(C_BORDER); strokeWeight(3); noFill();
  rect(battlefieldX, battlefieldY, battlefieldWidth, battlefieldHeight);
  noStroke();
}

// ═══════════════════════════════════════════════════════════════
//  GAME OBJECT UPDATE / DRAW  (identical to original)
// ═══════════════════════════════════════════════════════════════
void updateGameObjects() {
  tank1.update(barriers, tank2, currentTerrain);
  tank2.update(barriers, tank1, currentTerrain);

  for (int i = projectiles.size()-1; i >= 0; i--) {
    Projectile p = projectiles.get(i); p.update();
    if (!p.alive) projectiles.remove(i);
  }
  for (int i = barriers.size()-1; i >= 0; i--) {
    if (barriers.get(i).isDestroyed()) {
      createExplosion(barriers.get(i).x+barriers.get(i).w/2, barriers.get(i).y+barriers.get(i).h/2, 50);
      barriers.remove(i);
    }
  }
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i); p.update();
    if (!p.alive) particles.remove(i);
  }
  for (int i = timers.size()-1; i >= 0; i--) {
    timers.get(i).update();
    if (timers.get(i).isDone()) timers.remove(i);
  }
  for (int i = powerUps.size()-1; i >= 0; i--) {
    PowerUp p = powerUps.get(i);
    if (p.isCollectedBy(tank1)) {
      if (p.type.equals("hack")) { powerUps.remove(i); startHackChallenge(tank1); }
      else { tank1.applyPowerUp(p); powerUps.remove(i); }
    } else if (p.isCollectedBy(tank2) && !isVsComputer) {
      if (p.type.equals("hack")) { powerUps.remove(i); startHackChallenge(tank2); }
      else { tank2.applyPowerUp(p); powerUps.remove(i); }
    } else if (p.isCollectedBy(tank2) && isVsComputer) {
      if (p.type.equals("hack")) { tank2.hasShield = true; powerUps.remove(i); }
      else { tank2.applyPowerUp(p); powerUps.remove(i); }
    }
  }
  if (tank1.health <= 0) gameOver("PLAYER 2 WINS!");
  else if (tank2.health <= 0) gameOver("PLAYER 1 WINS!");
}

void drawGameObjects() {
  for (Barrier b    : barriers)    b.display();
  for (Projectile p : projectiles) p.display();
  for (PowerUp p    : powerUps)    p.display();
  for (Particle p   : particles)   p.display();
  tank1.display(true);
  tank2.display(true);
}

// ═══════════════════════════════════════════════════════════════
//  EXPLOSION  (enhanced)
// ═══════════════════════════════════════════════════════════════
void createExplosion(float x, float y, float size) {
  explosionSound.trigger();
  for (int i = 0; i < 20; i++)
    particles.add(new Particle(x, y, random(-4,4), random(-4,4),
      color(255, random(140,255), 0), random(6,16), 35));
  for (int i = 0; i < 8; i++)
    particles.add(new Particle(x, y, random(-2,2), random(-2,2),
      color(80,80,80), random(8,20), 50));
}

// ═══════════════════════════════════════════════════════════════
//  SPRING BOOT INTEGRATION
// ═══════════════════════════════════════════════════════════════
void postToBackend(final String endpoint, final String params) {
  final String url = "http://localhost:8080/api/game/" + endpoint +
                     (params != null ? "?" + params : "");
  Thread t = new Thread(new Runnable() { public void run() {
    try {
      HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
      c.setRequestMethod("POST"); c.setConnectTimeout(500);
      c.getResponseCode(); c.disconnect();
    } catch (Exception e) { println("[Backend] " + endpoint + ": " + e.getMessage()); }
  }});
  t.setDaemon(true); t.start();
}

// ═══════════════════════════════════════════════════════════════
//  LEGACY HELPERS
// ═══════════════════════════════════════════════════════════════
void drawRoundedRect(float x, float y, float w, float h, float r, color c) {
  fill(c); noStroke();
  rect(x, y+r, w, h-2*r); rect(x+r, y, w-2*r, h);
  ellipse(x+r,y+r,2*r,2*r); ellipse(x+w-r,y+r,2*r,2*r);
  ellipse(x+r,y+h-r,2*r,2*r); ellipse(x+w-r,y+h-r,2*r,2*r);
}
void drawGradientBackground(color c1, color c2) {
  for (int i=0; i<=height; i++) { stroke(lerpColor(c1,c2,map(i,0,height,0,1))); line(0,i,width,i); }
}

// ═══════════════════════════════════════════════════════════════
//  INPUT HANDLERS
// ═══════════════════════════════════════════════════════════════
void keyPressed() {

  // Hack challenge input — always first
  if (gameState.equals("hacking")) {
    if      (key == ENTER || key == RETURN) { checkHackAnswer(); }
    else if (key == ESC) { key = 0; endHackChallenge(); }
    else if (key == BACKSPACE) {
      if (hackInput.length() > 0) hackInput = hackInput.substring(0, hackInput.length()-1);
    } else if (key != CODED && hackInput.length() < 40) { hackInput += key; }
    return;
  }

  if (gameState.equals("welcome")) {
    if (key != CODED) gameState = "mode_selection";
    return;
  }

  if (gameState.equals("mode_selection")) {
    if      (key=='p'||key=='P') { isVsComputer=false; gameState="terrain_selection"; }
    else if (key=='c'||key=='C') { isVsComputer=true;  gameState="terrain_selection"; }
    else if (key=='b'||key=='B') { gameState="leaderboard"; }
    return;
  }

  if (gameState.equals("terrain_selection")) {
    if      (key=='g'||key=='G') { currentTerrain="grassland"; generateMap("grassland"); gameState="countdown"; countdownStartTime=millis(); }
    else if (key=='d'||key=='D') { currentTerrain="desert";    generateMap("desert");    gameState="countdown"; countdownStartTime=millis(); }
    else if (key=='b'||key=='B') { gameState="mode_selection"; }
    return;
  }

  if (gameState.equals("countdown")) return;

  if (gameState.equals("game_over")) {
    if      (key=='r'||key=='R') { resetGame(); }
    else if (key=='l'||key=='L') { gameState="leaderboard"; }
    return;
  }

  if (gameState.equals("leaderboard")) {
    if (key=='r'||key=='R'||key==ESC) { key=0; gameState="mode_selection"; }
    else if (key=='c'||key=='C') { clearLeaderboard(); }
    return;
  }

  // Playing
  tank1.handleKeyPressed(key, true);
  if (!isVsComputer) tank2.handleKeyPressed(keyCode, true);
}

void keyReleased() {
  if (!gameState.equals("playing")) return;
  tank1.handleKeyPressed(key, false);
  if (!isVsComputer) tank2.handleKeyPressed(keyCode, false);
}

void handleTerrainSelection() {}

// ═══════════════════════════════════════════════════════════════
//  GAME FLOW
// ═══════════════════════════════════════════════════════════════
void gameOver(String message) {
  if (!gameState.equals("game_over")) {
    gameState = "game_over";
    winnerMessage = message;

    String winner = message.contains("1") ? "Player+1" : "Player+2";
    String loser  = message.contains("1") ? "Player+2" : "Player+1";
    postToBackend("result",
      "winnerName=" + winner + "&loserName=" + loser +
      "&damageDealt=100&terrain=" + currentTerrain +
      "&usedHack=" + hackChallengeUsed);

    // Save to local leaderboard
    saveMatchResult(winner.replace("+", " "), loser.replace("+", " "),
                    currentTerrain, hackChallengeUsed);
  }
}

void resetGame() {
  projectiles.clear(); barriers.clear();
  powerUps.clear(); particles.clear(); timers.clear();
  tank1 = new Tank(0,0,color(255,0,0),  true,  tank1Img, false);
  tank2 = new Tank(0,0,color(0,0,255),  false, tank2Img, isVsComputer);
  hackChallengeUsed = false;
  spawnPowerUps();
  winnerMessage = "";
  gameState = "mode_selection";
  currentTerrain = "";
}

// ═══════════════════════════════════════════════════════════════
//  MAP GENERATION  (identical to original)
// ═══════════════════════════════════════════════════════════════
void generateMap(String terrainType) {
  int cols = battlefieldWidth/TILE_SIZE, rows = battlefieldHeight/TILE_SIZE;
  tileMap = new int[rows][cols];
  barriers.clear();
  PImage bImg; float bHealth, indestructible = 10000;

  switch(terrainType) {
    case "grassland":
      bImg = barrierGImg; bHealth = 100;
      for (int r=0; r<rows; r++) for (int c=0; c<cols; c++) tileMap[r][c]=TILE_GRASS;
      for (int c=0; c<cols; c++) tileMap[rows/2][c]=TILE_GRASS_ROAD_EAST;
      for (int r=0; r<rows; r++) tileMap[r][cols/2]=TILE_GRASS_ROAD_NORTH;
      tileMap[rows/2][cols/2]=TILE_GRASS_ROAD_SPLIT_E;
      tileMap[0][cols/2]=TILE_GRASS_ROAD_CORNER_LL;
      tileMap[rows-1][cols/2]=TILE_GRASS_ROAD_CORNER_UR;
      tileMap[rows/2][0]=TILE_GRASS_ROAD_CORNER_UR;
      tileMap[rows/2][cols-1]=TILE_GRASS_ROAD_CORNER_LL;
      barriers.add(new Barrier(battlefieldX+cols/2*TILE_SIZE-barrierStandardWidth-10,
        battlefieldY+rows/2*TILE_SIZE+TILE_SIZE-barrierStandardHeight,
        barrierStandardWidth, barrierStandardHeight, bHealth, bImg, 0));
      barriers.add(new Barrier(battlefieldX+cols/2*TILE_SIZE+10,
        battlefieldY+rows/2*TILE_SIZE+TILE_SIZE-barrierStandardHeight,
        barrierStandardWidth, barrierStandardHeight, bHealth, bImg, 0));
      float th=60;
      barriers.add(new Barrier(battlefieldX+100,battlefieldY+100+TILE_SIZE-th,60,60,indestructible,treeGreenLargeImg,-20));
      barriers.add(new Barrier(battlefieldX+battlefieldWidth-160,battlefieldY+100+TILE_SIZE-th,60,60,indestructible,treeGreenLargeImg,-20));
      barriers.add(new Barrier(battlefieldX+100,battlefieldY+battlefieldHeight-100-th+TILE_SIZE-th,60,60,indestructible,treeGreenLargeImg,-20));
      barriers.add(new Barrier(battlefieldX+battlefieldWidth-160,battlefieldY+battlefieldHeight-100-th+TILE_SIZE-th,60,60,indestructible,treeGreenLargeImg,-20));
      barriers.add(new Barrier(battlefieldX+50,battlefieldY+rows/4*TILE_SIZE+TILE_SIZE-barrierStandardHeight,barrierStandardWidth,barrierStandardHeight,bHealth,bImg,0));
      barriers.add(new Barrier(battlefieldX+battlefieldWidth-50-barrierStandardWidth,battlefieldY+rows*3/4*TILE_SIZE+TILE_SIZE-barrierStandardHeight,barrierStandardWidth,barrierStandardHeight,bHealth,bImg,0));
      break;

    case "desert":
      bImg = barrierDImg; bHealth = 50;
      for (int r=0; r<rows; r++) for (int c=0; c<cols; c++) tileMap[r][c]=TILE_SAND;
      PVector[] pts = {new PVector(cols/4,rows/4),new PVector(cols*3/4,rows/4),
                       new PVector(cols/4,rows*3/4),new PVector(cols*3/4,rows*3/4),
                       new PVector(cols/2,rows/2)};
      for (PVector pt : pts) {
        float cx=battlefieldX+pt.x*TILE_SIZE, cy=battlefieldY+pt.y*TILE_SIZE;
        int num=(int)random(2,5);
        for (int i=0; i<num; i++)
          barriers.add(new Barrier(cx+random(-30,30),cy+random(-30,30)+TILE_SIZE-barrierStandardHeight,barrierStandardWidth,barrierStandardHeight,bHealth,bImg,0));
        if (random(1)>0.5)
          barriers.add(new Barrier(cx+random(-20,20),cy+random(-20,20)+TILE_SIZE-60,60,60,indestructible,treeBrownLargeImg,-20));
      }
      for (int i=0; i<10; i++) {
        float rx=random(battlefieldX+50,battlefieldX+battlefieldWidth-80);
        float ry=random(battlefieldY+50,battlefieldY+battlefieldHeight-80);
        barriers.add(new Barrier(rx,ry+TILE_SIZE-30,30,30,indestructible,treeBrownTwigsImg,-10));
      }
      barriers.add(new Barrier(battlefieldX+100,battlefieldY+rows/3*TILE_SIZE+TILE_SIZE-barrierStandardHeight,barrierStandardWidth*2,barrierStandardHeight,bHealth,bImg,0));
      barriers.add(new Barrier(battlefieldX+battlefieldWidth-100-barrierStandardWidth*2,battlefieldY+rows*2/3*TILE_SIZE+TILE_SIZE-barrierStandardHeight,barrierStandardWidth*2,barrierStandardHeight,bHealth,bImg,0));
      break;
  }

  tank1 = new Tank(0,0,color(255,0,0),true, tank1Img,false);
  tank2 = new Tank(0,0,color(0,0,255),false,tank2Img,isVsComputer);
  PVector s1=findClearSpawnPoint(battlefieldX,battlefieldY,battlefieldWidth/2,battlefieldHeight/2,tank1.tankWidth,tank1.tankHeight);
  PVector s2=findClearSpawnPoint(battlefieldX+battlefieldWidth/2,battlefieldY+battlefieldHeight/2,battlefieldWidth/2,battlefieldHeight/2,tank2.tankWidth,tank2.tankHeight);
  tank1.x=s1.x; tank1.y=s1.y;
  tank2.x=s2.x; tank2.y=s2.y;
  spawnPowerUps();
}

PVector findClearSpawnPoint(float ax,float ay,float aw,float ah,float ow,float oh) {
  for (int i=0; i<100; i++) {
    float sx=random(ax,ax+aw-ow), sy=random(ay,ay+ah-oh);
    boolean hit=false;
    for (Barrier b:barriers)
      if (sx<b.x+b.w&&sx+ow>b.x&&sy<b.y+b.h&&sy+oh>b.y){hit=true;break;}
    if (!hit) return new PVector(sx,sy);
  }
  return new PVector(ax+aw/4,ay+ah/4);
}
