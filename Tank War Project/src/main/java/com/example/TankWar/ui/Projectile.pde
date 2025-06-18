class Projectile {
  float x, y, dx, dy;
  int pColor;
  float damage;
  float radius = 6;

  Projectile(float x, float y, float dx, float dy, int c, float damage) {
    this(x, y, dx, dy, c, damage, 6);
  }

  Projectile(float x, float y, float dx, float dy, int c, float damage, float radius) {
    this.x = x;
    this.y = y;
    this.dx = dx;
    this.dy = dy;
    this.pColor = c;
    this.damage = damage;
    this.radius = radius;
  }

  void update() {
    x += dx;
    y += dy;

    if (this.pColor != tank1.tankColor && isHit(tank1)) {
      tank1.health -= damage;
      projectiles.remove(this);
      return;
    }

    if (this.pColor != tank2.tankColor && isHit(tank2)) {
      tank2.health -= damage;
      projectiles.remove(this);
      return;
    }
  }

  boolean isHit(Tank t) {
    return x > t.x && x < t.x + t.tankWidth &&
           y > t.y && y < t.y + t.tankHeight;
  }

  void display() {
    fill(pColor);
    ellipse(x, y, radius, radius);
  }
}
