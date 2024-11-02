package com.example.TankWar.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.TankWar.Model.Tank;
import com.example.TankWar.Model.Terrain;
import com.example.TankWar.Model.Weapon;
import com.example.TankWar.Service.GameService;

@RestController
@RequestMapping("/api/game")
public class GameController {
	@Autowired
    private GameService gameService;

    
    @PostMapping("/start")
    public String startNewGame() {
        gameService.startNewGame();
        return "New game started!";
    }

    
    @GetMapping("/tanks")
    public List<Tank> getAllTanks() {
        return gameService.getAllTanks();
    }

    
    @PostMapping("/tanks/{tankId}/fire")
    public String fireProjectile(@PathVariable int tankId, @RequestParam double angle, @RequestParam double power) {
        gameService.fireProjectile(tankId, angle, power);
        return "Projectile fired!";
    }

    
    @PostMapping("/tanks/{tankId}/damage")
    public String applyDamage(@PathVariable int tankId, @RequestParam int damage) {
        gameService.applyDamage(tankId, damage);
        return "Damage applied to tank " + tankId;
    }

    
    @GetMapping("/status")
    public String checkGameStatus() {
        if (gameService.isGameOver()) {
            return "Game Over!";
        }
        return "Game is ongoing!";
    }

    
    @GetMapping("/terrain")
    public Terrain getTerrain(@RequestParam String type) {
        return gameService.getTerrainByType(type);
    }

   
    @GetMapping("/weapon")
    public Weapon chooseWeapon(@RequestParam String type) {
        return gameService.chooseWeapon(type);
    }
	
}
