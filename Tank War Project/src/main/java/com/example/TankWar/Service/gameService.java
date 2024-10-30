package com.example.TankWar.Service;

import org.springframework.stereotype.Service;

@Service
public class gameService {

	public GameState startNewGame() {
        return new GameState();
    }

    public GameState fireProjectile(double angle, double power) {
        // Handle projectile logic
        return new GameState(); // Updated game state after the action
    }
}
