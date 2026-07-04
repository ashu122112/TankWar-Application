package com.example.TankWar.Model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

/**
 * Persists match results so the game has a real leaderboard.
 *
 * Previously the backend saved nothing when a game ended.
 * Now GameService.saveGameResult() is called from GameSketch
 * on the game_over transition.
 */
@Entity
@Table(name = "game_results")
public class GameResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String winnerName;
    private String loserName;
    private int winnerDamageDealt;
    private String terrainType;
    private boolean cybersecurityChallengeUsed; // true if hack terminal was solved
    private LocalDateTime playedAt;

    public GameResult() {
    }

    // Getters & Setters

    public int getId() {
        return id;
    }

    public String getWinnerName() {
        return winnerName;
    }

    public void setWinnerName(String winnerName) {
        this.winnerName = winnerName;
    }

    public String getLoserName() {
        return loserName;
    }

    public void setLoserName(String loserName) {
        this.loserName = loserName;
    }

    public int getWinnerDamageDealt() {
        return winnerDamageDealt;
    }

    public void setWinnerDamageDealt(int winnerDamageDealt) {
        this.winnerDamageDealt = winnerDamageDealt;
    }

    public String getTerrainType() {
        return terrainType;
    }

    public void setTerrainType(String terrainType) {
        this.terrainType = terrainType;
    }

    public boolean isCybersecurityChallengeUsed() {
        return cybersecurityChallengeUsed;
    }

    public void setCybersecurityChallengeUsed(boolean used) {
        this.cybersecurityChallengeUsed = used;
    }

    public LocalDateTime getPlayedAt() {
        return playedAt;
    }

    public void setPlayedAt(LocalDateTime playedAt) {
        this.playedAt = playedAt;
    }
}
