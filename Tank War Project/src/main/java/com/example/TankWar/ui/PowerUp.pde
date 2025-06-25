class PowerUp {
  float x, y;
  float size = 20;
  String type;
  boolean active = true;
  color c;
  
  PowerUp(float x, float y, String type) {
    this.x = x;
    this.y = y;
    this.type = type;
    
    if (type.equals("health")) c = color(0, 255, 0);
    else if (type.equals("shield")) c = color(0, 200, 255);
    else if (type.equals("speed")) c = color(255, 200, 0);
    else if (type.equals("rapid")) c = color(255, 0, 200);
  }
  
  void display() {
    if (!active) return;
    fill(c);
    ellipse(x, y, size, size);
    
    // Draw icon
    fill(255);
    textSize(12);
    textAlign(CENTER, CENTER);
    if (type.equals("health")) text("H", x, y);
    else if (type.equals("shield")) text("S", x, y);
    else if (type.equals("speed")) text("Sp", x, y);
    else if (type.equals("rapid")) text("R", x, y);
  }
  
  boolean isCollectedBy(Tank t) {
    return active && dist(x, y, t.x + t.tankWidth/2, t.y + t.tankHeight/2) < size + t.tankWidth/2;
  }
}
