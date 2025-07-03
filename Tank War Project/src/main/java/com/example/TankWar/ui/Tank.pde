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
      moveX *= 0.7071;
      moveY *= 0.7071;
    }
    
    // Calculate new position
    float newX = x + moveX;
    float newY = y + moveY;
    
    // Boundary check
    newX = constrain(newX, battlefieldX, battlefieldX + battlefieldWidth - tankWidth);
    newY = constrain(newY, battlefieldY, battlefieldY + battlefieldHeight - tankHeight);
    
    // Barrier collision check
    boolean canMove = true;
    for (Barrier b : barriers) {
      if (newX + tankWidth > b.x && newX < b.x + b.w &&
          newY + tankHeight > b.y && newY < b.y + b.h) {
        canMove = false;
        break;
      }
    }
    
    // Tank-to-tank collision check
    if (newX + tankWidth > otherTank.x && newX < otherTank.x + otherTank.tankWidth &&
        newY + tankHeight > otherTank.y && newY < otherTank.y + otherTank.tankHeight) {
      canMove = false;
    }
    
    if (canMove) {
      x = newX;
      y = newY;
    }
    
    // Update turret angle
    if (isPlayer1) {
      turretAngle = atan2(mouseY - (y + tankHeight/2), mouseX - (x + tankWidth/2));
    } else {
      turretAngle = atan2(tank1.y - y, tank1.x - x);
    }
    
    // Update cooldown
    if (fireCooldown > 0) fireCooldown--;
  }

  void display(boolean showHealth) {
  pushMatrix();
  translate(x + tankWidth/2, y + tankHeight/2);
  
  // Draw tank body
  imageMode(CENTER);
  if (hasShield) {
    fill(tankColor, 100);
    ellipse(0, 0, tankWidth * 1.5f, tankHeight * 1.5f);
  }
  image(tankImg, 0, 0, tankWidth, tankHeight);
  
  // Draw turret
  rotate(turretAngle);
  fill(tankColor);
  rect(0, -5, 30, 10);
  
  popMatrix();
  
  if (showHealth) {
    // Draw health bar above tank
    float barWidth = tankWidth;
    float barHeight = 5;
    float healthPercent = constrain(health / 100.0f, 0, 1);
    
    fill(80);
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
    float px = x + tankWidth/2 + cos(turretAngle) * 30;
    float py = y + tankHeight/2 + sin(turretAngle) * 30;
    float speed = 8;
    float dx = cos(turretAngle) * speed;
    float dy = sin(turretAngle) * speed;
    
    float damage = 10;
    float radius = 8;
    int cooldown = 20;
    
    switch(weaponType) {
      case "bullet":
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
      hasShield = false;
      return;
    }
    health -= amount;
    if (health < 0) health = 0;
  }

  String getCurrentWeapon() {
    return weapons[selectedWeapon];
  }
  
  void applyPowerUp(PowerUp p) {
    switch(p.type) {
      case "health":
        health = min(health + 30, 100);
        break;
      case "shield":
        hasShield = true;
        break;
      case "speed":
        speedBoost = 1.5f;
        new Timer(10000, () -> speedBoost = 1.0f);
        break;
      case "rapid":
        rapidFire = 2.0f;
        new Timer(10000, () -> rapidFire = 1.0f);
        break;
    }
  }
  
  void handleKeyPressed(int key, boolean pressed) {
    if (isPlayer1) {
      switch(key) {
        case 'w': case 'W': movingUp = pressed; break;
        case 's': case 'S': movingDown = pressed; break;
        case 'a': case 'A': movingLeft = pressed; break;
        case 'd': case 'D': movingRight = pressed; break;
        case ' ': if (pressed) fire(); break;
        case 'q': case 'Q': if (pressed) selectedWeapon = (selectedWeapon + 1) % weapons.length; break;
      }
    } else {
      switch(key) {
        case UP: movingUp = pressed; break;
        case DOWN: movingDown = pressed; break;
        case LEFT: movingLeft = pressed; break;
        case RIGHT: movingRight = pressed; break;
        case 'l': case 'L': if (pressed) fire(); break;
        case 'k': case 'K': if (pressed) selectedWeapon = (selectedWeapon + 1) % weapons.length; break;
      }
    }
  }
}

// Helper class for timed power-ups
class Timer {
  int startTime;
  int duration;
  Runnable callback;
  boolean done = false;
  
  Timer(int duration, Runnable callback) {
    this.startTime = millis();
    this.duration = duration;
    this.callback = callback;
  }
  
  void update() {
    if (!done && millis() - startTime > duration) {
      callback.run();
      done = true;
    }
  }
  
  boolean isDone() {
    return done;
  }
}
