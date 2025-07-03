class Barrier {
  float x, y, w, h;
  int health;
  int maxHealth = 100;
  int lastHitTime = -10000;
  int showHealthDuration = 1000;
  PImage barrierImg;
  
  Barrier(float x, float y, float w, float h, PImage img) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.health = maxHealth;
    this.barrierImg = img;
  }
  
  void display() {
    if (barrierImg != null) {
      if (millis() - lastHitTime < 200) {
        tint(255, 150);
      } else {
        noTint();
      }
      image(barrierImg, x, y, w, h);
    } else {
      if (health > 60) fill(180);
      else if (health > 30) fill(220, 180, 0);
      else fill(255, 0, 0);
      rect(x, y, w, h);
    }
    
    if (millis() - lastHitTime <= showHealthDuration) {
      drawHealthBar();
    }
  }
  
  void drawHealthBar() {
    float barWidth = w;
    float barHeight = 5;
    float healthPercent = constrain(health / (float)maxHealth, 0, 1);
    
    fill(80);
    rect(x, y - barHeight - 2, barWidth, barHeight);
    fill(lerpColor(color(255, 0, 0), color(0, 255, 0), healthPercent));
    rect(x, y - barHeight - 2, barWidth * healthPercent, barHeight);
    noFill();
    stroke(255);
    rect(x, y - barHeight - 2, barWidth, barHeight);
    noStroke();
  }
  
  boolean collidesWith(Projectile p) {
  return (p.x + p.radius > x && p.x - p.radius < x + w &&
          p.y + p.radius > y && p.y - p.radius < y + h);
}
  
  void takeDamage(float amount) {
    health -= amount;
    lastHitTime = millis();
    
    for (int i = 0; i < 5; i++) {
      particles.add(new Particle(
        x + random(w), y + random(h),
        random(-1, 1), random(-1, 1),
        color(150),
        random(2, 5),
        40
      ));
    }
  }
  
  boolean isDestroyed() {
    return health <= 0;
  }
}
