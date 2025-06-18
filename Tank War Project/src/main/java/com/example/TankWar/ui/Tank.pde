class Tank {
  float x, y;
  float speed = 2;
  int tankColor;
  boolean left, right, up, down;
  float health = 100;
  float tankWidth = 40;
  float tankHeight = 20;
  String[] weapons = {"normal", "heavy", "rapid"};
  int selectedWeapon = 0;
  int fireCooldown = 0;


  
  Tank(float x, float y, int tankColor) {
    this.x = x;
    this.y = y;
    this.tankColor = tankColor;
  }

  void update() {
    if (left) x -= speed;
    if (right) x += speed;
    if (up) y -= speed;
    if (down) y += speed;

    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
    if (fireCooldown > 0) fireCooldown--;
  }
  
  void switchWeapon() {
  selectedWeapon = (selectedWeapon + 1) % weapons.length;
}


  void display() {
  // Tank body
  fill(tankColor);
  rect(x, y, tankWidth, tankHeight);
  rect(x + 15, y - 10, 10, 10);  // Turret

  // Health bar background
  fill(100);
  rect(x, y - 20, tankWidth, 5);
  
  // Health bar foreground
  fill(0, 255, 0);
  float healthWidth = map(health, 0, 100, 0, tankWidth);
  rect(x, y - 20, healthWidth, 5);
}


  void handleKeyPressed(char key, boolean isPressed) {
   if (this == tank1) {
  if (key == 'a') left = isPressed;
  if (key == 'd') right = isPressed;
  if (key == 'w') up = isPressed;
  if (key == 's') down = isPressed;
  if (key == ' ') {
    if (isPressed && fireCooldown == 0) fire();
  }
  if (key == 'q' && isPressed) switchWeapon();
} else if (this == tank2) {
  if (keyCode == LEFT) left = isPressed;
  if (keyCode == RIGHT) right = isPressed;
  if (keyCode == UP) up = isPressed;
  if (keyCode == DOWN) down = isPressed;
  if (key == 'l') {
    if (isPressed && fireCooldown == 0) fire();
  }
  if (key == 'k' && isPressed) switchWeapon();
}

  }

void fire() {
  String weapon = weapons[selectedWeapon];

  if (this == tank1) {
    if (weapon.equals("normal")) {
      projectiles.add(new Projectile(x + 40, y + 5, 6, 0, tankColor, 10));
      fireCooldown = 20;
    } else if (weapon.equals("heavy")) {
      projectiles.add(new Projectile(x + 40, y + 5, 3, 0, tankColor, 25, 12));
      fireCooldown = 40;
    } else if (weapon.equals("rapid")) {
      projectiles.add(new Projectile(x + 40, y + 5, 8, 0, tankColor, 5));
      fireCooldown = 10;
    }
  } else {
    if (weapon.equals("normal")) {
      projectiles.add(new Projectile(x - 5, y + 5, -6, 0, tankColor, 10));
      fireCooldown = 20;
    } else if (weapon.equals("heavy")) {
      projectiles.add(new Projectile(x - 5, y + 5, -3, 0, tankColor, 25, 12));
      fireCooldown = 40;
    } else if (weapon.equals("rapid")) {
      projectiles.add(new Projectile(x - 5, y + 5, -8, 0, tankColor, 5));
      fireCooldown = 10;
    }
  }
}


}
