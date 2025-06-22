class Projectile {
  float x, y, dx, dy;
  int pColor;
  float damage;
  float radius;
  boolean alive = true;
  String type;


 Projectile(float x, float y, float dx, float dy, int c, float damage, float radius, String type) {
  this.x = x;
  this.y = y;
  this.dx = dx;
  this.dy = dy;
  this.pColor = c;
  this.damage = damage;
  this.radius = radius;
  this.type = type;
}


  void update() {
    x += dx;
    y += dy;

    // Barrier collision
    for (Barrier b : barriers) {
      if (b.collidesWith(this)) {
        b.takeDamage(this.damage);
        alive = false;
        return;
      }
    }

    // Tank hit detection
    if (this.pColor != tank1.tankColor && isHit(tank1)) {
      tank1.health -= damage;
      alive = false;
      return;
    }

    if (this.pColor != tank2.tankColor && isHit(tank2)) {
      tank2.health -= damage;
      alive = false;
      return;
    }
  }

  boolean isHit(Tank t) {
    return x > t.x && x < t.x + t.tankWidth &&
           y > t.y && y < t.y + t.tankHeight;
  }

  void display() {
    switch (type) {
      case "missile":
        fill(255, 100, 100);
        break;
      case "plasma":
        fill(100, 255, 255);
        break;
      default: // bullet
        fill(pColor);
        break;
    }
    ellipse(x, y, radius, radius);
  }
}
