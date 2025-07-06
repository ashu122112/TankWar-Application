// Tank.pde - Class definition
import ddf.minim.*; // Import the Minim library for audio

class Tank {
  float x, y;
  float speed = 3.78; // Reduced tank speed by an additional 30% (was 5.4, now 5.4 * 0.7 = 3.78)
  color tankColor;
  float health = 100;
  // These are the default dimensions. If you load images,
  // you might want to adjust these based on image.width/height if images vary.
  float tankWidth = 60;
  float tankHeight = 40;
  float tankRotationAngle = 0; // Controls the entire tank's rotation (body + fixed barrel)

  String[] weapons = {"bullet", "missile", "plasma"};
  int selectedWeapon = 0;
  int fireCooldown = 0;
  PImage tankImg; // Image for the tank body (e.g., tankBody_bigRed_outline.png)
  // tankBarrelImg is a global PImage in GameSketch.pde and accessed directly here.
  boolean isPlayer1;
  boolean isAI; // New: Flag to determine if this tank is AI controlled

  // Power-up effects
  boolean hasShield = false;
  float speedBoost = 1.0;
  float rapidFire = 1.0;

  // Movement flags - controlled by handleKeyPressed/keyReleased
  boolean movingUp = false;
  boolean movingDown = false;
  boolean movingLeft = false;
  boolean movingRight = false;

  // AI specific variables
  String aiState = "attack"; // "attack", "dodge", "retreat"
  int aiStateTimer = 0; // Timer for how long AI stays in a specific state (e.g., dodging)
  int weaponChangeTimer = 0; // Timer for when AI should consider changing weapon
  float dodgeDirectionX = 0;
  float dodgeDirectionY = 0;


  // Constructor
  Tank(float x, float y, color tankColor, boolean isPlayer1, PImage tankImg, boolean isAI) {
    this.x = x;
    this.y = y;
    this.tankColor = tankColor;
    this.isPlayer1 = isPlayer1;
    this.tankImg = tankImg;
    this.isAI = isAI; // Initialize the AI flag
    // Note: tankWidth and tankHeight are fixed here. If your images are different sizes,
    // you might want to set them based on tankImg.width and tankImg.height here.
  }

  void update(ArrayList<Barrier> barriers, Tank otherTank, String currentTerrain) {
    // AI Logic (if this tank is AI controlled)
    if (this.isAI) {
      // Decrement timers
      if (aiStateTimer > 0) aiStateTimer--;
      if (weaponChangeTimer > 0) weaponChangeTimer--;

      // --- AI State Management ---
      // Prioritize dodging
      boolean dodging = false;
      // Access global projectiles list
      for (Projectile p : projectiles) {
        // Corrected: Use p.pColor to compare with this tank's color
        if (p.pColor != this.tankColor) { // Only consider projectiles from the other tank
          // Calculate distance to projectile
          float distToProj = dist(this.x + tankWidth/2, this.y + tankHeight/2, p.x, p.y);
          float projSpeed = sqrt(p.dx * p.dx + p.dy * p.dy);

          // Estimate time to impact (simple linear prediction)
          float timeToImpact = distToProj / projSpeed;

          // Calculate projectile's current angle from its velocity components
          float projAngle = atan2(p.dy, p.dx);

          // Check if projectile is heading towards the tank and is close enough to dodge
          // This is a simplified check. A more accurate one would involve projecting the projectile's path.
          if (distToProj < 150 && timeToImpact < 30 && abs(atan2(p.y - (this.y + tankHeight/2), p.x - (this.x + tankWidth/2)) - projAngle) < PI/4) {
            // Projectile is close and generally heading towards us
            aiState = "dodge";
            aiStateTimer = 30; // Dodge for 0.5 seconds (30 frames at 60fps)
            // Determine dodge direction (perpendicular to projectile's incoming path)
            float perpAngle = projAngle + HALF_PI; // Rotate 90 degrees
            if (random(1) > 0.5) perpAngle = projAngle - HALF_PI; // Randomly choose left or right dodge
            dodgeDirectionX = cos(perpAngle);
            dodgeDirectionY = sin(perpAngle);
            dodging = true;
            break;
          }
        }
      }

      if (!dodging && aiStateTimer <= 0) {
        aiState = "attack"; // Revert to attack if not dodging and dodge timer is over
      }

      // --- AI Movement ---
      movingUp = false;
      movingDown = false;
      movingLeft = false;
      movingRight = false;

      if (aiState.equals("dodge")) {
        // Move in the calculated dodge direction
        if (dodgeDirectionX > 0.1) movingRight = true;
        else if (dodgeDirectionX < -0.1) movingLeft = true;
        if (dodgeDirectionY > 0.1) movingDown = true;
        else if (dodgeDirectionY < -0.1) movingUp = true;
      } else { // "attack" state
        // Move towards the player with some randomness
        float dxToTarget = otherTank.x - this.x;
        float dyToTarget = otherTank.y - this.y;

        // Add some random strafing/wobble
        if (frameCount % 60 < 30) { // Every second, for half a second, add side movement
            if (dxToTarget > 0) movingRight = true; else movingLeft = true;
            if (random(1) > 0.7) { // 30% chance to strafe vertically
                if (dyToTarget > 0) movingUp = true; else movingDown = true; // Move away from target vertically
            }
        } else {
            if (dyToTarget > 0) movingDown = true; else movingUp = true;
            if (random(1) > 0.7) { // 30% chance to strafe horizontally
                if (dxToTarget > 0) movingLeft = true; else movingRight = true; // Move away from target horizontally
            }
        }

        // Simple obstacle avoidance (rudimentary: if a barrier is directly in the path, try to move perpendicular)
        float lookAheadDist = speed * speedBoost * 10; // Look a bit further ahead
        PVector currentPos = new PVector(x + tankWidth/2, y + tankHeight/2);
        PVector futurePos = new PVector(x + (movingRight ? lookAheadDist : (movingLeft ? -lookAheadDist : 0)),
                                        y + (movingDown ? lookAheadDist : (movingUp ? -lookAheadDist : 0)));

        for (Barrier b : barriers) {
          if (collideRectRect(futurePos.x, futurePos.y, tankWidth, tankHeight, b.x, b.y, b.w, b.h)) {
            // Collision detected, try to move perpendicular
            if (movingRight || movingLeft) {
              movingRight = false; movingLeft = false;
              if (random(1) > 0.5) movingUp = true; else movingDown = true;
            } else if (movingUp || movingDown) {
              movingUp = false; movingDown = false;
              if (random(1) > 0.5) movingLeft = true; else movingRight = true;
            }
            aiStateTimer = 10; // Stay in this avoidance state briefly
            break;
          }
        }
      }


      // --- AI Weapon Selection ---
      if (weaponChangeTimer <= 0) {
        float distToPlayer = dist(this.x, this.y, otherTank.x, otherTank.y);
        if (distToPlayer < 200) { // Close range
          selectedWeapon = 2; // Plasma
        } else if (distToPlayer < 400) { // Medium range
          selectedWeapon = 1; // Missile
        } else { // Long range
          selectedWeapon = 0; // Bullet
        }
        weaponChangeTimer = (int)random(60, 180); // Change weapon every 1-3 seconds
      }

      // --- AI Firing Logic ---
      float angleToOtherTank = atan2((otherTank.y + otherTank.tankHeight/2) - (y + tankHeight/2),
                                      (otherTank.x + otherTank.tankWidth/2) - (x + tankWidth/2));
      float angleTolerance = PI/16; // Tighter angle tolerance for firing

      float currentAngle = tankRotationAngle;
      float diff = angleToOtherTank - currentAngle;
      if (diff > PI) diff -= TWO_PI;
      if (diff < -PI) diff += TWO_PI;

      // If the other tank is roughly in front and cooldown is ready
      if (abs(diff) < angleTolerance && fireCooldown == 0) {
          // More robust line-of-sight check: Raycasting
          boolean lineOfSightClear = true;
          PVector startPoint = new PVector(x + tankWidth/2, y + tankHeight/2);
          PVector endPoint = new PVector(otherTank.x + otherTank.tankWidth/2, otherTank.y + otherTank.tankHeight/2);

          for (Barrier b : barriers) {
              // Check if the line segment (startPoint to endPoint) intersects the barrier's rectangle
              if (lineRect(startPoint.x, startPoint.y, endPoint.x, endPoint.y, b.x, b.y, b.w, b.h)) {
                  lineOfSightClear = false;
                  break;
              }
          }
          if (lineOfSightClear && random(1) > 0.2) { // 80% chance to fire if clear (adds human-like hesitation)
              fire();
          }
      }
    }


    // Calculate desired movement based on input flags and speed boost
    float moveX = 0;
    float moveY = 0;

    if (movingLeft) moveX -= speed * speedBoost;
    if (movingRight) moveX += speed * speedBoost;
    if (movingUp) moveY -= speed * speedBoost;
    if (movingDown) moveY += speed * speedBoost;

    // Normalize diagonal movement to prevent faster diagonal speed
    if (moveX != 0 && moveY != 0) {
      moveX *= 0.7071; // Approximate 1/sqrt(2)
      moveY *= 0.7071;
    }

    // Calculate potential new position
    float newX = x + moveX;
    float newY = y + moveY;

    // Constrain new position within battlefield boundaries
    newX = constrain(newX, battlefieldX, battlefieldX + battlefieldWidth - tankWidth);
    newY = constrain(newY, battlefieldY, battlefieldY + battlefieldHeight - tankHeight);

    // Store current position for collision rollback
    float prevX = x;
    float prevY = y;

    // --- Collision Detection and Rollback ---
    // Attempt to move horizontally first and check collisions
    x = newX; // Apply potential X movement
    // Check against barriers
    for (Barrier b : barriers) {
      if (x + tankWidth > b.x && x < b.x + b.w &&
          y + tankHeight > b.y && y < b.y + b.h) {
        x = prevX; // Collision detected, revert X movement
        break; // Only revert once per barrier
      }
    }
    // Check against other tank
    if (x + tankWidth > otherTank.x && x < otherTank.x + otherTank.tankWidth &&
        y + tankHeight > otherTank.y && y < otherTank.y + otherTank.tankHeight) {
      x = prevX; // Collision detected, revert X movement
    }

    // Attempt to move vertically and check collisions (after handling X)
    y = newY; // Apply potential Y movement
    // Check against barriers
    for (Barrier b : barriers) {
      if (x + tankWidth > b.x && x < b.x + b.w &&
          y + tankHeight > b.y && y < b.y + b.h) {
        y = prevY; // Collision detected, revert Y movement
        break; // Only revert once per barrier
      }
    }
    // Check against other tank
    if (x + tankWidth > otherTank.x && x < otherTank.x + otherTank.tankWidth &&
        y + tankHeight > otherTank.y && y < otherTank.y + otherTank.tankHeight) {
      y = prevY; // Collision detected, revert Y movement
    }
    // --- End Collision Detection ---


    // Tank Rotation: Make the tank body point towards the other tank
    // Calculate the target angle from this tank's center to the other tank's center
    float targetAngle = atan2((otherTank.y + otherTank.tankHeight/2) - (y + tankHeight/2),
                              (otherTank.x + otherTank.tankWidth/2) - (x + tankWidth/2));

    // Calculate the difference between current angle and target angle
    float angleDiff = targetAngle - tankRotationAngle;

    // Normalize angle difference to be within -PI to PI for the shortest rotation path
    if (angleDiff > PI) angleDiff -= TWO_PI;
    if (angleDiff < -PI) angleDiff += TWO_PI;

    // Smoothly interpolate the tank's rotation angle
    float rotationSpeed = 0.1; // Increased rotation speed for more responsiveness
    tankRotationAngle += angleDiff * rotationSpeed;

    // Keep angle within 0 to TWO_PI range for consistency
    tankRotationAngle = (tankRotationAngle + TWO_PI) % TWO_PI;


    // Update fire cooldown
    if (fireCooldown > 0) fireCooldown--;
  }

  void display(boolean showHealth) {
    pushMatrix(); // Save current transformation state
    translate(x + tankWidth/2, y + tankHeight/2); // Translate origin to tank's center for rotation

    // Draw shield effect if active
    if (hasShield) {
      noFill();
      stroke(tankColor, 150); // Semi-transparent shield color
      strokeWeight(3);
      ellipse(0, 0, tankWidth * 1.3f, tankHeight * 1.3f); // Slightly larger shield effect
    }

    // Apply the tank's overall rotation (for both body and barrel)
    rotate(tankRotationAngle); // Rotate the entire tank body based on its facing direction

    // Draw tank body (assuming tankImg is now barrel-less, or you accept two barrels)
    imageMode(CENTER); // Draw image from its center
    if (tankImg != null) { // Check if tank body image is loaded
        image(tankImg, 0, 0, tankWidth, tankHeight);
    } else {
        // Fallback if tank body image fails to load
        fill(tankColor);
        rect(-tankWidth/2, -tankHeight/2, tankWidth, tankHeight);
    }

    // Draw the separate, "immobile" barrel
    // It's immobile relative to the tank body, but rotates with the whole tank.
    if (tankBarrelImg != null) { // Check if the global barrel image is loaded
      pushMatrix(); // Save current transformation for barrel's local position
      // Translate to the attachment point of the barrel on the tank body
      // These values (e.g., tankWidth/2 - 10, 0) are crucial and need to be
      // adjusted to align the barrel perfectly with your tank body image.
      // tankWidth/2 is the front edge; subtracting 10 pulls it back slightly.
      translate(tankWidth/2 - 10, 0); // Adjust this X and Y offset as needed for your specific image

      // Apply tint for Player 1's barrel if it's the blue barrel image
      if (isPlayer1) {
        tint(255, 0, 0); // Apply red tint to the barrel for Player 1
      } else {
        noTint(); // No tint for Player 2, use original image color (blue)
      }

      image(tankBarrelImg, 0, 0, 30, 10); // Draw the barrel image. Adjust size (30, 10) as needed.
      noTint(); // Always reset tint after drawing to avoid affecting subsequent elements

      popMatrix(); // Restore transformation after drawing barrel
    } else {
        // Fallback for barrel if image not loaded
        fill(50); // Dark grey barrel
        rect(tankWidth/2 - 15, -2, 20, 4); // Simple rectangle for barrel (adjust position and size)
    }

    popMatrix(); // Restore original transformation matrix after tank drawing

    // Draw health bar below the tank (outside of tank's transformations)
    if (showHealth) {
      float barWidth = tankWidth;
      float barHeight = 5;
      float healthPercent = constrain(health / 100.0f, 0, 1);

      // Health bar background
      fill(80);
      noStroke();
      rect(x, y + tankHeight + 5, barWidth, barHeight); // Position below the tank body

      // Health bar foreground (lerpColor from red to green)
      fill(lerpColor(color(255, 0, 0), color(0, 255, 0), healthPercent));
      rect(x, y + tankHeight + 5, barWidth * healthPercent, barHeight);

      noFill();
      stroke(255); // White border around the health bar
      rect(x, y + tankHeight + 5, barWidth, barHeight); // Outline
      noStroke();
    }
  }

  void fire() {
    if (fireCooldown > 0) return; // Cannot fire if still in cooldown

    String weaponType = weapons[selectedWeapon];
    // Projectile starts slightly in front of the tank barrel, aligned with tankRotationAngle
    // Calculate projectile start position based on tank's center and its current rotation (fixed barrel direction)
    float projStartX = x + tankWidth/2 + cos(tankRotationAngle) * (tankWidth/2 + 5);
    float projStartY = y + tankHeight/2 + sin(tankRotationAngle) * (tankHeight/2 + 5);
    float projSpeed = 8;
    float dx = cos(tankRotationAngle) * projSpeed; // Projectile direction matches tank's facing
    float dy = sin(tankRotationAngle) * projSpeed;

    float damage = 10;
    float radius = 8;
    int cooldown = 10; // Base cooldown for "bullet"

    // Adjust projectile properties based on selected weapon type
    switch(weaponType) {
      case "bullet":
        // Default values apply, no change needed here
        break;
      case "missile":
        damage = 15;
        radius = 10;
        cooldown = (int)(20 * 0.7); // Reduced cooldown by 30% (20 * 0.7 = 14)
        break;
      case "plasma":
        damage = 20;
        radius = 12;
        cooldown = (int)(30 * 0.7); // Reduced cooldown by 30% (30 * 0.7 = 21)
        break;
    }

    // Add the new projectile to the global projectiles list (managed in GameSketch)
    projectiles.add(new Projectile(projStartX, projStartY, dx, dy, tankColor, damage, radius, weaponType));
    fireSound.trigger(); // Play fire sound effect
    // Apply rapid fire power-up effect to the cooldown
    fireCooldown = (int)(cooldown / rapidFire);
  }

  void takeDamage(float amount) {
    if (hasShield) {
      hasShield = false; // Shield absorbs one hit, then is gone
      return;
    }
    health -= amount;
    if (health < 0) health = 0; // Health cannot go below 0

    // Optional: Add visual feedback (particles) when the tank is hit
    for (int i = 0; i < 10; i++) {
      particles.add(new Particle(
        x + random(tankWidth), y + random(tankHeight), // Spawn particles randomly within tank area
        random(-2, 2), random(-2, 2), // Random velocity
        color(255, 0, 0, 200), // Reddish color for damage
        random(3, 8), // Random size
        30 // Lifespan
      ));
    }
  }

  String getCurrentWeapon() {
    return weapons[selectedWeapon];
  }

  void applyPowerUp(PowerUp p) {
    p.active = false; // Mark power-up as collected/inactive (it will be removed from list later)
    powerupSound.trigger(); // Play power-up sound effect
    switch(p.type) {
      case "health":
        health = min(health + 30, 100); // Add health, but not over max
        break;
      case "shield":
        hasShield = true; // Activate shield
        break;
      case "speed":
        speedBoost = 1.5f; // Apply speed boost
        // Add a timer to the global timers list to revert speed after duration
        timers.add(new Timer(10000, () -> speedBoost = 1.0f)); // 10 seconds duration
        break;
      case "rapid":
        rapidFire = 2.0f; // Apply rapid fire
        // Add a timer to the global timers list to revert rapid fire after duration
        timers.add(new Timer(10000, () -> rapidFire = 1.0f)); // 10 seconds duration
        break;
    }
    // Optional: Add particle effect for power-up collection
    for (int i = 0; i < 15; i++) {
        particles.add(new Particle(p.x, p.y, random(-1, 1), random(-1, 1), p.c, random(5, 10), 30));
    }
  }

  // This method is called from GameSketch's keyPressed/keyReleased
  void handleKeyPressed(int k, boolean pressed) {
    if (isAI) return; // AI tanks do not respond to keyboard input

    if (isPlayer1) {
      switch(k) {
        case 'w': case 'W': movingUp = pressed; break;
        case 's': case 'S': movingDown = pressed; break;
        case 'a': case 'A': movingLeft = pressed; break;
        case 'd': case 'D': movingRight = pressed; break;
        case ' ': if (pressed) fire(); break; // Fire on spacebar press
        case 'q': case 'Q': if (pressed) selectedWeapon = (selectedWeapon + 1) % weapons.length; break;
        case '1': if (pressed) selectedWeapon = 0; break; // Direct weapon selection
        case '2': if (pressed) selectedWeapon = 1; break;
        case '3': if (pressed) selectedWeapon = 2; break;
      }
    } else { // Player 2 controls
      switch(k) {
        case UP:    movingUp = pressed; break;
        case DOWN:  movingDown = pressed; break;
        case LEFT:  movingLeft = pressed; break;
        case RIGHT: movingRight = pressed; break;
        case 'l': case 'L': if (pressed) fire(); break; // Fire on 'L' press
        case 'k': case 'K': if (pressed) selectedWeapon = (selectedWeapon + 1) % weapons.length; break;
        case '8': if (pressed) selectedWeapon = 0; break; // Direct weapon selection
        case '9': if (pressed) selectedWeapon = 1; break;
        case '0': if (pressed) selectedWeapon = 2; break;
      }
    }
  }

  // Helper function for line-rectangle intersection (used by AI line of sight)
  boolean lineRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
    // Check if the line intersects any of the four sides of the rectangle
    boolean left = lineLine(x1, y1, x2, y2, rx, ry, rx, ry + rh);
    boolean right = lineLine(x1, y1, x2, y2, rx + rw, ry, rx + rw, ry + rh);
    boolean top = lineLine(x1, y1, x2, y2, rx, ry, rx + rw, ry);
    boolean bottom = lineLine(x1, y1, x2, y2, rx, ry + rh, rx + rw, ry + rh);

    // If any of the sides intersect, return true
    if (left || right || top || bottom) {
      return true;
    }
    return false;
  }

  // Helper function for line-line intersection (used by lineRect)
  boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    // calculate the direction of the lines
    float uA = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
    float uB = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));

    // if uA and uB are between 0-1, lines are colliding
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
      return true;
    }
    return false;
  }

  // Helper function for rectangle-rectangle collision (used by AI obstacle avoidance)
  boolean collideRectRect(float r1x, float r1y, float r1w, float r1h, float r2x, float r2y, float r2w, float r2h) {
    // are the rectangles overlapping in x and y?
    if (r1x + r1w >= r2x &&    // r1 right edge past r2 left
        r1x <= r2x + r2w &&    // r1 left edge past r2 right
        r1y + r1h >= r2y &&    // r1 bottom edge past r2 top
        r1y <= r2y + r2h) {    // r1 top edge past r2 bottom
      return true;
    }
    return false;
  }
}
