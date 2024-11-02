package com.example.TankWar;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import processing.core.PApplet;

@SpringBootApplication
public class TankGameApplication {

	public static void main(String[] args) {
		SpringApplication.run(TankGameApplication.class, args);
		
		 PApplet.main("com.example.tankgame.ui.GameSketch");
	}

}
