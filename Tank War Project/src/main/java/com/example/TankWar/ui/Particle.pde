// Particle.pde - Class definition

class Particle {
  float x, y;
  float vx, vy;
  color c;
  float size;
  int lifespan; // Total duration the particle should live
  int life;     // Current remaining life of the particle
  boolean alive = true; // Flag to indicate if the particle is still active

  // Constructor to initialize a new particle
  Particle(float x, float y, float vx, float vy, color c, float size, int lifespan) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.c = c;
    this.size = size;
    this.lifespan = lifespan;
    this.life = lifespan; // Start with full life
  }

  // Update method to move the particle and decrease its life
  void update() {
    x += vx; // Update horizontal position
    y += vy; // Update vertical position
    vy += 0.1; // Apply a simple gravity effect (constant downward acceleration)
    life--;    // Decrease remaining life

    // If life runs out, mark the particle as no longer alive
    if (life <= 0) {
      alive = false;
    }
  }

  // Display method to draw the particle, fading it out as its life decreases
  void display() {
    // Map the current life to an alpha value (transparency)
    // As life goes from lifespan (full) to 0 (empty), alpha goes from 255 (opaque) to 0 (fully transparent)
    float alpha = map(life, 0, lifespan, 0, 255);
    
    // Set fill color with the particle's color and calculated alpha
    fill(red(c), green(c), blue(c), alpha);
    noStroke(); // No border for the particle
    ellipse(x, y, size, size); // Draw the particle as a circle
  }
}
