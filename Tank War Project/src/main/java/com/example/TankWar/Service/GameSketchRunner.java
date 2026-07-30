package com.example.tankwar.service;

import processing.core.PApplet;

/**
 * Bridges Spring Boot and Processing.
 *
 * Keeping this in its own class means TankGameApplication stays clean,
 * and the Processing dependency is isolated here — easier to swap out later.
 *
 * <p>NOTE: GameSketch is a Processing .pde sketch compiled by the Processing
 * IDE, not by Maven.  This runner uses reflection so the backend compiles
 * independently of the Processing sketch.</p>
 */
public final class GameSketchRunner {

    /** Prevent instantiation — this is a utility class. */
    private GameSketchRunner() {
    }

    /**
     * Launches the Processing-based game UI.
     * Uses reflection to instantiate GameSketch so the Spring Boot backend
     * compiles independently even when the .pde sketch is not on the classpath.
     *
     * @param gameService the Spring-managed GameService
     */
    public static void launch(GameService gameService) {
        try {
            Class<?> sketchClass = Class.forName("com.example.tankwar.service.GameSketch");
            PApplet sketch = (PApplet) sketchClass
                    .getDeclaredConstructor(GameService.class)
                    .newInstance(gameService);
            PApplet.runSketch(new String[]{"TankWar — Hacker Edition"}, sketch);
        } catch (ClassNotFoundException e) {
            System.err.println("[GameSketchRunner] GameSketch not found on classpath. "
                    + "Run the .pde sketch from the Processing IDE instead.");
        } catch (ReflectiveOperationException e) {
            throw new IllegalStateException("Failed to instantiate GameSketch", e);
        }
    }
}
