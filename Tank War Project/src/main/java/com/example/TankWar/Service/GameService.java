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
	    
	    private int currentTankIndex = 0;  
	    
	    public Tank getCurrentTank() {
	        List<Tank> tanks = tankRepository.findAll();

	        if (tanks.isEmpty()) {
	            throw new IllegalStateException("No tanks available in the game.");
	        }

	        
	        Tank currentTank = tanks.get(currentTankIndex);
	        currentTankIndex = (currentTankIndex + 1) % tanks.size();  

	        return currentTank;
	    }
	  
	    public void fireProjectile(int tankId, double angle, double power) {
	        Optional<Tank> tankOpt = tankRepository.findById(tankId);
	        if (tankOpt.isPresent()) {
	            Tank tank = tankOpt.get();
	           //logic of angle and power?
	            Projectile projectile = new Projectile();
	            projectileRepository.save(projectile);
	            
	        }
	    }
	    public List<Projectile> getActiveProjectiles() {
	        
	        return projectileRepository.findAll().stream()
	                                   .filter(Projectile::isActive)
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

	    public static class HackChallenge {
	        public final String title;
	        public final String description;
	        public final String hint;
	        public final String answer;
	        public final String reward;

	        public HackChallenge(String title, String description,
	                             String hint, String answer, String reward) {
	            this.title = title;
	            this.description = description;
	            this.hint = hint;
	            this.answer = answer;
	            this.reward = reward;
	        }
	    }

	    private final List<HackChallenge> challengeBank = List.of(
	        new HackChallenge("SQL LOGIN BYPASS",
	            "SELECT * FROM users WHERE name='{input}' AND pass='x'",
	            "Comment out the password check",
	            "admin'--", "missile_burst"),

	        new HackChallenge("BASE64 DECODE",
	            "Decode: U0hJRUxE",
	            "Standard Base64 encoding",
	            "SHIELD", "shield"),

	        new HackChallenge("XSS INJECTION",
	            "Inject into: <input value='{input}'>",
	            "Break out of the attribute",
	            "'><script>alert(1)</script>", "rapid_fire"),

	        new HackChallenge("CAESAR CIPHER",
	            "Decode (shift 3): VSRBS",
	            "Each letter shifted back by 3",
	            "SPEED", "speed"),

	        new HackChallenge("COMMAND INJECTION",
	            "ping tool runs: ping {input}",
	            "Chain a second command with semicolon",
	            "127.0.0.1; ls", "triple_shot")
	    );

	    public HackChallenge getRandomChallenge() {
	        int idx = (int)(Math.random() * challengeBank.size());
	        return challengeBank.get(idx);
	    }

	    public boolean verifyAnswer(int challengeIndex, String userAnswer) {
	        if (challengeIndex < 0 || challengeIndex >= challengeBank.size()) return false;
	        return challengeBank.get(challengeIndex).answer
	                   .trim().equalsIgnoreCase(userAnswer.trim());
	    }

	    public String getChallengeReward(int challengeIndex) {
	        if (challengeIndex < 0 || challengeIndex >= challengeBank.size()) return null;
	        return challengeBank.get(challengeIndex).reward;
	    }
}
