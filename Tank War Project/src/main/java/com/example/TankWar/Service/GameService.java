package com.example.TankWar.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.TankWar.Model.GameResult;
import com.example.TankWar.Model.Projectile;
import com.example.TankWar.Model.Tank;
import com.example.TankWar.Model.Terrain;
import com.example.TankWar.Model.Weapon;
import com.example.TankWar.repository.GameResultRepository;
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
	@Autowired
	private GameResultRepository gameResultRepository;

	// ── TURN TRACKING ──────────────────────────────────────────────────────────
	// volatile ensures visibility across threads (Processing runs on its own
	// thread)
	private volatile int currentTankIndex = 0;

	// ── HACK CHALLENGE BANK ────────────────────────────────────────────────────
	// Hardcoded here so no extra DB table is needed.
	// Adding new challenges = adding one entry to this list. Nothing else changes.
	public static class HackChallenge {
		public final int index;
		public final String title;
		public final String description;
		public final String hint;
		private final String answer; // kept private — never sent to client
		public final String reward;

		public HackChallenge(int index, String title, String description,
				String hint, String answer, String reward) {
			this.index = index;
			this.title = title;
			this.description = description;
			this.hint = hint;
			this.answer = answer;
			this.reward = reward;
		}
	}

	private final List<HackChallenge> challengeBank = List.of(
			new HackChallenge(0,
					"SQL LOGIN BYPASS",
					"Query: SELECT * FROM users WHERE name='{input}' AND pass='x'",
					"Comment out the password check with --",
					"admin'--",
					"missile_burst"),

			new HackChallenge(1,
					"BASE64 DECODE",
					"Decode this string: U0hJRUxE",
					"Standard Base64 encoding — try any online decoder",
					"SHIELD",
					"shield"),

			new HackChallenge(2,
					"XSS INJECTION",
					"Inject into: <input value='{input}'>",
					"Break out of the attribute with a closing quote",
					"'><script>alert(1)</script>",
					"rapid_fire"),

			new HackChallenge(3,
					"CAESAR CIPHER",
					"Decode (shift 3): VSRBS",
					"Shift each letter back by 3 in the alphabet",
					"SPEED",
					"speed"),

			new HackChallenge(4,
					"COMMAND INJECTION",
					"Ping tool runs: ping {input}",
					"Chain a second shell command using a semicolon",
					"127.0.0.1; ls",
					"triple_shot"));

	// ── GAME LIFECYCLE ─────────────────────────────────────────────────────────

	/**
	 * Clears previous game data and seeds two fresh tanks.
	 * Called by the REST endpoint and also by GameSketch at game start.
	 */
	public void startNewGame() {
		projectileRepository.deleteAll();
		tankRepository.deleteAll();

		Tank tank1 = new Tank(0, 100, 100.0, 300.0, 0.0, 50.0, "bullet");
		Tank tank2 = new Tank(0, 100, 600.0, 300.0, 180.0, 50.0, "bullet");
		tankRepository.saveAll(List.of(tank1, tank2));

		currentTankIndex = 0;
	}

	// ── TANKS ──────────────────────────────────────────────────────────────────

	public List<Tank> getAllTanks() {
		return tankRepository.findAll();
	}

	public Tank getCurrentTank() {
		List<Tank> tanks = tankRepository.findAll();
		if (tanks.isEmpty()) {
			throw new IllegalStateException("No tanks in game. Call /api/game/start first.");
		}
		Tank current = tanks.get(currentTankIndex % tanks.size());
		currentTankIndex = (currentTankIndex + 1) % tanks.size();
		return current;
	}

	// ── COMBAT ────────────────────────────────────────────────────────────────

	/**
	 * Records a fired projectile to the database.
	 * Previously saved an empty Projectile() — now saves real data.
	 */
	public void fireProjectile(int tankId, double angle, double power) {
		Tank tank = tankRepository.findById(tankId)
				.orElseThrow(() -> new IllegalArgumentException("Tank not found: " + tankId));

		// Sync tank's latest angle/power from the live game into the DB
		tank.setAngle(angle);
		tank.setPower(power);
		tankRepository.save(tank);

		// Persist the projectile with real values
		Projectile projectile = new Projectile(angle, power, tank.getWeaponType());
		projectile.setPositionX(tank.getPositionX());
		projectile.setPositionY(tank.getPositionY());
		projectile.setActive(true);
		projectileRepository.save(projectile);
	}

	public List<Projectile> getActiveProjectiles() {
		return projectileRepository.findAll().stream()
				.filter(Projectile::isActive)
				.collect(Collectors.toList());
	}

	/**
	 * Applies damage to a tank and saves updated health to the database.
	 * Called from GameSketch when a projectile hits.
	 */
	public void applyDamage(int tankId, int damage) {
		Tank tank = tankRepository.findById(tankId)
				.orElseThrow(() -> new IllegalArgumentException("Tank not found: " + tankId));
		tank.takeDamage(damage);
		tankRepository.save(tank);
	}

	// ── GAME OVER & LEADERBOARD ───────────────────────────────────────────────

	public boolean isGameOver() {
		return tankRepository.findAll().stream()
				.anyMatch(tank -> tank.getHealth() <= 0);
	}

	/**
	 * Saves match result to the leaderboard when game ends.
	 * Called from GameSketch after the winning condition is detected.
	 *
	 * @param winnerName  display name of the winner
	 * @param loserName   display name of the loser
	 * @param damageDealt total damage the winner dealt
	 * @param terrain     terrain type used in this match
	 * @param usedHack    true if a hack challenge was completed in this match
	 */
	public GameResult saveGameResult(String winnerName, String loserName,
			int damageDealt, String terrain,
			boolean usedHack) {
		GameResult result = new GameResult();
		result.setWinnerName(winnerName);
		result.setLoserName(loserName);
		result.setWinnerDamageDealt(damageDealt);
		result.setTerrainType(terrain);
		result.setCybersecurityChallengeUsed(usedHack);
		result.setPlayedAt(LocalDateTime.now());
		return gameResultRepository.save(result);
	}

	public List<GameResult> getLeaderboard() {
		// Returns matches sorted by damage dealt descending
		return gameResultRepository.findAll().stream()
				.sorted((a, b) -> b.getWinnerDamageDealt() - a.getWinnerDamageDealt())
				.collect(Collectors.toList());
	}

	// ── TERRAIN & WEAPON ──────────────────────────────────────────────────────

	public Terrain getTerrainByType(String type) {
		return terrainRepository.findAll().stream()
				.filter(t -> t.getType().equalsIgnoreCase(type))
				.findFirst()
				.orElseThrow(() -> new IllegalArgumentException("Unknown terrain: " + type));
	}

	public Weapon chooseWeapon(String type) {
		return weaponRepository.findAll().stream()
				.filter(w -> w.getType().equalsIgnoreCase(type))
				.findFirst()
				.orElseThrow(() -> new IllegalArgumentException("Unknown weapon: " + type));
	}

	// ── HACK CHALLENGES ───────────────────────────────────────────────────────

	public HackChallenge getRandomChallenge() {
		int idx = (int) (Math.random() * challengeBank.size());
		return challengeBank.get(idx);
	}

	public HackChallenge getChallengeByIndex(int index) {
		if (index < 0 || index >= challengeBank.size()) {
			throw new IllegalArgumentException("Challenge index out of range: " + index);
		}
		return challengeBank.get(index);
	}

	/**
	 * Verifies a player's answer against the stored answer (case-insensitive,
	 * trimmed).
	 * The correct answer is never exposed to the client — only this method checks
	 * it.
	 */
	public boolean verifyAnswer(int challengeIndex, String userAnswer) {
		HackChallenge challenge = getChallengeByIndex(challengeIndex);
		return challenge.answer.trim().equalsIgnoreCase(userAnswer.trim());
	}

	public String getChallengeReward(int challengeIndex) {
		return getChallengeByIndex(challengeIndex).reward;
	}
}
