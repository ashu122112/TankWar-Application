package com.example.TankWar.ui;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;

import com.example.TankWar.Model.Projectile;
import com.example.TankWar.Model.Tank;
import com.example.TankWar.Service.GameService;

import processing.core.PApplet;

public class GameSketch extends PApplet{
	 @Autowired
	    private GameService gameService;

	    private Tank currentTank;
	    private double angle = 45;       // Default angle for pro
	    private double power = 50;       // Default power for pro

	    @Override
	    public void settings() {
	        size(800, 600);  // Set the window size
	    }

	    @Override
	    public void setup() {
	        background(200);  // Light background for contrast
	        frameRate(30);    // Control frame rate for smoother animations
	    }

	    @Override
	    public void draw() {
	        background(200);
	        drawTerrain();
	        drawTanks();
	        drawProjectiles();
	    }

	    private void drawTerrain() {
	        // Placeholder for terrain; in future, this could be more dynamic
	        fill(100, 200, 100);  // Green terrain
	        rect(0, height - 100, width, 100);  // A simple ground
	    }

	    private void drawTanks() {
	        List<Tank> tanks = gameService.getAllTanks();
	        fill(0, 255, 0);  // Green tank
	        for (Tank tank : tanks) {
	            rect((float) tank.getPositionX(), height - 100 - 20, 40, 20);  // Tank is a rectangle
	        }
	    }

	    private void drawProjectiles() {
	        List<Projectile> projectiles = gameService.getActiveProjectiles();
	        fill(255, 0, 0);  // Red pro
	        for (Projectile projectile : projectiles) {
	            ellipse((float) projectile.getPositionX(), (float) projectile.getPositionY(), 10, 10);  // Draw pro as a circle
	        }
	    }

	    @Override
	    public void keyPressed() {
	        switch (key) {
	            case ' ':
	                fireProjectile();
	                break;
	            case 'a':
	                angle -= 5;
	                break;
	            case 'd':
	                angle += 5;
	                break;
	            case 'w':
	                power += 5;
	                break;
	            case 's':
	                power -= 5;
	                break;
	            default:
	                break;
	        }
	    }

	    private void fireProjectile() {
	        if (currentTank == null) {
	            currentTank = gameService.getCurrentTank();
	        }

	        // Using the gameService to fire a pro from the current tank
	        gameService.fireProjectile(currentTank.getPlayerId(), angle, power);
	    }
	    
	    
	    public GameSketch(GameService gameService) {
	        this.gameService = gameService;
	    }
}
