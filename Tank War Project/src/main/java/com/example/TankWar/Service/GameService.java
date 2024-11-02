package com.example.TankWar.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.TankWar.Model.Projectile;
import com.example.TankWar.Model.Tank;
import com.example.TankWar.Model.Terrain;
import com.example.TankWar.Model.Weapon;
import com.example.TankWar.repository.ProjectileRepository;
import com.example.TankWar.repository.TankRepository;
import com.example.TankWar.repository.TerrainRepository;
import com.example.TankWar.repository.WeaponRepository;

@Service
public class GameService {
	 @Autowired
	    private TankRepository tankRepository;

	    @Autowired
	    private ProjectileRepository projectileRepository;

	    @Autowired
	    private TerrainRepository terrainRepository;

	    @Autowired
	    private WeaponRepository weaponRepository;

	    
	    public void startNewGame() {
	       
	    }

	    
	    public List<Tank> getAllTanks() {
	        return tankRepository.findAll();
	    }
	    
	    private int currentTankIndex = 0;  // Tracks which tank's turn it is

	    // Other methods like fireProjectile(), getTanks(), getActiveProjectiles(), etc.

	    public Tank getCurrentTank() {
	        List<Tank> tanks = tankRepository.findAll();

	        if (tanks.isEmpty()) {
	            throw new IllegalStateException("No tanks available in the game.");
	        }

	        // Retrieve the current tank and prepare for the next turn
	        Tank currentTank = tanks.get(currentTankIndex);
	        currentTankIndex = (currentTankIndex + 1) % tanks.size();  // Cycle to the next tank

	        return currentTank;
	    }
	  
	    public void fireProjectile(int tankId, double angle, double power) {
	        Optional<Tank> tankOpt = tankRepository.findById(tankId);
	        if (tankOpt.isPresent()) {
	            Tank tank = tankOpt.get();
	           
	            Projectile projectile = new Projectile();
	            projectileRepository.save(projectile);
	            
	        }
	    }
	    public List<Projectile> getActiveProjectiles() {
	        // Retrieve all projectiles and filter based on an 'isActive' status (boolean attribute)
	        return projectileRepository.findAll().stream()
	                                   .filter(Projectile::isActive) // Assuming 'isActive' indicates active projectiles
	                                   .collect(Collectors.toList());
	    }

	    
	    public void applyDamage(int tankId, int damage) {
	        Optional<Tank> tankOpt = tankRepository.findById(tankId);
	        if (tankOpt.isPresent()) {
	            Tank tank = tankOpt.get();
	            int newHealth = tank.getHealth() - damage;
	            tank.setHealth(Math.max(newHealth, 0));
	            tankRepository.save(tank);
	        }
	    }

	    
	    public boolean isGameOver() {
	        List<Tank> tanks = tankRepository.findAll();
	        return tanks.stream().anyMatch(tank -> tank.getHealth() <= 0);
	    }

	    
	    public Terrain getTerrainByType(String type) {
	        return terrainRepository.findAll().stream()
	                .filter(terrain -> terrain.getType().equals(type))
	                .findFirst()
	                .orElse(null);
	    }

	    
	    public Weapon chooseWeapon(String type) {
	        return weaponRepository.findAll().stream()
	                .filter(weapon -> weapon.getType().equals(type))
	                .findFirst()
	                .orElse(null);
	    }

}
