class Projectile {
  float x, y;
  float dx, dy;
  color pColor;
  float damage;
  float radius;
  boolean alive = true;
  String type;
  int lifespan = 1000;
  int creationTime;
  Tank target = null;
  float homingStrength = 0.05;

  // Add a reference to the main game sketch (or specific lists) to allow adding particles/explosions
  // A cleaner approach is to have updateGameObjects handle particle creation on projectile death
  // For now, we'll keep createExplosion as a global function that adds to 'particles' list

  Projectile(float x, float y, float dx, float dy, color c,
             float damage, float radius, String type) {
    this.x = x;
    this.y = y;
    this.dx = dx;
    this.dy = dy;
    this.pColor = c;
    this.damage = damage;
    this.radius = radius;
    this.type = type;
    this.creationTime = millis();

    // Determine target for homing missile based on projectile's color (i.e., who shot it)
    if (type.equals("missile")) {
      target = (c == tank1.tankColor) ? tank2 : tank1; // Assign the opponent as target
    }
  }

  void update() {
    x += dx;
    y += dy;

    // Special behaviors
    if (type.equals("missile") && target != null && target.health > 0) { // Only home if target is alive
      // Simple homing logic
      float angleToTarget = atan2(target.y + target.tankHeight/2 - y,
                                  target.x + target.tankWidth/2 - x);
      // Gradually adjust direction towards target
      dx = lerp(dx, cos(angleToTarget) * 5, homingStrength);
      dy = lerp(dy, sin(angleToTarget) * 5, homingStrength);
    } else if (type.equals("plasma")) {
      dy += 0.05; // Gravity effect
    }

    // Check lifespan
    if (millis() - creationTime > lifespan) {
      alive = false;
      return;
    }

    // Check collisions
    checkCollisions();

    // Boundary check (adjust to use battlefield boundaries)
    if (x < battlefieldX || x > battlefieldX + battlefieldWidth ||
        y < battlefieldY || y > battlefieldY + battlefieldHeight) {
      alive = false;
    }
  }

  void checkCollisions() {
    // Barrier collision
    for (Barrier b : barriers) {
      if (b.collidesWith(this)) {
        b.takeDamage(damage);
        createExplosion(x, y, radius * 2); // Create explosion on barrier hit
        alive = false;
        return;
      }
    }

    // Tank collision - ensure projectile doesn't hit its own tank
    if (pColor != tank1.tankColor && hits(tank1)) {
      tank1.takeDamage(damage);
      createExplosion(x, y, radius * 2); // Create explosion on tank hit
      alive = false;
      return;
    }

    if (pColor != tank2.tankColor && hits(tank2)) {
      tank2.takeDamage(damage);
      createExplosion(x, y, radius * 2); // Create explosion on tank hit
      alive = false;
      return;
    }
  }

  boolean hits(Tank tank) {
    // Improved collision detection using distance-based check
    // Consider tank's actual bounding box for more accuracy instead of just center
    // This is an AABB (Axis-Aligned Bounding Box) check against a circle (projectile)
    float closestX = constrain(x, tank.x, tank.x + tank.tankWidth);
    float closestY = constrain(y, tank.y, tank.y + tank.tankHeight);
    float distanceX = x - closestX;
    float distanceY = y - closestY;
    float distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
    return distanceSquared < (radius * radius);
  }

  void display() {
    pushMatrix();
    translate(x, y);

    switch(type) {
      case "bullet":
        imageMode(CENTER);
        image(bulletImg, 0, 0, radius * 2, radius * 2);
        break;

      case "missile":
        imageMode(CENTER);
        rotate(atan2(dy, dx)); // Rotate missile to face direction of travel
        image(missileImg, 0, 0, radius * 2, radius * 2);
        // Optional: add a small "jet flame" effect
        fill(255, 150, 0, 150);
        ellipse(-radius, 0, radius*1.5, radius/3);
        break;

      case "plasma":
        imageMode(CENTER);
        image(plasmaImg, 0, 0, radius * 2, radius * 2);
        // Add a glow effect
        for (int i = 1; i <= 3; i++) {
          fill(100, 255, 255, 50/i);
          ellipse(0, 0, radius + i*5, radius + i*5);
        }
        break;
    }

    popMatrix();
  }
}
