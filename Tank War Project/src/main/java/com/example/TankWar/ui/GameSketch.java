package com.example.TankWar.ui;

import processing.core.PApplet;

public class GameSketch extends PApplet {
    // Game state
    private int currentPlayer = 0;  // 0 or 1 for player turns
    private Tank[] tanks;
    private TerrainType currentTerrain = TerrainType.GRASS;
    private Weapon currentWeapon = Weapon.CANNONBALL;
    private boolean gameOver = false;
    
    // Projectile state
    private float projectileX = -1;
    private float projectileY = -1;
    private float velocityX = 0;
    private float velocityY = 0;
    private boolean projectileActive = false;
    
    // Constants
    private final float GRAVITY = 0.5f;
    private final float GROUND_HEIGHT = 100;
    private final int INITIAL_HEALTH = 100;
    private final float TANK_MOVE_SPEED = 5;
    private final float MIN_TANK_DISTANCE = 100;
    private final float TANK_WIDTH = 40;
    private final float TANK_HEIGHT = 20;
    
    // Combat effects
    private boolean showExplosion = false;
    private float explosionX, explosionY;
    private int explosionFrames = 0;
    private final int EXPLOSION_DURATION = 30;
    
    // Weapon types with damage values
    private enum Weapon {
        CANNONBALL(20, 1.0f),
        MISSILE(35, 1.2f),
        MORTAR(45, 0.8f);
        
        final int damage;
        final float speedMultiplier;
        
        Weapon(int damage, float speedMultiplier) {
            this.damage = damage;
            this.speedMultiplier = speedMultiplier;
        }
    }
    
    private int getWeaponColor(Weapon weapon) {
        switch(weapon) {
            case CANNONBALL: return color(255, 0, 0);
            case MISSILE: return color(255, 165, 0);
            case MORTAR: return color(128, 128, 128);
            default: return color(255, 0, 0);
        }
    }
    
    private enum TerrainType {
        GRASS, DESERT, SNOW
    }
    
    private int getTerrainGroundColor(TerrainType terrain) {
        switch(terrain) {
            case GRASS: return color(34, 139, 34);
            case DESERT: return color(210, 180, 140);
            case SNOW: return color(255, 255, 255);
            default: return color(34, 139, 34);
        }
    }
    
    private int getTerrainSkyColor(TerrainType terrain) {
        switch(terrain) {
            case GRASS: return color(135, 206, 235);
            case DESERT: return color(255, 200, 150);
            case SNOW: return color(200, 225, 255);
            default: return color(135, 206, 235);
        }
    }
    
    private class Tank {
        float x;
        float y;
        float angle = 45;
        float power = 50;
        int health = INITIAL_HEALTH;
        int playerIndex;
        boolean isAlive = true;
        int direction; // 1 for right (Player 1), -1 for left (Player 2)
        
        Tank(float x, int playerIndex) {
            this.x = x;
            this.playerIndex = playerIndex;
            // Set initial direction based on player index
            this.direction = (playerIndex == 0) ? 1 : -1;
            // Set initial angle based on direction
            this.angle = (playerIndex == 0) ? 45 : 135;
        }
        
        int getColor() {
            return playerIndex == 0 ? color(0, 100, 0) : color(100, 0, 0);
        }
        
        void move(float dx) {
            float newX = x + dx;
            // Check boundaries and minimum distance from other tank
            if (newX >= 0 && newX <= width - TANK_WIDTH) {
                Tank otherTank = tanks[playerIndex == 0 ? 1 : 0];
                float distance = abs(newX - otherTank.x);
                if (distance >= MIN_TANK_DISTANCE) {
                    x = newX;
                }
            }
        }
        
        void takeDamage(int damage) {
            health -= damage;
            if (health <= 0) {
                health = 0;
                isAlive = false;
            }
        }
    }
        
 
    
    @Override
    public void settings() {
        size(800, 600);
    }
    
    @Override
    public void setup() {
        frameRate(60);
        tanks = new Tank[2];
        tanks[0] = new Tank(width * 0.2f, 0);
        tanks[1] = new Tank(width * 0.8f - TANK_WIDTH, 1);
        
        for (Tank tank : tanks) {
            tank.y = height - GROUND_HEIGHT - TANK_HEIGHT;
        }
    }
    
    private void drawTerrain() {
        noStroke();
        fill(getTerrainGroundColor(currentTerrain));
        rect(0, height - GROUND_HEIGHT, width, GROUND_HEIGHT);
    }
    
    private void drawTank(Tank tank, boolean isActive) {
        // Save the current transformation matrix
        pushMatrix();
        
        // Move to tank position
        translate(tank.x + TANK_WIDTH/2, tank.y + TANK_HEIGHT/2);
        
        // Flip tank 2 horizontally and vertically
        if (tank.direction == -1) {  // Player 2
            scale(-1, -1);
        }
        
        // Draw tank body relative to center point
        fill(tank.getColor());
        rect(-TANK_WIDTH/2, -TANK_HEIGHT/2, TANK_WIDTH, TANK_HEIGHT);
        
        // Draw tank barrel
        stroke(tank.getColor());
        strokeWeight(4);
        float barrelLength = 30;
        float angle;
        if (tank.direction == 1) {  // Player 1
            angle = radians(-tank.angle);
        } else {  // Player 2
            angle = radians(tank.angle);  // Changed to positive angle for Tank 2
        }
        
        float barrelEndX = cos(angle) * barrelLength;
        float barrelEndY = sin(angle) * barrelLength;
        line(0, 0, barrelEndX, barrelEndY);
        
        popMatrix();
        
        // Health bar in screen coordinates
        noStroke();
        float healthBarWidth = 40;
        float healthBarHeight = 5;
        float healthPercentage = tank.health / (float)INITIAL_HEALTH;
        
        fill(255, 0, 0);
        rect(tank.x, tank.y - 10, healthBarWidth, healthBarHeight);
        
        fill(0, 255, 0);
        rect(tank.x, tank.y - 10, healthBarWidth * healthPercentage, healthBarHeight);
        
        if (isActive) {
            noFill();
            stroke(255, 255, 0);
            strokeWeight(2);
            rect(tank.x - 2, tank.y - 12, TANK_WIDTH + 4, TANK_HEIGHT + 14);
        }
    }
    
    private void drawAimLine(Tank tank) {
        pushMatrix();
        translate(tank.x + TANK_WIDTH/2, tank.y + TANK_HEIGHT/2);
        
        if (tank.direction == -1) {  // Player 2
            scale(-1, -1);
        }
        
        stroke(255, 255, 0, 128);
        strokeWeight(1);
        float angle;
        if (tank.direction == 1) {  // Player 1
            angle = radians(-tank.angle);
        } else {  // Player 2
            angle = radians(tank.angle);  // Changed to positive angle for Tank 2
        }
        
        float lineLength = tank.power * 2;
        float endX = cos(angle) * lineLength;
        float endY = sin(angle) * lineLength;
        line(0, 0, endX, endY);
        
        popMatrix();
    }

    
    private void drawProjectile() {
        if (projectileActive) {
            fill(getWeaponColor(currentWeapon));
            noStroke();
            ellipse(projectileX, projectileY, 8, 8);
        }
    }
    
    private void drawExplosion() {
        if (explosionFrames < EXPLOSION_DURATION) {
            float size = map(explosionFrames, 0, EXPLOSION_DURATION, 10, 30);
            fill(255, 165, 0, 200);
            ellipse(explosionX, explosionY, size, size);
            fill(255, 69, 0, 150);
            ellipse(explosionX, explosionY, size * 0.7f, size * 0.7f);
            explosionFrames++;
        } else {
            showExplosion = false;
            explosionFrames = 0;
        }
    }
    
    @Override
    public void draw() {
        background(getTerrainSkyColor(currentTerrain));
        drawTerrain();
        
        for (int i = 0; i < tanks.length; i++) {
            if (tanks[i].isAlive) {
                drawTank(tanks[i], i == currentPlayer && !gameOver);
            }
        }
        
        if (!projectileActive && !gameOver && tanks[currentPlayer].isAlive) {
            drawAimLine(tanks[currentPlayer]);
        }
        
        if (projectileActive) {
            updateProjectile();
            drawProjectile();
        }
        
        if (showExplosion) {
            drawExplosion();
        }
        
        drawUI();
        checkGameOver();
    }
    
    private void updateProjectile() {
        if (projectileActive) {
            projectileX += velocityX;
            projectileY += velocityY;
            velocityY += GRAVITY;
            
            for (Tank tank : tanks) {
                if (tank.isAlive && checkTankHit(tank, projectileX, projectileY)) {
                    tank.takeDamage(currentWeapon.damage);
                    triggerExplosion(projectileX, projectileY);
                    projectileActive = false;
                    nextTurn();
                    return;
                }
            }
            
            if (projectileY > height - GROUND_HEIGHT) {
                triggerExplosion(projectileX, height - GROUND_HEIGHT);
                projectileActive = false;
                nextTurn();
            }
            
            if (projectileX < 0 || projectileX > width) {
                projectileActive = false;
                nextTurn();
            }
        }
    }
    
    private void drawUI() {
        if (!gameOver) {
            Tank currentTank = tanks[currentPlayer];
            
            fill(0);
            textSize(16);
            textAlign(LEFT);
            text("Player " + (currentPlayer + 1) + "'s turn", 10, 20);
            if (currentTank.isAlive) {
                text("Angle: " + nf(currentTank.angle, 0, 1) + "°", 10, 40);
                text("Power: " + nf(currentTank.power, 0, 1), 10, 60);
                text("Weapon: " + currentWeapon, 10, 80);
            }
            
            textAlign(RIGHT);
            textSize(14);
            text("Controls:", width - 10, 20);
            text("LEFT/RIGHT - Move tank", width - 10, 40);
            text("A/D - Adjust angle", width - 10, 60);
            text("W/S - Adjust power", width - 10, 80);
            text("SPACE - Fire", width - 10, 100);
            text("1/2/3 - Change weapon", width - 10, 120);
        }
    }
    
    private void checkGameOver() {
        int aliveTanks = 0;
        int winnerIndex = -1;
        
        for (int i = 0; i < tanks.length; i++) {
            if (tanks[i].isAlive) {
                aliveTanks++;
                winnerIndex = i;
            }
        }
        
        if (aliveTanks <= 1) {
            gameOver = true;
            textAlign(CENTER);
            textSize(32);
            fill(255, 0, 0);
            if (winnerIndex != -1) {
                text("Player " + (winnerIndex + 1) + " Wins!", width/2, height/2);
            } else {
                text("Draw!", width/2, height/2);
            }
        }
    }
    
    private void triggerExplosion(float x, float y) {
        showExplosion = true;
        explosionX = x;
        explosionY = y;
        explosionFrames = 0;
    }
    
    private boolean checkTankHit(Tank tank, float projX, float projY) {
        return projX >= tank.x && projX <= tank.x + TANK_WIDTH &&
               projY >= tank.y && projY <= tank.y + TANK_HEIGHT;
    }
    
    private void fireProjectile() {
        Tank currentTank = tanks[currentPlayer];
        projectileX = currentTank.x + TANK_WIDTH/2;
        projectileY = currentTank.y + TANK_HEIGHT/2;
        
        float angle;
        if (currentTank.direction == 1) {  // Player 1
            angle = radians(-currentTank.angle);  // Negative angle for right direction
        } else {  // Player 2
            angle = radians(currentTank.angle + 180);  // Positive angle + 180 for left direction
        }
        
        float speed = currentTank.power * 0.5f * currentWeapon.speedMultiplier;
        velocityX = cos(angle) * speed;
        velocityY = sin(angle) * speed;
        
        projectileActive = true;
    }

    
    
    private void nextTurn() {
        do {
            currentPlayer = (currentPlayer + 1) % 2;
        } while (!tanks[currentPlayer].isAlive && !gameOver);
    }
    
    @Override
    public void keyPressed() {
        if (!projectileActive && !gameOver && tanks[currentPlayer].isAlive) {
            Tank currentTank = tanks[currentPlayer];
            float angleSpeed = 5;
            float powerSpeed = 2;
            
            switch (keyCode) {
                case LEFT:
                    currentTank.move(-TANK_MOVE_SPEED);
                    break;
                case RIGHT:
                    currentTank.move(TANK_MOVE_SPEED);
                    break;
            }
            
            switch (key) {
                case 'a':
                case 'A':
                    currentTank.angle = constrain(currentTank.angle + angleSpeed, 0, 90);
                    break;
                case 'd':
                case 'D':
                    currentTank.angle = constrain(currentTank.angle - angleSpeed, 0, 90);
                    break;
                case 'w':
                case 'W':
                    currentTank.power = constrain(currentTank.power + powerSpeed, 0, 100);
                    break;
                case 's':
                case 'S':
                    currentTank.power = constrain(currentTank.power - powerSpeed, 0, 100);
                    break;
                case ' ':
                    fireProjectile();
                    break;
                case '1':
                    currentWeapon = Weapon.CANNONBALL;
                    break;
                case '2':
                    currentWeapon = Weapon.MISSILE;
                    break;
                case '3':
                    currentWeapon = Weapon.MORTAR;
                    break;
            }
        }
    }
    
    public static void main(String[] args) {
        PApplet.main("com.example.TankWar.ui.GameSketch");
    }
}