package com.example.TankWar.Model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="tanks")
public class Tank {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private int playerId;          
    private int health;            
    private double positionX;      
    private double positionY;      
    private double angle;          
    private double power;          
    private String weaponType;     

    
    public Tank() {}

    public Tank(int playerId, int health, double positionX, double positionY, double angle, double power, String weaponType) {
        this.playerId = playerId;
        this.health = health;
        this.positionX = positionX;
        this.positionY = positionY;
        this.angle = angle;
        this.power = power;
        this.weaponType = weaponType;
    }

	public int getPlayerId() {
		return playerId;
	}

	public void setPlayerId(int playerId) {
		this.playerId = playerId;
	}

	public int getHealth() {
		return health;
	}

	public void setHealth(int health) {
		this.health = health;
	}

	public double getPositionX() {
		return positionX;
	}

	public void setPositionX(double positionX) {
		this.positionX = positionX;
	}

	public double getPositionY() {
		return positionY;
	}

	public void setPositionY(double positionY) {
		this.positionY = positionY;
	}

	public double getAngle() {
		return angle;
	}

	public void setAngle(double angle) {
		this.angle = angle;
	}

	public double getPower() {
		return power;
	}

	public void setPower(double power) {
		this.power = power;
	}

	public String getWeaponType() {
		return weaponType;
	}

	public void setWeaponType(String weaponType) {
		this.weaponType = weaponType;
	}
	
	public void takeDamage(int damage) {
        this.health -= damage;
        if (this.health < 0) {
            this.health = 0;  //  health can not be negative
        }
    }
}
