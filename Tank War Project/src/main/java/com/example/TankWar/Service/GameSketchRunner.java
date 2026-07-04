package com.example.TankWar.Service;


import com.example.TankWar.Service.GameService;
import processing.core.PApplet;

/**
 * Bridges Spring Boot and Processing.
 *
 * Keeping this in its own class means TankGameApplication stays clean,
 * and the Processing dependency is isolated here — easier to swap out later.
 */
public class GameSketchRunner {

    public static void launch(GameService gameService) {
        // GameSketch receives the Spring-managed GameService via constructor.
        // Add this constructor to GameSketch.pde (see GameSketch.pde fix notes).
        GameSketch sketch = new GameSketch(gameService);
        PApplet.runSketch(new String[]{"TankWar — Hacker Edition"}, sketch);
    }
}
