class Barrier {
  float x, y, w, h;
  int health;
  int lastHitTime = -10000;
  int showHealthDuration = 1000;
  PImage barrierImg; // 🆕 holds image for this barrier

  Barrier(float x, float y, float w, float h, PImage img) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.health = 100;
    this.barrierImg = img;
  }

  void display() {
    if (barrierImg != null) {
      image(barrierImg, x, y, w, h);  // show image
    } else {
      if (health > 60) fill(180);
      else if (health > 30) fill(220, 180, 0);
      else fill(255, 0, 0);
      rect(x, y, w, h);
    }

    if (millis() - lastHitTime <= showHealthDuration) {
      float barWidth = w;
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

  boolean collidesWith(Projectile p) {
    return p.x > x && p.x < x + w && p.y > y && p.y < y + h;
  }

  void takeDamage(float amount) {
    health -= amount;
    lastHitTime = millis();
  }

  boolean isDestroyed() {
    return health <= 0;
  }
}
