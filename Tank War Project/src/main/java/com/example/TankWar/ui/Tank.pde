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

  void update() {
    // Movement
    float moveX = 0;
    float moveY = 0;
    
    if (movingLeft) moveX -= speed;
    if (movingRight) moveX += speed;
    if (movingUp) moveY -= speed;
    if (movingDown) moveY += speed;
    
    // Normalize diagonal movement
    if (moveX != 0 && moveY != 0) {
      moveX *= 0.7071;
      moveY *= 0.7071;
    }
    
    // Update position
    x = constrain(x + moveX, 0, width - UI_PANEL_WIDTH - tankWidth);
    y = constrain(y + moveY, 0, height - tankHeight);
    
    // Update turret angle
    if (isPlayer1) {
      turretAngle = atan2(mouseY - (y + tankHeight/2), mouseX - (x + tankWidth/2));
    } else {
      turretAngle = atan2(tank1.y - y, tank1.x - x);
    }
    
    // Update cooldown
    if (fireCooldown > 0) fireCooldown--;
  }

  void display() {
    pushMatrix();
    translate(x + tankWidth/2, y + tankHeight/2);
    
    // Draw tank body
    imageMode(CENTER);
    image(tankImg, 0, 0, tankWidth, tankHeight);
    
    // Draw turret
    rotate(turretAngle);
    fill(tankColor);
    rect(0, -5, 30, 10);
    
    popMatrix();
  }

  void fire() {
    if (fireCooldown > 0) return;
    
    String weaponType = weapons[selectedWeapon];
    float px = x + tankWidth/2 + cos(turretAngle) * 30;
    float py = y + tankHeight/2 + sin(turretAngle) * 30;
    float speed = 8;
    float dx = cos(turretAngle) * speed;
    float dy = sin(turretAngle) * speed;
    
    projectiles.add(new Projectile(px, py, dx, dy, tankColor, 10, 8, weaponType));
    fireCooldown = 20;
  }

  String getCurrentWeapon() {
    return weapons[selectedWeapon];
  }
}
