// PowerUp.pde — Redesigned for 2026 Cyber Aesthetic

class PowerUp {
  float x, y;
  float size = 24;
  String type;
  boolean active = true;
  color c;
  color cGlow;
  int spawnTime;


  PowerUp(float x, float y, String type) {
    this.x = x;
    this.y = y;
    this.type = type;
    this.spawnTime = millis();

    if      (type.equals("health")) { c = color(0, 255, 136);  cGlow = color(0, 255, 136,  60); }
    else if (type.equals("shield")) { c = color(0, 212, 255);  cGlow = color(0, 212, 255,  60); }
    else if (type.equals("speed"))  { c = color(255, 200, 0);  cGlow = color(255, 200, 0,  60); }
    else if (type.equals("rapid"))  { c = color(255, 80, 160); cGlow = color(255, 80, 160, 60); }
    else if (type.equals("hack"))   { c = color(0, 255, 100);  cGlow = color(0, 255, 100,  80); size = 28; }
    else                            { c = color(200, 200, 200); cGlow = color(200, 200, 200, 40); }
  }

  void display() {
    if (!active) return;

    float t         = (millis() - spawnTime) / 1000.0;
    float pulse     = sin(t * 3.5) * 4;           // pulsing outer glow ring
    float bob       = sin(t * 2.0) * 3;           // gentle floating up/down
    float drawY     = y + bob;
    float outerSize = size + pulse + 12;
    float midSize   = size + pulse * 0.5 + 6;

    pushStyle();

    // --- outermost glow halo ---
    noStroke();
    fill(red(c), green(c), blue(c), 18);
    ellipse(x, drawY, outerSize + 10, outerSize + 10);

    // --- pulsing ring ---
    fill(red(c), green(c), blue(c), 35);
    ellipse(x, drawY, outerSize, outerSize);

    // --- mid ring ---
    fill(red(c), green(c), blue(c), 60);
    ellipse(x, drawY, midSize, midSize);

    // --- main disc ---
    fill(c);
    ellipse(x, drawY, size, size);

    // --- inner highlight (top-left gleam) ---
    fill(255, 90);
    ellipse(x - size * 0.18, drawY - size * 0.18, size * 0.28, size * 0.28);

    // --- icon label ---
    fill(255);
    textAlign(CENTER, CENTER);

    if (type.equals("health")) {
      // Draw a "+" cross
      textSize(16);
      text("+", x, drawY - 1);

    } else if (type.equals("shield")) {
      // Draw a small diamond outline
      textSize(11);
      text("S", x, drawY - 1);

    } else if (type.equals("speed")) {
      textSize(11);
      text(">>", x, drawY - 1);

    } else if (type.equals("rapid")) {
      textSize(10);
      text("!!", x, drawY - 1);

    } else if (type.equals("hack")) {
      // Terminal cursor icon — most distinctive
      textSize(10);
      text(">_", x, drawY - 1);

      // Extra: small rotating corner brackets for hack terminal
      float br = size * 0.75;
      float blen = 6;
      stroke(c, 180);
      strokeWeight(1.5);
      noFill();
      // top-left bracket
      line(x - br, drawY - br, x - br + blen, drawY - br);
      line(x - br, drawY - br, x - br, drawY - br + blen);
      // top-right bracket
      line(x + br, drawY - br, x + br - blen, drawY - br);
      line(x + br, drawY - br, x + br, drawY - br + blen);
      // bottom-left bracket
      line(x - br, drawY + br, x - br + blen, drawY + br);
      line(x - br, drawY + br, x - br, drawY + br - blen);
      // bottom-right bracket
      line(x + br, drawY + br, x + br - blen, drawY + br);
      line(x + br, drawY + br, x + br, drawY + br - blen);
      noStroke();
    }

    popStyle();
  }

  boolean isCollectedBy(Tank t) {
    if (!active) return false;
    float closestX = constrain(x, t.x, t.x + t.tankWidth);
    float closestY = constrain(y, t.y, t.y + t.tankHeight);
    float dx = x - closestX;
    float dy = y - closestY;
    float r  = size / 2;
    return (dx*dx + dy*dy) <= (r*r);
  }
}