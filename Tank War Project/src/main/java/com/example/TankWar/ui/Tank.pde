class Tank {
  float x, y;
  float speed = 2;
  int tankColor;
  boolean left, right, up, down;
  float health = 100;
  float tankWidth = 40;
  float tankHeight = 20;
  String[] weapons = {"bullet", "missile", "plasma"};
  int selectedWeapon = 0;
  int fireCooldown = 0;
  String weaponType = "bullet"; // default
  int tempSpeedTimer = -1;
  int tempRapidFireTimer = -1;
  boolean tempRapidFire = false;
  PImage tankImg; // Image for tank

  // Define battlefield boundaries
  static final int BATTLEFIELD_MARGIN_LEFT = 150;
  static final int BATTLEFIELD_MARGIN_RIGHT = 150;
  static final int BATTLEFIELD_MARGIN_TOP = 50;
  static final int BATTLEFIELD_MARGIN_BOTTOM = 50;

  Tank(float x, float y, int tankColor, boolean isLeft, PImage tankImg) {
    this.x = x;
    this.y = y;
    this.tankColor = tankColor;
    this.tankImg = tankImg;
  }

  void update(ArrayList<Barrier> barriers, Tank otherTank) {
    float newX = x;
    float newY = y;

    if (left) newX -= speed;
    if (right) newX += speed;
    if (up) newY -= speed;
    if (down) newY += speed;

    newX = constrain(newX, BATTLEFIELD_MARGIN_LEFT, width - BATTLEFIELD_MARGIN_RIGHT - tankWidth);
    newY = constrain(newY, BATTLEFIELD_MARGIN_TOP, height - BATTLEFIELD_MARGIN_BOTTOM - tankHeight);

    boolean blocked = false;
    for (Barrier b : barriers) {
      if (rectsOverlap(newX, newY, tankWidth, tankHeight, b.x, b.y, b.w, b.h)) {
        blocked = true;
        break;
      }
    }

    if (!blocked && rectsOverlap(newX, newY, tankWidth, tankHeight, otherTank.x, otherTank.y, otherTank.tankWidth, otherTank.tankHeight)) {
      blocked = true;
    }

    if (!blocked) {
      x = newX;
      y = newY;
    }

    if (fireCooldown > 0) fireCooldown--;

    if (tempSpeedTimer > 0 && millis() - tempSpeedTimer > 5000) {
      speed = 2;
      tempSpeedTimer = -1;
    }
    if (tempRapidFire && millis() - tempRapidFireTimer > 5000) {
      tempRapidFire = false;
    }
  }

  boolean rectsOverlap(float x1, float y1, float w1, float h1,
                       float x2, float y2, float w2, float h2) {
    return !(x1 + w1 < x2 || x1 > x2 + w2 ||
             y1 + h1 < y2 || y1 > y2 + h2);
  }

  void switchWeapon() {
    selectedWeapon = (selectedWeapon + 1) % weapons.length;
  }

  void display(boolean showExtras) {
     float imgWidth = 60;
  float imgHeight = 40;

  if (tankImg != null) {
    image(tankImg, x, y, imgWidth, imgHeight);
  } else {
    fill(tankColor);
    rect(x, y, tankWidth, tankHeight);
    rect(x + 15, y - 10, 10, 10);
  }

    if (showExtras) {
      fill(100);
      rect(x, y - 20, tankWidth, 5);

      fill(0, 255, 0);
      float healthWidth = map(health, 0, 100, 0, tankWidth);
      rect(x, y - 20, healthWidth, 5);

      fill(255);
      textAlign(CENTER);
      textSize(10);
      text(weapons[selectedWeapon], x + tankWidth / 2, y - 30);
    }
  }

  void handleKeyPressed(char key, boolean isPressed) {
    if (this == tank1) {
      if (key == 'a') left = isPressed;
      if (key == 'd') right = isPressed;
      if (key == 'w') up = isPressed;
      if (key == 's') down = isPressed;
      if (key == ' ' && isPressed && fireCooldown == 0) fire();
      if (key == 'q' && isPressed) switchWeapon();

      if (key == '1' && isPressed) selectedWeapon = 0;
      if (key == '2' && isPressed) selectedWeapon = 1;
      if (key == '3' && isPressed) selectedWeapon = 2;
    }

    if (this == tank2) {
      if (keyCode == LEFT) left = isPressed;
      if (keyCode == RIGHT) right = isPressed;
      if (keyCode == UP) up = isPressed;
      if (keyCode == DOWN) down = isPressed;
      if (key == 'l' && isPressed && fireCooldown == 0) fire();
      if (key == 'k' && isPressed) switchWeapon();

      if (key == '8' && isPressed) selectedWeapon = 0;
      if (key == '9' && isPressed) selectedWeapon = 1;
      if (key == '0' && isPressed) selectedWeapon = 2;
    }
  }

  void fire() {
    String weaponType = weapons[selectedWeapon];

    float px, py, dx;
    if (this == tank1) {
      px = x + tankWidth;
      dx = 6;
    } else {
      px = x - 5;
      dx = -6;
    }
    py = y + tankHeight / 2;

   if (weaponType.equals("bullet")) {
    projectiles.add(new Projectile(px, py, dx * 1.5f, 0, tankColor, 10, 4, "bullet"));
    fireCooldown = 20;


} else if (weaponType.equals("missile")) {
  projectiles.add(new Projectile(px, py, dx, 0, tankColor, 25, 8, "missile"));
  fireCooldown = 40;
} else if (weaponType.equals("plasma")) {
  projectiles.add(new Projectile(px, py, dx * 2, 0, tankColor, 15, 12, "plasma"));
  fireCooldown = 30;
}


    if (tempRapidFire) fireCooldown = 8;
  }

  boolean collidesWith(Barrier b) {
    return !(x + tankWidth < b.x || x > b.x + b.w ||
             y + tankHeight < b.y || y > b.y + b.h);
  }

  boolean collidesWith(Tank other) {
    return !(x + tankWidth < other.x || x > other.x + other.tankWidth ||
             y + tankHeight < other.y || y > other.y + other.tankHeight);
  }
}
