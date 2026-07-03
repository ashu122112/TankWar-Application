package com.example.TankWar.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

/**
 * Catches exceptions thrown from GameService and returns proper HTTP responses
 * instead of raw Spring stack traces.
 *
 * Before this fix, any bad request (unknown tank ID, invalid terrain type)
 * returned a 500 with a full stack trace — not appropriate for a portfolio
 * project.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** Tank not found, bad challenge index, unknown terrain/weapon */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(IllegalArgumentException ex) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("error", ex.getMessage()));
    }

    /** No tanks in game — call /api/game/start first */
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<Map<String, String>> handleGameState(IllegalStateException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(Map.of("error", ex.getMessage()));
    }

    /** Catch-all for any unexpected errors */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGeneral(Exception ex) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Unexpected error: " + ex.getMessage()));
    }
}
