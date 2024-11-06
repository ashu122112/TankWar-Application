package com.example.TankWar;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import com.example.TankWar.Service.GameService;
import com.example.TankWar.ui.GameSketch;

import processing.core.PApplet;

@SpringBootApplication
public class TankGameApplication {

	public static void main(String[] args) {
		SpringApplication.run(TankGameApplication.class, args);
		
		 
	}
	@Bean
    public PApplet mainSketch(GameService gameService) {
        return new GameSketch(gameService);
    }

}
