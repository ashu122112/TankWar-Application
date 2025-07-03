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
    
    if (type.equals("missile")) {
      target = (pColor == tank1.tankColor) ? tank2 : tank1;
    }
  }
  
  void update() {
    x += dx;
    y += dy;
    
    // Special behaviors
    if (type.equals("missile") && target != null) {
      float angle = atan2(target.y + target.tankHeight/2 - y, 
                         target.x + target.tankWidth/2 - x);
      dx = lerp(dx, cos(angle) * 5, homingStrength);
      dy = lerp(dy, sin(angle) * 5, homingStrength);
    } else if (type.equals("plasma")) {
      dy += 0.05;
    }
    
    // Check lifespan
    if (millis() - creationTime > lifespan) {
      alive = false;
      return;
    }
    
    // Check collisions
    checkCollisions();
  }
  
  void checkCollisions() {
    // Barrier collision
    for (Barrier b : barriers) {
      if (b.collidesWith(this)) {
        b.takeDamage(damage);
        alive = false;
        return;
      }
    }
    
    // Tank collision
    if (pColor != tank1.tankColor && hits(tank1)) {
      tank1.takeDamage(damage);
      alive = false;
      return;
    }
    
    if (pColor != tank2.tankColor && hits(tank2)) {
      tank2.takeDamage(damage);
      alive = false;
      return;
    }
    
    // Boundary check
    if (x < battlefieldX || x > battlefieldX + battlefieldWidth ||
        y < battlefieldY || y > battlefieldY + battlefieldHeight) {
      alive = false;
    }
  }
  
  boolean hits(Tank tank) {
    // Improved collision detection using distance-based check
    float tankCenterX = tank.x + tank.tankWidth/2;
    float tankCenterY = tank.y + tank.tankHeight/2;
    float distance = dist(x, y, tankCenterX, tankCenterY);
    return distance < (radius + tank.tankWidth/2);
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    
    switch(type) {
      case "bullet":
        fill(pColor);
        noStroke();
        ellipse(0, 0, radius, radius);
        break;
        
      case "missile":
        rotate(atan2(dy, dx));
        fill(255, 100, 100);
        ellipse(0, 0, radius, radius/2);
        fill(255, 150, 0, 150);
        ellipse(-radius, 0, radius*1.5, radius/3);
        break;
        
      case "plasma":
        fill(100, 255, 255, 200);
        noStroke();
        ellipse(0, 0, radius, radius);
        for (int i = 1; i <= 3; i++) {
          fill(100, 255, 255, 50/i);
          ellipse(0, 0, radius + i*5, radius + i*5);
        }
        break;
    }
    
    popMatrix();
  }
}
