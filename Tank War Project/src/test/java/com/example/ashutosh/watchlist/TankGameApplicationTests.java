package com.example.TankWar;  // FIXED: was com.example.ashutosh.watchlist (wrong project copy-paste)

import com.example.TankWar.Model.Tank;
import com.example.TankWar.Service.GameService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class TankGameApplicationTests {

    @Autowired
    private GameService gameService;

    /** Spring context must load cleanly — catches any misconfigured beans early */
    @Test
    void contextLoads() {
    }

    // ── Tank Model Tests ───────────────────────────────────────────────────────

    @Test
    void takeDamage_reducesHealthCorrectly() {
        Tank tank = new Tank(0, 100, 0, 0, 0, 50, "bullet");
        tank.takeDamage(30);
        assertEquals(70, tank.getHealth(), "Health should be 70 after 30 damage");
    }

    @Test
    void takeDamage_healthCannotGoBelowZero() {
        Tank tank = new Tank(0, 100, 0, 0, 0, 50, "bullet");
        tank.takeDamage(999);
        assertTrue(tank.getHealth() >= 0, "Health must never go negative");
        assertEquals(0, tank.getHealth());
    }

    @Test
    void takeDamage_zeroDoesNotChangeHealth() {
        Tank tank = new Tank(0, 100, 0, 0, 0, 50, "bullet");
        tank.takeDamage(0);
        assertEquals(100, tank.getHealth(), "Zero damage should not change health");
    }

    // ── Hack Challenge Tests ───────────────────────────────────────────────────

    @Test
    void verifyAnswer_correctAnswerReturnsTrue() {
        // Challenge 0 is SQL bypass — answer is "admin'--"
        assertTrue(gameService.verifyAnswer(0, "admin'--"),
            "Correct SQL injection answer should return true");
    }

    @Test
    void verifyAnswer_wrongAnswerReturnsFalse() {
        assertFalse(gameService.verifyAnswer(0, "wronganswer"),
            "Incorrect answer should return false");
    }

    @Test
    void verifyAnswer_isCaseInsensitive() {
        // Challenge 1 is Base64 decode — answer is "SHIELD"
        assertTrue(gameService.verifyAnswer(1, "shield"),
            "Answer check should be case-insensitive");
        assertTrue(gameService.verifyAnswer(1, "Shield"),
            "Answer check should be case-insensitive");
    }

    @Test
    void verifyAnswer_tripsOnInvalidIndex() {
        assertThrows(IllegalArgumentException.class,
            () -> gameService.verifyAnswer(999, "test"),
            "Out-of-range index should throw IllegalArgumentException");
    }

    @Test
    void getRandomChallenge_returnsNonNull() {
        GameService.HackChallenge c = gameService.getRandomChallenge();
        assertNotNull(c);
        assertNotNull(c.title);
        assertNotNull(c.reward);
    }
}
