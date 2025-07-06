// PowerUp.pde - Class definition

class PowerUp {
  float x, y;
  float size = 20; // This defines the diameter of the power-up circle
  String type;
  boolean active = true; // True if the power-up is available to be collected
  color c;
  
  // Constructor
  PowerUp(float x, float y, String type) {
    this.x = x;
    this.y = y;
    this.type = type;
    
    // Assign color based on power-up type
    if (type.equals("health")) c = color(0, 255, 0);        // Green for health
    else if (type.equals("shield")) c = color(0, 200, 255); // Light blue for shield
    else if (type.equals("speed")) c = color(255, 200, 0); // Orange/Yellow for speed
    else if (type.equals("rapid")) c = color(255, 0, 200); // Pink/Magenta for rapid fire
  }
  
  // Method to display the power-up
  void display() {
    if (!active) return; // Don't draw if power-up has been collected
    
    // Draw the base circular shape of the power-up
    fill(c);
    noStroke(); // No outline for the circle
    ellipse(x, y, size, size); // Draw circle at x, y with diameter 'size'
    
    // Draw icon text on top of the power-up
    fill(255); // White text
    textSize(12); // Adjust text size as needed
    textAlign(CENTER, CENTER); // Center the text on x, y
    
    // Draw the specific icon based on type
    if (type.equals("health")) text("H", x, y);
    else if (type.equals("shield")) text("S", x, y);
    else if (type.equals("speed")) text("Sp", x, y);
    else if (type.equals("rapid")) text("R", x, y);
  }
  
  // Corrected method to check if the power-up is collected by a tank
  // Implements Circle-to-Rectangle collision detection
  boolean isCollectedBy(Tank t) {
    if (!active) return false; // An inactive power-up cannot be collected
    
    // Calculate the closest point on the tank's rectangle to the power-up's center (x, y)
    float closestX = constrain(x, t.x, t.x + t.tankWidth);
    float closestY = constrain(y, t.y, t.y + t.tankHeight);

    // Calculate the distance between the power-up's center and this closest point
    float distanceX = x - closestX;
    float distanceY = y - closestY;
    float distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);

    // The power-up's radius is size / 2 (since 'size' is its diameter)
    float powerUpRadius = size / 2;

    // If the distance is less than the power-up's radius, a collision occurred
    return distanceSquared <= (powerUpRadius * powerUpRadius);
  }
}
