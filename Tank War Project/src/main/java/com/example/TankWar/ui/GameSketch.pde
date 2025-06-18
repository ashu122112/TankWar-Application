Tank tank1, tank2;
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<Barrier> barriers = new ArrayList<Barrier>();

void setup() {
  size(1000, 600);
  tank1 = new Tank(100, height - 60, color(255, 0, 0));
  tank2 = new Tank(900, height - 60, color(0, 0, 255));
  barriers.add(new Barrier(500, height - 100, 50, 150));  // Example wall
}

void draw() {
  background(180, 220, 255);
  
  for (Barrier b : barriers) b.display();
  
  tank1.update();
  tank2.update();
  tank1.display();
  tank2.display();

  for (Projectile p : projectiles) {
    p.update();
    p.display();
  }
  if (tank1.health <= 0) {
  gameOver("Player 2 Wins!");
} else if (tank2.health <= 0) {
  gameOver("Player 1 Wins!");
}
fill(0);
textSize(14);
textAlign(LEFT);
text("Tank 1 Weapon: " + tank1.weapons[tank1.selectedWeapon], 10, 20);
text("Tank 2 Weapon: " + tank2.weapons[tank2.selectedWeapon], 10, 40);

}

void gameOver(String message) {
  fill(0);
  textSize(50);
  textAlign(CENTER, CENTER);
  text(message, width / 2, height / 2);
  noLoop();  // Stop the game
}


void keyPressed() {
  tank1.handleKeyPressed(key, true);
  tank2.handleKeyPressed(key, true);
}

void keyReleased() {
  tank1.handleKeyPressed(key, false);
  tank2.handleKeyPressed(key, false);
}
