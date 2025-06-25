class Particle {
  float x, y;
  float vx, vy;
  color c;
  float size;
  int lifespan;
  int life;
  boolean alive = true;
  
  Particle(float x, float y, float vx, float vy, color c, float size, int lifespan) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.c = c;
    this.size = size;
    this.lifespan = lifespan;
    this.life = lifespan;
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.1; // gravity
    life--;
    
    if (life <= 0) {
      alive = false;
    }
  }
  
  void display() {
    float alpha = map(life, 0, lifespan, 0, 255);
    fill(red(c), green(c), blue(c), alpha);
    noStroke();
    ellipse(x, y, size, size);
  }
}
