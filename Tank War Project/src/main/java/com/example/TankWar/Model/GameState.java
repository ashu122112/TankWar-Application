package com.example.TankWar.Model;

import java.util.List;

//import jakarta.persistence.Entity;
//import jakarta.persistence.GeneratedValue;
//import jakarta.persistence.GenerationType;
//import jakarta.persistence.Id;
//import jakarta.persistence.JoinColumn;
//import jakarta.persistence.OneToMany;
//import jakarta.persistence.Table;

public class GameState {

	private int currentPlayerTurn; 
    private List<Tank> tanks;           
    private String terrainType;         
    private boolean gameOver;           
    private String winner;              

    
    public GameState() {}

    public GameState(int currentPlayerTurn, List<Tank> tanks, String terrainType, boolean gameOver, String winner) {
        this.currentPlayerTurn = currentPlayerTurn;
        this.tanks = tanks;
        this.terrainType = terrainType;
        this.gameOver = gameOver;
        this.winner = winner;
    }
    
    public int getCurrentPlayerTurn() {
        return currentPlayerTurn;
    }

    public void setCurrentPlayerTurn(int currentPlayerTurn) {
        this.currentPlayerTurn = currentPlayerTurn;
    }

    public List<Tank> getTanks() {
        return tanks;
    }

    public void setTanks(List<Tank> tanks) {
        this.tanks = tanks;
    }

    public String getTerrainType() {
        return terrainType;
    }

    public void setTerrainType(String terrainType) {
        this.terrainType = terrainType;
    }

    public boolean isGameOver() {
        return gameOver;
    }

    public void setGameOver(boolean gameOver) {
        this.gameOver = gameOver;
    }

    public String getWinner() {
        return winner;
    }

    public void setWinner(String winner) {
        this.winner = winner;
    }
    
}
