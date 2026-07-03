package com.example.TankWar;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TankGameApplication {

	public static void main(String[] args) {
		// Starts Spring Boot REST API on localhost:8080
		// The Processing sketch (.pde files) runs separately in Processing IDE
		// and communicates with this backend via HTTP calls to /api/game/...
		SpringApplication.run(TankGameApplication.class, args);
	}
}
