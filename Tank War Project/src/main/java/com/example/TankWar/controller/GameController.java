package com.example.TankWar.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.TankWar.Model.GameResult;
import com.example.TankWar.Model.Tank;
import com.example.TankWar.Model.Terrain;
import com.example.TankWar.Model.Weapon;
import com.example.TankWar.Service.GameService;

@RestController
@RequestMapping("/api/game")
public class GameController {

    @Autowired
    private GameService gameService;

    // ── GAME LIFECYCLE ─────────────────────────────────────────────────────────

    /** POST /api/game/start — seeds two tanks, clears old projectiles */
    @PostMapping("/start")
    public ResponseEntity<String> startNewGame() {
        gameService.startNewGame();
        return ResponseEntity.ok("New game started — tanks seeded in DB.");
    }

    // ── TANKS ──────────────────────────────────────────────────────────────────

    /** GET /api/game/tanks — returns all tanks and their current state */
    @GetMapping("/tanks")
    public ResponseEntity<List<Tank>> getAllTanks() {
        return ResponseEntity.ok(gameService.getAllTanks());
    }

    // ── COMBAT ────────────────────────────────────────────────────────────────

    /**
     * POST /api/game/tanks/{tankId}/fire?angle=45&power=80
     * Records a fired projectile with real angle, power, and weapon type.
     */
    @PostMapping("/tanks/{tankId}/fire")
    public ResponseEntity<String> fireProjectile(
            @PathVariable int tankId,
            @RequestParam double angle,
            @RequestParam double power) {

        if (angle < 0 || angle > 360) {
            return ResponseEntity.badRequest().body("Angle must be between 0 and 360.");
        }
        if (power < 0 || power > 100) {
            return ResponseEntity.badRequest().body("Power must be between 0 and 100.");
        }

        gameService.fireProjectile(tankId, angle, power);
        return ResponseEntity.ok("Projectile fired by tank " + tankId);
    }

    /**
     * POST /api/game/tanks/{tankId}/damage?damage=25
     * Applies damage and saves updated health to DB.
     */
    @PostMapping("/tanks/{tankId}/damage")
    public ResponseEntity<String> applyDamage(
            @PathVariable int tankId,
            @RequestParam int damage) {

        if (damage < 0) {
            return ResponseEntity.badRequest().body("Damage cannot be negative.");
        }

        gameService.applyDamage(tankId, damage);
        return ResponseEntity.ok("Damage " + damage + " applied to tank " + tankId);
    }

    /** GET /api/game/status — returns whether the game is over */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> checkGameStatus() {
        boolean over = gameService.isGameOver();
        return ResponseEntity.ok(Map.of(
                "gameOver", over,
                "message", over ? "Game Over!" : "Game is ongoing."));
    }

    // ── LEADERBOARD ───────────────────────────────────────────────────────────

    /**
     * GET /api/game/leaderboard — all match results sorted by damage dealt.
     * Powered by the new GameResult entity.
     */
    @GetMapping("/leaderboard")
    public ResponseEntity<List<GameResult>> getLeaderboard() {
        return ResponseEntity.ok(gameService.getLeaderboard());
    }

    /**
     * POST /api/game/result
     * Called from GameSketch when game_over state is reached.
     * Body params: winnerName, loserName, damageDealt, terrain, usedHack
     */
    @PostMapping("/result")
    public ResponseEntity<GameResult> saveResult(
            @RequestParam String winnerName,
            @RequestParam String loserName,
            @RequestParam int damageDealt,
            @RequestParam String terrain,
            @RequestParam(defaultValue = "false") boolean usedHack) {

        GameResult result = gameService.saveGameResult(
                winnerName, loserName, damageDealt, terrain, usedHack);
        return ResponseEntity.ok(result);
    }

    // ── TERRAIN & WEAPON ──────────────────────────────────────────────────────

    /** GET /api/game/terrain?type=grassland */
    @GetMapping("/terrain")
    public ResponseEntity<Terrain> getTerrain(@RequestParam String type) {
        return ResponseEntity.ok(gameService.getTerrainByType(type));
    }

    /** GET /api/game/weapon?type=missile */
    @GetMapping("/weapon")
    public ResponseEntity<Weapon> chooseWeapon(@RequestParam String type) {
        return ResponseEntity.ok(gameService.chooseWeapon(type));
    }

    // ── HACK CHALLENGES ───────────────────────────────────────────────────────

    /**
     * GET /api/game/challenge/random
     * Returns a random challenge's title, description, hint, reward.
     * The correct answer is NEVER returned here — only verifyAnswer() checks it.
     */
    @GetMapping("/challenge/random")
    public ResponseEntity<Map<String, Object>> getRandomChallenge() {
        GameService.HackChallenge c = gameService.getRandomChallenge();
        return ResponseEntity.ok(Map.of(
                "index", c.index,
                "title", c.title,
                "description", c.description,
                "hint", c.hint,
                "reward", c.reward));
    }

    /**
     * POST /api/game/challenge/verify?index=0&answer=admin'--
     * Returns correct true/false + reward name if correct.
     * Answer is compared server-side only — never exposed to client.
     */
    @PostMapping("/challenge/verify")
    public ResponseEntity<Map<String, Object>> verifyChallenge(
            @RequestParam int index,
            @RequestParam String answer) {

        boolean correct = gameService.verifyAnswer(index, answer);
        String reward = correct ? gameService.getChallengeReward(index) : null;

        return ResponseEntity.ok(Map.of(
                "correct", correct,
                "reward", reward != null ? reward : "none"));
    }
}
