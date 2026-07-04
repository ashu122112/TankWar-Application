// Barrier.pde - Class definition

class Barrier {
  float x, y, w, h;
  int health;
  int maxHealth; // Changed to be set by constructor
  int lastHitTime = -10000; // Initialize far in the past so health bar isn't shown initially
  int showHealthDuration = 1000; // How long to show health bar after hit
  PImage barrierImg;
  float drawOffsetY; // Variable for vertical drawing offset

  // Constructor
  Barrier(float x, float y, float w, float h, float initialHealth, PImage img, float drawOffsetY) {
    this.x = x;
    this.y = y; // This 'y' is the top-left y of the *collision box*.
    this.w = w;
    this.h = h;
    this.maxHealth = (int)initialHealth; // Set maxHealth based on initialHealth      
    this.health = (int)initialHealth;    // Initialize current health
    this.barrierImg = img;
    this.drawOffsetY = drawOffsetY; // Initialize the offset for visual drawing
  }

  void display() {
    pushStyle(); // Save current drawing style

    // Apply tint for hit effect if recently hit
    if (barrierImg != null) {
      if (millis() - lastHitTime < 200) { // Flash for 200ms
        tint(255, 150); // Flash white (more transparent white for image tint)
      } else {
        noTint(); // Important: remove tint after effect
      }
      // Draw the image. Its top-left corner is at (x, y + drawOffsetY).
      // This allows shifting the image relative to the collision box.
      image(barrierImg, x, y + drawOffsetY, w, h);
      noTint(); // Ensure no tint for subsequent drawings, even if not flashing
    } else {
      // Fallback if no image is provided (uses basic color based on health)
      if (health > maxHealth * 0.6) fill(180); // Healthy (grey)
      else if (health > maxHealth * 0.3) fill(220, 180, 0); // Damaged (yellowish)
      else fill(255, 0, 0); // Critical (red)
      rect(x, y, w, h); // Fallback rect drawn at collision box's y
    }

    // --- DEBUGGING: Removed the transparent red collision box drawing ---
    // fill(255, 0, 0, 80); // Semi-transparent red
    // rect(x, y, w, h);
    // --- END DEBUGGING ---


    // Draw health bar if recently hit or if health is less than max (always show if not full health)
    if (millis() - lastHitTime <= showHealthDuration) {
      drawHealthBar();
    }
    popStyle(); // Restore previous drawing style
  }

  void drawHealthBar() {
    float barWidth = w;
    float barHeight = 5;
    float healthPercent = constrain(health / (float)maxHealth, 0, 1);

    fill(80); // Background of health bar
    // Position health bar directly above the visual image (using drawOffsetY)
    rect(x, y + drawOffsetY - barHeight - 2, barWidth, barHeight);
    fill(lerpColor(color(255, 0, 0), color(0, 255, 0), healthPercent)); // Health color: Red to Green
    rect(x, y + drawOffsetY - barHeight - 2, barWidth * healthPercent, barHeight);
    noFill();
    stroke(255); // Outline of health bar
    rect(x, y + drawOffsetY - barHeight - 2, barWidth, barHeight);
    noStroke();
  }

  // Corrected collidesWith method for accurate Circle-to-Rectangle collision
  // This method assumes a 'Projectile' class exists with 'x', 'y', and 'radius' properties.
  boolean collidesWith(Projectile p) {
    // Find the closest point on the barrier rectangle to the projectile's center
    // Collision check uses the actual x,y,w,h of the barrier's collision box.
    float closestX = constrain(p.x, x, x + w);
    float closestY = constrain(p.y, y, y + h);

    // Calculate the distance between the projectile's center and this closest point
    float distanceX = p.x - closestX;
    float distanceY = p.y - closestY;
    float distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);

    // If the distance is less than the projectile's radius, a collision occurred
    return distanceSquared <= (p.radius * p.radius);
  }

  void takeDamage(float amount) {
    health -= amount;
    lastHitTime = millis(); // Record time of hit

    // Create particles for damage effect
    // This assumes a global 'ArrayList<Particle> particles;' is declared
    // and a 'Particle' class is defined with a matching constructor.
    for (int i = 0; i < 5; i++) {
      particles.add(new Particle(
        x + random(w), y + random(h), // Random position within barrier's collision box
        random(-1, 1), random(-1, 1), // Small random velocity
        color(150), // Grey/brownish color for debris
        random(2, 5), // Random size
        40 // Particle lifetime
      ));
    }
  }

  boolean isDestroyed() {
    return health <= 0;
  }
}
