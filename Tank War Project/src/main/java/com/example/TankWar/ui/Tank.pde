class Tank {
  float x, y;
  float speed = 3;
  color tankColor;
  float health = 100;
  float tankWidth = 60;
  float tankHeight = 40;
  float turretAngle = 0;

  String[] weapons = {"bullet", "missile", "plasma"};
  int selectedWeapon = 0;
  int fireCooldown = 0;
  PImage tankImg;
  boolean isPlayer1;

  // Power-up effects
  boolean hasShield = false;
  float speedBoost = 1.0;
  float rapidFire = 1.0;

  // Movement flags
  boolean movingUp = false;
  boolean movingDown = false;
  boolean movingLeft = false;
  boolean movingRight = false;

  Tank(float x, float y, color tankColor, boolean isPlayer1, PImage tankImg) {
    this.x = x;
    this.y = y;
    this.tankColor = tankColor;
    this.isPlayer1 = isPlayer1;
    this.tankImg = tankImg;
  }

  void update(ArrayList<Barrier> barriers, Tank otherTank) {
    // Movement
    float moveX = 0;
    float moveY = 0;

    if (movingLeft) moveX -= speed * speedBoost;
    if (movingRight) moveX += speed * speedBoost;
    if (movingUp) moveY -= speed * speedBoost;
    if (movingDown) moveY += speed * speedBoost;

    // Normalize diagonal movement
    if (moveX != 0 && moveY != 0) {
      moveX *= 0.7071; // Approximate 1/sqrt(2) for diagonal speed
      moveY *= 0.7071;
    }

    // Calculate new position
    float newX = x + moveX;
    float newY = y + moveY;

    // Boundary check (using battlefield coordinates)
    newX = constrain(newX, battlefieldX, battlefieldX + battlefieldWidth - tankWidth);
    newY = constrain(newY, battlefieldY, battlefieldY + battlefieldHeight - tankHeight);

    // Store potential position before collision check
    float prevX = x;
    float prevY = y;
    x = newX;
    y = newY;

    // Collision checks and rollback if needed
    // Barrier collision check
    for (Barrier b : barriers) {
      if (x + tankWidth > b.x && x < b.x + b.w &&
          y + tankHeight > b.y && y < b.y + b.h) {
        // Simple rollback: move back to previous position
        x = prevX;
        y = prevY;
        break;
      }
    }

    // Tank-to-tank collision check
    if (x + tankWidth > otherTank.x && x < otherTank.x + otherTank.tankWidth &&
        y + tankHeight > otherTank.y && y < otherTank.y + otherTank.tankHeight) {
      // Simple rollback: move back to previous position
      x = prevX;
      y = prevY;
    }

    // Update turret angle
    if (isPlayer1) {
      turretAngle = atan2(mouseY - (y + tankHeight/2), mouseX - (x + tankWidth/2));
    } else {
      // AI aiming at opponent's center
      turretAngle = atan2((otherTank.y + otherTank.tankHeight/2) - (y + tankHeight/2),
                          (otherTank.x + otherTank.tankWidth/2) - (x + tankWidth/2));
      // Basic AI firing
      if (fireCooldown == 0 && dist(x,y,otherTank.x, otherTank.y) < 400 && random(1) < 0.02) { // Fire when close and randomly
        fire();
      }
    }

    // Update cooldown
    if (fireCooldown > 0) fireCooldown--;
  }

  void display(boolean showHealth) {
    pushMatrix();
    translate(x + tankWidth/2, y + tankHeight/2);

    // Draw shield effect if active
    if (hasShield) {
      noFill();
      stroke(tankColor, 150);
      strokeWeight(3);
      ellipse(0, 0, tankWidth * 1.3f, tankHeight * 1.3f); // Slightly larger shield
    }

    // Draw tank body
    imageMode(CENTER);
    image(tankImg, 0, 0, tankWidth, tankHeight);

    // Draw turret
    rotate(turretAngle);
    fill(tankColor);
    noStroke();
    rect(0, -5, 30, 10); // Turret barrel

    popMatrix();

    if (showHealth) {
      // Draw health bar above tank
      float barWidth = tankWidth;
      float barHeight = 5;
      float healthPercent = constrain(health / 100.0f, 0, 1);

      fill(80);
      noStroke();
      rect(x, y - barHeight - 2, barWidth, barHeight);
      fill(lerpColor(color(255, 0, 0), color(0, 255, 0), healthPercent));
      rect(x, y - barHeight - 2, barWidth * healthPercent, barHeight);
      noFill();
      stroke(255);
      rect(x, y - barHeight - 2, barWidth, barHeight);
      noStroke();
    }
  }

  void fire() {
    if (fireCooldown > 0) return;

    String weaponType = weapons[selectedWeapon];
    // Projectile starts slightly in front of the tank barrel
    float px = x + tankWidth/2 + cos(turretAngle) * (tankWidth/2 + 5);
    float py = y + tankHeight/2 + sin(turretAngle) * (tankHeight/2 + 5);
    float projSpeed = 8;
    float dx = cos(turretAngle) * projSpeed;
    float dy = sin(turretAngle) * projSpeed;

    float damage = 10;
    float radius = 8;
    int cooldown = 20;

    switch(weaponType) {
      case "bullet":
        // Defaults are fine
        break;
      case "missile":
        damage = 15;
        radius = 10;
        cooldown = 40;
        break;
      case "plasma":
        damage = 20;
        radius = 12;
        cooldown = 60;
        break;
    }

    projectiles.add(new Projectile(px, py, dx, dy, tankColor, damage, radius, weaponType));
    fireCooldown = (int)(cooldown / rapidFire);
  }

  void takeDamage(float amount) {
    if (hasShield) {
      hasShield = false; // Shield absorbs one hit
      return;
    }
    health -= amount;
    if (health < 0) health = 0;

    // Optional: Add some visual feedback when hit
    for (int i = 0; i < 10; i++) {
      particles.add(new Particle(
        x + random(tankWidth), y + random(tankHeight),
        random(-2, 2), random(-2, 2),
        color(255, 0, 0), random(3, 8), 30
      ));
    }
  }

  String getCurrentWeapon() {
    return weapons[selectedWeapon];
  }

  void applyPowerUp(PowerUp p) {
    p.active = false; // Deactivate power-up after collection
    switch(p.type) {
      case "health":
        health = min(health + 30, 100);
        break;
      case "shield":
        hasShield = true;
        break;
      case "speed":
        speedBoost = 1.5f;
        // Add timer to global timers list
        timers.add(new Timer(10000, () -> speedBoost = 1.0f));
        break;
      case "rapid":
        rapidFire = 2.0f;
        // Add timer to global timers list
        timers.add(new Timer(10000, () -> rapidFire = 1.0f));
        break;
    }
    // Optional: Add particle effect for power-up collection
    for (int i = 0; i < 15; i++) {
        particles.add(new Particle(p.x, p.y, random(-1, 1), random(-1, 1), p.c, random(5, 10), 30));
    }
  }

  void handleKeyPressed(int k, boolean pressed) {
    if (isPlayer1) {
      switch(k) {
        case 'w': case 'W': movingUp = pressed; break;
        case 's': case 'S': movingDown = pressed; break;
        case 'a': case 'A': movingLeft = pressed; break;
        case 'd': case 'D': movingRight = pressed; break;
        case ' ': if (pressed) fire(); break;
        case 'q': case 'Q': if (pressed) selectedWeapon = (selectedWeapon + 1) % weapons.length; break;
        case '1': if (pressed) selectedWeapon = 0; break;
        case '2': if (pressed) selectedWeapon = 1; break;
        case '3': if (pressed) selectedWeapon = 2; break;
      }
    } else {
      switch(k) {
        case UP: movingUp = pressed; break;
        case DOWN: movingDown = pressed; break;
        case LEFT: movingLeft = pressed; break;
        case RIGHT: movingRight = pressed; break;
        case 'l': case 'L': if (pressed) fire(); break;
        case 'k': case 'K': if (pressed) selectedWeapon = (selectedWeapon + 1) % weapons.length; break;
        case '8': if (pressed) selectedWeapon = 0; break;
        case '9': if (pressed) selectedWeapon = 1; break;
        case '0': if (pressed) selectedWeapon = 2; break;
      }
    }
  }
}
