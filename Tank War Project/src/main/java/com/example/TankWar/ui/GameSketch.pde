// GameSketch.pde - Final Version with Improved Layouts and Fixes
import ddf.minim.*; // Import the Minim library for audio

// Global Game State Variables
Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier> barriers = new ArrayList<Barrier>();
ArrayList<PowerUp> powerUps = new ArrayList<PowerUp>();
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Timer> timers = new ArrayList<Timer>(); // Declare globally

// Game state management
String gameState = "mode_selection"; // "mode_selection", "terrain_selection", "countdown", "playing", "game_over"
boolean isVsComputer = false; // Flag to determine if playing against AI
String currentTerrain = ""; // This variable needs to be globally accessible in GameSketch.pde

int countdownStartTime;
int countdownDuration = 4000; // 3-second countdown + "GO!"
String winnerMessage = "";

// Images
PImage tank1Img, tank2Img, tankBarrelImg;
PImage barrierGImg, barrierDImg; // Removed barrierIImg as ice terrain is removed
PImage bulletImg, missileImg, plasmaImg;
PImage explosionImg;

// Tileable background images for more complex terrain
PImage grassTileImg;
PImage sandTileImg;

// Grassland specific road and tree tiles
PImage grassRoadCornerLLImg, grassRoadCornerLRImg, grassRoadCornerULImg, grassRoadCornerURImg; // Added UL for completeness
PImage grassRoadEastImg, grassRoadNorthImg; // Added North for vertical roads
PImage grassRoadSplitEImg, grassRoadSplitSImg, grassRoadSplitNImg, grassRoadSplitWImg; // Added N, W for completeness
PImage treeGreenLargeImg;

// Desert specific road and tree tiles
PImage sandRoadCornerLLImg, sandRoadCornerLRImg, sandRoadCornerULImg, sandRoadCornerURImg;
PImage sandRoadSplitEImg, sandRoadSplitNImg;
PImage treeBrownLargeImg, treeBrownSmallImg, treeBrownTwigsImg;

PImage roadTileImg; // Global declaration for roadTileImg

// Barrier dimensions (Standardized sizes for uniform barriers)
final float barrierStandardWidth = 50;
final float barrierStandardHeight = 100; // Adjusted for better visual fit and gameplay

// Tilemap dimensions
final int TILE_SIZE = 50; // Size of each tile in pixels
int[][] tileMap; // 2D array to store tile types for the battlefield background

// Tile types (for tileMap)
final int TILE_GRASS = 0;
final int TILE_SAND = 1;
final int TILE_ROAD = 2; // Generic road (can be used for desert if specific tiles not available)
// Removed TILE_ICE = 3;
final int TILE_GRASS_ROAD_CORNER_LL = 4;
final int TILE_GRASS_ROAD_CORNER_LR = 5;
final int TILE_GRASS_ROAD_CORNER_UL = 6; // Added UL
final int TILE_GRASS_ROAD_CORNER_UR = 7; // Adjusted UR
final int TILE_GRASS_ROAD_EAST = 8; // Adjusted
final int TILE_GRASS_ROAD_NORTH = 9; // Added for vertical roads
final int TILE_GRASS_ROAD_SPLIT_E = 10; // Adjusted
final int TILE_GRASS_ROAD_SPLIT_S = 11; // Adjusted
final int TILE_GRASS_ROAD_SPLIT_N = 12; // Added
final int TILE_GRASS_ROAD_SPLIT_W = 13; // Added

// Desert specific tile types
final int TILE_SAND_ROAD_CORNER_LL = 14; // Adjusted
final int TILE_SAND_ROAD_CORNER_LR = 15; // Adjusted
final int TILE_SAND_ROAD_CORNER_UL = 16; // Adjusted
final int TILE_SAND_ROAD_CORNER_UR = 17; // Adjusted
final int TILE_SAND_ROAD_SPLIT_E = 18; // Adjusted
final int TILE_SAND_ROAD_SPLIT_N = 19; // Adjusted


// Font
PFont gameFont;

// Audio variables
Minim minim;
AudioPlayer backgroundMusic;
AudioSample fireSound;
AudioSample explosionSound;
AudioSample powerupSound;

// Battlefield layout - Declared as static final for global accessibility
static final int battlefieldX = 0;
static final int battlefieldY = 0;
static final int battlefieldWidth = 750; // Keep consistent with UI panel
static final int battlefieldHeight = 600;

// UI Panel constants - Moved to global scope. UI_BG_COLOR and UI_TEXT_COLOR will be initialized in setup()
static final int UI_PANEL_WIDTH = 250;
color UI_BG_COLOR; // Removed static final, will be initialized in setup()
color UI_TEXT_COLOR; // Removed static final, will be initialized in setup()
static final int UI_PADDING = 20;


void setup() {
  size(1000, 600); // Total window size
  smooth(); // Enable anti-aliasing

  // Initialize UI colors here, after PApplet context is available
  UI_BG_COLOR = color(50, 70, 90);
  UI_TEXT_COLOR = color(255);

  // Load Images
  // Ensure these filenames match your 'data' folder exactly (case-sensitive)
  tank1Img = loadImage("tankBody_bigRed_outline.png");
  tank2Img = loadImage("tankBody_blue_outline.png");
  tankBarrelImg = loadImage("tankBlue_barrel1.png");

  barrierGImg = loadImage("barricadeMetal.png"); // Metal X-barricade
  barrierDImg = loadImage("crateWood.png");      // Wooden crate
  // Removed barrierIImg

  // Load tileable background images
  grassTileImg = loadImage("tileGrass1.png"); // Basic grass tile

  // Load grassland specific road tiles
  grassRoadCornerLLImg = loadImage("tileGrass_roadCornerLL.png");
  grassRoadCornerLRImg = loadImage("tileGrass_roadCornerLR.png");
  grassRoadCornerULImg = loadImage("tileGrass_roadCornerUL.png"); // New
  grassRoadCornerURImg = loadImage("tileGrass_roadCornerUR.png");
  grassRoadEastImg = loadImage("tileGrass_roadEast.png");
  // For vertical roads, we'll rotate grassRoadEastImg or need a dedicated vertical tile
  grassRoadNorthImg = loadImage("tileGrass_roadEast.png"); // Using horizontal and rotating for vertical
  grassRoadSplitEImg = loadImage("tileGrass_roadSplitE.png");
  grassRoadSplitSImg = loadImage("tileGrass_roadSplitS.png");
  grassRoadSplitNImg = loadImage("tileGrass_roadSplitN.png"); // New
  grassRoadSplitWImg = loadImage("tileGrass_roadSplitE.png"); // Using East split and rotating for West
  treeGreenLargeImg = loadImage("treeGreen_large.png"); // Large green tree

  sandTileImg = loadImage("tileSand1.png"); // Basic sand tile

  // Load desert specific road and tree tiles
  sandRoadCornerLLImg = loadImage("tileSand_roadCornerLL.png");
  sandRoadCornerLRImg = loadImage("tileSand_roadCornerLR.png");
  sandRoadCornerULImg = loadImage("tileSand_roadCornerUL.png");
  sandRoadCornerURImg = loadImage("tileSand_roadCornerUR.png");
  sandRoadSplitEImg = loadImage("tileSand_roadSplitE.png");
  sandRoadSplitNImg = loadImage("tileSand_roadSplitN.png");
  treeBrownLargeImg = loadImage("treeBrown_large.png");
  treeBrownSmallImg = loadImage("treeBrown_small.png");
  treeBrownTwigsImg = loadImage("treeBrown_twigs.png");

  // Re-added roadTileImg loading as it's used by TILE_ROAD.
  // Make sure 'tileSand_roadEast.png' exists in your sketch's 'data' folder.
  roadTileImg = loadImage("tileSand_roadEast.png"); // Generic road tile

  // Removed iceTileImg

  bulletImg = loadImage("bulletDark1_outline.png");
  missileImg = loadImage("bulletSand3_outline.png");
  plasmaImg = loadImage("shotOrange.png");

  explosionImg = loadImage("explosion2.png");

  // Load font - Changed to Monospaced for a game-like feel
  gameFont = createFont("Monospaced", 16, true);
  textFont(gameFont);

  // Initialize Minim and load audio files
  minim = new Minim(this);
  // Make sure these files exist in your sketch's "data" folder!
  backgroundMusic = minim.loadFile("background_music.mp3"); // Replace with your music file
  fireSound = minim.loadSample("fire.wav");         // Replace with your fire sound effect
  explosionSound = minim.loadSample("explosion.wav"); // Replace with your explosion sound effect
  powerupSound = minim.loadSample("powerup.wav");     // Replace with your power-up sound effect

  // Tanks are initialized in generateMap based on game mode
}

void stop() {
  // Always close Minim when the sketch stops
  backgroundMusic.close();
  fireSound.close();
  explosionSound.close();
  powerupSound.close();
  minim.stop();
  super.stop();
}


void spawnPowerUps() {
  powerUps.clear();
  // Adjust power-up positions to be within the battlefield area
  for (int i = 0; i < 4; i++) { // Spawn 4 power-ups
    float px = random(battlefieldX + 50, battlefieldX + battlefieldWidth - 50);
    float py = random(battlefieldY + 50, battlefieldY + battlefieldHeight - 50);
    String[] types = {"health", "shield", "speed", "rapid"};
    powerUps.add(new PowerUp(px, py, types[(int)random(types.length)]));
  }
}

void draw() {
  background(180); // Default background color

  if (gameState.equals("mode_selection")) {
    drawModeSelection();
    if (backgroundMusic.isPlaying()) {
      backgroundMusic.pause(); // Pause music during selection screens
      backgroundMusic.rewind();
    }
    return;
  } else if (gameState.equals("terrain_selection")) {
    drawTerrainSelection();
    if (backgroundMusic.isPlaying()) {
      backgroundMusic.pause(); // Pause music during selection screens
      backgroundMusic.rewind();
    }
    return;
  } else if (gameState.equals("countdown")) {
    drawCountdown();
    if (backgroundMusic.isPlaying()) {
      backgroundMusic.pause(); // Pause music during countdown
      backgroundMusic.rewind();
    }
    return;
  } else if (gameState.equals("game_over")) {
    drawGameOver();
    if (backgroundMusic.isPlaying()) {
      backgroundMusic.pause(); // Stop music on game over
      backgroundMusic.rewind();
    }
    return;
  }

  // Main game loop (only runs if gameState is "playing")
  if (!backgroundMusic.isPlaying()) {
    backgroundMusic.loop(); // Start looping music when game is playing
  }
  displayTerrain(); // Draw the battlefield background based on tileMap
  updateGameObjects();
  drawGameObjects(); // Draw tanks, projectiles, barriers, powerups, particles
  drawUIPanel(); // Draw the UI panel on the right
}

void drawModeSelection() {
  drawGradientBackground(color(50, 70, 90), color(30, 40, 60));

  fill(255);
  textSize(40); // Increased size for main title
  textAlign(CENTER, CENTER);
  text("SELECT GAME MODE", width/2, height/2 - 120);

  textSize(28); // Increased size for options
  textAlign(CENTER, CENTER);
  text("Press P for Player vs Player", width/2, height/2 - 40);
  text("Press C for Player vs Computer", width/2, height/2 + 20);
}


void drawTerrainSelection() {
  drawGradientBackground(color(50, 70, 90), color(30, 40, 60));

  fill(255);
  textSize(40); // Increased size for main title
  textAlign(CENTER, CENTER);
  text("SELECT BATTLEFIELD", width/2, height/2 - 120); // Adjusted Y position for text

  textSize(28); // Increased size for options
  textAlign(CENTER, CENTER); // Ensure text is centered for these lines
  text("Press G for Grassland", width/2, height/2 - 60); // Reverted text
  text("Press D for Desert", width/2, height/2 - 20);
  // Removed "Press I for Ice"

  // Preview images (adjusted positions for better layout)
  float previewSize = 120;
  float previewY = height/2 + 80; // Adjusted Y position for images
  float previewSpacing = 180; // Increased spacing between previews

  // Draw grassland preview
  if (grassTileImg != null) {
    imageMode(CENTER);
    image(grassTileImg, width/2 - previewSpacing/2, previewY, previewSize, previewSize); // Centered single image
  } else {
    fill(0, 180, 0); // Fallback green square
    rectMode(CENTER);
    rect(width/2 - previewSpacing/2, previewY, previewSize, previewSize);
  }

  // Draw desert preview
  if (sandTileImg != null) {
    imageMode(CENTER);
    image(sandTileImg, width/2 + previewSpacing/2, previewY, previewSize, previewSize); // Centered single image
  } else {
    fill(200, 180, 100); // Fallback sand square
    rectMode(CENTER);
    rect(width/2 + previewSpacing/2, previewY, previewSize, previewSize);
  }

  rectMode(CORNER); // Reset rectMode
  imageMode(CORNER); // Reset imageMode
}

void drawCountdown() {
  displayTerrain(); // Show terrain during countdown

  // Dark overlay
  fill(0, 180);
  rect(0, 0, width, height);

  int timePassed = millis() - countdownStartTime;
  int secondsLeft = 3 - (timePassed / 1000);

  fill(255);
  textSize(90); // Increased size for countdown
  textAlign(CENTER, CENTER);

  if (secondsLeft >= 1) {
    text(secondsLeft, width/2, height/2);
  } else if (timePassed < countdownDuration) {
    text("GO!", width/2, height/2);
  } else {
    gameState = "playing"; // Transition to playing state
  }
}

void drawGameOver() {
  println("drawGameOver() called. Winner: " + winnerMessage); // Debugging
  displayTerrain(); // Show terrain behind game over screen

  // Dark overlay
  fill(0, 180);
  rect(0, 0, width, height);

  fill(255);
  textSize(60); // Increased size for winner message
  textAlign(CENTER, CENTER);
  text(winnerMessage, width/2, height/2);

  textSize(28); // Increased size for restart instruction
  text("Press R to Restart", width/2, height/2 + 60);
}

// Reverted displayTerrain to its tile-based drawing
void displayTerrain() {
  // Draw battlefield background based on tileMap
  for (int y = 0; y < tileMap.length; y++) {
    for (int x = 0; x < tileMap[0].length; x++) {
      PImage tileToDraw = null;
      float rotationAngle = 0; // Default no rotation

      switch (tileMap[y][x]) {
        case TILE_GRASS: tileToDraw = grassTileImg; break;
        case TILE_SAND: tileToDraw = sandTileImg; break;
        case TILE_ROAD: tileToDraw = roadTileImg; break;

        case TILE_GRASS_ROAD_CORNER_LL: tileToDraw = grassRoadCornerLLImg; break;
        case TILE_GRASS_ROAD_CORNER_LR: tileToDraw = grassRoadCornerLRImg; break;
        case TILE_GRASS_ROAD_CORNER_UL: tileToDraw = grassRoadCornerULImg; break;
        case TILE_GRASS_ROAD_CORNER_UR: tileToDraw = grassRoadCornerURImg; break;
        case TILE_GRASS_ROAD_EAST: tileToDraw = grassRoadEastImg; break;
        case TILE_GRASS_ROAD_NORTH: tileToDraw = grassRoadNorthImg; rotationAngle = HALF_PI; break; // Rotate for vertical
        case TILE_GRASS_ROAD_SPLIT_E: tileToDraw = grassRoadSplitEImg; break;
        case TILE_GRASS_ROAD_SPLIT_S: tileToDraw = grassRoadSplitSImg; break;
        case TILE_GRASS_ROAD_SPLIT_N: tileToDraw = grassRoadSplitNImg; rotationAngle = PI; break; // Rotate for North split
        case TILE_GRASS_ROAD_SPLIT_W: tileToDraw = grassRoadSplitEImg; rotationAngle = -HALF_PI; break; // Corrected: grassRoadSplitWImg was not declared, using grassRoadSplitEImg and rotating
        // Desert Road Tiles
        case TILE_SAND_ROAD_CORNER_LL: tileToDraw = sandRoadCornerLLImg; break;
        case TILE_SAND_ROAD_CORNER_LR: tileToDraw = sandRoadCornerLRImg; break;
        case TILE_SAND_ROAD_CORNER_UL: tileToDraw = sandRoadCornerULImg; break;
        case TILE_SAND_ROAD_CORNER_UR: tileToDraw = sandRoadCornerURImg; break;
        case TILE_SAND_ROAD_SPLIT_E: tileToDraw = sandRoadSplitEImg; break;
        case TILE_SAND_ROAD_SPLIT_N: tileToDraw = sandRoadSplitNImg; break;
      }

      if (tileToDraw != null) {
        pushMatrix();
        translate(battlefieldX + x * TILE_SIZE + TILE_SIZE/2, battlefieldY + y * TILE_SIZE + TILE_SIZE/2);
        rotate(rotationAngle); // Apply rotation if needed
        imageMode(CENTER);
        image(tileToDraw, 0, 0, TILE_SIZE, TILE_SIZE);
        popMatrix();
      } else {
        // Fallback color if tile image is null
        fill(100); // Grey
        rect(battlefieldX + x * TILE_SIZE, battlefieldY + y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
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
  // Update tanks - NOW PASSING currentTerrain
  tank1.update(barriers, tank2, currentTerrain);
  tank2.update(barriers, tank1, currentTerrain);

  // Update projectiles
  for (int i = projectiles.size()-1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.update();
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

  // Player 2 Info (adjust display based on game mode)
  fill(0, 0, 255); // Blue for Player 2
  if (isVsComputer) {
    text("COMPUTER", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 100);
  } else {
    text("PLAYER 2", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 100);
  }
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

  // Player 2 controls (hide if AI)
  if (!isVsComputer) {
    text("PLAYER 2:", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 420);
    text("Move: ARROWS", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 445);
    text("Fire: L", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 470);
    text("Switch: K", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 495);
    text("Weapons:", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 520);
    text("8-Bullet 9-Missile", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 545);
    text("0-Plasma", width - UI_PANEL_WIDTH + UI_PADDING, yPos + 570);
  }
}


void createExplosion(float x, float y, float size) {
  explosionSound.trigger(); // Play explosion sound
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
  println("keyPressed: " + key + " (keyCode: " + keyCode + ")"); // Debugging
  if (gameState.equals("mode_selection")) {
    if (key == 'p' || key == 'P') {
      isVsComputer = false;
      gameState = "terrain_selection";
    } else if (key == 'c' || key == 'C') {
      isVsComputer = true;
      gameState = "terrain_selection";
    }
    return; // Consume key press
  }

  if (gameState.equals("terrain_selection")) {
    if (key == 'g' || key == 'G') {
      currentTerrain = "grassland";
      generateMap("grassland"); // Call generateMap for grassland
      gameState = "countdown"; // Transition to countdown
      countdownStartTime = millis();
    } else if (key == 'd' || key == 'D') {
      currentTerrain = "desert";
      generateMap("desert"); // Call generateMap for desert
      gameState = "countdown"; // Transition to countdown
      countdownStartTime = millis();
    }
    return; // Consume key press
  }


  if (gameState.equals("countdown")) {
    println("Input blocked during countdown."); // Debugging
    return; // Don't allow movement/firing during countdown
  }

  if (gameState.equals("game_over")) {
    println("Game Over state. Key pressed: " + key); // Debugging
    if (key == 'r' || key == 'R') {
      resetGame();
    }
    return;
  }

  // Player 1 controls (always active)
  tank1.handleKeyPressed(key, true);
  // Player 2 controls (only active if not AI)
  if (!isVsComputer) {
    tank2.handleKeyPressed(keyCode, true);
  }
}

void keyReleased() {
  println("keyReleased: " + key + " (keyCode: " + keyCode + ")"); // Debugging
  // Only process key releases if in playing state
  if (!gameState.equals("playing")) {
    println("Input blocked when not in active game state."); // Debugging
    return;
  }

  // Player 1 controls (always active)
  tank1.handleKeyPressed(key, false);
  // Player 2 controls (only active if not AI)
  if (!isVsComputer) {
    tank2.handleKeyPressed(keyCode, false);
  }
}

// Modified handleTerrainSelection to call the new generateMap function
// This function is now implicitly called by keyPressed after terrain selection.
// Its internal logic has been moved into keyPressed.
// This function is now effectively a placeholder for previous flow.
void handleTerrainSelection() {
  // Logic moved to keyPressed for state management
}

void gameOver(String message) {
  if (!gameState.equals("game_over")) {
    gameState = "game_over";
    winnerMessage = message;
    println("GAME OVER! " + winnerMessage); // Debugging
  }
}

void resetGame() {
  println("resetGame() called. Resetting game state."); // Debugging
  projectiles.clear();
  barriers.clear();
  powerUps.clear();
  particles.clear();
  timers.clear();

  // Reset tanks based on the game mode
  tank1 = new Tank(0, 0, color(255,0,0), true, tank1Img, false); // Player 1 is always human
  tank2 = new Tank(0, 0, color(0,0,255), false, tank2Img, isVsComputer); // Tank 2 is AI if isVsComputer is true

  spawnPowerUps(); // Power-ups will be placed on the new map

  winnerMessage = "";

  // Reset the game state to return to mode selection
  gameState = "mode_selection";
  currentTerrain = "";
  // countdownStartTime will be set when a new terrain is selected
}

// NEW: Function to generate the map (tileMap and barriers) based on terrain type
void generateMap(String terrainType) {
  println("generateMap() called for terrain: " + terrainType); // Debugging
  // Determine map dimensions in tiles
  int cols = battlefieldWidth / TILE_SIZE;
  int rows = battlefieldHeight / TILE_SIZE;
  tileMap = new int[rows][cols]; // Initialize the tile map

  barriers.clear(); // Clear existing barriers for the new map

  PImage currentBarrierImg = null;
  float currentBarrierHealth = 100;
  float indestructibleHealth = 10000; // Effectively indestructible, accessible by all cases

  switch (terrainType) {
    case "grassland":
      currentBarrierImg = barrierGImg; // Metal X-barricade
      currentBarrierHealth = 100;

      // Fill with grass tiles (TILE_GRASS) by default
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          tileMap[r][c] = TILE_GRASS;
        }
      }

      // Grassland Layout: A central cross road with strategic obstacles
      // Horizontal road segment
      for (int c = 0; c < cols; c++) {
        tileMap[rows/2][c] = TILE_GRASS_ROAD_EAST;
      }
      // Vertical road segment
      for (int r = 0; r < rows; r++) {
        tileMap[r][cols/2] = TILE_GRASS_ROAD_NORTH;
      }

      // Intersections and corners
      tileMap[rows/2][cols/2] = TILE_GRASS_ROAD_SPLIT_E;
      tileMap[0][cols/2] = TILE_GRASS_ROAD_CORNER_LL;
      tileMap[rows-1][cols/2] = TILE_GRASS_ROAD_CORNER_UR;
      tileMap[rows/2][0] = TILE_GRASS_ROAD_CORNER_UR;
      tileMap[rows/2][cols-1] = TILE_GRASS_ROAD_CORNER_LL;


      // Strategic placement of metal barricades and trees
      // The last argument is 'drawOffsetY'. Adjust this value for each barrier type
      // until its image perfectly aligns with the red collision box.
      // Positive values shift the image DOWN, negative values shift it UP.
      barriers.add(new Barrier(battlefieldX + cols/2 * TILE_SIZE - barrierStandardWidth - 10,
                               (battlefieldY + rows/2 * TILE_SIZE + TILE_SIZE) - barrierStandardHeight,
                               (float)barrierStandardWidth, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      barriers.add(new Barrier(battlefieldX + cols/2 * TILE_SIZE + 10,
                               (battlefieldY + rows/2 * TILE_SIZE + TILE_SIZE) - barrierStandardHeight,
                               (float)barrierStandardWidth, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));

      float treeLargeHeight = 60.0f; // Assuming 60x60 for trees
      barriers.add(new Barrier(battlefieldX + 100, (battlefieldY + 100 + TILE_SIZE) - treeLargeHeight, 60.0f, 60.0f, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 100 - 60.0f, (battlefieldY + 100 + TILE_SIZE) - treeLargeHeight, 60.0f, 60.0f, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + 100, (battlefieldY + battlefieldHeight - 100 - 60.0f + TILE_SIZE) - treeLargeHeight, 60.0f, 60.0f, indestructibleHealth, treeGreenLargeImg, -20));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 100 - 60.0f, (battlefieldY + battlefieldHeight - 100 - 60.0f + TILE_SIZE) - treeLargeHeight, 60.0f, 60.0f, indestructibleHealth, treeGreenLargeImg, -20));

      barriers.add(new Barrier(battlefieldX + 50, (battlefieldY + rows/4 * TILE_SIZE + TILE_SIZE) - barrierStandardHeight, (float)barrierStandardWidth, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 50 - barrierStandardWidth, (battlefieldY + rows*3/4 * TILE_SIZE + TILE_SIZE) - barrierStandardHeight, (float)barrierStandardWidth, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));

      break;

    case "desert":
      currentBarrierImg = barrierDImg; // Wooden crate
      currentBarrierHealth = 50;

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          tileMap[r][c] = TILE_SAND;
        }
      }

      PVector[] clusterPoints = {
        new PVector(cols/4, rows/4),
        new PVector(cols*3/4, rows/4),
        new PVector(cols/4, rows*3/4),
        new PVector(cols*3/4, rows*3/4),
        new PVector(cols/2, rows/2)
      };

      for (PVector point : clusterPoints) {
        float clusterX = battlefieldX + point.x * TILE_SIZE;
        float clusterY = battlefieldY + point.y * TILE_SIZE;
        int numCrates = (int)random(2, 5);
        for (int i = 0; i < numCrates; i++) {
          float offsetX = random(-30, 30);
          float offsetY = random(-30, 30);
          barriers.add(new Barrier(clusterX + offsetX, (clusterY + offsetY + TILE_SIZE) - barrierStandardHeight, (float)barrierStandardWidth, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
        }
        if (random(1) > 0.5) {
          float treeBrownLargeHeight = 60.0f;
          barriers.add(new Barrier(clusterX + random(-20, 20), (clusterY + random(-20, 20) + TILE_SIZE) - treeBrownLargeHeight, 60.0f, 60.0f, indestructibleHealth, treeBrownLargeImg, -20));
        }
      }

      for (int i = 0; i < 10; i++) {
        float randX = random(battlefieldX + 50, battlefieldX + battlefieldWidth - 50 - 30);
        float randY = random(battlefieldY + 50, battlefieldY + battlefieldHeight - 50 - 30);
        float treeBrownTwigsHeight = 30.0f;
        barriers.add(new Barrier(randX, (randY + TILE_SIZE) - treeBrownTwigsHeight, 30.0f, 30.0f, indestructibleHealth, treeBrownTwigsImg, -10));
      }

      barriers.add(new Barrier(battlefieldX + 100, (battlefieldY + rows/3 * TILE_SIZE + TILE_SIZE) - barrierStandardHeight, (float)barrierStandardWidth * 2, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));
      barriers.add(new Barrier(battlefieldX + battlefieldWidth - 100 - barrierStandardWidth * 2, (battlefieldY + rows*2/3 * TILE_SIZE + TILE_SIZE) - barrierStandardHeight, (float)barrierStandardWidth * 2, (float)barrierStandardHeight, currentBarrierHealth, currentBarrierImg, 0));

      break;
  }

  // Initialize tanks after map generation to ensure spawn points are clear
  tank1 = new Tank(0, 0, color(255,0,0), true, tank1Img, false); // Player 1 is always human
  tank2 = new Tank(0, 0, color(0,0,255), false, tank2Img, isVsComputer); // Tank 2 is AI if isVsComputer is true

  PVector p1Spawn = findClearSpawnPoint(battlefieldX, battlefieldY, battlefieldWidth/2, battlefieldHeight/2, tank1.tankWidth, tank1.tankHeight);
  tank1.x = p1Spawn.x;
  tank1.y = p1Spawn.y;

  PVector p2Spawn = findClearSpawnPoint(battlefieldX + battlefieldWidth/2, battlefieldY + battlefieldHeight/2, battlefieldWidth/2, battlefieldHeight/2, tank2.tankWidth, tank2.tankHeight);
  tank2.x = p2Spawn.x;
  tank2.y = p2Spawn.y;
}

PVector findClearSpawnPoint(float areaX, float areaY, float areaWidth, float areaHeight, float objWidth, float objHeight) {
  int maxAttempts = 100;
  for (int i = 0; i < maxAttempts; i++) {
    float spawnX = random(areaX, areaX + areaWidth - objWidth);
    float spawnY = random(areaY, areaY + areaHeight - objHeight);

    boolean collision = false;
    for (Barrier b : barriers) {
      if (spawnX < b.x + b.w &&
          spawnX + objWidth > b.x &&
          spawnY < b.y + b.h &&
          spawnY + objHeight > b.y) {
        collision = true;
        break;
      }
    }

    if (!collision) {
      println("Found clear spawn point: (" + spawnX + ", " + spawnY + ")");
      return new PVector(spawnX, spawnY);
    }
  }
  println("WARNING: Could not find clear spawn point after " + maxAttempts + " attempts. Spawning at default.");
  return new PVector(areaX + areaWidth / 4, areaY + areaHeight / 4);
}
